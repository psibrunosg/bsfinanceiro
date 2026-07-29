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
  import_batch_a uuid;
  duplicate_batch_a uuid;
  discard_batch_a uuid;
  collision_batch_a uuid;
  applied_first uuid[];
  applied_second uuid[];
  transaction_count_after_first integer;
  duplicate_transaction_count integer;
  duplicate_result_count integer;
  failure_transaction_count integer;
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

  insert into public.transaction_import_batches (
    workspace_id,
    owner_id,
    account_id,
    file_name
  )
  values (
    workspace_a,
    user_a,
    transaction_account_a,
    'extrato-a.csv'
  )
  returning id into import_batch_a;

  insert into public.transaction_import_items (
    batch_id,
    workspace_id,
    owner_id,
    row_number,
    competence_date,
    description,
    amount_cents,
    type,
    status,
    fingerprint
  )
  values
    (
      import_batch_a,
      workspace_a,
      user_a,
      2,
      current_date - 1,
      'Receita importada A',
      25050,
      'income',
      'ready',
      'receita-importada-a'
    ),
    (
      import_batch_a,
      workspace_a,
      user_a,
      3,
      current_date,
      'Despesa importada A',
      1099,
      'expense',
      'ready',
      'despesa-importada-a'
    );

  if (select count(*) from public.transactions) <> 1 then
    raise exception 'preview must not create transactions before confirmation';
  end if;

  if (select count(*) from public.workspaces) <> 1 then
    raise exception 'user A should see exactly one workspace';
  end if;

  if (select count(*) from public.transactions) <> 1 then
    raise exception 'user A should see exactly one transaction';
  end if;

  begin
    update public.transaction_import_batches
    set status = 'applied', applied_at = now()
    where id = import_batch_a;
    raise exception 'owner can directly apply a transaction import batch';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    update public.transaction_import_items
    set transaction_id = transaction_a
    where batch_id = import_batch_a;
    raise exception 'owner can directly link a transaction import item';
  exception
    when insufficient_privilege then
      null;
  end;

  begin
    delete from public.transaction_import_items
    where batch_id = import_batch_a;
    raise exception 'owner can directly delete transaction import items';
  exception
    when insufficient_privilege then
      null;
  end;

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

  if exists (
    select 1
    from public.transaction_import_batches
    where id = import_batch_a
  ) then
    raise exception 'user B can read user A transaction import batch';
  end if;

  if exists (
    select 1
    from public.transaction_import_items
    where batch_id = import_batch_a
  ) then
    raise exception 'user B can read user A transaction import items';
  end if;

  begin
    perform *
    from public.apply_transaction_import_batch(import_batch_a);
    raise exception 'user B confirmed user A transaction import batch';
  exception
    when no_data_found or insufficient_privilege then
      null;
  end;

  begin
    perform public.discard_transaction_import_batch(import_batch_a);
    raise exception 'user B discarded user A transaction import batch';
  exception
    when no_data_found or insufficient_privilege then
      null;
  end;

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

  select array_agg(result.transaction_id order by result.transaction_id)
  into applied_first
  from public.apply_transaction_import_batch(import_batch_a) as result;

  select count(*)
  into transaction_count_after_first
  from public.transactions
  where owner_id = user_a
    and workspace_id = workspace_a;

  select array_agg(result.transaction_id order by result.transaction_id)
  into applied_second
  from public.apply_transaction_import_batch(import_batch_a) as result;

  if applied_first is null or cardinality(applied_first) <> 2 then
    raise exception 'confirmation should create exactly two ready transactions';
  end if;

  if applied_first is distinct from applied_second then
    raise exception 'repeated confirmation should return the same transactions';
  end if;

  if not exists (
    select 1
    from public.transaction_import_batches
    where id = import_batch_a
      and status = 'applied'
      and applied_at is not null
      and discarded_at is null
  ) then
    raise exception 'confirmation should mark the batch applied with an applied timestamp';
  end if;

  if (
    select count(*)
    from public.transactions
    where id = any(applied_first)
      and owner_id = user_a
      and workspace_id = workspace_a
  ) <> 2 then
    raise exception 'confirmed import transactions are missing or out of scope';
  end if;

  if (
    select count(*)
    from public.transaction_import_items
    where batch_id = import_batch_a
      and status = 'ready'
      and transaction_id = any(applied_first)
  ) <> 2 then
    raise exception 'ready import items should link to confirmed transactions';
  end if;

  if transaction_count_after_first <> 3 then
    raise exception 'confirmation should add exactly two transactions once';
  end if;

  if (
    select count(*)
    from public.transactions
    where owner_id = user_a
      and workspace_id = workspace_a
  ) <> transaction_count_after_first then
    raise exception 'reapplying an import batch created duplicate transactions';
  end if;

  insert into public.transaction_import_batches (
    workspace_id,
    owner_id,
    account_id,
    file_name
  )
  values (
    workspace_a,
    user_a,
    transaction_account_a,
    'extrato-duplicado-pelo-cliente-a.csv'
  )
  returning id into duplicate_batch_a;

  insert into public.transaction_import_items (
    batch_id,
    workspace_id,
    owner_id,
    row_number,
    competence_date,
    description,
    amount_cents,
    type,
    status,
    fingerprint
  )
  values (
    duplicate_batch_a,
    workspace_a,
    user_a,
    2,
    current_date,
    '  receita a  ',
    10000,
    'income',
    'ready',
    'fingerprint-enviado-pelo-cliente'
  );

  select count(*)
  into duplicate_transaction_count
  from public.transactions
  where owner_id = user_a
    and workspace_id = workspace_a;

  select count(*)
  into duplicate_result_count
  from public.apply_transaction_import_batch(duplicate_batch_a);

  if duplicate_result_count <> 0 then
    raise exception 'client-marked ready duplicate returned a transaction';
  end if;

  if (
    select count(*)
    from public.transactions
    where owner_id = user_a
      and workspace_id = workspace_a
  ) <> duplicate_transaction_count then
    raise exception 'client-marked ready duplicate created a transaction';
  end if;

  if not exists (
    select 1
    from public.transaction_import_batches
    where id = duplicate_batch_a
      and status = 'applied'
      and applied_at is not null
  ) then
    raise exception 'duplicate-only batch should still be applied';
  end if;

  if not exists (
    select 1
    from public.transaction_import_items
    where batch_id = duplicate_batch_a
      and status = 'duplicate'
      and reason = 'duplicate transaction already exists'
      and transaction_id is null
  ) then
    raise exception 'apply should independently mark the client duplicate';
  end if;

  execute 'set local role postgres';

  begin
    insert into public.transaction_import_items (
      batch_id,
      workspace_id,
      owner_id,
      row_number,
      competence_date,
      description,
      amount_cents,
      type,
      status,
      fingerprint
    )
    values (
      import_batch_a,
      workspace_a,
      user_a,
      99,
      current_date,
      'Tentativa terminal',
      1,
      'expense',
      'ready',
      'tentativa-terminal'
    );
    raise exception 'terminal batch accepted an import item';
  exception
    when object_not_in_prerequisite_state then
      null;
  end;

  execute 'set local role authenticated';

  insert into public.transaction_import_batches (
    workspace_id,
    owner_id,
    account_id,
    file_name
  )
  values (
    workspace_a,
    user_a,
    transaction_account_a,
    'extrato-colisao-a.csv'
  )
  returning id into collision_batch_a;

  insert into public.transaction_import_items (
    batch_id,
    workspace_id,
    owner_id,
    row_number,
    competence_date,
    description,
    amount_cents,
    type,
    status,
    fingerprint
  )
  values
    (
      collision_batch_a,
      workspace_a,
      user_a,
      2,
      current_date - 2,
      'Linha que deve sofrer rollback',
      500,
      'expense',
      'ready',
      'rollback-importado-a'
    ),
    (
      collision_batch_a,
      workspace_a,
      user_a,
      3,
      current_date - 1,
      'Colisão previsível',
      1234,
      'expense',
      'ready',
      'colisao-importado-a'
    );

  insert into public.transactions (
    workspace_id,
    owner_id,
    account_id,
    type,
    status,
    description,
    amount,
    competence_date,
    paid_at,
    notes,
    idempotency_key
  )
  values (
    workspace_a,
    user_a,
    transaction_account_a,
    'expense',
    'paid',
    'Colisão de idempotência previsível',
    12.34,
    current_date - 1,
    null,
    'marcador incorreto de colisão',
    md5(
      'transaction-import:'
      || collision_batch_a::text
      || ':3'
    )::uuid
  );

  select count(*)
  into failure_transaction_count
  from public.transactions
  where owner_id = user_a
    and workspace_id = workspace_a;

  begin
    perform *
    from public.apply_transaction_import_batch(collision_batch_a);
    raise exception 'idempotency collision unexpectedly applied a batch';
  exception
    when unique_violation then
      null;
  end;

  if not exists (
    select 1
    from public.transaction_import_batches
    where id = collision_batch_a
      and status = 'pending'
      and applied_at is null
      and discarded_at is null
  ) then
    raise exception 'idempotency collision should leave the batch pending';
  end if;

  if exists (
    select 1
    from public.transaction_import_items
    where batch_id = collision_batch_a
      and transaction_id is not null
  ) then
    raise exception 'idempotency collision should roll back item transaction links';
  end if;

  if (
    select count(*)
    from public.transactions
    where owner_id = user_a
      and workspace_id = workspace_a
  ) <> failure_transaction_count then
    raise exception 'idempotency collision should roll back inserted transactions';
  end if;

  insert into public.transaction_import_batches (
    workspace_id,
    owner_id,
    account_id,
    file_name
  )
  values (
    workspace_a,
    user_a,
    transaction_account_a,
    'extrato-descartado-a.csv'
  )
  returning id into discard_batch_a;

  insert into public.transaction_import_items (
    batch_id,
    workspace_id,
    owner_id,
    row_number,
    status,
    reason
  )
  values (
    discard_batch_a,
    workspace_a,
    user_a,
    2,
    'invalid',
    'linha inválida para o smoke test'
  );

  begin
    insert into public.transaction_import_items (
      batch_id,
      workspace_id,
      owner_id,
      row_number,
      competence_date,
      description,
      amount_cents,
      type,
      status,
      fingerprint
    )
    values (
      discard_batch_a,
      workspace_a,
      user_a,
      3,
      current_date,
      'Valor além da precisão da transação',
      100000000000000,
      'expense',
      'ready',
      'valor-alem-do-limite'
    );
    raise exception 'oversized import amount unexpectedly succeeded';
  exception
    when check_violation then
      null;
  end;

  perform public.discard_transaction_import_batch(discard_batch_a);

  if not exists (
    select 1
    from public.transaction_import_batches
    where id = discard_batch_a
      and status = 'discarded'
      and discarded_at is not null
  ) then
    raise exception 'own pending batch should be marked discarded';
  end if;

  if exists (
    select 1
    from public.transaction_import_items
    where batch_id = discard_batch_a
  ) then
    raise exception 'discarding a pending batch should remove its items';
  end if;

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
