-- Migration: fix atomic RPCs
-- The original atomic RPCs inserted transactions with status='completed', but
-- public.transaction_status only allows ('planned','pending','paid','cancelled').
-- Runtime would raise invalid enum value. Also record_investment_operation
-- referenced columns that do not exist on investment_operations
-- (type/price/amount) and ticker on investment_assets (the table uses
-- name/operation_type/unit_price). Rewrite the RPCs against the real schema.

create or replace function public.receive_patient_earning(
  p_earning_id uuid,
  p_account_id uuid,
  p_received_date date
) returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_earning public.patient_earnings%rowtype;
  v_transaction_id uuid;
begin
  select * into v_earning from public.patient_earnings where id = p_earning_id for update;
  if not found then
    raise exception 'Earning not found';
  end if;

  if v_earning.status = 'received' then
    return; -- Idempotent
  end if;

  insert into public.transactions (workspace_id, owner_id, account_id, category_id, type, amount, description, competence_date, status, context_id)
  values (v_earning.workspace_id, v_earning.owner_id, p_account_id, null, 'income', v_earning.amount, 'Recebimento de paciente', p_received_date, 'paid', v_earning.context_id)
  returning id into v_transaction_id;

  update public.patient_earnings
  set status = 'received', transaction_id = v_transaction_id
  where id = p_earning_id;
end;
$$;

create or replace function public.register_payslip(
  p_workspace_id uuid,
  p_owner_id uuid,
  p_context_id uuid,
  p_employer text,
  p_competence date,
  p_gross_amount numeric,
  p_discounts_amount numeric,
  p_net_amount numeric,
  p_received_date date,
  p_account_id uuid,
  p_pdf_path text default null,
  p_notes text default null
) returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_payslip_id uuid;
  v_transaction_id uuid;
begin
  if p_received_date is not null and p_account_id is not null then
    insert into public.transactions (workspace_id, owner_id, account_id, category_id, type, amount, description, competence_date, status, context_id)
    values (p_workspace_id, p_owner_id, p_account_id, null, 'income', p_net_amount, 'Contracheque ' || p_employer, p_received_date, 'paid', p_context_id)
    returning id into v_transaction_id;
  end if;

  insert into public.payslips (workspace_id, owner_id, context_id, employer, competence, gross_amount, discounts_amount, net_amount, received_date, transaction_id, pdf_path, notes)
  values (p_workspace_id, p_owner_id, p_context_id, p_employer, p_competence, p_gross_amount, p_discounts_amount, p_net_amount, p_received_date, v_transaction_id, p_pdf_path, p_notes)
  returning id into v_payslip_id;

  return v_payslip_id;
end;
$$;

create or replace function public.record_investment_operation(
  p_asset_id uuid,
  p_account_id uuid,
  p_type text, -- 'buy', 'sell', 'dividend', 'tax', 'fee'
  p_quantity numeric,
  p_price numeric,
  p_amount numeric,
  p_date date
) returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_asset public.investment_assets%rowtype;
  v_transaction_id uuid;
  v_operation_id uuid;
begin
  select * into v_asset from public.investment_assets where id = p_asset_id for update;

  if p_type = 'buy' then
    insert into public.transactions (workspace_id, owner_id, account_id, type, amount, description, competence_date, status, context_id)
    values (v_asset.workspace_id, v_asset.owner_id, p_account_id, 'expense', p_amount, 'Compra de ' || v_asset.name, p_date, 'paid', v_asset.context_id)
    returning id into v_transaction_id;
  elsif p_type = 'sell' or p_type = 'dividend' then
    insert into public.transactions (workspace_id, owner_id, account_id, type, amount, description, competence_date, status, context_id)
    values (v_asset.workspace_id, v_asset.owner_id, p_account_id, 'income', p_amount, (case when p_type = 'sell' then 'Venda de ' else 'Rendimento de ' end) || v_asset.name, p_date, 'paid', v_asset.context_id)
    returning id into v_transaction_id;
  elsif p_type = 'tax' or p_type = 'fee' then
    insert into public.transactions (workspace_id, owner_id, account_id, type, amount, description, competence_date, status, context_id)
    values (v_asset.workspace_id, v_asset.owner_id, p_account_id, 'expense', p_amount, (case when p_type = 'tax' then 'Imposto sobre ' else 'Taxa sobre ' end) || v_asset.name, p_date, 'paid', v_asset.context_id)
    returning id into v_transaction_id;
  end if;

  insert into public.investment_operations (workspace_id, owner_id, context_id, asset_id, operation_type, quantity, unit_price, operation_date, transaction_id)
  values (v_asset.workspace_id, v_asset.owner_id, v_asset.context_id, p_asset_id, p_type, p_quantity, p_price, p_date, v_transaction_id)
  returning id into v_operation_id;

  return v_operation_id;
end;
$$;
