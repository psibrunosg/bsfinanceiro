create table public.workspace_preferences (
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  default_cash_account_id uuid,
  primary key (workspace_id, owner_id),
  foreign key (workspace_id, owner_id)
    references public.workspaces(id, owner_id) on delete cascade,
  foreign key (default_cash_account_id, workspace_id, owner_id)
    references public.accounts(id, workspace_id, owner_id)
    on delete set null (default_cash_account_id)
);

alter table public.workspace_preferences enable row level security;

create policy "workspace_preferences_own" on public.workspace_preferences
for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

grant select, insert, update, delete on public.workspace_preferences to authenticated;
