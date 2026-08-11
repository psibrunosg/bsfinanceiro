-- RETURNS TABLE exposes id/storage_path/status as PL/pgSQL variables; qualify every table reference.
create or replace function public.create_payslip_document_import(
  p_file_name text, p_content_type text, p_size_bytes integer, p_sha256 text
) returns table (id uuid, storage_path text, status public.payslip_document_import_status)
language plpgsql security definer set search_path = '' as $$
declare
  v_user_id uuid := (select auth.uid());
  v_workspace public.workspaces%rowtype;
  v_existing public.payslip_document_imports%rowtype;
  v_name text := btrim(coalesce(p_file_name, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_content_type <> 'application/pdf' or p_size_bytes not between 1 and 10485760 or p_sha256 !~ '^[a-f0-9]{64}$' or v_name = '' or char_length(v_name) > 120 then raise exception 'invalid payslip document' using errcode = '22023'; end if;
  select w.* into v_workspace
  from public.workspaces as w join public.profiles as p on p.id = v_user_id
  where w.id = p.active_workspace_id and w.owner_id = v_user_id;
  if not found then raise exception 'active workspace not found' using errcode = 'P0002'; end if;
  select i.* into v_existing
  from public.payslip_document_imports as i
  where i.workspace_id = v_workspace.id and i.owner_id = v_user_id and i.sha256 = p_sha256
  for update;
  if found then
    if v_existing.status = 'failed' then
      update public.payslip_document_imports as i
      set status = 'pending', error_code = null, started_at = null, completed_at = null, expires_at = now() + interval '7 days'
      where i.id = v_existing.id
      returning i.id, i.storage_path, i.status into id, storage_path, status;
    else
      id := v_existing.id; storage_path := v_existing.storage_path; status := v_existing.status;
    end if;
    return next; return;
  end if;
  insert into public.payslip_document_imports as i (workspace_id, owner_id, storage_path, file_name, content_type, size_bytes, sha256)
  values (v_workspace.id, v_user_id, v_user_id::text || '/' || gen_random_uuid()::text || '/' || regexp_replace(v_name, '[^a-zA-Z0-9._-]', '_', 'g'), v_name, p_content_type, p_size_bytes, p_sha256)
  returning i.id, i.storage_path, i.status into id, storage_path, status;
  return next;
end;
$$;
revoke all on function public.create_payslip_document_import(text,text,integer,text) from public, anon;
grant execute on function public.create_payslip_document_import(text,text,integer,text) to authenticated;
