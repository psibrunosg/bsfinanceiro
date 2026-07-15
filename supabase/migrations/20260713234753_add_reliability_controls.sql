alter table public.fixed_commitments
  add constraint fixed_commitments_id_workspace_owner_unique unique (id,workspace_id,owner_id);

create table public.goal_contributions (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  financial_goal_id uuid not null,
  amount numeric(14,2) not null check (amount > 0),
  contributed_on date not null default current_date,
  note text check (note is null or char_length(btrim(note)) between 1 and 160),
  idempotency_key uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (owner_id,idempotency_key),
  foreign key (workspace_id,owner_id)
    references public.workspaces(id,owner_id) on delete cascade,
  foreign key (financial_goal_id,workspace_id,owner_id)
    references public.financial_goals(id,workspace_id,owner_id) on delete cascade
);

create table public.alert_preferences (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  budget_alerts boolean not null default true,
  goal_alerts boolean not null default true,
  fixed_commitment_alerts boolean not null default true,
  credit_card_alerts boolean not null default true,
  low_balance_alerts boolean not null default true,
  weekly_digest boolean not null default true,
  budget_warning_percent smallint not null default 80
    check (budget_warning_percent between 1 and 100),
  low_balance_amount numeric(14,2) not null default 0
    check (low_balance_amount >= 0),
  weekly_digest_day smallint not null default 1
    check (weekly_digest_day between 0 and 6),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (workspace_id,owner_id),
  foreign key (workspace_id,owner_id)
    references public.workspaces(id,owner_id) on delete cascade
);

create table public.fixed_commitment_occurrences (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  fixed_commitment_id uuid not null,
  occurrence_month date not null,
  due_date date not null,
  description text not null check (char_length(btrim(description)) between 1 and 160),
  amount numeric(14,2) not null check (amount > 0),
  status public.transaction_status not null default 'planned',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (fixed_commitment_id,occurrence_month),
  foreign key (workspace_id,owner_id)
    references public.workspaces(id,owner_id) on delete cascade,
  foreign key (fixed_commitment_id,workspace_id,owner_id)
    references public.fixed_commitments(id,workspace_id,owner_id) on delete cascade,
  check (occurrence_month = date_trunc('month',occurrence_month)::date),
  check (due_date >= occurrence_month
    and due_date < (occurrence_month + interval '1 month')::date)
);

alter table public.goal_contributions enable row level security;
alter table public.alert_preferences enable row level security;
alter table public.fixed_commitment_occurrences enable row level security;

create policy "goal_contributions_own" on public.goal_contributions
for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "alert_preferences_own" on public.alert_preferences
for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "fixed_commitment_occurrences_own" on public.fixed_commitment_occurrences
for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create trigger goal_contributions_set_updated_at
before update on public.goal_contributions
for each row execute function public.set_updated_at();

create trigger alert_preferences_set_updated_at
before update on public.alert_preferences
for each row execute function public.set_updated_at();

create trigger fixed_commitment_occurrences_set_updated_at
before update on public.fixed_commitment_occurrences
for each row execute function public.set_updated_at();

-- Preserve progress created before contributions became the source of truth.
insert into public.goal_contributions (
  workspace_id,owner_id,financial_goal_id,amount,contributed_on,note
)
select workspace_id,owner_id,id,current_amount,created_at::date,'Saldo inicial da meta'
from public.financial_goals
where current_amount > 0;

create or replace function public.enforce_financial_goal_progress()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.current_amount := 0;
  else
    select coalesce(sum(gc.amount),0)
      into new.current_amount
    from public.goal_contributions gc
    where gc.financial_goal_id = new.id
      and gc.workspace_id = new.workspace_id
      and gc.owner_id = new.owner_id;
  end if;

  if new.status <> 'cancelled' and new.current_amount >= new.target_amount then
    new.status := 'completed';
  elsif new.status = 'completed' and new.current_amount < new.target_amount then
    new.status := 'active';
  end if;

  return new;
end;
$$;

create or replace function public.sync_financial_goal_from_contributions()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  target_goal_id uuid := coalesce(new.financial_goal_id,old.financial_goal_id);
  target_workspace_id uuid := coalesce(new.workspace_id,old.workspace_id);
  target_owner_id uuid := coalesce(new.owner_id,old.owner_id);
begin
  update public.financial_goals
  set current_amount = current_amount
  where id = target_goal_id
    and workspace_id = target_workspace_id
    and owner_id = target_owner_id;

  if tg_op = 'UPDATE'
     and (old.financial_goal_id,old.workspace_id,old.owner_id)
         is distinct from
         (new.financial_goal_id,new.workspace_id,new.owner_id) then
    update public.financial_goals
    set current_amount = current_amount
    where id = old.financial_goal_id
      and workspace_id = old.workspace_id
      and owner_id = old.owner_id;
  end if;

  return coalesce(new,old);
end;
$$;

create trigger financial_goals_enforce_progress
before insert or update of target_amount,current_amount,status
on public.financial_goals
for each row execute function public.enforce_financial_goal_progress();

create trigger goal_contributions_sync_goal
after insert or update or delete on public.goal_contributions
for each row execute function public.sync_financial_goal_from_contributions();

create or replace function public.materialize_fixed_commitment_occurrences(
  p_workspace_id uuid,
  p_month date
)
returns setof public.fixed_commitment_occurrences
language plpgsql
security invoker
set search_path = ''
as $$
declare
  caller_id uuid := (select auth.uid());
  normalized_month date := date_trunc('month',p_month)::date;
begin
  if caller_id is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if p_month is null then
    raise exception 'Month is required' using errcode = '22004';
  end if;

  if not exists (
    select 1
    from public.workspaces w
    where w.id = p_workspace_id and w.owner_id = caller_id
  ) then
    raise exception 'Workspace not found' using errcode = 'P0002';
  end if;

  insert into public.fixed_commitment_occurrences (
    workspace_id,owner_id,fixed_commitment_id,occurrence_month,
    due_date,description,amount,status
  )
  select
    fc.workspace_id,
    fc.owner_id,
    fc.id,
    normalized_month,
    least(
      normalized_month + (fc.due_day - 1),
      (normalized_month + interval '1 month - 1 day')::date
    ),
    fc.description,
    fc.amount,
    'planned'::public.transaction_status
  from public.fixed_commitments fc
  where fc.workspace_id = p_workspace_id
    and fc.owner_id = caller_id
    and fc.active
  on conflict (fixed_commitment_id,occurrence_month) do nothing;

  return query
  select occurrence.*
  from public.fixed_commitment_occurrences occurrence
  where occurrence.workspace_id = p_workspace_id
    and occurrence.owner_id = caller_id
    and occurrence.occurrence_month = normalized_month
  order by occurrence.due_date,occurrence.created_at;
end;
$$;

revoke all on function public.enforce_financial_goal_progress() from public,anon,authenticated;
revoke all on function public.sync_financial_goal_from_contributions() from public,anon,authenticated;
revoke all on function public.materialize_fixed_commitment_occurrences(uuid,date) from public,anon;
grant execute on function public.materialize_fixed_commitment_occurrences(uuid,date) to authenticated;

grant select,insert on public.goal_contributions to authenticated;
grant select,insert,update,delete on public.alert_preferences to authenticated;
grant select on public.fixed_commitment_occurrences to authenticated;

create index goal_contributions_goal_date_idx
on public.goal_contributions(financial_goal_id,contributed_on desc,created_at desc);

create index alert_preferences_owner_idx
on public.alert_preferences(owner_id);

create index fixed_commitment_occurrences_workspace_due_idx
on public.fixed_commitment_occurrences(workspace_id,owner_id,due_date,status);
