create type public.credit_card_statement_import_status as enum (
  'pending', 'processing', 'imported', 'failed'
);

create table public.credit_card_statement_imports (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  credit_card_id uuid not null,
  storage_path text not null unique,
  file_name text not null check (char_length(btrim(file_name)) between 1 and 120),
  content_type text not null check (content_type in ('application/pdf', 'text/plain')),
  size_bytes integer not null check (size_bytes between 1 and 5242880),
  sha256 text not null check (sha256 ~ '^[a-f0-9]{64}$'),
  status public.credit_card_statement_import_status not null default 'pending',
  error_code text,
  result_purchase_id uuid,
  started_at timestamptz,
  completed_at timestamptz,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, credit_card_id, sha256),
  foreign key (workspace_id, owner_id)
    references public.workspaces(id, owner_id) on delete cascade,
  foreign key (credit_card_id, workspace_id, owner_id)
    references public.credit_cards(id, workspace_id, owner_id) on delete cascade,
  foreign key (result_purchase_id, credit_card_id, workspace_id, owner_id)
    references public.credit_card_purchases(id, credit_card_id, workspace_id, owner_id) on delete restrict,
  check (
    (status = 'pending' and started_at is null and completed_at is null and error_code is null and result_purchase_id is null)
    or (status = 'processing' and started_at is not null and completed_at is null and error_code is null and result_purchase_id is null)
    or (status = 'imported' and started_at is not null and completed_at is not null and error_code is null and result_purchase_id is not null)
    or (status = 'failed' and started_at is not null and completed_at is not null and error_code is not null and result_purchase_id is null)
  )
);

alter table public.credit_card_statement_imports enable row level security;

create policy "credit_card_statement_imports_own"
on public.credit_card_statement_imports for select to authenticated
using ((select auth.uid()) = owner_id);

create trigger credit_card_statement_imports_set_updated_at
before update on public.credit_card_statement_imports
for each row execute function public.set_updated_at();

create index credit_card_statement_imports_card_created_idx
on public.credit_card_statement_imports(credit_card_id, owner_id, created_at desc);

create index credit_card_statement_imports_cleanup_idx
on public.credit_card_statement_imports(expires_at)
where status in ('imported', 'failed');

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'credit-card-statements',
  'credit-card-statements',
  false,
  5242880,
  array['application/pdf', 'text/plain']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "credit_card_statement_upload_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'credit-card-statements'
  and exists (
    select 1
    from public.credit_card_statement_imports i
    where i.storage_path = name
      and i.owner_id = (select auth.uid())
      and i.status = 'pending'
  )
);

create policy "credit_card_statement_read_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'credit-card-statements'
  and exists (
    select 1
    from public.credit_card_statement_imports i
    where i.storage_path = name
      and i.owner_id = (select auth.uid())
  )
);

create policy "credit_card_statement_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'credit-card-statements'
  and exists (
    select 1
    from public.credit_card_statement_imports i
    where i.storage_path = name
      and i.owner_id = (select auth.uid())
      and i.status = 'pending'
  )
);

create or replace function public.create_credit_card_statement_import(
  p_credit_card_id uuid,
  p_file_name text,
  p_content_type text,
  p_size_bytes integer,
  p_sha256 text
)
returns table (id uuid, storage_path text, status public.credit_card_statement_import_status)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_card public.credit_cards%rowtype;
  v_name text := btrim(coalesce(p_file_name, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_content_type not in ('application/pdf', 'text/plain') then raise exception 'unsupported content type' using errcode = '22023'; end if;
  if p_size_bytes not between 1 and 5242880 then raise exception 'file must be between 1 byte and 5 MB' using errcode = '22023'; end if;
  if v_name = '' or char_length(v_name) > 120 then raise exception 'invalid file name' using errcode = '22023'; end if;
  if p_sha256 !~ '^[a-f0-9]{64}$' then raise exception 'invalid file checksum' using errcode = '22023'; end if;

  select * into v_card
  from public.credit_cards
  where id = p_credit_card_id and owner_id = v_user_id and active;
  if not found then raise exception 'active credit card not found' using errcode = 'P0002'; end if;

  insert into public.credit_card_statement_imports (
    workspace_id, owner_id, credit_card_id, storage_path,
    file_name, content_type, size_bytes, sha256
  ) values (
    v_card.workspace_id, v_user_id, v_card.id,
    v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'),
    v_name, p_content_type, p_size_bytes, p_sha256
  ) on conflict (owner_id, credit_card_id, sha256)
  do update set updated_at = public.credit_card_statement_imports.updated_at
  returning credit_card_statement_imports.id, credit_card_statement_imports.storage_path, credit_card_statement_imports.status
  into id, storage_path, status;

  return next;
end;
$$;

create or replace function public.queue_credit_card_statement_import(
  p_import_id uuid
) returns public.credit_card_statement_import_status
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_import public.credit_card_statement_imports%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  select * into v_import from public.credit_card_statement_imports
  where id = p_import_id and owner_id = v_user_id
  for update;
  if not found then raise exception 'import not found' using errcode = 'P0002'; end if;
  if v_import.status <> 'pending' then return v_import.status; end if;
  if not exists (
    select 1 from storage.objects
    where bucket_id = 'credit-card-statements' and name = v_import.storage_path
  ) then raise exception 'uploaded file not found' using errcode = 'P0002'; end if;
  return v_import.status;
end;
$$;

create or replace function public.claim_credit_card_statement_import(
  p_import_id uuid,
  p_owner_id uuid
)
returns public.credit_card_statement_imports
language plpgsql
security definer
set search_path = ''
as $$
declare v_import public.credit_card_statement_imports%rowtype;
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  select * into v_import from public.credit_card_statement_imports
  where id = p_import_id and owner_id = p_owner_id
  for update skip locked;
  if not found then raise exception 'pending import not found' using errcode = 'P0002'; end if;
  if v_import.status <> 'pending' then return v_import; end if;
  update public.credit_card_statement_imports
  set status = 'processing', started_at = now()
  where id = v_import.id
  returning * into v_import;
  return v_import;
end;
$$;

create or replace function public.finish_credit_card_statement_import(
  p_import_id uuid,
  p_status public.credit_card_statement_import_status,
  p_error_code text default null,
  p_purchase_id uuid default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  if p_status not in ('imported', 'failed') then raise exception 'invalid terminal import status' using errcode = '22023'; end if;
  update public.credit_card_statement_imports
  set status = p_status,
      error_code = case when p_status = 'failed' then coalesce(nullif(btrim(p_error_code), ''), 'processing_failed') else null end,
      result_purchase_id = case when p_status = 'imported' then p_purchase_id else null end,
      completed_at = now()
  where id = p_import_id and status = 'processing';
  if not found then raise exception 'processing import not found' using errcode = 'P0002'; end if;
end;
$$;

revoke all on table public.credit_card_statement_imports from public, anon;
grant select on table public.credit_card_statement_imports to authenticated;
revoke all on function public.create_credit_card_statement_import(uuid,text,text,integer,text) from public, anon;
revoke all on function public.queue_credit_card_statement_import(uuid) from public, anon;
grant execute on function public.create_credit_card_statement_import(uuid,text,text,integer,text) to authenticated;
grant execute on function public.queue_credit_card_statement_import(uuid) to authenticated;
revoke all on function public.claim_credit_card_statement_import(uuid,uuid) from public, anon, authenticated;
revoke all on function public.finish_credit_card_statement_import(uuid,public.credit_card_statement_import_status,text,uuid) from public, anon, authenticated;
grant execute on function public.claim_credit_card_statement_import(uuid,uuid) to service_role;
grant execute on function public.finish_credit_card_statement_import(uuid,public.credit_card_statement_import_status,text,uuid) to service_role;
