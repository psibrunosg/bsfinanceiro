-- A cleanup-pending failed job is a tombstone: only the cleanup worker may release it.

create or replace function public.create_credit_card_statement_import(
  p_credit_card_id uuid, p_file_name text, p_content_type text, p_size_bytes integer, p_sha256 text
) returns table (id uuid, storage_path text, status public.credit_card_statement_import_status)
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_card public.credit_cards%rowtype; v_existing public.credit_card_statement_imports%rowtype; v_name text := btrim(coalesce(p_file_name, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_content_type not in ('application/pdf', 'text/plain') or p_size_bytes not between 1 and 5242880 or v_name = '' or char_length(v_name) > 120 or p_sha256 !~ '^[a-f0-9]{64}$' then raise exception 'invalid statement document' using errcode = '22023'; end if;
  select c.* into v_card from public.credit_cards as c where c.id = p_credit_card_id and c.owner_id = v_user_id and c.active;
  if not found then raise exception 'active credit card not found' using errcode = 'P0002'; end if;
  select i.* into v_existing from public.credit_card_statement_imports as i where i.owner_id = v_user_id and i.credit_card_id = v_card.id and i.sha256 = p_sha256 for update;
  if found then
    if v_existing.error_code = 'cleanup_pending' then raise exception 'statement cleanup is in progress' using errcode = '55000'; end if;
    if v_existing.status = 'failed' then
      update public.credit_card_statement_imports as i set status = 'pending', error_code = null, result_purchase_id = null, started_at = null, completed_at = null, expires_at = now() + interval '7 days' where i.id = v_existing.id returning i.id, i.storage_path, i.status into id, storage_path, status;
    else id := v_existing.id; storage_path := v_existing.storage_path; status := v_existing.status; end if;
    return next; return;
  end if;
  insert into public.credit_card_statement_imports as i (workspace_id, owner_id, credit_card_id, storage_path, file_name, content_type, size_bytes, sha256)
  values (v_card.workspace_id, v_user_id, v_card.id, v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'), v_name, p_content_type, p_size_bytes, p_sha256)
  returning i.id, i.storage_path, i.status into id, storage_path, status;
  return next;
end;
$$;

create or replace function public.prepare_credit_card_statement_import_cleanup(p_import_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare v_import public.credit_card_statement_imports%rowtype;
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  select i.* into v_import from public.credit_card_statement_imports as i where i.id = p_import_id for update;
  if not found then raise exception 'import not found' using errcode = 'P0002'; end if;
  if v_import.error_code = 'cleanup_pending' then return; end if;
  if v_import.expires_at > now() then raise exception 'import is no longer expired' using errcode = '55000'; end if;
  if v_import.status not in ('pending', 'processing', 'failed') then raise exception 'import cannot be cleaned' using errcode = '55000'; end if;
  update public.credit_card_statement_imports as i set status = 'failed', error_code = 'cleanup_pending', started_at = coalesce(i.started_at, now()), completed_at = now() where i.id = v_import.id;
end;
$$;

create or replace function public.finish_credit_card_statement_import_cleanup(p_import_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  update public.credit_card_statement_imports as i set error_code = 'expired', completed_at = now() where i.id = p_import_id and i.status = 'failed' and i.error_code = 'cleanup_pending';
  if not found then raise exception 'cleanup was not prepared' using errcode = '55000'; end if;
end;
$$;

revoke all on function public.prepare_credit_card_statement_import_cleanup(uuid), public.finish_credit_card_statement_import_cleanup(uuid) from public, anon, authenticated;
grant execute on function public.prepare_credit_card_statement_import_cleanup(uuid), public.finish_credit_card_statement_import_cleanup(uuid) to service_role;
