alter table public.fixed_commitment_occurrences
  add column payment_transaction_id uuid,
  add column payment_idempotency_key uuid,
  add column paid_at date,
  add constraint fixed_commitment_occurrences_payment_transaction_fk
    foreign key (payment_transaction_id,workspace_id,owner_id)
    references public.transactions(id,workspace_id,owner_id) on delete restrict,
  add constraint fixed_commitment_occurrences_payment_state_check check (
    (
      status = 'paid'
      and payment_transaction_id is not null
      and payment_idempotency_key is not null
      and paid_at is not null
    )
    or (
      status <> 'paid'
      and payment_transaction_id is null
      and payment_idempotency_key is null
      and paid_at is null
    )
  ),
  add constraint fixed_commitment_occurrences_payment_transaction_unique
    unique (payment_transaction_id),
  add constraint fixed_commitment_occurrences_owner_payment_idempotency_unique
    unique (owner_id,payment_idempotency_key);

create index fixed_commitment_occurrences_payment_transaction_idx
on public.fixed_commitment_occurrences(payment_transaction_id)
where payment_transaction_id is not null;

create or replace function public.pay_fixed_commitment_occurrence(
  p_occurrence_id uuid,
  p_account_id uuid,
  p_paid_on date default current_date,
  p_idempotency_key uuid default gen_random_uuid()
)
returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_occurrence public.fixed_commitment_occurrences%rowtype;
  v_commitment public.fixed_commitments%rowtype;
  v_existing_transaction_id uuid;
  v_transaction_id uuid;
begin
  if v_user_id is null then
    raise exception 'authentication required' using errcode = '28000';
  end if;
  if p_occurrence_id is null then
    raise exception 'occurrence id required' using errcode = '22023';
  end if;
  if p_account_id is null then
    raise exception 'account id required' using errcode = '22023';
  end if;
  if p_paid_on is null then
    raise exception 'payment date required' using errcode = '22023';
  end if;
  if p_idempotency_key is null then
    raise exception 'idempotency key required' using errcode = '22023';
  end if;

  select occurrence.*
  into v_occurrence
  from public.fixed_commitment_occurrences occurrence
  where occurrence.id = p_occurrence_id
    and occurrence.owner_id = v_user_id
  for update;

  if not found then
    raise exception 'fixed commitment occurrence not found' using errcode = 'P0002';
  end if;

  if v_occurrence.status = 'paid' then
    if v_occurrence.payment_idempotency_key = p_idempotency_key then
      return v_occurrence.payment_transaction_id;
    end if;
    raise exception 'fixed commitment occurrence already paid' using errcode = '23505';
  end if;

  if v_occurrence.status = 'cancelled' then
    raise exception 'cancelled fixed commitment occurrence cannot be paid'
      using errcode = '22023';
  end if;

  if not exists (
    select 1
    from public.workspaces workspace
    where workspace.id = v_occurrence.workspace_id
      and workspace.owner_id = v_user_id
  ) then
    raise exception 'workspace not found' using errcode = 'P0002';
  end if;

  if not exists (
    select 1
    from public.accounts account
    where account.id = p_account_id
      and account.workspace_id = v_occurrence.workspace_id
      and account.owner_id = v_user_id
      and account.active
  ) then
    raise exception 'active payment account not found' using errcode = 'P0002';
  end if;

  select commitment.*
  into v_commitment
  from public.fixed_commitments commitment
  where commitment.id = v_occurrence.fixed_commitment_id
    and commitment.workspace_id = v_occurrence.workspace_id
    and commitment.owner_id = v_user_id;

  if not found then
    raise exception 'fixed commitment not found' using errcode = 'P0002';
  end if;

  select transaction.id
  into v_existing_transaction_id
  from public.transactions transaction
  where transaction.owner_id = v_user_id
    and transaction.idempotency_key = p_idempotency_key;

  if found then
    raise exception 'idempotency key already used for another transaction'
      using errcode = '23505';
  end if;

  insert into public.transactions (
    workspace_id,
    owner_id,
    account_id,
    category_id,
    type,
    status,
    description,
    amount,
    competence_date,
    paid_at,
    notes,
    idempotency_key
  )
  values (
    v_occurrence.workspace_id,
    v_user_id,
    p_account_id,
    v_commitment.category_id,
    'expense',
    'paid',
    v_occurrence.description,
    v_occurrence.amount,
    v_occurrence.due_date,
    p_paid_on,
    'Pagamento gerado pelo compromisso fixo ' || v_occurrence.id::text,
    p_idempotency_key
  )
  returning id into v_transaction_id;

  update public.fixed_commitment_occurrences
  set status = 'paid',
      paid_at = p_paid_on,
      payment_transaction_id = v_transaction_id,
      payment_idempotency_key = p_idempotency_key
  where id = v_occurrence.id
    and workspace_id = v_occurrence.workspace_id
    and owner_id = v_user_id;

  return v_transaction_id;
end;
$$;

revoke all on function public.pay_fixed_commitment_occurrence(uuid,uuid,date,uuid)
from public,anon;
grant execute on function public.pay_fixed_commitment_occurrence(uuid,uuid,date,uuid)
to authenticated;
