alter table public.transactions
  add constraint transactions_id_workspace_owner_unique unique (id,workspace_id,owner_id);

alter table public.credit_card_invoices
  add column payment_transaction_id uuid,
  add column payment_idempotency_key uuid,
  add constraint credit_card_invoices_payment_transaction_fk
    foreign key (payment_transaction_id,workspace_id,owner_id)
    references public.transactions(id,workspace_id,owner_id) on delete restrict,
  add constraint credit_card_invoices_payment_state_check check (
    (status = 'paid' and paid_at is not null and payment_transaction_id is not null and payment_idempotency_key is not null)
    or (status <> 'paid' and paid_at is null and payment_transaction_id is null and payment_idempotency_key is null)
  ),
  add constraint credit_card_invoices_payment_transaction_unique unique (payment_transaction_id),
  add constraint credit_card_invoices_owner_payment_idempotency_unique unique (owner_id,payment_idempotency_key);

create or replace function public.create_installment_purchase(
  p_credit_card_id uuid,
  p_description text,
  p_total_amount numeric,
  p_purchased_on date,
  p_installment_count integer default 1,
  p_category_id uuid default null,
  p_notes text default null,
  p_idempotency_key uuid default gen_random_uuid()
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_card public.credit_cards%rowtype;
  v_purchase_id uuid;
  v_existing public.credit_card_purchases%rowtype;
  v_total_cents bigint;
  v_base_cents bigint;
  v_remainder integer;
  v_number integer;
  v_closing_month date;
  v_closing_date date;
  v_previous_closing date;
  v_due_month date;
  v_due_date date;
  v_invoice_id uuid;
  v_amount numeric(14,2);
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_idempotency_key is null then raise exception 'idempotency key required' using errcode = '22023'; end if;
  if p_purchased_on is null then raise exception 'purchase date required' using errcode = '22023'; end if;
  if char_length(trim(coalesce(p_description,''))) not between 1 and 160 then raise exception 'invalid description' using errcode = '22023'; end if;
  if p_installment_count not between 1 and 120 then raise exception 'invalid installment count' using errcode = '22023'; end if;

  v_total_cents := round(p_total_amount * 100);
  if p_total_amount is null or p_total_amount <> round(p_total_amount,2) or v_total_cents <= 0 then
    raise exception 'amount must be positive with at most two decimal places' using errcode = '22023';
  end if;
  if v_total_cents < p_installment_count then
    raise exception 'each installment must be at least one cent' using errcode = '22023';
  end if;

  select * into v_existing
  from public.credit_card_purchases
  where owner_id = v_user_id and idempotency_key = p_idempotency_key;
  if found then
    if v_existing.credit_card_id <> p_credit_card_id
       or v_existing.description <> trim(p_description)
       or v_existing.total_amount <> p_total_amount
       or v_existing.purchased_on <> p_purchased_on
       or v_existing.installment_count <> p_installment_count
       or v_existing.category_id is distinct from p_category_id then
      raise exception 'idempotency key already used with different purchase data' using errcode = '23505';
    end if;
    return v_existing.id;
  end if;

  select * into v_card from public.credit_cards
  where id = p_credit_card_id and owner_id = v_user_id and active;
  if not found then raise exception 'active credit card not found' using errcode = 'P0002'; end if;

  if p_category_id is not null and not exists (
    select 1 from public.categories
    where id = p_category_id and workspace_id = v_card.workspace_id
      and owner_id = v_user_id and kind = 'expense' and active
  ) then raise exception 'active expense category not found' using errcode = 'P0002'; end if;

  insert into public.credit_card_purchases
    (workspace_id,owner_id,credit_card_id,category_id,description,total_amount,purchased_on,installment_count,notes,idempotency_key)
  values
    (v_card.workspace_id,v_user_id,v_card.id,p_category_id,trim(p_description),p_total_amount,p_purchased_on,p_installment_count,nullif(trim(p_notes),''),p_idempotency_key)
  returning id into v_purchase_id;

  v_base_cents := v_total_cents / p_installment_count;
  v_remainder := (v_total_cents % p_installment_count)::integer;
  v_closing_month := date_trunc('month',p_purchased_on)::date;
  v_closing_date := (v_closing_month + (least(v_card.closing_day,extract(day from (v_closing_month + interval '1 month - 1 day')))::integer - 1))::date;
  if p_purchased_on > v_closing_date then v_closing_month := (v_closing_month + interval '1 month')::date; end if;

  for v_number in 1..p_installment_count loop
    v_closing_month := (v_closing_month + make_interval(months => case when v_number = 1 then 0 else 1 end))::date;
    v_closing_date := (v_closing_month + (least(v_card.closing_day,extract(day from (v_closing_month + interval '1 month - 1 day')))::integer - 1))::date;
    v_previous_closing := ((v_closing_month - interval '1 month')::date
      + (least(v_card.closing_day,extract(day from (v_closing_month - interval '1 day')))::integer - 1))::date;
    v_due_month := case when v_card.due_day > v_card.closing_day then v_closing_month else (v_closing_month + interval '1 month')::date end;
    v_due_date := (v_due_month + (least(v_card.due_day,extract(day from (v_due_month + interval '1 month - 1 day')))::integer - 1))::date;

    insert into public.credit_card_invoices
      (workspace_id,owner_id,credit_card_id,period_start,period_end,closing_date,due_date)
    values
      (v_card.workspace_id,v_user_id,v_card.id,v_previous_closing + 1,v_closing_date,v_closing_date,v_due_date)
    on conflict (credit_card_id,period_start) do update set updated_at = public.credit_card_invoices.updated_at
    returning id into v_invoice_id;

    v_amount := ((v_base_cents + case when v_number <= v_remainder then 1 else 0 end)::numeric / 100)::numeric(14,2);
    insert into public.credit_card_installments
      (workspace_id,owner_id,credit_card_id,purchase_id,invoice_id,installment_number,amount,competence_date)
    values
      (v_card.workspace_id,v_user_id,v_card.id,v_purchase_id,v_invoice_id,v_number,v_amount,v_due_date);
  end loop;
  return v_purchase_id;
end;
$$;

create or replace function public.pay_credit_card_invoice(
  p_invoice_id uuid,
  p_account_id uuid,
  p_paid_on date default current_date,
  p_idempotency_key uuid default gen_random_uuid()
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_invoice public.credit_card_invoices%rowtype;
  v_amount numeric(14,2);
  v_transaction_id uuid;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode = '28000'; end if;
  if p_idempotency_key is null then raise exception 'idempotency key required' using errcode = '22023'; end if;
  if p_paid_on is null then raise exception 'payment date required' using errcode = '22023'; end if;

  select * into v_invoice from public.credit_card_invoices
  where id = p_invoice_id and owner_id = v_user_id
  for update;
  if not found then raise exception 'invoice not found' using errcode = 'P0002'; end if;

  if v_invoice.status = 'paid' then
    if v_invoice.payment_idempotency_key = p_idempotency_key then return v_invoice.payment_transaction_id; end if;
    raise exception 'invoice already paid' using errcode = '23505';
  end if;
  if v_invoice.status = 'cancelled' then raise exception 'cancelled invoice cannot be paid' using errcode = '22023'; end if;
  if not exists (
    select 1 from public.accounts where id = p_account_id
      and workspace_id = v_invoice.workspace_id and owner_id = v_user_id and active
  ) then raise exception 'active payment account not found' using errcode = 'P0002'; end if;

  select coalesce(sum(amount),0)::numeric(14,2) into v_amount
  from public.credit_card_installments
  where invoice_id = v_invoice.id and owner_id = v_user_id;
  if v_amount <= 0 then raise exception 'invoice has no payable installments' using errcode = '22023'; end if;

  insert into public.transactions
    (workspace_id,owner_id,account_id,type,status,description,amount,competence_date,paid_at,notes,idempotency_key)
  values
    (v_invoice.workspace_id,v_user_id,p_account_id,'expense','paid','Pagamento de fatura do cartão',v_amount,v_invoice.due_date,p_paid_on,
     'Pagamento gerado pela fatura ' || v_invoice.id::text,p_idempotency_key)
  returning id into v_transaction_id;

  update public.credit_card_invoices set
    status = 'paid', paid_at = p_paid_on,
    payment_transaction_id = v_transaction_id,
    payment_idempotency_key = p_idempotency_key
  where id = v_invoice.id;
  return v_transaction_id;
end;
$$;

revoke all on function public.create_installment_purchase(uuid,text,numeric,date,integer,uuid,text,uuid) from public,anon;
revoke all on function public.pay_credit_card_invoice(uuid,uuid,date,uuid) from public,anon;
grant execute on function public.create_installment_purchase(uuid,text,numeric,date,integer,uuid,text,uuid) to authenticated;
grant execute on function public.pay_credit_card_invoice(uuid,uuid,date,uuid) to authenticated;
