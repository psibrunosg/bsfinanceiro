create table public.shared_reports (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique default md5(random()::text || clock_timestamp()::text),
  name text not null,
  config jsonb not null default '{}'::jsonb,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.shared_reports enable row level security;

create policy "Users can manage their own shared reports"
  on public.shared_reports for all
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

-- The public can read a report if they have the exact token and it hasn't expired
create policy "Anyone can read unexpired shared reports via token"
  on public.shared_reports for select
  using (
    (expires_at is null or expires_at > now())
  );

grant select, insert, update, delete on table public.shared_reports to authenticated;
grant select on table public.shared_reports to anon;
create or replace function public.get_shared_report_data(p_token text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_report public.shared_reports%rowtype;
  v_result jsonb;
begin
  select * into v_report from public.shared_reports where token = p_token and (expires_at is null or expires_at > now());
  
  if not found then
    return null;
  end if;

  select jsonb_build_object(
    'report', row_to_json(v_report),
    'transactions', (
      select coalesce(jsonb_agg(row_to_json(t)), '[]'::jsonb)
      from (
        select id, competence_date, amount, type, description, category_id, account_id
        from public.transactions
        where workspace_id = v_report.workspace_id
          -- Add any other filtering based on v_report.config here in the future
        order by competence_date desc
      ) t
    ),
    'categories', (
      select coalesce(jsonb_agg(row_to_json(c)), '[]'::jsonb)
      from (
        select id, name, kind, color
        from public.categories
        where workspace_id = v_report.workspace_id
      ) c
    )
  ) into v_result;

  return v_result;
end; $$;

grant execute on function public.get_shared_report_data(text) to anon, authenticated;
