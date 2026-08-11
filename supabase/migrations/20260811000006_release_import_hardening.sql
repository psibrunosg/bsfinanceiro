-- Release hardening for legacy manual payslips and statement imports.

create or replace function public.register_payslip(
  p_workspace_id uuid, p_owner_id uuid, p_context_id uuid, p_employer text,
  p_competence date, p_gross_amount numeric, p_discounts_amount numeric,
  p_net_amount numeric, p_received_date date, p_account_id uuid,
  p_pdf_path text default null, p_notes text default null
) returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_user_id uuid := (select auth.uid()); v_workspace public.workspaces%rowtype;
  v_context public.financial_contexts%rowtype; v_account public.accounts%rowtype;
  v_payslip_id uuid; v_transaction_id uuid; v_employer text := btrim(coalesce(p_employer, ''));
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_workspace_id is not null and p_workspace_id <> (select p.active_workspace_id from public.profiles as p where p.id = v_user_id) then raise exception 'active workspace required' using errcode = '42501'; end if;
  if p_owner_id is not null and p_owner_id <> v_user_id then raise exception 'owner mismatch' using errcode = '42501'; end if;
  if v_employer = '' or char_length(v_employer) > 120 or p_competence is null or p_gross_amount < 0 or p_discounts_amount < 0 or p_net_amount < 0 or p_net_amount <> p_gross_amount - p_discounts_amount or ((p_received_date is null) <> (p_account_id is null)) then raise exception 'invalid payslip' using errcode = '22023'; end if;
  select w.* into v_workspace from public.workspaces as w join public.profiles as p on p.id = v_user_id where w.id = p.active_workspace_id and w.owner_id = v_user_id;
  if not found then raise exception 'active workspace not found' using errcode = 'P0002'; end if;
  select c.* into v_context from public.financial_contexts as c where c.id = p_context_id and c.workspace_id = v_workspace.id and c.owner_id = v_user_id and c.active;
  if not found then raise exception 'active context not found' using errcode = 'P0002'; end if;
  if p_account_id is not null then
    select a.* into v_account from public.accounts as a where a.id = p_account_id and a.workspace_id = v_workspace.id and a.owner_id = v_user_id and a.active and a.type in ('checking', 'cash', 'savings') for update;
    if not found then raise exception 'active cash account not found' using errcode = 'P0002'; end if;
    insert into public.transactions (workspace_id, owner_id, account_id, category_id, type, amount, description, competence_date, paid_at, status, context_id)
    values (v_workspace.id, v_user_id, v_account.id, null, 'income', p_net_amount, 'Contracheque ' || v_employer, p_received_date, p_received_date, 'paid', v_context.id) returning id into v_transaction_id;
  end if;
  insert into public.payslips (workspace_id, owner_id, context_id, employer, competence, gross_amount, discounts_amount, net_amount, received_date, transaction_id, pdf_path, notes)
  values (v_workspace.id, v_user_id, v_context.id, v_employer, p_competence, p_gross_amount, p_discounts_amount, p_net_amount, p_received_date, v_transaction_id, p_pdf_path, p_notes) returning id into v_payslip_id;
  return v_payslip_id;
end;
$$;
revoke all on function public.register_payslip(uuid,uuid,uuid,text,date,numeric,numeric,numeric,date,uuid,text,text) from public, anon, authenticated;
grant execute on function public.register_payslip(uuid,uuid,uuid,text,date,numeric,numeric,numeric,date,uuid,text,text) to authenticated;

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

create or replace function public.finish_credit_card_statement_import_failed(p_import_id uuid, p_error_code text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.role()) <> 'service_role' then raise exception 'service role required' using errcode = '28000'; end if;
  update public.credit_card_statement_imports as i set status = 'failed', error_code = coalesce(nullif(btrim(p_error_code), ''), 'processing_failed'), started_at = coalesce(i.started_at, now()), completed_at = now() where i.id = p_import_id and i.status in ('pending', 'processing');
  if not found then raise exception 'processing import not found' using errcode = 'P0002'; end if;
end;
$$;
revoke all on function public.create_credit_card_statement_import(uuid,text,text,integer,text) from public, anon;
grant execute on function public.create_credit_card_statement_import(uuid,text,text,integer,text) to authenticated;
revoke all on function public.finish_credit_card_statement_import_failed(uuid,text) from public, anon, authenticated;
grant execute on function public.finish_credit_card_statement_import_failed(uuid,text) to service_role;
