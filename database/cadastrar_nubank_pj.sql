SET client_encoding = 'UTF8';
BEGIN;

-- 1. Categorias complementares
INSERT INTO categories (id, workspace_id, owner_id, name, kind, color, budget_limit, created_at)
VALUES ('c0a80101-9999-4444-aaaa-bbbbcccc0001', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Despesas da Empresa (PJ)', 'expense', '#38BDF8', NULL, NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO categories (id, workspace_id, owner_id, name, kind, color, budget_limit, created_at)
VALUES ('f1a2b3c4-d5e6-7890-abcd-ef1234567890', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Taxas & Encargos', 'expense', '#F59E0B', NULL, NOW())
ON CONFLICT (id) DO NOTHING;

-- 2. Conta Técnica do Cartão Nubank PJ
INSERT INTO accounts (id, workspace_id, owner_id, name, type, initial_balance, active, is_system, is_shared, created_at)
VALUES ('e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Cartão Nubank PJ', 'credit_card', 0.00, true, false, false, NOW())
ON CONFLICT (id) DO NOTHING;

-- 3. Cartão de Crédito Nubank PJ
INSERT INTO credit_cards (id, account_id, workspace_id, owner_id, name, brand, last_four, credit_limit, limit_amount, closing_day, due_day, created_at)
VALUES ('f8c9d0e1-2345-6789-abcd-ef0123456789', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Nubank PJ', 'Mastercard', '3197', 5300.00, 5300.00, 4, 11, NOW())
ON CONFLICT (id) DO UPDATE SET credit_limit = 5300.00, limit_amount = 5300.00, closing_day = 4, due_day = 11;

-- ===========================================================================
-- Fatura 2025-11 (Nubank_2025-11-11.pdf) - R$ 493.72
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('46c533c3-88ce-45be-ba87-55b6ce6b1158', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 11, 2025, '2025-11-04', '2025-11-11', 493.72, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('84669501-40f7-42d9-894c-ccc3c54b27a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mp *Cucinadongennaro', 81.0, '2025-10-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('93c232e3-c9bd-4ca0-b0ae-fb0ef3f4cad8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '84669501-40f7-42d9-894c-ccc3c54b27a4', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 81.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c78ceb33-0727-48b9-8193-57f817a589ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mp *Cucinadongennaro', 81.0, 'expense', 'paid', '2025-10-11', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('be5ede05-31ea-42b0-a1c2-836636933e56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Castorino de Oliveira', 40.0, '2025-10-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9f161a16-a90e-4ded-beaf-308a81cfda38', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'be5ede05-31ea-42b0-a1c2-836636933e56', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 40.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f6d84e15-313f-4d49-b633-b0337ea72d8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Castorino de Oliveira', 40.0, 'expense', 'paid', '2025-10-12', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a2d3c9f2-2082-4c00-b28b-ea7af21c8855', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Baronesa', 30.0, '2025-10-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9cecb006-6b55-4648-9b11-5338b59d11a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a2d3c9f2-2082-4c00-b28b-ea7af21c8855', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7fe6e86a-6736-4d74-afe9-d78f7047e984', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Baronesa', 30.0, 'expense', 'paid', '2025-10-13', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ec075c1f-9d4e-434d-8c24-f3a003bd56b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Une Sushi - Pelotas', 15.8, '2025-10-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b90f0d5b-d7ad-4338-97fc-46aa6b143b78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ec075c1f-9d4e-434d-8c24-f3a003bd56b2', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 15.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dbddd20d-5397-443a-89ca-dff774cfffa3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Une Sushi - Pelotas', 15.8, 'expense', 'paid', '2025-10-13', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7b44dac0-974d-41a1-a7a3-e9b56d185814', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pratica Solucoes Digit - Parcela 1/3', 59.68, '2025-10-14', 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('126be5f3-2397-4213-934c-17c0f01d3bbc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7b44dac0-974d-41a1-a7a3-e9b56d185814', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 59.68, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e216a145-7a31-488f-bae3-b71d949cf871', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pratica Solucoes Digit - Parcela 1/3', 59.68, 'expense', 'paid', '2025-10-14', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b9d895b4-fdf1-46db-a06f-24abfcbd29d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, '2025-10-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2f94c2de-7a07-4430-ad59-a7c5c220a8c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b9d895b4-fdf1-46db-a06f-24abfcbd29d4', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 12.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4137d953-742a-4cb9-89d3-8ecdb644176f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, 'expense', 'paid', '2025-10-14', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f901d95d-d252-4d28-9001-ce8c1c9ea68c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 24.79, '2025-10-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f4f7f98e-c084-47ad-a80c-92c2430d74a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f901d95d-d252-4d28-9001-ce8c1c9ea68c', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 24.79, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('02bea65b-fb9e-4292-a043-d01915ef5547', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 24.79, 'expense', 'paid', '2025-10-14', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('98875d14-bdbe-4bbb-adb8-9b243d34889a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 30.0, '2025-10-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8b3c6de-79cd-4664-a021-ed0a6023006a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '98875d14-bdbe-4bbb-adb8-9b243d34889a', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('925d695d-2979-46d0-8e58-96e248fd116b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 30.0, 'expense', 'paid', '2025-10-15', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5624f689-4972-4a67-959a-b6e8f075441d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 32.25, '2025-10-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ec69b721-5596-4df8-b4d5-6e9536ca87ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5624f689-4972-4a67-959a-b6e8f075441d', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 32.25, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('78f4beb9-4a83-4059-bb48-f0ca33ede01a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 32.25, 'expense', 'paid', '2025-10-15', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('835ef0e1-bd63-4adb-a8a5-9b38c8eb0996', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, '2025-10-16', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5074fe4-3388-4df6-a232-e615f306d0ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '835ef0e1-bd63-4adb-a8a5-9b38c8eb0996', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 9.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('99e5bf88-5539-4480-8e3a-328e15130f19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, 'expense', 'paid', '2025-10-16', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('00d9ba2c-88a0-46d3-ba66-55f382353015', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 4.99, '2025-10-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f4e23e6-b026-45e6-9d1e-7136afcc6175', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '00d9ba2c-88a0-46d3-ba66-55f382353015', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 4.99, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44d813d4-1a74-4d3e-9dec-6eba126a697a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 4.99, 'expense', 'paid', '2025-10-17', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('223a0fde-79b7-4f1e-8fa1-7af626b14f85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 20.0, '2025-10-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('805deb3b-65a9-436d-8efa-a91ca0fe673c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '223a0fde-79b7-4f1e-8fa1-7af626b14f85', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 20.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0a45c091-b328-493b-b7d5-68b3c838b3c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 20.0, 'expense', 'paid', '2025-10-18', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('af14af4c-9f08-4eba-a961-95e7c968ebfb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 10.0, '2025-10-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5bd3e56c-1d22-4a2e-921c-a9aa94667951', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'af14af4c-9f08-4eba-a961-95e7c968ebfb', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 10.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ad62b0fa-0ed2-495c-a84a-81f6bd61681d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke', 10.0, 'expense', 'paid', '2025-10-18', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1b74e7a4-ecf9-4891-877b-8fcde3fe8d24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '21.005.737 Eduardo Ara', 12.0, '2025-10-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('07722831-e61a-4217-bd0f-c5e4a0ec44db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1b74e7a4-ecf9-4891-877b-8fcde3fe8d24', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 12.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d0bbbac8-572e-4722-8f17-88556006c8e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '21.005.737 Eduardo Ara', 12.0, 'expense', 'paid', '2025-10-18', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3049cfc8-a53a-4a88-9394-5e82b5016714', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 11.28, '2025-10-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f0f6f15e-8a26-42e8-a5f9-78fbcad321b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3049cfc8-a53a-4a88-9394-5e82b5016714', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 11.28, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('716d86c3-ba04-4597-b9ae-5ac8207128cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 11.28, 'expense', 'paid', '2025-10-18', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('525c098d-d1ce-4989-ba2e-5235e359e9d0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Giraffas', 38.9, '2025-10-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3730939e-7e10-46ab-a653-c7adc3afd91d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '525c098d-d1ce-4989-ba2e-5235e359e9d0', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 38.9, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3aa2029-d0ac-4aa1-b5de-d4d0959fb312', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Giraffas', 38.9, 'expense', 'paid', '2025-10-19', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('773f6fd8-5027-40af-a158-f8668aed0eb6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('61902732-2188-4463-b575-401c0c6073e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '773f6fd8-5027-40af-a158-f8668aed0eb6', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 9.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e7249104-dbcc-49df-9dff-137be68f0c4c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('82264cd1-73b5-45dd-86fd-87f08882cbd7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 10.46, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7acaa2dd-c828-4ef5-8e5e-285d4055986d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '82264cd1-73b5-45dd-86fd-87f08882cbd7', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 10.46, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e164f85c-d325-425f-bbfb-1cb480476b54', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 10.46, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0a1af760-1aed-4fb7-a4e9-d71132709727', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Postos Coqueiro', 30.0, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5dded4a3-001a-401d-8697-915baf912a77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0a1af760-1aed-4fb7-a4e9-d71132709727', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d479729-a137-4392-b6af-73cb61fa91c6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Postos Coqueiro', 30.0, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('61b5450b-7142-4220-bcba-d2140071f69a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('239e19c1-ab5c-445c-b8e3-2f242b057b5d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '61b5450b-7142-4220-bcba-d2140071f69a', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 12.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6bae05ba-aef9-412e-92f2-dd3a8db7be44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('49873758-557e-41dd-8973-ac788ed9098b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 13.88, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aa1a57fc-3ed9-4069-9a95-3925c433e6bc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '49873758-557e-41dd-8973-ac788ed9098b', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 13.88, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c379ac11-ac4f-4cc5-85b8-d010ac18c802', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 13.88, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('136513c5-e9f8-43c3-b26d-5720e334f011', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Desconto Antecipação Pratica Solucoes Digit', 1.49, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c32cbffc-b92d-4cd3-8d96-8f2da8b4d8d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '136513c5-e9f8-43c3-b26d-5720e334f011', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, -1.49, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('49c671fd-ea7b-4413-8c28-abae41c1b452', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Desconto Antecipação Pratica Solucoes Digit', 1.49, 'income', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d9b2b459-fd57-45cb-b6e0-f3b73bbb791b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Pratica Solucoes Digit - Parcela 2/3', 59.66, '2025-10-25', 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('72def4ea-87ac-48a5-b0c4-955f8fbd1e7b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd9b2b459-fd57-45cb-b6e0-f3b73bbb791b', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 2, 59.66, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7aae891e-092b-433e-bd70-2db29146186e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Pratica Solucoes Digit - Parcela 2/3', 59.66, 'expense', 'paid', '2025-10-25', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 2, 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bb56db8d-6613-4c82-a4e8-3a94957f8df7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Pratica Solucoes Digit - Parcela 3/3', 59.66, '2025-10-25', 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('54329056-9909-4526-a8b9-f5321ae6c0f6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'bb56db8d-6613-4c82-a4e8-3a94957f8df7', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 3, 59.66, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7478fe9a-104e-4970-83ef-8f471e646350', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Pratica Solucoes Digit - Parcela 3/3', 59.66, 'expense', 'paid', '2025-10-25', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 3, 3, 'Cartão Nubank PJ (Final 9220) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d372b2ee-3f9e-4dad-b7a5-f8e757058c39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 51.0, '2025-10-27', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('402f5cf6-e6b4-4794-9cae-6cdde295af77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd372b2ee-3f9e-4dad-b7a5-f8e757058c39', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 51.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('55d93081-63e6-49be-987c-6eab58f8afc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 51.0, 'expense', 'paid', '2025-10-27', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7cc478cc-afd1-4ad9-a6dc-79ec129476fb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 2.89, '2025-10-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e799eb84-26f7-484d-b93d-5fee48a40f22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7cc478cc-afd1-4ad9-a6dc-79ec129476fb', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 2.89, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9571b466-6c19-40c8-89c2-5a701e9f1dbf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 2.89, 'expense', 'paid', '2025-10-28', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5de908fc-d171-42a2-945c-4f129dc2a954', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, '2025-10-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f6315f14-c3d3-4388-9f4c-7bceca0a5ced', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5de908fc-d171-42a2-945c-4f129dc2a954', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 12.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('db8e8d49-a7f0-4784-92b0-b77c8c9d7cff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, 'expense', 'paid', '2025-10-28', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac202d38-545d-4fc0-810e-c04764341d30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, '2025-10-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5f9fe19e-884e-495f-b4cc-8c0e17486c08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ac202d38-545d-4fc0-810e-c04764341d30', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 9.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d8f7d074-d9d9-4c10-8c85-fad904f0e2e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, 'expense', 'paid', '2025-10-28', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2aef86ae-7142-49bc-9ab7-1cafc5afb712', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 72.0, '2025-10-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1c516b35-b4c6-49ca-a0bd-804d0debeb9e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2aef86ae-7142-49bc-9ab7-1cafc5afb712', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 72.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a182b69a-0137-42b4-b1db-784922acd9bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 72.0, 'expense', 'paid', '2025-10-28', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1ca8bfc7-dd46-458e-a2b2-d75dd1c4fe71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Luiz Carlos Silva dos', 40.0, '2025-10-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6183784b-63d5-4a70-91b3-e96597292062', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1ca8bfc7-dd46-458e-a2b2-d75dd1c4fe71', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 40.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dcfa7739-30d5-4109-aad5-a428152ce3ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Luiz Carlos Silva dos', 40.0, 'expense', 'paid', '2025-10-28', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('274fb3cb-5b51-48a6-a341-642779190631', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 15.05, '2025-10-29', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e1c16242-22b2-40b1-9f0b-522fbcc44569', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '274fb3cb-5b51-48a6-a341-642779190631', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 15.05, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b306a977-0fb9-4bde-958a-5bf1297ca10e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Npo Pelotas', 15.05, 'expense', 'paid', '2025-10-29', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e47d0a82-99f1-41e0-aa30-d411947faab7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Baronesa', 30.0, '2025-10-29', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e2500031-6d90-46d9-b4db-8ced8b4a7da5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e47d0a82-99f1-41e0-aa30-d411947faab7', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0919c520-ae9a-4bd5-92ce-5d10d3f78407', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Baronesa', 30.0, 'expense', 'paid', '2025-10-29', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('259d8121-f226-4560-ba63-fdf8e0760305', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Thalespereirade', 9.0, '2025-10-30', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c5a8add4-7f69-4488-889d-b1407e9b52e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '259d8121-f226-4560-ba63-fdf8e0760305', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 9.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0691aea0-1af2-42bf-9578-01c5a9eed823', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Thalespereirade', 9.0, 'expense', 'paid', '2025-10-30', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2ce5072f-c57f-430b-8e00-19ed7850703a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fura Bolo', 15.0, '2025-10-30', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a39dc0d1-2e06-42eb-99ff-26a37d8b1086', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2ce5072f-c57f-430b-8e00-19ed7850703a', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 15.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6eaff9d-0ac0-4e36-aa07-9805b83f37e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fura Bolo', 15.0, 'expense', 'paid', '2025-10-30', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('10d57605-4273-4419-92f4-3d17f12353ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Severo Garage', 48.0, '2025-10-30', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4ecfc346-79ce-448c-abd1-a9603facd2be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '10d57605-4273-4419-92f4-3d17f12353ee', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 48.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ddaf6174-b1ac-47eb-b724-d32165c2d014', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Severo Garage', 48.0, 'expense', 'paid', '2025-10-30', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3eaf84dc-3622-40b3-8eaa-251e1422055f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, '2025-10-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d0261f91-7eac-4dfb-8c24-9497c9470896', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3eaf84dc-3622-40b3-8eaa-251e1422055f', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 8.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('135dcfb8-5bb7-47c8-8a1a-3ae186efcfe4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, 'expense', 'paid', '2025-10-31', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4936d9f6-6563-47c2-a1ec-989702821573', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 13.04, '2025-10-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('74e0329f-bbf0-4869-9b7e-a3a351de6947', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4936d9f6-6563-47c2-a1ec-989702821573', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 13.04, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bb44c7af-9bb2-4177-acb6-277731492c68', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 13.04, 'expense', 'paid', '2025-10-31', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('01d49faf-cbd6-4fd2-9d8f-f2389c645630', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, '2025-10-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6d26dcb4-5846-4c2b-836c-f6e402ba85f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '01d49faf-cbd6-4fd2-9d8f-f2389c645630', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('02102192-6a91-41c6-9e9c-1700eb5e3f86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, 'expense', 'paid', '2025-10-31', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6d27e145-b889-43e2-9af5-7ae6c5f2213e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, '2025-11-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9b19186f-2ed3-4558-85fb-62173db412a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6d27e145-b889-43e2-9af5-7ae6c5f2213e', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 8.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cb81740d-5f4c-49cd-a23e-506297fb31aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, 'expense', 'paid', '2025-11-01', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b4a8e149-195e-4d10-86b5-ce0e3cd6a64a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2025-11-03', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e9f106e-15dc-4685-9c3d-0802adaea20f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b4a8e149-195e-4d10-86b5-ce0e3cd6a64a', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 11.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('59d2e51a-a0a8-4b77-beca-586b80507cb4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2025-11-03', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e65d963d-dbde-4275-ad92-55d985d38c41', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 30.1, '2025-11-03', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f1fe2dd2-b34c-4239-a6ed-689f4fea6f5e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e65d963d-dbde-4275-ad92-55d985d38c41', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 30.1, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6169851a-9b85-421c-a072-8ae6234e84f6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 30.1, 'expense', 'paid', '2025-11-03', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5cf08d34-94cc-4897-b835-a6be6287a351', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: CEEE DISTRIBUICAO', 48.85, '2025-10-11', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5e02b23c-f945-43c0-82e4-7b32d099c774', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5cf08d34-94cc-4897-b835-a6be6287a351', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 48.85, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d5901b4-aa79-4557-ac3f-6ef0eaccb547', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: CEEE DISTRIBUICAO', 48.85, 'expense', 'paid', '2025-10-11', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e152bad9-be2f-4fea-8a7c-57b7dec1a4a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: 50.448.076 ADRIANA ROSA BOETTGE', 8.4, '2025-10-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bb2daed3-dc97-4b5a-994e-9ff5ccf52fea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e152bad9-be2f-4fea-8a7c-57b7dec1a4a1', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 8.4, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4049e518-51c5-4193-af1c-c0b5856d5448', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: 50.448.076 ADRIANA ROSA BOETTGE', 8.4, 'expense', 'paid', '2025-10-21', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a36a448b-7f79-4928-b9ea-2b0e23b4b47b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.08, '2025-10-21', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8b5feca5-929f-49be-9724-16d3d990a72c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a36a448b-7f79-4928-b9ea-2b0e23b4b47b', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1.08, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('197a7515-6ee9-456f-9996-6231b2ecb897', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.08, 'expense', 'paid', '2025-10-21', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c6cec9a5-d75e-4c1a-b791-7d2565b0d2c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.18, '2025-10-22', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('08228435-0f2a-487f-bed1-d0acc48e3036', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c6cec9a5-d75e-4c1a-b791-7d2565b0d2c1', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 2.18, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2e3f9bfc-2fc6-43f1-99f4-5c93d3148bb0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.18, 'expense', 'paid', '2025-10-22', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cc1e0c00-5a02-4abc-9ddd-16d86b8b5e69', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.08, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8973706d-0c83-4f0b-b69c-3a391c541243', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'cc1e0c00-5a02-4abc-9ddd-16d86b8b5e69', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1.08, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('436da13b-2ff8-42fd-96b3-b60ba023d9a9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.08, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('38596bd9-bdc0-4567-ba17-cfa61275adc4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.63, '2025-10-23', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a7e42a32-b7a1-419b-948d-4795765c99fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '38596bd9-bdc0-4567-ba17-cfa61275adc4', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1.63, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d6de91ae-a1a0-4df0-9316-9ba203475374', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.63, 'expense', 'paid', '2025-10-23', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('65eaf80f-cd96-4135-9f19-8686b525083d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.14, '2025-10-30', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3f1c5a40-fdc6-48ea-8451-72f4e917f8bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '65eaf80f-cd96-4135-9f19-8686b525083d', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 2.14, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('898d21ee-3158-42e7-9d1a-5a488028c10f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.14, 'expense', 'paid', '2025-10-30', '2025-11-11', '2025-11-11', '46c533c3-88ce-45be-ba87-55b6ce6b1158', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-12 (Nubank_2025-12-11.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c74798d3-a5df-476a-ade4-8f1929494fd0', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 12, 2025, '2025-12-04', '2025-12-11', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7dd02981-dd3d-4aa8-88e2-1d9bca4e9df4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Espetino Pelotas', 36.45, '2025-11-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eefb3060-05cc-47dd-b0fc-007eddb52e52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7dd02981-dd3d-4aa8-88e2-1d9bca4e9df4', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 36.45, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('39e747f9-0f83-497b-b078-74911e7f524e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Espetino Pelotas', 36.45, 'expense', 'paid', '2025-11-05', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bdb3051a-0fca-4af4-93b6-16104e23354a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Azeredo', 30.0, '2025-11-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('847d92b3-4c4d-410d-b434-74ea46128bce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'bdb3051a-0fca-4af4-93b6-16104e23354a', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44745b6e-c2af-4dd9-8419-1f56f1ddb3d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Azeredo', 30.0, 'expense', 'paid', '2025-11-05', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eb8abef0-ab2d-4085-98ef-758d89586ad7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 2.99, '2025-11-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c451e90d-525b-4062-85a4-52f4b4923202', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'eb8abef0-ab2d-4085-98ef-758d89586ad7', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 2.99, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4d647600-421a-4069-8e0b-7bc8c0919c37', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 2.99, 'expense', 'paid', '2025-11-05', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d16b59fd-39cc-4676-becf-1ef23ed06e64', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, '2025-11-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('12177ff1-b729-4192-8239-b54f217b0444', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd16b59fd-39cc-4676-becf-1ef23ed06e64', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 9.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a863e20-5421-4504-afcb-df280d8d57de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.5, 'expense', 'paid', '2025-11-07', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1b07e684-0a9a-458d-bf0c-d077f2cb868f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 17.0, '2025-11-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7e06e9da-fc91-456e-a95f-b0fb2d9c2fe5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1b07e684-0a9a-458d-bf0c-d077f2cb868f', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 17.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('94b9e058-6307-4660-9ac3-fa9695b8d56e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 17.0, 'expense', 'paid', '2025-11-08', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e728e24b-cd69-4741-907b-6a73a1d3efa1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Pizzaria Pelotense', 193.79, '2025-11-09', 1, 'Cartão Nubank PJ (Final 9132) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5b07f2b0-e2bc-4194-84a1-b580712b52c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e728e24b-cd69-4741-907b-6a73a1d3efa1', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 193.79, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d4b655c6-fa0d-4192-bd5c-ea319c90a685', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Pizzaria Pelotense', 193.79, 'expense', 'paid', '2025-11-09', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 9132) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a6d3fedd-79cd-4ec9-a85e-5a62c5160779', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Seboicaria', 60.0, '2025-11-09', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('115b6fac-c96f-4653-ae2f-cab4b4667be0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a6d3fedd-79cd-4ec9-a85e-5a62c5160779', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 60.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b197e99c-7e1b-4003-afad-76120ba54e6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Seboicaria', 60.0, 'expense', 'paid', '2025-11-09', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7138cb46-76e8-4c45-b845-73a851f70ba2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cono Gelateria', 17.0, '2025-11-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('40a30271-0c66-4127-bfde-b4d5ef1788eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7138cb46-76e8-4c45-b845-73a851f70ba2', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 17.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bc82a450-86de-47fe-8cb1-2a832fa0debc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cono Gelateria', 17.0, 'expense', 'paid', '2025-11-10', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2124255d-c5e2-4423-aea4-ee3abc8f286c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 122.15, '2025-11-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2e64ac8b-0ec0-4de6-827b-0adfe959c346', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2124255d-c5e2-4423-aea4-ee3abc8f286c', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 122.15, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5753c8fb-b3ee-46c8-9f10-64a75167b2c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 122.15, 'expense', 'paid', '2025-11-10', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3855d6a6-db25-497c-9ad0-fb29d44f3dfa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'la Cucinetta', 59.0, '2025-11-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('10359c00-d8ce-4686-9c55-6b62c341a053', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3855d6a6-db25-497c-9ad0-fb29d44f3dfa', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 59.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e35719dc-5dc9-4f71-a6a1-1aef9c1c4dc3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'la Cucinetta', 59.0, 'expense', 'paid', '2025-11-10', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bab06af3-b00a-4578-b4f6-ab49888c3428', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ciranda Cultural', 60.0, '2025-11-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('df71f318-9491-41cc-8c20-2a9246ca41fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'bab06af3-b00a-4578-b4f6-ab49888c3428', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 60.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('65d14068-4df3-4580-8039-ea0646ba4fdd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ciranda Cultural', 60.0, 'expense', 'paid', '2025-11-10', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dc6cb34b-5310-4396-b0fe-91571007de0b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, '2025-11-13', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6075b419-f0e9-4a26-9396-9b6fe485b048', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'dc6cb34b-5310-4396-b0fe-91571007de0b', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 5.6, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bd38d6cc-f019-4e71-b1e0-5bfbafa826a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, 'expense', 'paid', '2025-11-13', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c3578abe-271f-4a57-acc5-f4a5370739f8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 1.4, '2025-11-13', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5bb40f04-b770-4f94-8af7-4cc5ab497f7d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c3578abe-271f-4a57-acc5-f4a5370739f8', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1.4, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3c4e81d-3640-4f2c-be83-6e1b4e287e88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 1.4, 'expense', 'paid', '2025-11-13', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('22850092-270d-41c0-bf62-79cee09368f8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ig*Psicomanager', 109.51, '2025-11-14', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3a0be935-a199-4295-87e8-60c1c92a56b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '22850092-270d-41c0-bf62-79cee09368f8', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 109.51, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f99886b2-d0c0-4aeb-8c5c-b4558c05c63c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ig*Psicomanager', 109.51, 'expense', 'paid', '2025-11-14', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('98f3f64d-180d-488b-8f40-f5c1a75b679a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, '2025-11-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('22ea4b96-88eb-44b5-bba6-814a9bdf1c67', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '98f3f64d-180d-488b-8f40-f5c1a75b679a', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 12.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f6ad5702-0007-4e6d-8f5b-896dfd2b4f7d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, 'expense', 'paid', '2025-11-14', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fb4086bc-d17a-450f-84ab-2467a9d83bfd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, '2025-11-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('df7ce4ad-17d5-4509-890f-8cdd39830051', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fb4086bc-d17a-450f-84ab-2467a9d83bfd', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a906c004-7109-47f9-bc63-7b078c24de9e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, 'expense', 'paid', '2025-11-14', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('861b30a8-f063-478d-82fc-9ba8800ec91f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Brapel Comercio de Ali', 4.0, '2025-11-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c763b674-988d-46d0-93f1-0e1b86b1f44e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '861b30a8-f063-478d-82fc-9ba8800ec91f', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 4.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1bc0dd86-7766-4de2-abef-e5ed0f152ae3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Brapel Comercio de Ali', 4.0, 'expense', 'paid', '2025-11-19', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a97ccb9c-6871-4c77-a5c6-1f9d2aa17ce8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.59, '2025-11-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3190ebd0-5ddb-4aaa-8176-bd899834c0fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a97ccb9c-6871-4c77-a5c6-1f9d2aa17ce8', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 3.59, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3be29628-2558-4607-88a7-d988aed37256', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.59, 'expense', 'paid', '2025-11-20', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('27b0572e-b10f-47c3-8787-8c156346cbad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, '2025-11-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fbbfa560-6504-41a7-b4cf-c8dd4924451b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '27b0572e-b10f-47c3-8787-8c156346cbad', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 12.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8c0f7c67-f5ea-44ab-abda-3146c5efa34a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Joaobatistavieira', 12.0, 'expense', 'paid', '2025-11-20', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('be30cdf7-7822-4f95-8989-1fa999646d08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Postos Coqueiro', 30.0, '2025-11-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a5b05bc0-8d0f-457e-929e-a4234a30a5bc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'be30cdf7-7822-4f95-8989-1fa999646d08', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('38884a03-a2a2-4c29-b13f-aba0e5286564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Postos Coqueiro', 30.0, 'expense', 'paid', '2025-11-21', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a40c24d6-eabd-494c-8366-259cc942a32d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 24.9, '2025-11-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3f99743e-85dc-4d2c-9416-6f0310d3f0d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a40c24d6-eabd-494c-8366-259cc942a32d', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 24.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21ff9323-2d41-44d2-99c7-2b1beb6be6e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 24.9, 'expense', 'paid', '2025-11-26', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e4255e16-9033-46f5-9d78-b92160a9c1f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2025-11-26', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('14ca0b1e-c1c4-4faf-96be-165facc31e5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e4255e16-9033-46f5-9d78-b92160a9c1f2', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 11.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a3af9d7c-fe83-467d-850d-daf8796d0c6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2025-11-26', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5c990af4-dae8-4bf2-9b05-0706ca6f41fa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 40.0, '2025-11-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c6c64f2f-377b-45b6-b38d-9a6deb1dfe6b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5c990af4-dae8-4bf2-9b05-0706ca6f41fa', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 40.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('434ae475-e5bb-4bb6-abd8-114bd976dab6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 40.0, 'expense', 'paid', '2025-11-26', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ae11aa78-884d-4a37-a444-50b9a1879fb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Subway Xv', 34.9, '2025-11-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cb9d5299-7b60-4543-a8bf-f47e58741c10', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ae11aa78-884d-4a37-a444-50b9a1879fb1', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 34.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('db19c9b0-7fff-4ed7-a0f2-39f61b3eca32', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Subway Xv', 34.9, 'expense', 'paid', '2025-11-26', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3d299bb1-bb93-4c94-b3ec-57218a5669c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 2.8, '2025-11-27', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6e2b006d-adf7-4f71-af9e-be98f45fb0b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3d299bb1-bb93-4c94-b3ec-57218a5669c1', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 2.8, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('977e03ee-3e57-4400-a591-759292a28fc7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 2.8, 'expense', 'paid', '2025-11-27', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('55ad5be3-e144-472e-9cbe-7efd97173e9a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Adega do Colono', 170.0, '2025-12-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4b991711-bb17-48b0-94e7-c90bcfe6086f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '55ad5be3-e144-472e-9cbe-7efd97173e9a', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 170.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('692c9f33-cae9-4fd3-a400-1dcbb2f53262', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Adega do Colono', 170.0, 'expense', 'paid', '2025-12-01', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1945b5db-6893-4008-b67e-68d9560b897a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Luciano Santos Gonçalves', 10.4, '2025-11-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e88ef3bb-1db5-4aa0-a662-d0fa150ea7da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1945b5db-6893-4008-b67e-68d9560b897a', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 10.4, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f689d4bf-b5ec-4ba1-8a1c-5d08ce8197ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Luciano Santos Gonçalves', 10.4, 'expense', 'paid', '2025-11-25', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3059b341-2f9f-40b0-a023-a4e192f46fa6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 20.82, '2025-11-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('12c7a069-fe4f-40ea-88a6-b1c320377005', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3059b341-2f9f-40b0-a023-a4e192f46fa6', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 20.82, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a1420198-d5fa-4742-9d76-fb290c0ffbeb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 20.82, 'expense', 'paid', '2025-11-25', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ce7f9477-3ad9-4c97-84ca-28cae5eacd5a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.62, '2025-11-26', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a376b680-e17a-4488-8644-0b4c9f4fb902', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ce7f9477-3ad9-4c97-84ca-28cae5eacd5a', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1.62, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9fadbf8b-96d2-4982-8a06-e195313a08ef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.62, 'expense', 'paid', '2025-11-26', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('de8653d6-8483-4fa9-848f-5cbd728905e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.07, '2025-11-27', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f9839e8f-af9a-469d-8045-c5fc22dd3d80', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'de8653d6-8483-4fa9-848f-5cbd728905e5', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1.07, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0b30a499-e6e5-4680-b0d4-349ec51ecd3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.07, 'expense', 'paid', '2025-11-27', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fe6040fd-97f9-4a88-8742-e1ff323c113e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.07, '2025-11-27', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cae7f492-e1d4-4cdd-a00f-e4089a4f38b8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fe6040fd-97f9-4a88-8742-e1ff323c113e', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1.07, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('51a41567-3939-4f49-ae51-e899a9ea3873', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.07, 'expense', 'paid', '2025-11-27', '2025-12-11', '2025-12-11', 'c74798d3-a5df-476a-ade4-8f1929494fd0', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-01 (Nubank_2026-01-11.pdf) - R$ 150.73
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('93628453-bd87-406a-be2c-a80e22c46a15', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 1, 2026, '2026-01-04', '2026-01-12', 150.73, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0e827342-2b58-4401-9e4c-fa235d4b2e62', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Universal', 40.0, '2025-12-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e5c8723-56a6-4238-9310-c0e8317e1f44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0e827342-2b58-4401-9e4c-fa235d4b2e62', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 40.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b5ce13a9-2a47-479c-bb9b-f2ef92db1404', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Universal', 40.0, 'expense', 'paid', '2025-12-05', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b191050e-caf2-4107-8004-8477b427ea15', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2025-12-05', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bade0ffd-bd2c-4310-85f6-ff8f652fbc20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b191050e-caf2-4107-8004-8477b427ea15', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 11.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5dabd326-56ae-4630-89ce-c599b3ffaf1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2025-12-05', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f6f92e1e-ebdf-406d-9c8a-cb4a87280b80', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke.', 56.9, '2025-12-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1f36af27-6c7d-4897-acfd-9b3718b608f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f6f92e1e-ebdf-406d-9c8a-cb4a87280b80', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 56.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9b47223c-dd34-4dcc-9eaa-22ebe5c543a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke.', 56.9, 'expense', 'paid', '2025-12-05', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('89b047db-8452-4b39-85a0-264ff1209211', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cineflix', 36.0, '2025-12-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5a212214-617e-48e3-b2b1-3f5972302223', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '89b047db-8452-4b39-85a0-264ff1209211', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 36.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3c445b8a-3be9-4d98-81cb-1a9934bcb326', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cineflix', 36.0, 'expense', 'paid', '2025-12-05', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5f761256-ec88-491e-b392-6ab005dd8e98', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 29.9, '2025-12-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b70ae2ab-ecaf-4b61-9e0e-aed3f80b427d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5f761256-ec88-491e-b392-6ab005dd8e98', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 29.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fb25959d-888c-4317-a07f-13d130783003', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 29.9, 'expense', 'paid', '2025-12-05', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('619e2ce5-e412-4f7e-9a85-5b2ece414ccf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 5.18, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7f1c70db-2774-4094-9f78-bd77beb6b52d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '619e2ce5-e412-4f7e-9a85-5b2ece414ccf', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 5.18, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e9edf8ab-fa77-4778-8311-dbe8f447ff8d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 5.18, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d063966c-e30f-4982-85f0-d5c2d3b9f47c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 24.35, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('79f0cf7e-fe6f-41de-82c0-f62d6908d5c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd063966c-e30f-4982-85f0-d5c2d3b9f47c', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 24.35, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0977132e-5ca9-4452-b997-6b19f3d6f94e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 24.35, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b10d8b2f-57a6-44ff-9b6d-2898f8a471ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 48.58, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0c716f05-ac79-422f-a977-872be4039613', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b10d8b2f-57a6-44ff-9b6d-2898f8a471ba', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 48.58, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ae73f582-a9a2-4582-81f4-ea45eef57f47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Stok Center', 48.58, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dd41fcbe-825c-4d29-8eca-2692d4f666cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Rio Sul Comercio de Ma', 60.75, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9644087b-cbb8-43ba-9392-e78acb70f347', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'dd41fcbe-825c-4d29-8eca-2692d4f666cb', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 60.75, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('983a8938-ef46-4749-9b9e-b57bf65bb77a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Rio Sul Comercio de Ma', 60.75, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8f365593-4d5b-4ee0-8c9d-6a9a53dd86ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 9.5, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('662a5bf4-d9d1-40d9-a2ca-541c079afe0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '8f365593-4d5b-4ee0-8c9d-6a9a53dd86ff', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 9.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('10fdb2ef-3e5e-4608-9a48-c3d10b8303d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 9.5, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7c7a8a59-b26e-428d-8cb3-aca6ea82c6d0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Rio Sul Comercio de Ma', 15.25, '2025-12-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7f97965d-ad83-4f2c-bf3a-5cc09b6c1bd6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7c7a8a59-b26e-428d-8cb3-aca6ea82c6d0', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 15.25, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('35502523-0d97-412f-b9d1-25ba97a740af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Rio Sul Comercio de Ma', 15.25, 'expense', 'paid', '2025-12-06', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ce51ec3b-2356-4d83-8cc4-312b882c7bf7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 14.98, '2025-12-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f23bf95b-59db-4879-8026-14e6545e2349', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ce51ec3b-2356-4d83-8cc4-312b882c7bf7', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 14.98, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ccc7d96-35a8-4317-bba0-6587ee1d3dc4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 14.98, 'expense', 'paid', '2025-12-07', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4b094ba1-e337-45c4-b393-6016e933aae5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 15.95, '2025-12-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3ca41315-a649-4908-87ab-91ef30f2718f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4b094ba1-e337-45c4-b393-6016e933aae5', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 15.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fe41cd0b-bf4e-4e2f-9b15-c366584d7ab5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 15.95, 'expense', 'paid', '2025-12-07', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('97ceebb1-910f-4565-9c8b-5acf550bd5b3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 49.5, '2025-12-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4aa1fc43-cba3-4aad-b629-439580a6022a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '97ceebb1-910f-4565-9c8b-5acf550bd5b3', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 49.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9f9be233-2115-4b9b-a967-3640f4458e56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 49.5, 'expense', 'paid', '2025-12-07', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3d77892f-ddfd-4abb-b947-9dea1be5c49a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Valdirjosenoguez', 51.0, '2025-12-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d6957fd5-5cf3-4d67-9169-b748b99d272f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3d77892f-ddfd-4abb-b947-9dea1be5c49a', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 51.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6181ca5e-138f-484a-9f39-17eabed66037', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Valdirjosenoguez', 51.0, 'expense', 'paid', '2025-12-08', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0f25e44c-8bfd-4f66-92fc-419b8ed6cee4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 80.12, '2025-12-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f6a0b173-36f3-42b0-b51a-2a48656f70d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0f25e44c-8bfd-4f66-92fc-419b8ed6cee4', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 80.12, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a4cce85-2dff-4ab4-a632-e714e7a8b9d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 80.12, 'expense', 'paid', '2025-12-08', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4856d3c9-bdba-4274-92e3-a429669aee1e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'sem*Parar', 30.0, '2025-12-08', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8878bbb8-e74a-4cf7-9918-46ed6a309dd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4856d3c9-bdba-4274-92e3-a429669aee1e', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 30.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f7c31f14-eb4e-4900-a5e1-1cbcd7d9092b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'sem*Parar', 30.0, 'expense', 'paid', '2025-12-08', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dfc4db9c-1046-4d38-accb-b9f3f6f1a595', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jairjosuedacunha', 23.0, '2025-12-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39a6c909-af06-4d08-8be3-db2332b47b20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'dfc4db9c-1046-4d38-accb-b9f3f6f1a595', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 23.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8429bf26-ccbb-4158-b98f-b18d57d2926e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jairjosuedacunha', 23.0, 'expense', 'paid', '2025-12-08', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2f6e53a0-3bcd-4762-b2d5-998d06dd6354', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Natura Pay*Isis - Par - Parcela 1/2', 74.95, '2025-12-08', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5208cdc3-a5d7-40a7-8b77-267d74e0ae55', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2f6e53a0-3bcd-4762-b2d5-998d06dd6354', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 74.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ce3a1272-0e53-4e4e-b4a0-5321f52d3554', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Natura Pay*Isis - Par - Parcela 1/2', 74.95, 'expense', 'paid', '2025-12-08', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('04eb4de2-88ec-4f81-91a5-d916ceb8e9f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 1.4, '2025-12-09', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1e6f090c-6ecb-4857-8b93-92069e8ba227', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '04eb4de2-88ec-4f81-91a5-d916ceb8e9f5', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1.4, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44a8c94e-08af-422c-99b6-48410bae2834', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 1.4, 'expense', 'paid', '2025-12-09', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3ef74cd-d265-4181-b3bf-ae6a4c93739f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 2.8, '2025-12-09', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4a6bcc62-2d59-47a8-8482-ab7889cc0494', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e3ef74cd-d265-4181-b3bf-ae6a4c93739f', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 2.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('58414679-6058-41b8-a22c-2b45ca9f1483', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 2.8, 'expense', 'paid', '2025-12-09', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7fb50c09-53e5-4288-a613-404ded2b1c0d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 11.0, '2025-12-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('115bd3ff-0533-4c38-9cd3-f33553c80b40', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7fb50c09-53e5-4288-a613-404ded2b1c0d', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 11.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('22d9edbe-652e-4402-b99f-7f19b1601019', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 11.0, 'expense', 'paid', '2025-12-23', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8b2a2552-b6d9-4c1c-b9ac-c73bf49fff5d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 14.0, '2025-12-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fadb191f-927c-4982-94c8-1f633aaa8774', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '8b2a2552-b6d9-4c1c-b9ac-c73bf49fff5d', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 14.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3ba1b4fc-2aa8-4aa5-b012-a663a8efd0cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 14.0, 'expense', 'paid', '2025-12-24', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('63e78218-6312-4f18-b815-0634f2ba328a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gran Coffee', 13.99, '2025-12-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ec1fc199-1ed5-4a16-8e6a-cf5dd23438b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '63e78218-6312-4f18-b815-0634f2ba328a', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 13.99, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f425506c-519e-4731-9e2c-a1bdad06b4c9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gran Coffee', 13.99, 'expense', 'paid', '2025-12-25', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fac8d268-70ef-4e1b-8d78-a4ea7fca3b03', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Ultrapopular - Parcela 1/2', 47.39, '2025-12-27', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a5e9bb34-a824-45e7-a064-8a67af4f6ea4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fac8d268-70ef-4e1b-8d78-a4ea7fca3b03', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 47.39, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('046cfe59-2d05-401c-abfd-71bc544b8acf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Ultrapopular - Parcela 1/2', 47.39, 'expense', 'paid', '2025-12-27', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3fb65e3f-ebf8-4c45-8dec-7da3e186b03c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cafesa Anapolis', 7.0, '2025-12-29', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('683d7cf8-a9c5-483e-be96-abb561e1c5b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3fb65e3f-ebf8-4c45-8dec-7da3e186b03c', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 7.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5934c13a-eff9-4ab0-9950-024086e63ec2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cafesa Anapolis', 7.0, 'expense', 'paid', '2025-12-29', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c69281cd-38c9-4030-b85c-a8631c67de55', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Concebra', 5.4, '2025-12-30', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a4f0e556-e73b-4b33-b78c-24aeb45a4b1a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c69281cd-38c9-4030-b85c-a8631c67de55', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 5.4, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2beaa45b-d875-4988-83ce-bab4690186ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Concebra', 5.4, 'expense', 'paid', '2025-12-30', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('da726be9-30f7-47fc-8315-5ae8fc6e87af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 11.5, '2025-12-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5d5ccb64-e77e-40b6-a6c3-3ba12917ca26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'da726be9-30f7-47fc-8315-5ae8fc6e87af', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 11.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d773fbbb-60ab-4813-a3b8-d3c9c1c61c63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 11.5, 'expense', 'paid', '2025-12-31', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f75cde1e-d0ab-429c-9ddf-a69f0cefb80b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 30.5, '2025-12-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('49227988-667b-46e1-a6d9-22bdbdc84f74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f75cde1e-d0ab-429c-9ddf-a69f0cefb80b', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 30.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('86b0e33e-d175-4b21-8248-b2f31ab3241d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 30.5, 'expense', 'paid', '2025-12-31', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f94389e1-1b94-4b34-8ca6-f0afad2310ac', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 30.17, '2026-01-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('127fbfc6-f8af-4646-a817-49bc9f089d01', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f94389e1-1b94-4b34-8ca6-f0afad2310ac', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 30.17, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a152c608-1ad2-44ba-a3e1-c7831925874e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 30.17, 'expense', 'paid', '2026-01-01', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3d589cf-34d8-4346-b68b-3b7df93d2a62', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 3.4, '2025-12-12', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8de5de8e-44d4-4be0-80a8-eef7adb8df05', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e3d589cf-34d8-4346-b68b-3b7df93d2a62', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 3.4, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f3c6695a-76a2-4afa-a394-f5cdccb4d47e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 3.4, 'expense', 'paid', '2025-12-12', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b44b249d-dac7-43ee-a36c-c9d8d842ab57', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.68, '2025-12-12', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('698a86d5-cdcd-43c2-a627-19757b2c187d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b44b249d-dac7-43ee-a36c-c9d8d842ab57', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1.68, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2e0f196f-9fb5-44ad-a572-ca74031a73ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.68, 'expense', 'paid', '2025-12-12', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('814a2da2-225f-4c73-a2d5-ce236a03b6fa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.24, '2025-12-12', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dab6ec9e-43d8-44da-9eeb-ba193f1e2d5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '814a2da2-225f-4c73-a2d5-ce236a03b6fa', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 2.24, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6aee279f-61a9-4ddb-b514-8308f65552a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 2.24, 'expense', 'paid', '2025-12-12', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('74d23d16-1c6e-4c73-a669-8a704706a0c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: GRUPO A', 38.0, '2025-12-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4426ed12-ac55-44b5-a1c3-3dc62385b8e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '74d23d16-1c6e-4c73-a669-8a704706a0c4', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 38.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b2b29f4f-e0cd-4dd2-9f9e-ba6c0e91f62f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: GRUPO A', 38.0, 'expense', 'paid', '2025-12-12', '2026-01-12', '2026-01-12', '93628453-bd87-406a-be2c-a80e22c46a15', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-02 (Nubank_2026-02-11.pdf) - R$ 356.44
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 2, 2026, '2026-02-04', '2026-02-11', 356.44, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3cf3fdb1-050e-4387-9703-719946aae6d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Ultrapopular - Parcela 2/2', 47.39, '2026-01-04', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('977145de-4b38-4d96-b465-708990b77749', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3cf3fdb1-050e-4387-9703-719946aae6d4', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 2, 47.39, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('52a06ff5-9f6e-4d26-8642-fb37d2a73960', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Ultrapopular - Parcela 2/2', 47.39, 'expense', 'paid', '2026-01-04', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 2, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ce0db22c-f895-456a-86d5-1407d918e42a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Natura Pay*Isis - Par - Parcela 2/2', 74.95, '2026-01-04', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('81e42613-a047-47da-b40f-1b2da7e24232', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ce0db22c-f895-456a-86d5-1407d918e42a', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 2, 74.95, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('54cccac8-8ecc-4dfb-948b-d186f9c7d2a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Natura Pay*Isis - Par - Parcela 2/2', 74.95, 'expense', 'paid', '2026-01-04', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 2, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('53fbcdfd-c6f8-49b6-a799-f7f62f562c24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 30.02, '2026-01-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d68d556b-80f4-4fe1-b80d-d4517b0d9056', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '53fbcdfd-c6f8-49b6-a799-f7f62f562c24', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 30.02, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1b11b353-1ecd-4c0a-a467-31e9565da783', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Paulo Moreira', 30.02, 'expense', 'paid', '2026-01-05', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ee541d35-ed2a-4215-8da7-e2dddd7fc9f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 13.0, '2026-01-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d0031e86-04c6-42a5-b598-6804bb9242a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ee541d35-ed2a-4215-8da7-e2dddd7fc9f2', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 13.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5bc985fd-f4bf-4253-a852-b02d741a78a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 13.0, 'expense', 'paid', '2026-01-07', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6f19ea40-df6c-4814-b19d-1691bf410ef0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke.', 30.0, '2026-01-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3a26d99a-7721-4498-b6b2-f461a0c1934b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6f19ea40-df6c-4814-b19d-1691bf410ef0', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 30.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1e6489de-2197-4291-aed8-76cea568c26d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Jke.', 30.0, 'expense', 'paid', '2026-01-07', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('890f491e-0adb-48b4-8e35-3d4cede75a9d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 3.0, '2026-01-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0992b725-d8e7-45ec-b6d4-774c4f330312', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '890f491e-0adb-48b4-8e35-3d4cede75a9d', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 3.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7bebffdb-98ff-419c-b07d-aee6d639b220', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 3.0, 'expense', 'paid', '2026-01-08', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('29810ef6-874b-4cbf-ab89-e9ffae95312d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 12.07, '2026-01-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a8d4c3bd-f551-43bf-bdcb-19c87a342ba3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '29810ef6-874b-4cbf-ab89-e9ffae95312d', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 12.07, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('33e99d8d-a189-421f-8589-0e39bd0eb1b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 12.07, 'expense', 'paid', '2026-01-08', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('69f988cb-f760-4911-b3b2-17fa1312853e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 12.87, '2026-01-09', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('46186b27-7c54-4b89-a878-a69aa56b5e35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '69f988cb-f760-4911-b3b2-17fa1312853e', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 12.87, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('69474106-d05f-4ee7-97b6-e774b2caa449', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 12.87, 'expense', 'paid', '2026-01-09', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('513ebf97-0b51-4366-a550-877d0b78c850', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 25.9, '2026-01-09', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7a1fb918-3c90-40d8-a5f2-29ea9e8ebd5d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '513ebf97-0b51-4366-a550-877d0b78c850', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 25.9, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('60627bef-d1a2-4dab-b477-08f06fa933ac', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 25.9, 'expense', 'paid', '2026-01-09', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('368bc7c8-6acc-4252-a88b-cf8525e6bde7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 10.87, '2026-01-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d52ee1f3-ab96-4017-a7c4-8a71d2b8d2aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '368bc7c8-6acc-4252-a88b-cf8525e6bde7', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 10.87, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b50fab65-eea1-439b-9ac4-b3a464d80b8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 10.87, 'expense', 'paid', '2026-01-10', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eeac8f08-d97e-4a1e-a0be-8a7191a9961f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 28.78, '2026-01-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('27f7098a-4286-43f0-936a-4b07c57b875b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'eeac8f08-d97e-4a1e-a0be-8a7191a9961f', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 28.78, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ef93f6e-26b4-464e-9a09-62acbf729729', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 28.78, 'expense', 'paid', '2026-01-10', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1386e871-d218-4a3f-b2b8-8231125126fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 20.03, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4c901d4b-a158-49e3-ade9-cb840cab5d42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1386e871-d218-4a3f-b2b8-8231125126fd', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 20.03, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8a8abaea-ec63-4160-b92e-5654ee37b1f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 20.03, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('47eaefd0-a534-474e-9928-b8c93dfde0f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, '2026-01-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('842394c0-cc05-443f-8f05-b2f7b2ec59fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '47eaefd0-a534-474e-9928-b8c93dfde0f0', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 8.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a03c2251-00c1-49ba-bc63-5aab492ba54e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Tyamy', 8.5, 'expense', 'paid', '2026-01-21', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6013a3a8-d3d0-4440-a667-589b1b0d9693', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 33.44, '2026-01-22', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2f38cb76-c55f-4a5b-b264-7b487250df48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6013a3a8-d3d0-4440-a667-589b1b0d9693', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 33.44, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8a2a58e9-71c8-4640-9f1a-c7152b9e0a24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 33.44, 'expense', 'paid', '2026-01-22', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c445f393-38eb-4899-8ba7-9da668d52b1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.73, '2026-01-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bd6dae3e-ab4b-43fc-b534-d4e0848583d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c445f393-38eb-4899-8ba7-9da668d52b1b', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 50.73, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dd577a17-54de-4f3c-a5bf-3224b5b4afd8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.73, 'expense', 'paid', '2026-01-23', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a30823a2-2971-4f55-a51b-b18cb73589ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 12.5, '2026-01-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2d2b4c0d-967b-40b2-aff7-5f178ddb2eae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a30823a2-2971-4f55-a51b-b18cb73589ca', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 12.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('00e6cdfc-ee66-4f91-b1e5-41b07db88395', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 12.5, 'expense', 'paid', '2026-01-24', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('300ccfa7-5dd1-49ef-af86-7251f07e669f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 22.65, '2026-01-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e065431-3b0b-4a71-bbfe-8af3e4d48a33', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '300ccfa7-5dd1-49ef-af86-7251f07e669f', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 22.65, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3b43e60-b35b-4499-972d-fa19e31c7064', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 22.65, 'expense', 'paid', '2026-01-24', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f9f3dc3d-0568-4896-a516-963cb60a4bfd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Circulus Lanches', 38.9, '2026-01-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d5ca7ecb-4e17-405d-9d30-013bf836403e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f9f3dc3d-0568-4896-a516-963cb60a4bfd', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 38.9, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('82e627cf-d874-43fd-bd00-14d2240acb83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Circulus Lanches', 38.9, 'expense', 'paid', '2026-01-24', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a516e6ba-778b-4ef5-b1f2-894dfdd88c26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Via Mais Postos Ataca', 14.98, '2026-01-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6bdb7609-dbb8-4b82-a5dc-eeb6965ad5ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a516e6ba-778b-4ef5-b1f2-894dfdd88c26', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 14.98, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('69dc2394-867f-41d2-9062-e825bf5601e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Via Mais Postos Ataca', 14.98, 'expense', 'paid', '2026-01-26', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b747fd3f-8b98-439f-bca2-2ca6fa6e3e27', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2026-02-02', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9f233a09-e294-4f00-afe4-7755f0aa7934', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b747fd3f-8b98-439f-bca2-2ca6fa6e3e27', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 11.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3f2c29dc-0776-4bfa-88a8-fbb55f7a408a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2026-02-02', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c6214bb8-6d51-42fb-be09-ddd4a35e1a3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Zamp S.A.', 16.48, '2026-02-02', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4abd732a-aa4c-4a1a-a930-8cf3a84e40c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c6214bb8-6d51-42fb-be09-ddd4a35e1a3d', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 16.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f703ca54-d4c1-4299-a924-02338de0d0eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Zamp S.A.', 16.48, 'expense', 'paid', '2026-02-02', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e33ed33f-cb70-42f3-99dc-bea64e231593', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*25.030.026 Pamela', 28.96, '2026-02-02', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ac229ed2-1294-42a3-bf91-b42c804cde47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e33ed33f-cb70-42f3-99dc-bea64e231593', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 28.96, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ae2d8647-5873-4936-8e2a-baf7a66b4180', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*25.030.026 Pamela', 28.96, 'expense', 'paid', '2026-02-02', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f1ce2eb5-bc47-4195-81bd-0745c136d62a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CAFESA ANAPOLIS', 69.67, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ee7e63a5-56b0-4390-b357-50205cdc8980', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f1ce2eb5-bc47-4195-81bd-0745c136d62a', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 69.67, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('021daaba-2f5e-44a4-a717-c3b423b07115', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CAFESA ANAPOLIS', 69.67, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('17a2cdff-3508-4fed-bafc-7c4bad9b6376', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 112.08, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f73cba17-03c9-4253-ad34-95eed2c6f8b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '17a2cdff-3508-4fed-bafc-7c4bad9b6376', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 112.08, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('01d59f07-f6ad-43fa-8e6d-74856b8e7fb2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 112.08, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('014e88be-afc8-42af-88f0-0180e9616a61', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Gabriel Leal da Silva', 89.0, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2314102a-7b39-4dbc-ba49-e0920e16dbdc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '014e88be-afc8-42af-88f0-0180e9616a61', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 89.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('885ff85e-d8b0-46e0-9454-c04060ea1172', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Gabriel Leal da Silva', 89.0, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ee628dad-dd42-4bfa-be71-60bb58f29327', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lígia Sousa Rodrigues Prado', 68.71, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('19b0b449-19d6-49fb-91c6-eac39a121d52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ee628dad-dd42-4bfa-be71-60bb58f29327', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 68.71, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eac3c572-be77-419e-b5c8-518128bd0063', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lígia Sousa Rodrigues Prado', 68.71, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1a3a51df-9ea8-44a3-916f-a29e1e873812', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 16.57, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('10d69995-bf73-4583-9831-0be3890660f6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1a3a51df-9ea8-44a3-916f-a29e1e873812', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 16.57, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b5e2cd9a-101e-443b-ad8e-efb3679bd600', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 16.57, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('212caa86-88d3-47f3-9f1b-4b15ac8a6119', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 30.33, '2026-01-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1bf7f61e-d328-4ee0-915e-9d7fe5f9c07b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '212caa86-88d3-47f3-9f1b-4b15ac8a6119', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 30.33, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('649a6423-69f8-4b40-a232-8fc0c6bac34c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 30.33, 'expense', 'paid', '2026-01-11', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c70eb79c-f4ee-45c3-ba7c-8f7acc398c74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 3.29, '2026-01-21', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('615a1e2b-866e-497f-b744-fbf4d5edc6aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c70eb79c-f4ee-45c3-ba7c-8f7acc398c74', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 3.29, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6010b05-9678-4f95-9bf5-8b1514f3ec74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 3.29, 'expense', 'paid', '2026-01-21', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7826e7be-9dc7-47e9-81ab-20b0cadd536e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.65, '2026-01-21', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b6710b38-049e-47f6-bea3-afc3d44cc18c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7826e7be-9dc7-47e9-81ab-20b0cadd536e', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1.65, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e1c38692-7734-4a6d-82dd-7a0d3b265e80', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.65, 'expense', 'paid', '2026-01-21', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f05ce7b2-e9f8-4cd4-8411-293f2fd8de59', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.63, '2026-01-22', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f71ce437-7f07-4274-a36f-965f97c8bbf3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f05ce7b2-e9f8-4cd4-8411-293f2fd8de59', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1.63, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('10746bc7-c2b6-454b-8bff-b17b19b80bfe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.63, 'expense', 'paid', '2026-01-22', '2026-02-11', '2026-02-11', '7eb32a97-312f-48fb-82b7-26ef37fdbbfe', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-03 (Nubank_2026-03-11.pdf) - R$ 452.99
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('37e4203c-6614-49ba-8906-8b5041e4eaed', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 3, 2026, '2026-03-04', '2026-03-11', 452.99, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eb0e8e3f-bfa0-49f7-8157-df4f3c5162c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.0, '2026-02-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b13ecbc1-d9b8-47d5-bf47-22db94a1e85c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'eb0e8e3f-bfa0-49f7-8157-df4f3c5162c2', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 9.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('613b5f5d-6d4a-48de-a6d6-728b68131f6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 9.0, 'expense', 'paid', '2026-02-04', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e45f195d-b8d0-4ba4-9851-cb641b4e0c5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Castelo Alimentos', 25.25, '2026-02-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('47ba7316-50c5-455e-aa3d-7d8460d0ce70', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e45f195d-b8d0-4ba4-9851-cb641b4e0c5c', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 25.25, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('919f1f8f-708c-4a41-83be-3a013c9c2143', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Castelo Alimentos', 25.25, 'expense', 'paid', '2026-02-04', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('59f30af2-5ae8-4c75-87e3-2ce2654a2e45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Amilto Garcia Vieira M - Parcela 1/2', 70.0, '2026-02-05', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('98411bb0-5f69-42fa-ab95-2bc29d32e0b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '59f30af2-5ae8-4c75-87e3-2ce2654a2e45', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 70.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('55903ed7-c862-4907-81cb-1493021bb6f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Amilto Garcia Vieira M - Parcela 1/2', 70.0, 'expense', 'paid', '2026-02-05', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eed4682a-45a6-4e26-9d37-9ea93346bf81', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 92.54, '2026-02-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2cbbf090-13f2-400d-9c77-7c6980fc9e94', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'eed4682a-45a6-4e26-9d37-9ea93346bf81', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 92.54, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2a26a8aa-9356-44fe-ba7f-8029c2a42f2a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 92.54, 'expense', 'paid', '2026-02-05', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c22226be-f802-484a-a444-a90ffe8bd06c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 40.04, '2026-02-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aa3cd052-1a9a-4aec-a6e9-515f4a8c6d81', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c22226be-f802-484a-a444-a90ffe8bd06c', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 40.04, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('281fc4be-2385-4192-8a3a-f5be508179b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 40.04, 'expense', 'paid', '2026-02-05', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7d0d470a-4725-408c-998a-18d22ea2e8ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, '2026-02-05', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('186a86ea-2231-4139-948c-dd835ce8ccb8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7d0d470a-4725-408c-998a-18d22ea2e8ff', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 5.6, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7f8a47ab-6054-4f6b-a617-a16bfb0cf2b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, 'expense', 'paid', '2026-02-05', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('57371e34-8474-4b34-8fa1-5d2cd1c40221', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.3, '2026-02-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c5694ac2-d073-46e4-8e5a-e9b13ab2f1d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '57371e34-8474-4b34-8fa1-5d2cd1c40221', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 50.3, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4f81328e-340d-420f-b1b3-d474c7f7026a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.3, 'expense', 'paid', '2026-02-06', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('776362d2-26b5-4e7f-a8f6-e5afc16e755c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pingo Nozes', 6.0, '2026-02-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ebb1a4db-6bd8-4556-8c59-0b3c489fabd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '776362d2-26b5-4e7f-a8f6-e5afc16e755c', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 6.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b0b08d87-3b4b-4b8e-8934-7047fd29cf58', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pingo Nozes', 6.0, 'expense', 'paid', '2026-02-06', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bf20514b-7dd2-4fb8-8aa5-21ab0c7f1852', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'Uninter', 234.51, '2026-02-07', 1, 'Cartão Nubank PJ (Final 7795) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0c35170d-6e06-4525-99fe-a14c15cef767', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'bf20514b-7dd2-4fb8-8aa5-21ab0c7f1852', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 234.51, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1dc5de0a-f250-449e-9184-59b42cc5395b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'Uninter', 234.51, 'expense', 'paid', '2026-02-07', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('22cafa01-9186-4a75-94e6-bfd5cf05de0c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 14.99, '2026-02-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c4cb4b6d-5b13-40e8-852b-6ca2804ccdd3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '22cafa01-9186-4a75-94e6-bfd5cf05de0c', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 14.99, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a7eefa02-c6a4-4950-a5db-d6cb4ffce4ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Jamielmohamad', 14.99, 'expense', 'paid', '2026-02-08', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a520b50e-7e1a-4997-86a1-5354237ab01b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Acouguedossantos', 30.0, '2026-02-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('122250d9-9c4d-45d8-bdec-9f37ce8b16c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a520b50e-7e1a-4997-86a1-5354237ab01b', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 30.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('469d232e-65cf-4990-a58f-36a10e9ed1ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Acouguedossantos', 30.0, 'expense', 'paid', '2026-02-12', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d2f9d00f-93c4-4ee0-b8f5-96b6de93528b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 12.0, '2026-02-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f4912e2-83ae-4c16-92ff-4e043b3ea8b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd2f9d00f-93c4-4ee0-b8f5-96b6de93528b', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('42cbf447-0570-4151-8ecf-c6437af1f652', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 12.0, 'expense', 'paid', '2026-02-20', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c3020ef1-cdc0-4347-98af-209a4b3332e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Nicolini Supermercados', 44.93, '2026-02-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('453fe5ba-7aae-4949-a427-898e57f3ea2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c3020ef1-cdc0-4347-98af-209a4b3332e1', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 44.93, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dc842418-e32f-4134-9aa0-6a9cd6e097d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Nicolini Supermercados', 44.93, 'expense', 'paid', '2026-02-20', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4cdfd27b-5179-4afb-8971-69cf102089c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 10.0, '2026-02-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f852745c-13d9-4e43-93b3-cd2a75668f06', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4cdfd27b-5179-4afb-8971-69cf102089c2', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 10.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1fa60e0c-89c0-4876-82c4-fd88a469d410', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 10.0, 'expense', 'paid', '2026-02-20', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6ddaa8fb-d74a-47d4-955f-1c31f0e4855c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 102.18, '2026-02-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8c689a62-c8be-4bb5-b508-bcd2fdbfd744', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6ddaa8fb-d74a-47d4-955f-1c31f0e4855c', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 102.18, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1749b75a-17e7-4e3f-a1e1-6dc812621a7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 102.18, 'expense', 'paid', '2026-02-21', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('650cbb1e-9cd5-4cc9-a86f-1fb51325f250', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 21.48, '2026-02-22', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0938ac70-ecb9-4160-a9c5-3cf83d0ff9c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '650cbb1e-9cd5-4cc9-a86f-1fb51325f250', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 21.48, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('302376f3-9968-4ccc-8dfa-89cd85b66ad7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 21.48, 'expense', 'paid', '2026-02-22', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba1dbfd5-3a48-4b79-b1e5-14613611112d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 18.35, '2026-02-22', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fb59d3b0-5efe-4453-b58c-f2e83dadd5c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ba1dbfd5-3a48-4b79-b1e5-14613611112d', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 18.35, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d35f56da-9b56-4f9f-9a58-687c896240e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 18.35, 'expense', 'paid', '2026-02-22', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7b6b1ec3-53ff-4acd-b2c8-8024380a8d29', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 22.87, '2026-02-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('96af10ab-5af2-4590-8396-78885e09b3e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7b6b1ec3-53ff-4acd-b2c8-8024380a8d29', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 22.87, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ee6f8eca-1eac-4f85-8e09-24d5b7692f4e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 22.87, 'expense', 'paid', '2026-02-24', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a7bd12b7-2899-447d-988b-34788704491f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 4.2, '2026-02-24', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('40f06b92-9ed3-4908-b7b0-0d3fef742f9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a7bd12b7-2899-447d-988b-34788704491f', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 4.2, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('512ad45b-d316-4c20-8ee9-bd5e84dbcffb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 4.2, 'expense', 'paid', '2026-02-24', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b627df74-5ee7-4044-a4cc-3b6d5b8971ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 10.0, '2026-02-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5d570c4-9651-4a81-929e-68fb1d17bb1c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b627df74-5ee7-4044-a4cc-3b6d5b8971ce', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 10.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6439105d-0981-4825-a500-c86a3d0d55c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 10.0, 'expense', 'paid', '2026-02-25', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6a996fd4-5720-4102-b586-06f3623d59d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Havan Pelotas', 12.99, '2026-03-02', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f1ce62d-6e2d-4ab6-8ff7-49b749822713', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6a996fd4-5720-4102-b586-06f3623d59d7', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 12.99, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62b1a47a-453f-46db-a6ff-556126e04b7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Havan Pelotas', 12.99, 'expense', 'paid', '2026-03-02', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e13c740e-49fe-4847-bf68-86efe5b537d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CENTRO UNIVERSITARIO UNIFATECIE', 74.84, '2026-02-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0779f307-8b4d-4698-9bfa-ab76847ec368', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e13c740e-49fe-4847-bf68-86efe5b537d3', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 74.84, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9db4d7d1-42f2-4657-aa54-faed2b95c33c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CENTRO UNIVERSITARIO UNIFATECIE', 74.84, 'expense', 'paid', '2026-02-11', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1b7a16e2-dc52-40ed-aa01-a4ebffb7cd02', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.69, '2026-02-19', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f4886dce-f387-44fb-ba6c-0fffb5af2d31', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1b7a16e2-dc52-40ed-aa01-a4ebffb7cd02', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1.69, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('be677d50-f15f-45f9-806f-8dc2ebb5eca8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: MUNICIPIO DE PELOTAS', 1.69, 'expense', 'paid', '2026-02-19', '2026-03-11', '2026-03-11', '37e4203c-6614-49ba-8906-8b5041e4eaed', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-04 (Nubank_2026-04-11.pdf) - R$ 2363.03
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 4, 2026, '2026-04-04', '2026-04-13', 2363.03, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fcbc7afc-a209-48e4-a44f-6c943e752324', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Amilto Garcia Vieira M - Parcela 2/2', 70.0, '2026-03-04', 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fe80b1fd-a241-44fc-9007-f6d6d7ee8298', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fcbc7afc-a209-48e4-a44f-6c943e752324', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 2, 70.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('03e54391-01f6-4d99-9f48-8e7b2962be85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Amilto Garcia Vieira M - Parcela 2/2', 70.0, 'expense', 'paid', '2026-03-04', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 2, 2, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('36eae917-8445-42b8-bd9f-3d97ca605e91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'Uninter', 139.0, '2026-03-05', 1, 'Cartão Nubank PJ (Final 7795) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8d3d15d8-7602-4c27-b4f8-2a9b864d9109', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '36eae917-8445-42b8-bd9f-3d97ca605e91', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 139.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8c1274fe-d97b-492d-8866-31e1a3ee90ec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'Uninter', 139.0, 'expense', 'paid', '2026-03-05', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4b06fa2c-04db-4a34-add6-47f809f72a73', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 3.0, '2026-03-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('78e0a1f1-75ae-40af-a5a7-2c2ae3ea8de5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4b06fa2c-04db-4a34-add6-47f809f72a73', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 3.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('311251c6-c87d-4d72-a2bf-beaf28cebf19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 3.0, 'expense', 'paid', '2026-03-06', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('46efbbe1-2f22-428a-9982-4e0f672505de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 11.0, '2026-03-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f0b62294-6486-45a8-8f35-f314a9859737', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '46efbbe1-2f22-428a-9982-4e0f672505de', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 11.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1637361f-9411-4f3b-a021-89d6851246bb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 11.0, 'expense', 'paid', '2026-03-06', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6ffc3110-9d40-4f72-889f-b21eb61ae0c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 126.19, '2026-03-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e2a6b88-1ad3-4dfa-a19e-0c8389dc5640', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6ffc3110-9d40-4f72-889f-b21eb61ae0c2', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 126.19, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('311a026b-cf3b-4629-93f6-6a9f5cc0dadc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 126.19, 'expense', 'paid', '2026-03-06', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6feabbb7-3d38-48ae-99cf-23d6cb3d475f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 22.87, '2026-03-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('74916ca8-3490-4432-965e-ac8ee29df2b8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6feabbb7-3d38-48ae-99cf-23d6cb3d475f', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 22.87, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ed3440fa-1161-4d9b-b92a-6e7719235b87', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 22.87, 'expense', 'paid', '2026-03-07', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ca513aea-d731-4096-ad66-a2ec8101319c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 42.13, '2026-03-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('77184dbe-3e94-4c1a-98d7-657eec978ad4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ca513aea-d731-4096-ad66-a2ec8101319c', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 42.13, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1d59fa79-bda3-41c3-89cc-40de6211e8cf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 42.13, 'expense', 'paid', '2026-03-08', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f633508c-0585-4681-975e-ac41f3914ddc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Carmendasflores', 20.0, '2026-03-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9c15e8aa-0707-46d4-84b8-0c576c32be4a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f633508c-0585-4681-975e-ac41f3914ddc', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 20.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21157843-6ea3-4680-8d65-88c34d565a41', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Carmendasflores', 20.0, 'expense', 'paid', '2026-03-08', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3fb806dc-00f6-4215-958b-22cfde1d62e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 50.0, '2026-03-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('94d78604-d6c4-4fc4-8185-759ec63e7a84', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3fb806dc-00f6-4215-958b-22cfde1d62e5', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 50.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e5a1bc37-925e-461c-b4f5-cd3e4ee5a191', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 50.0, 'expense', 'paid', '2026-03-10', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('920e5e7f-f283-4e1c-adfd-a18a9ad5d7b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 14.77, '2026-03-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3bc034da-30d4-4650-9fd7-58f4812f8cd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '920e5e7f-f283-4e1c-adfd-a18a9ad5d7b4', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 14.77, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d48e3421-3b6c-4470-99bb-0976590419f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 14.77, 'expense', 'paid', '2026-03-10', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('643aceb6-e79c-4fb3-b548-1ec1fc9e745e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 17.17, '2026-03-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('770cafc2-b441-4c42-98e6-9ea8c299b1a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '643aceb6-e79c-4fb3-b548-1ec1fc9e745e', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 17.17, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4a784e1e-8f17-4099-941d-4deb9a4879b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 17.17, 'expense', 'paid', '2026-03-12', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6309566e-3dc6-4b20-a24c-b0a0b5545cde', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 14.5, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9cfc5c87-2afd-41e1-93db-07f23a82e215', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6309566e-3dc6-4b20-a24c-b0a0b5545cde', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 14.5, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('327fb8b8-4c4c-4ab6-8e88-0ef1da865aac', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 14.5, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7a15feed-ce96-4452-a0ff-09c27a1ffc9c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.5, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('23e3f56f-afc6-4e3f-8dff-29bdb2d88da6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7a15feed-ce96-4452-a0ff-09c27a1ffc9c', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 7.5, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('676787c1-e7c3-48f5-b07c-df72775ef55c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.5, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ef9c0dbc-d108-495c-aa7f-ad368e45066d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 41.85, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4ffbedf6-f934-4030-8c2e-4afdf45fa956', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ef9c0dbc-d108-495c-aa7f-ad368e45066d', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 41.85, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ba7da28f-a85d-4503-aee9-94d909d52993', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 41.85, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4e78620f-9ec3-4f5a-9d1b-9d7d34cc0756', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 25.99, '2026-03-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dc476a9c-8349-4e79-adbe-681952883780', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4e78620f-9ec3-4f5a-9d1b-9d7d34cc0756', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 25.99, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('81131b0f-2bdc-4232-b766-f97489c13f7d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 25.99, 'expense', 'paid', '2026-03-14', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('47beb33c-d8a3-4ea0-af7c-d41b2bb37e85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 50.0, '2026-03-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7838e411-952c-457f-9295-4c88d79308c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '47beb33c-d8a3-4ea0-af7c-d41b2bb37e85', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 50.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('47463cba-9657-4d7f-8fa3-846452916962', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 50.0, 'expense', 'paid', '2026-03-14', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a231d71f-520b-4e0c-b223-1665e8106491', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 13.42, '2026-03-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bc853f14-9f69-4462-944d-2ab583fe4731', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a231d71f-520b-4e0c-b223-1665e8106491', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 13.42, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5c28e23a-1282-45f8-8f57-32e39029a5e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 13.42, 'expense', 'paid', '2026-03-14', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('68c70108-7c11-44d8-bd9c-258aceb228c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Brapel C de A', 37.9, '2026-03-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a8c00ad6-8272-4559-ae9f-8d492e7b5c58', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '68c70108-7c11-44d8-bd9c-258aceb228c2', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 37.9, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('15206420-03fd-4bfa-a2c2-c15325c9d2a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Brapel C de A', 37.9, 'expense', 'paid', '2026-03-14', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9aeeb80f-295e-4b49-ae24-878e279d171b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Comercio de Chocolate', 173.95, '2026-03-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('42463d58-af01-4f1c-b6db-41511a55bb7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9aeeb80f-295e-4b49-ae24-878e279d171b', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 173.95, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9c50e739-9bfd-4a6b-a58f-6d1fbd18ee3c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Comercio de Chocolate', 173.95, 'expense', 'paid', '2026-03-15', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f84a988b-6f3f-42f3-9558-b272712e3db8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Paulo', 10.2, '2026-03-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('15c9b3dc-8c0f-401e-96f5-302443a1eb14', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f84a988b-6f3f-42f3-9558-b272712e3db8', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 10.2, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('99563647-60a2-4306-a75c-cf42e2d3bf9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Paulo', 10.2, 'expense', 'paid', '2026-03-15', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3ccbc268-3eab-44af-88a6-195345bef526', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Farmacia Sao Joao', 18.04, '2026-03-16', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bac9a82f-410b-4201-b43a-94e2b58a036b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3ccbc268-3eab-44af-88a6-195345bef526', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 18.04, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('36026ff5-ad37-487b-9817-fa221ace5ffa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Farmacia Sao Joao', 18.04, 'expense', 'paid', '2026-03-16', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('43cfb400-e776-424e-9351-3bbea658d3be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, '2026-03-17', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('838abc55-5762-447c-8dd9-c76225842635', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '43cfb400-e776-424e-9351-3bbea658d3be', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 5.6, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('375ee60e-491e-4b2f-8858-f6daff3155c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, 'expense', 'paid', '2026-03-17', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6438d5ae-758f-48db-976b-b38208d8cc41', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Filial 367 Plt', 7.49, '2026-03-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('95b232e6-5665-4222-a93f-2a8d19377ed1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6438d5ae-758f-48db-976b-b38208d8cc41', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 7.49, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('20aaaf76-a264-4f5c-b034-ed70ed0dc6b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Filial 367 Plt', 7.49, 'expense', 'paid', '2026-03-17', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fa5cfff3-6f63-40db-8dbc-1633f680cd4f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 18.21, '2026-03-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('971d5603-0e77-4731-be62-c1adce0b62dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fa5cfff3-6f63-40db-8dbc-1633f680cd4f', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 18.21, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('88fd0196-0c34-47f7-bd08-99771efc6c44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 18.21, 'expense', 'paid', '2026-03-18', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b036a100-c0ba-44bd-8c07-179b8cc728c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 100.0, '2026-03-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('746c873f-adfd-47c8-a019-8b47277f0c58', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b036a100-c0ba-44bd-8c07-179b8cc728c0', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 100.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('113390d6-622f-45d0-a75d-cc55e64d7202', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 100.0, 'expense', 'paid', '2026-03-18', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cd1e5273-c520-4278-94be-2d214877a224', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Marilenemartins', 12.0, '2026-03-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b6d31b8b-2b0f-4523-8d03-023f40088803', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'cd1e5273-c520-4278-94be-2d214877a224', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2713dacd-5a01-48e9-9e98-8541868643a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Marilenemartins', 12.0, 'expense', 'paid', '2026-03-18', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2c0dd162-3877-4d95-abb2-baabb60d7fdf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 6.38, '2026-03-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a1a976cd-9813-4603-a242-b005a17f5bfd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2c0dd162-3877-4d95-abb2-baabb60d7fdf', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 6.38, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b87353d2-6f48-4249-a51d-a23791b8e208', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 6.38, 'expense', 'paid', '2026-03-18', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0c1304dc-5227-4386-a004-24b9873e22d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Padaria 1 de Maio', 11.49, '2026-03-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5f35612e-f654-4bd9-b78a-e8f64562fd8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0c1304dc-5227-4386-a004-24b9873e22d2', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 11.49, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aba7cc87-fcfd-48d6-8bfa-afed1b9bb6f8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Padaria 1 de Maio', 11.49, 'expense', 'paid', '2026-03-19', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8d420748-82ea-4f4b-929b-64fcf0b12dfa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, '2026-03-19', 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('26db4864-33fb-4f8f-ba20-673458c4c889', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '8d420748-82ea-4f4b-929b-64fcf0b12dfa', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 5.6, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4efa7d8d-ee98-4086-86f6-8a6ce63bf74c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Zae Pelotas', 5.6, 'expense', 'paid', '2026-03-19', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f758f4f8-3356-49fb-a476-c75590f1beb8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 12.0, '2026-03-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6d68ce56-60cc-4dd3-8684-366405af8736', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f758f4f8-3356-49fb-a476-c75590f1beb8', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b0744811-b102-4054-aa7a-698fff04940f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 12.0, 'expense', 'paid', '2026-03-19', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9eebd8d8-4153-4f84-8894-985a53593d73', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Nicolas Wotter da', 10.0, '2026-03-20', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9e62aa1c-823b-4af4-9269-c2a676dead2a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9eebd8d8-4153-4f84-8894-985a53593d73', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 10.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dd69b8e5-18bf-4640-b53c-e9f0a1a59a4d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Nicolas Wotter da', 10.0, 'expense', 'paid', '2026-03-20', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('74e14a38-27db-4177-b7a6-5c87b823ab71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 45.5, '2026-03-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('85aa0857-144e-4c9c-af07-2beb0f0a4bf5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '74e14a38-27db-4177-b7a6-5c87b823ab71', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 45.5, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ce9cbc73-962f-4a0c-9659-2af7d6c9a0f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 45.5, 'expense', 'paid', '2026-03-21', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8cf6ab01-2140-4d2b-8b5b-0ce48fd11e93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 15.99, '2026-03-22', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d95d6280-90b1-4f5b-ba2c-67ecc771c60a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '8cf6ab01-2140-4d2b-8b5b-0ce48fd11e93', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 15.99, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ddef1405-6164-4738-8337-c43960ab4df0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 15.99, 'expense', 'paid', '2026-03-22', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4c5d8a9f-09f3-439e-8afa-73ddb7ef6f6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 138.18, '2026-03-22', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1c11c1ae-349d-49b9-b7e4-883791eaa1e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4c5d8a9f-09f3-439e-8afa-73ddb7ef6f6c', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 138.18, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('127c7e39-f063-48db-9a03-5f21912e0bcb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 138.18, 'expense', 'paid', '2026-03-22', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5af80abe-c30c-4ee0-87a8-f703e9629b4d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 38.9, '2026-03-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7821869d-5e37-4066-80f4-578544722774', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5af80abe-c30c-4ee0-87a8-f703e9629b4d', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 38.9, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c9349a46-44c1-4ca6-ac8e-2715fda49cc8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 38.9, 'expense', 'paid', '2026-03-23', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5b8271ab-91b4-404c-a49c-2be5ca1bb742', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 57.66, '2026-03-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2b09ed22-1464-4958-a0d5-67fc5e230dd7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5b8271ab-91b4-404c-a49c-2be5ca1bb742', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 57.66, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a036710d-d40a-4642-89fb-7b1805369a56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 57.66, 'expense', 'paid', '2026-03-23', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('85914af7-851d-42d7-999c-d1ad84cb5696', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.89, '2026-03-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('54bc5930-2317-48ff-95b5-33acf3cf96f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '85914af7-851d-42d7-999c-d1ad84cb5696', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 3.89, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('392a3400-28a0-490f-9e77-ab87cadea96d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.89, 'expense', 'paid', '2026-03-25', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('038a0282-49ad-4bb8-b6f2-8fc25d220572', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 30.27, '2026-03-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('00525de0-1c49-4375-8ff7-0c423d399148', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '038a0282-49ad-4bb8-b6f2-8fc25d220572', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 30.27, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0ca50de1-6f05-4dec-8650-f165483618d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 30.27, 'expense', 'paid', '2026-03-25', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dc859c0d-0465-4c92-8dba-576973a9086b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Super Onze', 24.49, '2026-03-25', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f88435c5-6f7b-4535-893e-d65ea0cb031a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'dc859c0d-0465-4c92-8dba-576973a9086b', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 24.49, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('362de3b3-09fd-43cd-b22d-0d14f5fd5798', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Super Onze', 24.49, 'expense', 'paid', '2026-03-25', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1e06817f-45c7-43b4-8e1b-9199fd341d83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 19.24, '2026-03-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bfcbfa03-b563-4c1d-98f9-d83337045e17', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1e06817f-45c7-43b4-8e1b-9199fd341d83', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 19.24, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eef2c8c9-cdf6-405d-a822-cec11eae1618', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 19.24, 'expense', 'paid', '2026-03-26', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('561af712-4a6e-4a43-bd8d-a85ef8b50151', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, '2026-03-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2080336f-bd22-4773-b9f6-abcbabea29bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '561af712-4a6e-4a43-bd8d-a85ef8b50151', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('83fae3e0-650e-4499-a359-60c324f7a630', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, 'expense', 'paid', '2026-03-26', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac2beda4-dad6-41f6-90f7-c28c14ae5c3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cinesystem', 28.0, '2026-03-27', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a78570f4-ed28-46e5-8ce2-adec08e33f83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ac2beda4-dad6-41f6-90f7-c28c14ae5c3b', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 28.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9d525622-7803-435e-acba-d804b04b808f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cinesystem', 28.0, 'expense', 'paid', '2026-03-27', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('35f3ae18-76d1-4bbf-8f94-959098c99357', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Subway', 19.9, '2026-03-27', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a1ee49b3-c102-4094-ac7b-244758e811b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '35f3ae18-76d1-4bbf-8f94-959098c99357', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 19.9, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('33c462c8-1b4d-4aaf-ae2c-f5773a44c27b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Subway', 19.9, 'expense', 'paid', '2026-03-27', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('75113fc9-c82f-422b-8fce-8a317895d47f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Lojas Americanas', 11.99, '2026-03-27', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('51b2e541-882e-4d87-9723-55bda27a5e88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '75113fc9-c82f-422b-8fce-8a317895d47f', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 11.99, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('05375182-3a1e-4336-b386-25b4fd2f6b0f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Lojas Americanas', 11.99, 'expense', 'paid', '2026-03-27', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('79907d97-ccb1-4ef5-a247-e18c46008be6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 14.0, '2026-03-27', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fd002100-84b6-4f86-8315-b47e92105927', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '79907d97-ccb1-4ef5-a247-e18c46008be6', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 14.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0ca3140c-4745-408f-a172-7d432a1aad7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 14.0, 'expense', 'paid', '2026-03-27', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c305bc9a-c520-41d1-aa2f-5d2570b55fc2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 10.0, '2026-03-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2bbded08-49d4-4aa6-a409-53484aa62b43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c305bc9a-c520-41d1-aa2f-5d2570b55fc2', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 10.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a397eb37-125a-449d-a89a-224467755e95', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 10.0, 'expense', 'paid', '2026-03-28', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0250aa19-28d8-4dae-b0f8-1c149ba3a49f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pingo Nozes', 10.0, '2026-03-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4fb1f4f3-b189-4a56-b157-f914badf13f9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0250aa19-28d8-4dae-b0f8-1c149ba3a49f', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 10.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f4804343-58f3-4133-b9ca-4bd4da06a22b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pingo Nozes', 10.0, 'expense', 'paid', '2026-03-28', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('52a12bb2-ea10-45cb-91a2-7b444e9959b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 12.0, '2026-03-28', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('69f4b3b4-6b8d-4252-b759-de68fed01477', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '52a12bb2-ea10-45cb-91a2-7b444e9959b1', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6f8c8a00-9e49-4bb7-b45e-02a075818699', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 12.0, 'expense', 'paid', '2026-03-28', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('155d47fd-3f97-4e2d-b34c-2fa1c0171b49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.3, '2026-03-29', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9bae6c78-e6b4-4707-8db9-b6606d84661a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '155d47fd-3f97-4e2d-b34c-2fa1c0171b49', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 50.3, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d211dddd-aff9-4f56-855f-1ced53780fc9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 50.3, 'expense', 'paid', '2026-03-29', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('be470d36-7324-4fb7-a87e-a92c154f739d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 1/4', 161.66, '2026-03-29', 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eae85c26-2046-4555-8ce2-652b01c0888a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'be470d36-7324-4fb7-a87e-a92c154f739d', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 161.66, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('509c760c-c25c-4ff8-a593-3636e6789b43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 1/4', 161.66, 'expense', 'paid', '2026-03-29', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3c49c1ae-0ddc-4e64-8daa-238d39502803', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 44.79, '2026-03-30', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('21a1d513-ad45-4e88-8241-24b6391d64a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3c49c1ae-0ddc-4e64-8daa-238d39502803', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 44.79, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5e96b530-3042-4de2-94c7-ac538d67ba59', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 44.79, 'expense', 'paid', '2026-03-30', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d40002a5-fa54-4963-8143-c6d59d5c6ef9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 12.0, '2026-03-31', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2d43eeb0-b5ed-42a0-b6ed-effb9f6ed26d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd40002a5-fa54-4963-8143-c6d59d5c6ef9', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ca68ffc-5762-462f-ab47-54052d8ee89f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 12.0, 'expense', 'paid', '2026-03-31', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2d62f873-ac6a-4b0d-89c5-4dccc9ac451b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cristianemullerro', 15.0, '2026-04-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f3ff5ea3-9fb0-43d9-86b2-ed5c8ff394c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2d62f873-ac6a-4b0d-89c5-4dccc9ac451b', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 15.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('da7eb31c-3501-4875-975e-29a35b7f6d26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cristianemullerro', 15.0, 'expense', 'paid', '2026-04-01', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6b43a6fe-d94a-487f-a4f7-338a27a28566', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Paulo Mor', 50.0, '2026-04-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('48725441-7155-4275-89a0-1cce08f8433c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6b43a6fe-d94a-487f-a4f7-338a27a28566', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 50.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a67b38dd-7300-40a7-b359-31f9d55de5a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Abastecedora Paulo Mor', 50.0, 'expense', 'paid', '2026-04-01', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f23c4849-6799-4b7b-9226-b83f02e9e962', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 10.5, '2026-04-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a51017fc-74bd-4f70-801b-bf00eca2c508', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f23c4849-6799-4b7b-9226-b83f02e9e962', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 10.5, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('05e99e15-e9a3-41d3-8a41-f0558e9fe180', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 10.5, 'expense', 'paid', '2026-04-01', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6825974e-314a-4971-85b1-be5724ee1a1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.89, '2026-04-01', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('12a0df30-4cdf-4f6d-a20b-5a7a971eadf9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6825974e-314a-4971-85b1-be5724ee1a1d', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 3.89, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e77a3fec-c9cb-46b1-a864-4976ab90036b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 3.89, 'expense', 'paid', '2026-04-01', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('006f3a0a-41bb-4a95-8ca8-983273a34746', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2026-04-02', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('600fcb32-a3d2-4397-948f-fca82c4cf565', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '006f3a0a-41bb-4a95-8ca8-983273a34746', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 11.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b5fa1ef7-85f5-4172-84af-820c62dff564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2026-04-02', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5a3f7632-d280-49c0-8800-296c5bd0efd8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, '2026-04-03', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('25214b07-7c46-4b59-9a50-0c0aa66b1b24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5a3f7632-d280-49c0-8800-296c5bd0efd8', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 12.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6d57fa7c-66e1-443f-a83f-3f7dc7a5987a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, 'expense', 'paid', '2026-04-03', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('073c1744-b733-43ea-a2e0-d4c99e9f4069', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CENTRO UNIVERSITARIO UNIFATECIE', 75.55, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e8b3c338-cd1d-48c2-a7cd-6b0b1f1c6404', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '073c1744-b733-43ea-a2e0-d4c99e9f4069', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 75.55, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('94576bbd-3eb9-416f-bf1b-bf8942973d04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: CENTRO UNIVERSITARIO UNIFATECIE', 75.55, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5c1c0767-25e2-4563-b381-952f30208f40', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Pix/Boleto no Crédito: Claro', 57.09, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('09c0b99f-cdc0-43dc-863a-6895b7d76d48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5c1c0767-25e2-4563-b381-952f30208f40', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 57.09, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0a51eb03-122e-47c5-b22f-cd132ce3ade4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Pix/Boleto no Crédito: Claro', 57.09, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2701f7a8-80ba-4caf-9d5d-f685bd3dac19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: CEEE DISTRIBUICAO', 55.28, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c5f4d38f-7013-4742-9818-9958afa5b946', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '2701f7a8-80ba-4caf-9d5d-f685bd3dac19', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 55.28, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dc39270d-f91e-4593-b056-7a61e9d17e28', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pix/Boleto no Crédito: CEEE DISTRIBUICAO', 55.28, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba3d4995-8499-4a77-9526-5ff0616f8113', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Pix/Boleto no Crédito: Claro', 69.82, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cf7f3b8d-74dc-447b-ad0c-a4465b58bac3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ba3d4995-8499-4a77-9526-5ff0616f8113', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 69.82, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a7d4b48c-137c-4bad-aef2-bae16354a8b0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Pix/Boleto no Crédito: Claro', 69.82, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9fd536a8-651d-4cd4-946b-6a4c52ca51a9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: IFOOD.COM AGENCIA DE RESTAURANTES ONLINE S.A.', 39.53, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('47bb5679-7232-481d-8551-6804cbec9426', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9fd536a8-651d-4cd4-946b-6a4c52ca51a9', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 39.53, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('77349fef-2dec-47bf-b3df-ad6745d516be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: IFOOD.COM AGENCIA DE RESTAURANTES ONLINE S.A.', 39.53, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fdcd256b-01cf-4215-831f-314fa6b18e8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 78.98, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0b77308e-0f95-419e-aa6d-5632e937318e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fdcd256b-01cf-4215-831f-314fa6b18e8e', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 78.98, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('00baf592-408c-46a8-ac1d-2b9f374759be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 78.98, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('10a0a6c7-773c-47e5-a768-53ff57aee92d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 78.98, '2026-03-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bf144f02-e045-4bdb-981d-0bf2b0e43987', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '10a0a6c7-773c-47e5-a768-53ff57aee92d', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 78.98, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('52868cd0-b425-4992-b5b1-15de6c350a97', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 78.98, 'expense', 'paid', '2026-03-13', '2026-04-13', '2026-04-13', 'c8aebd32-5ef7-4a1b-bcaf-945d658f1615', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-05 (Nubank_2026-05-11.pdf) - R$ 3006.96
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('03854a90-9073-402a-ae6e-940c6ab4b2db', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 5, 2026, '2026-05-04', '2026-05-11', 3006.96, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e1822b57-67fa-4dcf-b7e7-74ed5d6d20d0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 2/4', 161.65, '2026-04-04', 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cede376f-01c9-428d-8e8f-91a406d6147a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e1822b57-67fa-4dcf-b7e7-74ed5d6d20d0', '03854a90-9073-402a-ae6e-940c6ab4b2db', 2, 161.65, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('572645d6-1577-4cbf-b65e-dbd2dd31fe7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 2/4', 161.65, 'expense', 'paid', '2026-04-04', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 2, 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4b172ea8-ffc5-4134-83d0-ed52385442f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 164.37, '2026-04-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('48b10a70-7404-42d5-8835-1363839bfdd6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4b172ea8-ffc5-4134-83d0-ed52385442f0', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 164.37, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eaf5fc99-2300-4195-b94e-aab0030de03a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 164.37, 'expense', 'paid', '2026-04-05', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('138fe763-74b2-4bf8-a97a-0220f270080a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 259.47, '2026-04-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3492a188-289b-403b-ac6a-a7b4560b3fa0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '138fe763-74b2-4bf8-a97a-0220f270080a', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 259.47, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8886d49f-3c2e-4bae-95cc-85c54ffe7088', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn *Tiktok Shop', 259.47, 'expense', 'paid', '2026-04-05', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dd88f96e-71cb-482a-90be-348b4d441d5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 7.49, '2026-04-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5cfe7fa-d1ca-4773-bcb0-5a061073c832', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'dd88f96e-71cb-482a-90be-348b4d441d5c', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 7.49, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3cb9efd3-eda9-4fbf-afe5-d4b1101d79fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 7.49, 'expense', 'paid', '2026-04-05', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('33223c15-ab44-41d8-adef-b2c12be2e9d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 16.77, '2026-04-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('44c30c6f-3358-41ac-8b14-730b86c3d047', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '33223c15-ab44-41d8-adef-b2c12be2e9d9', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 16.77, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d38d5d30-afad-4cae-b6e7-ef4ec0e4e420', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 16.77, 'expense', 'paid', '2026-04-05', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eca1fe07-7ec5-46c7-aead-ee02f0d3adaf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 14.49, '2026-04-06', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b1656b41-a8d5-4ef3-9056-4197c5a31e32', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'eca1fe07-7ec5-46c7-aead-ee02f0d3adaf', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 14.49, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('89365db0-0e14-4f80-a5a7-6a8e32675c7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Jvbebidase', 14.49, 'expense', 'paid', '2026-04-06', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('28048204-e564-4d4f-a4eb-1ba90364d154', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 51.11, '2026-04-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b66a131b-68c5-447a-9d22-df4b19ce8d91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '28048204-e564-4d4f-a4eb-1ba90364d154', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 51.11, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bb4dc187-138e-461e-b760-9067d5d53dcb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Gb Mix Quartier', 51.11, 'expense', 'paid', '2026-04-07', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9567fbf9-1969-410b-a1ed-bfd8849a6941', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Santo Forno Massas', 30.24, '2026-04-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5fb85eae-fa88-41a3-be02-884a9a1f5207', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9567fbf9-1969-410b-a1ed-bfd8849a6941', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 30.24, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2557b77f-54e1-423d-a26c-7ba37bab39b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Santo Forno Massas', 30.24, 'expense', 'paid', '2026-04-07', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6e419a21-d5b1-456b-8639-e58c4782abd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 49.95, '2026-04-07', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('21afb613-9da4-4629-8b9d-36428ac1bff2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e419a21-d5b1-456b-8639-e58c4782abd0', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 49.95, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cd6c0b29-5554-4b50-855a-f42ffa7db47f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 49.95, 'expense', 'paid', '2026-04-07', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('08ed2de7-a05c-400e-8cb5-0c5e70547018', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial', 49.1, '2026-04-08', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3e25a382-fcef-4ef0-93cb-6294a5958f0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '08ed2de7-a05c-400e-8cb5-0c5e70547018', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 49.1, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('899525db-95fe-4555-81f2-3d5cc9e7912e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial', 49.1, 'expense', 'paid', '2026-04-08', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f87c3623-e3fa-40b0-8c47-2ff44a19b4d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, '2026-04-10', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e327d34e-5a4b-4170-bad0-8f3ecc5d24c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f87c3623-e3fa-40b0-8c47-2ff44a19b4d2', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 12.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3b7dfeda-c363-4942-858b-99fa3e7a315a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, 'expense', 'paid', '2026-04-10', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b9d44df0-beac-483b-b48c-c61190d67c2c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 66.0, '2026-04-11', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bbcee483-47e9-4e54-8521-0a55129d38f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b9d44df0-beac-483b-b48c-c61190d67c2c', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 66.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5c8cb408-3d40-429a-9270-2b80bba8e297', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 66.0, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fda35f87-b0e9-4f7f-a093-ca3254bdda0b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5ea204d9-d667-4abd-8300-70ec31041ec0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fda35f87-b0e9-4f7f-a093-ca3254bdda0b', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 13.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f4bda753-42e6-4b55-a288-47691766cb19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0d97447b-5f34-4233-90f0-8c7dd931e1cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/3', 146.42, '2026-04-11', 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('17b798df-f854-477f-a108-f86528b19b83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0d97447b-5f34-4233-90f0-8c7dd931e1cb', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 146.42, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('877379d2-534c-4a4d-b2e6-36bc35f94aef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/3', 146.42, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('06962cff-85f5-4f9c-a921-b11a7d1b09cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 214.75, '2026-04-11', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('67838ea7-334a-4c39-82bb-43982ef753ef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '06962cff-85f5-4f9c-a921-b11a7d1b09cc', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 214.75, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('50d031b6-76ac-42cf-a050-3cd4f6449f78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 214.75, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('35ccc495-17f7-4a0b-8986-688bf5b84b44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/2', 222.26, '2026-04-11', 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cf0d4059-da64-48ed-a4aa-9a4a4bdc6d54', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '35ccc495-17f7-4a0b-8986-688bf5b84b44', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 222.26, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('45768869-2409-4c2e-85d3-4a6a0c4bb138', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/2', 222.26, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0f1275dc-076e-4340-994a-b1d357dc79ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/2', 206.07, '2026-04-11', 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('673d8ba2-417a-4c0d-ad46-539533325fe9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0f1275dc-076e-4340-994a-b1d357dc79ee', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 206.07, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('53563e1e-b12f-4423-bc15-163393a02204', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/2', 206.07, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0cd2d5b0-a7e6-4077-8eee-f9199772b2eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 69.9, '2026-04-12', 1, 'Cartão Nubank PJ (Final 4632) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b51c1f4c-4b04-4f49-a522-aa9c3b368b90', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0cd2d5b0-a7e6-4077-8eee-f9199772b2eb', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 69.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('69a4ce9f-bc8a-428e-bf39-f4843669f1c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 69.9, 'expense', 'paid', '2026-04-12', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 4632) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fad6b6cd-6a2e-4ecf-8a62-3f184c36f611', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 1/6', 125.0, '2026-04-12', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('268b5e5e-0208-4c2d-a5d2-f26c04ce3f15', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fad6b6cd-6a2e-4ecf-8a62-3f184c36f611', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 125.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1382047f-7c1c-49ea-9945-09f2f71c0bf7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 1/6', 125.0, 'expense', 'paid', '2026-04-12', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('51f86624-4b24-4594-9e49-ea63ebea7df5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, '2026-04-12', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9b4c7969-c156-4f5c-bfc5-45b9bc3127e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '51f86624-4b24-4594-9e49-ea63ebea7df5', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 11.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fe09dcb2-ad28-4cf0-acfd-0929c8e1cfd5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao de Es', 11.0, 'expense', 'paid', '2026-04-12', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('40194509-1dc8-4f46-ad54-6d13d4871763', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 49.99, '2026-04-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cbbe5e7b-0273-4e70-ae83-6e6fd6ab13d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '40194509-1dc8-4f46-ad54-6d13d4871763', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 49.99, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('923079dd-cec7-464b-90d7-24835c327004', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 49.99, 'expense', 'paid', '2026-04-12', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('84d6f526-2bc9-4ad8-aded-e65a49056692', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 18.21, '2026-04-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('93ef9f5c-5889-4adb-9522-8c0f7dbca3e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '84d6f526-2bc9-4ad8-aded-e65a49056692', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 18.21, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c50a8f82-ea21-4498-a6a7-1d20c4ca754d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Supermercado Guanabara', 18.21, 'expense', 'paid', '2026-04-13', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6ed78b2c-ca68-4ae9-a41c-c81a026797bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 3.0, '2026-04-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('321a9efe-2c40-446d-b071-78cfb1f0dd5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6ed78b2c-ca68-4ae9-a41c-c81a026797bd', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 3.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('db54f76e-8e6c-4fdb-82ff-d4eb90c0c1e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 3.0, 'expense', 'paid', '2026-04-13', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5cc42157-5a75-475a-bf78-9575aff360df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 44.9, '2026-04-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('350dd223-4f85-4de2-8df7-1975292a7d97', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5cc42157-5a75-475a-bf78-9575aff360df', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 44.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4f551cc4-1fed-429d-acd7-0e43ba07b2f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 44.9, 'expense', 'paid', '2026-04-14', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('60dea08e-2037-49e1-a179-4bb9da397529', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cineflix', 20.0, '2026-04-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e8738f23-5329-4f35-9675-e3d0c7f57080', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '60dea08e-2037-49e1-a179-4bb9da397529', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 20.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c8d654d4-b6b9-4c35-b5cb-d3a1445852a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Cineflix', 20.0, 'expense', 'paid', '2026-04-14', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('43d4d62d-f3ec-4ca8-a7a4-613ba6cb99ad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 12.75, '2026-04-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c1833684-5d6e-46e9-805e-b524de67c911', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '43d4d62d-f3ec-4ca8-a7a4-613ba6cb99ad', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 12.75, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e55738ec-b8ff-42ea-b316-e46725512330', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 12.75, 'expense', 'paid', '2026-04-15', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('de2c0016-dab8-42cd-ae0e-4cbec8b1781d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn*Tiktok Sh', 69.8, '2026-04-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1fc130f8-c865-481d-aec9-c30c9869f2b3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'de2c0016-dab8-42cd-ae0e-4cbec8b1781d', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 69.8, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8a919757-fe65-400c-aefa-efad3bba4b27', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Ebn*Tiktok Sh', 69.8, 'expense', 'paid', '2026-04-15', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d5180a08-ec10-41ae-a08f-ddfc60f03d75', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 11.46, '2026-04-15', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('117871b3-bffe-4eb8-bb79-826609d299c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd5180a08-ec10-41ae-a08f-ddfc60f03d75', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 11.46, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3479019d-197e-458a-a3d7-79245784bc2b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 11.46, 'expense', 'paid', '2026-04-15', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7821e76d-fd69-42df-9f9f-08f079e1e186', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, '2026-04-16', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5953260f-1a9a-4eb3-8d11-308be82a4ccd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7821e76d-fd69-42df-9f9f-08f079e1e186', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 13.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d23e17d7-d246-4094-9972-27a76565f924', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, 'expense', 'paid', '2026-04-16', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d7902d5c-1771-4067-8089-cf5a80e70552', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 65.0, '2026-04-16', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('73bc265d-6438-41a6-93f6-5d07e111162a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'd7902d5c-1771-4067-8089-cf5a80e70552', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 65.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b05b41f9-ac55-4bff-92f2-7960b6d423a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mauricio Silveira Avil', 65.0, 'expense', 'paid', '2026-04-16', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('177e3408-fec3-4c0e-adb2-ce187a5dfd1c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fabianeweberrodri', 4.0, '2026-04-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('220c7775-4e68-4bb0-bc9c-e2b6f5843282', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '177e3408-fec3-4c0e-adb2-ce187a5dfd1c', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 4.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0e9e489b-5cca-41d3-a4a6-d7d9f670d092', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fabianeweberrodri', 4.0, 'expense', 'paid', '2026-04-17', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('09711e94-359f-48dc-91aa-b278c386c056', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fabianeweberrodri', 6.5, '2026-04-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('25ccabb3-da5e-4e5e-bbcd-9ce42137fc5e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '09711e94-359f-48dc-91aa-b278c386c056', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 6.5, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('68ef36fb-b87b-49a7-8dd4-dc0d1762ae9c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fabianeweberrodri', 6.5, 'expense', 'paid', '2026-04-17', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('759dbfe2-1f61-4148-8cff-8236ca6cdfa0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 40.0, '2026-04-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39ea8d86-7ae2-4369-b879-e6f5b88eb1fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '759dbfe2-1f61-4148-8cff-8236ca6cdfa0', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 40.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0dfcd533-d8b9-4334-a489-72bd410ff6c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Posto Paulo Moreira', 40.0, 'expense', 'paid', '2026-04-17', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('219fcd20-cf40-4151-bed4-bd60bcf551bc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 2.0, '2026-04-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('366e8bdd-5a36-470b-9fec-2a6363122d92', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '219fcd20-cf40-4151-bed4-bd60bcf551bc', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 2.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5bab0c29-3990-44cd-b7b6-69ba6a0d597d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 2.0, 'expense', 'paid', '2026-04-18', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3b9b546-a788-4dcc-848f-7adf004c273b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 15.98, '2026-04-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('19bdb0cf-5d16-4c88-ba76-ea533c76d96e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e3b9b546-a788-4dcc-848f-7adf004c273b', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 15.98, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('86773701-d3aa-440b-8454-26c44dd4f7a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 15.98, 'expense', 'paid', '2026-04-18', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a2c5b9f8-3f67-4f51-a381-c9d42e5d760e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 14.98, '2026-04-18', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('38119548-e448-4088-96f2-0b30c0f505b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a2c5b9f8-3f67-4f51-a381-c9d42e5d760e', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 14.98, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b450244f-c55b-4664-bd77-8ac5c585adc6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Buffon', 14.98, 'expense', 'paid', '2026-04-18', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba32df3d-c766-475b-9a08-25c4d78c8a08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Agibe dos Santos', 74.9, '2026-04-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d876c305-d53d-4d2d-a922-f48d2d0cb641', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ba32df3d-c766-475b-9a08-25c4d78c8a08', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 74.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21ef5b1b-332c-4ce9-b550-dfb61abe1a70', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Agibe dos Santos', 74.9, 'expense', 'paid', '2026-04-19', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ee5f6bf3-f443-4c6e-9bd2-0762f8f57425', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 45.86, '2026-04-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('81f247b8-5a3f-4a57-b879-8b6179c95741', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ee5f6bf3-f443-4c6e-9bd2-0762f8f57425', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 45.86, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('494c9604-400a-4dda-96a6-95b73fba31f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 45.86, 'expense', 'paid', '2026-04-19', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f5a44f5e-cec8-4914-aaf3-36e9bf9aa293', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 14.0, '2026-04-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a16bf08e-ca4d-427f-b4d9-9acbc69c4a68', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f5a44f5e-cec8-4914-aaf3-36e9bf9aa293', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 14.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b53d230b-ec50-47fb-b943-4e47c5d538a9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Mbuckdesouzaltda', 14.0, 'expense', 'paid', '2026-04-19', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b3099690-8a67-457b-a961-0e136dc0a8da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Farmacias', 19.8, '2026-04-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f21d2bd7-8c5c-49bf-b5f4-03bb86926e85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b3099690-8a67-457b-a961-0e136dc0a8da', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 19.8, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f4ccab7e-0059-4350-b37d-c167d1b9aa1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Farmacias', 19.8, 'expense', 'paid', '2026-04-19', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('59cbb025-04e0-460d-ab50-87c1080f5dfe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, '2026-04-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ce1fcab4-6d87-4491-86af-979d67d6514c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '59cbb025-04e0-460d-ab50-87c1080f5dfe', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 13.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4068d22e-fa9f-4658-a0d6-2d699c2d6d16', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, 'expense', 'paid', '2026-04-21', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('543357e3-39c2-4425-8125-e4dbdc33134c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 42.01, '2026-04-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0bf3ae80-90fa-45bb-9ef1-7a75716f26a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '543357e3-39c2-4425-8125-e4dbdc33134c', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 42.01, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dcb03849-e1de-4229-a0e8-0de9045f7044', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '486e0678-651e-4083-958d-1955ae38bd61', 'Dli Comercio de Combu', 42.01, 'expense', 'paid', '2026-04-21', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9fdd99d1-f062-4cc1-887a-5384d8506755', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao Estac', 14.0, '2026-04-22', 1, 'Cartão Nubank PJ (Final 3168) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('80187eec-5ff1-49bb-b038-a8e726d8819e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9fdd99d1-f062-4cc1-887a-5384d8506755', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 14.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5f76a467-9778-45c3-9d06-576797662adb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Pelotense Gestao Estac', 14.0, 'expense', 'paid', '2026-04-22', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3168) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4bca7429-2a42-4edb-81de-4233ba55acba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King App', 25.8, '2026-04-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c526fb20-2e5d-4ef7-bce0-f2e8a773ca77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4bca7429-2a42-4edb-81de-4233ba55acba', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 25.8, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('60adb11d-bd46-429a-b409-cc2d086ba64d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King App', 25.8, 'expense', 'paid', '2026-04-23', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9945a5fd-df64-4d35-9d03-585f7a6812d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 11.0, '2026-04-23', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('73536093-461b-4da4-ae87-15af3646ae35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9945a5fd-df64-4d35-9d03-585f7a6812d3', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 11.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1c95261b-6198-4a62-b72b-216463d5d20c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 11.0, 'expense', 'paid', '2026-04-23', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('225493f5-bbdc-49cf-aa40-e3cf84a23a77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, '2026-04-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c4b6af91-9f7e-4723-b585-a2897c8c85da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '225493f5-bbdc-49cf-aa40-e3cf84a23a77', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 30.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('918f6b96-7ee2-4519-972d-5f77c3750615', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 30.0, 'expense', 'paid', '2026-04-24', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('415fed3b-c81d-4e57-91e4-f647972ef3b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, '2026-04-24', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2bcf5af5-6c46-4d28-8df8-10456f0a48b0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '415fed3b-c81d-4e57-91e4-f647972ef3b6', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 12.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c09bd55c-17a7-4698-a418-464f20022e86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, 'expense', 'paid', '2026-04-24', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('752e3aaa-af05-4c1e-bedd-4ba25c1e6344', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 10.65, '2026-04-26', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('960145fe-470e-4843-ae1c-532c23a5eb76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '752e3aaa-af05-4c1e-bedd-4ba25c1e6344', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 10.65, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7ca5ce12-1661-4772-bbef-722e10453625', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Carrefour Pelotas Gene', 10.65, 'expense', 'paid', '2026-04-26', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('51a726c4-a7a6-4bdd-bb3e-996741e53a45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.0, '2026-04-29', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bf12ad70-c6ea-437c-bfd4-56702b8e539b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '51a726c4-a7a6-4bdd-bb3e-996741e53a45', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 7.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('25ec5a68-43cf-4639-845d-b4e5c7c44258', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.0, 'expense', 'paid', '2026-04-29', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0129d895-ab2b-4911-b1fe-a6e13b0c7cb0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Pix/Boleto no Crédito: UNE SUSHI LTDA', 231.48, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1dec41a6-1a8a-4289-ab25-6c392937a549', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0129d895-ab2b-4911-b1fe-a6e13b0c7cb0', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 231.48, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('60dad237-12e5-47d0-85db-1ef8f4c97a56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Pix/Boleto no Crédito: UNE SUSHI LTDA', 231.48, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('01038ff2-2c4a-46c1-a21f-10a467167f7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: FLAVIA ELENA RODRIGUES RIBEIRO', 223.76, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e3729d43-44cf-46da-81ac-f84d26b7e707', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '01038ff2-2c4a-46c1-a21f-10a467167f7e', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 223.76, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b67c0b27-02e5-42e6-b582-a20212247300', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: FLAVIA ELENA RODRIGUES RIBEIRO', 223.76, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c220fd85-64f9-4aea-8279-bf0af009e7e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 77.19, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('692fa5cf-af15-46a0-83fd-64ba51024e60', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c220fd85-64f9-4aea-8279-bf0af009e7e7', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 77.19, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('199a4756-8898-4015-8abd-ce1b9664d087', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 77.19, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba3f4d3e-9952-457b-9086-fbe5c262ed2a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 110.34, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8611b934-e7b5-4ef0-afcd-7ff153d3cc0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ba3f4d3e-9952-457b-9086-fbe5c262ed2a', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 110.34, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2ffa92ad-fbd8-4d3a-bfcd-171c28ec296d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 110.34, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a6feafa8-d33d-4193-be1e-3937f9ad327d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 77.19, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('541ad0ac-af44-4492-a78a-f8ff15165e22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a6feafa8-d33d-4193-be1e-3937f9ad327d', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 77.19, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5661dced-4aad-457d-a977-67d55c04eb8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: METROPOLITANA', 77.19, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('408ac4e0-31a2-45ee-a236-5ca276a21c31', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 62.15, '2026-04-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5c97096-cde5-4027-b947-dff5bdf2bbb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '408ac4e0-31a2-45ee-a236-5ca276a21c31', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 62.15, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c72e63f9-8103-4b5e-bc63-33e83e6a4478', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Lara Farias Monteiro', 62.15, 'expense', 'paid', '2026-04-11', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f0941ac8-28d5-4dfa-a728-b8e3314848d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 32.52, '2026-04-19', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('35f0f2ff-9aba-4aa1-be1b-5b68f79fbcd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'f0941ac8-28d5-4dfa-a728-b8e3314848d4', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 32.52, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c0cafd55-a0fb-4079-a03a-65a66ad91464', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Bruno de Souza Goncalves', 32.52, 'expense', 'paid', '2026-04-19', '2026-05-11', '2026-05-11', '03854a90-9073-402a-ae6e-940c6ab4b2db', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-06 (Nubank_2026-06-11.pdf) - R$ 2300.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 6, 2026, '2026-06-04', '2026-06-11', 2300.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('22f1b892-97fe-43f3-8022-5b17335b241c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 2/2', 206.07, '2026-05-04', 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1954aaa9-338d-448f-b641-71a7470c065f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '22f1b892-97fe-43f3-8022-5b17335b241c', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 206.07, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e19dcb5f-b731-4a8d-b61e-8444e4506421', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 2/2', 206.07, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('025e5cf9-3d86-4fcb-b249-33e6730e57a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 3/4', 161.65, '2026-05-04', 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2432c711-4d58-466c-acca-3ca7defa6435', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '025e5cf9-3d86-4fcb-b249-33e6730e57a2', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 3, 161.65, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('db690e03-07a4-4131-bd55-35794be7ad06', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 3/4', 161.65, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 3, 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('44b9dce0-ae63-4081-ae70-58b422abef34', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 2/3', 146.41, '2026-05-04', 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7ea5d646-0733-4281-be1e-9cd5726eca7c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '44b9dce0-ae63-4081-ae70-58b422abef34', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 146.41, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eafb86ae-a6b2-4350-b37c-c9bb35d13b9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 2/3', 146.41, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0e213f99-4379-4407-952d-6c3d01f63bdf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 2/6', 125.0, '2026-05-04', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('23c75d6c-5be2-42f5-9b39-fa1b2e060058', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0e213f99-4379-4407-952d-6c3d01f63bdf', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 125.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4738385d-e155-467a-aead-6d4703d68a66', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 2/6', 125.0, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3dbb95ef-efa5-4623-804d-a33f451cf9c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 2/2', 222.26, '2026-05-04', 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('823055de-d56d-4284-ade1-00c895a3a673', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3dbb95ef-efa5-4623-804d-a33f451cf9c1', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 222.26, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0a946d3e-6712-4cab-ba0c-dda4e7ef0a48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 2/2', 222.26, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 2, 2, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0ba02381-663b-48ee-b4a6-7ee0c68264dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Raparts - Parcela 1/3', 103.34, '2026-05-05', 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('654b2d1d-61f5-4721-a3f3-3abf3397eb7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '0ba02381-663b-48ee-b4a6-7ee0c68264dd', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 103.34, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1ae7e0e6-f0c5-4650-ae3e-3eed4f93bd0c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Raparts - Parcela 1/3', 103.34, 'expense', 'paid', '2026-05-05', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c517d7bd-fc6c-4fcd-944d-28ca35c0246e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 50.0, '2026-05-05', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b7f0936a-08f7-4bf9-a81a-5291489ab712', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c517d7bd-fc6c-4fcd-944d-28ca35c0246e', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 50.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eac467be-3d33-4f94-95e4-5d9e6ce35e0c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Convenienciajj', 50.0, 'expense', 'paid', '2026-05-05', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4e46b220-d395-459b-8601-43cc2b01107e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Lara - Parcela 1/3', 393.03, '2026-05-08', 3, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2c85b991-6ca2-491f-936e-407ab7962343', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4e46b220-d395-459b-8601-43cc2b01107e', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 393.03, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b829fdc6-8a17-474d-81ed-3c0ff01bc3e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Lara - Parcela 1/3', 393.03, 'expense', 'paid', '2026-05-08', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 3, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fd41a4d6-995d-4d35-8ba2-c7c5a641dca0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Tikpag Meios*Tikpag - Parcela 1/3', 370.5, '2026-05-09', 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6222e29a-fe57-4ebe-9ce4-ec8fb3d6ff6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fd41a4d6-995d-4d35-8ba2-c7c5a641dca0', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 370.5, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('705b2cba-6b61-4a45-93da-291a64a73492', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Tikpag Meios*Tikpag - Parcela 1/3', 370.5, 'expense', 'paid', '2026-05-09', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('01304bf3-481d-4788-a93a-404ff5390b2c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 66.0, '2026-05-09', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aa1260d3-d0ab-404a-8717-9d117001ffd3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '01304bf3-481d-4788-a93a-404ff5390b2c', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 66.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('330b0036-d2c6-41cc-9fd5-8d34e78aeda8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 66.0, 'expense', 'paid', '2026-05-09', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a01523ba-405a-42a0-ba1c-70695e88e89b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 214.75, '2026-05-09', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f38819f9-db57-4341-bede-56a5cd675345', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a01523ba-405a-42a0-ba1c-70695e88e89b', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 214.75, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d0a4af31-3d4a-46c2-8ec5-03fde8d29403', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Fatecie', 214.75, 'expense', 'paid', '2026-05-09', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5022c483-1646-4845-8ee8-c45b6af376a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial - Parcela 1/2', 108.4, '2026-05-11', 2, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('47a561f8-e0a5-4589-9aed-1007b0b368bb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5022c483-1646-4845-8ee8-c45b6af376a2', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 108.4, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5939a5ab-9c35-488f-b316-791cd6467fa4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial - Parcela 1/2', 108.4, 'expense', 'paid', '2026-05-11', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 2, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a26c428b-1e08-4783-9fea-9e1734d4bf45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial', 49.79, '2026-05-11', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('58f65b01-2d7f-4ddc-bd13-407574501e10', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a26c428b-1e08-4783-9fea-9e1734d4bf45', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 49.79, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c355e0dd-84c6-4e11-a8fd-9926e7d5a379', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial', 49.79, 'expense', 'paid', '2026-05-11', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c043edc3-a1d2-4e7b-a14e-67e22ae2330c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '00000004', 69.9, '2026-05-13', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('55d26859-c2e7-42d0-ba5c-189a549b61ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c043edc3-a1d2-4e7b-a14e-67e22ae2330c', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 69.9, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f2528c09-0bae-4053-982b-ea3ba8535245', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '00000004', 69.9, 'expense', 'paid', '2026-05-13', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a2a1459a-ed68-4ab5-86dc-6bbc89f7f75e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, '2026-05-14', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c63943a3-eb06-463d-82e7-c57d57ee27f4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a2a1459a-ed68-4ab5-86dc-6bbc89f7f75e', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 13.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aa8d891d-ed8c-4d5f-bc86-431b05ef3182', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, 'expense', 'paid', '2026-05-14', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fee66356-1ff8-455a-b260-51bf4fd898c6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 12.5, '2026-05-17', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5f7a207c-5ecd-4a8b-bf53-a660bc7e53d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'fee66356-1ff8-455a-b260-51bf4fd898c6', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 12.5, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('29452187-5637-41bf-b232-c3d770496f51', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '60628267', 12.5, 'expense', 'paid', '2026-05-17', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9f8e5bda-23d2-415e-9955-e505ccb64525', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'R$ 44,23 de juros) divididos em 2 parcelas de', 109.46, '2026-05-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7290bf9f-9427-48b3-a83f-96f487fb1820', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '9f8e5bda-23d2-415e-9955-e505ccb64525', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 109.46, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('556f6576-6957-4f4e-b073-e2e3b14c2ddc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'R$ 44,23 de juros) divididos em 2 parcelas de', 109.46, 'expense', 'paid', '2026-05-04', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6819d9b3-cbd8-4dfb-aa79-1fd5bf8ade0f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Flavia Elena Rodrigues Ribeiro', 226.16, '2026-05-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4d1ef216-3c06-420d-8697-ec60900a7d2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6819d9b3-cbd8-4dfb-aa79-1fd5bf8ade0f', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 226.16, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2b300d98-b89c-44d5-945e-7ed5b5981a0b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Pix/Boleto no Crédito: Flavia Elena Rodrigues Ribeiro', 226.16, 'expense', 'paid', '2026-05-11', '2026-06-11', '2026-06-11', '2e7515bf-c32d-4a79-8d1d-5ed774f46e2a', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-07 (Nubank_2026-07-11.pdf) - R$ 3013.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('6e04d3cf-d32b-41b4-b842-6720bf0fd727', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 7, 2026, '2026-07-04', '2026-07-13', 3013.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('80c685cb-e352-42e1-b0c4-ebb2081d3dda', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Raparts - Parcela 2/3', 103.33, '2026-06-04', 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39789e41-fe36-483c-b433-e815c97fe6ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '80c685cb-e352-42e1-b0c4-ebb2081d3dda', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 103.33, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7bea508b-04fd-4fc8-9f1d-91f8d14ba1b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Raparts - Parcela 2/3', 103.33, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7195a12b-bc10-4e4c-acc3-28719646df73', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Antecipada - Mercadolivre*Raparts - Parcela 3/3', 103.33, '2026-06-04', 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e79e1d9-4a38-4281-9b2a-1f2050faa655', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7195a12b-bc10-4e4c-acc3-28719646df73', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 103.33, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ae5187ec-48d4-4b20-aad9-54593e046e01', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Antecipada - Mercadolivre*Raparts - Parcela 3/3', 103.33, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a46ddb7d-4a44-4ec4-b3f5-627fc55422ae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Desconto Antecipação Mercadolivre*Raparts', 0.86, '2026-06-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('84136468-659f-41c2-8713-65fda0800fd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a46ddb7d-4a44-4ec4-b3f5-627fc55422ae', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, -0.86, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b67a3369-6021-4763-bcb5-64b61f5fcedf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Desconto Antecipação Mercadolivre*Raparts', 0.86, 'income', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cbad23d8-a255-43f6-a698-f9d90e181968', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 3/3', 146.41, '2026-06-04', 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('864c9a25-37fa-49d4-a8a9-f3e9624bb512', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'cbad23d8-a255-43f6-a698-f9d90e181968', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 146.41, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('572b0979-d93f-4c07-b2a7-07f349f846c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 3/3', 146.41, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 3, 'Cartão Nubank PJ (Final 4632) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('97acc77b-b266-4dcc-8f91-f5230380e8be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Desconto Antecipação Zp*Ltda', 6.22, '2026-06-04', 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a1ad996f-c976-4e08-8db7-e245e41dea93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '97acc77b-b266-4dcc-8f91-f5230380e8be', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, -6.22, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f61c0983-ab70-4b3c-840b-d53f11df1e60', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Desconto Antecipação Zp*Ltda', 6.22, 'income', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b73002cd-dafc-4e98-bc3f-cc0cea11b568', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 4/6', 125.0, '2026-06-04', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('02eb2f97-58c4-48d7-bb92-daf6b03d2801', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b73002cd-dafc-4e98-bc3f-cc0cea11b568', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 4, 125.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a30295e-4d2e-49b6-b02e-c22144fd8998', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 4/6', 125.0, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 4, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e07aa36a-19c7-45ca-901f-7b8d93518d2c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Lara - Parcela 2/3', 393.03, '2026-06-04', 3, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('52c411c4-c6bc-4bf5-b502-d2d80957c31a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e07aa36a-19c7-45ca-901f-7b8d93518d2c', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 393.03, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1cbc8c67-fee1-498c-83af-b09f0659bc89', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Lara - Parcela 2/3', 393.03, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 3, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7f4f0c73-9a69-47c2-a21f-a684c6d5427c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 6/6', 125.0, '2026-06-04', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ba9fbdb3-6bda-4094-9054-0aa0b667a22c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '7f4f0c73-9a69-47c2-a21f-a684c6d5427c', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 6, 125.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e31d87f1-cf0f-4381-bb8e-e474355026ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 6/6', 125.0, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 6, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('017dc723-03b4-46d1-8bc7-bd82c6fbea32', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 4/4', 161.65, '2026-06-04', 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f195a868-2786-4cbc-ade5-958bcfa19c45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '017dc723-03b4-46d1-8bc7-bd82c6fbea32', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 4, 161.65, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1389c4d8-7020-4875-8bb9-de521909de3e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Mercadolivre*Mercadol - Parcela 4/4', 161.65, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 4, 4, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8a37d7ba-40c1-4a04-a394-5a19800515cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 5/6', 125.0, '2026-06-04', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0f20061d-54a0-46e7-8255-da75180c2563', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '8a37d7ba-40c1-4a04-a394-5a19800515cd', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 5, 125.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a76ea64-5c24-4695-8ae8-b25aa0c888ae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Antecipada - Zp*Ltda - Parcela 5/6', 125.0, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 5, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('60c95dfb-73e0-445f-8a57-06ab262d8467', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 3/6', 125.0, '2026-06-04', 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7cf94fd6-e28f-4302-83cb-26d3dec75bc6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '60c95dfb-73e0-445f-8a57-06ab262d8467', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 125.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5e39a924-7547-4a32-9857-112f130f38b8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Zp*Ltda - Parcela 3/6', 125.0, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 3, 6, 'Cartão Nubank PJ (Final 3197) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b4b7e6a2-a11f-454e-9bec-91da081c51f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial - Parcela 2/2', 108.4, '2026-06-04', 2, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ab805cb7-201d-4c1e-afce-d3c5d62cac12', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b4b7e6a2-a11f-454e-9bec-91da081c51f0', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 108.4, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a84fbf3-2bdf-4485-a477-0e67551d2a52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Bmb *Equatorial - Parcela 2/2', 108.4, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 2, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1d418089-40b9-4a79-8f06-e5acda8e4fcf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 53.9, '2026-06-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0c1b869c-03b5-4a50-8393-4a85af901379', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1d418089-40b9-4a79-8f06-e5acda8e4fcf', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 53.9, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fd9b6cb5-4570-45cb-bf40-b2d03eac39cf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Burger King', 53.9, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e2540201-1fac-440e-88eb-5356ac340332', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Farmacias', 64.29, '2026-06-04', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e27862f3-12f4-4ce7-8474-72e630fd16b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e2540201-1fac-440e-88eb-5356ac340332', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 64.29, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dec08afa-8f9e-4688-8787-2f12718c9f02', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '334d3509-9536-47f2-8367-4521038b454d', 'Panvel Farmacias', 64.29, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c75e9718-3160-4ed4-a4f4-8c698528efd8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Tikpag Meios*Tikpag - Parcela 2/3', 370.49, '2026-06-04', 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d2aa9e87-586e-4c1c-8dcc-76f3fde786cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c75e9718-3160-4ed4-a4f4-8c698528efd8', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 370.49, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5ef17912-c4a0-4fa0-bfe2-29e34a4a954b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Tikpag Meios*Tikpag - Parcela 2/3', 370.49, 'expense', 'paid', '2026-06-04', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 2, 3, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('44afc305-010d-44f8-8bf2-35c64f0c5139', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Metropolitana', 69.0, '2026-06-06', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3dc8af30-fc73-4ebb-a431-6d1aec7c360d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '44afc305-010d-44f8-8bf2-35c64f0c5139', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 69.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43397c4a-5a17-4792-9761-fe249df94f51', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Metropolitana', 69.0, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3d1c259d-2c69-44bf-8b8f-574cfd5cc3c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 69.9, '2026-06-06', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('795c4d83-b39e-4e90-b521-2f09cebd6da6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '3d1c259d-2c69-44bf-8b8f-574cfd5cc3c1', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 69.9, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cc5c20dd-2313-41d7-bc96-58e45e09ab91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 69.9, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e97d1112-a6f2-460b-ab49-74a621b6e4e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/4', 104.71, '2026-06-06', 4, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3e3a7c6f-38c4-4879-9653-bbd7b9b2c210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e97d1112-a6f2-460b-ab49-74a621b6e4e1', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 104.71, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b918c74a-eeb1-4782-af84-5425bb1e632c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/4', 104.71, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 4, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4b033758-33db-4558-82ea-0cf13382091a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Metropolitana', 69.0, '2026-06-06', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4d6d0517-9d1f-46eb-932f-285033978944', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '4b033758-33db-4558-82ea-0cf13382091a', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 69.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3fac3a73-32e2-458e-b0bd-993a216a121f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Metropolitana', 69.0, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1332bb50-f5c6-4d2a-b521-9abfd0512dc9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 71.81, '2026-06-06', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('99fb362a-4a88-42b5-8f75-9cb813be17ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1332bb50-f5c6-4d2a-b521-9abfd0512dc9', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 71.81, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6c14363a-b04a-433e-a56e-7ba7ca43daa3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 71.81, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ef17e25f-2bba-4095-8352-4694e5dca89d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/3', 130.52, '2026-06-06', 3, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e62c7fb1-e5ae-41bf-938d-0bc59eb38ffb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'ef17e25f-2bba-4095-8352-4694e5dca89d', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 130.52, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5105ea53-5c9a-4769-9bf7-0e570457f3c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/3', 130.52, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 3, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('db9dd49c-042e-48cd-a02d-58a1d05a455d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/2', 211.25, '2026-06-06', 2, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e3867900-05f6-401e-8e66-f581cdf2caee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'db9dd49c-042e-48cd-a02d-58a1d05a455d', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 211.25, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('06fd3181-0168-43f6-88fc-5e5d74efd39c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Matriculacurs - Parcela 1/2', 211.25, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 2, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('08b81115-e06d-4b0b-9600-1d4a776ff5a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/2', 197.59, '2026-06-06', 2, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('12f7ce6b-ad91-4c9f-b66c-75da90c3eb44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '08b81115-e06d-4b0b-9600-1d4a776ff5a4', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 197.59, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('552fc945-71d6-46d7-8d31-872d078ca8c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Cogniti*Acordodemensa - Parcela 1/2', 197.59, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 2, 'Cartão Nubank PJ (Final 9205) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('50fcd742-ffb4-432e-ac71-3025a9e2e87c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 61.84, '2026-06-06', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b392e2d0-ec39-4afd-b29e-722744f580c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '50fcd742-ffb4-432e-ac71-3025a9e2e87c', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 61.84, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aaeaacd7-a69e-4003-a1b4-91b5042c6230', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 61.84, 'expense', 'paid', '2026-06-06', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a1995a2d-e7b7-449f-8513-2e0f2fcdbe24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 10.25, '2026-06-08', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3445e541-c4cd-495a-ba59-796745b7eba9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'a1995a2d-e7b7-449f-8513-2e0f2fcdbe24', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 10.25, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d40b02fc-703f-40a2-a4b9-24d09f640b30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elenice Machado Marqu', 10.25, 'expense', 'paid', '2026-06-08', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b34aa55d-af13-481d-a87d-e075c3f0fde3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 15.0, '2026-06-09', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c7dd24d8-6e26-489c-975d-982c32d60ec2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'b34aa55d-af13-481d-a87d-e075c3f0fde3', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 15.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2c4b94cc-f42c-4af7-af8a-e620c630e71e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Sky Fit Pelotas', 15.0, 'expense', 'paid', '2026-06-09', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('51f5a0c7-4704-4773-b0dc-941235f26af5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 49.67, '2026-06-10', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('64b55880-4c90-4233-b903-d631ddb193af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '51f5a0c7-4704-4773-b0dc-941235f26af5', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 49.67, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('01ddc65a-fcb9-4cee-8540-26282487b857', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 49.67, 'expense', 'paid', '2026-06-10', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('81809b08-e689-44e6-9923-9efe2cd976a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 63.13, '2026-06-10', 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('385d0acb-c7d8-496d-8667-93536bf53f6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '81809b08-e689-44e6-9923-9efe2cd976a6', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 63.13, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1421e2b5-6c97-4e52-8c47-48d15eca877a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Net Pgt*Fatura Claro', 63.13, 'expense', 'paid', '2026-06-10', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 7795) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5eb434c6-0420-4978-a0fa-44e2ebba9a0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.0, '2026-06-11', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('08f618c6-93c4-4884-8624-33562d1b79d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '5eb434c6-0420-4978-a0fa-44e2ebba9a0e', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 7.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e9e85767-5381-4c6f-885a-e2ad1db789c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 7.0, 'expense', 'paid', '2026-06-11', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('870630a3-8295-4db7-ba2e-af589708c2df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elisangela', 25.0, '2026-06-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0a4c2b16-bc1c-4de8-b449-1892eb8ad207', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '870630a3-8295-4db7-ba2e-af589708c2df', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 25.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f5cab34e-798a-47f4-b684-7a8fa3229c1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Elisangela', 25.0, 'expense', 'paid', '2026-06-12', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('31669a6c-cd45-401f-aaf5-2d862d8d19f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, '2026-06-12', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d18ca65e-f338-40c5-88b2-9c80bba32cbb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '31669a6c-cd45-401f-aaf5-2d862d8d19f3', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 12.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('32cbf380-0e1a-4e27-8bec-8534f65f055d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 12.0, 'expense', 'paid', '2026-06-12', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1309f685-d92e-44e1-92d7-4f154f050a46', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Nicolas Wotter da', 17.48, '2026-06-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e30cbf09-f8e8-4b8e-a22c-298d235c467d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '1309f685-d92e-44e1-92d7-4f154f050a46', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 17.48, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44dfccdd-797c-49bf-8a36-c0fef4436fe4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*Nicolas Wotter da', 17.48, 'expense', 'paid', '2026-06-21', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('07c07864-b0d5-44fe-84c2-c2e87649bb18', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*25.030.026 Pamela', 33.97, '2026-06-21', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d378d220-badc-4a9f-aa70-7c943035f16a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '07c07864-b0d5-44fe-84c2-c2e87649bb18', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 33.97, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('205da4de-71e3-4100-a9a1-4aeb162999ec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Ifd*25.030.026 Pamela', 33.97, 'expense', 'paid', '2026-06-21', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('857ce259-47f2-4cd7-b6e4-bee4699f80d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, '2026-07-03', 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2d9a8761-983b-4621-91cb-b2267304ea88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'f8c9d0e1-2345-6789-abcd-ef0123456789', '857ce259-47f2-4cd7-b6e4-bee4699f80d2', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 13.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('49f2688c-826d-4586-9072-809ea1fb7d30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e7b8c9d0-1234-4567-89ab-cdef01234567', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008douglas', 13.0, 'expense', 'paid', '2026-07-03', '2026-07-13', '2026-07-13', '6e04d3cf-d32b-41b4-b842-6720bf0fd727', 1, 1, 'Cartão Nubank PJ (Final 3197) | [Uso Pessoal] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

COMMIT;
