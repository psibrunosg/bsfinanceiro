-- Migration: patients, patient_earnings, payslips
create table public.patients (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 120),
  context_id uuid not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id)
);

create table public.patient_earnings (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  patient_id uuid not null,
  context_id uuid not null,
  amount numeric(14,2) not null check (amount > 0),
  appointment_date date not null,
  due_date date not null,
  status text not null default 'pending' check (status in ('pending','received','cancelled')),
  transaction_id uuid,
  notes text,
  created_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (patient_id,workspace_id,owner_id) references public.patients(id,workspace_id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id),
  foreign key (transaction_id) references public.transactions(id) on delete set null
);

create table public.payslips (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  context_id uuid not null,
  employer text not null check (char_length(employer) between 1 and 120),
  competence date not null,
  gross_amount numeric(14,2) not null check (gross_amount >= 0),
  discounts_amount numeric(14,2) not null check (discounts_amount >= 0),
  net_amount numeric(14,2) not null check (net_amount >= 0),
  received_date date,
  transaction_id uuid,
  pdf_path text,
  notes text,
  created_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (workspace_id,owner_id,employer,competence),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade,
  foreign key (context_id) references public.financial_contexts(id),
  foreign key (transaction_id) references public.transactions(id) on delete set null
);

alter table public.patients enable row level security;
alter table public.patient_earnings enable row level security;
alter table public.payslips enable row level security;

create policy "patients_own" on public.patients
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "patient_earnings_own" on public.patient_earnings
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create policy "payslips_own" on public.payslips
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create trigger patients_set_updated_at before update on public.patients
  for each row execute function public.set_updated_at();
create trigger patient_earnings_set_updated_at before update on public.patient_earnings
  for each row execute function public.set_updated_at();
create trigger payslips_set_updated_at before update on public.payslips
  for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.patients,public.patient_earnings,public.payslips to authenticated;

create index patients_workspace_idx on public.patients(workspace_id,owner_id,active);
create index patient_earnings_workspace_idx on public.patient_earnings(workspace_id,owner_id,due_date);
create index payslips_workspace_idx on public.payslips(workspace_id,owner_id,competence);
create index payslips_received_idx on public.payslips(workspace_id,owner_id,received_date) where received_date is not null;
