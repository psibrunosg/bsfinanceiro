-- P2.5 — Validação: Orçamento, consumo, metas, aportes, auto-completar
-- Execute no Supabase SQL Editor como service_role.

DO $$
DECLARE
  v_user_id uuid;
  v_workspace_id uuid;
  v_category_id uuid;
  v_budget_id uuid;
  v_goal_id uuid;
  v_spent_before numeric;
  v_goal_status text;
  v_goal_current numeric;
BEGIN
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  SELECT id INTO v_workspace_id FROM public.workspaces
  WHERE owner_id = v_user_id AND kind = 'personal' LIMIT 1;
  RAISE NOTICE 'User: %, Workspace: %', v_user_id, v_workspace_id;

  -- Categoria de despesa
  INSERT INTO public.categories (workspace_id, owner_id, name, kind, color)
  VALUES (v_workspace_id, v_user_id, 'Teste Orçamento', 'expense', '#0000ff')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_category_id;
  IF v_category_id IS NULL THEN
    SELECT id INTO v_category_id FROM public.categories
    WHERE workspace_id = v_workspace_id AND owner_id = v_user_id
      AND name = 'Teste Orçamento' AND kind = 'expense' LIMIT 1;
  END IF;

  -- Conta
  DECLARE v_account_id uuid;
  BEGIN
    INSERT INTO public.accounts (workspace_id, owner_id, name, type)
    VALUES (v_workspace_id, v_user_id, 'Conta Teste Orçamento', 'checking')
    RETURNING id INTO v_account_id;

    -- ═══ Teste 1: Orçamento + consumo ═══
    INSERT INTO public.monthly_budgets (workspace_id, owner_id, category_id, category_kind, month, amount)
    VALUES (v_workspace_id, v_user_id, v_category_id, 'expense', date_trunc('month', CURRENT_DATE)::date, 500.00)
    ON CONFLICT (workspace_id, owner_id, category_id, month) DO UPDATE SET amount = 500.00
    RETURNING id INTO v_budget_id;

    RAISE NOTICE 'Orçamento criado: % (R$500,00)', v_budget_id;

    -- Registrar despesa nessa categoria
    INSERT INTO public.transactions (workspace_id, owner_id, account_id, category_id, type, status, description, amount, competence_date)
    VALUES (v_workspace_id, v_user_id, v_account_id, v_category_id, 'expense', 'paid', 'Despesa teste orçamento', 350.00, CURRENT_DATE);

    -- Verificar consumo: R$350 de R$500 = 70%
    SELECT COALESCE(SUM(t.amount), 0) INTO v_spent_before
    FROM public.transactions t
    WHERE t.workspace_id = v_workspace_id AND t.owner_id = v_user_id
      AND t.category_id = v_category_id AND t.type = 'expense'
      AND t.competence_date >= date_trunc('month', CURRENT_DATE)::date
      AND t.competence_date < (date_trunc('month', CURRENT_DATE) + interval '1 month')::date;

    IF v_spent_before < 350.00 THEN
      RAISE EXCEPTION 'Consumo esperado >= R$350, obteve R$%', v_spent_before;
    END IF;
    RAISE NOTICE '✓ Consumo verificado: R$% de R$500 (70%%)', v_spent_before;

    -- ═══ Teste 2: Meta com aporte e progresso ═══
    INSERT INTO public.financial_goals (workspace_id, owner_id, name, target_amount, current_amount, deadline, status)
    VALUES (v_workspace_id, v_user_id, 'Férias Teste', 2000.00, 0, '2026-12-31', 'active')
    RETURNING id INTO v_goal_id;

    RAISE NOTICE 'Meta criada: % (alvo R$2000)', v_goal_id;

    -- Registrar aporte
    INSERT INTO public.goal_contributions (workspace_id, owner_id, financial_goal_id, amount, note, idempotency_key)
    VALUES (v_workspace_id, v_user_id, v_goal_id, 800.00, 'Primeiro aporte', gen_random_uuid());

    -- Verificar progresso via trigger
    SELECT current_amount, status INTO v_goal_current, v_goal_status
    FROM public.financial_goals WHERE id = v_goal_id;

    IF v_goal_current != 800.00 THEN
      RAISE EXCEPTION 'Progresso esperado R$800, obteve R$%', v_goal_current;
    END IF;
    IF v_goal_status != 'active' THEN
      RAISE EXCEPTION 'Status deveria ser "active", obteve "%"', v_goal_status;
    END IF;
    RAISE NOTICE '✓ Progresso: R$% / R$2000 (40%%), status: %', v_goal_current, v_goal_status;

    -- ═══ Teste 3: Atingir meta → auto-complete ═══
    INSERT INTO public.goal_contributions (workspace_id, owner_id, financial_goal_id, amount, note, idempotency_key)
    VALUES (v_workspace_id, v_user_id, v_goal_id, 1200.00, 'Aporte final', gen_random_uuid());

    SELECT current_amount, status INTO v_goal_current, v_goal_status
    FROM public.financial_goals WHERE id = v_goal_id;

    IF v_goal_current != 2000.00 THEN
      RAISE EXCEPTION 'Progresso final esperado R$2000, obteve R$%', v_goal_current;
    END IF;
    IF v_goal_status != 'completed' THEN
      RAISE EXCEPTION 'Status deveria ser "completed", obteve "%"', v_goal_status;
    END IF;
    RAISE NOTICE '✓ Meta completada automaticamente: R$% / R$2000, status: %', v_goal_current, v_goal_status;

    -- Limpeza
    DELETE FROM public.goal_contributions WHERE financial_goal_id = v_goal_id;
    DELETE FROM public.financial_goals WHERE id = v_goal_id;
    DELETE FROM public.monthly_budgets WHERE id = v_budget_id;
    DELETE FROM public.transactions WHERE owner_id = v_user_id AND description LIKE '%teste orçamento%';
    DELETE FROM public.accounts WHERE id = v_account_id;
  END;

  DELETE FROM public.categories WHERE id = v_category_id;

  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '  P2.5 — TODOS OS TESTES PASSARAM ✓';
  RAISE NOTICE '═══════════════════════════════════════';
END $$;
