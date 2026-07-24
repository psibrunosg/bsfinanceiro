-- P2.4 — Validação: Compromissos fixos, materialização, pagamento, clamping
-- Execute no Supabase SQL Editor como postgres/superuser.

DO $$
DECLARE
  v_user_id uuid;
  v_workspace_id uuid;
  v_account_id uuid;
  v_category_id uuid;
  v_commitment_id uuid;
  v_occurrence_id uuid;
  v_occurrence_status text;
  v_payment_tx_id uuid;
  v_clamping_commitment_id uuid;
  v_clamping_due_date date;
  v_current_month date := date_trunc('month', CURRENT_DATE)::date;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id INTO v_workspace_id FROM public.workspaces
  WHERE owner_id = v_user_id AND kind = 'personal' LIMIT 1;
  RAISE NOTICE 'User: %, Workspace: %', v_user_id, v_workspace_id;

  -- Forçar auth.uid() sem SET ROLE
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_id)::text, true);

  -- Conta para pagamento
  INSERT INTO public.accounts (workspace_id, owner_id, name, type)
  VALUES (v_workspace_id, v_user_id, 'Conta Teste Compromisso', 'checking')
  RETURNING id INTO v_account_id;

  -- Categoria
  INSERT INTO public.categories (workspace_id, owner_id, name, kind, color)
  VALUES (v_workspace_id, v_user_id, 'Teste Compromisso', 'expense', '#00ff00')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_category_id;
  IF v_category_id IS NULL THEN
    SELECT id INTO v_category_id FROM public.categories
    WHERE workspace_id = v_workspace_id AND owner_id = v_user_id
      AND name = 'Teste Compromisso' AND kind = 'expense' LIMIT 1;
  END IF;

  -- ═══ Teste 1: Compromisso com due_day dentro do mês ═══
  INSERT INTO public.fixed_commitments (workspace_id, owner_id, description, amount, due_day, account_id, category_id)
  VALUES (v_workspace_id, v_user_id, 'Aluguel Teste', 1500.00, EXTRACT(DAY FROM CURRENT_DATE)::int, v_account_id, v_category_id)
  RETURNING id INTO v_commitment_id;

  RAISE NOTICE 'Compromisso criado (due_day=%): %', EXTRACT(DAY FROM CURRENT_DATE)::int, v_commitment_id;

  -- Materializar ocorrências
  PERFORM public.materialize_fixed_commitment_occurrences(v_workspace_id, v_current_month);

  -- Verificar ocorrência materializada
  SELECT id, status INTO v_occurrence_id, v_occurrence_status
  FROM public.fixed_commitment_occurrences
  WHERE fixed_commitment_id = v_commitment_id AND occurrence_month = v_current_month;

  IF v_occurrence_id IS NULL THEN
    RAISE EXCEPTION 'Ocorrência não foi materializada para o mês atual';
  END IF;
  IF v_occurrence_status != 'planned' THEN
    RAISE EXCEPTION 'Ocorrência deveria ser "planned", está "%"', v_occurrence_status;
  END IF;
  RAISE NOTICE '✓ Ocorrência materializada: %, status: %', v_occurrence_id, v_occurrence_status;

  -- Pagamento da ocorrência
  v_payment_tx_id := public.pay_fixed_commitment_occurrence(
    v_occurrence_id, v_account_id, CURRENT_DATE, gen_random_uuid()
  );

  -- Verificar status mudou para paid
  SELECT status INTO v_occurrence_status
  FROM public.fixed_commitment_occurrences WHERE id = v_occurrence_id;

  IF v_occurrence_status != 'paid' THEN
    RAISE EXCEPTION 'Ocorrência deveria ser "paid", está "%"', v_occurrence_status;
  END IF;
  RAISE NOTICE '✓ Ocorrência paga, transação: %', v_payment_tx_id;

  -- Verificar transação criada
  IF NOT EXISTS (
    SELECT 1 FROM public.transactions
    WHERE id = v_payment_tx_id AND owner_id = v_user_id
      AND type = 'expense' AND status = 'paid'
  ) THEN
    RAISE EXCEPTION 'Transação de pagamento não encontrada';
  END IF;
  RAISE NOTICE '✓ Transação de pagamento criada corretamente';

  -- ═══ Teste 2: Clamping due_day=31 em mês com 30 dias ═══
  INSERT INTO public.fixed_commitments (workspace_id, owner_id, description, amount, due_day)
  VALUES (v_workspace_id, v_user_id, 'Teste Clamping Dia 31', 100.00, 31)
  RETURNING id INTO v_clamping_commitment_id;

  -- Materializar para fevereiro 2026 (28 dias)
  PERFORM public.materialize_fixed_commitment_occurrences(v_workspace_id, '2026-02-01');

  SELECT due_date INTO v_clamping_due_date
  FROM public.fixed_commitment_occurrences
  WHERE fixed_commitment_id = v_clamping_commitment_id AND occurrence_month = '2026-02-01';

  IF v_clamping_due_date != '2026-02-28' THEN
    RAISE EXCEPTION 'Clamping falhou: esperado 2026-02-28, obteve %', v_clamping_due_date;
  END IF;
  RAISE NOTICE '✓ Clamping: due_day=31 em fev/2026 → %', v_clamping_due_date;

  -- Materializar para abril 2026 (30 dias)
  PERFORM public.materialize_fixed_commitment_occurrences(v_workspace_id, '2026-04-01');

  SELECT due_date INTO v_clamping_due_date
  FROM public.fixed_commitment_occurrences
  WHERE fixed_commitment_id = v_clamping_commitment_id AND occurrence_month = '2026-04-01';

  IF v_clamping_due_date != '2026-04-30' THEN
    RAISE EXCEPTION 'Clamping falhou: esperado 2026-04-30, obteve %', v_clamping_due_date;
  END IF;
  RAISE NOTICE '✓ Clamping: due_day=31 em abr/2026 → %', v_clamping_due_date;

  -- Limpeza (ordem: transactions antes de accounts)
  DELETE FROM public.fixed_commitment_occurrences WHERE fixed_commitment_id IN (v_commitment_id, v_clamping_commitment_id);
  DELETE FROM public.fixed_commitments WHERE id IN (v_commitment_id, v_clamping_commitment_id);
  DELETE FROM public.transactions WHERE owner_id = v_user_id AND account_id = v_account_id;
  DELETE FROM public.accounts WHERE id = v_account_id;
  DELETE FROM public.categories WHERE id = v_category_id;

  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '  P2.4 — TODOS OS TESTES PASSARAM ✓';
  RAISE NOTICE '═══════════════════════════════════════';
END $$;
