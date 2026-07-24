-- P2.3 — Validação: Cartão de crédito, compra parcelada, pagamento de fatura
-- Execute no Supabase SQL Editor como postgres/superuser.

DO $$
DECLARE
  v_user_id uuid;
  v_workspace_id uuid;
  v_account_id uuid;
  v_category_id uuid;
  v_card_id uuid;
  v_purchase_id uuid;
  v_invoice_id uuid;
  v_invoice_status text;
  v_payment_tx_id uuid;
  v_installment_count int;
  v_invoice_count int;
  v_open_invoices int;
BEGIN
  -- 1. Resolver usuário e workspace
  SELECT id INTO v_user_id FROM auth.users LIMIT 1;
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Nenhum usuário encontrado em auth.users';
  END IF;

  SELECT id INTO v_workspace_id FROM public.workspaces
  WHERE owner_id = v_user_id AND kind = 'personal' LIMIT 1;
  IF v_workspace_id IS NULL THEN
    RAISE EXCEPTION 'Nenhum workspace pessoal encontrado';
  END IF;

  RAISE NOTICE 'User: %, Workspace: %', v_user_id, v_workspace_id;

  -- Forçar auth.uid() sem SET ROLE (mantém grants do superuser)
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_user_id)::text, true);

  -- 2. Criar categoria de despesa (se não existir)
  INSERT INTO public.categories (workspace_id, owner_id, name, kind, color)
  VALUES (v_workspace_id, v_user_id, 'Teste Cartão', 'expense', '#ff0000')
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_category_id;

  IF v_category_id IS NULL THEN
    SELECT id INTO v_category_id FROM public.categories
    WHERE workspace_id = v_workspace_id AND owner_id = v_user_id
      AND name = 'Teste Cartão' AND kind = 'expense' LIMIT 1;
  END IF;

  RAISE NOTICE 'Categoria de teste: %', v_category_id;

  -- 3. Criar conta do tipo credit_card
  INSERT INTO public.accounts (workspace_id, owner_id, name, type, initial_balance)
  VALUES (v_workspace_id, v_user_id, 'Conta Cartão Teste', 'credit_card', 0)
  RETURNING id INTO v_account_id;

  RAISE NOTICE 'Conta credit_card criada: %', v_account_id;

  -- 4. Criar cartão de crédito vinculado à conta
  INSERT INTO public.credit_cards (workspace_id, owner_id, account_id, name, brand, last_four, credit_limit, closing_day, due_day)
  VALUES (v_workspace_id, v_user_id, v_account_id, 'Nubank Teste', 'visa', '1234', 5000.00, 15, 25)
  RETURNING id INTO v_card_id;

  RAISE NOTICE 'Cartão criado: %', v_card_id;

  -- 5. Registrar compra parcelada (6x de R$100 = R$600)
  v_purchase_id := public.create_installment_purchase(
    v_card_id,
    'Compra teste parcelada',
    600.00,
    CURRENT_DATE,
    6,
    v_category_id,
    'Teste P2.3',
    gen_random_uuid()
  );

  RAISE NOTICE 'Compra parcelada criada: %', v_purchase_id;

  -- 6. Verificar que parcelas foram criadas
  SELECT COUNT(*) INTO v_installment_count
  FROM public.credit_card_installments
  WHERE purchase_id = v_purchase_id AND owner_id = v_user_id;

  IF v_installment_count != 6 THEN
    RAISE EXCEPTION 'Esperado 6 parcelas, encontrado %', v_installment_count;
  END IF;
  RAISE NOTICE '✓ 6 parcelas criadas corretamente';

  -- 7. Verificar que faturas foram geradas
  SELECT COUNT(*) INTO v_invoice_count
  FROM public.credit_card_invoices
  WHERE credit_card_id = v_card_id AND owner_id = v_user_id;

  IF v_invoice_count < 1 THEN
    RAISE EXCEPTION 'Nenhuma fatura gerada para a compra';
  END IF;
  RAISE NOTICE '✓ % faturas geradas', v_invoice_count;

  -- 8. Selecionar primeira fatura em aberto para pagar
  SELECT id INTO v_invoice_id
  FROM public.credit_card_invoices
  WHERE credit_card_id = v_card_id AND owner_id = v_user_id AND status = 'open'
  ORDER BY due_date LIMIT 1;

  IF v_invoice_id IS NULL THEN
    RAISE EXCEPTION 'Nenhuma fatura em aberto encontrada';
  END IF;

  -- 9. Pagar a fatura
  v_payment_tx_id := public.pay_credit_card_invoice(
    v_invoice_id,
    v_account_id,
    CURRENT_DATE,
    gen_random_uuid()
  );

  RAISE NOTICE 'Fatura paga, transaction: %', v_payment_tx_id;

  -- 10. Verificar que a fatura mudou para 'paid'
  SELECT status INTO v_invoice_status
  FROM public.credit_card_invoices WHERE id = v_invoice_id;

  IF v_invoice_status != 'paid' THEN
    RAISE EXCEPTION 'Fatura deveria estar "paid", está "%"', v_invoice_status;
  END IF;
  RAISE NOTICE '✓ Fatura status: paid';

  -- 11. Verificar que transação de pagamento foi criada
  IF NOT EXISTS (
    SELECT 1 FROM public.transactions
    WHERE id = v_payment_tx_id AND owner_id = v_user_id
      AND type = 'expense' AND status = 'paid'
      AND description LIKE '%fatura%'
  ) THEN
    RAISE EXCEPTION 'Transação de pagamento não encontrada ou inválida';
  END IF;
  RAISE NOTICE '✓ Transação de pagamento criada corretamente';

  -- 12. Verificar que faturas restantes ainda estão em aberto
  SELECT COUNT(*) INTO v_open_invoices
  FROM public.credit_card_invoices
  WHERE credit_card_id = v_card_id AND owner_id = v_user_id AND status = 'open';

  RAISE NOTICE '✓ % faturas restantes em aberto', v_open_invoices;

  -- 13. Testar idempotência
  DECLARE
    v_idem_key uuid := gen_random_uuid();
    v_first_payment uuid;
    v_second_payment uuid;
  BEGIN
    SELECT id INTO v_invoice_id
    FROM public.credit_card_invoices
    WHERE credit_card_id = v_card_id AND owner_id = v_user_id AND status = 'open'
    ORDER BY due_date LIMIT 1;

    IF v_invoice_id IS NOT NULL THEN
      v_first_payment := public.pay_credit_card_invoice(v_invoice_id, v_account_id, CURRENT_DATE, v_idem_key);
      v_second_payment := public.pay_credit_card_invoice(v_invoice_id, v_account_id, CURRENT_DATE, v_idem_key);
      IF v_first_payment != v_second_payment THEN
        RAISE EXCEPTION 'Idempotência falhou: pagamentos diferentes com mesma chave';
      END IF;
      RAISE NOTICE '✓ Idempotência de pagamento verificada';
    END IF;
  END;

  -- Limpeza (ordem: transactions antes de accounts)
  DELETE FROM public.credit_card_installments WHERE purchase_id = v_purchase_id;
  DELETE FROM public.credit_card_invoices WHERE credit_card_id = v_card_id;
  DELETE FROM public.credit_card_purchases WHERE id = v_purchase_id;
  DELETE FROM public.credit_cards WHERE id = v_card_id;
  DELETE FROM public.transactions WHERE owner_id = v_user_id AND (description LIKE '%fatura%' OR description LIKE '%Compra teste%');
  DELETE FROM public.accounts WHERE id = v_account_id;
  DELETE FROM public.categories WHERE id = v_category_id;

  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '  P2.3 — TODOS OS TESTES PASSARAM ✓';
  RAISE NOTICE '═══════════════════════════════════════';
END $$;
