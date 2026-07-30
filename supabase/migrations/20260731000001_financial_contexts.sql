-- Migration: financial_contexts for Pessoal and Clinica
create type public.financial_context as enum ('pessoal','clinica');

create table public.financial_contexts (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  kind public.financial_context not null,
  name text not null check (char_length(name) between 1 and 40),
  color text not null default '#087f5b' check (color ~ '^#[0-9a-fA-F]{6}$'),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (id,workspace_id,owner_id),
  unique (workspace_id,owner_id,kind),
  foreign key (workspace_id,owner_id) references public.workspaces(id,owner_id) on delete cascade
);

alter table public.financial_contexts enable row level security;

create policy "financial_contexts_own" on public.financial_contexts
  for all to authenticated
  using ((select auth.uid()) = owner_id)
  with check ((select auth.uid()) = owner_id);

create trigger financial_contexts_set_updated_at before update on public.financial_contexts
  for each row execute function public.set_updated_at();

grant select,insert,update,delete on public.financial_contexts to authenticated;

create index financial_contexts_workspace_idx on public.financial_contexts(workspace_id,owner_id,active);

-- Insert default contexts for existing workspaces
insert into public.financial_contexts (workspace_id, owner_id, kind, name, color)
select id, owner_id, 'pessoal'::public.financial_context, 'Pessoal', '#087f5b'
from public.workspaces
where kind = 'personal'
on conflict (workspace_id,owner_id,kind) do nothing;

insert into public.financial_contexts (workspace_id, owner_id, kind, name, color)
select id, owner_id, 'clinica'::public.financial_context, 'Clinica', '#b93636'
from public.workspaces
where kind = 'personal'
on conflict (workspace_id,owner_id,kind) do nothing;
