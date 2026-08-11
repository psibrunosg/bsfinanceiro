create or replace function public.delete_payslip(p_payslip_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_user_id uuid := (select auth.uid()); v_payslip public.payslips%rowtype; v_import public.payslip_document_imports%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode='28000'; end if;
  select * into v_payslip from public.payslips where id=p_payslip_id and owner_id=v_user_id for update;
  if not found then raise exception 'payslip not found' using errcode='P0002'; end if;
  select * into v_import from public.payslip_document_imports where result_payslip_id=v_payslip.id and owner_id=v_user_id for update;
  -- Preserve imported result/idempotency before any delete.
  if found and v_import.status = 'imported' then raise exception 'imported payslip cannot be deleted' using errcode='55000'; end if;
  if found then update public.payslip_document_imports set status = 'discarded', result_payslip_id = null, completed_at = now(), error_code = null where id = v_import.id; end if;
  if v_payslip.transaction_id is not null then delete from public.transactions where id=v_payslip.transaction_id and workspace_id=v_payslip.workspace_id and owner_id=v_user_id; end if;
  delete from public.payslips where id=v_payslip.id and workspace_id=v_payslip.workspace_id and owner_id=v_user_id;
  if not found then raise exception 'payslip delete failed' using errcode='P0002'; end if;
end; $$;
