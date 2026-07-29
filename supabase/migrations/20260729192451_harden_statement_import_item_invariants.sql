alter table public.transaction_import_items
  add constraint transaction_import_items_amount_cents_max
  check (amount_cents is null or amount_cents <= 99999999999999);

create or replace function public.enforce_transaction_import_item_pending_batch()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_batch public.transaction_import_batches%rowtype;
begin
  if v_user_id is null or new.owner_id <> v_user_id then
    raise exception 'transaction import item owner mismatch'
      using errcode = '42501';
  end if;

  select batch.*
  into v_batch
  from public.transaction_import_batches as batch
  where batch.id = new.batch_id
  for key share;

  if not found
     or v_batch.workspace_id <> new.workspace_id
     or v_batch.owner_id <> new.owner_id then
    raise exception 'transaction import batch not found'
      using errcode = 'P0002';
  end if;

  if v_batch.status <> 'pending' then
    raise exception 'transaction import batch is not pending'
      using errcode = '55000';
  end if;

  return new;
end;
$$;

create trigger transaction_import_items_require_pending_batch
before insert or update on public.transaction_import_items
for each row
execute function public.enforce_transaction_import_item_pending_batch();

revoke all on function public.enforce_transaction_import_item_pending_batch()
from public, anon, authenticated;
