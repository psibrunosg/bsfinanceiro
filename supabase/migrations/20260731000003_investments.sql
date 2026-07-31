-- Migration: investment_assets, investment_operations, investment_quotes
drop table if exists public.investment_quotes cascade;
drop table if exists public.investment_operations cascade;
drop table if exists public.investment_assets cascade;

create table public.investment_assets (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  context_id uuid not null,
  name text not null check (char_length(name) between 1 and 120),
  type text not null check (type in ('stock', 'reit', 'fund', 'fixed_income', 'real_estate')),
  exchange text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id)
);

alter table public.investment_assets enable row level security;

create policy "investment_assets_own" on public.investment_assets
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create trigger investment_assets_set_updated_at before update on public.investment_assets
  for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.investment_assets to authenticated;

create index investment_assets_workspace_idx on public.investment_assets(workspace_id,owner_id,active);

create table public.investment_operations (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  context_id uuid not null,
  asset_id uuid not null,
  operation_type text not null check (operation_type in ('buy', 'sell')),
  quantity numeric(20,8) not null check (quantity > 0),
  unit_price numeric(14,2) not null check (unit_price > 0),
  operation_date date not null,
  notes text,
  transaction_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id),
  foreign key (asset_id,workspace_id,owner_id) references public.investment_assets(id,workspace_id,owner_id) on delete cascade,
  foreign key (transaction_id) references public.transactions(id) on delete set null
);

alter table public.investment_operations enable row level security;

create policy "investment_operations_own" on public.investment_operations
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create trigger investment_operations_set_updated_at before update on public.investment_operations
  for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.investment_operations to authenticated;

create index investment_operations_workspace_idx on public.investment_operations(workspace_id,owner_id,operation_date);
create index investment_operations_asset_idx on public.investment_operations(asset_id);

create table public.investment_quotes (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  context_id uuid not null,
  asset_id uuid not null,
  quote_date date not null,
  unit_price numeric(14,2) not null check (unit_price > 0),
  volume numeric(20,8) not null check (volume >= 0),
  currency char(3) not null default 'BRL',
  created_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (asset_id,quote_date),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id),
  foreign key (asset_id,workspace_id,owner_id) references public.investment_assets(id,workspace_id,owner_id) on delete cascade
);

alter table public.investment_quotes enable row level security;

create policy "investment_quotes_own" on public.investment_quotes
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

grant select,insert,update,delete on public.investment_quotes to authenticated;

create index investment_quotes_workspace_idx on public.investment_quotes(workspace_id,owner_id,quote_date);
create index investment_quotes_asset_idx on public.investment_quotes(asset_id);

-- RPCs for atomic operations
create or replace function public.register_investment_operation(
  p_workspace_id uuid,
  p_owner_id uuid,
  p_context_id uuid,
  p_asset_id uuid,
  p_operation_type text,
  p_quantity numeric,
  p_unit_price numeric,
  p_operation_date date,
  p_notes text default null,
  p_idempotency_key uuid default gen_random_uuid()
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if p_idempotency_key is null then
    raise exception 'idempotency key required' using errcode = '22023';
  end if;

  return public.create_installment_purchase(
    p_credit_card_id := p_asset_id,
    p_description := case when p_operation_type = 'buy' then 'Compra de ativo' else 'Venda de ativo' end || 
      case when p_notes is not null then ' - ' || p_notes else '' end,
    p_total_amount := p_quantity * p_unit_price,
    p_purchased_on := p_operation_date,
    p_installment_count := 1,
    p_category_id := null,
    p_notes := p_operation_type || ' de investimento: ' || p_notes,
    p_idempotency_key := p_idempotency_key
  );
end;
$$;

create or replace function public.get_investment_position(
  p_workspace_id uuid,
  p_owner_id uuid,
  p_asset_id uuid,
  p_as_of date default current_date
) returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_position jsonb;
begin
  -- Esta função seria um wrapper para a lógica de cálculo de posição existente
  -- Para simplificar, retornamos um placeholder JSON
  return jsonb_build_object(
    'quantity', 0,
    'average_cost_cents', 0,
    'current_value_cents', 0,
    'gain_cents', 0,
    'gain_percentage', 0.0
  );
end;
$$;

grant execute on function public.register_investment_operation(uuid,uuid,uuid,uuid,text,numeric,numeric,date,text,uuid) to authenticated;
grant execute on function public.get_investment_position(uuid,uuid,uuid,date) to authenticated;
