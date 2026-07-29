create or replace function public.normalize_transaction_import_description(
  p_description text
)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select translate(
    regexp_replace(lower(btrim(p_description)), '\s+', ' ', 'g'),
    'áàâãäåéèêëíìîïóòôõöúùûüçñ',
    'aaaaaaeeeeiiiiooooouuuucn'
  );
$$;

create index transactions_statement_import_duplicate_idx
on public.transactions (
  owner_id,
  account_id,
  competence_date,
  type,
  amount,
  public.normalize_transaction_import_description(description)
);

create or replace function public.apply_transaction_import_batch(
  p_batch_id uuid
)
returns table (transaction_id uuid)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_batch public.transaction_import_batches%rowtype;
begin
  if v_user_id is null then
    raise exception 'authentication required' using errcode = '28000';
  end if;

  select batch.*
  into v_batch
  from public.transaction_import_batches as batch
  where batch.id = p_batch_id
    and batch.owner_id = v_user_id
  for update;

  if not found then
    raise exception 'transaction import batch not found' using errcode = 'P0002';
  end if;

  if v_batch.status = 'applied' then
    return query
    select item.transaction_id
    from public.transaction_import_items as item
    where item.batch_id = v_batch.id
      and item.workspace_id = v_batch.workspace_id
      and item.owner_id = v_user_id
      and item.status = 'ready'
      and item.transaction_id is not null
    order by item.row_number;
    return;
  end if;

  if v_batch.status <> 'pending' then
    raise exception 'transaction import batch is not pending'
      using errcode = '55000';
  end if;

  if not exists (
    select 1
    from public.accounts as account
    where account.id = v_batch.account_id
      and account.workspace_id = v_batch.workspace_id
      and account.owner_id = v_user_id
      and account.active
      and account.type in ('checking', 'cash', 'savings')
  ) then
    raise exception 'active cash account not found' using errcode = 'P0002';
  end if;

  with ready_items as (
    select
      item.id,
      row_number() over (
        partition by
          item.competence_date,
          item.type,
          item.amount_cents,
          public.normalize_transaction_import_description(item.description)
        order by item.row_number, item.id
      ) as duplicate_rank,
      exists (
        select 1
        from public.transactions as transaction
        where transaction.owner_id = v_user_id
          and transaction.workspace_id = v_batch.workspace_id
          and transaction.account_id = v_batch.account_id
          and transaction.competence_date = item.competence_date
          and transaction.type = item.type
          and transaction.amount = item.amount_cents::numeric / 100
          and public.normalize_transaction_import_description(
            transaction.description
          ) = public.normalize_transaction_import_description(item.description)
      ) as matches_existing_transaction
    from public.transaction_import_items as item
    where item.batch_id = v_batch.id
      and item.workspace_id = v_batch.workspace_id
      and item.owner_id = v_user_id
      and item.status = 'ready'
  )
  update public.transaction_import_items as item
  set status = 'duplicate',
      reason = case
        when ready_items.matches_existing_transaction
          then 'duplicate transaction already exists'
        else 'duplicate row in import batch'
      end,
      transaction_id = null
  from ready_items
  where item.id = ready_items.id
    and (
      ready_items.matches_existing_transaction
      or ready_items.duplicate_rank > 1
    );

  insert into public.transactions (
    workspace_id,
    owner_id,
    account_id,
    type,
    status,
    description,
    amount,
    competence_date,
    paid_at,
    notes,
    idempotency_key
  )
  select
    item.workspace_id,
    item.owner_id,
    v_batch.account_id,
    item.type,
    'paid',
    trim(item.description),
    item.amount_cents::numeric / 100,
    item.competence_date,
    item.competence_date,
    'Importado do lote de extrato ' || v_batch.id::text,
    md5(
      'transaction-import:'
      || item.batch_id::text
      || ':'
      || item.row_number::text
    )::uuid
  from public.transaction_import_items as item
  where item.batch_id = v_batch.id
    and item.workspace_id = v_batch.workspace_id
    and item.owner_id = v_user_id
    and item.status = 'ready'
  order by item.row_number
  on conflict (owner_id, idempotency_key) do nothing;

  update public.transaction_import_items as item
  set transaction_id = transaction.id
  from public.transactions as transaction
  where item.batch_id = v_batch.id
    and item.workspace_id = v_batch.workspace_id
    and item.owner_id = v_user_id
    and item.status = 'ready'
    and transaction.workspace_id = item.workspace_id
    and transaction.owner_id = item.owner_id
    and transaction.idempotency_key = md5(
      'transaction-import:'
      || item.batch_id::text
      || ':'
      || item.row_number::text
    )::uuid;

  if exists (
    select 1
    from public.transaction_import_items as item
    left join public.transactions as transaction
      on transaction.id = item.transaction_id
      and transaction.workspace_id = item.workspace_id
      and transaction.owner_id = item.owner_id
    where item.batch_id = v_batch.id
      and item.workspace_id = v_batch.workspace_id
      and item.owner_id = v_user_id
      and item.status = 'ready'
      and (
        transaction.id is null
        or transaction.account_id is distinct from v_batch.account_id
        or transaction.type is distinct from item.type
        or transaction.status is distinct from 'paid'::public.transaction_status
        or transaction.description is distinct from trim(item.description)
        or transaction.amount is distinct from item.amount_cents::numeric / 100
        or transaction.competence_date is distinct from item.competence_date
        or transaction.paid_at is distinct from item.competence_date
        or transaction.notes is distinct from
          'Importado do lote de extrato ' || v_batch.id::text
      )
  ) then
    raise exception 'transaction import idempotency collision'
      using errcode = '23505';
  end if;

  update public.transaction_import_batches as batch
  set status = 'applied',
      applied_at = now()
  where batch.id = v_batch.id
    and batch.workspace_id = v_batch.workspace_id
    and batch.owner_id = v_user_id
    and batch.status = 'pending';

  return query
  select item.transaction_id
  from public.transaction_import_items as item
  where item.batch_id = v_batch.id
    and item.workspace_id = v_batch.workspace_id
    and item.owner_id = v_user_id
    and item.status = 'ready'
    and item.transaction_id is not null
  order by item.row_number;
end;
$$;

revoke all on function public.normalize_transaction_import_description(text)
from public, anon;
grant execute on function public.normalize_transaction_import_description(text)
to authenticated;
