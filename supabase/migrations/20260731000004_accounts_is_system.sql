-- Migration: accounts.is_system flag for technical credit card accounts
alter table public.accounts
  add column is_system boolean not null default false;

-- Mark existing credit_card type accounts as system
update public.accounts set is_system = true where type = 'credit_card';

-- Add context_id columns to existing tables, nullable for backward compat
alter table public.transactions add column if not exists context_id uuid references public.financial_contexts(id);
alter table public.fixed_commitments add column if not exists context_id uuid references public.financial_contexts(id);
alter table public.categories add column if not exists context_id uuid references public.financial_contexts(id);
alter table public.monthly_budgets add column if not exists context_id uuid references public.financial_contexts(id);
alter table public.financial_goals add column if not exists context_id uuid references public.financial_contexts(id);
alter table public.credit_card_purchases add column if not exists context_id uuid references public.financial_contexts(id);

-- Backfill context_id to Pessoal for existing data
update public.transactions t
  set context_id = (select id from public.financial_contexts where workspace_id = t.workspace_id and owner_id = t.owner_id and kind = 'pessoal' limit 1)
  where t.context_id is null;

update public.fixed_commitments c
  set context_id = (select id from public.financial_contexts where workspace_id = c.workspace_id and owner_id = c.owner_id and kind = 'pessoal' limit 1)
  where c.context_id is null;

update public.categories cat
  set context_id = (select id from public.financial_contexts where workspace_id = cat.workspace_id and owner_id = cat.owner_id and kind = 'pessoal' limit 1)
  where cat.context_id is null;

-- Index for context queries
create index if not exists transactions_context_idx on public.transactions(workspace_id,owner_id,context_id);
create index if not exists commitments_context_idx on public.fixed_commitments(workspace_id,owner_id,context_id);
create index if not exists categories_context_idx on public.categories(workspace_id,owner_id,context_id);
