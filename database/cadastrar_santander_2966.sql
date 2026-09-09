SET client_encoding = 'UTF8';
BEGIN;

-- 1. Conta Técnica do Cartão Santander SX (Final 2966)
INSERT INTO accounts (id, workspace_id, owner_id, name, type, initial_balance, active, is_system, is_shared, created_at)
VALUES ('b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Cartão Santander SX (Final 2966)', 'credit_card', 0.00, true, false, false, NOW())
ON CONFLICT (id) DO NOTHING;

-- 2. Cartão de Crédito Santander SX (Final 2966) - Limite R$ 821,00
INSERT INTO credit_cards (id, account_id, workspace_id, owner_id, name, brand, last_four, credit_limit, limit_amount, closing_day, due_day, created_at)
VALUES ('c8b7a6d5-4321-0987-fedc-b21304958675', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Santander SX (Final 2966)', 'Visa', '2966', 821.00, 821.00, 15, 22, NOW())
ON CONFLICT (id) DO UPDATE SET credit_limit = 821.00, limit_amount = 821.00, closing_day = 15, due_day = 22;

-- ===========================================================================
-- Fatura 2025-11 (Santander - 22112025.pdf) - R$ 101.46
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('7bf82162-8a2e-4b66-be9c-a9e39098d405', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 11, 2025, '2025-11-14', '2025-11-22', 101.46, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c6365b6a-abef-41a3-bcb4-8193c780c43e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'PELOTENSE GESTAO DE ESTAC', 11.0, '2025-10-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3a0851ee-069a-42bc-bfa2-d7ed129263ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c6365b6a-abef-41a3-bcb4-8193c780c43e', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 11.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9df6f48a-18ee-43b4-8d45-93e91de5769a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'PELOTENSE GESTAO DE ESTAC', 11.0, 'expense', 'paid', '2025-10-18', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('169d30bf-8d9a-4e12-9b73-3c936c21b35d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2025-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a50fec90-74cd-4ba0-9821-76c5818cc0e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '169d30bf-8d9a-4e12-9b73-3c936c21b35d', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 10, 312.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3ab1985f-7775-4f15-bdfb-f804a0b4efda', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2025-01-08', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 10, 12, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fcf6aa56-6543-4f6c-a93f-294075db9341', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 50.0, '2025-01-08', 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e804a84f-15c9-4743-949a-c25c17524c2a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fcf6aa56-6543-4f6c-a93f-294075db9341', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 10, 50.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('680403cb-0a77-444c-a2ed-03043c8b80d0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 50.0, 'expense', 'paid', '2025-01-08', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 10, 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('48827db7-a8e0-4a39-96a8-0fcd539a5925', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('20c90c00-c5cd-4ad3-a51c-c367b0c4d4a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '48827db7-a8e0-4a39-96a8-0fcd539a5925', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 6, 67.48, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21962183-b0ce-4ff6-bb2a-94892fb89461', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 6, 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e935b0c2-5e7a-4fb0-b349-ec13f8cb3b47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, '2025-06-14', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fc367804-81b3-4a3d-8f4f-afdbf0c4a74a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e935b0c2-5e7a-4fb0-b349-ec13f8cb3b47', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 5, 74.66, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1f548ec3-f2e3-40b5-b4be-63022c45beea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, 'expense', 'paid', '2025-06-14', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9e0316cc-08dc-4774-a01e-f7a4a6957ab1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, '2025-06-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('400419f8-a6ef-4997-801a-2db490c6d119', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9e0316cc-08dc-4774-a01e-f7a4a6957ab1', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 5, 60.24, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('42c515c0-51e1-4af1-83c5-3f8579f2a68d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, 'expense', 'paid', '2025-06-18', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('af1b2c12-b3f3-4113-89fb-308bbeccb540', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d321991d-126b-4fdd-9856-91f6d96f1d77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'af1b2c12-b3f3-4113-89fb-308bbeccb540', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 12.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('150fd1ab-0eee-48d8-9258-0d7c780bf21d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f0829f3-c0cc-45b5-9d5a-e6d5343cd2c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d821ca77-b4c0-40bb-a69e-bae7d8a82641', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f0829f3-c0cc-45b5-9d5a-e6d5343cd2c0', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 200.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9b015799-bd68-4e5e-a94d-b6008d1709e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e2481a35-1571-4da3-b8e7-67091388d6c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('223269b9-3859-439a-ae4d-c2798b405bd8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e2481a35-1571-4da3-b8e7-67091388d6c3', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 172.17, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('244925ef-b011-46a2-b452-cc92d5046b9e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6c7bc534-b553-4646-8443-c474afee274a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 60.45, '2025-09-17', 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('034590d4-a523-4bc0-bc50-da6ee7aee424', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6c7bc534-b553-4646-8443-c474afee274a', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 60.45, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eb5f2509-56c3-4daf-a32d-408afbd0dbd6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 60.45, 'expense', 'paid', '2025-09-17', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1084d820-1bc5-4cb0-93a8-1f9934ddbc70', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('996757fe-e059-424b-bf2e-4ad0a3e815ed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1084d820-1bc5-4cb0-93a8-1f9934ddbc70', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 74.09, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e3d78a77-878b-48bf-9cca-f8acf1055a99', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9ba43de1-8b58-4c5b-9093-5208f3aab918', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, '2025-09-20', 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('08ace5fd-3999-4857-98ce-8293c3002626', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9ba43de1-8b58-4c5b-9093-5208f3aab918', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 19.61, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f6446c94-2cf6-4884-bf08-0f60c1e7a85b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, 'expense', 'paid', '2025-09-20', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c7d13e6e-5f09-4a76-9e00-830983eefd10', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, '2025-09-27', 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e6d0da00-b911-4e61-9512-325d27e54e7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c7d13e6e-5f09-4a76-9e00-830983eefd10', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 42.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('99c34e00-c4be-4b28-a90d-97c643b0c5de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, 'expense', 'paid', '2025-09-27', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c06ce383-73c8-4795-a784-b5b13ccb1083', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5f688340-4d37-4165-bf8e-af4eeaaebcd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c06ce383-73c8-4795-a784-b5b13ccb1083', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 70.17, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5a33e456-1b4a-4721-b5dd-ae4f4d5f4b48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('78bf2ddf-1079-45be-bb6a-f1b239430e9d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*UNE SUSHI LTDA', 49.55, '2025-10-06', 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('204ebb04-6860-415c-931a-91c10b66abff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '78bf2ddf-1079-45be-bb6a-f1b239430e9d', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 49.55, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('53108c03-960b-4a26-a2e8-37ae1ee91659', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*UNE SUSHI LTDA', 49.55, 'expense', 'paid', '2025-10-06', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8d23d134-4a2c-4b46-8a7b-58478c143ba2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('858221a6-0718-448d-8c40-73649bacaa8d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8d23d134-4a2c-4b46-8a7b-58478c143ba2', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 130.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cc575e8c-31c8-401a-8ae4-e5e8ee4025b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('785ec05a-567c-4621-974a-9f63fd1b5395', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('42778e8c-6e29-4d59-a882-8f78366e5a03', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '785ec05a-567c-4621-974a-9f63fd1b5395', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 108.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('abbca8a9-3e30-40ad-88c8-2a7cf3aab581', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 5, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('53f9e914-bdf6-4fe7-b553-dc05cf392a0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 6.9, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fa6db491-b70b-4042-a2ca-e13996732d24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '53f9e914-bdf6-4fe7-b553-dc05cf392a0e', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 6.9, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3975db6e-6fcf-429d-b63c-b82466f33879', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 6.9, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1c8494de-a51c-4a23-b7d5-1bdfac9d3cb8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 12.87, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('87da016c-f48c-4e1c-97d1-9dc5415f3e2d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1c8494de-a51c-4a23-b7d5-1bdfac9d3cb8', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 12.87, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2fa885b2-2d21-438f-85fd-f4011a6aa185', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 12.87, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5f226d0e-7061-41d1-9e26-5b82be931238', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.0, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('865ff29a-179c-4db7-92b7-11c1b09ef0a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5f226d0e-7061-41d1-9e26-5b82be931238', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0d836838-291f-4f43-add9-df41a856864b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.0, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8bfd1d78-2d35-4034-b42e-dc9a7e8b9c54', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM JOAQUIM', 7.5, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('378fa98b-eae7-436a-a188-75f5e5b713cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8bfd1d78-2d35-4034-b42e-dc9a7e8b9c54', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 7.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1ccb9bac-f1f1-4541-b94a-1f6c39c399d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM JOAQUIM', 7.5, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ab97acd0-94be-46bf-8174-6c0427c7d0f9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'IG*PSICOMANAGER', 89.0, '2025-10-22', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f5fc22c1-af68-479c-b55e-40f872edfbcf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ab97acd0-94be-46bf-8174-6c0427c7d0f9', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 89.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c945d307-c9a2-4e8b-a082-222049a000fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'IG*PSICOMANAGER', 89.0, 'expense', 'paid', '2025-10-22', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d4ee5e5c-2142-444d-9b0b-eea5df2606da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 12.5, '2025-10-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3ca49035-81dc-43d6-894a-d9df469e6d27', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd4ee5e5c-2142-444d-9b0b-eea5df2606da', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 12.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eba9bdf9-7d43-4240-8577-eb36dc3f1de9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 12.5, 'expense', 'paid', '2025-10-23', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('62d99a5d-4cd9-40df-8c0d-9d0920dee9ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 148.8, '2025-10-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a60cac06-6a76-4f8f-8e20-c31a7b8482b8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '62d99a5d-4cd9-40df-8c0d-9d0920dee9ce', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 148.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('389ddd46-819f-4da9-b6ad-588ccc8c711b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 148.8, 'expense', 'paid', '2025-10-24', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e293410e-ffa9-4a87-ae50-2fe929eac7b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 30.3, '2025-10-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a4f0a116-b4d9-4349-9d45-dc7b790606a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e293410e-ffa9-4a87-ae50-2fe929eac7b5', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 30.3, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e769476e-5873-40df-96d2-01f24652c940', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 30.3, 'expense', 'paid', '2025-10-24', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('910ae7da-a9e5-4ec9-9a4c-fa6a66c35873', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 38.97, '2025-10-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('02481a67-0240-47e8-ae0f-d491a2e1412d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '910ae7da-a9e5-4ec9-9a4c-fa6a66c35873', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 38.97, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a365bf5-344f-4896-baae-3d326ae0ac02', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 38.97, 'expense', 'paid', '2025-10-27', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('14e2b562-ea78-4295-86c4-072c55cb8d3c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MADU FOODS LTDA', 55.88, '2025-10-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('06312d76-152f-4c95-befa-34b306fbbdf8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '14e2b562-ea78-4295-86c4-072c55cb8d3c', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 55.88, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('05c03a1f-2b49-4689-957f-348ada9bbd78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MADU FOODS LTDA', 55.88, 'expense', 'paid', '2025-10-27', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e4b45885-7321-4173-a176-d26d0e7dfbc9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58 067 449 ANGEL GONC', 28.88, '2025-10-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d5882eab-c560-4c07-8822-b753512ec2cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e4b45885-7321-4173-a176-d26d0e7dfbc9', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 28.88, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('120c8850-f0e0-4df4-9e5d-6c04a90dcd3c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58 067 449 ANGEL GONC', 28.88, 'expense', 'paid', '2025-10-28', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3e59436a-d056-4609-97b8-c3a854b8b42c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 26.8, '2025-10-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ffe5a176-3ead-42e1-b716-729dae882d71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3e59436a-d056-4609-97b8-c3a854b8b42c', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 26.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9e9a2068-ce52-4286-a8e9-6f486eb36be6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 26.8, 'expense', 'paid', '2025-10-31', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('23dd366b-b3dc-465e-a233-da242d07adce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 39.98, '2025-11-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dba806f3-28bf-40c6-b0ff-0a5fe8eff1cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '23dd366b-b3dc-465e-a233-da242d07adce', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 39.98, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3ebda4e1-d5dc-4d27-a05b-cbc70c5962fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 39.98, 'expense', 'paid', '2025-11-02', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b4d27c1b-5cb0-45bd-81ee-48761dd459d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*LOTUS COMERCIO DE ALI', 27.52, '2025-11-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('648cdc52-2a85-456d-9598-ab5d887f4440', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b4d27c1b-5cb0-45bd-81ee-48761dd459d8', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 27.52, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b6209218-829b-426e-872b-bbcf0b61a3af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*LOTUS COMERCIO DE ALI', 27.52, 'expense', 'paid', '2025-11-03', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d7c37fd2-87a9-46e8-98ab-c47e5352dce9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*ALTAIR SILVA SERVICOS', 28.33, '2025-11-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cc644c4b-8241-4a2f-b9e1-b1b25338f94d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd7c37fd2-87a9-46e8-98ab-c47e5352dce9', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 28.33, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a2d05e84-8561-4804-83f8-9fe409e392c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*ALTAIR SILVA SERVICOS', 28.33, 'expense', 'paid', '2025-11-04', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0022656c-4215-47cf-bfc1-ed1f3709fa63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, '2025-11-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3bddd13b-0eb1-4bfa-b735-41a252bb87a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0022656c-4215-47cf-bfc1-ed1f3709fa63', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 7.95, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('10203b72-adaa-41ee-8fee-5c2d5851320c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, 'expense', 'paid', '2025-11-12', '2025-11-22', '2025-11-22', '7bf82162-8a2e-4b66-be9c-a9e39098d405', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-12 (Santander - 22122025.pdf) - R$ 1553.42
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('f1710adc-3ec2-4477-be13-b864388dbb53', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 12, 2025, '2025-12-15', '2025-12-22', 1553.42, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d6fb3b9d-368c-4d4e-8f56-9822b52afbfe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3c00153d-dc02-4574-aa95-008a25f20420', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd6fb3b9d-368c-4d4e-8f56-9822b52afbfe', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 204.61, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('01b3e2c3-4cbc-4044-a8fc-9ad469dc7404', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 3, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2a174e8b-2905-4845-8597-1bd669a99366', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 9.57, '2025-11-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cf925f46-9b20-439b-bc35-7b05754a4db2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2a174e8b-2905-4845-8597-1bd669a99366', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 9.57, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('61d82421-b835-4122-9d3a-d33371e2591f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 9.57, 'expense', 'paid', '2025-11-27', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('63e415dc-818e-49e6-bca1-261c98e81c75', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 121.87, '2025-11-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d66ef26d-5a31-4e88-8b2c-45dfb0d7a830', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '63e415dc-818e-49e6-bca1-261c98e81c75', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 121.87, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8152a6a5-25a9-4601-8875-1cc23fa50884', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 121.87, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b51dbb99-450d-441a-9744-7f8a8504ab7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, '2025-12-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('84341f1a-251a-46ae-ad71-844d39ccdc5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b51dbb99-450d-441a-9744-7f8a8504ab7a', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 12.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('74c92612-968f-4b54-a4ce-6d109fc63c63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, 'expense', 'paid', '2025-12-03', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cca47a1e-dcf6-4002-9f7b-748f4770f836', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 4.19, '2025-12-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ff2255d4-d9f5-40ab-9248-f3ccd9602972', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cca47a1e-dcf6-4002-9f7b-748f4770f836', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 4.19, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('064ce1ba-9d84-4aed-acf0-c3753c31bf39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 4.19, 'expense', 'paid', '2025-12-03', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('74f8c3db-0bc1-4585-83af-55fe13738eea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: MP*COSTELLONE', 120.0, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4c3cd774-d0d8-4609-8862-4a2c4abc6e36', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '74f8c3db-0bc1-4585-83af-55fe13738eea', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, -120.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7f5c55d4-fc8f-4cf5-bfd8-573938c9cbce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: MP*COSTELLONE', 120.0, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9117ccc5-0759-4e9f-9bf4-503def8f4fb5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: GAU COZINHA GAUCHA', 222.0, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2316ab5d-8c59-4d86-9d2c-261e04c468f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9117ccc5-0759-4e9f-9bf4-503def8f4fb5', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, -222.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9174a5ac-2997-4385-9cdd-45f2972d1cd8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: GAU COZINHA GAUCHA', 222.0, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('092ead0e-8015-483a-bc89-6a1be67aceb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: BAGAGGIO 358 PELOTAS', 199.9, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a4920380-1d3a-45a8-b27e-86b9da337bed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '092ead0e-8015-483a-bc89-6a1be67aceb1', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, -199.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f8d07398-5ed0-48e8-9eaf-fbb6193cbd43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: BAGAGGIO 358 PELOTAS', 199.9, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('718092e9-8d94-482c-adf4-509998610d26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: FARIA GASTRONOMIA LTDA', 95.9, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('63499614-0ee3-4f22-91e0-7486cebeff50', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '718092e9-8d94-482c-adf4-509998610d26', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, -95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('410edfc4-723b-4972-8730-e4f224d2391a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: FARIA GASTRONOMIA LTDA', 95.9, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('38964630-7020-43ae-a87b-7fa77c07a9c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2025-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5c3bd267-442d-40f6-ba59-baab332605c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '38964630-7020-43ae-a87b-7fa77c07a9c8', 'f1710adc-3ec2-4477-be13-b864388dbb53', 11, 312.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('47179399-4e2d-42c8-bcf6-24c72f960a94', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2025-01-08', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 11, 12, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('55c07ee2-4db1-4ad0-ac61-8499fa317720', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ee1ff6f6-4885-4fb0-8a9b-729414350e1c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '55c07ee2-4db1-4ad0-ac61-8499fa317720', 'f1710adc-3ec2-4477-be13-b864388dbb53', 7, 67.48, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('72dde313-50bd-42ea-a702-4d557ad3c051', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 7, 10, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('52e6a61d-07b4-43df-9acc-5ae552dbf801', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, '2025-06-14', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39edb7fd-7d89-4379-b477-0abfa47d7d96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '52e6a61d-07b4-43df-9acc-5ae552dbf801', 'f1710adc-3ec2-4477-be13-b864388dbb53', 6, 74.66, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('72e42f61-cf51-4732-8312-61bdb8620229', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, 'expense', 'paid', '2025-06-14', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f4e75d48-1a18-4d12-97ae-8c357052110a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, '2025-06-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('29de85c8-186e-4dd1-b606-26fa505f829c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f4e75d48-1a18-4d12-97ae-8c357052110a', 'f1710adc-3ec2-4477-be13-b864388dbb53', 6, 60.24, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4a88cf87-8225-4a91-8db2-fb402feea756', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, 'expense', 'paid', '2025-06-18', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4c49a401-48b8-420c-87b2-ed3c6ab71567', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('25bfff93-cee5-4a52-ab3d-7ca3cabb641d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4c49a401-48b8-420c-87b2-ed3c6ab71567', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 12.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b08ad662-e464-4a73-a087-909538af4de3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('99216d61-f2c1-420c-9ce3-ea3812554187', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0992ff9e-cf9e-457a-913d-981e1737b9b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '99216d61-f2c1-420c-9ce3-ea3812554187', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 200.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2b8368b1-529d-4b5b-9eda-c2c5d255920d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0547d81d-6eaa-4a49-81ee-4dea0f9784cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bca4aad2-da64-4e87-9e6c-846b836c4225', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0547d81d-6eaa-4a49-81ee-4dea0f9784cd', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 172.17, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a5df0bd-b1b8-4bfc-807d-3f6e65bfc1f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bb140849-f745-441c-b70c-91ed024689e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c4d4bfb0-7dd4-4f14-9d69-12836839fb8b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bb140849-f745-441c-b70c-91ed024689e0', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 74.09, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b6c34305-1d4e-4d91-92f5-50d9dc802d6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('72e5a718-0a11-4093-8546-97bf82f52804', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, '2025-09-20', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1b18f0df-2754-47bf-a964-2469750ccd39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '72e5a718-0a11-4093-8546-97bf82f52804', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 19.61, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('12976f4e-be8c-47ad-b4f2-5cb1e144f28b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, 'expense', 'paid', '2025-09-20', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d6ecf2bd-cea1-4b66-b6ec-99ca2663645e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, '2025-09-27', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('508fa885-ddce-4f72-b91b-6db68ee29463', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd6ecf2bd-cea1-4b66-b6ec-99ca2663645e', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 42.8, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fc7bdb84-dc6f-483d-915c-7523447f80a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, 'expense', 'paid', '2025-09-27', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('796fc209-2e72-4314-a75f-732db5a785d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f7990ada-fe20-437a-99b5-d6a3979283a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '796fc209-2e72-4314-a75f-732db5a785d7', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 70.17, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a02079c3-f531-4a06-9495-7240252d7bd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 3, 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('656d6f1c-d457-4b01-836d-64f89fc182cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e7152199-5585-459a-8740-367928b638b3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '656d6f1c-d457-4b01-836d-64f89fc182cb', 'f1710adc-3ec2-4477-be13-b864388dbb53', 2, 130.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ee4bf982-65e0-412a-b729-e98bab2dec40', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 2, 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('97668b64-0785-46b8-8f0e-cdc89050ecff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('76693810-d117-4751-87b4-1b32dbe184f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '97668b64-0785-46b8-8f0e-cdc89050ecff', 'f1710adc-3ec2-4477-be13-b864388dbb53', 2, 108.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b72df8f7-f89c-4ec4-914c-bd08f7657fa5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 2, 5, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('abc8325e-ee1c-420e-bd4b-2a311d98f1cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8e26b5f-a935-4ce0-a587-e7382cda4d78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'abc8325e-ee1c-420e-bd4b-2a311d98f1cc', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 71.87, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2a00cf22-6801-45bb-84a5-892850be17b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5bca7e65-2098-4c81-a87c-0b4b91f0804c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5543be41-e14e-43cd-8e5e-1cfc2cf5dd49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5bca7e65-2098-4c81-a87c-0b4b91f0804c', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 116.88, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('71b3383c-d8c8-497a-a439-8b5baa1d8f9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac8de4dd-751f-4ce5-83fb-1d174eddf7b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8d43f66-a9d0-42fa-971e-e1b04a8c4ec6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ac8de4dd-751f-4ce5-83fb-1d174eddf7b4', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 50.49, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('051f37e9-1e2f-45f7-bf8c-2611d03c8215', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5085725c-14b3-4182-991b-ccbc51a16618', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, '2025-11-30', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d7c4c0b8-b02b-4325-8915-d239886ecb40', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5085725c-14b3-4182-991b-ccbc51a16618', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 63.18, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2843cf0e-1461-49a8-b2b5-b56abba2bc60', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2036e173-b3d0-4a47-a885-efc5fc7bbee8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CIRCULUS LANCHES', 38.9, '2025-11-13', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6798f6a5-6831-4d37-937f-5c32c59d73db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2036e173-b3d0-4a47-a885-efc5fc7bbee8', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 38.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7f6531c3-6f8b-433b-9337-ad9342faf64d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CIRCULUS LANCHES', 38.9, 'expense', 'paid', '2025-11-13', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e30a2e47-11cc-4473-a250-fd58c9da2009', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, '2025-11-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('369cefb4-376e-4037-8cb6-1b85749ec4e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e30a2e47-11cc-4473-a250-fd58c9da2009', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 5.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('24d8506b-79a0-4ac5-bd21-3b1b98c48728', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, 'expense', 'paid', '2025-11-14', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('46fb7294-11a3-4be6-b876-a8650bb6df5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*VINICIUS AFFONSO FARI', 27.98, '2025-11-16', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('078473d6-683b-428d-bab1-55eccb609457', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '46fb7294-11a3-4be6-b876-a8650bb6df5c', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 27.98, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('937693fd-5b2e-442c-8f69-3a5bd230b500', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*VINICIUS AFFONSO FARI', 27.98, 'expense', 'paid', '2025-11-16', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('59727f8f-cc63-4ad3-9456-e3a6009cc53b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2025-11-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0c8f6ea4-90bb-48c1-90d0-4851918dd9c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '59727f8f-cc63-4ad3-9456-e3a6009cc53b', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('da441da8-d360-474d-b033-2d33adb9e6e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2025-11-22', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3e7b11fe-3132-49a8-8798-22dcd994f3bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MICHELE CESAR RODRIGU', 66.29, '2025-11-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ef7fa867-aabd-4f64-9230-8b84df4a2555', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3e7b11fe-3132-49a8-8798-22dcd994f3bd', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 66.29, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4448f14e-24ea-4d2d-ad1a-f71a73a81429', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MICHELE CESAR RODRIGU', 66.29, 'expense', 'paid', '2025-11-22', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('45471f54-0d1c-4732-b0f4-8382bf1ca35f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAAP, MARTINS E CIA RE', 16.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8f02f502-ddc3-4d61-a987-9e0d5e172182', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '45471f54-0d1c-4732-b0f4-8382bf1ca35f', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 16.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1d24c88d-c0fb-4c62-a8c8-3236dabf45f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAAP, MARTINS E CIA RE', 16.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('69b2a8e0-9124-4ed1-b855-b79576cd590f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LOJAS AMERICANAS 427', 95.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2b9be0b9-f2d8-4327-9c46-9bce9e81e813', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '69b2a8e0-9124-4ed1-b855-b79576cd590f', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bfc3ab2e-dd1f-4b6e-96c0-b305f81cd205', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LOJAS AMERICANAS 427', 95.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('28ae8af0-5114-402e-b4bd-2f56fa3e7a27', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 199.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('16765fba-bc4e-4555-8945-dbd65e82d70f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '28ae8af0-5114-402e-b4bd-2f56fa3e7a27', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 199.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fc3f021a-a87a-42b2-b5a0-546309f2de99', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 199.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ab353a1f-332a-498a-88e3-0e46dfd89f90', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FILIAL 321', 30.0, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('080b2542-2aa8-44f6-9d10-a7577aaa116d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ab353a1f-332a-498a-88e3-0e46dfd89f90', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2c80ecc9-8256-4585-b537-5165ee09af96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FILIAL 321', 30.0, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a16e2d12-7c09-4a93-9591-274541184769', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 11.52, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fb0249fb-bf0e-468b-be9a-853391204c5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a16e2d12-7c09-4a93-9591-274541184769', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 11.52, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b1d16d25-9eb3-4a77-93da-09103ea0e26e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 11.52, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a370b628-998c-4358-a527-121deaad374f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ea3f10f3-0077-4645-ab26-219b7f2362fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a370b628-998c-4358-a527-121deaad374f', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6759e9d3-402d-41f8-8e0a-02f4430e0abb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('104c6230-126a-4e6c-82f1-5e4e5992c2ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PASTELARIAPONTAL', 39.0, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0b6a8797-ffee-4714-adf1-238447e82e8b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '104c6230-126a-4e6c-82f1-5e4e5992c2ee', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 39.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d2aaa7d9-cf3e-4303-8b85-c02e1d73763c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PASTELARIAPONTAL', 39.0, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('68500808-71cc-4510-a6c6-35e9b0fb19c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'UBER * PENDING', 13.15, '2025-11-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fbde6109-2be8-48c3-8bf5-5254ac42e1ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '68500808-71cc-4510-a6c6-35e9b0fb19c0', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 13.15, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62386f63-2261-4019-b0e1-4fa23e68a2e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'UBER * PENDING', 13.15, 'expense', 'paid', '2025-11-25', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('58bafea3-113a-4ed6-ba47-e339e1f39b26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'SEM PARAR', 30.0, '2025-11-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cf0c6aeb-b132-4418-850d-f139d06eb0cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '58bafea3-113a-4ed6-ba47-e339e1f39b26', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b4d9769d-a611-4392-aefc-d369ca0e044b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'SEM PARAR', 30.0, 'expense', 'paid', '2025-11-25', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8b58d9d1-2b08-41f4-b1c5-66e7a8b4120d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 91.0, '2025-11-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7e7fb1fb-ad0e-4d3b-9e24-88649e2e4fd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8b58d9d1-2b08-41f4-b1c5-66e7a8b4120d', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 91.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('baf36113-6c88-4626-9f33-1abf9bed9065', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 91.0, 'expense', 'paid', '2025-11-26', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac47ce0a-e556-4dbf-a49c-6f3f7c6ad265', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2025-11-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f96adab4-0cc7-4d9e-bba3-f27e0270d327', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ac47ce0a-e556-4dbf-a49c-6f3f7c6ad265', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 10.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('936192a4-8f41-4f5e-b2c2-651e2227f8b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2025-11-26', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0320afd4-de61-43f3-a6e2-9a61ff6be1e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'VIA MAIS REDE DE POSTO', 10.98, '2025-11-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('84384b0f-3508-4920-8bf9-ec3cba27496b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0320afd4-de61-43f3-a6e2-9a61ff6be1e4', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 10.98, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('984551b5-5ae3-4198-8cb9-aa34094d9eb7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'VIA MAIS REDE DE POSTO', 10.98, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8cf2bf4d-9c10-4d14-a6e9-d4584761ca94', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SCHIMITZ RESTAURANTE', 58.0, '2025-11-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('abf9fbc7-ec84-4632-bb41-6926616c07f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8cf2bf4d-9c10-4d14-a6e9-d4584761ca94', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 58.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a878c72-c7f7-4d2c-bc2b-de0b279ec337', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SCHIMITZ RESTAURANTE', 58.0, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('976ac663-b641-413d-b682-306785f63559', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 222.0, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7c4fdecc-3da4-4603-94ea-87303d08ee6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '976ac663-b641-413d-b682-306785f63559', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 222.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('70ab7b36-9ba1-405b-bbd7-10113f4b5162', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 222.0, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('332c3466-d229-4935-ac1b-81a72b8e3bc3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CACAU SERVICOS DE GAST', 69.16, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e2a1575c-bb43-47ee-b6d5-0bd1650299a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '332c3466-d229-4935-ac1b-81a72b8e3bc3', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 69.16, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('afc2f874-9ca4-48fd-a596-498146e4f360', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CACAU SERVICOS DE GAST', 69.16, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f808f79e-d034-4aa1-bfc9-295d6220da95', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LA FAMILLE DE GAZON', 32.0, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('49a96d5c-cde2-429e-8e4e-5468b650bdcd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f808f79e-d034-4aa1-bfc9-295d6220da95', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 32.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e3f88782-396f-465f-aac5-511d2c999358', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LA FAMILLE DE GAZON', 32.0, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('af5fd92b-3980-4107-be74-eaae151353d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 95.9, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d243718d-9658-40ba-9c4f-9edfb6fe2264', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'af5fd92b-3980-4107-be74-eaae151353d4', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d34fc263-7e32-4d43-a3aa-181e44117fb2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 95.9, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bc4875ba-9159-4b53-acca-e189b0dcf932', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SEVERO GARAGE', 50.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c20e339d-c2d3-4ec1-981a-062508282fed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bc4875ba-9159-4b53-acca-e189b0dcf932', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f9a17405-4cdf-40ea-b306-d6a02f034d78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SEVERO GARAGE', 50.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a8c8bca8-3726-485e-af59-96bd33e166c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 50.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4d1f9675-1127-4d13-87b8-d4b88aaa080e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a8c8bca8-3726-485e-af59-96bd33e166c2', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a8e19954-dc1b-4965-9aa3-cf790903a893', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 50.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('24cd1380-1b18-403d-9bc8-1203956abbb3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 120.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dd16e1d4-edbb-4ecd-9124-bf304f94bcd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '24cd1380-1b18-403d-9bc8-1203956abbb3', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 120.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ecf7db5b-2181-4472-9971-12f415dd7dc0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 120.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6cd30c0c-77ec-421b-ad57-35b399d5cc19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 30.27, '2025-12-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1e3b961b-f647-48c9-9a9b-165b40dfcca3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6cd30c0c-77ec-421b-ad57-35b399d5cc19', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 30.27, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9379d978-e68e-4817-b595-9b1ad47ceea6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 30.27, 'expense', 'paid', '2025-12-01', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ea43d390-a5e3-45cf-b5bf-b260dc111095', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, '2025-12-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('335aa1c4-faed-4327-b81c-ccb94cc9d3aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ea43d390-a5e3-45cf-b5bf-b260dc111095', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 9.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a7ad27b8-6052-409e-88c1-9d44b828e76b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, 'expense', 'paid', '2025-12-04', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7b060891-db6c-4879-9d8e-cfad573c12d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, '2025-12-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('142cb435-017e-4e34-affc-1eb9e7144528', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7b060891-db6c-4879-9d8e-cfad573c12d8', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 39.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bcdd41e9-a973-4981-a47e-9f69d8a453f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, 'expense', 'paid', '2025-12-05', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e62076f8-8535-4832-bae1-1335c468a5d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 29.9, '2025-12-09', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d27400e0-3ec1-4159-8450-8b48bb3bbf53', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e62076f8-8535-4832-bae1-1335c468a5d4', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 29.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4aa9260b-d501-4324-b692-8790aab03bf4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 29.9, 'expense', 'paid', '2025-12-09', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('146a6f77-a3c8-4a39-8e7a-2c4b006fd854', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, '2025-12-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('66f94e69-98f5-4730-9dae-8ce7e540f6e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '146a6f77-a3c8-4a39-8e7a-2c4b006fd854', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 7.95, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('818c2f0d-a9c1-484a-a408-7c005358418b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, 'expense', 'paid', '2025-12-12', '2025-12-22', '2025-12-22', 'f1710adc-3ec2-4477-be13-b864388dbb53', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-03 (Santander -  22032026.pdf) - R$ 1832.63
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 3, 2026, '2026-03-16', '2026-03-22', 1832.63, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8b45ebdb-f7c5-4a91-8545-3cc05edf9cda', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('32f158ae-9cb4-4125-b416-f42ca04ee4d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8b45ebdb-f7c5-4a91-8545-3cc05edf9cda', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 326.43, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6ac90274-137e-4568-816e-d506e754ba76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 5, 'Cartão Santander SX (Final 2966) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6e16c978-0512-4b5c-8733-08045cf2221f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f7401cae-19e4-49cc-b5a3-55db46e0c173', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e16c978-0512-4b5c-8733-08045cf2221f', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 2, 120.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c1c9f0c2-b653-41ba-b6b3-853356288c7c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 2, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fd990d31-2e97-494f-9c75-0c34362aaf9a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.34, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8bf15208-4f2e-44b2-ae94-1fe80a01e8fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fd990d31-2e97-494f-9c75-0c34362aaf9a', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 233.34, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8182e33d-63ab-4d62-9714-6c76371f1bb9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.34, 'expense', 'paid', '2026-02-11', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a8537e5e-fcc3-4303-900c-1537c2901d71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: SHOPEE *RSAUTOPECAS', 0.04, '2026-01-13', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4cfd655d-29c9-487d-8d49-cf5473b27cea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a8537e5e-fcc3-4303-900c-1537c2901d71', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, -0.04, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5501e85d-1f9b-4b58-9d26-9d1503945bfe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: SHOPEE *RSAUTOPECAS', 0.04, 'income', 'paid', '2026-01-13', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('25184f49-8bc7-4745-a4c5-b3d0c99ed2d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f58a70dd-cf2f-475d-a699-5f16f8bcec84', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '25184f49-8bc7-4745-a4c5-b3d0c99ed2d3', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 10, 67.48, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2c0aeb55-eeef-48d6-a54c-a89aac5f5db4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 10, 10, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('06dc96a1-8b73-4c7f-9ba4-28f8bab32062', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7fb1819a-3f42-425c-978f-8a46816707bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '06dc96a1-8b73-4c7f-9ba4-28f8bab32062', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 6, 74.09, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0342f1e6-0235-435b-8760-29a1a7db7517', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('32c65192-2366-4e07-8417-6a853cd9eabc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2c1da3b7-e947-4797-a224-b0eccc2c4675', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '32c65192-2366-4e07-8417-6a853cd9eabc', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 5, 108.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9afad9ec-0d56-43e5-92a1-622ae3fc533a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 5, 5, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0dcccc60-0661-4e11-a993-df6e641eb0fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ff843bbd-7e05-4f7d-a23c-63c9cb230be7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0dcccc60-0661-4e11-a993-df6e641eb0fd', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 42.48, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6bfe5093-0aa4-404d-8237-7a4c4dc13999', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba2d8c02-923b-4074-948e-9ab7f830eea0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a31062c4-f9f1-490a-a71b-3db7be44be52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ba2d8c02-923b-4074-948e-9ab7f830eea0', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 42.19, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e61af482-e472-46fc-81b4-4f8e675f35ae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3dabcba2-db4a-4fa8-9dec-f912f118e464', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('47f12e92-0327-4783-95a0-82317606cf0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3dabcba2-db4a-4fa8-9dec-f912f118e464', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 32.43, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('09b979fe-4378-422d-bda0-eb3cf3a16431', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fc15bf31-3802-411d-a443-0dc8b75e529c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d7d28d88-0eef-4583-8b58-61bf0ea1e988', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fc15bf31-3802-411d-a443-0dc8b75e529c', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 59.02, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('59fc6979-0742-4d28-aac4-7140a6acebf6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e146113b-1d86-478d-8bf7-f5e10ba651be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('97570761-ae45-4094-af60-b8d7eead6601', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e146113b-1d86-478d-8bf7-f5e10ba651be', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 31.08, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fd7d8c52-a1b3-434e-8004-ebc68ee6b14f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4bf47bb7-f2fe-4bf0-984d-630ebf3b042f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4bff78b9-630c-4b56-88cb-9a6c14c02dde', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4bf47bb7-f2fe-4bf0-984d-630ebf3b042f', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 71.77, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c0bbb663-5db2-4d4f-8321-7969279c47f4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5cec83de-4286-4c02-9e75-8818e9147605', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('80d43b57-439d-4e3f-941d-4feee3fe5b20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5cec83de-4286-4c02-9e75-8818e9147605', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 82.2, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('90b366ba-2892-42bb-93d3-e3362b08f615', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 3, 12, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4eb67b21-6010-456c-9cfa-9ba8a7f8d1ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.28, '2026-02-21', 2, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('43cdb13f-b2f1-4d06-8bda-d7153cfa9d49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4eb67b21-6010-456c-9cfa-9ba8a7f8d1ea', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 42.28, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c2ba305a-1af4-4d1c-812d-38913add1d92', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.28, 'expense', 'paid', '2026-02-21', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f5acc493-48b1-4d7d-8497-be77c930a4c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-02-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e2458bcc-a581-4b62-b1e0-98598bc2bf4f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f5acc493-48b1-4d7d-8497-be77c930a4c7', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 7.95, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('027c7256-42cf-4618-8524-a102a5e9cd36', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-02-12', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6099de37-4e82-499d-b4c9-df062574f298', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLECOMBILL', 5.9, '2026-02-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1718388e-ee35-49fe-b56e-281841a85b09', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6099de37-4e82-499d-b4c9-df062574f298', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 5.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d2950e38-06da-4d54-9740-7ea8fb139dc8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLECOMBILL', 5.9, 'expense', 'paid', '2026-02-20', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('da559c57-899d-45d9-85ea-c84b6b49044e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-02-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('80acb709-7635-4ac4-8f5f-1e4a1d530be0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'da559c57-899d-45d9-85ea-c84b6b49044e', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 129.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0eea6cbd-cd50-4a8b-ac86-095a9587fcf2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-02-21', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a6c18d5a-6827-4d9b-9d16-026aa89a204a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bb65892b-5de7-42fd-abea-3705612aa04f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a6c18d5a-6827-4d9b-9d16-026aa89a204a', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 30.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6835ac6-dbf0-48d4-bfb5-83a0fcfdcd99', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e9ae90ec-ed5e-4c28-92bf-6f8cb3381533', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 73.0, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('003d9ecf-c529-40d8-819f-5ba69574ee3f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e9ae90ec-ed5e-4c28-92bf-6f8cb3381533', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 73.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('921e1b00-5ffb-42b5-b8b8-b789c27bc027', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 73.0, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('323f2326-aab5-4202-95df-5cb8d755b09c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*61 756 681 GILNEI NUN', 21.98, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('914cef84-fde7-4151-9855-c6681b23185c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '323f2326-aab5-4202-95df-5cb8d755b09c', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 21.98, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0605c93c-da8d-4406-9d6e-4290eea6448c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*61 756 681 GILNEI NUN', 21.98, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e9984bf2-4469-40fc-83e9-ec24806ebf19', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 12.0, '2026-02-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('98d5fc11-91cd-484f-b052-5faa6cc19d93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e9984bf2-4469-40fc-83e9-ec24806ebf19', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1a643793-afea-47d5-bfef-8268a446f323', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 12.0, 'expense', 'paid', '2026-02-24', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b9f9972d-69f5-4116-9d29-e24bd4f6681c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 27.99, '2026-02-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('61f53c5b-c010-45b1-bd88-8139c1a2e975', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b9f9972d-69f5-4116-9d29-e24bd4f6681c', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 27.99, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('edbfcb4f-2d13-493c-91a6-448747557dff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 27.99, 'expense', 'paid', '2026-02-24', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('20c2eee8-4be2-40e3-b760-8e6e26f7c038', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'A POPULAR PADARIA', 11.8, '2026-02-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7c1325a5-3085-4fb6-985a-bf4d36b4708b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '20c2eee8-4be2-40e3-b760-8e6e26f7c038', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 11.8, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('36306e47-6528-4540-a83a-37530f8a9507', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'A POPULAR PADARIA', 11.8, 'expense', 'paid', '2026-02-25', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('30eda69d-aa2f-42ca-85a4-308116d4afd9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'FARMACIA SAO JOAO', 16.9, '2026-02-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('465710a1-716e-411e-9f68-a02463005e88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '30eda69d-aa2f-42ca-85a4-308116d4afd9', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 16.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('59f450f9-d22d-4a97-81db-1dc8d22adcc7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'FARMACIA SAO JOAO', 16.9, 'expense', 'paid', '2026-02-27', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bfdbc235-d09f-4453-8f77-974e4f451712', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JVBEBIDASE', 21.98, '2026-02-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4dfdb482-c6c1-4223-8af5-a1a95e3e15d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bfdbc235-d09f-4453-8f77-974e4f451712', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 21.98, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('843621ba-c850-4431-971d-850be12b8212', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JVBEBIDASE', 21.98, 'expense', 'paid', '2026-02-27', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dbe54e95-7570-4fdb-8c63-2256e74d5864', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 18.35, '2026-02-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a911022a-09f3-4e24-b73c-85add0a910de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dbe54e95-7570-4fdb-8c63-2256e74d5864', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 18.35, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aa682bfb-26f9-4be9-a2dd-7ddaa5eb287c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 18.35, 'expense', 'paid', '2026-02-28', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6202778a-677f-44ab-ad0f-e65b038500d6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 29.8, '2026-03-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9481e430-9ec5-4b11-b88f-d64f2cfa4353', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6202778a-677f-44ab-ad0f-e65b038500d6', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 29.8, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('99178cf5-9057-4481-8ea3-97c61505f7f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 29.8, 'expense', 'paid', '2026-03-01', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0af302a8-b172-4560-9aa7-a19909f4e48f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.64, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1cb58f4a-1c9e-4dbb-a668-87b0e0383f31', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0af302a8-b172-4560-9aa7-a19909f4e48f', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 17.64, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f9927128-15c0-4651-99a7-db5d80c631f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.64, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('96f21c3c-1d54-4395-8cdb-a64bff547d83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('24cc0d6c-54ed-43c8-99c9-a7fd54d1256b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '96f21c3c-1d54-4395-8cdb-a64bff547d83', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cd3d6518-4eab-47e9-bfe5-f8731f537176', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fc66f42d-bfda-40e2-b1a8-47ad8626b10c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c7b84b94-50bc-420b-82a3-d6bac1fa9c57', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fc66f42d-bfda-40e2-b1a8-47ad8626b10c', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 30.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1440305f-668f-44f8-8310-5f387f36d159', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('310efabf-5299-4f58-8390-cc2d53295ebd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 4.49, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5e4265df-4298-47d4-81db-bb2c5d7e621a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '310efabf-5299-4f58-8390-cc2d53295ebd', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 4.49, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d82dec21-7ddd-4dfd-9618-eee450c29644', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 4.49, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5a871cd0-ce58-4bb1-9ac0-f6d566074b20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.21, '2026-03-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('074b6529-d6b0-4673-9cb2-aec7be9b7348', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5a871cd0-ce58-4bb1-9ac0-f6d566074b20', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 8.21, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e4262b59-0c09-4e40-b6ef-fa6bfd9e41c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.21, 'expense', 'paid', '2026-03-03', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('39b1764c-dc87-418a-b6c7-8212a5aa53c6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, '2026-03-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('603ff59d-a9ca-4a8f-a1f0-6cb84fb895b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '39b1764c-dc87-418a-b6c7-8212a5aa53c6', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2eb56460-e3d7-4563-b27f-817570638134', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, 'expense', 'paid', '2026-03-03', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('26237bcd-e978-463c-9ab8-5bc59416fccc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-03-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('49acf083-dffb-4639-bb68-dfe9b6057471', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '26237bcd-e978-463c-9ab8-5bc59416fccc', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 7.95, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bc554560-c5ce-41d3-a2ee-18cbc41517bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-03-12', '2026-03-22', '2026-03-22', '85c228a2-ce77-4f2d-8f7b-bab40d663a4e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-04 (Santander -  22042026.pdf) - R$ 1722.04
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('80ad1a06-b821-4ae7-8768-657235fd1ed8', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 4, 2026, '2026-04-14', '2026-04-22', 1722.04, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0e7c049a-9316-4348-967d-dbad63ff0518', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bc4d520d-922f-49f4-9921-0c6caa13fbc2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0e7c049a-9316-4348-967d-dbad63ff0518', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 4, 326.43, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('77716415-e0b4-4b1f-bd3a-872306bf9e43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 4, 5, 'Cartão Santander SX (Final 2966) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b767d435-ff1e-4934-a3c4-8b9c83e36079', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d76613eb-51c3-48ec-83ff-ca9a5f422187', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b767d435-ff1e-4934-a3c4-8b9c83e36079', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 3, 120.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1f2529f4-5310-464d-93ec-78d8d946169b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 3, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1e2c22e0-180e-490a-b280-9c74e1393b21', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cc980a90-612b-4fa5-bc00-80020ec6b639', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1e2c22e0-180e-490a-b280-9c74e1393b21', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 2, 233.33, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('92e2d1ee-0553-48eb-9352-a3d8e4c4d25c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, 'expense', 'paid', '2026-02-11', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5868bad4-3aaf-4916-ba1b-5e09acfdf496', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b2940b6a-0203-4f1e-90bd-01ddd448bd26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5868bad4-3aaf-4916-ba1b-5e09acfdf496', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 362.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bb6c62ae-b2c8-438f-97b3-804f3517774c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, 'expense', 'paid', '2026-03-19', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4c3d68de-311a-44eb-a949-04e64482b9df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.51, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a2db2a7a-21d1-4d5b-971d-254e54c11d5c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4c3d68de-311a-44eb-a949-04e64482b9df', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 288.51, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('98633c77-a1e4-4824-a8a4-81bba1131f3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.51, 'expense', 'paid', '2026-03-19', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('285e1634-5124-4b30-8ea6-c243b30c2ac7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('55f11229-4aac-4dc3-9bda-cfd12616cb3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '285e1634-5124-4b30-8ea6-c243b30c2ac7', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 4, 82.18, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0da5f1be-c2fb-4bc8-b0c4-3e013aa0bbca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 4, 12, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bfd6a7c5-9491-42d6-bed8-343a11d47228', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.27, '2026-02-21', 2, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1293f587-de72-4bb6-8440-9a968d83f7db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bfd6a7c5-9491-42d6-bed8-343a11d47228', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 2, 42.27, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('60e8d21e-a31c-4980-8005-157a52c33c9d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.27, 'expense', 'paid', '2026-02-21', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('283d77df-05db-4db4-8ecd-b64366c61220', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ac333e76-6e3c-4950-b7d3-228cfc5cc2a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '283d77df-05db-4db4-8ecd-b64366c61220', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 37.48, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2ae5e62a-e74e-4cc2-a039-892c9445e7e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 10, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f3dcb82c-5c71-4064-b250-d41203878cf9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-03-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('92835f6e-1f53-4487-b694-f9bc26631a09', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f3dcb82c-5c71-4064-b250-d41203878cf9', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 129.9, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('731cd3c7-8321-43fa-a471-b4b4d9b26c20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-03-21', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c1f3708e-eea0-4540-b871-a51f81ca9d53', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EBN *TIKTOK SHOP', 91.99, '2026-03-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c15e1bcd-8c51-4f70-b025-20f291e06948', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c1f3708e-eea0-4540-b871-a51f81ca9d53', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 91.99, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('acebece9-afb5-4692-8a0b-726e5a3884d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EBN *TIKTOK SHOP', 91.99, 'expense', 'paid', '2026-03-21', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('698184d8-7b2c-455f-ab37-622f971ed9f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-04-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a45b67b6-f69f-4af4-9662-0e890b4090bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '698184d8-7b2c-455f-ab37-622f971ed9f0', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 7.95, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('695ca3a8-7d8c-4c2e-bf55-37d6fdeb7051', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-04-12', '2026-04-22', '2026-04-22', '80ad1a06-b821-4ae7-8768-657235fd1ed8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-05 (Santander -  22052026.pdf) - R$ 1868.79
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('d620b940-1178-4cfc-8bd6-66dc3c9fb435', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 5, 2026, '2026-05-15', '2026-05-22', 1868.79, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5755acd2-0e83-46e5-9389-260ff748fd34', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ZP*LTDA 62157', 0.02, '2026-03-19', 1, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e95c3a8d-1b28-4719-ae8e-9b2bdd83643f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5755acd2-0e83-46e5-9389-260ff748fd34', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, -0.02, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('54b42990-455d-4a8d-b160-fe20b37f2c3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ZP*LTDA 62157', 0.02, 'income', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('13345d99-2edf-485a-8ea3-c67884a28344', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c15c3139-7d59-4ce6-8485-955ba0710f7b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '13345d99-2edf-485a-8ea3-c67884a28344', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 5, 326.43, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c8a16ea5-4588-4896-8003-473bd5b91866', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 5, 5, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7f43a18a-e5e6-458d-865b-5f2f9364d361', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('40b151d9-10c4-409f-8645-bdbb87516213', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7f43a18a-e5e6-458d-865b-5f2f9364d361', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 4, 120.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a36f63dc-c656-44cb-9c59-552a2f1aac6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 4, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a29d37d5-b64c-4800-82d4-28e9df77b59f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b8271872-881d-4465-871a-5a3accdeb2fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a29d37d5-b64c-4800-82d4-28e9df77b59f', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 3, 233.33, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e705b1a8-01db-4104-9fc6-8e18127e566d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, 'expense', 'paid', '2026-02-11', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4d949e80-acfd-4a59-9831-f4e8bdd4d611', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4bf5e976-2da3-4ac2-9a95-bf97056fc388', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4d949e80-acfd-4a59-9831-f4e8bdd4d611', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 362.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b4312cc8-529d-42dd-8803-c4ec8c6681b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, 'expense', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6b2d2b77-42f5-4e13-85e2-32c7ff97ea24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1998560e-4d55-4c17-a2e8-93be94debea6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6b2d2b77-42f5-4e13-85e2-32c7ff97ea24', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 288.5, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cc8efd1c-3f81-45b4-a8c9-7c18d563d2f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, 'expense', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('216874a7-0fcc-4233-a479-3215d7f05b73', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 15.0, '2026-04-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8e343855-b4dd-4418-8a33-65db1c428317', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '216874a7-0fcc-4233-a479-3215d7f05b73', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 15.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('13611e10-440e-4022-bce7-6fa24f9febd9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 15.0, 'expense', 'paid', '2026-04-28', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('74423a1d-61dd-4645-ad61-a2552c28db22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('503b18c3-05ff-475c-aa25-c812edbba5bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '74423a1d-61dd-4645-ad61-a2552c28db22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 5, 82.18, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ddccc791-bd26-4517-8118-74b24251a889', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 5, 12, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('531d8093-c562-48b9-b1e6-4197ed220dd9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('afa427d8-bcf6-4cd1-b202-bdc230d4a1b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '531d8093-c562-48b9-b1e6-4197ed220dd9', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 37.48, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f59306a3-d1f4-49da-8bfd-0fad23b8fc3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 2, 10, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1b38e41c-0335-4df9-be53-9a0f07e1b7a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, '2026-04-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9b8ae69f-cf44-4174-8506-65c5eea6c59d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1b38e41c-0335-4df9-be53-9a0f07e1b7a2', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 5.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('85ea6600-e9f7-43e1-a2d8-ba71bcfe70cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, 'expense', 'paid', '2026-04-14', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0ce0448d-ac0a-47ba-8787-fd353a496f1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-04-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ad0964f0-4658-486e-9584-cbab30ebb825', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0ce0448d-ac0a-47ba-8787-fd353a496f1d', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 129.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62106025-513f-4214-8fa3-0752bdfeff79', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-04-21', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('27f26e1c-3efd-4fad-bcc9-4b4332022225', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, '2026-04-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2b931f90-03bc-448a-9cd0-6c70d26d4e7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '27f26e1c-3efd-4fad-bcc9-4b4332022225', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 26.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e7608504-769b-49f1-8548-1321d91912e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, 'expense', 'paid', '2026-04-24', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('66a14de6-bc30-4ea9-abcd-6a7f4fffe728', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, '2026-04-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4766b7b8-57b5-4e0f-b8db-346bbb989dc4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '66a14de6-bc30-4ea9-abcd-6a7f4fffe728', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 50.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dde5e68b-9029-48ed-b768-fd792beb0b9d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, 'expense', 'paid', '2026-04-26', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b6291a77-9a45-4fd1-930b-4813b53ede7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 25.9, '2026-04-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d8151c5d-92c4-40fd-b38b-ac41de963606', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b6291a77-9a45-4fd1-930b-4813b53ede7a', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 25.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6a8554d-8788-420f-853f-393aeea89714', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 25.9, 'expense', 'paid', '2026-04-29', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('16842b17-0b20-4dcf-9ca5-9b56050bf58e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-04-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0fb7048c-b143-46cb-8eb6-91bf4aa10649', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '16842b17-0b20-4dcf-9ca5-9b56050bf58e', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 30.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6185de20-7e04-4810-852e-b6b73c6a150e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-04-30', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ad497e3c-2ac6-4145-8caa-c680a16a1208', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 7.99, '2026-05-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('83cbcdcb-2fbf-4a25-ac6c-a05f2102fe33', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ad497e3c-2ac6-4145-8caa-c680a16a1208', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 7.99, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9de64684-9162-4dd1-86c0-7fff280954ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 7.99, 'expense', 'paid', '2026-05-01', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8060b7e6-d49f-4eeb-9aa5-f7e325768f55', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 47.89, '2026-05-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dcbeb0fc-c3a9-4730-88d0-515daa552b3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8060b7e6-d49f-4eeb-9aa5-f7e325768f55', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 47.89, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4466a9a5-f9f4-4ce4-8813-c6b1d4f5bb3a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 47.89, 'expense', 'paid', '2026-05-02', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c742dbcf-8b2c-438c-ba2f-71d3d40dd9d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 11.49, '2026-05-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3baa42e2-8aae-49b1-b0ff-ab551ae88b46', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c742dbcf-8b2c-438c-ba2f-71d3d40dd9d1', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 11.49, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3ba2f0a7-2478-456f-be66-92c0e2fd838c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 11.49, 'expense', 'paid', '2026-05-02', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('20c71768-97e7-4281-8145-9ce5040c4a7d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 45.94, '2026-05-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('61839abf-722d-4582-8483-3cfc74766fce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '20c71768-97e7-4281-8145-9ce5040c4a7d', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 45.94, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d0415905-a530-4339-93af-ebb161925c96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 45.94, 'expense', 'paid', '2026-05-03', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cbd51ce3-8542-4fb1-afca-044840610bf5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIR', 21.98, '2026-05-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ba7bf61b-6d80-4548-a867-efd23361990d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cbd51ce3-8542-4fb1-afca-044840610bf5', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 21.98, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('672fd637-ee57-4797-ba70-8159a14108d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIR', 21.98, 'expense', 'paid', '2026-05-04', '2026-05-22', '2026-05-22', 'd620b940-1178-4cfc-8bd6-66dc3c9fb435', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-06 (Santander -  22062026.pdf) - R$ 1000.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('18fa8565-865c-439f-aeb4-7f54e57c5499', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 6, 2026, '2026-06-15', '2026-06-22', 1000.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b4ae05f2-a8d2-4b56-803e-948caafd6b3a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fbfd00f3-9ee9-441f-ad3c-c6f1262ffb5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b4ae05f2-a8d2-4b56-803e-948caafd6b3a', '18fa8565-865c-439f-aeb4-7f54e57c5499', 5, 120.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b247bd05-1409-463a-8a16-30c9d221ea49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 5, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9575b113-0916-4c3f-a815-7968772aa8f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 361.98, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cd518911-7fb9-46ea-ad78-2bef64660b11', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9575b113-0916-4c3f-a815-7968772aa8f1', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 361.98, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8ad32439-27bf-497c-ad23-15de9f708ceb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 361.98, 'expense', 'paid', '2026-03-19', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c17379e6-0d16-448a-84ca-00dcafe5df21', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('28b6a0d0-a882-426a-8515-a4620c9e3e6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c17379e6-0d16-448a-84ca-00dcafe5df21', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 288.5, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c0493a36-7526-4664-b063-91ac5ef27124', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, 'expense', 'paid', '2026-03-19', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5c1399b2-4b3f-4b8a-b479-fce59a5e2ffe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.17, '2026-05-22', 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('717f779e-7a01-4c63-a330-858abf690f5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5c1399b2-4b3f-4b8a-b479-fce59a5e2ffe', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 849.17, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f0ac92f1-7639-42b4-8f5d-93e71c9e1f9c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.17, 'expense', 'paid', '2026-05-22', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c695a5e7-f407-4f2e-8a73-a7fb07466eaf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e842999a-1912-40f2-818d-cf499f5a96bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c695a5e7-f407-4f2e-8a73-a7fb07466eaf', '18fa8565-865c-439f-aeb4-7f54e57c5499', 6, 82.18, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eca58d19-f3f7-41f8-ace6-629dcf1160f8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 6, 12, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8f0d6f25-4fda-49f8-b2c9-8850c54f612f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ca99c8fb-678a-46eb-95c8-1c3f50803e61', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8f0d6f25-4fda-49f8-b2c9-8850c54f612f', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 37.48, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b0f789a6-f094-45cc-8ab0-17cd5280b8ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 3, 10, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('30952888-a070-409f-9453-4754d37fe534', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DOMNETTOPIZZARIA', 64.99, '2026-05-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f991f97f-fb0a-4d7a-aa4c-7c9ef0e307d5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '30952888-a070-409f-9453-4754d37fe534', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 64.99, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b9451966-813d-4a5e-9a97-13bf92fe6592', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DOMNETTOPIZZARIA', 64.99, 'expense', 'paid', '2026-05-25', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c760f281-ed47-4674-88fa-4ab782731161', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 132.67, '2026-05-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('597fb8b0-db77-44f6-8a13-96210b2e663d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c760f281-ed47-4674-88fa-4ab782731161', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 132.67, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eb1efe70-7503-48fd-ae37-2eb978be4c78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 132.67, 'expense', 'paid', '2026-05-25', '2026-06-22', '2026-06-22', '18fa8565-865c-439f-aeb4-7f54e57c5499', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-07 (Santander -  22072026.pdf) - R$ 1400.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('b7b48f35-5140-4b7b-9bd6-301c47eefd25', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 7, 2026, '2026-07-15', '2026-07-22', 1400.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1f2c4387-7141-4629-af5a-b22a1c3c3d90', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('edbd3706-9598-42bd-afda-e5d39851402c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1f2c4387-7141-4629-af5a-b22a1c3c3d90', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 6, 120.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3ce40a16-8393-4399-8c88-d463ba3ed240', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 6, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fce278dd-95af-4c2e-9b4e-8675140bca3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.16, '2026-05-22', 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('943d20b7-0dc1-450e-a7e7-d27de2144d7b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fce278dd-95af-4c2e-9b4e-8675140bca3b', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 2, 849.16, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f55bf89b-ff73-4cbc-aca6-114366fe8c82', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.16, 'expense', 'paid', '2026-05-22', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 2, 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f02b0b73-e266-407b-aa5d-25abacffe716', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, '2026-06-22', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('afdc42f2-77e4-41d5-99a5-db5d1249b122', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f02b0b73-e266-407b-aa5d-25abacffe716', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 354.95, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6fa86825-3320-4577-a85c-861373477b85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, 'expense', 'paid', '2026-06-22', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6a80ca92-eb29-4181-b6ab-def99caa540f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 46.84, '2026-06-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a37d39dd-16be-4e71-907a-f69f26b863b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6a80ca92-eb29-4181-b6ab-def99caa540f', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 46.84, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('680fbc94-8c9d-4815-a6ef-182563836cab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 46.84, 'expense', 'paid', '2026-06-25', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dbd22070-7bf9-4a62-8e5e-618c64a7d942', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.28, '2026-06-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cb477230-75f6-4c9b-a3dc-a7935c7b9292', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dbd22070-7bf9-4a62-8e5e-618c64a7d942', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 31.28, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('213b8f14-faca-4c65-88d8-841322ddcbb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.28, 'expense', 'paid', '2026-06-29', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('814aac9a-6ad1-4b56-ab8f-087a03d8425f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*BR', 24.08, '2026-06-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('62dc3db8-8427-440c-890e-df7fa3d368fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '814aac9a-6ad1-4b56-ab8f-087a03d8425f', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 24.08, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ed8dc3bd-b0f2-4384-8c45-1c09da06b351', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*BR', 24.08, 'expense', 'paid', '2026-06-29', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5dff7c8b-7a30-4f64-b0b3-fe98259ce168', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 40.88, '2026-06-30', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bd80125b-a9f0-4e82-a572-a776ece0fa1e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5dff7c8b-7a30-4f64-b0b3-fe98259ce168', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 40.88, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cb183b39-040b-439f-b77d-fb4d642f0310', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 40.88, 'expense', 'paid', '2026-06-30', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eb8205f3-1036-4d40-8eff-304b54cf95db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1e763460-1aad-48d8-8937-ccb8adcc46ef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'eb8205f3-1036-4d40-8eff-304b54cf95db', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 7, 82.18, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0ca25763-1d10-47e7-a6de-805cbe564ad8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 7, 12, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9ca42fa3-04d1-4693-ba85-85a1a84af06b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('84d42be9-35f3-49c7-b151-5bfda641f6c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9ca42fa3-04d1-4693-ba85-85a1a84af06b', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 4, 37.48, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5f7a6cf9-5c2f-4d52-b8d8-ce6c0139ff86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-07-22', '2026-07-22', 'b7b48f35-5140-4b7b-9bd6-301c47eefd25', 4, 10, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-08 (Santander -  22082026.pdf) - R$ 7.91
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('3d37b795-11e2-4600-a424-b45ca3196a98', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 8, 2026, '2026-08-17', '2026-08-22', 7.91, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('292104e6-499d-4584-8497-090528f2d6a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RESERVAS', 109.2, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1bc0afc1-1606-4c5f-b78e-a20d3406c8e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '292104e6-499d-4584-8497-090528f2d6a3', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, -109.2, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62117ffc-3fdb-4b1c-bacd-e4a04e79f02c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RESERVAS', 109.2, 'income', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b401b72e-f8e8-479e-ac94-b14bf9a0c7fe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eb2f0ccb-02fd-47b2-ac63-6cd356573599', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b401b72e-f8e8-479e-ac94-b14bf9a0c7fe', '3d37b795-11e2-4600-a424-b45ca3196a98', 7, 120.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('04b61ab1-37cf-4a04-b585-6292b44be238', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 7, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7887ed4b-3db0-4ae8-ba68-78370c9fde91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, '2026-06-22', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8b42f4c4-5058-4c7b-9aa2-9fd1435e4a58', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7887ed4b-3db0-4ae8-ba68-78370c9fde91', '3d37b795-11e2-4600-a424-b45ca3196a98', 2, 354.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('25624663-ae93-4395-87bc-da4b5cd22f1c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, 'expense', 'paid', '2026-06-22', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a2d231d6-dd73-46b8-b93c-962c951d07b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 12.0, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ecbff099-a27f-4f06-a029-f4be82c029e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a2d231d6-dd73-46b8-b93c-962c951d07b9', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 12.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4f3179bf-4df6-4eed-b829-d2c9b2ec1471', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 12.0, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c65e64b0-5b0e-4e9c-a495-80ef6b2a0451', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 11.95, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6bddfe3b-1cac-4ccc-aa58-a8397ed5bff4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c65e64b0-5b0e-4e9c-a495-80ef6b2a0451', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 11.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ec3c59c1-455f-413f-a9e9-e331aa2f7ab5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 11.95, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('733646e7-f226-4ac6-be5d-485bcc63e0d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*NICOLAS WOTTER DA SIL', 17.48, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('34d19e53-b592-440c-b902-ccf8ddfd437f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '733646e7-f226-4ac6-be5d-485bcc63e0d1', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 17.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5bfc897e-688b-4493-90e9-4a23db0e86fa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*NICOLAS WOTTER DA SIL', 17.48, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('30263da7-75cb-4d52-a1dc-fea530334f03', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.44, '2026-07-19', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('954d7a3a-8dc1-4be3-9816-d6cf9326f6d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '30263da7-75cb-4d52-a1dc-fea530334f03', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 71.44, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3d98dad0-87d9-4739-844a-da9331af0086', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.44, 'expense', 'paid', '2026-07-19', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e4ea3437-6cd0-483a-9bb8-79cab167d0f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 30.0, '2026-07-21', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a64b1df3-d0ec-4f05-a417-a93b31c4f24b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e4ea3437-6cd0-483a-9bb8-79cab167d0f7', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('39f509da-eb36-4bc3-8935-513c6d1b68bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 30.0, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0f237f53-a71a-4c70-9c8b-217529fcaf62', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 7.0, '2026-07-21', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e403483e-179c-4174-b1c9-af728494d101', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0f237f53-a71a-4c70-9c8b-217529fcaf62', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 7.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('08c9978e-f031-4feb-9337-5d9b277fb50e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 7.0, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('91a39d6b-42a6-41ea-9182-30cbd0369ff7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 39.88, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bf1f1f68-8a1c-4c9e-9481-4cd2c4af37f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '91a39d6b-42a6-41ea-9182-30cbd0369ff7', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 39.88, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dbf7aeed-fe19-473e-b579-c345e5532474', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 39.88, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8bff9d09-78ac-48ae-b2b9-fd7ce958802b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ELENICE MACHADO MARQUES', 10.25, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5ad9e02a-104c-471e-8e92-b3d91c22b248', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8bff9d09-78ac-48ae-b2b9-fd7ce958802b', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 10.25, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0a163f12-5730-4d18-91e8-d78f842daeb2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ELENICE MACHADO MARQUES', 10.25, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8b0075e0-1637-4ea7-a820-4e0848fbd890', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0af4215e-db1a-4849-8ab6-7db94c4dc5fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8b0075e0-1637-4ea7-a820-4e0848fbd890', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 14.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a496f080-6401-42e6-972f-36d9c4725221', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f3792339-c323-4396-8d4b-a75f5184492d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 37.88, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('84120154-a83f-4ca9-8458-be765f76edfe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f3792339-c323-4396-8d4b-a75f5184492d', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 37.88, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('14c27ed1-9a96-4f67-97b6-3652f8b671bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 37.88, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6863dc59-a91d-4036-9317-46cb8497a397', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 37.77, '2026-07-23', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1f811ca0-cea8-4c9c-818d-a64365e354ef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6863dc59-a91d-4036-9317-46cb8497a397', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 37.77, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a8caf853-727d-479f-8017-f7220005de0d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 37.77, 'expense', 'paid', '2026-07-23', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f2dd9924-d2b3-4136-ab9c-82989a2d2841', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 16.48, '2026-07-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('574bd5ef-1429-46f5-b853-a1c9d778265a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f2dd9924-d2b3-4136-ab9c-82989a2d2841', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 16.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ebcd866-84c2-4619-8dfa-987a19b612ef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 16.48, 'expense', 'paid', '2026-07-24', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('533fc51d-5fa4-481f-b635-f6cb4bc67617', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, '2026-07-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('57ff54e8-9a4b-432e-b43e-f725c3ad194e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '533fc51d-5fa4-481f-b635-f6cb4bc67617', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 14.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d8b5b681-c9f1-4223-b346-b0423ba166da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, 'expense', 'paid', '2026-07-24', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('801af164-02b9-4351-b092-cc7fff6d43a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.49, '2026-07-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2c373f15-d105-4ef8-afc7-32927281e2df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '801af164-02b9-4351-b092-cc7fff6d43a4', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 15.49, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8a188892-2a1f-4b78-b7a9-5f5d472403ed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.49, 'expense', 'paid', '2026-07-25', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('85ead70c-fd6c-4f3b-8af0-78e7dc964ba5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FERNANDA LOPER SANTANA', 17.0, '2026-07-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1154e093-36a6-4141-9c77-aafe5c6d586a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '85ead70c-fd6c-4f3b-8af0-78e7dc964ba5', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 17.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44b4d48f-3ded-4a18-865b-6475db4bf36e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FERNANDA LOPER SANTANA', 17.0, 'expense', 'paid', '2026-07-25', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ca2aac42-c3e8-464d-8063-969568377663', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.01, '2026-07-26', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('96a02023-01d9-4be8-ab1e-36ea2029e0e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ca2aac42-c3e8-464d-8063-969568377663', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 30.01, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9c2aad0a-b4de-4d1e-8bae-7f68efc20e17', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.01, 'expense', 'paid', '2026-07-26', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('aaee6beb-e52d-4d74-b2b6-f19b20b16eed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 41.8, '2026-07-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('418d7e3b-c042-4f54-8e48-3fc6e591fe5f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'aaee6beb-e52d-4d74-b2b6-f19b20b16eed', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 41.8, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6d919993-59de-467a-8064-480ba8c40054', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 41.8, 'expense', 'paid', '2026-07-27', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('01337906-5f4b-4c0b-a49c-5c33983bea9c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 18.9, '2026-07-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c98ce083-408a-4b26-850f-6b915dc4ccd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '01337906-5f4b-4c0b-a49c-5c33983bea9c', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 18.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cb39a35f-cfcd-4862-a5a1-f87ce896fa63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 18.9, 'expense', 'paid', '2026-07-27', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6bb03cd7-9fe0-47e0-8e24-e2a7f6c9f660', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 30.0, '2026-07-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ef501015-ecc1-4945-8991-493181512d7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6bb03cd7-9fe0-47e0-8e24-e2a7f6c9f660', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('757c244c-6b80-4a94-a9db-a630ad1c7296', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 30.0, 'expense', 'paid', '2026-07-28', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('40bc6523-4a83-4f8b-91b9-216ec3373f2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2026-07-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d3d375c9-5b68-439d-baa8-83badb518eb6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '40bc6523-4a83-4f8b-91b9-216ec3373f2e', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 10.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('14423862-4755-455f-9a50-cd2bf020a8d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2026-07-28', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('37cb0b25-27ee-4919-8541-b1a01b95e6ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '27 736 853 ALEF DOMING', 15.0, '2026-07-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('30d28aba-3fb6-4f6c-9968-ddce69a3dca1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '37cb0b25-27ee-4919-8541-b1a01b95e6ea', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 15.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21504e17-1d46-4bb3-8df4-3f1986f1d650', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '27 736 853 ALEF DOMING', 15.0, 'expense', 'paid', '2026-07-29', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0dd3d513-f309-4f29-81d5-eb44a1d46d90', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2026-07-30', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2ffa82e1-db11-4c85-b566-e08295733fdd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0dd3d513-f309-4f29-81d5-eb44a1d46d90', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 10.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5b8a7ffa-384c-47d9-9835-32accf6c5393', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2026-07-30', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0596c434-c007-486f-b012-e776d7a08c44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RESERVAS', 156.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('921d29d2-57c4-4f0b-9acc-5b903d3a6a32', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0596c434-c007-486f-b012-e776d7a08c44', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 156.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('448f5b81-45ef-4cf6-b13f-db148bea1070', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RESERVAS', 156.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('188a6a40-73e9-48b1-921c-60924bbae309', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 60.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('68cd9fd1-5534-4bf4-95be-3a5d2bb95161', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '188a6a40-73e9-48b1-921c-60924bbae309', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 60.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8d0c3796-bac8-435f-8ee9-af0b3cbb69c9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 60.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('aaa8d1ed-134e-4c69-8c15-393ed9521582', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 167.68, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39a568c9-04a9-4841-9ca4-051d432a3a8d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'aaa8d1ed-134e-4c69-8c15-393ed9521582', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 167.68, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('93b2de8b-f4e0-4030-a527-d4c90898696f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 167.68, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('13498793-29c8-45ab-a589-c43928bae5ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'GARAGEM BELEM LTDA', 25.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('41308869-0eff-4c6e-a023-6dda9517bdec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '13498793-29c8-45ab-a589-c43928bae5ab', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 25.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c2c9a504-9266-45a9-9802-221690e00384', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'GARAGEM BELEM LTDA', 25.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('020c3813-8ea1-4eaa-945f-eceee4b5380e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 15.0, '2026-08-02', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1e82009f-488c-4430-be72-032d8ea6122e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '020c3813-8ea1-4eaa-945f-eceee4b5380e', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 15.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('35009a8e-3538-4ecd-80ab-646c848491e6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 15.0, 'expense', 'paid', '2026-08-02', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('26bd2889-e95d-41f8-a1e2-8898eca6f7b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, '2026-08-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f7c3d89c-f11e-4949-9d6c-4507b8700a68', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '26bd2889-e95d-41f8-a1e2-8898eca6f7b4', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 26.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('20133864-bbdd-4532-b7f6-e25ed1fc13de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, 'expense', 'paid', '2026-08-03', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('153770a5-c80e-443e-81a3-26fb87536395', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 18.38, '2026-08-07', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('df0dd072-1b02-42d4-b4b5-ba6d56645df0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '153770a5-c80e-443e-81a3-26fb87536395', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 18.38, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bacba357-d1c9-482b-8f78-1de740ae3d7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 18.38, 'expense', 'paid', '2026-08-07', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9fe69496-b60b-4f01-b24e-56b29efec228', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 42.83, '2026-08-09', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6fb60ab1-66ea-4024-b179-b1e84fc6f247', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9fe69496-b60b-4f01-b24e-56b29efec228', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 42.83, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e624078b-9f93-4e38-b710-8826b46b1822', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 42.83, 'expense', 'paid', '2026-08-09', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0b0ef474-a9c4-4798-8c10-6b54163c0ea2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 15.5, '2026-08-10', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dd285611-0f83-435b-b3e6-d5c9573ae351', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0b0ef474-a9c4-4798-8c10-6b54163c0ea2', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 15.5, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('96c4bf71-1ac1-4b93-8c64-7fb9997f6447', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 15.5, 'expense', 'paid', '2026-08-10', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4f961ef1-b864-4e4c-9310-d3127112349a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 40.0, '2026-08-10', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8120e08-9a56-402a-8eba-711ed48ce3c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4f961ef1-b864-4e4c-9310-d3127112349a', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 40.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c8cbd567-311c-472d-bea4-a3df3657f8e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 40.0, 'expense', 'paid', '2026-08-10', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f3d9cb4f-4d96-47f1-a1ca-8d07e2962b1a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 70.0, '2026-08-11', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d0a4039d-a9d1-4a40-9b87-c14e96c55a21', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f3d9cb4f-4d96-47f1-a1ca-8d07e2962b1a', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 70.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a953b04-6064-4f66-92da-d75df5642b6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 70.0, 'expense', 'paid', '2026-08-11', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fbffdde2-5b63-4c54-8fe7-d04a9483a1e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ALEXANDRE DE MENEZES S', 100.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9636d8dc-ba1b-41c5-8a2a-201c87c16924', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fbffdde2-5b63-4c54-8fe7-d04a9483a1e0', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 100.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9efc5582-4837-46f5-b2c1-4c5e7d39d479', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ALEXANDRE DE MENEZES S', 100.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eb431250-4eb2-4648-b06b-172fd5899bab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('563afb25-5e76-4f64-bb26-12391d2b12cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'eb431250-4eb2-4648-b06b-172fd5899bab', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b9879983-2f7a-4c16-b699-efd79ab0a206', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('93ab6c28-2126-48cd-b390-a225e90b4845', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5ff09bad-9d66-4c81-bbbd-17e83646cbf7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '93ab6c28-2126-48cd-b390-a225e90b4845', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6859900-0dc8-4e0c-ba44-c7b3aacf0ecb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c8e38517-f1f0-49a0-83d5-93ab069437e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 10.95, '2026-08-14', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a9481d9b-4c2f-43ae-ba7d-f38de8f3808d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c8e38517-f1f0-49a0-83d5-93ab069437e7', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 10.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('86d03eb0-1d02-4b53-aef5-6ea4497cb82a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 10.95, 'expense', 'paid', '2026-08-14', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2675c694-b2ad-4e4c-ad4e-020ada4d03b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a26921b6-a456-404d-a3ee-0e8ca35e00ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2675c694-b2ad-4e4c-ad4e-020ada4d03b5', '3d37b795-11e2-4600-a424-b45ca3196a98', 8, 82.18, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a130ded6-a8d2-400c-9c2f-f9c822b03d33', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 8, 12, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7b9f9d61-15d8-4891-9f5b-52268fa3ed6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1ad87d90-fee4-4a0f-ba37-9084ddf4f36e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7b9f9d61-15d8-4891-9f5b-52268fa3ed6f', '3d37b795-11e2-4600-a424-b45ca3196a98', 5, 37.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8c122d55-bd9f-4aa1-a731-5f4d70ae3283', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 5, 10, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1556d56e-091c-47fa-9e68-449792e03c8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ANTHROPIC* CLAUDE SUB 117,14', 21.68, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4e335c52-14e8-439b-9357-3fa4973c588b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1556d56e-091c-47fa-9e68-449792e03c8e', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 21.68, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3c4f74e0-ca7d-4b92-a95c-c30a85499e2b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ANTHROPIC* CLAUDE SUB 117,14', 21.68, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('81fc7cfa-2c37-4784-97f4-a7fb32e6ddee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 109.9, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7744132f-bb6a-4a07-9680-dc9e38186d3f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '81fc7cfa-2c37-4784-97f4-a7fb32e6ddee', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 109.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9fabd7ec-0714-4644-8dd1-1dc3e194914f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 109.9, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2e88ac07-aa06-4377-8224-dc9f6a7f69c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: APPLE COM/BILL', 109.9, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('01cf7b94-244c-490b-9291-98736f42c7b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2e88ac07-aa06-4377-8224-dc9f6a7f69c7', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, -109.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('164eb51d-0fa1-42a5-91e5-5c0da26efcd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: APPLE COM/BILL', 109.9, 'income', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9e082f7f-0fdf-42f6-af73-c0a336cb4f40', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 56.06, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7a22c0e6-5b94-4a96-940b-f0776c04bdda', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9e082f7f-0fdf-42f6-af73-c0a336cb4f40', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 56.06, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('130fa25b-642b-4af7-b88d-266a14934361', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 56.06, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b07a0028-7532-459a-8d5c-764860a08098', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 133.61, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ce2b9129-4856-4f25-94fa-efa01138886d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b07a0028-7532-459a-8d5c-764860a08098', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 133.61, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a4484e5f-0b8c-4a0d-943d-ed52149a7d6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 133.61, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('65cb89ac-cb2e-4e89-9808-015376f354ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 49.86, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4ba31353-ddd9-41e6-92f0-85a452c2ef96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '65cb89ac-cb2e-4e89-9808-015376f354ca', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 49.86, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0487b515-58dc-4a1c-931d-d9e6a0c36f24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 49.86, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7f52fdf0-2460-462e-ab11-07252a9f2d6b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 158.65, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c61f3ec4-7cb9-4938-a28a-69b35b503b69', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7f52fdf0-2460-462e-ab11-07252a9f2d6b', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 158.65, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0f917fa4-10c1-4584-ae7a-76fb7ae4818d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 158.65, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4a7a17a2-82ea-43b9-a0c9-c7e0a7ec13de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f01672b8-5153-4e5d-9a1c-3b084efff8aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4a7a17a2-82ea-43b9-a0c9-c7e0a7ec13de', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 129.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('703e6f54-f778-49e2-8c52-434d75cb4db0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('42904fdb-0a83-4223-8594-a0ac87ce4922', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'MOONSHOT AI 108,77', 20.01, '2026-08-12', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b50bd063-e054-4575-90d5-b85315fc94d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '42904fdb-0a83-4223-8594-a0ac87ce4922', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 20.01, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b6956905-4100-4489-9320-9bf458516a7d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'MOONSHOT AI 108,77', 20.01, 'expense', 'paid', '2026-08-12', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('edafca64-d538-4373-ac30-c0acc306fe20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58067449 ANGEL GON', 31.62, '2026-08-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('492fb58c-615e-4916-a305-fe53e2419950', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'edafca64-d538-4373-ac30-c0acc306fe20', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 31.62, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bea986ad-5062-4182-a627-70b2a448abe5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58067449 ANGEL GON', 31.62, 'expense', 'paid', '2026-08-12', '2026-08-22', '2026-08-22', '3d37b795-11e2-4600-a424-b45ca3196a98', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-01 (Santander - 22012026.pdf) - R$ 1450.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('dc805328-b871-4ebd-86f7-687855fb5e20', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 1, 2026, '2026-01-15', '2026-01-22', 1450.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7afe7367-1d7a-49f2-86c1-54b1cf396bfa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RAC PELO', 0.02, '2025-11-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('126b638d-0529-490e-8231-4ab7b4553cbe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7afe7367-1d7a-49f2-86c1-54b1cf396bfa', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -0.02, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9dd99657-1913-4f35-88fb-e1467b7f4a57', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RAC PELO', 0.02, 'income', 'paid', '2025-11-28', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3bacb3e2-9c52-42b3-a4c2-2662fe75c98f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0264d6c5-a8a5-4287-acf3-fe56c5b6ab14', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3bacb3e2-9c52-42b3-a4c2-2662fe75c98f', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 204.61, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('79e8c591-15e5-42a9-ade6-02728b22c48e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, 'expense', 'paid', '2025-11-28', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 3, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bedbe736-d0d2-42bc-b484-64c4145dcc6d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('36ee98a8-d025-4514-b4e2-5da865c947b8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bedbe736-d0d2-42bc-b484-64c4145dcc6d', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 326.43, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bd50ef1c-a218-418a-8329-e66579313813', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 5, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('71cc923d-d176-4c2c-a4c3-f4d764d06fbe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 40.77, '2025-12-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6a5c5d80-86d8-4b0e-8770-473a4d39c5c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '71cc923d-d176-4c2c-a4c3-f4d764d06fbe', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 40.77, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('76968b92-d868-4dbc-b655-28f5d297f77e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 40.77, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d27f2928-40b9-4c53-bcc8-8c2ffb4a3db2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: GB MIX QUARTIER', 199.29, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e3e13b47-94bc-4054-a6f5-9355480799a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd27f2928-40b9-4c53-bcc8-8c2ffb4a3db2', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -199.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d20ef70-4fc3-4ce6-a16b-a528b58e369e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: GB MIX QUARTIER', 199.29, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c3892fd5-bc6f-4f14-9ef9-2e6634ed9639', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: CARREFOUR PELOTAS GENE', 86.3, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5899fc5d-5efa-4b9a-bc1f-ba32d94414be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c3892fd5-bc6f-4f14-9ef9-2e6634ed9639', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -86.3, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1c5330e0-96ad-491f-9848-8bc577a1d7a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: CARREFOUR PELOTAS GENE', 86.3, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8e1f7e99-1487-4426-b000-449ced4e34c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: KENKYO COZINHA ORIENTA', 163.9, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('19d8aa50-6c88-4ab5-b1a4-8121788f5ec3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8e1f7e99-1487-4426-b000-449ced4e34c0', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -163.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ab0bee5-56c0-4f0b-b003-83abd6e69dbc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: KENKYO COZINHA ORIENTA', 163.9, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b585b3b6-009c-4257-97d0-19d0c3393f49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: QSQ PH GUARULHOS 0T02L', 90.06, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('36c6c4bf-1c3b-42fa-986b-54534ae8ce7b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b585b3b6-009c-4257-97d0-19d0c3393f49', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -90.06, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5f1fb5d1-511b-49e5-bfb3-e709ab147b4e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: QSQ PH GUARULHOS 0T02L', 90.06, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ad1fa379-4a63-47bf-b271-bbdffd84a75f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Estorno/Crédito: CLARO P*FATURA CLARO', 117.15, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('15551ed2-8ea5-4b7e-85bd-3987aeed2a77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ad1fa379-4a63-47bf-b271-bbdffd84a75f', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -117.15, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9bc317c3-8ae4-4868-8a26-5c2402797fc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Estorno/Crédito: CLARO P*FATURA CLARO', 117.15, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2979d66a-7087-4647-a968-4f4071b97356', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ORIONGESTAODE', 117.96, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f831008-e838-4cdc-8dbf-c9e454f03832', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2979d66a-7087-4647-a968-4f4071b97356', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, -117.96, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ada6ef0b-df2e-49bd-8fa0-dc79191c7ad6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ORIONGESTAODE', 117.96, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5ded4120-057e-4523-8431-3c1fe8ccf319', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2026-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('10d6b1b5-9584-4159-8b87-afc678c49e02', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5ded4120-057e-4523-8431-3c1fe8ccf319', 'dc805328-b871-4ebd-86f7-687855fb5e20', 12, 312.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('219ef6af-cd70-488f-a26a-ca0087a0ad83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2026-01-08', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 12, 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c75bffb7-6b5d-4553-a9ec-fbc33170d270', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('44285095-dc2e-466b-8bd4-0737cfd26668', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c75bffb7-6b5d-4553-a9ec-fbc33170d270', 'dc805328-b871-4ebd-86f7-687855fb5e20', 8, 67.48, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3c60925d-07ca-4b78-9530-239c829ea033', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 8, 10, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8f8eb662-eeae-4aba-807b-068fe7c259cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('303ca9f8-7394-4a22-b79b-a155fefae0b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8f8eb662-eeae-4aba-807b-068fe7c259cc', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 12.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d6a9072a-fca1-4061-9003-5d05b039a6e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1bbf2630-c4ef-4e5f-95b0-6bd8271f07df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4fc4dbe8-dd3b-488d-8f9b-475c6a759ee8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1bbf2630-c4ef-4e5f-95b0-6bd8271f07df', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 200.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('89e23abc-ff5b-482a-874b-d9ca8acf7144', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1431ee7b-0b77-4958-8061-47882002a631', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2c280968-5c1f-48da-b34f-8d95bff4114f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1431ee7b-0b77-4958-8061-47882002a631', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 172.17, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fb26f1f1-32cd-42ae-b0b7-8d03cd6793d5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d45514e8-8514-439b-8148-a51c13a32748', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('35768851-b5b9-471a-bc5e-bc19c920a9c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd45514e8-8514-439b-8148-a51c13a32748', 'dc805328-b871-4ebd-86f7-687855fb5e20', 4, 74.09, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aa0d4ebe-0c38-4b31-a675-bb8ee3645bb4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9a3467da-8ec4-4b57-996a-0e832097040d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5805e923-e65b-45f6-bef2-b5d505c74342', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9a3467da-8ec4-4b57-996a-0e832097040d', 'dc805328-b871-4ebd-86f7-687855fb5e20', 4, 70.17, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e082582a-4bd6-471a-83ac-7c6ecc092ac3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 4, 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('de9d8421-4eef-4615-b120-56e45c9b67aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('02af49de-be03-40a1-85d4-ecc4114999d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'de9d8421-4eef-4615-b120-56e45c9b67aa', 'dc805328-b871-4ebd-86f7-687855fb5e20', 3, 130.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0d9b905e-d2e1-46fc-8c47-061034d8f789', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 3, 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0c87d036-cc90-471c-8926-bf835a3eb55b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b098159f-35cd-45e1-8c8e-e7ca1b51ba52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0c87d036-cc90-471c-8926-bf835a3eb55b', 'dc805328-b871-4ebd-86f7-687855fb5e20', 3, 108.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('42f3f653-f46f-4535-aff7-46c8b0c17c48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 3, 5, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0df788ba-95c4-401a-a945-df9c29176273', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ed882cdf-aad9-4659-84da-9541bd8d5c86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0df788ba-95c4-401a-a945-df9c29176273', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 71.87, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('07bbdb7e-c5ac-4feb-9a4d-2ac8cb026e3c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6686ad63-eed2-411b-a370-f03bc9738205', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e71e3b44-30cd-4cdd-9b2d-0dc2eb1e401a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6686ad63-eed2-411b-a370-f03bc9738205', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 116.88, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c276aec9-68ff-4460-893e-8e8b6f2564d6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, 'expense', 'paid', '2025-11-29', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6944735e-b001-46fe-ae91-d14e622ce4e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aac7d46f-3b74-49aa-b145-ec049558fb76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6944735e-b001-46fe-ae91-d14e622ce4e5', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 50.49, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('17d082f6-07f9-4d7f-8a41-8aa7eae49756', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, 'expense', 'paid', '2025-11-29', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('aa35f7ef-3bf0-44e7-a613-a11b9bd9ff17', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, '2025-11-30', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c9a3691d-428b-4ac5-8d02-bd3eafa65491', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'aa35f7ef-3bf0-44e7-a613-a11b9bd9ff17', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 63.18, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2c8eefdf-d634-4463-bb79-996e3cee424a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, 'expense', 'paid', '2025-11-30', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7d10d033-3fad-45d8-8a31-338d80c9084c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3010e774-5b32-4f51-bb82-1bb0ac91f59d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7d10d033-3fad-45d8-8a31-338d80c9084c', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 42.48, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5d7c2c6a-f24c-4bb2-833d-e3109a0e21fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3faee746-5ad3-41f5-ad60-7e2556ee2bd9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('73212838-97ca-4861-bf7f-ff24858febe4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3faee746-5ad3-41f5-ad60-7e2556ee2bd9', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 42.19, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('06230ab7-ac49-43f8-8305-577a681b816f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('41ae9121-885d-46b0-ae93-08639c0e28a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, '2025-12-19', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('20bb5a4f-5a70-4b1b-9f31-26b1e9b12f3d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '41ae9121-885d-46b0-ae93-08639c0e28a4', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 81.93, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4b548c1e-ede5-4f3e-bab3-08834fd81af0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, 'expense', 'paid', '2025-12-19', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d2f4472b-182b-4635-b4fa-6308c50c6279', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0544fdd8-e3ff-4064-9ab4-8fedaa929c20', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd2f4472b-182b-4635-b4fa-6308c50c6279', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 32.43, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0b0d1e65-a28c-458c-b525-6df6a66403df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5da51bab-21c1-4f2e-8ec7-d0a2640f83f9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2aa50979-6ec1-4151-9b95-c6ff46b02368', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5da51bab-21c1-4f2e-8ec7-d0a2640f83f9', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 59.02, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('894c3168-0aeb-4310-b375-6a49cb6d5fbd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dab357e2-b43e-4055-9d25-91eb097bce0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eb949338-7071-49f2-b469-4f90b39433a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dab357e2-b43e-4055-9d25-91eb097bce0a', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 31.08, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('de9b4fec-2d2d-4f59-85ac-7a0cb3e418cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('daae22d1-f93c-438f-a34a-8e36a8203229', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8a216f62-bcac-4795-886d-801c11157546', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'daae22d1-f93c-438f-a34a-8e36a8203229', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 71.77, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7167f601-fc78-44cd-9400-d0d989e888f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('26be107a-474a-4aef-a3b2-8e3ac1a3fb18', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('023b9275-47bb-4f93-91ca-3445f4805da3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '26be107a-474a-4aef-a3b2-8e3ac1a3fb18', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 82.2, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9f29f3b6-b550-40a3-9d5d-a88b40d75546', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a1bd8cfe-d7cd-4eec-a5d1-bfca221ecb91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, '2025-12-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0a361f47-fccb-43c5-b177-29a08b41a9a3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a1bd8cfe-d7cd-4eec-a5d1-bfca221ecb91', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 50.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0fdb21c5-8f85-495b-bc72-30791154ac2c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, 'expense', 'paid', '2025-12-14', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b8fc26b0-70d7-4ee7-b077-78b07699ff88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 117.96, '2025-12-16', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('56916421-26d4-428f-b3f7-5e0ead4a5592', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b8fc26b0-70d7-4ee7-b077-78b07699ff88', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 117.96, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('56e4eb60-8380-4f7c-9d70-97e2274a1a1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 117.96, 'expense', 'paid', '2025-12-16', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('849a1e04-77a9-4be6-9205-52d7956e4fbd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 15.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0922b1a8-69ba-4232-917d-cb6958a758b0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '849a1e04-77a9-4be6-9205-52d7956e4fbd', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 15.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fbf11082-1747-47b1-87fb-ac3eeeb8c03b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 15.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4f67feac-26d5-4a04-9a9b-9002e36d60e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 31.95, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8a75c61e-4c82-4096-a5e1-31b1b8f62813', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4f67feac-26d5-4a04-9a9b-9002e36d60e5', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 31.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9893507c-7434-4bce-a325-cc18c09ad0af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 31.95, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b540d47e-bd6d-493d-a761-c7ddf4836c11', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TYAMY', 9.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f7e32a42-b028-4aa8-92c4-515e5e81b293', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b540d47e-bd6d-493d-a761-c7ddf4836c11', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 9.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('196696cf-da2b-4213-8a03-8dffc1723b6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TYAMY', 9.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('efb79ecc-4353-49dd-af0d-d90d9a4888c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ACOUGUEDOSSANTOS', 21.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8afcf23-b8d6-4844-9699-f075e155d718', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'efb79ecc-4353-49dd-af0d-d90d9a4888c8', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 21.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4fb88503-cedb-4366-ba73-d8ff5b3a3f08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ACOUGUEDOSSANTOS', 21.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c6bfec74-2044-4313-a9e8-945717bcd631', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 50.0, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a6b7bfcd-425d-49f1-8642-17a1d89aac08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c6bfec74-2044-4313-a9e8-945717bcd631', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 50.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a65f021d-6698-41b7-92bb-36cf5a3840ad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 50.0, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3eae2618-f417-4e12-8c4e-422c7a6a9304', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 117.15, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('193930d9-756a-427f-b5c8-ccf42715fd1f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3eae2618-f417-4e12-8c4e-422c7a6a9304', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 117.15, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('69cbc438-e56f-41c7-964e-7d6c2a8587ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 117.15, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('aca87825-1194-4d2e-b40d-bc9b5a7f24ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a6045c10-9743-4db0-97cc-b95084e18ccb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'aca87825-1194-4d2e-b40d-bc9b5a7f24ce', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 9.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('84cf75c0-6757-43ef-8429-bb3b53aed6dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7a95fc63-6256-4cd7-b19e-f5c50af45d5a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 43.85, '2025-12-19', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f5ee9ebb-b384-49bf-866f-4540647c314d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7a95fc63-6256-4cd7-b19e-f5c50af45d5a', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 43.85, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5f775c51-dfb5-4e5a-83c9-4f2464d1fdc8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 43.85, 'expense', 'paid', '2025-12-19', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('95a4dcd5-5c5d-4e4f-aa30-66cfec8d66c6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*PETIT POA BUFFET EVE', 29.53, '2025-12-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('37d62ed2-9fcd-4a28-a26d-ec554e5d85e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '95a4dcd5-5c5d-4e4f-aa30-66cfec8d66c6', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 29.53, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62bd0960-1ebe-4fb7-ae4f-7baa4c812dbf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*PETIT POA BUFFET EVE', 29.53, 'expense', 'paid', '2025-12-20', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ab3877aa-cf54-4566-a5e1-2b8485daf3d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 45.8, '2025-12-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f70d6947-406e-46f1-b3a0-6390c4f731ec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ab3877aa-cf54-4566-a5e1-2b8485daf3d9', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 45.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('002af64a-a71c-4558-877c-5d0eaa5359d5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 45.8, 'expense', 'paid', '2025-12-21', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1baec8f4-4e10-4b33-9f1c-a974d8c7db5a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CALAUFABIAOFABIAO', 64.9, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('122631ac-5a1f-458d-b203-724b7f28343d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1baec8f4-4e10-4b33-9f1c-a974d8c7db5a', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 64.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b713e788-2bc2-41d2-a90e-fc9ebfc2498c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CALAUFABIAOFABIAO', 64.9, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('22162569-727b-4158-b674-98ca613c82f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'BRAPEL COMERCIO DE ALI', 15.8, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2099f606-6034-4d9f-b04b-f054f205031d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '22162569-727b-4158-b674-98ca613c82f0', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 15.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6ae59c44-ceda-42e8-abca-d615671b848b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'BRAPEL COMERCIO DE ALI', 15.8, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('da6e747b-36d6-4bde-b55d-f8c47a03cf41', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 39.99, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('40d04d91-2a0e-4750-8e3f-97df6969badf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'da6e747b-36d6-4bde-b55d-f8c47a03cf41', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 39.99, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('01027c40-f53a-4ffa-b339-147fe20ccaf8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 39.99, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fae377ac-92e5-41b2-a1b7-864225b598c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAA PORTO ALEGRE AEROP', 14.4, '2025-12-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('94a9bf9f-c88f-4247-a4b0-f0cc114f86fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fae377ac-92e5-41b2-a1b7-864225b598c7', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 14.4, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2b35df80-a37c-42c4-99c8-3e61dafc0f2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAA PORTO ALEGRE AEROP', 14.4, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('09bd2ee3-56d0-4437-8717-3ac78b05f0c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 90.06, '2025-12-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1d380cc3-73ef-410f-91b5-5ddfd28b8598', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '09bd2ee3-56d0-4437-8717-3ac78b05f0c0', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 90.06, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('22b917f8-6a51-43fb-9966-3941cb38d2f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 90.06, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e2749f18-e90d-4160-8993-edcfaaf07164', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 49.8, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c197c69d-71f8-47b0-aff4-2051e8f2f15c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e2749f18-e90d-4160-8993-edcfaaf07164', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 49.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('00360225-6380-4e13-bb0f-e383c2c61fcc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 49.8, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('650aacbf-5e2e-464c-95de-eb839d0af677', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'NUTRY FOOD', 14.99, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4fbd035c-357b-4e33-840d-496d97e8f3d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '650aacbf-5e2e-464c-95de-eb839d0af677', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 14.99, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a8eecb7f-7f66-4bf7-9b62-c6d875e1ad6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'NUTRY FOOD', 14.99, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1bcd7075-f8be-472f-bb2e-69961b7d104f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'COXINHAS EXPRESS', 10.83, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('32093142-0112-4a13-a190-3f5e48fb9b9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1bcd7075-f8be-472f-bb2e-69961b7d104f', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 10.83, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ebdceb2a-a35a-4daa-b305-335dfd6c3b3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'COXINHAS EXPRESS', 10.83, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a795e7ca-9596-49bd-8282-ce32986b60fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 163.9, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1329e562-bfbb-4e7f-ace3-cdf3e33d42a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a795e7ca-9596-49bd-8282-ce32986b60fd', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 163.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('df6bd9cd-e6a6-434a-9746-16b49815aba4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 163.9, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0df1d1b3-e11b-47ad-b86b-255a64622989', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EDEN SUPERMERCADO', 30.58, '2025-12-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b1f95708-c0c2-4f21-b634-d492bc24b2c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0df1d1b3-e11b-47ad-b86b-255a64622989', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 30.58, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e112e467-dacf-450e-ab02-1039ea4d29a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EDEN SUPERMERCADO', 30.58, 'expense', 'paid', '2025-12-27', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ea127c28-8cec-4b29-a264-f4e77b80c919', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BALI EMPREENDIMENTOS L', 12.9, '2025-12-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('847392af-3ab3-44c0-85fd-b3efc05745f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ea127c28-8cec-4b29-a264-f4e77b80c919', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 12.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e1d3b3db-72bc-462e-bdf8-7e703e6f3579', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BALI EMPREENDIMENTOS L', 12.9, 'expense', 'paid', '2025-12-29', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f9f27d70-a511-431e-b316-19b7d0b04a42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GRAN COFFEE', 8.0, '2025-12-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('19ea175c-db80-4382-8403-27c37bb102ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f9f27d70-a511-431e-b316-19b7d0b04a42', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 8.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3840336c-3219-438e-98a8-8c6f8c483c43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GRAN COFFEE', 8.0, 'expense', 'paid', '2025-12-29', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7babfdd2-bc9b-46eb-81c7-b42760444d82', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 86.3, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('11490d17-1953-4dd4-9cdb-8c2ea801af04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7babfdd2-bc9b-46eb-81c7-b42760444d82', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 86.3, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a6fc336-ad55-4a50-969a-d839d05a847c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 86.3, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('64b44c31-4009-4a6d-a97e-5920dd57bb43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 3.29, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('320deafa-428a-40f5-a6d1-da294b0f1166', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '64b44c31-4009-4a6d-a97e-5920dd57bb43', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 3.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e1975462-7f24-4a84-83a2-6bb27ce9c041', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 3.29, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6f45393a-edd6-45ac-84e7-b5a953aee7d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SUBWAY XV', 19.9, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('73942430-c56e-47a0-8b3d-0f0fc83dce51', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6f45393a-edd6-45ac-84e7-b5a953aee7d1', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 19.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f6ca4051-a8c9-40c3-9582-6293cd2c28bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SUBWAY XV', 19.9, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cb0df200-b754-4ed8-9a47-a4062e955d36', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 32.09, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fbacc3e4-5bd9-4484-b671-aa0f1a124823', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cb0df200-b754-4ed8-9a47-a4062e955d36', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 32.09, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0c14ee52-68ee-47c0-b4a3-b69ea210d4e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 32.09, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4ee7618c-5df0-49f6-b351-6f0b66123732', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*LOTERIASONLINEJSNX', 30.0, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('140527a7-6b6c-4d33-a740-68b9b9e2d096', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4ee7618c-5df0-49f6-b351-6f0b66123732', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 30.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('80f949b8-7d7f-4d9e-a0c4-1dc0bf6be5e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*LOTERIASONLINEJSNX', 30.0, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('39b3ce78-2f60-46ba-909b-7ba179f9d76c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 199.29, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5eb7f9c4-37b2-403c-af0d-835acf963130', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '39b3ce78-2f60-46ba-909b-7ba179f9d76c', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 199.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c666515e-eb0f-4cc7-b0fa-5539012654ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 199.29, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f9ebe365-6630-41c0-9f96-1c29b8797cef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTOS COQUEIRO', 46.8, '2026-01-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dd0ef1ad-f9a5-4177-a322-e459cbd00d87', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f9ebe365-6630-41c0-9f96-1c29b8797cef', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 46.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f289f3b1-d349-45cd-8748-eedc43356920', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTOS COQUEIRO', 46.8, 'expense', 'paid', '2026-01-01', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5bf5d155-9140-42f7-9fe4-0c0876ea8610', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, '2026-01-06', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e65cc698-2400-4691-b639-879def8bc984', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5bf5d155-9140-42f7-9fe4-0c0876ea8610', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 39.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('310a6011-d0c6-4503-950c-d5c0bc1524ad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, 'expense', 'paid', '2026-01-06', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('098a610e-f5ed-40d5-91b5-6d74dd3b4c14', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD', 7.95, '2026-01-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cab40f1d-40ba-45ac-8486-78d9a807c57c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '098a610e-f5ed-40d5-91b5-6d74dd3b4c14', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 7.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0d33bc33-9cd4-4cc6-83ba-b72343de42db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD', 7.95, 'expense', 'paid', '2026-01-12', '2026-01-22', '2026-01-22', 'dc805328-b871-4ebd-86f7-687855fb5e20', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-02 (Santander - 22022026.pdf) - R$ 1678.63
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('557e445f-2676-4f21-b5c1-6de47e07d654', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 2, 2026, '2026-02-12', '2026-02-22', 1678.63, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('21b35090-607b-49f1-8a8e-996da4e142a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.59, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a5fb5ca5-ce9a-45e1-8407-88b99ae7e392', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '21b35090-607b-49f1-8a8e-996da4e142a7', '557e445f-2676-4f21-b5c1-6de47e07d654', 3, 204.59, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('11356381-53e1-4965-92e1-e1108eb046ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.59, 'expense', 'paid', '2025-11-28', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 3, 3, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f1eecd4c-c6c9-48b2-80f2-710c3078dd93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('31dc6d82-ef2a-4423-9ec2-7d33d04c2ed7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f1eecd4c-c6c9-48b2-80f2-710c3078dd93', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 326.43, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('59b50c6f-e879-4224-96cd-0689b1777b6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 5, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('decea5d2-7fd3-46f5-bd95-e6c1777b52dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('de73dcab-46b9-4feb-9e39-21117e19e196', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'decea5d2-7fd3-46f5-bd95-e6c1777b52dd', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 120.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('72ff480e-c7da-48a6-ac63-2fbed2801689', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c9e1b638-135d-4eb9-9e16-03dbf6461384', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CONTA DE LUZ', 47.18, '2026-01-23', 1, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0c6fbd20-c0d4-40ea-b1ff-bd55b4fb86c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c9e1b638-135d-4eb9-9e16-03dbf6461384', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 47.18, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9e7d12a5-08e4-4072-ba95-6192945c7005', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CONTA DE LUZ', 47.18, 'expense', 'paid', '2026-01-23', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ff9266c1-2265-4857-b200-eb71ac15cb7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d800b794-840c-482b-8ab8-04829efef232', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ff9266c1-2265-4857-b200-eb71ac15cb7a', '557e445f-2676-4f21-b5c1-6de47e07d654', 9, 67.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('11613c84-6694-4633-8960-20b352bb8de6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 9, 10, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('587fd30d-d5a8-46ab-909d-28c28b23a1a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e3cf0ab6-0702-496d-b94f-d52a5f2840a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '587fd30d-d5a8-46ab-909d-28c28b23a1a4', '557e445f-2676-4f21-b5c1-6de47e07d654', 5, 74.09, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('36b60007-ff62-4ba4-9f6c-87fd429776ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c1ef51ff-ce51-4a30-a584-539b4617741e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7ddae5f9-0289-4816-9a0e-73243bb4cace', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c1ef51ff-ce51-4a30-a584-539b4617741e', '557e445f-2676-4f21-b5c1-6de47e07d654', 4, 130.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8b3f69bf-9c28-4460-a909-5fa0836bb767', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 4, 4, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bd87c5b7-c137-4cdd-be4e-873d6df3dc46', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cde70d28-d0db-484b-b80b-ad14190c4bb0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bd87c5b7-c137-4cdd-be4e-873d6df3dc46', '557e445f-2676-4f21-b5c1-6de47e07d654', 4, 108.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a923e4e3-7b88-4db2-8a52-f598abc100d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 4, 5, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2d925347-af86-4926-ad09-a79c669d707b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a561558c-8338-48d9-8de5-29105b981599', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2d925347-af86-4926-ad09-a79c669d707b', '557e445f-2676-4f21-b5c1-6de47e07d654', 3, 71.87, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d8485dd-440e-4a8b-8adf-55fb3cd51ec3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f0724d7-c30b-4f6b-9a7e-5e8093feaee9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4b402806-24e1-4afd-aa3c-c4cfbe8f9559', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f0724d7-c30b-4f6b-9a7e-5e8093feaee9', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 42.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('51352580-0523-4454-97eb-8af937134652', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f2fef4d8-2c25-45e4-a89b-af98b4b882a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('676c014b-aaa1-4f38-9e35-837ad8f7661f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f2fef4d8-2c25-45e4-a89b-af98b4b882a6', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 42.19, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6d704bcd-8d24-4a2f-a54a-72935b3dafe7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('635bc3b2-b1a6-4748-be78-fe73343ae96b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, '2025-12-19', 2, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6fb06fc8-37bb-41cc-bb2f-4ce949081d4a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '635bc3b2-b1a6-4748-be78-fe73343ae96b', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 81.93, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4d24b76b-1d12-474c-aaa8-606235926770', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, 'expense', 'paid', '2025-12-19', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3e849533-28ec-456e-8f0f-0249ad4d823e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2f0acb34-551d-42b8-aa45-f1bf5925e877', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3e849533-28ec-456e-8f0f-0249ad4d823e', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 32.43, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7c75b452-a560-493c-8759-8b8a4c342d2a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f7f8536e-963c-4e3c-bcfd-ffd7f215a4eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c6b091d5-f957-4797-a338-1d88981cc846', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f7f8536e-963c-4e3c-bcfd-ffd7f215a4eb', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 59.02, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ae9ea85d-616d-4842-8e09-a3499900d76c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f34cb41-46dc-433c-a976-b2984c0a3008', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ce012295-258d-4083-8dd5-8acfe57e53a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f34cb41-46dc-433c-a976-b2984c0a3008', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 31.08, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('58884a4b-d554-449d-8ed5-a90da761d400', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c8f441fa-3a1f-42d8-bbb0-799a7ee5eced', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9835c513-b3cb-4c67-978a-bbdaa0f7a9b0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c8f441fa-3a1f-42d8-bbb0-799a7ee5eced', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 71.77, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d86ca79b-defd-4d39-9f45-6c33e3a6f346', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('50ef5791-3a5e-4835-981b-502fd69b0e9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('90eb3bfe-fe82-4abd-8488-2af94d080ba1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '50ef5791-3a5e-4835-981b-502fd69b0e9b', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 82.2, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('500d0572-b699-48e8-b442-b7a68dd4362f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 2, 12, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1e2fc79f-899b-43b3-ae89-893f224caa15', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.0, '2026-01-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d634c280-297f-4e51-91ea-9c216da28174', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1e2fc79f-899b-43b3-ae89-893f224caa15', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 15.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('23b27a14-e9d8-4c12-8f52-8ce70dcda8f9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.0, 'expense', 'paid', '2026-01-20', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('71155918-f9ff-4151-8100-197d150804a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-01-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('69cf2152-ea48-4557-b0a1-4b860a72e492', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '71155918-f9ff-4151-8100-197d150804a7', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 129.9, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('88ca4686-bc36-4dba-88f8-3113ee390d06', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-01-21', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9556d1e7-3e9d-4b37-9b3c-5e2ba50ada3f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 70.0, '2026-01-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3ac1dda4-bfd9-4cba-862c-9558d093af92', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9556d1e7-3e9d-4b37-9b3c-5e2ba50ada3f', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 70.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('87817b53-a911-4e42-9dc4-e18ea4f98fc2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 70.0, 'expense', 'paid', '2026-01-22', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3a58bf59-0518-49b9-8022-eb36d0f85951', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAITON SALGADOS', 27.5, '2026-01-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('98412eb5-8ba8-47d4-8d85-52ced9087485', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3a58bf59-0518-49b9-8022-eb36d0f85951', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 27.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a5d34522-8c30-462c-8e98-f66fe8d16f4e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAITON SALGADOS', 27.5, 'expense', 'paid', '2026-01-24', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('17265a18-6fbb-48bd-8e39-c8978cadfd76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 52.16, '2026-01-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c9f3d434-4f1b-49a6-aaa0-590703972dd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '17265a18-6fbb-48bd-8e39-c8978cadfd76', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 52.16, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ffc93e0c-29ee-4c99-8b45-a8cc41051f22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 52.16, 'expense', 'paid', '2026-01-25', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2a231f3a-a34e-43dd-baa3-4ccc3d49a73f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 25.85, '2026-01-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('83c8bfb9-db74-4e18-aa09-7ab44d2388f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2a231f3a-a34e-43dd-baa3-4ccc3d49a73f', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 25.85, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4d053ed7-18dd-4753-98d0-0b0a6d6b3a8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 25.85, 'expense', 'paid', '2026-01-26', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4c293a8a-64f7-4a7d-9a27-60369dcfa0c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 7.0, '2026-01-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0989fb7e-d9b5-4f21-82cd-9d3fab2b8512', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4c293a8a-64f7-4a7d-9a27-60369dcfa0c4', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 7.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fa65752d-7116-44ac-acfb-8fbad51b09d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 7.0, 'expense', 'paid', '2026-01-26', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3ebf351a-34dc-495f-bfa8-4417ec2849a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, '2026-01-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('054b7fe1-9fc5-4271-9a2a-09aa90dc6f09', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3ebf351a-34dc-495f-bfa8-4417ec2849a2', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 19.8, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f600ade2-444b-41f2-a39f-45c20071eb4b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, 'expense', 'paid', '2026-01-27', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f0f5155a-7a75-4bfa-83f6-85feb4ece54f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('315dcbb4-5f2c-428d-8394-f22f66d6e50f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f0f5155a-7a75-4bfa-83f6-85feb4ece54f', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 50.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4dfcbfde-332c-47b9-8bec-1c4944c0e0be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('95a4e082-169f-4ed3-9333-bb54ce2e9679', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 19.61, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b646fe17-4a57-4d18-94de-1678c3059d65', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '95a4e082-169f-4ed3-9333-bb54ce2e9679', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 19.61, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8b2250b0-4ae9-4120-8bfd-d82ae5abcccd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 19.61, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e7d608ad-6927-489e-8bd9-0452948b3746', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('80fd50bd-9ca4-4158-9007-4ac3f7bc50d5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e7d608ad-6927-489e-8bd9-0452948b3746', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 12.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0d1a5a74-c246-48ba-9a06-01c153a99016', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('506e18a6-2a92-4ba0-8f03-70645b5fd0d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.38, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d7fdbaf8-664b-4cdd-9066-26aad4350399', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '506e18a6-2a92-4ba0-8f03-70645b5fd0d8', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 8.38, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('afd6a15b-5a5b-44c2-b472-72b9b3ccecd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.38, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('188ea603-4e95-413e-ab80-1aa970b1e5f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, '2026-01-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1de5c73a-8d5f-4734-a0f6-72a943bc511c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '188ea603-4e95-413e-ab80-1aa970b1e5f7', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 19.8, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bade201e-d0b7-4af3-adc7-3292c3b960da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, 'expense', 'paid', '2026-01-29', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('67dd916e-7b7e-496c-b5c4-7d96a5a86685', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.76, '2026-01-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('582e895c-fca6-4cd1-8a37-4c3cf0de907f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '67dd916e-7b7e-496c-b5c4-7d96a5a86685', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 17.76, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('375df9d0-5ee3-42e9-be47-efd44f72bc22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.76, 'expense', 'paid', '2026-01-29', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('619a8cfe-e8b3-4a4f-b108-b242bd708936', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 24.0, '2026-01-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e58f0076-fcd1-4db8-a31c-a1e98035632f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '619a8cfe-e8b3-4a4f-b108-b242bd708936', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 24.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('79be01ad-0fe5-4d74-8e0b-25b54770cd4a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 24.0, 'expense', 'paid', '2026-01-30', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1d04af5e-711b-4549-883e-8421f0f8c254', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MARILEIAFIORIDASI', 28.5, '2026-01-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('02899e59-629d-4ef2-859f-526fcdf3aabe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1d04af5e-711b-4549-883e-8421f0f8c254', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 28.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9d7f4d55-0189-4d27-aad2-860d8320bb44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MARILEIAFIORIDASI', 28.5, 'expense', 'paid', '2026-01-31', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ed9fdc56-a053-467f-b77b-65f25085ad35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAIRTON HOLZ PORATH 0', 36.2, '2026-01-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c6b115e9-2fa6-4134-8b0a-f71406b39340', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ed9fdc56-a053-467f-b77b-65f25085ad35', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 36.2, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aa8b8800-a165-49bd-b5a2-7ecb8ee87b53', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAIRTON HOLZ PORATH 0', 36.2, 'expense', 'paid', '2026-01-31', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c4ea938a-d89d-411e-b326-de3f1b74195b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 20.48, '2026-02-09', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0af61756-9fc2-422d-b80c-6791a70a7a76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c4ea938a-d89d-411e-b326-de3f1b74195b', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 20.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('44a6b5ea-1b83-424a-935d-de1377e2dcfb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 20.48, 'expense', 'paid', '2026-02-09', '2026-02-22', '2026-02-22', '557e445f-2676-4f21-b5c1-6de47e07d654', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

COMMIT;
