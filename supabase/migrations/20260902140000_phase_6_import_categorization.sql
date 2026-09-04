-- 1. Create the transaction_category_rules table
create table public.transaction_category_rules (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  pattern text not null,
  category_id uuid not null references public.categories(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.transaction_category_rules enable row level security;

create policy "Users can view their own transaction category rules"
  on public.transaction_category_rules for select
  using (auth.uid() = owner_id);

create policy "Users can insert their own transaction category rules"
  on public.transaction_category_rules for insert
  with check (auth.uid() = owner_id);

create policy "Users can update their own transaction category rules"
  on public.transaction_category_rules for update
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

create policy "Users can delete their own transaction category rules"
  on public.transaction_category_rules for delete
  using (auth.uid() = owner_id);

-- Grants
grant select, insert, update, delete on table public.transaction_category_rules to authenticated;

-- 2. Add category_id to transaction_import_items
alter table public.transaction_import_items
  add column category_id uuid references public.categories(id) on delete set null;

-- 3. Update apply_transaction_import_batch function
-- We just need to drop the old one and re-create it to select category_id
-- We will replace the insert statement.

create or replace function public.apply_transaction_import_batch(p_batch_id uuid)
returns table(transaction_id uuid) language plpgsql security definer set search_path='' as $$
declare
  v_user_id uuid:=(select auth.uid()); 
  v_batch public.transaction_import_batches%rowtype;
begin
  if v_user_id is null then raise exception 'authentication required' using errcode='28000'; end if;
  select batch.* into v_batch from public.transaction_import_batches batch where batch.id=p_batch_id and batch.owner_id=v_user_id for update;
  if not found then raise exception 'transaction import batch not found' using errcode='P0002'; end if;
  if v_batch.status='applied' then 
    return query select item.transaction_id from public.transaction_import_items item where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready' and item.transaction_id is not null order by item.row_number; 
    return; 
  end if;
  if v_batch.status<>'pending' then raise exception 'transaction import batch is not pending' using errcode='55000'; end if;
  if not exists(select 1 from public.accounts account where account.id=v_batch.account_id and account.workspace_id=v_batch.workspace_id and account.owner_id=v_user_id and account.active and account.type in ('checking','cash','savings')) then raise exception 'active cash account not found' using errcode='P0002'; end if;
  
  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text||'|'||v_batch.account_id::text,0));
  
  with ready_items as (
    select item.id,row_number() over(partition by item.competence_date,item.type,item.amount_cents,public.normalize_transaction_import_description(item.description) order by item.row_number,item.id) duplicate_rank,
    exists(select 1 from public.transactions transaction where transaction.owner_id=v_user_id and transaction.workspace_id=v_batch.workspace_id and transaction.account_id=v_batch.account_id and transaction.competence_date=item.competence_date and transaction.type=item.type and transaction.amount=item.amount_cents::numeric/100 and public.normalize_transaction_import_description(transaction.description)=public.normalize_transaction_import_description(item.description)) matches_existing_transaction
    from public.transaction_import_items item where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready'
  ) update public.transaction_import_items item set status='duplicate',reason=case when ready_items.matches_existing_transaction then 'duplicate transaction already exists' else 'duplicate row in import batch' end,transaction_id=null from ready_items where item.id=ready_items.id and (ready_items.matches_existing_transaction or ready_items.duplicate_rank>1);
  
  insert into public.transactions(workspace_id,owner_id,account_id,type,status,description,amount,competence_date,paid_at,notes,category_id,idempotency_key)
  select item.workspace_id,item.owner_id,v_batch.account_id,item.type,'paid',trim(item.description),item.amount_cents::numeric/100,item.competence_date,item.competence_date,'Importado do lote de extrato '||v_batch.id::text,item.category_id,md5('transaction-import:'||item.batch_id::text||':'||item.row_number::text)::uuid 
  from public.transaction_import_items item where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready' order by item.row_number on conflict(owner_id,idempotency_key) do nothing;
  
  update public.transaction_import_items item set transaction_id=transaction.id from public.transactions transaction where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready' and transaction.workspace_id=item.workspace_id and transaction.owner_id=item.owner_id and transaction.idempotency_key=md5('transaction-import:'||item.batch_id::text||':'||item.row_number::text)::uuid;
  
  if exists(select 1 from public.transaction_import_items item left join public.transactions transaction on transaction.id=item.transaction_id and transaction.workspace_id=item.workspace_id and transaction.owner_id=item.owner_id where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready' and (transaction.id is null or transaction.account_id is distinct from v_batch.account_id or transaction.type is distinct from item.type or transaction.status is distinct from 'paid'::public.transaction_status or transaction.description is distinct from trim(item.description) or transaction.amount is distinct from item.amount_cents::numeric/100 or transaction.competence_date is distinct from item.competence_date or transaction.paid_at is distinct from item.competence_date or transaction.notes is distinct from 'Importado do lote de extrato '||v_batch.id::text)) then raise exception 'transaction import idempotency collision' using errcode='23505'; end if;
  
  update public.transaction_import_batches batch set status='applied',applied_at=now() where batch.id=v_batch.id and batch.workspace_id=v_batch.workspace_id and batch.owner_id=v_user_id and batch.status='pending';
  
  return query select item.transaction_id from public.transaction_import_items item where item.batch_id=v_batch.id and item.workspace_id=v_batch.workspace_id and item.owner_id=v_user_id and item.status='ready' and item.transaction_id is not null order by item.row_number;
end; $$;
