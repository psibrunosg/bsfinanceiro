create or replace function public.normalize_payslip_employer(p_value text) returns text
language sql immutable strict set search_path = '' as $$
  select lower(regexp_replace(btrim(p_value), '\s+', ' ', 'g'));
$$;

alter table public.payslips add column employer_key text generated always as (public.normalize_payslip_employer(employer)) stored;
alter table public.payslips add constraint payslips_workspace_owner_employer_key_competence_unique unique (workspace_id, owner_id, employer_key, competence);

alter table public.payslip_document_imports drop constraint payslip_document_imports_owner_id_sha256_key;
alter table public.payslip_document_imports add constraint payslip_document_imports_workspace_owner_sha256_unique unique (workspace_id, owner_id, sha256);

create or replace function public.create_payslip_document_import(p_file_name text, p_content_type text, p_size_bytes integer, p_sha256 text)
returns table (id uuid, storage_path text, status public.payslip_document_import_status)
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_workspace public.workspaces%rowtype; v_existing public.payslip_document_imports%rowtype; v_name text := btrim(coalesce(p_file_name, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_content_type <> 'application/pdf' or p_size_bytes not between 1 and 10485760 or p_sha256 !~ '^[a-f0-9]{64}$' or v_name = '' or char_length(v_name) > 120 then raise exception 'invalid payslip document' using errcode = '22023'; end if;
  select w.* into v_workspace from public.workspaces w join public.profiles p on p.id=v_user_id where w.id=p.active_workspace_id and w.owner_id=v_user_id;
  if not found then raise exception 'active workspace not found' using errcode='P0002'; end if;
  select * into v_existing from public.payslip_document_imports where workspace_id=v_workspace.id and owner_id=v_user_id and sha256=p_sha256 for update;
  if found then
    if v_existing.status = 'failed' then
      update public.payslip_document_imports set status='pending',error_code=null,started_at=null,completed_at=null,expires_at=now()+interval '7 days' where id=v_existing.id
      returning payslip_document_imports.id,payslip_document_imports.storage_path,payslip_document_imports.status into id,storage_path,status;
    else id:=v_existing.id; storage_path:=v_existing.storage_path; status:=v_existing.status; end if;
    return next; return;
  end if;
  insert into public.payslip_document_imports(workspace_id,owner_id,storage_path,file_name,content_type,size_bytes,sha256)
  values(v_workspace.id,v_user_id,v_user_id::text||'/'||gen_random_uuid()::text||'/'||regexp_replace(v_name,'[^a-zA-Z0-9._-]','_','g'),v_name,p_content_type,p_size_bytes,p_sha256)
  returning payslip_document_imports.id,payslip_document_imports.storage_path,payslip_document_imports.status into id,storage_path,status;
  return next;
end; $$;

create or replace function public.apply_payslip_document_import(p_import_id uuid, p_candidate jsonb, p_received_date date, p_account_id uuid, p_context_id uuid) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_import public.payslip_document_imports%rowtype; v_account public.accounts%rowtype; v_context public.financial_contexts%rowtype; v_payslip_id uuid; v_transaction_id uuid; v_employer text; v_competence date; v_gross bigint; v_discounts bigint; v_net bigint; v_hash text;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode='28000'; end if;
  if jsonb_typeof(p_candidate)<>'object' or ((p_received_date is null)<>(p_account_id is null)) or p_context_id is null then raise exception 'invalid payslip confirmation' using errcode='22023'; end if;
  select * into v_import from public.payslip_document_imports where id=p_import_id and owner_id=v_user_id for update;
  if not found then raise exception 'import not found' using errcode='P0002'; end if;
  if not exists (select 1 from public.profiles p where p.id=v_user_id and p.active_workspace_id=v_import.workspace_id) then raise exception 'active workspace mismatch' using errcode='42501'; end if;
  v_hash:=md5(p_candidate::text||coalesce(p_received_date::text,'')||coalesce(p_account_id::text,'')||p_context_id::text);
  if v_import.status='imported' then if v_import.applied_candidate_hash<>v_hash then raise exception 'import already applied with different candidate' using errcode='23505'; end if; return v_import.result_payslip_id; end if;
  if v_import.status<>'pending_review' then raise exception 'import is not ready for review' using errcode='22023'; end if;
  if (p_candidate->>'employer') is null or char_length(btrim(p_candidate->>'employer')) not between 2 and 120 or coalesce(p_candidate->>'competence','') !~ '^[0-9]{4}-[0-9]{2}-01$' or coalesce(p_candidate->>'grossAmountCents','') !~ '^[0-9]+$' or coalesce(p_candidate->>'discountsAmountCents','') !~ '^[0-9]+$' or coalesce(p_candidate->>'netAmountCents','') !~ '^[0-9]+$' or (p_candidate->>'sourceFingerprint') is distinct from v_import.source_fingerprint then raise exception 'invalid payslip candidate' using errcode='22023'; end if;
  v_employer:=btrim(p_candidate->>'employer'); v_competence:=(p_candidate->>'competence')::date; v_gross:=(p_candidate->>'grossAmountCents')::bigint; v_discounts:=(p_candidate->>'discountsAmountCents')::bigint; v_net:=(p_candidate->>'netAmountCents')::bigint;
  if v_gross not between 0 and 999999999999 or v_discounts not between 0 and 999999999999 or v_net<>v_gross-v_discounts then raise exception 'invalid payslip candidate' using errcode='22023'; end if;
  select * into v_context from public.financial_contexts where id=p_context_id and workspace_id=v_import.workspace_id and owner_id=v_user_id and active;
  if not found then raise exception 'active context not found' using errcode='P0002'; end if;
  if p_received_date is not null then select * into v_account from public.accounts where id=p_account_id and workspace_id=v_import.workspace_id and owner_id=v_user_id and active and type in ('checking','cash','savings') for update; if not found then raise exception 'active cash account not found' using errcode='P0002'; end if; end if;
  begin
    if p_received_date is not null then insert into public.transactions(workspace_id,owner_id,account_id,type,status,description,amount,competence_date,paid_at,context_id,idempotency_key) values(v_import.workspace_id,v_user_id,v_account.id,'income','paid','Contracheque '||v_employer,v_net::numeric/100,p_received_date,p_received_date,v_context.id,md5('payslip-document:'||v_import.id::text)::uuid) returning id into v_transaction_id; end if;
    insert into public.payslips(workspace_id,owner_id,context_id,employer,competence,gross_amount,discounts_amount,net_amount,received_date,transaction_id,notes) values(v_import.workspace_id,v_user_id,v_context.id,v_employer,v_competence,v_gross::numeric/100,v_discounts::numeric/100,v_net::numeric/100,p_received_date,v_transaction_id,'Importado de documento '||v_import.id::text) returning id into v_payslip_id;
  exception when unique_violation then raise exception 'duplicate_payslip' using errcode='23505'; end;
  update public.payslip_document_imports set status='imported',result_payslip_id=v_payslip_id,applied_candidate_hash=v_hash,completed_at=now() where id=v_import.id;
  return v_payslip_id;
end; $$;

create or replace function public.delete_payslip(p_payslip_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_payslip public.payslips%rowtype; v_import public.payslip_document_imports%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode='28000'; end if;
  select * into v_payslip from public.payslips where id=p_payslip_id and owner_id=v_user_id for update;
  if not found then raise exception 'payslip not found' using errcode='P0002'; end if;
  select * into v_import from public.payslip_document_imports where result_payslip_id=v_payslip.id and owner_id=v_user_id for update;
  if found then update public.payslip_document_imports set status = 'discarded', result_payslip_id = null, completed_at = now(), error_code = null where id = v_import.id; end if;
  if v_payslip.transaction_id is not null then delete from public.transactions where id=v_payslip.transaction_id and workspace_id=v_payslip.workspace_id and owner_id=v_user_id; end if;
  delete from public.payslips where id=v_payslip.id and workspace_id=v_payslip.workspace_id and owner_id=v_user_id;
  if not found then raise exception 'payslip delete failed' using errcode='P0002'; end if;
end; $$;

revoke all on function public.delete_payslip(uuid) from public, anon;
grant execute on function public.delete_payslip(uuid) to authenticated;
