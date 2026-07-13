create type public.financial_goal_status as enum ('active','paused','completed','cancelled');

alter table public.categories
  add constraint categories_id_workspace_owner_kind_unique unique (id,workspace_id,owner_id,kind);

create table public.monthly_budgets (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid not null,
  category_kind public.transaction_type not null default 'expense' check (category_kind = 'expense'),
  month date not null,
  amount numeric(14,2) not null check (amount > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (workspace_id,owner_id,category_id,month),
  foreign key (workspace_id,owner_id)
    references public.workspaces(id,owner_id) on delete cascade,
  foreign key (category_id,workspace_id,owner_id,category_kind)
    references public.categories(id,workspace_id,owner_id,kind) on delete restrict,
  check (month = date_trunc('month',month)::date)
);

create table public.financial_goals (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 2 and 100),
  target_amount numeric(14,2) not null check (target_amount > 0),
  current_amount numeric(14,2) not null default 0 check (current_amount >= 0),
  deadline date,
  status public.financial_goal_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id)
    references public.workspaces(id,owner_id) on delete cascade,
  check (status <> 'completed' or current_amount >= target_amount)
);

alter table public.monthly_budgets enable row level security;
alter table public.financial_goals enable row level security;

create policy "monthly_budgets_own" on public.monthly_budgets for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "financial_goals_own" on public.financial_goals for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create trigger monthly_budgets_set_updated_at before update on public.monthly_budgets
for each row execute function public.set_updated_at();

create trigger financial_goals_set_updated_at before update on public.financial_goals
for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.monthly_budgets,public.financial_goals
to authenticated;

create index monthly_budgets_workspace_month_idx
on public.monthly_budgets(workspace_id,owner_id,month);

create index monthly_budgets_category_idx
on public.monthly_budgets(category_id);

create index financial_goals_workspace_status_idx
on public.financial_goals(workspace_id,owner_id,status,deadline);
