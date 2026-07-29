create type public.transaction_import_batch_status as enum (
  'pending',
  'applied',
  'discarded'
);

create type public.transaction_import_item_status as enum (
  'ready',
  'duplicate',
  'invalid'
);

create table public.transaction_import_batches (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null,
  file_name text not null
    check (char_length(trim(file_name)) between 1 and 255),
  status public.transaction_import_batch_status not null default 'pending',
  created_at timestamptz not null default now(),
  applied_at timestamptz,
  discarded_at timestamptz,
  unique (id, workspace_id, owner_id),
  foreign key (workspace_id, owner_id)
    references public.workspaces(id, owner_id) on delete cascade,
  foreign key (account_id, workspace_id, owner_id)
    references public.accounts(id, workspace_id, owner_id) on delete restrict,
  check (
    (status = 'pending' and applied_at is null and discarded_at is null)
    or (status = 'applied' and applied_at is not null and discarded_at is null)
    or (status = 'discarded' and applied_at is null and discarded_at is not null)
  )
);

create table public.transaction_import_items (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null,
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  row_number integer not null check (row_number > 0),
  competence_date date,
  description text,
  amount_cents bigint,
  type public.transaction_type,
  status public.transaction_import_item_status not null,
  reason text,
  fingerprint text,
  transaction_id uuid,
  created_at timestamptz not null default now(),
  unique (batch_id, row_number),
  foreign key (batch_id, workspace_id, owner_id)
    references public.transaction_import_batches(id, workspace_id, owner_id)
    on delete cascade,
  foreign key (transaction_id, workspace_id, owner_id)
    references public.transactions(id, workspace_id, owner_id)
    on delete restrict,
  check (type is null or type in ('income', 'expense')),
  check (amount_cents is null or amount_cents > 0),
  check (description is null or char_length(trim(description)) between 1 and 160),
  check (
    (
      status in ('ready', 'duplicate')
      and competence_date is not null
      and description is not null
      and amount_cents is not null
      and type is not null
      and nullif(trim(fingerprint), '') is not null
    )
    or (
      status = 'invalid'
      and nullif(trim(reason), '') is not null
    )
  ),
  check (transaction_id is null or status = 'ready')
);

alter table public.transaction_import_batches enable row level security;
alter table public.transaction_import_items enable row level security;

create policy "transaction_import_batches_own"
on public.transaction_import_batches
for all
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "transaction_import_items_own"
on public.transaction_import_items
for all
to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create index transaction_import_batches_workspace_status_idx
on public.transaction_import_batches(
  workspace_id,
  owner_id,
  status,
  created_at desc
);

create index transaction_import_items_batch_status_idx
on public.transaction_import_items(batch_id, status, row_number);

create or replace function public.apply_transaction_import_batch(
  p_batch_id uuid
)
returns table (transaction_id uuid)
language plpgsql
security invoker
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
        or transaction.account_id <> v_batch.account_id
        or transaction.type <> item.type
        or transaction.status <> 'paid'
        or transaction.description <> trim(item.description)
        or transaction.amount <> item.amount_cents::numeric / 100
        or transaction.competence_date <> item.competence_date
        or transaction.paid_at <> item.competence_date
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

create or replace function public.discard_transaction_import_batch(
  p_batch_id uuid
)
returns void
language plpgsql
security invoker
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

  if v_batch.status = 'discarded' then
    return;
  end if;

  if v_batch.status <> 'pending' then
    raise exception 'transaction import batch is not pending'
      using errcode = '55000';
  end if;

  delete from public.transaction_import_items as item
  where item.batch_id = v_batch.id
    and item.workspace_id = v_batch.workspace_id
    and item.owner_id = v_user_id;

  update public.transaction_import_batches as batch
  set status = 'discarded',
      discarded_at = now()
  where batch.id = v_batch.id
    and batch.workspace_id = v_batch.workspace_id
    and batch.owner_id = v_user_id
    and batch.status = 'pending';
end;
$$;

revoke all on table public.transaction_import_batches from public, anon;
revoke all on table public.transaction_import_items from public, anon;

grant select, insert, update, delete
on table public.transaction_import_batches
to authenticated;

grant select, insert, update, delete
on table public.transaction_import_items
to authenticated;

revoke all on function public.apply_transaction_import_batch(uuid)
from public, anon;
revoke all on function public.discard_transaction_import_batch(uuid)
from public, anon;

grant execute on function public.apply_transaction_import_batch(uuid)
to authenticated;
grant execute on function public.discard_transaction_import_batch(uuid)
to authenticated;
