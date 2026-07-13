create type public.credit_card_invoice_status as enum ('open','closed','paid','overdue','cancelled');

create table public.credit_cards (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null,
  name text not null check (char_length(name) between 2 and 60),
  brand text check (brand is null or char_length(brand) between 2 and 30),
  last_four text check (last_four is null or last_four ~ '^[0-9]{4}$'),
  credit_limit numeric(14,2) not null default 0 check (credit_limit >= 0),
  closing_day smallint not null check (closing_day between 1 and 31),
  due_day smallint not null check (due_day between 1 and 31),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (account_id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (account_id,workspace_id,owner_id) references public.accounts(id,workspace_id,owner_id) on delete restrict
);

create table public.credit_card_invoices (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  credit_card_id uuid not null,
  period_start date not null,
  period_end date not null,
  closing_date date not null,
  due_date date not null,
  status public.credit_card_invoice_status not null default 'open',
  paid_at date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (id,credit_card_id,workspace_id,owner_id),
  unique (credit_card_id,period_start),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (credit_card_id,workspace_id,owner_id) references public.credit_cards(id,workspace_id,owner_id) on delete cascade,
  check (period_start <= period_end),
  check (period_end <= closing_date),
  check (closing_date <= due_date),
  check ((status = 'paid' and paid_at is not null) or (status <> 'paid' and paid_at is null))
);

create table public.credit_card_purchases (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  credit_card_id uuid not null,
  category_id uuid,
  description text not null check (char_length(description) between 1 and 160),
  total_amount numeric(14,2) not null check (total_amount > 0),
  purchased_on date not null,
  installment_count smallint not null default 1 check (installment_count between 1 and 120),
  notes text,
  idempotency_key uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (id,credit_card_id,workspace_id,owner_id),
  unique (owner_id,idempotency_key),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (credit_card_id,workspace_id,owner_id) references public.credit_cards(id,workspace_id,owner_id) on delete restrict,
  foreign key (category_id,workspace_id,owner_id) references public.categories(id,workspace_id,owner_id) on delete restrict
);

create table public.credit_card_installments (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  credit_card_id uuid not null,
  purchase_id uuid not null,
  invoice_id uuid,
  installment_number smallint not null check (installment_number > 0),
  amount numeric(14,2) not null check (amount > 0),
  competence_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (purchase_id,installment_number),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (purchase_id,credit_card_id,workspace_id,owner_id) references public.credit_card_purchases(id,credit_card_id,workspace_id,owner_id) on delete cascade,
  foreign key (invoice_id,credit_card_id,workspace_id,owner_id) references public.credit_card_invoices(id,credit_card_id,workspace_id,owner_id) on delete restrict
);

alter table public.credit_cards enable row level security;
alter table public.credit_card_invoices enable row level security;
alter table public.credit_card_purchases enable row level security;
alter table public.credit_card_installments enable row level security;

create policy "credit_cards_own" on public.credit_cards for all to authenticated
using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "credit_card_invoices_own" on public.credit_card_invoices for all to authenticated
using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "credit_card_purchases_own" on public.credit_card_purchases for all to authenticated
using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "credit_card_installments_own" on public.credit_card_installments for all to authenticated
using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);

create trigger credit_cards_set_updated_at before update on public.credit_cards
for each row execute function public.set_updated_at();
create trigger credit_card_invoices_set_updated_at before update on public.credit_card_invoices
for each row execute function public.set_updated_at();
create trigger credit_card_purchases_set_updated_at before update on public.credit_card_purchases
for each row execute function public.set_updated_at();
create trigger credit_card_installments_set_updated_at before update on public.credit_card_installments
for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.credit_cards,public.credit_card_invoices,
public.credit_card_purchases,public.credit_card_installments to authenticated;

create index credit_cards_workspace_idx on public.credit_cards(workspace_id,owner_id,active);
create index credit_card_invoices_card_due_idx on public.credit_card_invoices(credit_card_id,due_date desc);
create index credit_card_invoices_workspace_status_idx on public.credit_card_invoices(workspace_id,owner_id,status,due_date);
create index credit_card_purchases_card_date_idx on public.credit_card_purchases(credit_card_id,purchased_on desc);
create index credit_card_purchases_category_idx on public.credit_card_purchases(category_id);
create index credit_card_installments_invoice_idx on public.credit_card_installments(invoice_id);
create index credit_card_installments_workspace_date_idx on public.credit_card_installments(workspace_id,owner_id,competence_date);
