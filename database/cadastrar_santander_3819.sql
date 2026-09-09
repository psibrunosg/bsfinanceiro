SET client_encoding = 'UTF8';
BEGIN;

-- 1. Conta Técnica do Cartão Santander SX (Final 3819)
INSERT INTO accounts (id, workspace_id, owner_id, name, type, initial_balance, active, is_system, is_shared, created_at)
VALUES ('d8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Cartão Santander SX (Final 3819)', 'credit_card', 0.00, true, false, false, NOW())
ON CONFLICT (id) DO NOTHING;

-- 2. Cartão de Crédito Santander SX (Final 3819)
INSERT INTO credit_cards (id, account_id, workspace_id, owner_id, name, brand, last_four, credit_limit, limit_amount, closing_day, due_day, created_at)
VALUES ('e9d8c7b6-5432-9876-fedc-ba0987654321', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'Santander SX', 'Visa', '3819', 550.00, 550.00, 15, 22, NOW())
ON CONFLICT (id) DO UPDATE SET credit_limit = 550.00, limit_amount = 550.00, closing_day = 15, due_day = 22;

-- ===========================================================================
-- Fatura 2024-12 (fatura 12122024.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('c349f9b4-bfa5-4f78-af00-5f0f73cba7d9', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 12, 2024, '2024-12-05', '2024-12-12', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('158cc829-4314-4be6-ab2d-500d331c56ce', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.68, '2024-11-30', 3, 'Cartão Santander SX (Final 3819) | Fatura 12/2024', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('36c36540-aa8c-4973-8ac5-51351d8c66df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '158cc829-4314-4be6-ab2d-500d331c56ce', 'c349f9b4-bfa5-4f78-af00-5f0f73cba7d9', 1, 116.68, '2024-12-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c6c6429f-1b0c-4d5d-b9f8-5e77d88923aa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.68, 'expense', 'paid', '2024-11-30', '2024-12-12', '2024-12-12', 'c349f9b4-bfa5-4f78-af00-5f0f73cba7d9', 1, 3, 'Cartão Santander SX (Final 3819) | Fatura 12/2024', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-01 (fatura 12012025.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('46a78151-4b95-422c-8f69-63b8aff50c37', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 1, 2025, '2025-01-06', '2025-01-12', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('9b87b722-7d46-4cf4-b037-bf4bb7779e48', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.68, '2024-11-30', 3, 'Cartão Santander SX (Final 3819) | Fatura 01/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('10424aa2-bd65-4cfc-bc16-0b793994ed4f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '9b87b722-7d46-4cf4-b037-bf4bb7779e48', '46a78151-4b95-422c-8f69-63b8aff50c37', 2, 116.68, '2025-01-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('732dd933-c8da-455c-87a0-bddf4d1e315f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.68, 'expense', 'paid', '2024-11-30', '2025-01-12', '2025-01-12', '46a78151-4b95-422c-8f69-63b8aff50c37', 2, 3, 'Cartão Santander SX (Final 3819) | Fatura 01/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-02 (fatura 12022025.pdf) - R$ 300.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('88e58505-d085-4183-8d26-3fe9b9a6079c', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 2, 2025, '2025-02-05', '2025-02-12', 300.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('523f1d6c-7c41-4305-9897-39eecd83a5eb', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.66, '2024-11-30', 3, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('45ef3388-51b2-4507-a4cf-8be347eafab0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '523f1d6c-7c41-4305-9897-39eecd83a5eb', '88e58505-d085-4183-8d26-3fe9b9a6079c', 3, 116.66, '2025-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('d025f72b-9748-4d33-825f-9f1eec7f961b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'ATACADAO 0865 AS', 116.66, 'expense', 'paid', '2024-11-30', '2025-02-12', '2025-02-12', '88e58505-d085-4183-8d26-3fe9b9a6079c', 3, 3, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('3f23706d-a9cd-45a3-9c4c-aa04f88874a2', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '486e0678-651e-4083-958d-1955ae38bd61', 'LUBRISUL', 133.67, '2025-01-06', 2, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('13bde7bf-fb45-4c3a-98c1-72cc8e8d433c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '3f23706d-a9cd-45a3-9c4c-aa04f88874a2', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 133.67, '2025-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('e63b88da-82fb-4093-bcc1-d17d53e908f1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '486e0678-651e-4083-958d-1955ae38bd61', 'LUBRISUL', 133.67, 'expense', 'paid', '2025-01-06', '2025-02-12', '2025-02-12', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 2, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('480276a5-9143-4ca5-baa4-e86948c048dc', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KAMILAGONCALVES', 56.5, '2025-01-07', 1, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('dc76856d-6690-4308-91e3-1ac2aae131c4', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '480276a5-9143-4ca5-baa4-e86948c048dc', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 56.5, '2025-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('686858eb-c1ed-495a-93f1-37707be7beae', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'KAMILAGONCALVES', 56.5, 'expense', 'paid', '2025-01-07', '2025-02-12', '2025-02-12', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 1, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f26a5a3c-1fd7-478d-b059-08c74362958c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM PEDRITO', 100.0, '2025-01-08', 1, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('352ff597-4117-45b0-9ea0-7218c7381c72', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'f26a5a3c-1fd7-478d-b059-08c74362958c', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 100.0, '2025-02-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('3d52f84f-e2c5-4cd3-bb6e-6b2b2592cbb1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '486e0678-651e-4083-958d-1955ae38bd61', 'SIM DOM PEDRITO', 100.0, 'expense', 'paid', '2025-01-08', '2025-02-12', '2025-02-12', '88e58505-d085-4183-8d26-3fe9b9a6079c', 1, 1, 'Cartão Santander SX (Final 3819) | Fatura 02/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-03 (fatura 22032025.pdf) - R$ 382.58
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('685055c4-87fe-427e-a53e-2e2f9766c7e2', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 3, 2025, '2025-03-17', '2025-03-22', 382.58, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('c2d93496-c6c6-4388-8393-f51201532c7f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '486e0678-651e-4083-958d-1955ae38bd61', 'LUBRISUL', 133.66, '2025-01-06', 2, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('2428e93e-a006-4288-82e0-e561e3864982', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'c2d93496-c6c6-4388-8393-f51201532c7f', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 2, 133.66, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('7efb7c43-a537-4d85-9f03-7619d651ff7a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '486e0678-651e-4083-958d-1955ae38bd61', 'LUBRISUL', 133.66, 'expense', 'paid', '2025-01-06', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 2, 2, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('2e040e10-0a76-4ccf-ab44-e10d4185ae43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 17.06, '2025-02-17', 1, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('33934e14-045b-4668-84e5-8378bcaeec1a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '2e040e10-0a76-4ccf-ab44-e10d4185ae43', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 17.06, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('cdd5d016-8ddb-4956-9381-fd61bbe3ce76', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 17.06, 'expense', 'paid', '2025-02-17', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('a7f0f9ed-57f6-4b66-8f05-5aeea6af2216', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '486e0678-651e-4083-958d-1955ae38bd61', 'BUFFON 18', 61.9, '2025-02-26', 1, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8ac21ca1-8471-4509-a5d6-6a0ba6dcc857', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'a7f0f9ed-57f6-4b66-8f05-5aeea6af2216', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 61.9, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('fb59c73c-be02-4b5f-83d9-ae1816fd1b81', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '486e0678-651e-4083-958d-1955ae38bd61', 'BUFFON 18', 61.9, 'expense', 'paid', '2025-02-26', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 3819) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('13a77449-34f2-4c7e-acc5-9e4659226b53', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 32.65, '2025-02-17', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('8b4ddd7d-e484-4d63-84ee-9745b718ddba', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '13a77449-34f2-4c7e-acc5-9e4659226b53', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 32.65, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('30c72b3d-eb2c-4e89-b369-a419d910ccaa', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'JAMIELMOHAMAD', 32.65, 'expense', 'paid', '2025-02-17', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('36d02a48-3ff0-439b-81ec-2c133e1f8a00', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CRISTIANEMULLERRO', 20.0, '2025-02-27', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('90b444f0-f5d9-4770-a5f5-c3b754c965c0', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '36d02a48-3ff0-439b-81ec-2c133e1f8a00', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 20.0, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('6bc9a041-c48f-4fc6-80aa-39364e94e2a1', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'CRISTIANEMULLERRO', 20.0, 'expense', 'paid', '2025-02-27', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('1dc0e3c7-fb9d-4de8-97a6-ec5fe2e3b02f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LEONAMARALPEREIRA', 37.7, '2025-02-28', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('7e95172c-7914-4114-aa7a-102ba2c3ab2f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '1dc0e3c7-fb9d-4de8-97a6-ec5fe2e3b02f', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 37.7, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c3ec044f-a200-4866-9cbc-2ca4159fde43', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'LEONAMARALPEREIRA', 37.7, 'expense', 'paid', '2025-02-28', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('0bb4b486-beff-4f1b-bb23-7e731ecdd568', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 22.97, '2025-02-28', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('d7116170-438a-4615-91c9-ff86866f6dc6', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '0bb4b486-beff-4f1b-bb23-7e731ecdd568', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 22.97, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('09bacc05-65a9-4f30-b8d4-dd39a55fb44e', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', '40169-CARREFOUR NPO PE', 22.97, 'expense', 'paid', '2025-02-28', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('6223ee4a-d943-4159-8eef-1e9c438d3727', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 32.45, '2025-02-28', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f3cfa57-6bd2-48b6-80ef-fd554655a0df', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6223ee4a-d943-4159-8eef-1e9c438d3727', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 32.45, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('01c69f31-24b4-4e8f-a68a-40b846551cdd', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '486e0678-651e-4083-958d-1955ae38bd61', 'PAULO MOREIRA', 32.45, 'expense', 'paid', '2025-02-28', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f11b6a0e-ecf6-4d3f-a7d9-9b182c338e86', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'NUESTRO GUSTO', 24.19, '2025-03-02', 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('6ad32b8f-5790-40ae-97f0-94704ad11f22', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'f11b6a0e-ecf6-4d3f-a7d9-9b182c338e86', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 24.19, '2025-03-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0e28a956-31c0-4e86-8bc4-2483315b1f8b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'NUESTRO GUSTO', 24.19, 'expense', 'paid', '2025-03-02', '2025-03-22', '2025-03-22', '685055c4-87fe-427e-a53e-2e2f9766c7e2', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 03/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-04 (fatura 22042025.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('68574a86-56de-4686-bd0b-0f3608f6b427', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 4, 2025, '2025-04-11', '2025-04-22', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('79894a2b-76f1-45b0-b3ba-e2fe712e4b35', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 3.0, '2025-03-18', 1, 'Cartão Santander SX (Final 0614) | Fatura 04/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('1ba8cd30-2ac9-4ce1-bf8b-9ad89a4a7b4c', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '79894a2b-76f1-45b0-b3ba-e2fe712e4b35', '68574a86-56de-4686-bd0b-0f3608f6b427', 1, 3.0, '2025-04-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c9cbdb77-b481-4de6-949d-a4f80af74682', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', 'e35db615-21f0-48de-90e2-b156819af5f9', 'CONFEITARIA BEROLA DOCES', 3.0, 'expense', 'paid', '2025-03-18', '2025-04-22', '2025-04-22', '68574a86-56de-4686-bd0b-0f3608f6b427', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 04/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2025-09 (fatura 22092025.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('e093d649-a1c5-4399-a429-c4d4a4401887', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 9, 2025, '2025-09-15', '2025-09-22', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('8c940149-8d6f-47f5-a0e9-f24a8d8a081a', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 12.45, '2025-08-21', 1, 'Cartão Santander SX (Final 0614) | Fatura 09/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('127e95fa-6baa-4e0d-a4c6-6651c21fc0ec', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '8c940149-8d6f-47f5-a0e9-f24a8d8a081a', 'e093d649-a1c5-4399-a429-c4d4a4401887', 1, 12.45, '2025-09-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('c8899d6d-8919-4798-b556-b1ebda30506f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'STEAM', 12.45, 'expense', 'paid', '2025-08-21', '2025-09-22', '2025-09-22', 'e093d649-a1c5-4399-a429-c4d4a4401887', 1, 1, 'Cartão Santander SX (Final 0614) | Fatura 09/2025', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-07 (fatura 22072026.pdf) - R$ 50.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('212cdf66-6a24-45e9-b517-6a803ff8b61e', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 7, 2026, '2026-07-15', '2026-07-22', 50.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('f6de45ba-2bcc-434a-9a6a-c9e656c3edf8', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GIRAOSPORTCENTER', 50.0, '2026-07-09', 11, 'Cartão Santander SX (Final 3819) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('4f0707b1-395e-4466-8e33-1f99f8602bb5', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'f6de45ba-2bcc-434a-9a6a-c9e656c3edf8', '212cdf66-6a24-45e9-b517-6a803ff8b61e', 1, 50.0, '2026-07-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('0571706d-0bd8-4c3a-9b7b-6b2218db9883', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GIRAOSPORTCENTER', 50.0, 'expense', 'paid', '2026-07-09', '2026-07-22', '2026-07-22', '212cdf66-6a24-45e9-b517-6a803ff8b61e', 1, 11, 'Cartão Santander SX (Final 3819) | Fatura 07/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ===========================================================================
-- Fatura 2026-08 (fatura 22082026.pdf) - R$ 0.00
-- ===========================================================================
INSERT INTO credit_card_invoices (id, account_id, workspace_id, owner_id, credit_card_id, month, year, closing_date, due_date, total_amount, status, created_at)
VALUES ('04d10e8f-f519-424d-8067-020300e0f4f0', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 8, 2026, '2026-08-17', '2026-08-22', 0.0, 'paid', NOW())
ON CONFLICT (id) DO NOTHING;

INSERT INTO credit_card_purchases (id, workspace_id, owner_id, credit_card_id, category_id, description, total_amount, purchased_on, installment_count, notes, created_at, updated_at)
VALUES ('ad3d81a8-cd53-4afb-b9ea-6f2b279aa770', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GIRAOSPORTCENTER', 49.99, '2026-07-09', 11, 'Cartão Santander SX (Final 3819) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO credit_card_installments (id, workspace_id, owner_id, credit_card_id, purchase_id, invoice_id, installment_number, amount, competence_date, created_at, updated_at)
VALUES ('37f8adae-326a-4c0d-b06c-4b83aba6f06f', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'e9d8c7b6-5432-9876-fedc-ba0987654321', 'ad3d81a8-cd53-4afb-b9ea-6f2b279aa770', '04d10e8f-f519-424d-8067-020300e0f4f0', 2, 49.99, '2026-08-01', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;
INSERT INTO transactions (id, workspace_id, owner_id, account_id, category_id, description, amount, type, status, competence_date, due_date, paid_at, invoice_id, installment_current, installment_total, notes, created_at, updated_at)
VALUES ('9febdc8d-987b-469a-add5-6b8c5f80376b', '0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', 'd8c7b6a5-4321-8765-fedc-ba9876543210', '6e3b6e65-54b3-4d53-baf1-66aa24eb5f7f', 'GIRAOSPORTCENTER', 49.99, 'expense', 'paid', '2026-07-09', '2026-08-22', '2026-08-22', '04d10e8f-f519-424d-8067-020300e0f4f0', 2, 11, 'Cartão Santander SX (Final 3819) | Fatura 08/2026', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

COMMIT;
