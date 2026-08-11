create table public.payslip_document_imports (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null unique,
  file_name text not null check (char_length(btrim(file_name)) between 1 and 120),
  content_type text not null check (content_type = 'application/pdf'),
  size_bytes integer not null check (size_bytes between 1 and 10485760),
  sha256 text not null check (sha256 ~ '^[a-f0-9]{64}$'),
  status public.payslip_document_import_status not null default 'pending',
  employer text check (char_length(btrim(employer)) between 2 and 120),
  competence date,
  gross_amount_cents bigint check (gross_amount_cents between 0 and 999999999999),
  discounts_amount_cents bigint check (discounts_amount_cents between 0 and 999999999999),
  net_amount_cents bigint check (net_amount_cents between 0 and 999999999999),
  parser_name text,
  parser_version text,
  source_fingerprint text check (source_fingerprint is null or source_fingerprint ~ '^[a-f0-9]{64}$'),
  error_code text,
  result_payslip_id uuid,
  applied_candidate_hash text,
  started_at timestamptz,
  completed_at timestamptz,
  expires_at timestamptz not null default (now() + interval '7 days'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, sha256),
  unique (id, workspace_id, owner_id),
  foreign key (workspace_id, owner_id) references public.workspaces(id, owner_id) on delete cascade,
  foreign key (result_payslip_id, workspace_id, owner_id) references public.payslips(id, workspace_id, owner_id) on delete restrict,
  check (
    (status = 'pending' and started_at is null and completed_at is null and error_code is null and result_payslip_id is null)
    or (status = 'processing' and started_at is not null and completed_at is null and error_code is null and result_payslip_id is null)
    or (status = 'pending_review' and started_at is not null and completed_at is not null and error_code is null and result_payslip_id is null
      and employer is not null and competence is not null and gross_amount_cents is not null and discounts_amount_cents is not null and net_amount_cents is not null
      and parser_name = 'payslip' and parser_version is not null and source_fingerprint is not null)
    or (status = 'imported' and started_at is not null and completed_at is not null and error_code is null and result_payslip_id is not null and applied_candidate_hash is not null)
    or (status = 'failed' and started_at is not null and completed_at is not null and error_code is not null and result_payslip_id is null)
    or (status = 'discarded' and completed_at is not null and result_payslip_id is null)
  )
);

alter table public.payslip_document_imports enable row level security;
create policy "payslip_document_imports_own" on public.payslip_document_imports for select to authenticated using ((select auth.uid()) = owner_id);
create trigger payslip_document_imports_set_updated_at before update on public.payslip_document_imports for each row execute function public.set_updated_at();
create index payslip_document_imports_cleanup_idx on public.payslip_document_imports(expires_at, status);

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('payslip-document-imports', 'payslip-document-imports', false, 10485760, array['application/pdf'])
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

create policy "payslip_document_import_upload_own" on storage.objects for insert to authenticated with check (
  bucket_id = 'payslip-document-imports' and exists (
    select 1 from public.payslip_document_imports i where i.storage_path = name and i.owner_id = (select auth.uid()) and i.status = 'pending'
  )
);
create policy "payslip_document_import_read_own" on storage.objects for select to authenticated using (
  bucket_id = 'payslip-document-imports' and exists (select 1 from public.payslip_document_imports i where i.storage_path = name and i.owner_id = (select auth.uid()))
);
create policy "payslip_document_import_delete_own" on storage.objects for delete to authenticated using (
  bucket_id = 'payslip-document-imports' and exists (select 1 from public.payslip_document_imports i where i.storage_path = name and i.owner_id = (select auth.uid()) and i.status = 'pending')
);

create or replace function public.create_payslip_document_import(p_file_name text, p_content_type text, p_size_bytes integer, p_sha256 text)
returns table (id uuid, storage_path text, status public.payslip_document_import_status)
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_workspace public.workspaces%rowtype; v_existing public.payslip_document_imports%rowtype; v_name text := btrim(coalesce(p_file_name, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_content_type <> 'application/pdf' or p_size_bytes not between 1 and 10485760 or p_sha256 !~ '^[a-f0-9]{64}$' or v_name = '' or char_length(v_name) > 120 then raise exception 'invalid payslip document' using errcode = '22023'; end if;
  select w.* into v_workspace from public.workspaces w join public.profiles p on p.id = v_user_id where w.id = p.active_workspace_id and w.owner_id = v_user_id;
  if not found then raise exception 'active workspace not found' using errcode = 'P0002'; end if;
  select * into v_existing from public.payslip_document_imports where owner_id = v_user_id and sha256 = p_sha256 for update;
  if found then
    if v_existing.status = 'failed' then
      update public.payslip_document_imports set status = 'pending', storage_path = v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'), file_name = v_name, error_code = null, started_at = null, completed_at = null, expires_at = now() + interval '7 days' where id = v_existing.id
      returning payslip_document_imports.id, payslip_document_imports.storage_path, payslip_document_imports.status into id, storage_path, status;
    else id := v_existing.id; storage_path := v_existing.storage_path; status := v_existing.status; end if;
    return next; return;
  end if;
  insert into public.payslip_document_imports(workspace_id,owner_id,storage_path,file_name,content_type,size_bytes,sha256)
  values(v_workspace.id,v_user_id,v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'),v_name,p_content_type,p_size_bytes,p_sha256)
  returning payslip_document_imports.id,payslip_document_imports.storage_path,payslip_document_imports.status into id,storage_path,status;
  return next;
end; $$;

create or replace function public.queue_payslip_document_import(p_import_id uuid) returns public.payslip_document_import_status
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_import public.payslip_document_imports%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  select * into v_import from public.payslip_document_imports where id = p_import_id and owner_id = v_user_id for update;
  if not found then raise exception 'import not found' using errcode = 'P0002'; end if;
  if v_import.status <> 'pending' then return v_import.status; end if;
  if not exists (select 1 from storage.objects where bucket_id = 'payslip-document-imports' and name = v_import.storage_path) then raise exception 'uploaded file not found' using errcode = 'P0002'; end if;
  return v_import.status;
end; $$;

create or replace function public.claim_payslip_document_import(p_import_id uuid, p_owner_id uuid) returns public.payslip_document_imports
language plpgsql security definer set search_path = '' as $$
declare v_import public.payslip_document_imports%rowtype;
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  select * into v_import from public.payslip_document_imports where id = p_import_id and owner_id = p_owner_id and expires_at > now() and (status = 'pending' or (status = 'processing' and started_at < now() - interval '10 minutes')) for update skip locked;
  if not found then raise exception 'claimable import not found' using errcode = 'P0002'; end if;
  update public.payslip_document_imports set status = 'processing', started_at = now(), completed_at = null, error_code = null where id = v_import.id returning * into v_import;
  return v_import;
end; $$;

create or replace function public.finish_payslip_document_import_review(p_import_id uuid, p_employer text, p_competence date, p_gross_amount_cents bigint, p_discounts_amount_cents bigint, p_net_amount_cents bigint, p_parser_name text, p_parser_version text, p_source_fingerprint text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  if char_length(btrim(coalesce(p_employer,''))) not between 2 and 120 or p_competence is null or p_competence <> date_trunc('month', p_competence)::date or p_gross_amount_cents is null or p_gross_amount_cents not between 0 and 999999999999 or p_discounts_amount_cents is null or p_discounts_amount_cents not between 0 and 999999999999 or p_net_amount_cents is null or p_net_amount_cents <> p_gross_amount_cents - p_discounts_amount_cents or p_parser_name <> 'payslip' or char_length(coalesce(p_parser_version,'')) not between 1 and 32 or coalesce(p_source_fingerprint, '') !~ '^[a-f0-9]{64}$' then raise exception 'invalid review candidate' using errcode = '22023'; end if;
  update public.payslip_document_imports set status='pending_review',employer=btrim(p_employer),competence=p_competence,gross_amount_cents=p_gross_amount_cents,discounts_amount_cents=p_discounts_amount_cents,net_amount_cents=p_net_amount_cents,parser_name=p_parser_name,parser_version=p_parser_version,source_fingerprint=p_source_fingerprint,completed_at=now(),error_code=null where id=p_import_id and status='processing';
  if not found then raise exception 'processing import not found' using errcode = 'P0002'; end if;
end; $$;

create or replace function public.finish_payslip_document_import_failed(p_import_id uuid, p_error_code text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  update public.payslip_document_imports set status='failed',error_code=coalesce(nullif(btrim(p_error_code),''),'processing_failed'),started_at=coalesce(started_at,now()),completed_at=now() where id=p_import_id and (status = 'processing' or (status = 'pending' and expires_at <= now()));
  if not found then raise exception 'processing import not found' using errcode = 'P0002'; end if;
end; $$;

create or replace function public.discard_payslip_document_import(p_import_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid());
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  update public.payslip_document_imports set status='discarded',completed_at=now(),error_code=null where id=p_import_id and owner_id=v_user_id and status in ('pending','pending_review','failed');
  if not found then raise exception 'import cannot be discarded' using errcode = 'P0002'; end if;
end; $$;

create or replace function public.apply_payslip_document_import(p_import_id uuid, p_candidate jsonb, p_received_date date, p_account_id uuid, p_context_id uuid) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_import public.payslip_document_imports%rowtype; v_account public.accounts%rowtype; v_context public.financial_contexts%rowtype; v_payslip_id uuid; v_transaction_id uuid; v_employer text; v_competence date; v_gross bigint; v_discounts bigint; v_net bigint; v_fingerprint text; v_hash text;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if jsonb_typeof(p_candidate) <> 'object' or ((p_received_date is null) <> (p_account_id is null)) or p_context_id is null then raise exception 'invalid payslip confirmation' using errcode = '22023'; end if;
  select * into v_import from public.payslip_document_imports where id=p_import_id and owner_id=v_user_id for update;
  if not found then raise exception 'import not found' using errcode = 'P0002'; end if;
  v_hash := md5(p_candidate::text || coalesce(p_received_date::text,'') || coalesce(p_account_id::text,'') || p_context_id::text);
  if v_import.status = 'imported' then if v_import.applied_candidate_hash <> v_hash then raise exception 'import already applied with different candidate' using errcode = '23505'; end if; return v_import.result_payslip_id; end if;
  if v_import.status <> 'pending_review' then raise exception 'import is not ready for review' using errcode = '22023'; end if;
  if (p_candidate->>'employer') is null or char_length(btrim(p_candidate->>'employer')) not between 2 and 120 or coalesce(p_candidate->>'competence','') !~ '^[0-9]{4}-[0-9]{2}-01$' or coalesce(p_candidate->>'grossAmountCents','') !~ '^[0-9]+$' or coalesce(p_candidate->>'discountsAmountCents','') !~ '^[0-9]+$' or coalesce(p_candidate->>'netAmountCents','') !~ '^[0-9]+$' or (p_candidate->>'sourceFingerprint') is distinct from v_import.source_fingerprint then raise exception 'invalid payslip candidate' using errcode = '22023'; end if;
  v_employer := btrim(p_candidate->>'employer'); v_competence := (p_candidate->>'competence')::date; v_gross := (p_candidate->>'grossAmountCents')::bigint; v_discounts := (p_candidate->>'discountsAmountCents')::bigint; v_net := (p_candidate->>'netAmountCents')::bigint;
  if v_gross not between 0 and 999999999999 or v_discounts not between 0 and 999999999999 or v_net <> v_gross-v_discounts then raise exception 'invalid payslip candidate' using errcode = '22023'; end if;
  select * into v_context from public.financial_contexts where id=p_context_id and workspace_id=v_import.workspace_id and owner_id=v_user_id and active;
  if not found then raise exception 'active context not found' using errcode = 'P0002'; end if;
  if p_received_date is not null then select * into v_account from public.accounts where id=p_account_id and workspace_id=v_import.workspace_id and owner_id=v_user_id and active and type in ('checking','cash','savings') for update; if not found then raise exception 'active cash account not found' using errcode = 'P0002'; end if; end if;
  if exists (select 1 from public.payslips where workspace_id=v_import.workspace_id and owner_id=v_user_id and employer=v_employer and competence=v_competence) then raise exception 'duplicate_payslip' using errcode = '23505'; end if;
  begin
    if p_received_date is not null then insert into public.transactions(workspace_id,owner_id,account_id,type,status,description,amount,competence_date,paid_at,context_id,idempotency_key) values(v_import.workspace_id,v_user_id,v_account.id,'income','paid','Contracheque ' || v_employer,v_net::numeric/100,p_received_date,p_received_date,v_context.id,md5('payslip-document:'||v_import.id::text)::uuid) returning id into v_transaction_id; end if;
    insert into public.payslips(workspace_id,owner_id,context_id,employer,competence,gross_amount,discounts_amount,net_amount,received_date,transaction_id,notes) values(v_import.workspace_id,v_user_id,v_context.id,v_employer,v_competence,v_gross::numeric/100,v_discounts::numeric/100,v_net::numeric/100,p_received_date,v_transaction_id,'Importado de documento ' || v_import.id::text) returning id into v_payslip_id;
  exception when unique_violation then raise exception 'duplicate_payslip' using errcode='23505'; end;
  update public.payslip_document_imports set status='imported',result_payslip_id=v_payslip_id,applied_candidate_hash=v_hash,completed_at=now() where id=v_import.id;
  return v_payslip_id;
end; $$;

revoke all on table public.payslip_document_imports from public, anon;
grant select on table public.payslip_document_imports to authenticated;
revoke all on function public.create_payslip_document_import(text,text,integer,text), public.queue_payslip_document_import(uuid), public.discard_payslip_document_import(uuid), public.apply_payslip_document_import(uuid,jsonb,date,uuid,uuid) from public, anon;
grant execute on function public.create_payslip_document_import(text,text,integer,text), public.queue_payslip_document_import(uuid), public.discard_payslip_document_import(uuid), public.apply_payslip_document_import(uuid,jsonb,date,uuid,uuid) to authenticated;
revoke all on function public.claim_payslip_document_import(uuid,uuid), public.finish_payslip_document_import_review(uuid,text,date,bigint,bigint,bigint,text,text,text), public.finish_payslip_document_import_failed(uuid,text) from public, anon, authenticated;
grant execute on function public.claim_payslip_document_import(uuid,uuid), public.finish_payslip_document_import_review(uuid,text,date,bigint,bigint,bigint,text,text,text), public.finish_payslip_document_import_failed(uuid,text) to service_role;
