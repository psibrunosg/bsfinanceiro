create or replace function public.complete_compact_onboarding(
  p_display_name text,
  p_monthly_income numeric,
  p_current_balance numeric,
  p_card_name text,
  p_card_closing_day smallint,
  p_card_due_day smallint
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := (select auth.uid());
  v_workspace_id uuid;
  v_cash_account_id uuid;
  v_card_account_id uuid;
  v_income_category_id uuid;
begin
  if v_user_id is null then raise exception 'authentication required'; end if;
  if char_length(trim(p_display_name)) not between 2 and 60 then raise exception 'invalid display name'; end if;
  if p_monthly_income is null or p_monthly_income <= 0 then raise exception 'invalid monthly income'; end if;
  if p_current_balance is null then raise exception 'invalid current balance'; end if;
  if char_length(trim(p_card_name)) not between 2 and 60 then raise exception 'invalid card name'; end if;
  if p_card_closing_day not between 1 and 31 or p_card_due_day not between 1 and 31 then raise exception 'invalid card day'; end if;

  perform pg_advisory_xact_lock(hashtextextended(v_user_id::text, 0));

  select id into v_workspace_id
  from public.workspaces
  where owner_id = v_user_id and kind = 'personal'
  order by created_at
  limit 1;

  if exists (select 1 from public.profiles where id = v_user_id and onboarding_completed_at is not null) then
    if v_workspace_id is null then raise exception 'completed onboarding has no workspace'; end if;
    return v_workspace_id;
  end if;

  if v_workspace_id is null then
    insert into public.workspaces(owner_id, name, kind)
    values (v_user_id, 'Minhas finanças', 'personal')
    returning id into v_workspace_id;
  end if;

  insert into public.categories(workspace_id, owner_id, name, kind, color)
  values
    (v_workspace_id, v_user_id, 'Salário', 'income', '#087f5b'),
    (v_workspace_id, v_user_id, 'Atendimentos', 'income', '#0f766e'),
    (v_workspace_id, v_user_id, 'Outras receitas', 'income', '#2563eb'),
    (v_workspace_id, v_user_id, 'Moradia', 'expense', '#c2410c'),
    (v_workspace_id, v_user_id, 'Alimentação', 'expense', '#b45309'),
    (v_workspace_id, v_user_id, 'Transporte', 'expense', '#7c3aed'),
    (v_workspace_id, v_user_id, 'Saúde', 'expense', '#be123c'),
    (v_workspace_id, v_user_id, 'Lazer', 'expense', '#0369a1'),
    (v_workspace_id, v_user_id, 'Contas', 'expense', '#475569'),
    (v_workspace_id, v_user_id, 'Outras despesas', 'expense', '#64748b')
  on conflict do nothing;

  select id into v_cash_account_id
  from public.accounts
  where workspace_id = v_workspace_id and owner_id = v_user_id and name = 'Conta principal' and type = 'checking'
  limit 1;
  if v_cash_account_id is null then
    insert into public.accounts(workspace_id, owner_id, name, type, initial_balance)
    values (v_workspace_id, v_user_id, 'Conta principal', 'checking', p_current_balance)
    returning id into v_cash_account_id;
  end if;

  select id into v_income_category_id
  from public.categories
  where workspace_id = v_workspace_id and owner_id = v_user_id and name = 'Salário' and kind = 'income'
  limit 1;
  if not exists (
    select 1 from public.transactions
    where workspace_id = v_workspace_id and account_id = v_cash_account_id and description = 'Renda mensal informada no onboarding'
  ) then
    insert into public.transactions(workspace_id, owner_id, account_id, category_id, type, status, description, amount, competence_date, paid_at)
    values (v_workspace_id, v_user_id, v_cash_account_id, v_income_category_id, 'income', 'paid', 'Renda mensal informada no onboarding', p_monthly_income, current_date, current_date);
  end if;

  select id into v_card_account_id
  from public.accounts
  where workspace_id = v_workspace_id and owner_id = v_user_id and name = trim(p_card_name) and type = 'credit_card'
  limit 1;
  if v_card_account_id is null then
    insert into public.accounts(workspace_id, owner_id, name, type, initial_balance)
    values (v_workspace_id, v_user_id, trim(p_card_name), 'credit_card', 0)
    returning id into v_card_account_id;
  end if;

  if not exists (
    select 1 from public.credit_cards
    where workspace_id = v_workspace_id and owner_id = v_user_id and account_id = v_card_account_id
  ) then
    insert into public.credit_cards(workspace_id, owner_id, account_id, name, credit_limit, closing_day, due_day)
    values (v_workspace_id, v_user_id, v_card_account_id, trim(p_card_name), 0, p_card_closing_day, p_card_due_day);
  end if;

  insert into public.profiles(id, display_name, onboarding_completed_at)
  values (v_user_id, trim(p_display_name), now())
  on conflict (id) do update
  set display_name = excluded.display_name,
      onboarding_completed_at = coalesce(public.profiles.onboarding_completed_at, excluded.onboarding_completed_at);

  return v_workspace_id;
end;
$$;

revoke all on function public.complete_compact_onboarding(text, numeric, numeric, text, smallint, smallint) from public, anon;
grant execute on function public.complete_compact_onboarding(text, numeric, numeric, text, smallint, smallint) to authenticated;
