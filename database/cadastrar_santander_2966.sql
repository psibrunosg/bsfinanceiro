SET client_encoding = 'UTF8';
BEGIN;

-- Limpeza prévia para garantir idempotência sem duplicações
DELETE FROM transactions WHERE account_id = 'b7a6c5d4-3210-9876-edcb-a10293847564';
DELETE FROM credit_card_installments WHERE credit_card_id = 'c8b7a6d5-4321-0987-fedc-b21304958675';
DELETE FROM credit_card_purchases WHERE credit_card_id = 'c8b7a6d5-4321-0987-fedc-b21304958675';
DELETE FROM credit_card_invoices WHERE credit_card_id = 'c8b7a6d5-4321-0987-fedc-b21304958675';

-- 1. Conta Técnica do Cartão Santander SX (Final 2966)
INSERT INTO accounts (id, workspace_id, owner_id, name, type, initial_balance, active, is_system, is_shared, created_at)
VALUES ('b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Cartão Santander SX (Final 2966)', 'credit_card', 0.00, true, false, false, NOW())
ON CONFLICT (id) DO NOTHING;

-- 2. Cartão de Crédito Santander SX (Final 2966) - Limite Atual R$ 8.210,00 (anterior R$ 5.780,00)
INSERT INTO credit_cards (id, account_id, workspace_id, owner_id, name, brand, last_four, credit_limit, limit_amount, closing_day, due_day, created_at)
VALUES ('c8b7a6d5-4321-0987-fedc-b21304958675', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Santander SX (Final 2966)', 'Visa', '2966', 8210.00, 8210.00, 15, 22, NOW())
ON CONFLICT (id) DO UPDATE SET credit_limit = 8210.00, limit_amount = 8210.00, closing_day = 15, due_day = 22;

-- ===========================================================================
-- Fatura 2025-11 (Santander - 22112025.pdf) - R$ 101.46
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('112ff0ae-a530-56f4-91ef-542e334e5ebf', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 11, 2025, '2025-11-14', '2025-11-22', 101.46, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a2900cc4-32fd-5d09-8233-dc8f4819cfc1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'PELOTENSE GESTAO DE ESTAC', 11.0, '2025-10-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('244b472b-f396-587f-a022-d867dd56aa1a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a2900cc4-32fd-5d09-8233-dc8f4819cfc1', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 11.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e157cc6c-cfea-53e8-b731-ba9082dc2904', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'PELOTENSE GESTAO DE ESTAC', 11.0, 'expense', 'paid', '2025-10-18', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('625c5dea-5b86-54f5-9a20-3e2669444246', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2025-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4ca600a0-4934-5c29-8fd3-3e8dbc96db11', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '625c5dea-5b86-54f5-9a20-3e2669444246', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 10, 312.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9112b848-02e4-563e-a32a-4f22266f7dca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2025-01-08', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 10, 12, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('80b5e257-c08a-5a1b-b5c4-7d4119e77c77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 50.0, '2025-01-08', 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6bf5f902-ed9d-54e0-a77d-18004a12f287', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '80b5e257-c08a-5a1b-b5c4-7d4119e77c77', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 10, 50.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fbe7a93a-1ae2-531e-bd02-30e91e5c4238', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 50.0, 'expense', 'paid', '2025-01-08', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 10, 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4a988a3a-2ee1-5e0b-ac0b-b6a2df69cc04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('388c0efd-ec0b-5f0d-93c7-a30f60ae1414', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4a988a3a-2ee1-5e0b-ac0b-b6a2df69cc04', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 6, 67.48, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7bd6fbd6-3f00-5fa0-9fd6-45b44f043d57', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 6, 10, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba9485b8-d9cb-5637-8ab8-888fad38a40a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, '2025-06-14', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8d98f0e6-fc01-502c-9a75-fb5f1a1622a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ba9485b8-d9cb-5637-8ab8-888fad38a40a', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 5, 74.66, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3792c3a7-4893-5354-9002-c9c49b220813', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, 'expense', 'paid', '2025-06-14', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('12523168-5bed-5898-b2b4-fc1721767eae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, '2025-06-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('69c4e4bd-8e31-56d7-b60a-1ff4d43f0a39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '12523168-5bed-5898-b2b4-fc1721767eae', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 5, 60.24, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('68d90f4f-3d69-5460-bc42-38d30f099cc6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, 'expense', 'paid', '2025-06-18', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7ee50e98-5451-57c9-a809-e344843518ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c73a9782-98de-5107-98cf-5002b9408698', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7ee50e98-5451-57c9-a809-e344843518ba', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 12.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('da868a85-77f0-5955-ac6e-cc9c97a40eca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('511796ed-9a25-5b76-8217-fe7574ddd015', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aa812601-51f8-5a84-800c-51e09a5dda01', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '511796ed-9a25-5b76-8217-fe7574ddd015', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 200.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f0488f00-14c3-5789-938d-1e49c7755399', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('780e2c6f-2e89-59fc-837b-4d9645a51994', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('29c0084c-4516-5d7d-9fb7-786c568250a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '780e2c6f-2e89-59fc-837b-4d9645a51994', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 172.17, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ff5afd5b-c148-511e-8b89-cf7dbd19382d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('968bab5f-461d-5eb9-8b65-8da0351bb4b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 60.45, '2025-09-17', 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d160437a-4a12-599e-a7f2-8f8a45ddc483', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '968bab5f-461d-5eb9-8b65-8da0351bb4b9', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 60.45, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('194c560a-ea76-5599-a5ae-79d0de66900b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 60.45, 'expense', 'paid', '2025-09-17', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0fe159e3-2b3b-5152-a5e2-ca1807c5662b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5637f688-2442-5b78-b494-a04782a91704', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0fe159e3-2b3b-5152-a5e2-ca1807c5662b', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 74.09, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('60157f3b-b5dc-503a-a2f9-c837d4f3e1a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 6, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('32b36198-a182-5d7e-b7c0-0ba9fa6eddd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, '2025-09-20', 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6692878e-09b3-506f-90b8-a020d3288a0f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '32b36198-a182-5d7e-b7c0-0ba9fa6eddd2', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 19.61, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f0854ad8-5a7d-5f6f-87cf-4eec920430a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, 'expense', 'paid', '2025-09-20', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fdcdefc0-42a7-58e0-9a7e-a68734f06004', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, '2025-09-27', 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('583d0326-5d55-598e-ab55-a8389ee5a31f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fdcdefc0-42a7-58e0-9a7e-a68734f06004', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 42.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a7aa14f4-8286-5521-9b2b-d4855e8cbbf6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, 'expense', 'paid', '2025-09-27', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('91f2202a-0b6c-5484-a667-bbe70a0a9e50', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f31248df-c965-5b3c-a55c-2147107b9927', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '91f2202a-0b6c-5484-a667-bbe70a0a9e50', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 70.17, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('af80a2fb-be2d-5b64-ae3e-8fd3166148a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c9c272c4-e7b3-5a7f-badb-1b22b0b4b379', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*UNE SUSHI LTDA', 49.55, '2025-10-06', 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('286dcc92-ba30-50e9-ba68-ebbdc4ca0091', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c9c272c4-e7b3-5a7f-badb-1b22b0b4b379', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 49.55, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5bad6c1b-32d1-52d9-90ad-72589d802efc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*UNE SUSHI LTDA', 49.55, 'expense', 'paid', '2025-10-06', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b6f586cc-2c1b-511d-b09c-ed36c8af6b2d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e98e9db9-d59c-5381-a3ad-ab3eddf6558a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b6f586cc-2c1b-511d-b09c-ed36c8af6b2d', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 130.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e4dd283a-2ed2-534c-b570-cfb6ac1bc2f4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 4, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('29ab42dd-9a57-5649-ba68-c13739e534f6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c2d4ebc1-6c79-529a-a613-a01ea7395273', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '29ab42dd-9a57-5649-ba68-c13739e534f6', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 108.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6364c44-58bd-5f8a-ad88-b9606fbc492e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 5, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('07aa2602-3ffd-5156-bc9a-9523e1722b81', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 6.9, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ea34fe6e-12c1-5308-9d4a-737b945ad27a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '07aa2602-3ffd-5156-bc9a-9523e1722b81', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 6.9, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('62595425-359e-5b4c-93e1-2748c8ccc303', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 6.9, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3ae46e66-669d-5ded-af57-0113231fb8cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 12.87, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f891dfc-3eb8-5bd5-adea-888661753cf3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3ae46e66-669d-5ded-af57-0113231fb8cb', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 12.87, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a3e396e2-e833-5f83-bd3f-2388fdc284ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 12.87, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('29445e4e-2c40-5ec4-8447-c9129fafc36a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.0, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ef4c10e2-ee1f-5522-bceb-62df59be6786', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '29445e4e-2c40-5ec4-8447-c9129fafc36a', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 30.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7c975dcf-5093-53c3-a34c-0a99281cb552', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.0, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('665ad118-7977-55d3-b999-1eb10f6efb48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM JOAQUIM', 7.5, '2025-10-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fafd24e1-6ada-5a7f-9fa4-1f5509c5aa42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '665ad118-7977-55d3-b999-1eb10f6efb48', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 7.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('140aad36-eff2-5e77-b8b7-969c4087ce78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM JOAQUIM', 7.5, 'expense', 'paid', '2025-10-20', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c8a26dae-f877-5f98-bca1-7612eb404959', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'IG*PSICOMANAGER', 89.0, '2025-10-22', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2a6c4de9-7f02-5b6a-b13c-d3d5d09c199c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c8a26dae-f877-5f98-bca1-7612eb404959', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 89.0, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('23c7a824-a8eb-5537-b811-b2435368b84c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'IG*PSICOMANAGER', 89.0, 'expense', 'paid', '2025-10-22', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cf074d97-4d5a-560b-8298-443f1f345c08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 12.5, '2025-10-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('499c4dee-d85a-5f95-9a35-ed535e34ce0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cf074d97-4d5a-560b-8298-443f1f345c08', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 12.5, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5d79e5ad-65a1-5467-9046-9d569c2cec13', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 12.5, 'expense', 'paid', '2025-10-23', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('25203035-7843-51f6-99f2-b10266d378e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 148.8, '2025-10-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e7326dbc-e109-5ffe-bf99-e68c4e0b5e0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '25203035-7843-51f6-99f2-b10266d378e2', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 148.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1951ad69-4b1d-51d1-82bf-9c91aae81274', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 148.8, 'expense', 'paid', '2025-10-24', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fcf1c0b5-321e-5a22-ae80-60d640112b74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 30.3, '2025-10-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6cef97c0-6be1-589f-84db-208014929205', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fcf1c0b5-321e-5a22-ae80-60d640112b74', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 30.3, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bb50f031-9d97-5afc-8db2-e36e4c4ce121', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 30.3, 'expense', 'paid', '2025-10-24', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8c12bec8-e7ba-5960-afd0-f356d1e4971b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 38.97, '2025-10-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f0509fe2-3503-51a7-afa5-b6af9dd33876', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8c12bec8-e7ba-5960-afd0-f356d1e4971b', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 38.97, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2060e787-a55f-5de9-b9e9-78492ae12549', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 38.97, 'expense', 'paid', '2025-10-27', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bd289b9d-ad7d-5e8d-a182-e7978f5fc774', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MADU FOODS LTDA', 55.88, '2025-10-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('da960212-6534-543f-a9a8-12408c81bc96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bd289b9d-ad7d-5e8d-a182-e7978f5fc774', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 55.88, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a0fbbdc0-4ecf-562d-92cc-3d6e415491cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MADU FOODS LTDA', 55.88, 'expense', 'paid', '2025-10-27', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e80d061a-907e-53eb-b7c0-538e972383fb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58 067 449 ANGEL GONC', 28.88, '2025-10-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3a1b2e71-e45f-5e52-9cd4-3c915f90601a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e80d061a-907e-53eb-b7c0-538e972383fb', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 28.88, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1dd4398b-13fe-50c3-aa27-3780280cdac7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58 067 449 ANGEL GONC', 28.88, 'expense', 'paid', '2025-10-28', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('625f0537-7192-5c3e-a8db-923482580f09', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 26.8, '2025-10-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('44d49603-78a4-5031-b77e-0f66535cb991', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '625f0537-7192-5c3e-a8db-923482580f09', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 26.8, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4b880b53-1451-597c-8bd9-7cc6baef56f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MK CHAFARIZ', 26.8, 'expense', 'paid', '2025-10-31', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9624ca90-8550-509a-a1f3-6c62b32cef12', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 39.98, '2025-11-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b43143de-977f-5c31-983f-e41a6c5bd97c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9624ca90-8550-509a-a1f3-6c62b32cef12', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 39.98, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('63a75967-0c38-5b4e-b4d1-339b129fa7ae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*N1 E GRINGO PELOTAS L', 39.98, 'expense', 'paid', '2025-11-02', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7a1adf3d-f078-5a5b-9f97-d8537fe5da4b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*LOTUS COMERCIO DE ALI', 27.52, '2025-11-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4ee55eb1-eec9-5967-a4e4-0608577364e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7a1adf3d-f078-5a5b-9f97-d8537fe5da4b', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 27.52, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bd5737aa-8df3-5825-9230-333ae0db1628', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*LOTUS COMERCIO DE ALI', 27.52, 'expense', 'paid', '2025-11-03', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('96f5af4a-f26a-5b39-9664-9ac5f552bb71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*ALTAIR SILVA SERVICOS', 28.33, '2025-11-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('64acaea9-0cd1-5a89-b439-15b300796e3a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '96f5af4a-f26a-5b39-9664-9ac5f552bb71', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 28.33, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9c496729-ea9c-50ea-9854-305d774aeb88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*ALTAIR SILVA SERVICOS', 28.33, 'expense', 'paid', '2025-11-04', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5af10910-9393-5aa3-8fb0-30671a83054b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, '2025-11-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2aea30c3-326b-5655-88de-bde92e5fb520', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5af10910-9393-5aa3-8fb0-30671a83054b', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 7.95, '2025-11-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('66f07a8f-6085-5cdf-b226-75f885656341', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, 'expense', 'paid', '2025-11-12', '2025-11-22', '2025-11-22', '112ff0ae-a530-56f4-91ef-542e334e5ebf', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 11/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-12 (Santander - 22122025.pdf) - R$ 1553.42
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c34550b8-bcd6-5251-907e-26fa72185b4f', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 12, 2025, '2025-12-15', '2025-12-22', 1553.42, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6a8cf56e-f3f3-5391-9d05-f0b6155f92d1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('67a79d2f-7537-5d0e-a00e-9f5e6074117b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6a8cf56e-f3f3-5391-9d05-f0b6155f92d1', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 204.61, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3333e550-9c06-5b58-9cc8-5243027d7b6f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 3, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7958ff97-ed24-5747-af10-6541ec96b7d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 9.57, '2025-11-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('68f747f9-06ab-5866-bb4a-999c684ead59', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7958ff97-ed24-5747-af10-6541ec96b7d2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 9.57, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6aa37e75-063f-5dcc-b31b-adcb4732791c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 9.57, 'expense', 'paid', '2025-11-27', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('99cf65ae-df4a-5f63-9ed7-7d11ae61cb91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 121.87, '2025-11-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('10716ec2-2f28-5c81-903b-3b6f6b48b8db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '99cf65ae-df4a-5f63-9ed7-7d11ae61cb91', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 121.87, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('126704f9-0f6b-5774-81fe-8d661673cc00', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 121.87, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8aeab21d-9315-5215-a25f-7f6ff042fea9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, '2025-12-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c7e5098f-c6dd-541d-9b14-81deebb85dc3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8aeab21d-9315-5215-a25f-7f6ff042fea9', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 12.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9d49fc77-45e9-5911-a1c2-48ae853826a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, 'expense', 'paid', '2025-12-03', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ad8e3c3b-93ca-5f53-a13d-8a25e624ad30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 4.19, '2025-12-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fe2d3225-a564-51ef-8857-134d1cb6481c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ad8e3c3b-93ca-5f53-a13d-8a25e624ad30', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 4.19, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('11461d7e-2dd2-5131-9795-c5cb7bbf6680', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 4.19, 'expense', 'paid', '2025-12-03', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('85f638c5-a198-5783-b274-1942b1b51cd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: MP*COSTELLONE', 120.0, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e85e106d-3100-5468-93f2-c1091db7958c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '85f638c5-a198-5783-b274-1942b1b51cd2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, -120.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9aa8c2fe-836f-5f5e-bb12-92fc6e774756', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: MP*COSTELLONE', 120.0, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3684d82a-7b96-5945-a722-568240062ed9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: GAU COZINHA GAUCHA', 222.0, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('35c8a735-d9c3-5af8-b837-4babc3882da8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3684d82a-7b96-5945-a722-568240062ed9', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, -222.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3872c66d-a0d4-5a8f-a36c-9362d3276f6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: GAU COZINHA GAUCHA', 222.0, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2c46b2cc-1893-5589-8896-3607e8725c8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: BAGAGGIO 358 PELOTAS', 199.9, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b41ae867-bafe-5f99-a063-6995af2484b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2c46b2cc-1893-5589-8896-3607e8725c8f', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, -199.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('36a69b37-2f1d-5f78-bceb-cdb7573a354b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: BAGAGGIO 358 PELOTAS', 199.9, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d6bda377-2eb5-552b-ae05-a370f472eb93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: FARIA GASTRONOMIA LTDA', 95.9, '2025-12-07', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2c5d6656-fc45-5488-b517-3817d654a88a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd6bda377-2eb5-552b-ae05-a370f472eb93', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, -95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ec51d732-c1ec-584f-b276-f02d28d3ae1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: FARIA GASTRONOMIA LTDA', 95.9, 'income', 'paid', '2025-12-07', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f031d66-6300-5f21-9456-71020a0404de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2025-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b07ee9e0-66a5-5e02-9871-9e9c512b402b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f031d66-6300-5f21-9456-71020a0404de', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 11, 312.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f2e8ec61-06ed-5851-9ae6-1aebdb6f32af', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2025-01-08', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 11, 12, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2cb68a0a-59c0-5876-9e01-845504c407c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7ac4c52c-642d-5014-898c-25911ad36581', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2cb68a0a-59c0-5876-9e01-845504c407c0', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 7, 67.48, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d14bbcd7-3f05-5f13-a1aa-8ab631f078cf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 7, 10, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('400178b3-06c2-5a28-83ea-c268b73de61a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, '2025-06-14', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('68b723cb-4ada-55ef-ae9f-38f63e69e3c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '400178b3-06c2-5a28-83ea-c268b73de61a', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 6, 74.66, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ca26bcdd-5e6d-5c13-91d2-705cb3e3fc7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'COGNITI*ACORDODEMENSA', 74.66, 'expense', 'paid', '2025-06-14', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2a36ce1b-b878-5807-a376-d429591144d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, '2025-06-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e2407bad-e73b-5d31-8937-3c3453e33f10', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2a36ce1b-b878-5807-a376-d429591144d2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 6, 60.24, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e7a60f51-f772-55fb-96ac-b6760c5cf8a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'UNE SUSHI - PELOTAS', 60.24, 'expense', 'paid', '2025-06-18', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7d9adf15-0d33-50ec-a73e-44650285544d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('459a6e3d-1792-5e4c-a21d-8da913eb5d99', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7d9adf15-0d33-50ec-a73e-44650285544d', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 12.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('923564d3-2c50-594d-9fe1-a04b22dc6773', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9379c6d4-8e28-5779-82fa-7131f3052044', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c9bdefaa-800d-5d2c-841f-c8572484ec8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9379c6d4-8e28-5779-82fa-7131f3052044', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 200.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8e707ca3-08a5-5a8d-b3c5-73fbf9855443', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac568dc8-b5a7-5897-ba29-55dbd73a69c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('06950975-f6c1-574a-bf2a-ce00e699c364', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ac568dc8-b5a7-5897-ba29-55dbd73a69c4', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 172.17, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d4bd48af-6791-55bf-9584-626ca0182efa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d91acfa0-8eac-5492-a9de-58543857514b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e41b28fc-9172-56f7-a096-8d4bcf7357ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd91acfa0-8eac-5492-a9de-58543857514b', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 74.09, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a8dd07dd-ae04-56c3-8b1d-0e3d3c71721f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 6, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5a52165d-23bd-5ad6-8bca-7c8630ca97b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, '2025-09-20', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2ce2d836-4b75-5ef5-84aa-24189bf7fcaf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5a52165d-23bd-5ad6-8bca-7c8630ca97b7', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 19.61, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d9a46401-7088-56ae-8586-fac040f984b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 19.61, 'expense', 'paid', '2025-09-20', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9b610d2f-04d2-5e23-a221-ec05a224d9e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, '2025-09-27', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7c2bf4dc-8acc-5091-98fd-0f6e6d5d8053', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9b610d2f-04d2-5e23-a221-ec05a224d9e4', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 42.8, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6473ad46-d96e-562f-bed5-53d5393a2dd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDUARDO CARDOSO HOMSI', 42.8, 'expense', 'paid', '2025-09-27', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9725790e-a253-5164-8138-a9bd7329f57d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0ba5b8e8-33c0-5b37-8899-922e445fbeb7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9725790e-a253-5164-8138-a9bd7329f57d', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 70.17, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cdd65bb9-a772-5046-9a69-8f4f4fab7d93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 3, 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('83560c61-751d-5a32-9f5b-d09bbd7a30a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e7a8a9dc-1e46-5f38-a2df-fdfa8fef3d01', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '83560c61-751d-5a32-9f5b-d09bbd7a30a5', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 2, 130.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('34bca19d-3736-5687-8fce-59ad90fdc7b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 2, 4, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bc76e60b-61d9-5879-aec4-a8f516708c95', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c3f94df6-47fb-57da-ae55-d171f2ee1d4a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bc76e60b-61d9-5879-aec4-a8f516708c95', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 2, 108.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3d57068-e64d-5221-9807-ca7ec09e5051', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 2, 5, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f2947087-9538-5148-929d-ac4943100d3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6e9a6616-b1d7-58b2-afe2-3429b2648c88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f2947087-9538-5148-929d-ac4943100d3b', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 71.87, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('106bfecd-3341-5639-8322-0982ce346b6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('76d60b3d-3c63-575b-b5cf-6b08d01535ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c7f23fc5-4b90-5959-8460-7cbf85d0038f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '76d60b3d-3c63-575b-b5cf-6b08d01535ff', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 116.88, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('752b1457-6676-5364-984c-c39046e3f827', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('53dd790b-2ffb-5b4b-ace1-70b914161af8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39184c3f-32a9-5d5e-80a9-058ece1a9c43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '53dd790b-2ffb-5b4b-ace1-70b914161af8', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 50.49, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43ba0d42-65c5-5d4a-a728-9d06fe3cf785', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('84606070-ccb8-560e-a5c7-48652329a1d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, '2025-11-30', 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c947fd9b-c539-5f35-bd02-1dc1c3fd9872', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '84606070-ccb8-560e-a5c7-48652329a1d2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 63.18, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('51ba1def-52c5-522d-aaaf-77ee0bfccb84', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b70df5f5-ce8e-5053-824e-d682378367c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CIRCULUS LANCHES', 38.9, '2025-11-13', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e341afca-19e2-5ce1-aed1-5484473a24e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b70df5f5-ce8e-5053-824e-d682378367c4', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 38.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9003f7ed-db62-53ba-a92d-ba580fe12077', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CIRCULUS LANCHES', 38.9, 'expense', 'paid', '2025-11-13', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2dfcabb6-e905-5223-8589-14de7635bb47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, '2025-11-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9d261845-1133-57e3-af33-13158edb1bf3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2dfcabb6-e905-5223-8589-14de7635bb47', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 5.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('96683c14-0b46-506c-a273-ed5f88e6de62', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, 'expense', 'paid', '2025-11-14', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('92e1b854-16e3-5c19-8403-98e7131c33c9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*VINICIUS AFFONSO FARI', 27.98, '2025-11-16', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('04ccfd7e-7bc7-5fe4-8cad-d68082f52937', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '92e1b854-16e3-5c19-8403-98e7131c33c9', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 27.98, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f95788c5-1c3e-52ed-94d6-778c7b4d3e00', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*VINICIUS AFFONSO FARI', 27.98, 'expense', 'paid', '2025-11-16', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('73a84d51-a701-53d8-9528-a55152672114', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2025-11-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f646301b-aa9a-52e9-b550-26eedf75034b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '73a84d51-a701-53d8-9528-a55152672114', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5d22e3db-1fa7-590d-8be1-4c4be73ddbab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2025-11-22', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('365ed43c-0c5a-5eac-b074-65b285a502a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MICHELE CESAR RODRIGU', 66.29, '2025-11-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b070c2bf-3e64-5480-9cd8-56d029dd986c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '365ed43c-0c5a-5eac-b074-65b285a502a7', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 66.29, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4bb4d1f7-0f24-52dc-8b72-46614abcd830', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*MICHELE CESAR RODRIGU', 66.29, 'expense', 'paid', '2025-11-22', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dde60469-bcb6-5a0c-be2e-d23cc9a372f9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAAP, MARTINS E CIA RE', 16.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('77a30130-d030-5831-a4a6-09b467ec5111', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dde60469-bcb6-5a0c-be2e-d23cc9a372f9', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 16.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0c91fdef-acd9-55e7-9f76-01606a49cde4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAAP, MARTINS E CIA RE', 16.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1d7f911c-187c-5708-9f61-b9a95213382a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LOJAS AMERICANAS 427', 95.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dedd4a82-3333-5e54-b372-876ab97b8cee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1d7f911c-187c-5708-9f61-b9a95213382a', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e4934f61-45d9-519c-b901-bcfd1d61ca96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LOJAS AMERICANAS 427', 95.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2b2dce4e-97d4-57e4-aa22-d724de14459f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 199.9, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('62bc6980-0e02-5102-9b2e-bd18ce276fe5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2b2dce4e-97d4-57e4-aa22-d724de14459f', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 199.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('85b369db-4ba2-55cb-a74a-2b04fc6b524e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 199.9, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ae212758-9934-52f8-aaa2-6758ed7df4a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FILIAL 321', 30.0, '2025-11-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5d01f19e-9992-5b8d-86e5-8e31efaba9b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ae212758-9934-52f8-aaa2-6758ed7df4a0', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f3536f1f-4244-57d4-9c05-d1f7b95458e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FILIAL 321', 30.0, 'expense', 'paid', '2025-11-23', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('df6031fc-5144-5ae2-bf9e-053cd24fda71', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 11.52, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ac62a1f4-1a68-5011-904c-505d9ea4989d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'df6031fc-5144-5ae2-bf9e-053cd24fda71', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 11.52, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2a81cfa0-be45-5618-b0f4-1e98be25b3f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 11.52, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7e532b33-e172-5a6e-a4e7-e8c7ad5149a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('25aef850-9ba7-5d4d-bd06-1fa6df5f82e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7e532b33-e172-5a6e-a4e7-e8c7ad5149a5', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1f18aa1b-257f-5bd0-8862-ca1d4fb94d9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e976971f-14e5-55a3-8f8b-9fa980897969', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PASTELARIAPONTAL', 39.0, '2025-11-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2f9ddc9b-600e-5fce-9724-6c7d8361f302', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e976971f-14e5-55a3-8f8b-9fa980897969', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 39.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('32a0b35a-56c8-5982-a326-3909b4452cba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PASTELARIAPONTAL', 39.0, 'expense', 'paid', '2025-11-24', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a7fc7944-b6ec-5dc0-8dae-0886a682952f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'UBER * PENDING', 13.15, '2025-11-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a2636259-903f-5988-8b04-5e4f2ff07b59', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a7fc7944-b6ec-5dc0-8dae-0886a682952f', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 13.15, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1ace52e2-1ee3-55f4-8405-f07d92d0275f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'UBER * PENDING', 13.15, 'expense', 'paid', '2025-11-25', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c5e96fe5-da00-544b-b5c7-0eb34a8bc595', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'SEM PARAR', 30.0, '2025-11-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b22ed200-a109-5c76-8ecd-1879989ec9a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c5e96fe5-da00-544b-b5c7-0eb34a8bc595', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 30.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5306a800-dd1a-5551-8a45-ee186fb554fa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'SEM PARAR', 30.0, 'expense', 'paid', '2025-11-25', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('92261bca-3b6a-53aa-9a43-2f2da778953c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 91.0, '2025-11-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7c2cf144-f1a4-549e-89e2-53888c586120', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '92261bca-3b6a-53aa-9a43-2f2da778953c', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 91.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('260dc0fb-f1ef-5e6c-8f00-54f02e44df3c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 91.0, 'expense', 'paid', '2025-11-26', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('18b2ac31-5792-537b-adf2-4d65cbcdfaa2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2025-11-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9441af03-49d0-5778-9d67-fef6f446747b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '18b2ac31-5792-537b-adf2-4d65cbcdfaa2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 10.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6d763d4-3dd5-5f33-a700-a2ab21b3238c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2025-11-26', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('82b3f598-93e9-5a08-a763-535e97962ca5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'VIA MAIS REDE DE POSTO', 10.98, '2025-11-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('52c91fcb-c859-59e6-9c4e-4bba19dd341b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '82b3f598-93e9-5a08-a763-535e97962ca5', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 10.98, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dc95731e-5f63-51d0-ba43-667177fdc5de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'VIA MAIS REDE DE POSTO', 10.98, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('616cc125-ca59-5e89-89df-7b01e9e31c70', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SCHIMITZ RESTAURANTE', 58.0, '2025-11-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ec24112c-868b-5917-9a8d-b0f3ec9c5188', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '616cc125-ca59-5e89-89df-7b01e9e31c70', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 58.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6c095bf9-2331-5673-8951-5c79822e8dee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SCHIMITZ RESTAURANTE', 58.0, 'expense', 'paid', '2025-11-28', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7966d42b-2570-5d09-b045-5cf128d5081e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 222.0, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('70474a0e-4791-55af-b778-2e96c9995bd5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7966d42b-2570-5d09-b045-5cf128d5081e', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 222.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d469f054-3d32-5c6b-bee0-48b23b69c15f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 222.0, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('28b251ca-b1fd-58ef-98f3-da1f52c5e3c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CACAU SERVICOS DE GAST', 69.16, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('44bbf5f3-2048-5af9-b1d4-775eedfd6659', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '28b251ca-b1fd-58ef-98f3-da1f52c5e3c8', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 69.16, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('623f7868-6761-560f-83bc-c9e3dcee13e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CACAU SERVICOS DE GAST', 69.16, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('73f68e97-b755-5d5d-a46b-1d8eb61bbdd3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LA FAMILLE DE GAZON', 32.0, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f0b23fd2-060f-5912-8d7e-c112c788a7e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '73f68e97-b755-5d5d-a46b-1d8eb61bbdd3', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 32.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('38b08121-69e9-5ebf-974a-87431248786d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LA FAMILLE DE GAZON', 32.0, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ff025298-f773-50dd-a4e3-b96415234653', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 95.9, '2025-11-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e6d52131-f662-5920-925b-69153be65d73', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ff025298-f773-50dd-a4e3-b96415234653', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 95.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5ac78b1f-c917-5040-9475-2bceb5ccd672', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 95.9, 'expense', 'paid', '2025-11-29', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0e0ab2fe-b5fd-5afc-8d87-12fd251a89a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SEVERO GARAGE', 50.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('63aeb0c4-9cf7-5baf-9f87-413948216ce9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0e0ab2fe-b5fd-5afc-8d87-12fd251a89a2', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b3a0d84a-9ca6-5b29-bfaa-3338bfe99831', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SEVERO GARAGE', 50.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('31718c6d-f38d-5306-b0c2-9ccda50d354a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 50.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f2f03732-7fb5-553e-93c0-64a8192b8b89', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '31718c6d-f38d-5306-b0c2-9ccda50d354a', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 50.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('610de91d-3b06-56a0-8805-50b4dbed2395', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 50.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4c372e65-5b83-5592-a4ab-b41626f86c56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 120.0, '2025-11-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5dd9a336-0ac7-530d-838a-8877adca724a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4c372e65-5b83-5592-a4ab-b41626f86c56', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 120.0, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fe669c80-c750-5933-b666-e38c7561de9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 120.0, 'expense', 'paid', '2025-11-30', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f77e7d07-2096-5a51-8b9a-5ed112b4f2a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 30.27, '2025-12-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2157af29-3fb4-5b50-912b-04b4cecd6daf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f77e7d07-2096-5a51-8b9a-5ed112b4f2a0', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 30.27, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8afe0f9c-29e9-59f4-adf2-fb163331fd7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 30.27, 'expense', 'paid', '2025-12-01', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e2955ec7-4554-5992-b491-4f4165c97afd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, '2025-12-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3ba7ac56-b369-542c-b0ad-e57d6708ecf9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e2955ec7-4554-5992-b491-4f4165c97afd', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 9.5, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3a136165-8f2f-5e5f-aa82-a3de67f8abd4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, 'expense', 'paid', '2025-12-04', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('48d36f58-891d-5cdf-835a-b4b29462e29e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, '2025-12-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('16d6a3a4-463a-5aba-9e78-d27e6614be0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '48d36f58-891d-5cdf-835a-b4b29462e29e', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 39.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ed25f438-a33d-5ecf-b8ea-05b16bb5b6a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, 'expense', 'paid', '2025-12-05', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ef406a5d-3de0-5a7f-b9a5-fe72c46e93f4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 29.9, '2025-12-09', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fa298fd6-4e32-53b2-9182-655984c8a153', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ef406a5d-3de0-5a7f-b9a5-fe72c46e93f4', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 29.9, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e89b2d08-61f1-5916-93f5-0d5891a62427', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 29.9, 'expense', 'paid', '2025-12-09', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7a538176-586b-5ad8-8211-c6219f85dfd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, '2025-12-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c341bb28-91a9-59d4-8ddd-0a78357bc18e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7a538176-586b-5ad8-8211-c6219f85dfd1', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 7.95, '2025-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9fba4e2a-49bc-50a1-8267-090a9038ddef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD CLUB', 7.95, 'expense', 'paid', '2025-12-12', '2025-12-22', '2025-12-22', 'c34550b8-bcd6-5251-907e-26fa72185b4f', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 12/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-03 (Santander -  22032026.pdf) - R$ 1832.63
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 3, 2026, '2026-03-16', '2026-03-22', 1832.63, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f016da14-c727-5d3b-ac52-0b4310c7e573', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d3467ec3-c922-5998-9b02-5e0944d0856a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f016da14-c727-5d3b-ac52-0b4310c7e573', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 326.43, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('35d9b81b-0537-52f9-a60e-65a0a4605d39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 5, 'Cartão Santander SX (Final 2966) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cf73ff84-5e73-5793-b0f4-79aca273fdc1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b1807edc-7a6b-5ca7-8987-866c0c9495b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cf73ff84-5e73-5793-b0f4-79aca273fdc1', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 2, 120.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f06b1561-e8ab-53ab-804c-23557fc310c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 2, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7fa2bbec-5a7e-5481-9c14-2090f9b58ec1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.34, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('09ad7f40-84de-5e5a-9041-4a8444721755', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7fa2bbec-5a7e-5481-9c14-2090f9b58ec1', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 233.34, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d1b0f092-ee69-553a-8992-a4ac7d604a92', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.34, 'expense', 'paid', '2026-02-11', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e85316dd-3c0c-5610-a3d6-58f6e72f24c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: SHOPEE *RSAUTOPECAS', 0.04, '2026-01-13', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('25fb8e94-fa15-5864-948d-fdb6bada619a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e85316dd-3c0c-5610-a3d6-58f6e72f24c2', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, -0.04, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b8fa875d-4333-52d2-a375-37feec3a21c8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: SHOPEE *RSAUTOPECAS', 0.04, 'income', 'paid', '2026-01-13', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dd86e0ec-2dad-54e3-a937-45cc42168f56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a5170e7d-9cd6-5c3a-8496-658e750b31c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dd86e0ec-2dad-54e3-a937-45cc42168f56', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 10, 67.48, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bc6c3139-6a92-59cf-9f46-ee2dae251f86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 10, 10, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8ef5b51e-4eeb-5a64-aac5-83f0b7a2460c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('32dd2028-bbe6-5503-9ef4-e1cec9db3601', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8ef5b51e-4eeb-5a64-aac5-83f0b7a2460c', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 6, 74.09, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43c12e55-9df0-592a-84ec-2ece07fef528', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('54194ade-0b45-5a70-a671-9938efe7ee1f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('18bacb8f-55cc-5fcb-8b8f-9c47cf14f982', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '54194ade-0b45-5a70-a671-9938efe7ee1f', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 5, 108.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2860616b-9293-55df-b985-7d321e1fd730', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 5, 5, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b89d7a47-92a2-5342-8b0c-db0aced2830e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f7ef5d1e-c077-5748-a455-b9a5e3b3e18a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b89d7a47-92a2-5342-8b0c-db0aced2830e', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 42.48, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('11ce1e37-d9ac-517c-926d-1552f76cf8c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f9154296-5114-5009-bf67-900a130fc40d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c8e60560-9fc2-5005-8544-c8a4a6e7025c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f9154296-5114-5009-bf67-900a130fc40d', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 42.19, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('133c2388-9a70-5ca7-8327-4118c8b4ffcf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4513bb9a-0ddd-5282-9596-7207b60e85e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ac63cb5e-9098-54c0-93ae-0adcdbc05beb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4513bb9a-0ddd-5282-9596-7207b60e85e3', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 32.43, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('573b4dc0-c4a9-5a46-a7e8-ec04032a509e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5a5377f0-9325-5004-a2a9-ad818c4924c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3eef8f74-bf79-5039-b3cd-48b211ed5664', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5a5377f0-9325-5004-a2a9-ad818c4924c5', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 59.02, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6f3bdd2-ec78-5491-93bd-908701304fb5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0ce9b5f3-bd7e-5b0b-a4dc-e87e1e0ff24e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bd2fa89c-390a-570d-910a-1ad91ec25e8c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0ce9b5f3-bd7e-5b0b-a4dc-e87e1e0ff24e', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 31.08, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('85931e6f-d848-5a82-a026-54b8d15521de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('63177309-9e14-5ae3-8ad3-3400d8c66c11', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c67ce621-d28a-5789-bb31-97bdd1287aa0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '63177309-9e14-5ae3-8ad3-3400d8c66c11', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 71.77, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1767da41-bd8e-5b9a-82d3-e1c71f7118c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0e725b05-3ef1-53da-b3fe-cf4c4c81e9e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bcba4cb1-f39d-59e0-a035-804ff6876a3a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0e725b05-3ef1-53da-b3fe-cf4c4c81e9e9', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 82.2, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('820d03d7-8f15-5fef-8562-19cb3491a646', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 3, 12, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b47b438c-52ea-5c5d-ab5b-1ee6ef4cfb45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.28, '2026-02-21', 2, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8326a14c-6919-50ad-9e5f-53f6b784f247', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b47b438c-52ea-5c5d-ab5b-1ee6ef4cfb45', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 42.28, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8f68bf1e-6b26-5c84-868e-ed7542a11d29', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.28, 'expense', 'paid', '2026-02-21', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3b6db6a3-ac8f-5d58-996a-3f667012a101', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-02-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0ec56e13-0558-58f9-bd48-5e23bdfbd07f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3b6db6a3-ac8f-5d58-996a-3f667012a101', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 7.95, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cce1ae45-f09a-5b61-8eb5-b02f8eb8d309', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-02-12', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1e7b5af4-11ca-5e7e-ae14-d232f748c348', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLECOMBILL', 5.9, '2026-02-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6c7e21fe-64dd-547a-8d0e-e7a9af881089', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1e7b5af4-11ca-5e7e-ae14-d232f748c348', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 5.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ba4e8404-2a1e-57ef-babc-9e90ef27ced5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLECOMBILL', 5.9, 'expense', 'paid', '2026-02-20', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b2e9aada-57fc-556c-aab5-80b2e1a7cfc7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-02-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('66c8537c-918f-511a-92dd-0ea6f52da7da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b2e9aada-57fc-556c-aab5-80b2e1a7cfc7', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 129.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6532e25d-f459-5bac-88f3-ee68750a24e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-02-21', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('60de02c5-35aa-5a26-b749-b31c6899ced2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('91af921b-a443-5fb3-9ec8-c0bed8eeb755', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '60de02c5-35aa-5a26-b749-b31c6899ced2', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 30.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a9de4479-d212-50db-8b83-30a37970ab5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('91312a0b-0866-5994-a024-d5356a44496b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 73.0, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('768542ca-4a18-584d-8ecf-b196a43d11d6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '91312a0b-0866-5994-a024-d5356a44496b', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 73.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1cb7c763-2e14-59e9-8287-618daa1ae6ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MAURICIO SILVEIRA AVILA L', 73.0, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6fdf4eb8-c97a-5203-aad0-13b1d30a8e25', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*61 756 681 GILNEI NUN', 21.98, '2026-02-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('733d64ac-e234-5340-8db9-795d8f0b3db8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6fdf4eb8-c97a-5203-aad0-13b1d30a8e25', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 21.98, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ede99bf-4ace-599a-b06b-8a939764a38d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*61 756 681 GILNEI NUN', 21.98, 'expense', 'paid', '2026-02-23', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('39fa9293-cbb6-5910-8423-c64bb34ea10a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 12.0, '2026-02-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('398a5663-d161-5918-9230-bac822947693', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '39fa9293-cbb6-5910-8423-c64bb34ea10a', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('25bf2217-4cd5-5422-8cff-d841be18d614', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 12.0, 'expense', 'paid', '2026-02-24', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7122ef9a-6607-5696-9069-58a27e22c657', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 27.99, '2026-02-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5876c89-155f-50d7-95fa-b0dea447cb6b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7122ef9a-6607-5696-9069-58a27e22c657', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 27.99, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5cd77fa6-0606-58c3-8a34-da14a7016d47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 27.99, 'expense', 'paid', '2026-02-24', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba1982b6-7aa1-5a49-897b-01937a601579', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'A POPULAR PADARIA', 11.8, '2026-02-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('93bd65ad-54df-56ed-9f8c-b0214e811df3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ba1982b6-7aa1-5a49-897b-01937a601579', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 11.8, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9ff13ead-9d14-5007-891c-feb43b57c3a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'A POPULAR PADARIA', 11.8, 'expense', 'paid', '2026-02-25', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2d80c258-8b26-5418-8274-4f0dcd155b94', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'FARMACIA SAO JOAO', 16.9, '2026-02-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fa3924a0-8796-52b7-86e4-0c237c0215e1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2d80c258-8b26-5418-8274-4f0dcd155b94', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 16.9, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3d01996e-c19d-5bad-94f5-f56c9a315b95', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'FARMACIA SAO JOAO', 16.9, 'expense', 'paid', '2026-02-27', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('53663bb7-d970-5841-bd67-9a1167448691', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JVBEBIDASE', 21.98, '2026-02-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('65e08108-c0c6-5734-8497-cc1c027f54ec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '53663bb7-d970-5841-bd67-9a1167448691', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 21.98, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5801982d-e0f5-5179-a167-561505e50c2f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JVBEBIDASE', 21.98, 'expense', 'paid', '2026-02-27', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5a17881b-c007-51ff-af79-039eb1c71525', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 18.35, '2026-02-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d73c9648-4935-5686-abac-c1a293d305a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5a17881b-c007-51ff-af79-039eb1c71525', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 18.35, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3fa0be34-1b70-530d-b943-91f086420228', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 18.35, 'expense', 'paid', '2026-02-28', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ff035eab-9125-5621-ad4b-c621d3bc218a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 29.8, '2026-03-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('925df892-551c-5ad3-8cfe-6b55a13a4a47', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ff035eab-9125-5621-ad4b-c621d3bc218a', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 29.8, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4c95bd3a-a3f9-5dfe-a462-c538faf7bede', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 29.8, 'expense', 'paid', '2026-03-01', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fb5974a2-7054-5e41-a46e-3a8424d4d2f4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.64, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6ad0555b-236d-529d-937d-5acc1d54a06d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fb5974a2-7054-5e41-a46e-3a8424d4d2f4', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 17.64, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('65e139d8-ce8a-5998-8cc2-8582ea7e1c80', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.64, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c0f1904f-ee39-5ef6-81dd-aa58496d502f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5c6a398-bf98-5ce3-88e9-685cdc2358ee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0f1904f-ee39-5ef6-81dd-aa58496d502f', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cdfe19e6-955d-5421-a44d-bda74034edee', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0f6e060e-9eaa-5e5a-a817-d02b57e9cb78', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f6e672cf-7cf5-5326-baa2-8b13ae674f3b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0f6e060e-9eaa-5e5a-a817-d02b57e9cb78', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 30.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('29e8ebe6-36c5-59af-a08e-c82d4f1925e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e015c9c6-3d86-5fe7-9724-00e3e897a905', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 4.49, '2026-03-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('729898b6-a93e-5753-824c-6029b62efe03', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e015c9c6-3d86-5fe7-9724-00e3e897a905', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 4.49, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2964456a-1ad0-534a-979c-0a6d1532d08c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 4.49, 'expense', 'paid', '2026-03-02', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9873421c-4a64-55d7-940d-19f5879317cf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.21, '2026-03-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39a65280-aaf5-5179-842c-5024ce1bebeb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9873421c-4a64-55d7-940d-19f5879317cf', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 8.21, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9faee1b7-6c26-55d6-95b1-8142e5a519e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.21, 'expense', 'paid', '2026-03-03', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6c969efb-4104-53ef-97ae-bd525e67b6a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, '2026-03-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8cecd9db-7929-5aff-b813-e6b2edfd2129', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6c969efb-4104-53ef-97ae-bd525e67b6a4', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 12.0, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6e3b8615-122a-5d4b-b3ca-acda5301f2a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 12.0, 'expense', 'paid', '2026-03-03', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4605784b-5c61-5ea9-83bc-015e3eb578f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-03-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('742be04c-a108-5f7d-8dfc-1954f4e54d04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4605784b-5c61-5ea9-83bc-015e3eb578f5', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 7.95, '2026-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3c3cefa1-fc7e-5402-888d-6777b3cec00a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-03-12', '2026-03-22', '2026-03-22', 'c0f05c8d-b24b-5815-8a3b-e8894d1998b3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 03/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-04 (Santander -  22042026.pdf) - R$ 1722.04
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 4, 2026, '2026-04-14', '2026-04-22', 1722.04, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a704bdc6-734c-58d1-9b60-f02ef689ed3f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('39ca622a-e1ea-55f3-ae25-974dab8043d4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a704bdc6-734c-58d1-9b60-f02ef689ed3f', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 4, 326.43, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e8d22adc-85ec-5bb1-b444-e0c30669cce3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 4, 5, 'Cartão Santander SX (Final 2966) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('997ccfbe-4893-54c7-8f00-5198a97dbf8c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7680beb7-a45b-57ba-995d-b2639ee6f7bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '997ccfbe-4893-54c7-8f00-5198a97dbf8c', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 3, 120.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e0cd0b8d-343f-5722-b8af-4711329b21c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 3, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a44cca15-dea4-557b-82ab-13847e461af6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('db3815af-9654-5d45-90df-19d33e24f9f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a44cca15-dea4-557b-82ab-13847e461af6', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 2, 233.33, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43671c2e-7707-5166-b603-fb282710f35d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, 'expense', 'paid', '2026-02-11', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fd8d7c6e-7eb9-5124-bdc9-7a5cc40cb23a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8f632100-9c81-5b9b-8164-54c68244ebba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fd8d7c6e-7eb9-5124-bdc9-7a5cc40cb23a', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 362.0, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ba73983d-2229-510d-af4d-3663d6ed4b1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, 'expense', 'paid', '2026-03-19', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6e09ee4b-6288-534f-89d5-0e7b2fdbaf7b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.51, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7a8f047c-ee1b-5ad5-a482-be10152cdeb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e09ee4b-6288-534f-89d5-0e7b2fdbaf7b', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 288.51, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6c1bfd5a-5120-507b-82e8-99bda94e24aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.51, 'expense', 'paid', '2026-03-19', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('54ba016c-b50e-5cd7-8f55-4a76ea9b7500', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('91cecfce-632f-56de-a1c8-604447f0ff4a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '54ba016c-b50e-5cd7-8f55-4a76ea9b7500', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 4, 82.18, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8f593d2a-f9bc-5cfa-8570-acd16d5b56a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 4, 12, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e4a8bd27-507f-5a2d-850e-4ae4e08bf1fc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.27, '2026-02-21', 2, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c5dccd97-9749-51b7-9a62-e022766c2aaa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e4a8bd27-507f-5a2d-850e-4ae4e08bf1fc', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 2, 42.27, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('edefd28e-6c4a-54e4-a2af-841b28e6a8bb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RAFAEL CARVA', 42.27, 'expense', 'paid', '2026-02-21', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bd3e9389-be45-5fe5-8e5e-8ff596482779', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2174b3eb-4d10-59de-88ec-44aee8f986f5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bd3e9389-be45-5fe5-8e5e-8ff596482779', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 37.48, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('56261c45-0f73-5624-b2a3-5f86b94e6f8a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 10, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b9ad02c0-d8d3-5327-8bc6-44afa8d7ae54', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-03-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e8d3309c-018c-55c1-be18-75e34a9dcb52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b9ad02c0-d8d3-5327-8bc6-44afa8d7ae54', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 129.9, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('46c0641d-5f4e-5b1f-a65d-910151d1990c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-03-21', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e205aa3c-c254-573f-a1fe-5f5df853bf2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EBN *TIKTOK SHOP', 91.99, '2026-03-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5d8fa2ee-b8c5-539d-8998-4e521350070f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e205aa3c-c254-573f-a1fe-5f5df853bf2e', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 91.99, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d2cc45c3-0b04-5183-b9b5-69fe99974423', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EBN *TIKTOK SHOP', 91.99, 'expense', 'paid', '2026-03-21', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b94969db-e345-5058-98db-9f6fdf2c8bb8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, '2026-04-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1a7ca81a-28f6-5eba-b78b-35727519a8f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b94969db-e345-5058-98db-9f6fdf2c8bb8', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 7.95, '2026-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a13cf2a9-474b-5278-9f96-e537aa6ae0df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*IFOOD', 7.95, 'expense', 'paid', '2026-04-12', '2026-04-22', '2026-04-22', 'e9b953f0-78bb-5516-8779-fedd2ef0ccd8', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 04/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-05 (Santander -  22052026.pdf) - R$ 1868.79
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('6105e2d6-1254-55dc-bf98-6c249c2467f3', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 5, 2026, '2026-05-15', '2026-05-22', 1868.79, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('717b3af2-3f97-50b9-835b-08b7d73f9446', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ZP*LTDA 62157', 0.02, '2026-03-19', 1, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c64b433b-fd38-5444-a1da-242bbdf69dca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '717b3af2-3f97-50b9-835b-08b7d73f9446', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, -0.02, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bcfa89ac-b291-567a-b1f3-c6ef6d354aa3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ZP*LTDA 62157', 0.02, 'income', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('106e4332-692f-5830-ae89-e276cb8d2e1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('79da71a9-59d2-5981-b7ac-07924d5c9f6e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '106e4332-692f-5830-ae89-e276cb8d2e1b', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 5, 326.43, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0a413a51-8c46-5efd-9363-84e510b8a51c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 5, 5, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b98c934f-3a45-5352-afd7-96d8e7df740e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('89d16e16-1d81-5cc6-bd78-528cf817ce68', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b98c934f-3a45-5352-afd7-96d8e7df740e', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 4, 120.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fd28b0e3-c4f6-5593-9b1e-7a9f5f122834', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 4, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2c108100-567f-5e08-9e20-6be2592e4a3a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, '2026-02-11', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('afd1520f-14fd-5280-854d-ee5a41375278', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2c108100-567f-5e08-9e20-6be2592e4a3a', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 3, 233.33, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('11702caa-2026-5e39-89ef-2d605b801c1b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 233.33, 'expense', 'paid', '2026-02-11', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7627ab3b-1063-53b8-ae45-14a35ff9ca65', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b409d2d1-a4b9-5b8b-805c-515545f52c42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7627ab3b-1063-53b8-ae45-14a35ff9ca65', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 362.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f0be36be-b1c6-5830-bf41-1daa28fa9a00', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 362.0, 'expense', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('054ce7ee-015e-5b04-bea0-9e3b66288996', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f2e5c96f-6d1f-5b2b-b65f-b564c3d48df7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '054ce7ee-015e-5b04-bea0-9e3b66288996', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 288.5, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('036e7f51-44c0-5ccb-a2ec-28069e95672d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, 'expense', 'paid', '2026-03-19', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b2989de5-10b9-5f46-abbd-39c84e2bf696', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 15.0, '2026-04-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('98bccddc-32e8-5630-ac91-c26152175c9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b2989de5-10b9-5f46-abbd-39c84e2bf696', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 15.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8e3a8c96-d5b3-5443-abcd-0962ae54c8b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 15.0, 'expense', 'paid', '2026-04-28', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5f1904c4-840e-544c-b2fb-cf12c8422fdd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cddb9c6f-84a3-5f13-ba59-b40c26966ddd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5f1904c4-840e-544c-b2fb-cf12c8422fdd', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 5, 82.18, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('688221ba-773e-5202-bbbd-ca872773da6b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 5, 12, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba42b1bb-2cff-5e80-abf4-16a6e25ae583', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('29cfe5e5-c0da-541a-a125-9902e40f9cb9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ba42b1bb-2cff-5e80-abf4-16a6e25ae583', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 37.48, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2f217cb3-44b8-588e-ba0f-d5a7cea438a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 2, 10, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5c2f5f2a-a443-5bad-9bcf-8d70b8e1be61', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, '2026-04-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7a03ff95-8d77-5ed6-b764-3296d9c2e3da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5c2f5f2a-a443-5bad-9bcf-8d70b8e1be61', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 5.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43642ada-7c07-56b5-a5b1-c9f700ffe02b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 5.9, 'expense', 'paid', '2026-04-14', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('02188f6f-7c9b-5cae-a9fb-dd601861f423', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-04-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7538de48-29ec-5948-9b29-aaa270750754', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '02188f6f-7c9b-5cae-a9fb-dd601861f423', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 129.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4f46953b-5da2-55ea-a86e-a93035371758', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-04-21', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('19fc3056-2b7b-56ac-9c6d-967b0ce5bc28', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, '2026-04-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eb351273-35c7-5194-b9c0-39f43fcde9b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '19fc3056-2b7b-56ac-9c6d-967b0ce5bc28', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 26.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4df6a85d-c0c6-567e-855c-abbf57f25575', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, 'expense', 'paid', '2026-04-24', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0a8c4b0d-0b8f-5a78-8ae7-375aa57a8cd3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, '2026-04-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4c9d5c96-e6b1-5985-b927-9e4836525fba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0a8c4b0d-0b8f-5a78-8ae7-375aa57a8cd3', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 50.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dd2d15f4-5e99-5a8c-acc9-1fda27fbd5a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, 'expense', 'paid', '2026-04-26', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('165903ca-9f95-56b4-8b5c-036d9c00f481', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 25.9, '2026-04-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4b046e7f-82df-51a6-8707-b8607a7d7d70', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '165903ca-9f95-56b4-8b5c-036d9c00f481', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 25.9, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f83a31fb-7c30-506b-9d78-5ffc448e86cc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 25.9, 'expense', 'paid', '2026-04-29', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('927e9c9f-daab-5b4b-b1a9-599f6d070066', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, '2026-04-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('32a46d1c-5e6f-54fe-bf39-155d562249e0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '927e9c9f-daab-5b4b-b1a9-599f6d070066', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 30.0, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6dac1f2-b13b-5b1b-b7da-b992aa089e97', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 30.0, 'expense', 'paid', '2026-04-30', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2ade7219-5883-56df-aa9b-d083acc38c87', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 7.99, '2026-05-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('affbc41b-74ba-5148-86da-e0d756c4c993', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2ade7219-5883-56df-aa9b-d083acc38c87', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 7.99, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('96c8cf52-1c10-575e-91f8-9ae65e1892f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 7.99, 'expense', 'paid', '2026-05-01', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bfdecb7e-7588-57bc-b57f-67ef6a972570', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 47.89, '2026-05-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9894acbc-9d35-586d-a335-4372a158abd7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bfdecb7e-7588-57bc-b57f-67ef6a972570', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 47.89, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f12eaea1-f4e2-504a-b5aa-d91b618d90de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 47.89, 'expense', 'paid', '2026-05-02', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7a5170b8-02a1-53a9-9c0c-e4fcdd4a828e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 11.49, '2026-05-02', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3aef69e3-5af2-5ead-92c6-48e43fcf68d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7a5170b8-02a1-53a9-9c0c-e4fcdd4a828e', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 11.49, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bc1eac0e-61c1-505c-ad80-fea5f4bb3c0c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 11.49, 'expense', 'paid', '2026-05-02', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3fb0f6c-aff3-5667-9ffa-89387b34c9de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 45.94, '2026-05-03', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('65e81991-37ba-5257-b697-98d2791e452d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e3fb0f6c-aff3-5667-9ffa-89387b34c9de', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 45.94, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1ebb0a54-65d1-5a51-bf59-c3624a44f418', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 45.94, 'expense', 'paid', '2026-05-03', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8f23ace2-1dff-541c-9280-780df6b57756', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIR', 21.98, '2026-05-04', 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('03b9e607-094c-5193-9a53-c0dcd05e90d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8f23ace2-1dff-541c-9280-780df6b57756', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 21.98, '2026-05-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f6e57a76-639c-5701-b81d-f13929697aa4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIR', 21.98, 'expense', 'paid', '2026-05-04', '2026-05-22', '2026-05-22', '6105e2d6-1254-55dc-bf98-6c249c2467f3', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 05/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-06 (Santander -  22062026.pdf) - R$ 1000.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c73af715-fd7e-52ad-99e4-c9636d58e996', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 6, 2026, '2026-06-15', '2026-06-22', 1000.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a0c87504-3f87-5481-863a-d2c510a11f91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2f38e234-b619-5177-a757-91d1f8f484eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a0c87504-3f87-5481-863a-d2c510a11f91', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 5, 120.0, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ae109a38-3721-5ec7-9eb4-455d2c9f7e06', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 5, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('81b8b6c9-fd67-5239-9b48-120c578314aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 361.98, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1a304624-2b17-5156-b3ec-da0202fc3e03', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '81b8b6c9-fd67-5239-9b48-120c578314aa', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 361.98, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7a98a384-255f-5839-bc7e-a0ccc7eb6bff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 361.98, 'expense', 'paid', '2026-03-19', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('56d2d77d-8af1-58f1-aec5-8df2e60a60d2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, '2026-03-19', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('97e5548e-6177-5686-95a7-2354462a600b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '56d2d77d-8af1-58f1-aec5-8df2e60a60d2', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 288.5, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3096f161-ba5b-5684-a8d7-d8c8b4d4e812', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 288.5, 'expense', 'paid', '2026-03-19', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('323212ce-6433-5685-8cd3-4e2c217976d9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.17, '2026-05-22', 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d92e9f8c-b14c-5a09-8bfc-9b69142b39a6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '323212ce-6433-5685-8cd3-4e2c217976d9', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 849.17, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1c01fdc1-0fba-5ac8-917a-81546b8f08ae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.17, 'expense', 'paid', '2026-05-22', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5ea57ace-9794-594c-b6ac-4d3ab9f6c39b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('cefed839-0f3a-5d50-8de9-35588c4fd1c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5ea57ace-9794-594c-b6ac-4d3ab9f6c39b', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 6, 82.18, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3730db33-b5c0-5deb-8d01-87a938f1f4e9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 6, 12, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ca86f3f7-8644-5724-acb7-eedadfc18337', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aaa730fc-29b8-56bf-a8cf-cf929977ccf0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ca86f3f7-8644-5724-acb7-eedadfc18337', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 37.48, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c2c71793-23f6-5033-a442-40167fdf4d30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 3, 10, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8239db75-efc0-55be-922d-a5216be7a7b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DOMNETTOPIZZARIA', 64.99, '2026-05-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fad41b1b-cb34-500f-8c68-813f12f47c0b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8239db75-efc0-55be-922d-a5216be7a7b4', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 64.99, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f616df0b-7163-5376-a812-f2dd9cf1e9a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DOMNETTOPIZZARIA', 64.99, 'expense', 'paid', '2026-05-25', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ee3dae9b-62ec-55b0-8208-f7b400d3bcae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 132.67, '2026-05-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('48c5e9da-f8ce-545a-8e1b-a0debaced7fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ee3dae9b-62ec-55b0-8208-f7b400d3bcae', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 132.67, '2026-06-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('050ac714-c0a0-53ff-b529-defb85a31bab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 132.67, 'expense', 'paid', '2026-05-25', '2026-06-22', '2026-06-22', 'c73af715-fd7e-52ad-99e4-c9636d58e996', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 06/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-07 (Santander -  22072026.pdf) - R$ 1400.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 7, 2026, '2026-07-15', '2026-07-22', 1400.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('57537761-90b1-58c1-a7c4-56600e6ece80', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('635b5a04-d9e3-5ae0-964e-ed7f261dcf62', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '57537761-90b1-58c1-a7c4-56600e6ece80', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 6, 120.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1e72ab19-0d8f-5d82-8c63-e62014f5b0ad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 6, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3037f5e1-4dce-532f-82bf-68f4563b88a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.16, '2026-05-22', 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('827f3493-1ba1-5d13-9bd9-e271fd3edeba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3037f5e1-4dce-532f-82bf-68f4563b88a7', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 2, 849.16, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('65d98032-056e-5316-9f25-7dc6a5045d74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 849.16, 'expense', 'paid', '2026-05-22', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 2, 2, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('11c64cdd-f86d-5069-ac99-e84b38ba455f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, '2026-06-22', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f8bc916-570c-5904-918f-0b34a865bc49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '11c64cdd-f86d-5069-ac99-e84b38ba455f', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 354.95, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9ddc9ad3-a7b8-52fa-91d0-122e1307339a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, 'expense', 'paid', '2026-06-22', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9f736381-ff24-5087-b57b-aa25e094b0a8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 46.84, '2026-06-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d5920886-4587-5021-9b07-7cbd9aa708a5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9f736381-ff24-5087-b57b-aa25e094b0a8', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 46.84, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('89eb311a-91ba-558e-b4a5-f575ffb6c18a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 46.84, 'expense', 'paid', '2026-06-25', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d955a9e4-819c-56aa-9e2a-d9a0e636f388', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.28, '2026-06-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8c913168-c22d-5d1f-9df7-a8602a161164', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd955a9e4-819c-56aa-9e2a-d9a0e636f388', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 31.28, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ef16f8de-e7cf-5e78-b721-cd83ce1b5dd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.28, 'expense', 'paid', '2026-06-29', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5798f766-3019-50b0-9599-77b59c3bd552', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*BR', 24.08, '2026-06-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b3c5766c-10b3-5023-9c41-cf7fb97ca9f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5798f766-3019-50b0-9599-77b59c3bd552', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 24.08, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c53e0c05-14a8-51ce-83e4-2f7c1c19f86e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*BR', 24.08, 'expense', 'paid', '2026-06-29', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fdcea9a7-3efe-57c7-b107-a1871c0afa3e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 40.88, '2026-06-30', 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('893c5ad4-1e3b-5dba-8293-9e07e09f7666', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fdcea9a7-3efe-57c7-b107-a1871c0afa3e', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 40.88, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('49506513-d879-5a57-9304-3fb579a81445', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 40.88, 'expense', 'paid', '2026-06-30', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b67ee3c2-ed3e-55b6-9317-3c239d669548', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e0ecde16-da46-5a1b-a5a7-3f0e9719342b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b67ee3c2-ed3e-55b6-9317-3c239d669548', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 7, 82.18, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1e7650b5-3fc5-577e-bd56-41e233826dce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 7, 12, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('eb23fa00-1c59-5252-b775-16506549dd44', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e14f3ac6-9d7a-543f-8d63-209b2a0023b2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'eb23fa00-1c59-5252-b775-16506549dd44', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 4, 37.48, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('36965797-ec83-543e-a409-685037cd38c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-07-22', '2026-07-22', '109324d4-7c8b-543b-9ca9-f73c5fc2c73b', 4, 10, 'Cartão Santander SX (Final 8876) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-08 (Santander -  22082026.pdf) - R$ 7.91
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('59feb2ca-8df9-5ea0-ac14-400695b91587', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 8, 2026, '2026-08-17', '2026-08-22', 7.91, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('87f4230b-bbe8-57f0-b3d1-1ff1c49b820a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RESERVAS', 109.2, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e3aeb2f2-56b2-52ef-8158-2025d578ad1d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '87f4230b-bbe8-57f0-b3d1-1ff1c49b820a', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, -109.2, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('85a080cb-7fb4-53c4-998e-16ad90c07aad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RESERVAS', 109.2, 'income', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a7f8807a-662b-59f1-ba65-7e20433a7ac2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('97d73c93-58ed-5246-8c63-2cc847e55fc0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a7f8807a-662b-59f1-ba65-7e20433a7ac2', '59feb2ca-8df9-5ea0-ac14-400695b91587', 7, 120.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('eb8cf2fe-56d9-56d0-aa5c-4bf3352af885', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 7, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d48de10d-24fe-5a9d-b383-93f05edc8f85', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, '2026-06-22', 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aa1502a5-3ce8-5bf0-93ea-aadd64dc538d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd48de10d-24fe-5a9d-b383-93f05edc8f85', '59feb2ca-8df9-5ea0-ac14-400695b91587', 2, 354.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b32cefe0-1f0c-5736-9023-e8484a043a05', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 354.95, 'expense', 'paid', '2026-06-22', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 2, 3, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('70072186-cae6-5ac1-98b7-cbdadaffff50', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 12.0, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fe6392d5-eae1-5149-88f6-76ece8af9bf8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '70072186-cae6-5ac1-98b7-cbdadaffff50', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 12.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('67a26374-303b-58f7-bff6-a3b29e80ae13', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 12.0, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('060aa86d-9665-52c1-940d-db5afe239044', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 11.95, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3dfca99d-1379-5e4e-836d-2eae131df448', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '060aa86d-9665-52c1-940d-db5afe239044', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 11.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('31d63bbd-1712-58bf-a4e7-394e53c75229', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 11.95, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('60ccdd70-c035-55d1-abd8-68bfa0b0cfb5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*NICOLAS WOTTER DA SIL', 17.48, '2026-07-18', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('66423fde-06ca-56bb-9ff5-2cbb550b605f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '60ccdd70-c035-55d1-abd8-68bfa0b0cfb5', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 17.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aa4f26ec-e38d-5c74-8052-4fd018f3e82b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*NICOLAS WOTTER DA SIL', 17.48, 'expense', 'paid', '2026-07-18', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a17cc5bb-da8b-5baa-933f-f379cb1557bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.44, '2026-07-19', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dc5fbd56-349e-5012-8d67-2103273ddb6c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a17cc5bb-da8b-5baa-933f-f379cb1557bd', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 71.44, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9190d087-44bd-5e78-abda-8245112e7478', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.44, 'expense', 'paid', '2026-07-19', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a57b1a09-cf01-5fcd-af40-1a913e98538f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 30.0, '2026-07-21', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dc54ce23-dc35-57ab-88b5-a63f1926ed63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a57b1a09-cf01-5fcd-af40-1a913e98538f', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ce446a54-c3ae-5155-996d-a7b6e2642aef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 30.0, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bc5e8f61-2791-5d5b-aec2-36ee8b03a63d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 7.0, '2026-07-21', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('99020ca0-8f27-5f5b-b0e3-8a964213e3fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bc5e8f61-2791-5d5b-aec2-36ee8b03a63d', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 7.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4ca6bc39-cdcb-5bdf-bc53-fe36f5693ec3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 7.0, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('249e15c8-3922-55d6-8869-67f3a261223a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 39.88, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('59c7bd19-3718-5d4e-8e94-3ed915952378', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '249e15c8-3922-55d6-8869-67f3a261223a', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 39.88, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('579882a2-2d20-5e2f-91c6-d3f3ee72a8b3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 39.88, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('af5bb121-d31b-524c-8f75-8f2a0fd7bef6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ELENICE MACHADO MARQUES', 10.25, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6cf79a79-9e18-5733-b3f8-0d4e0762ebad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'af5bb121-d31b-524c-8f75-8f2a0fd7bef6', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 10.25, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('470ab4fe-b392-52bc-97c4-c6c4f0662594', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ELENICE MACHADO MARQUES', 10.25, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('944b2687-999c-561d-82ee-fa651328b3c2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0a1b5c65-cb6a-5601-956e-201270d11414', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '944b2687-999c-561d-82ee-fa651328b3c2', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 14.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c133a398-e5dd-56d2-8b3e-b83e3047421a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d7e4b838-7c2a-5f16-953e-45d061b85fdc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 37.88, '2026-07-22', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5a4f734e-f2dc-547a-ad35-c1eb94a8d90e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd7e4b838-7c2a-5f16-953e-45d061b85fdc', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 37.88, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('76f1afdd-6081-533c-8aca-55642b08c90c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 37.88, 'expense', 'paid', '2026-07-22', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('603ac33e-e5bf-5bc0-8948-1eb24d998980', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 37.77, '2026-07-23', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b5ffd777-ed2a-5f43-9de7-08fb30db1138', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '603ac33e-e5bf-5bc0-8948-1eb24d998980', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 37.77, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2a4de686-e146-50f9-8673-ad7f95b3361d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 37.77, 'expense', 'paid', '2026-07-23', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f9500ee6-11c8-5803-a885-d05c7ebdada4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 16.48, '2026-07-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('44a224ef-541e-5edb-9e04-c2e3073c2dce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f9500ee6-11c8-5803-a885-d05c7ebdada4', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 16.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('70a2594b-c93d-509b-b378-9ee48ea92d9a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 16.48, 'expense', 'paid', '2026-07-24', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1726084c-5de7-57a5-9559-f3257cd5b748', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, '2026-07-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fc8fc649-9cd5-5b08-8a32-d23b42fe46a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1726084c-5de7-57a5-9559-f3257cd5b748', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 14.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fb34c7a8-2117-5dfe-b443-80c64e17e3fa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 14.0, 'expense', 'paid', '2026-07-24', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('39f06dbf-a9de-5979-aced-aab133814064', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.49, '2026-07-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0f0ad91e-902f-580d-bb4c-4ebb603cae8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '39f06dbf-a9de-5979-aced-aab133814064', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 15.49, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7b1794c5-6bee-5cf1-a639-64ade208d5b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.49, 'expense', 'paid', '2026-07-25', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('42ed0e43-3740-5b21-81b8-c38666fde121', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FERNANDA LOPER SANTANA', 17.0, '2026-07-25', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8329508c-875e-5c52-bd8c-e70b82a15fbf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '42ed0e43-3740-5b21-81b8-c38666fde121', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 17.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ad5d0330-36b6-5fbe-91d1-08b2b36ec05b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FERNANDA LOPER SANTANA', 17.0, 'expense', 'paid', '2026-07-25', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6e79c3c8-22d5-5003-b812-d7954d0c58d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.01, '2026-07-26', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9bbbcbcb-1a0a-5014-941a-8f383c3cd88f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e79c3c8-22d5-5003-b812-d7954d0c58d3', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 30.01, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('424fc0d8-9749-5e67-8d46-9ec08a83ca21', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTO PAULO MOREIRA', 30.01, 'expense', 'paid', '2026-07-26', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ce5ec434-a681-5529-bf4b-f2d4d8e004fb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 41.8, '2026-07-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7c023ce2-594d-5dcb-8d40-07447675ec4f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ce5ec434-a681-5529-bf4b-f2d4d8e004fb', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 41.8, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fe76138b-339e-5358-9765-26bc56ce11b7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 41.8, 'expense', 'paid', '2026-07-27', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a4da2ca8-e970-5b2a-8fa9-767efe6cdded', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 18.9, '2026-07-27', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('682adce4-dd7f-506d-939c-80c6d8b41755', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a4da2ca8-e970-5b2a-8fa9-767efe6cdded', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 18.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3e40833-3b45-55bc-b2ed-ad28be0e33cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 18.9, 'expense', 'paid', '2026-07-27', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dca76125-0ce0-5170-8d06-acb14b87e501', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 30.0, '2026-07-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6c25c2a1-14a3-51a4-b4a9-e98376b2589e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dca76125-0ce0-5170-8d06-acb14b87e501', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('228bf6e1-90f9-5833-8f96-46c4c48f275e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 30.0, 'expense', 'paid', '2026-07-28', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e613ca33-4ad0-5717-a6be-7e6ae25bcfe7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2026-07-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a9e7f795-cad6-5582-ba60-f6ae96e2761d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e613ca33-4ad0-5717-a6be-7e6ae25bcfe7', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 10.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e7d04e8c-f538-5c6e-8954-fa677126a5ab', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2026-07-28', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f3230809-8561-53cc-8313-0618caf490fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '27 736 853 ALEF DOMING', 15.0, '2026-07-29', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('16f1c63d-f2ea-5fae-aa6b-2bfcf1ebfd7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f3230809-8561-53cc-8313-0618caf490fd', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 15.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('56d9bb5c-63be-5c35-a6bb-30d7034c7c7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '27 736 853 ALEF DOMING', 15.0, 'expense', 'paid', '2026-07-29', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c0dfdc8f-ac4e-559c-b922-cf6fb25be7ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, '2026-07-30', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6eee8625-dcb4-5ccd-901f-48594273d969', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0dfdc8f-ac4e-559c-b922-cf6fb25be7ce', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 10.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1ee143da-8a9e-59b2-a8de-a81e6a5cf664', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', '55534008DOUGLAS', 10.0, 'expense', 'paid', '2026-07-30', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5b0433eb-7dd4-58ef-a7c8-d0a1f0c4267b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RESERVAS', 156.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('38a35f4f-b807-5288-8979-0a748eea072e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5b0433eb-7dd4-58ef-a7c8-d0a1f0c4267b', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 156.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d53f08b-6510-5dff-817d-4b106857b41e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RESERVAS', 156.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8f0835fb-ce58-58fd-9ac2-2a991b9d78f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 60.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b94a3f39-3ea6-547b-97fc-8f545cfb362f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8f0835fb-ce58-58fd-9ac2-2a991b9d78f2', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 60.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d53a9042-dc2c-5150-bbdc-a5316d2bf847', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 60.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d5b793fa-c1d7-5672-bf02-cf6dc1ad7789', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 167.68, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0915ca15-5668-5ce5-a435-2231f669f710', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd5b793fa-c1d7-5672-bf02-cf6dc1ad7789', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 167.68, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('66eee800-cf78-5a8a-b755-334c58b0f8cf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 167.68, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ac073283-a825-5f2d-91e2-4fce7288ae2f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'GARAGEM BELEM LTDA', 25.0, '2026-07-31', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('eb426876-d8b1-5d38-853f-800d3a4f1511', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ac073283-a825-5f2d-91e2-4fce7288ae2f', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 25.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ddc2266d-e315-5e41-ab52-87b5db782b05', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'GARAGEM BELEM LTDA', 25.0, 'expense', 'paid', '2026-07-31', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0fca5bc4-415f-50c9-b9de-8157428d0596', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 15.0, '2026-08-02', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f8690fe6-427f-5ed0-bf3f-cc1e83fd4941', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0fca5bc4-415f-50c9-b9de-8157428d0596', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 15.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a1236e72-11f9-5085-a7ac-5960d9971f54', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 15.0, 'expense', 'paid', '2026-08-02', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('03ec1a2a-05ad-5340-9bed-e34d9a85efff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, '2026-08-03', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('04ee3d16-da6a-527f-8051-4b9429f0dbc8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '03ec1a2a-05ad-5340-9bed-e34d9a85efff', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 26.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('64f70364-57de-550f-a676-d4fcf555fc8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BS BURGER E SHAKES LT', 26.9, 'expense', 'paid', '2026-08-03', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ba038747-6d65-53bb-852e-a2b0ec090629', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 18.38, '2026-08-07', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9e177f3f-2953-594d-944f-77199cda5def', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ba038747-6d65-53bb-852e-a2b0ec090629', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 18.38, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2b275864-1ca2-53a3-8cf0-62106894de35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 18.38, 'expense', 'paid', '2026-08-07', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b1ae1e8c-4d68-5b2c-a7d7-16813918f3a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 42.83, '2026-08-09', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ec6cfe56-8e9f-571d-be0f-84acf3c45947', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b1ae1e8c-4d68-5b2c-a7d7-16813918f3a2', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 42.83, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2c0d5fa5-4678-5b48-bd69-aa0832441321', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 42.83, 'expense', 'paid', '2026-08-09', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ffb83711-d5be-5974-8ae3-6bc3a12aec3e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 15.5, '2026-08-10', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a87c9613-6145-5c81-9c50-1dc17a9eb7c6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ffb83711-d5be-5974-8ae3-6bc3a12aec3e', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 15.5, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ad09dcb1-da75-5345-984e-9ff21061598b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'DLI COMERCIO DE COMBU', 15.5, 'expense', 'paid', '2026-08-10', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('35a7dc3f-a491-593a-a463-88d4f10af5c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 40.0, '2026-08-10', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('df13440b-98e2-5b97-86bc-3ca94a7db3f2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '35a7dc3f-a491-593a-a463-88d4f10af5c7', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 40.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a838c57-f157-53c6-b471-15527ac60eb4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANG', 40.0, 'expense', 'paid', '2026-08-10', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('12d2d9d0-dbfb-56b0-9e74-dd858bd813ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 70.0, '2026-08-11', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d33d0e07-5b07-57e0-823d-1a38e46c69e6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '12d2d9d0-dbfb-56b0-9e74-dd858bd813ea', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 70.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8ab68533-b3a0-5757-85b2-edfdb1185db9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 70.0, 'expense', 'paid', '2026-08-11', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e9f7455c-2450-5162-9865-4e3ec7348a30', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ALEXANDRE DE MENEZES S', 100.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7120ba7c-1058-5171-ae78-fef428876d16', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e9f7455c-2450-5162-9865-4e3ec7348a30', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 100.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2314c1e7-fc6f-51cb-a1c3-5aa6adbd13de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ALEXANDRE DE MENEZES S', 100.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('578332ba-b36d-563f-8167-49c6d2375650', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6879b385-2af0-576f-ad2d-c8348effb089', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '578332ba-b36d-563f-8167-49c6d2375650', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ad1fb558-c671-5e22-9ff7-39905552e85b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9464e76e-7312-5828-acbf-627e74c7f005', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, '2026-08-13', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e14d6ac-93fd-55ef-b7d5-b366c457b4bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9464e76e-7312-5828-acbf-627e74c7f005', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 30.0, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f9dbce47-40f9-526c-be45-8c39e5f51023', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PANTALEAOANTUNES', 30.0, 'expense', 'paid', '2026-08-13', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('62eefaf4-d101-5925-9421-36c124b3a0b5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 10.95, '2026-08-14', 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c3ce7d1b-ba7e-5b45-a843-33c6772eeffc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '62eefaf4-d101-5925-9421-36c124b3a0b5', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 10.95, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7de33775-154f-58a0-8bc6-b3330ca22c42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPER ONZE', 10.95, 'expense', 'paid', '2026-08-14', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3f4cc3e-2566-540f-9d2d-9b00400003e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c96b2151-7613-5a53-89b2-e9c972591def', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e3f4cc3e-2566-540f-9d2d-9b00400003e2', '59feb2ca-8df9-5ea0-ac14-400695b91587', 8, 82.18, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a693da12-d70e-52d6-b1e5-11a7af9b05d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.18, 'expense', 'paid', '2026-01-13', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 8, 12, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('12ab432d-5d95-5a6d-b6ac-b9398f56fffe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, '2026-03-25', 10, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4946e2a6-2526-5e56-ab57-4a7671335e82', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '12ab432d-5d95-5a6d-b6ac-b9398f56fffe', '59feb2ca-8df9-5ea0-ac14-400695b91587', 5, 37.48, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8a14280c-47cf-51d2-b1d2-64e81b9dd657', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'b16ae701-1e89-4228-9561-fdb556399d3d', 'DESCOMPLICA VEST', 37.48, 'expense', 'paid', '2026-03-25', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 5, 10, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('73b13fde-3f32-5e30-9af4-a42ce8c25cec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ANTHROPIC* CLAUDE SUB 117,14', 21.68, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('743053fd-08ff-5da7-89ad-7fdebe65ecbd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '73b13fde-3f32-5e30-9af4-a42ce8c25cec', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 21.68, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9042ddc8-8674-5198-83b9-dc4fee419d0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ANTHROPIC* CLAUDE SUB 117,14', 21.68, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('10c3e1f0-aeaf-50dd-bbeb-37ed386a76c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 109.9, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b2cdb671-e440-5214-8329-8870b08066e3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '10c3e1f0-aeaf-50dd-bbeb-37ed386a76c0', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 109.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('f7aa363a-b91e-5966-8234-58764a8b2729', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 109.9, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1dcad94e-1cae-509d-9ac0-2d3d620c0534', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: APPLE COM/BILL', 109.9, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('09150d5e-0c93-56d9-9410-486a000bdfe9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1dcad94e-1cae-509d-9ac0-2d3d620c0534', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, -109.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9a4fec82-72ee-5806-8308-deb743f30a74', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: APPLE COM/BILL', 109.9, 'income', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('adf33775-81cb-58b4-80d5-991f93ba2617', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 56.06, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fbbdf165-f57b-5262-b21c-383445e8718d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'adf33775-81cb-58b4-80d5-991f93ba2617', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 56.06, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7ae0059d-3e8b-5a6b-a8af-369d20a1c696', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*JR VF NUNES LTDA', 56.06, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('391a9ca2-c3d7-506d-8d05-be263d84c4ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 133.61, '2026-07-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1453c0a8-a81e-5f4a-8cb9-a1e7f630d849', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '391a9ca2-c3d7-506d-8d05-be263d84c4ca', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 133.61, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('35a862ca-5d43-595a-88e6-861d31bcfdc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 133.61, 'expense', 'paid', '2026-07-17', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b69b11f5-7e03-5a15-bcc1-4a6c09adb303', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 49.86, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ab019257-b1a6-50e1-a90e-ab6b91a66ea4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b69b11f5-7e03-5a15-bcc1-4a6c09adb303', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 49.86, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d3b51f63-ed13-5477-b207-e7ecb075aab4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 49.86, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('570f06e3-6fa6-59b8-b784-a4c18d58b54e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 158.65, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9a496017-1919-5e18-9e75-b6d9ae97fdb7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '570f06e3-6fa6-59b8-b784-a4c18d58b54e', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 158.65, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6690b28c-59e6-503b-8b01-a32fdc7002be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 158.65, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5431a0d1-845b-5fb8-89ff-5175f19896b6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-07-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('078e5ec2-55ba-5fb8-b51c-d25ffa04c608', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5431a0d1-845b-5fb8-89ff-5175f19896b6', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 129.9, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('09b58133-dbf1-5012-967e-8967f83d22c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-07-21', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('aba56992-045a-5b47-839b-b0d776f9c614', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'MOONSHOT AI 108,77', 20.01, '2026-08-12', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fb04e5fe-65c7-5876-8592-414b1b21f635', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'aba56992-045a-5b47-839b-b0d776f9c614', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 20.01, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5dd775c9-7e5e-5a22-9737-04a76ee9c79b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'MOONSHOT AI 108,77', 20.01, 'expense', 'paid', '2026-08-12', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8aedb19f-0460-5a7a-8ad0-a6125661368d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58067449 ANGEL GON', 31.62, '2026-08-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b3cea95c-5701-5e42-a337-cefdb84ec90a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8aedb19f-0460-5a7a-8ad0-a6125661368d', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 31.62, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8694c0a9-5273-53cd-98de-53f1ebaee397', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*58067449 ANGEL GON', 31.62, 'expense', 'paid', '2026-08-12', '2026-08-22', '2026-08-22', '59feb2ca-8df9-5ea0-ac14-400695b91587', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-01 (Santander - 22012026.pdf) - R$ 1450.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('19fee412-7da7-50b1-97b2-8977bae3636e', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 1, 2026, '2026-01-15', '2026-01-22', 1450.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('7728e12b-47a9-5c9a-8302-9c1d8a8e9783', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RAC PELO', 0.02, '2025-11-28', 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('27a74fa9-0f60-5ce2-9c44-912334c8c8c3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '7728e12b-47a9-5c9a-8302-9c1d8a8e9783', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -0.02, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('49729767-5ec6-594d-bf72-1aaa102b9128', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'Estorno/Crédito: MOVIDA RAC PELO', 0.02, 'income', 'paid', '2025-11-28', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('52828479-49f0-504f-bd81-807ec26bd04d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('677eb9b8-9687-5b8b-8763-b826be1caa18', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '52828479-49f0-504f-bd81-807ec26bd04d', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 204.61, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6841422c-aa46-572a-9d21-74c499038037', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.61, 'expense', 'paid', '2025-11-28', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 3, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6d40783e-6eec-55ce-bcd8-1e82d8b6914e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c6771142-dd6e-5a68-a2c5-1c3fd74f2150', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6d40783e-6eec-55ce-bcd8-1e82d8b6914e', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 326.43, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('46fb0f48-5b3d-5704-a53d-088632890dbb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 5, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('88eb53c8-1f6c-58a3-89ed-1c5f5e837f35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 40.77, '2025-12-24', 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9224df42-165e-55ff-9332-b234fe39afef', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '88eb53c8-1f6c-58a3-89ed-1c5f5e837f35', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 40.77, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b18835c5-0d57-52f8-b3c1-8ae008437dbe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 40.77, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('cd760871-bd66-56f2-a2df-bc588087e1ed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: GB MIX QUARTIER', 199.29, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f62d99de-c223-5cf2-ab7f-5fa230c7d515', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'cd760871-bd66-56f2-a2df-bc588087e1ed', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -199.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('970c892b-0623-56bb-b548-a3680c97104c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: GB MIX QUARTIER', 199.29, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('30c9cad0-8f17-56e3-8f30-c8506d8f7b8f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: CARREFOUR PELOTAS GENE', 86.3, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fd480413-1df1-55eb-b8b7-695d8ed82298', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '30c9cad0-8f17-56e3-8f30-c8506d8f7b8f', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -86.3, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('067156dd-c2c7-550c-af5f-25de634ea237', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'Estorno/Crédito: CARREFOUR PELOTAS GENE', 86.3, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ee0e2041-3c36-5596-94ed-ff6ceb9d8ffe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: KENKYO COZINHA ORIENTA', 163.9, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('520d4e20-4dbf-59a6-be70-448239a79acf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ee0e2041-3c36-5596-94ed-ff6ceb9d8ffe', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -163.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dc2d2a68-bee6-54c8-a520-ca214d974901', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: KENKYO COZINHA ORIENTA', 163.9, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d48ea6cb-2b92-569e-abdb-5603250713ed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: QSQ PH GUARULHOS 0T02L', 90.06, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('029426d7-bbd9-5f88-b445-fa71bada8a02', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd48ea6cb-2b92-569e-abdb-5603250713ed', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -90.06, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1b125bb5-d515-5181-b33d-663f427a2182', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'Estorno/Crédito: QSQ PH GUARULHOS 0T02L', 90.06, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dba1861e-8827-560b-bfb3-e27e22a3653c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Estorno/Crédito: CLARO P*FATURA CLARO', 117.15, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f413e4bf-b9b1-54c0-aec5-d18ef869aca4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dba1861e-8827-560b-bfb3-e27e22a3653c', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -117.15, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e88276dd-f8a7-5a1c-8851-a29420cd3f7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'Estorno/Crédito: CLARO P*FATURA CLARO', 117.15, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5fc62db6-67a4-5862-89b8-e1f36ccbf4ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ORIONGESTAODE', 117.96, '2026-01-05', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3ccec693-3a44-5e27-ae34-d901599d4291', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5fc62db6-67a4-5862-89b8-e1f36ccbf4ba', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, -117.96, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('2041b723-17e0-54f8-8d22-cfad643f6666', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'Estorno/Crédito: ORIONGESTAODE', 117.96, 'income', 'paid', '2026-01-05', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2a4d30ea-9874-5aac-897b-3eeb41743303', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, '2026-01-08', 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('26dbfba5-d512-5c8d-9970-3fce19db93e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2a4d30ea-9874-5aac-897b-3eeb41743303', '19fee412-7da7-50b1-97b2-8977bae3636e', 12, 312.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e69b7217-edad-5b41-b19f-1cd096deedfd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 312.5, 'expense', 'paid', '2026-01-08', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 12, 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('be90c4b3-6ff0-516a-bed0-2e4e9eed5729', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('5c5238d3-064d-5301-9a25-05f768470783', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'be90c4b3-6ff0-516a-bed0-2e4e9eed5729', '19fee412-7da7-50b1-97b2-8977bae3636e', 8, 67.48, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fd1b7992-035f-52eb-a6c9-f8342b91cea2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 8, 10, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('12f4e51d-4b25-514c-8441-cde0ab8b234b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, '2025-07-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a0d67648-d055-53d7-ab35-58a934b67607', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '12f4e51d-4b25-514c-8441-cde0ab8b234b', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 12.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('dbf3b9c0-4e17-5d96-9daa-023774ef24cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HTM*ASSOCIACAO B', 12.5, 'expense', 'paid', '2025-07-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e137d569-00e6-5f2b-894a-1c2a02838740', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, '2025-08-08', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('70d8fdfe-05fc-5725-82fa-24d3946c1e86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e137d569-00e6-5f2b-894a-1c2a02838740', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 200.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a00b0c4c-0639-5594-8f28-45ca0d754dd0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 200.0, 'expense', 'paid', '2025-08-08', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fbe0c3c8-2a74-57b6-8a5c-50ee35373153', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, '2025-08-11', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('96e34f73-dbe2-593a-a636-1be0d6473d50', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fbe0c3c8-2a74-57b6-8a5c-50ee35373153', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 172.17, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('94cfdf9e-3ca6-5587-92c5-cfa62046dad4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EC *MERCADOLIVRE', 172.17, 'expense', 'paid', '2025-08-11', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 6, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('54014994-3984-544d-af82-beab32ec627c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c79b357c-3fdc-5a05-bd4d-7c4818451838', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '54014994-3984-544d-af82-beab32ec627c', '19fee412-7da7-50b1-97b2-8977bae3636e', 4, 74.09, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d1003644-9841-53aa-a0c9-48aadc469d84', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 4, 6, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4cd82424-dca3-5b6c-9e2b-dbb8eb8bc857', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, '2025-10-04', 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('66c3d8eb-b8d0-52a0-9228-ae5e8bbcf859', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4cd82424-dca3-5b6c-9e2b-dbb8eb8bc857', '19fee412-7da7-50b1-97b2-8977bae3636e', 4, 70.17, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('39a519fd-7467-5a72-b809-3921466e004d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'OSMAR NICOLINI SUPERMERCA', 70.17, 'expense', 'paid', '2025-10-04', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 4, 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8632a2aa-087c-56cc-a3f8-c7f584cdf7cb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4de98f59-c900-50c8-be2d-bbe74b1c22ff', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '8632a2aa-087c-56cc-a3f8-c7f584cdf7cb', '19fee412-7da7-50b1-97b2-8977bae3636e', 3, 130.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ecc01672-3235-50fa-8a69-bbc10f0ff259', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 3, 4, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('728198a7-ee24-56d1-904b-e6105edd0fa1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c418009e-3c4d-5b68-bd37-ac1faaf8c4cd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '728198a7-ee24-56d1-904b-e6105edd0fa1', '19fee412-7da7-50b1-97b2-8977bae3636e', 3, 108.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('19eeb7cc-b7a2-5354-9725-8733f3967792', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 3, 5, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('fd11c9e7-071d-5b23-8e4e-683918de1e63', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a4e670a8-3564-555d-9e55-31a82334d652', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'fd11c9e7-071d-5b23-8e4e-683918de1e63', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 71.87, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('09ce62fe-ad9f-5754-a646-da93766815f0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c8b02876-fa8f-5ada-ba36-318d21140092', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('96e044ca-a074-5518-bdd7-69d1c96a7a04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c8b02876-fa8f-5ada-ba36-318d21140092', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 116.88, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('899b19b5-844d-53b4-88ea-712b9df4665a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GAU COZINHA GAUCHA', 116.88, 'expense', 'paid', '2025-11-29', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c0a1b55b-cf3c-5264-a62d-461401747ea3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, '2025-11-29', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ac5cff52-b195-5263-b3ed-df17daf9eeb9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a1b55b-cf3c-5264-a62d-461401747ea3', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 50.49, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c58f1bdc-6f3d-5f0f-bf48-ca917d68f9c5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'FARIA GASTRONOMIA LTDA', 50.49, 'expense', 'paid', '2025-11-29', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f598f8eb-4a9c-5afe-bb5e-a8230b63d0f7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, '2025-11-30', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('616e1a81-3c9a-563e-bc85-55029687fefb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f598f8eb-4a9c-5afe-bb5e-a8230b63d0f7', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 63.18, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('40cc418f-b43d-5046-a641-7156d4f88a49', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*COSTELLONE', 63.18, 'expense', 'paid', '2025-11-30', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d3ad98a2-b13a-5185-b751-2035c23478a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('711e390d-21fb-5055-9b2c-45e0e8627553', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd3ad98a2-b13a-5185-b751-2035c23478a7', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 42.48, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4b41c632-d8f5-59d0-8d5e-ea08d15da1bc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0184d252-3e4d-5b69-8bb5-ddf35e4cf7c1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0bf8d096-f27e-5b08-ae87-a69be9f2e950', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0184d252-3e4d-5b69-8bb5-ddf35e4cf7c1', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 42.19, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('78153347-2ef6-57a2-a94c-d123173564be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('d76e3c21-f103-5664-ad7e-08f953271901', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, '2025-12-19', 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('fddd822d-0e4b-5d9c-b754-27e8a18952e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'd76e3c21-f103-5664-ad7e-08f953271901', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 81.93, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8337f025-8512-5028-a1c7-df6e45e871e2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, 'expense', 'paid', '2025-12-19', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 2, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b144afed-094b-5ba6-8a7d-820d90d0431c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c9f8bca5-641f-50ed-a1ab-6473a753e1bb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b144afed-094b-5ba6-8a7d-820d90d0431c', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 32.43, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('43c021d8-1790-5cfe-8b54-ababb54a939b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f0c46fc7-655f-578b-b481-326746cdb3c7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3922f84b-fc38-5c9a-808d-04f3720f10e6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f0c46fc7-655f-578b-b481-326746cdb3c7', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 59.02, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4f63cf4e-b1bf-532c-9399-cb31d56109d8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5489bb6f-94a4-5e63-804f-76203d20196d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('29008715-ce4a-5b0b-9d64-08d7ec900788', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5489bb6f-94a4-5e63-804f-76203d20196d', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 31.08, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7d44d4ce-7eae-55e1-86f8-79111a5bd93b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('468e45f4-55ac-5330-8459-471715acac45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('57297785-26dc-50b7-86e4-7c907a80e158', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '468e45f4-55ac-5330-8459-471715acac45', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 71.77, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c2c2b08a-ab4b-5e29-a44a-3e7055693d91', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4f4fe9c2-1767-56c9-b58a-54c82b79c188', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9c0a33dc-9005-553b-a89a-ab20542af6f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4f4fe9c2-1767-56c9-b58a-54c82b79c188', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 82.2, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('868cc987-e366-57b7-949a-0796ca9dea24', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 12, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('64cb0e56-3b76-5047-941d-84c3f21216e6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, '2025-12-14', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2520079a-6b6c-5e67-8d90-a3264deafb08', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '64cb0e56-3b76-5047-941d-84c3f21216e6', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 50.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b2c901dd-aa0b-56f6-89de-8ae62ebf31e4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'ABASTECEDORA JKE', 50.0, 'expense', 'paid', '2025-12-14', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('89d929e9-3980-5cef-af5f-16e0b297592d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 117.96, '2025-12-16', 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('54857044-6706-5ff0-aec9-e2e1e209a609', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '89d929e9-3980-5cef-af5f-16e0b297592d', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 117.96, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7b036c94-a5f2-5f71-8370-4b41aeebca42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 117.96, 'expense', 'paid', '2025-12-16', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('dfdf5d4f-46d2-5856-a153-e636d7085163', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 15.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b7180bd2-1f60-50b9-af77-a0d60935bee7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'dfdf5d4f-46d2-5856-a153-e636d7085163', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 15.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b8bf85a7-a4c5-5a2c-b2dc-4506fef1db83', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 15.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('500989d2-c7a9-50b1-9e5e-58e75918a02d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 31.95, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e1ab109f-7485-547f-8ee6-83d7d968426c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '500989d2-c7a9-50b1-9e5e-58e75918a02d', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 31.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c657c952-8c93-5dd2-8b42-9e78b0eb5f93', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ESPETINO PELOTAS', 31.95, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bccfb85f-923e-5e58-bfcf-0a238ee0ae26', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TYAMY', 9.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c5aa78ae-31a0-5de7-bf74-83bcd817b6d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bccfb85f-923e-5e58-bfcf-0a238ee0ae26', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 9.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('361489fc-5856-5deb-a92e-1ccd433e38ea', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TYAMY', 9.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('72ed60c5-9508-5d8e-87cf-116a489e75f6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ACOUGUEDOSSANTOS', 21.0, '2025-12-17', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0d8d99ee-f24f-5bb4-a525-780f599729a0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '72ed60c5-9508-5d8e-87cf-116a489e75f6', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 21.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ec80442f-ccb5-506f-85ad-de4b39026ebe', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ACOUGUEDOSSANTOS', 21.0, 'expense', 'paid', '2025-12-17', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ccccaa2d-a1a6-5f4d-ba98-d081cb6eabc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 50.0, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('62a28896-d2ad-579c-9fb7-cf07643d7d2e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ccccaa2d-a1a6-5f4d-ba98-d081cb6eabc5', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 50.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('aaaeabe5-cec3-59bf-b479-e54a5a61a244', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 50.0, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bc1e01fd-9f7c-5852-83d4-f49f72fb5289', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 117.15, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8e2b3ef5-fcf4-533f-aac9-80f7b8a6c0e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bc1e01fd-9f7c-5852-83d4-f49f72fb5289', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 117.15, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cbd8befb-d63c-50a3-9f44-3439987c11de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 117.15, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('134ba2f7-b4c2-5260-8b89-1f91fe5aff77', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, '2025-12-18', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('68f8c068-13ca-5c9e-827c-c0ff6760185a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '134ba2f7-b4c2-5260-8b89-1f91fe5aff77', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 9.5, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('79e79356-5b27-5e62-b273-3e1fd6f55908', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 9.5, 'expense', 'paid', '2025-12-18', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('322ff40e-c1db-52bf-97f2-76d3021300ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 43.85, '2025-12-19', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f6e22e06-eb3f-5cb7-a5f5-37fa7f77bdd4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '322ff40e-c1db-52bf-97f2-76d3021300ba', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 43.85, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('75f88445-62d0-5d5d-9e47-220d53a48d34', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'BMB *EQUATORIAL', 43.85, 'expense', 'paid', '2025-12-19', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('de997fe2-f7fa-5c23-8faf-616542b2c263', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*PETIT POA BUFFET EVE', 29.53, '2025-12-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ba476309-025f-5244-80c2-f90a92ba1298', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'de997fe2-f7fa-5c23-8faf-616542b2c263', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 29.53, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('09bd8179-21f6-5649-8646-1db70515bf8e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*PETIT POA BUFFET EVE', 29.53, 'expense', 'paid', '2025-12-20', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ec5e2821-157a-5a5a-b06e-2539dde7d4bb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 45.8, '2025-12-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0a6043fc-f2a9-5643-bf81-404b169023d3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ec5e2821-157a-5a5a-b06e-2539dde7d4bb', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 45.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a6547cf7-9399-50be-ae4a-b4f7bd71544a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'DFEIRA MIXFOOD', 45.8, 'expense', 'paid', '2025-12-21', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9506553b-0e92-5bf0-b0d4-b9d2ada9b83e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CALAUFABIAOFABIAO', 64.9, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e8b3f98e-9859-50fc-9d63-892bb6ad422f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9506553b-0e92-5bf0-b0d4-b9d2ada9b83e', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 64.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('33f0dc70-d058-5c2d-ad25-27d32413556e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CALAUFABIAOFABIAO', 64.9, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('36f89611-2397-5414-8534-dd42d0a37d52', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'BRAPEL COMERCIO DE ALI', 15.8, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c6de1260-c243-54dc-8e0b-d98f3bd32646', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '36f89611-2397-5414-8534-dd42d0a37d52', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 15.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6622aa40-bcf2-5637-96a7-eeaa1e6aa7db', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'BRAPEL COMERCIO DE ALI', 15.8, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('df651975-5b9b-5037-b4dc-76c824dd9c45', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 39.99, '2025-12-23', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aceb74b0-00a0-58d3-bfb4-d06680d39f0c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'df651975-5b9b-5037-b4dc-76c824dd9c45', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 39.99, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('49ae12d8-dfc5-5b34-b59f-e729fcffd3a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 39.99, 'expense', 'paid', '2025-12-23', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9b2472bd-f521-5ddf-bd26-1b9e5c91fffc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAA PORTO ALEGRE AEROP', 14.4, '2025-12-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('88df57ed-505a-5e95-9c04-9b813e60069d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9b2472bd-f521-5ddf-bd26-1b9e5c91fffc', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 14.4, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6a0aec7c-574f-5659-9e96-ba0499b1f710', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'PAA PORTO ALEGRE AEROP', 14.4, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0b9ca705-5177-535b-bf6e-c754a6ed4ef1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 90.06, '2025-12-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8c7f8a2a-6cab-5ea6-858c-8bed1ad73d7c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '0b9ca705-5177-535b-bf6e-c754a6ed4ef1', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 90.06, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4204a38b-3275-5259-99e3-23ec51eb558e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 90.06, 'expense', 'paid', '2025-12-24', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('72a914aa-f7cf-55ef-9956-01aee50cde2d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 49.8, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8ba1702c-c9b5-5641-97b9-2985d32dd1ba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '72a914aa-f7cf-55ef-9956-01aee50cde2d', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 49.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fd10d229-d724-5b1f-bbbb-5917a57c3dd7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BURGER KING', 49.8, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a691b6bb-fd9e-56a9-806d-b995abf5a05f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'NUTRY FOOD', 14.99, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('30e7e341-20ed-597b-a63a-5c93e562e278', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a691b6bb-fd9e-56a9-806d-b995abf5a05f', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 14.99, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9a588d3f-b2fa-5c1c-a893-4d7b162411be', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'NUTRY FOOD', 14.99, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('959ecd5e-86d7-552d-81df-dd0c3a199b76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'COXINHAS EXPRESS', 10.83, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1ca202e8-8bb3-5082-be32-6298fde676b4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '959ecd5e-86d7-552d-81df-dd0c3a199b76', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 10.83, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('21250bdc-a638-57ed-b1c6-dca21fa2e2dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'COXINHAS EXPRESS', 10.83, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('747c5992-14bf-50e7-bead-0c935bfffc94', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 163.9, '2025-12-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('34786f2b-840d-5978-af60-13d21bf72c96', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '747c5992-14bf-50e7-bead-0c935bfffc94', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 163.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('79e68131-bfcb-5378-842b-ffcd739fa9fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 163.9, 'expense', 'paid', '2025-12-26', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('178bf62f-a7dc-5d38-aa7a-383871cef474', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EDEN SUPERMERCADO', 30.58, '2025-12-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('08732c3a-71f7-5223-bb41-daabf8fb28de', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '178bf62f-a7dc-5d38-aa7a-383871cef474', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 30.58, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3d14a2ef-cac8-59c3-992e-b2d066280fd1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'EDEN SUPERMERCADO', 30.58, 'expense', 'paid', '2025-12-27', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('596ccce7-4447-5fd8-8c3c-67177fcaf350', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BALI EMPREENDIMENTOS L', 12.9, '2025-12-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('efecab10-c665-5ad8-b9a4-4caaa3a1dda7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '596ccce7-4447-5fd8-8c3c-67177fcaf350', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 12.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('352ed45e-a11f-5616-bd1c-09997bd29630', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BALI EMPREENDIMENTOS L', 12.9, 'expense', 'paid', '2025-12-29', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9f4d88a7-4fe2-589c-b431-cf303065046c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GRAN COFFEE', 8.0, '2025-12-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('929fd8ac-2bb7-57f6-a061-39e72d994fc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9f4d88a7-4fe2-589c-b431-cf303065046c', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 8.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('752e5e30-d886-53a4-b58b-99022cb214d6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GRAN COFFEE', 8.0, 'expense', 'paid', '2025-12-29', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2186ae19-6a0e-5ce3-917e-8724aa1232bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 86.3, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9052f6e5-ee98-5a52-a264-baa3581d910f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2186ae19-6a0e-5ce3-917e-8724aa1232bd', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 86.3, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d1c46866-bdee-558f-9a71-487008c49a4d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 86.3, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('43e98fc0-c91e-5d81-8fa4-6cfac49ea4ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 3.29, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('abf40d7a-d360-5fd3-968a-60cd3098f94d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '43e98fc0-c91e-5d81-8fa4-6cfac49ea4ca', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 3.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cdf368cf-2c61-5454-8c23-51caaa4ab5b3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 3.29, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('94fdd3b0-89af-5696-9795-4a6e2c4cc1a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SUBWAY XV', 19.9, '2025-12-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('3d884ddf-1789-5010-a62e-f4b6852579bf', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '94fdd3b0-89af-5696-9795-4a6e2c4cc1a1', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 19.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('5b9d7785-f8e6-52e2-acda-b0518a00b54f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SUBWAY XV', 19.9, 'expense', 'paid', '2025-12-30', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('40c62700-e3c8-5ab2-9b0b-09ddae60ce39', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 32.09, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('54bca251-5019-59f0-a7b9-990998280590', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '40c62700-e3c8-5ab2-9b0b-09ddae60ce39', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 32.09, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('20279f8e-6b48-569f-b643-78cc8d957d13', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 32.09, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a02df94c-fb60-5a01-babe-e9e49d975e9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*LOTERIASONLINEJSNX', 30.0, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2a365b9d-d26b-599c-8d88-c05b7cf875bd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a02df94c-fb60-5a01-babe-e9e49d975e9b', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 30.0, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8b0eb126-3d26-5de5-b966-88b967d3da9b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MP*LOTERIASONLINEJSNX', 30.0, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('40a5942b-f646-5811-bb6c-704cdf9feef3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 199.29, '2025-12-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2e7cc7ab-6c07-55e1-a117-3dd3f7bb7a72', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '40a5942b-f646-5811-bb6c-704cdf9feef3', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 199.29, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7500d2a9-809a-55b8-9b13-4bca7aade82f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 199.29, 'expense', 'paid', '2025-12-31', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2e4d4fbf-c413-518b-87f7-080a19c825a7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTOS COQUEIRO', 46.8, '2026-01-01', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0a9b2653-48e4-5683-adaa-0918bb4aadcd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2e4d4fbf-c413-518b-87f7-080a19c825a7', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 46.8, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c2ceb731-8783-523c-b0b3-eaabd10fa5e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'POSTOS COQUEIRO', 46.8, 'expense', 'paid', '2026-01-01', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('26a0c67e-2ce6-53d2-874f-cd61f17ea026', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, '2026-01-06', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dbd8ea37-edfc-5b66-8246-0f4a4625b9b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '26a0c67e-2ce6-53d2-874f-cd61f17ea026', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 39.9, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3e3918e5-ca22-5ab3-b4b0-5269c85508da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'APPLE COM/BILL', 39.9, 'expense', 'paid', '2026-01-06', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e9e96edb-e248-55ed-91a0-d844a0f0709b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD', 7.95, '2026-01-12', 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ee0fcf81-6bb7-5741-b17f-a817ca56779e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e9e96edb-e248-55ed-91a0-d844a0f0709b', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 7.95, '2026-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4d588afd-957a-5482-931b-5e429ae96ba2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFOOD', 7.95, 'expense', 'paid', '2026-01-12', '2026-01-22', '2026-01-22', '19fee412-7da7-50b1-97b2-8977bae3636e', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 01/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-02 (Santander - 22022026.pdf) - R$ 1678.63
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 'b7a6c5d4-3210-9876-edcb-a10293847564', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 2, 2026, '2026-02-12', '2026-02-22', 1678.63, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5e2907bc-7e19-557c-8ad4-ade7c3fbdbf3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.59, '2025-11-28', 3, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0ac2650e-7cb6-56c3-bd31-a60a741b6978', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5e2907bc-7e19-557c-8ad4-ade7c3fbdbf3', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 3, 204.59, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('db9a3d96-14d2-536c-a093-d540331cd5ad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC PELO', 204.59, 'expense', 'paid', '2025-11-28', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 3, 3, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('84844713-3561-5fa7-9c6d-34c1c2f1e7aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, '2025-12-24', 5, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('aad3a3e7-1961-592d-b593-4ffb840bf808', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '84844713-3561-5fa7-9c6d-34c1c2f1e7aa', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 326.43, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('80913df0-ab93-5828-b02b-d2699dd5822a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '486e0678-651e-4083-958d-1955ae38bd61', 'MOVIDA RAC GOAE', 326.43, 'expense', 'paid', '2025-12-24', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 5, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2993583b-a983-5314-98f8-6aa4bd0c494c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, '2026-02-06', 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c2b13f4b-21c9-5236-8cfe-e4dfce5398a4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2993583b-a983-5314-98f8-6aa4bd0c494c', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 120.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3b25fd28-3299-5587-b2d9-dc31a916c96b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ZP*LTDA 62157', 120.0, 'expense', 'paid', '2026-02-06', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 10, 'Cartão Santander SX (Final 2966) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3976f408-d927-571f-b7fa-64164ecac69d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CONTA DE LUZ', 47.18, '2026-01-23', 1, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('828afb44-8df4-538c-b7c3-b5b2be96b7d7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3976f408-d927-571f-b7fa-64164ecac69d', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 47.18, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('a49bb671-8f4f-56dc-bd17-36ff1cc97cf9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CONTA DE LUZ', 47.18, 'expense', 'paid', '2026-01-23', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 2966) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('08dfd1a0-9db8-5e71-aba8-04256fd1253b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, '2025-06-09', 10, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('41978f69-0804-5035-ac2e-1bb9cf13c178', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '08dfd1a0-9db8-5e71-aba8-04256fd1253b', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 9, 67.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ec899049-baf4-58ad-a442-2c470b080463', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'ZP *OLX CSAR SIL60010', 67.48, 'expense', 'paid', '2025-06-09', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 9, 10, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e3e12b31-a439-5cd6-8634-d8ad2225d1ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, '2025-09-18', 6, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8e2da8d6-0618-55a9-8e8b-6509bf8f3fc5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e3e12b31-a439-5cd6-8634-d8ad2225d1ce', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 5, 74.09, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('342ad8cd-aa1b-5cf3-8657-b8c60a834e0a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MIRAVOS RESTAURANTE LT', 74.09, 'expense', 'paid', '2025-09-18', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 5, 6, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('44a34c48-9d43-577f-9608-06d3d91bfb9f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, '2025-10-18', 4, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ed4e5ce0-1cde-5551-b40e-4fe57866a3dd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '44a34c48-9d43-577f-9608-06d3d91bfb9f', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 4, 130.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0fca1f67-c2fa-57c1-a763-01f715c32025', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'L A ALIMENTOS', 130.0, 'expense', 'paid', '2025-10-18', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 4, 4, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('740ecf96-aad7-5708-b1ac-d92c89a3cffc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, '2025-11-04', 5, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('9fac82c5-fc5e-518b-894e-629fbd52d934', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '740ecf96-aad7-5708-b1ac-d92c89a3cffc', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 4, 108.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1171712b-9b0d-5b16-9fc8-20d06a5949ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'TELLERINA COMERCIO DE', 108.0, 'expense', 'paid', '2025-11-04', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 4, 5, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('434d73af-9348-5319-8838-499c2eaead14', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, '2025-11-23', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7e137bb2-7b85-5639-963a-330c4faf2b13', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '434d73af-9348-5319-8838-499c2eaead14', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 3, 71.87, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b373eed7-d6da-55e4-be03-076e9bb8386c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'BAGAGGIO 358 PELOTAS', 71.87, 'expense', 'paid', '2025-11-23', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 3, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f84bc8e-2c2c-5d40-b6ec-4b8b73099ad2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, '2025-12-16', 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8a635ee7-bbfd-56d8-b3c8-e2ffe74fb2f3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f84bc8e-2c2c-5d40-b6ec-4b8b73099ad2', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 42.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6bbc2a24-0b93-5025-80b3-104aaa0c0ca3', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'c0a80101-9999-4444-aaaa-bbbbcccc0001', 'ORIONGESTAODE', 42.48, 'expense', 'paid', '2025-12-16', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | [Despesa Empresa (PJ)] | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1b7304a5-3e3d-57e0-ab41-41bd0a58c133', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, '2025-12-18', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('64f0516c-4918-5a32-ad01-36ab18fb446a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1b7304a5-3e3d-57e0-ab41-41bd0a58c133', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 42.19, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('8455d859-71f5-5475-94d5-d27eb926a1df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '787ece9f-0518-41ec-bb16-d114ee537fed', 'CLARO P*FATURA CLARO', 42.19, 'expense', 'paid', '2025-12-18', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9de6aaee-a95e-5f10-bd56-f8c0bcda0816', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, '2025-12-19', 2, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('bf2c1531-dfbb-59eb-8786-4a80a1126f9d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '9de6aaee-a95e-5f10-bd56-f8c0bcda0816', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 81.93, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('4894fb94-381a-5966-bdf3-cdb1ae9af404', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 81.93, 'expense', 'paid', '2025-12-19', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 2, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2b158233-f5b0-5591-bbdb-9a77492c9819', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, '2025-12-24', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('e5ffba45-fbc6-503b-84de-49fd001147b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2b158233-f5b0-5591-bbdb-9a77492c9819', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 32.43, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6d9fd9e-017f-5df7-8677-b1a0c97aa79e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'QSQ PH GUARULHOS 0T02L', 32.43, 'expense', 'paid', '2025-12-24', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ed904d16-ebc4-5a4b-9531-8c389aaf781d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, '2025-12-26', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('905843a5-71e4-5154-b32b-9e55139a5bcc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ed904d16-ebc4-5a4b-9531-8c389aaf781d', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 59.02, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('178f9b6e-bd7e-5c4f-a58e-6028351b8451', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KENKYO COZINHA ORIENTA', 59.02, 'expense', 'paid', '2025-12-26', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('57864807-dc92-5f0f-a0d6-7551fa9ce8c9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, '2025-12-30', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('537e03fd-e314-545a-93bd-faadc29cb35f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '57864807-dc92-5f0f-a0d6-7551fa9ce8c9', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 31.08, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c1158eef-55a1-51c1-995a-beb091554b7e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 31.08, 'expense', 'paid', '2025-12-30', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('5bf670eb-ffba-5990-840c-df5f3c48b836', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, '2025-12-31', 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a75eb21a-85d6-5b8a-8437-e055a0db9449', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '5bf670eb-ffba-5990-840c-df5f3c48b836', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 71.77, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('1f08b12b-16ed-5810-99db-3254b0aa7c04', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'GB MIX QUARTIER', 71.77, 'expense', 'paid', '2025-12-31', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 3, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('894129cc-eec6-5423-a0aa-fb95e3c22c23', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, '2026-01-13', 12, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('0e5b3b2e-b2c1-57eb-97c0-e864ef76b396', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '894129cc-eec6-5423-a0aa-fb95e3c22c23', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 82.2, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('31d33784-2ab7-5dc1-b87f-811198fc1ce2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'SHOPEE *RSAUTOPECAS', 82.2, 'expense', 'paid', '2026-01-13', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 2, 12, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6cbf6f47-f971-5c3d-a956-c2aa4a0c319e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.0, '2026-01-20', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('c8eef12c-869c-5371-b248-dc9cfd204123', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6cbf6f47-f971-5c3d-a956-c2aa4a0c319e', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 15.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7185a1ee-66c0-5693-aa88-fcbc3d7c5c1f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 15.0, 'expense', 'paid', '2026-01-20', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e4b70556-abac-5908-b555-2094b4470fad', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, '2026-01-21', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('41809b04-9a0b-514e-9e9f-fe017ae1690b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e4b70556-abac-5908-b555-2094b4470fad', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 129.9, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('df2d969d-80bd-5a97-95b6-62406a10a2aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'SKY FIT PELOTAS', 129.9, 'expense', 'paid', '2026-01-21', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1d4bbe11-5f7c-548d-a0a3-a071b50ad51a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 70.0, '2026-01-22', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1edd3312-1bf2-55b5-8a9e-e15713ca5802', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1d4bbe11-5f7c-548d-a0a3-a071b50ad51a', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 70.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('97195ecb-3aaf-5784-acaa-42fe00b51c66', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONVENIENCIAJJ', 70.0, 'expense', 'paid', '2026-01-22', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('4b965c2f-2127-5e31-9f46-0489cf6b5b56', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAITON SALGADOS', 27.5, '2026-01-24', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a3564c8e-a32e-5c5b-9a47-e62b9348e7aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '4b965c2f-2127-5e31-9f46-0489cf6b5b56', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 27.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6e913280-f654-5b2e-94ed-b0f979cbdf61', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAITON SALGADOS', 27.5, 'expense', 'paid', '2026-01-24', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2477070e-6b50-59cc-b130-1e098dc81928', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 52.16, '2026-01-25', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('b5d5ae88-a7c5-53b5-9c03-7d9a363fac42', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '2477070e-6b50-59cc-b130-1e098dc81928', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 52.16, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('29e59d8a-535f-576a-b995-f62101c2e3e5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 52.16, 'expense', 'paid', '2026-01-25', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f3d05b4-6f02-543e-9757-5a8313fc6412', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 25.85, '2026-01-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dd821756-b950-5e5d-a179-885ea5bb5b2d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3f3d05b4-6f02-543e-9757-5a8313fc6412', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 25.85, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('22dd3c1c-0b0b-5c25-aa7d-0ababdc4ca5b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'SUPERMERCADO GUANABARA', 25.85, 'expense', 'paid', '2026-01-26', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('b95b6d84-af33-5026-8093-4eeebb7c33e7', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 7.0, '2026-01-26', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('849b3594-6ade-5da0-94b8-2f5387bf76e8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'b95b6d84-af33-5026-8093-4eeebb7c33e7', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 7.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('bf789f06-2db6-5a4b-850e-6f8f4a8c7667', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 7.0, 'expense', 'paid', '2026-01-26', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f42a999f-beec-58a4-b1d0-cdb9b5435233', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, '2026-01-27', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('23988076-c834-5132-ad29-b0e22ba384ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'f42a999f-beec-58a4-b1d0-cdb9b5435233', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 19.8, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fdbaa225-c02e-5690-b0b5-95b9e20ea281', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, 'expense', 'paid', '2026-01-27', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('bd125e04-d762-5e0d-8b44-6f643fa8eda5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1734a5d4-05ee-5aff-94fb-945b0b416dd2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'bd125e04-d762-5e0d-8b44-6f643fa8eda5', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 50.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3905b5e0-9c95-5b6d-be68-54746b34e577', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'HLANGFILHO', 50.0, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('92be3372-ae38-532e-a98f-b4d9c2e83872', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 19.61, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('50e0d1af-ee2d-5512-9cc2-06767953a8a9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '92be3372-ae38-532e-a98f-b4d9c2e83872', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 19.61, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('811c1fb4-7043-5f27-b036-c9d6e30c5eed', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 19.61, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ad2e9a18-2d59-51d1-9a56-4a8c1dccc76e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ef86b24b-f196-5305-832c-701ea8d595b9', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'ad2e9a18-2d59-51d1-9a56-4a8c1dccc76e', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 12.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('99359886-1e1b-5ffc-aed0-22237ceddca2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'EDMARIGANSIDE', 12.0, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('103cd88f-035b-5482-b3c5-e2e7bcdde6ca', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.38, '2026-01-28', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('95dab0ae-19d0-5357-b491-b936bccd32b1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '103cd88f-035b-5482-b3c5-e2e7bcdde6ca', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 8.38, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('185e699f-a25a-507d-8826-e785338087da', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 8.38, 'expense', 'paid', '2026-01-28', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a9f91e12-a273-54bf-ab78-bdf5f98699fd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, '2026-01-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('a60b9c23-4409-5a06-8f25-d2fc5772aafd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'a9f91e12-a273-54bf-ab78-bdf5f98699fd', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 19.8, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('59ffe67d-8c67-5527-92f1-876ec31c7eec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '334d3509-9536-47f2-8367-4521038b454d', 'PANVEL FARMACIAS', 19.8, 'expense', 'paid', '2026-01-29', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('e33406e2-03a5-581d-89ab-7dd00ced762d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.76, '2026-01-29', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('371941b8-cbbe-58d9-b100-414b98f6d803', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', 'e33406e2-03a5-581d-89ab-7dd00ced762d', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 17.76, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('03147b20-ddcf-5acc-b7b3-da9dcf49c127', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CARREFOUR PELOTAS GENE', 17.76, 'expense', 'paid', '2026-01-29', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('07e3e4cf-c643-59d8-b0a1-257d60044a0e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 24.0, '2026-01-30', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6661c6f2-acda-5200-ba0b-b16170bd6046', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '07e3e4cf-c643-59d8-b0a1-257d60044a0e', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 24.0, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('ccec0c72-0393-5bd8-a111-1023d2a3587c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'JOAOBATISTAVIEIRA', 24.0, 'expense', 'paid', '2026-01-30', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('85674b00-ed55-53c7-a270-a6bc83bb4dfb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MARILEIAFIORIDASI', 28.5, '2026-01-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('ecb161ae-514a-5455-9df4-cf7ac45b7a36', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '85674b00-ed55-53c7-a270-a6bc83bb4dfb', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 28.5, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('da7fe05d-8815-5fe6-ba15-4d4b7f7ce866', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'MARILEIAFIORIDASI', 28.5, 'expense', 'paid', '2026-01-31', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1abfda04-b8e9-5c21-a1c6-9d2bb6056e16', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAIRTON HOLZ PORATH 0', 36.2, '2026-01-31', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('f608ffdb-bd0c-5f4f-a561-be71865ae04d', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '1abfda04-b8e9-5c21-a1c6-9d2bb6056e16', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 36.2, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('b5f2014d-8eb5-5dc9-a554-e68ef0684f88', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CLAIRTON HOLZ PORATH 0', 36.2, 'expense', 'paid', '2026-01-31', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3b72c874-081a-5239-a9e6-81b61ae9f160', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 20.48, '2026-02-09', 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('97813f5a-6e63-5a31-a376-4215ef439078', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'c8b7a6d5-4321-0987-fedc-b21304958675', '3b72c874-081a-5239-a9e6-81b61ae9f160', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 20.48, '2026-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fe680aec-e848-5845-9faa-b97edf73b500', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'b7a6c5d4-3210-9876-edcb-a10293847564', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'IFD*RESTAURANTE CASEIRO L', 20.48, 'expense', 'paid', '2026-02-09', '2026-02-22', '2026-02-22', '1f4fa6ab-190e-5f96-9b5d-ec56a01b841d', 1, 1, 'Cartão Santander SX (Final 8876) | Fatura 02/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

COMMIT;
