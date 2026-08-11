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
  parallel_first_batch_a uuid;
  parallel_second_batch_a uuid;
  discard_batch_a uuid;
  collision_batch_a uuid;
  applied_first uuid[];
  applied_second uuid[];
  transaction_count_after_first integer;
  duplicate_transaction_count integer;
  duplicate_result_count integer;
  parallel_first_result_count integer;
  parallel_second_result_count integer;
  parallel_transaction_count integer;
  failure_transaction_count integer;
  statement_card_a uuid;
  statement_import_a uuid;
  statement_import_atomic uuid;
  statement_first uuid[];
  statement_replay uuid[];
  statement_purchase_count integer;
  context_a uuid;
  payslip_import_a uuid;
  payslip_import_income_a uuid;
  payslip_duplicate_import_a uuid;
  payslip_manual_a uuid;
  payslip_first uuid;
  payslip_replay uuid;
  payslip_income_a uuid;
  payslip_income_transaction_a uuid;
  payslip_transaction_count integer;
  payslip_manual_hardened_a uuid;
  legacy_card_a uuid;
  legacy_patient_a uuid;
  legacy_earning_a uuid;
  mutation_count integer;
begin
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);

  workspace_a := public.bootstrap_personal_workspace('Teste A', 'Carteira A', 'understand');

  insert into public.financial_contexts (workspace_id, owner_id, kind, name, color)
  values (workspace_a, user_a, 'pessoal', 'Pessoal', '#087f5b')
  on conflict (workspace_id, owner_id, kind) do nothing;

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
    '  Rêcéita--A!!' || chr(6832) || '  ',
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
    'extrato-primeiro-lote-concorrente-a.csv'
  )
  returning id into parallel_first_batch_a;

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
    parallel_first_batch_a,
    workspace_a,
    user_a,
    2,
    current_date - 5,
    'Compra Única--Concorrente',
    3210,
    'expense',
    'ready',
    'compra-unica-concorrente'
  );

  select count(*)
  into parallel_first_result_count
  from public.apply_transaction_import_batch(parallel_first_batch_a);

  if parallel_first_result_count <> 1 then
    raise exception 'first distinct import batch should create one transaction';
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
    'extrato-segundo-lote-concorrente-a.csv'
  )
  returning id into parallel_second_batch_a;

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
    parallel_second_batch_a,
    workspace_a,
    user_a,
    2,
    current_date - 5,
    'compra unica concorrente',
    3210,
    'expense',
    'ready',
    'compra-unica-concorrente-cliente'
  );

  select count(*)
  into parallel_second_result_count
  from public.apply_transaction_import_batch(parallel_second_batch_a);

  if parallel_second_result_count <> 0 then
    raise exception 'second distinct import batch should be deduplicated';
  end if;

  select count(*)
  into parallel_transaction_count
  from public.transactions
  where owner_id = user_a
    and workspace_id = workspace_a
    and account_id = transaction_account_a
    and competence_date = current_date - 5
    and type = 'expense'
    and amount = 32.10
    and public.normalize_transaction_import_description(description)
      = 'compra unica concorrente';

  if parallel_transaction_count <> 1 then
    raise exception 'distinct identical batches created duplicate transactions';
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

  insert into public.credit_cards (workspace_id, owner_id, account_id, name, credit_limit, closing_day, due_day)
  values (workspace_a, user_a, transaction_account_a, 'Cartão de smoke A', 1000, 15, 22)
  returning id into statement_card_a;
  select id into statement_import_a from public.create_credit_card_statement_import(
    statement_card_a, 'fatura-a.pdf', 'application/pdf', 100, repeat('a', 64)
  );
  perform set_config('request.jwt.claim.role', 'service_role', true);
  perform set_config('role', 'service_role', true);
  perform public.claim_credit_card_statement_import(statement_import_a, user_a);
  perform public.finish_credit_card_statement_import_review(
    statement_import_a, 'santander', '1', current_date, current_date + 7, 1000,
    jsonb_build_array(jsonb_build_object(
      'ordinal', 1, 'purchasedOn', current_date::text, 'description', 'Compra de smoke A',
      'installmentAmountCents', 1000, 'installmentNumber', 1, 'installmentCount', 1,
      'totalAmountCents', 1000, 'needsReview', false, 'sourceFingerprint', repeat('b', 64)
    ))
  );
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  update public.credit_card_statement_import_items
  set description = 'mutação indevida'
  where import_id = statement_import_a;
  get diagnostics mutation_count = row_count;
  if mutation_count <> 0 then
    raise exception 'owner can directly mutate protected statement candidates';
  end if;
  perform set_config('request.jwt.claim.sub', user_b::text, true);
  if exists (select 1 from public.credit_card_statement_imports where id = statement_import_a)
    or exists (select 1 from public.credit_card_statement_import_items where import_id = statement_import_a) then
    raise exception 'user B can read user A statement review';
  end if;
  begin
    perform public.apply_credit_card_statement_import(statement_import_a, jsonb_build_array(jsonb_build_object(
      'ordinal', 1, 'purchasedOn', current_date::text, 'description', 'Compra de smoke A',
      'installmentAmountCents', 1000, 'installmentNumber', 1, 'installmentCount', 1,
      'totalAmountCents', 1000, 'sourceFingerprint', repeat('b', 64)
    )));
    raise exception 'user B can apply user A statement review';
  exception when no_data_found or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  select public.apply_credit_card_statement_import(statement_import_a, jsonb_build_array(jsonb_build_object(
    'ordinal', 1, 'purchasedOn', current_date::text, 'description', 'Compra de smoke A',
    'installmentAmountCents', 1000, 'installmentNumber', 1, 'installmentCount', 1,
    'totalAmountCents', 1000, 'sourceFingerprint', repeat('b', 64)
  ))) into statement_first;
  select public.apply_credit_card_statement_import(statement_import_a, jsonb_build_array(jsonb_build_object(
    'ordinal', 1, 'purchasedOn', current_date::text, 'description', 'Compra de smoke A',
    'installmentAmountCents', 1000, 'installmentNumber', 1, 'installmentCount', 1,
    'totalAmountCents', 1000, 'sourceFingerprint', repeat('b', 64)
  ))) into statement_replay;
  if statement_first is distinct from statement_replay or cardinality(statement_first) <> 1 then raise exception 'statement replay must return the original purchase'; end if;
  if exists (select 1 from public.transactions where owner_id = user_a and description like 'Pagamento de fatura%') then raise exception 'statement apply created a cash payment'; end if;

  select id into statement_import_atomic from public.create_credit_card_statement_import(statement_card_a, 'fatura-atomica.pdf', 'application/pdf', 101, repeat('c', 64));
  perform set_config('request.jwt.claim.role', 'service_role', true);
  perform set_config('role', 'service_role', true);
  perform public.claim_credit_card_statement_import(statement_import_atomic, user_a);
  perform public.finish_credit_card_statement_import_review(statement_import_atomic, 'santander', '1', current_date, current_date + 7, 2000, jsonb_build_array(
    jsonb_build_object('ordinal',1,'purchasedOn',current_date::text,'description','Atômica um','installmentAmountCents',1000,'installmentNumber',1,'installmentCount',1,'totalAmountCents',1000,'needsReview',false,'sourceFingerprint',repeat('d',64)),
    jsonb_build_object('ordinal',2,'purchasedOn',current_date::text,'description','Atômica dois','installmentAmountCents',1000,'installmentNumber',1,'installmentCount',1,'totalAmountCents',1000,'needsReview',false,'sourceFingerprint',repeat('e',64))
  ));
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  select count(*) into statement_purchase_count from public.credit_card_purchases where credit_card_id = statement_card_a;
  begin
    perform public.apply_credit_card_statement_import(statement_import_atomic, jsonb_build_array(
      jsonb_build_object('ordinal',1,'purchasedOn',current_date::text,'description','Atômica um','installmentAmountCents',1000,'installmentNumber',1,'installmentCount',1,'totalAmountCents',1000,'sourceFingerprint',repeat('d',64)),
      jsonb_build_object('ordinal',2,'purchasedOn',current_date::text,'description','Atômica dois','installmentAmountCents',1000,'installmentNumber',1,'installmentCount',1,'totalAmountCents',999,'sourceFingerprint',repeat('e',64))
    ));
    raise exception 'invalid statement item unexpectedly applied';
  exception when data_exception then null;
  end;
  if (select count(*) from public.credit_card_purchases where credit_card_id = statement_card_a) <> statement_purchase_count or not exists (select 1 from public.credit_card_statement_imports where id = statement_import_atomic and status = 'pending_review') then raise exception 'statement apply must be atomic'; end if;

  select id into context_a from public.financial_contexts where workspace_id = workspace_a and owner_id = user_a and active order by kind limit 1;
  if context_a is null then raise exception 'smoke workspace needs an active financial context'; end if;
  select public.create_credit_card(workspace_a, user_a, 'Cartao legacy smoke A', 1000, 10, 20, null, null) into legacy_card_a;
  if not exists (select 1 from public.credit_cards where id = legacy_card_a and workspace_id = workspace_a and owner_id = user_a) then raise exception 'legacy card owner path failed'; end if;
  insert into public.patients(workspace_id, owner_id, full_name, context_id) values (workspace_a, user_a, 'Paciente legacy smoke A', context_a) returning id into legacy_patient_a;
  insert into public.patient_earnings(workspace_id, owner_id, patient_id, context_id, amount, appointment_date, due_date) values (workspace_a, user_a, legacy_patient_a, context_a, 100, current_date, current_date) returning id into legacy_earning_a;
  perform set_config('request.jwt.claim.sub', user_b::text, true);
  begin
    perform public.create_credit_card(workspace_a, user_a, 'Cartao cruzado', 1000, 10, 20, null, null);
    raise exception 'user B can create a card for user A';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.receive_patient_earning(legacy_earning_a, transaction_account_a, current_date);
    raise exception 'user B can receive user A earning';
  exception when no_data_found or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claim.role', 'anon', true);
  begin
    perform public.create_credit_card(workspace_a, user_a, 'Cartao anonimo', 1000, 10, 20, null, null);
    raise exception 'anonymous card creation unexpectedly succeeded';
  exception when invalid_authorization_specification or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform public.receive_patient_earning(legacy_earning_a, transaction_account_a, current_date);
  if not exists (select 1 from public.patient_earnings where id = legacy_earning_a and status = 'received' and transaction_id is not null) then raise exception 'legacy earning owner path failed'; end if;
  select public.register_payslip(workspace_a, user_a, context_a, 'Manual hardening smoke A', date_trunc('month', current_date - interval '3 months')::date, 1000, 100, 900, null, null, null, null) into payslip_manual_hardened_a;
  if not exists (select 1 from public.payslips where id = payslip_manual_hardened_a and owner_id = user_a and workspace_id = workspace_a) then raise exception 'manual register_payslip owner path failed'; end if;
  perform set_config('request.jwt.claim.sub', user_b::text, true);
  begin
    perform public.register_payslip(workspace_a, user_a, context_a, 'Tentativa cruzada', date_trunc('month', current_date - interval '4 months')::date, 1000, 100, 900, null, null, null, null);
    raise exception 'user B can register a payslip for user A';
  exception when insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claim.role', 'anon', true);
  perform set_config('role', 'anon', true);
  begin
    perform public.register_payslip(workspace_a, user_a, context_a, 'Tentativa anonima', date_trunc('month', current_date - interval '5 months')::date, 1000, 100, 900, null, null, null, null);
    raise exception 'anonymous register_payslip unexpectedly succeeded';
  exception when invalid_authorization_specification or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  select id into payslip_import_a from public.create_payslip_document_import('contracheque-a.pdf', 'application/pdf', 100, repeat('f', 64));
  perform set_config('request.jwt.claim.role', 'service_role', true);
  perform set_config('role', 'service_role', true);
  perform public.claim_payslip_document_import(payslip_import_a, user_a);
  perform public.finish_payslip_document_import_review(payslip_import_a, 'Empregador smoke A', date_trunc('month', current_date)::date, 500000, 125000, 375000, 'payslip', '1', repeat('1', 64));
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  update public.payslip_document_imports
  set status = 'imported'
  where id = payslip_import_a;
  get diagnostics mutation_count = row_count;
  if mutation_count <> 0 then
    raise exception 'owner can directly mutate protected payslip import';
  end if;
  perform set_config('request.jwt.claim.sub', user_b::text, true);
  if exists (select 1 from public.payslip_document_imports where id = payslip_import_a) then raise exception 'user B can read user A payslip import'; end if;
  begin
    perform public.apply_payslip_document_import(payslip_import_a, '{}'::jsonb, null, null, context_a);
    raise exception 'user B can apply user A payslip import';
  exception when no_data_found or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  select public.apply_payslip_document_import(payslip_import_a, jsonb_build_object('employer','Empregador smoke A','competence',date_trunc('month',current_date)::date::text,'grossAmountCents',500000,'discountsAmountCents',125000,'netAmountCents',375000,'sourceFingerprint',repeat('1',64)), null, null, context_a) into payslip_first;
  select public.apply_payslip_document_import(payslip_import_a, jsonb_build_object('employer','Empregador smoke A','competence',date_trunc('month',current_date)::date::text,'grossAmountCents',500000,'discountsAmountCents',125000,'netAmountCents',375000,'sourceFingerprint',repeat('1',64)), null, null, context_a) into payslip_replay;
  if payslip_first is distinct from payslip_replay or exists (select 1 from public.payslips where id=payslip_first and transaction_id is not null) then raise exception 'payslip replay without cash must be durable and transaction-free'; end if;
  select count(*) into payslip_transaction_count from public.transactions where workspace_id=workspace_a and owner_id=user_a;
  select id into payslip_import_income_a from public.create_payslip_document_import('contracheque-renda-a.pdf', 'application/pdf', 101, repeat('2', 64));
  perform set_config('request.jwt.claim.role', 'service_role', true);
  perform set_config('role', 'service_role', true);
  perform public.claim_payslip_document_import(payslip_import_income_a, user_a);
  perform public.finish_payslip_document_import_review(payslip_import_income_a, 'Empregador smoke renda A', date_trunc('month', current_date - interval '1 month')::date, 300000, 50000, 250000, 'payslip', '1', repeat('3', 64));
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  select public.apply_payslip_document_import(payslip_import_income_a, jsonb_build_object('employer','Empregador smoke renda A','competence',date_trunc('month',current_date - interval '1 month')::date::text,'grossAmountCents',300000,'discountsAmountCents',50000,'netAmountCents',250000,'sourceFingerprint',repeat('3',64)), current_date, transaction_account_a, context_a) into payslip_income_a;
  select transaction_id into payslip_income_transaction_a from public.payslips where id=payslip_income_a;
  if (select count(*) from public.transactions where workspace_id=workspace_a and owner_id=user_a) <> payslip_transaction_count + 1 then raise exception 'payslip with account and date must create one income transaction'; end if;

  insert into public.payslips (workspace_id, owner_id, context_id, employer, competence, gross_amount, discounts_amount, net_amount)
  values (workspace_a, user_a, context_a, 'Empregador Manual Canonico', date_trunc('month', current_date - interval '2 months')::date, 1000, 100, 900)
  returning id into payslip_manual_a;
  select id into payslip_duplicate_import_a from public.create_payslip_document_import('contracheque-duplicado.pdf', 'application/pdf', 102, repeat('4', 64));
  perform set_config('request.jwt.claim.role', 'service_role', true);
  perform set_config('role', 'service_role', true);
  perform public.claim_payslip_document_import(payslip_duplicate_import_a, user_a);
  perform public.finish_payslip_document_import_review(payslip_duplicate_import_a, ' empregador   manual canonico ', date_trunc('month', current_date - interval '2 months')::date, 100000, 10000, 90000, 'payslip', '1', repeat('4', 64));
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config('role', 'authenticated', true);
  select count(*) into payslip_transaction_count from public.transactions where workspace_id=workspace_a and owner_id=user_a;
  begin
    perform public.apply_payslip_document_import(payslip_duplicate_import_a, jsonb_build_object('employer',' empregador   manual canonico ','competence',date_trunc('month',current_date - interval '2 months')::date::text,'grossAmountCents',100000,'discountsAmountCents',10000,'netAmountCents',90000,'sourceFingerprint',repeat('4',64)), current_date, transaction_account_a, context_a);
    raise exception 'manual canonical duplicate unexpectedly applied';
  exception when unique_violation then null;
  end;
  if (select count(*) from public.transactions where workspace_id=workspace_a and owner_id=user_a) <> payslip_transaction_count
     or not exists (select 1 from public.payslip_document_imports where id=payslip_duplicate_import_a and status='pending_review') then raise exception 'duplicate apply must roll back income transaction and preserve review'; end if;

  perform set_config('request.jwt.claim.sub', user_b::text, true);
  begin
    perform public.delete_payslip(payslip_first);
    raise exception 'user B can delete user A payslip';
  exception when no_data_found or insufficient_privilege then null;
  end;
  perform set_config('request.jwt.claim.sub', user_a::text, true);
  begin
    perform public.delete_payslip(payslip_income_a);
    raise exception 'imported payslip unexpectedly deleted';
  exception when object_not_in_prerequisite_state then null;
  end;
  if not exists (select 1 from public.payslips where id=payslip_income_a)
     or not exists (select 1 from public.transactions where id=payslip_income_transaction_a)
     or not exists (select 1 from public.payslip_document_imports where id=payslip_import_income_a and status='imported' and result_payslip_id=payslip_income_a) then raise exception 'imported payslip delete must preserve result, transaction and tombstone'; end if;

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
