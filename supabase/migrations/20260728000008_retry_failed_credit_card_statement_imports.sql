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
  v_existing public.credit_card_statement_imports%rowtype;
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

  select * into v_existing
  from public.credit_card_statement_imports
  where owner_id = v_user_id and credit_card_id = v_card.id and sha256 = p_sha256
  for update;

  if found then
    if v_existing.status = 'failed' then
      update public.credit_card_statement_imports
      set status = 'pending',
          error_code = null,
          result_purchase_id = null,
          started_at = null,
          completed_at = null,
          expires_at = now() + interval '7 days'
      where id = v_existing.id
      returning credit_card_statement_imports.id, credit_card_statement_imports.storage_path, credit_card_statement_imports.status
      into id, storage_path, status;
    else
      id := v_existing.id;
      storage_path := v_existing.storage_path;
      status := v_existing.status;
    end if;
    return next;
    return;
  end if;

  insert into public.credit_card_statement_imports (
    workspace_id, owner_id, credit_card_id, storage_path,
    file_name, content_type, size_bytes, sha256
  ) values (
    v_card.workspace_id, v_user_id, v_card.id,
    v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'),
    v_name, p_content_type, p_size_bytes, p_sha256
  ) returning credit_card_statement_imports.id, credit_card_statement_imports.storage_path, credit_card_statement_imports.status
    into id, storage_path, status;

  return next;
end;
$$;

revoke all on function public.create_credit_card_statement_import(uuid,text,text,integer,text) from public, anon;
grant execute on function public.create_credit_card_statement_import(uuid,text,text,integer,text) to authenticated;
