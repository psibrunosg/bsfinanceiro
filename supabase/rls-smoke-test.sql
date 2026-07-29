begin;

set local role postgres;

insert into auth.users (id, email)
values
  ('00000000-0000-0000-0000-0000000000a1', 'rls-a@example.test'),
  ('00000000-0000-0000-0000-0000000000b2', 'rls-b@example.test');

set local role authenticated;

do $$
declare
  user_a constant uuid := '00000000-0000-0000-0000-0000000000a1';
  user_b constant uuid := '00000000-0000-0000-0000-0000000000b2';
  workspace_a uuid;
  workspace_b uuid;
  account_a uuid;
  transaction_account_a uuid;
  transaction_a uuid;
begin
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);

  workspace_a := public.bootstrap_personal_workspace('Teste A', 'Carteira A', 'understand');

  insert into public.accounts (workspace_id, owner_id, name, type, initial_balance)
  values (workspace_a, user_a, 'Conta A', 'checking', 1000.00)
  returning id into account_a;

  insert into public.workspace_preferences (workspace_id, owner_id, default_cash_account_id)
  values (workspace_a, user_a, account_a);

  insert into public.accounts (workspace_id, owner_id, name, type, initial_balance)
  values (workspace_a, user_a, 'Conta para transações A', 'checking', 0)
  returning id into transaction_account_a;

  insert into public.transactions (workspace_id, owner_id, account_id, type, status, description, amount, competence_date)
  values (workspace_a, user_a, transaction_account_a, 'income', 'paid', 'Receita A', 100.00, current_date)
  returning id into transaction_a;

  if (select count(*) from public.workspaces) <> 1 then
    raise exception 'user A should see exactly one workspace';
  end if;

  if (select count(*) from public.transactions) <> 1 then
    raise exception 'user A should see exactly one transaction';
  end if;

  perform set_config('request.jwt.claim.sub', user_b::text, true);

  workspace_b := public.bootstrap_personal_workspace('Teste B', 'Carteira B', 'save');

  insert into public.accounts (workspace_id, owner_id, name, type, initial_balance)
  values (workspace_b, user_b, 'Conta B', 'checking', 2000.00);

  if (select count(*) from public.workspaces) <> 1 then
    raise exception 'user B should see only own workspace';
  end if;

  if exists (select 1 from public.workspaces where id = workspace_a) then
    raise exception 'user B can read user A workspace';
  end if;

  if exists (select 1 from public.transactions where id = transaction_a) then
    raise exception 'user B can read user A transaction';
  end if;

  if (select count(*) from public.workspace_preferences where owner_id = user_a) <> 0 then
    raise exception 'user B can read user A workspace preference';
  end if;

  update public.workspace_preferences
  set default_cash_account_id = null
  where workspace_id = workspace_a and owner_id = user_a;

  if found then
    raise exception 'user B can update user A workspace preference';
  end if;

  begin
    insert into public.transactions (workspace_id, owner_id, account_id, type, status, description, amount, competence_date)
    values (workspace_a, user_b, account_a, 'expense', 'paid', 'Tentativa cruzada', 10.00, current_date);
    raise exception 'cross-user insert unexpectedly succeeded';
  exception
    when foreign_key_violation or insufficient_privilege or check_violation or with_check_option_violation or object_not_in_prerequisite_state then
      null;
  end;

  perform set_config('request.jwt.claim.sub', user_a::text, true);

  delete from public.accounts
  where id = account_a and workspace_id = workspace_a and owner_id = user_a;

  if (select count(*) from public.workspace_preferences
      where workspace_id = workspace_a
        and owner_id = user_a
        and default_cash_account_id is null) <> 1 then
    raise exception 'deleting default account should preserve preference scope and clear only account reference';
  end if;
end $$;

rollback;
