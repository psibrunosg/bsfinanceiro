-- Cadastro do Contracheque de Agosto/2026 - Nova Era Comércio e Terceirizações Ltda
-- Arquivo origem: G:\Meu Drive\Documentos\Financeiro e Pessoal\Holerites\Nova Era\2026\Contracheque NE 08_26.pdf
-- Vencimentos: R$ 2.053,69 (Salário Base R$ 2.031,60 + HE 50% R$ 21,19 + Arredondamento R$ 0,90)
-- Descontos: R$ 543,83 (Consignado 6/12 R$ 299,14 + INSS R$ 160,43 + VR R$ 83,30 + Arred. Anterior R$ 0,96)
-- Valor Líquido: R$ 1.509,86
-- Data de Pagamento: 04/09/2026

BEGIN;

DO $$
DECLARE
  v_tx_id UUID;
  v_workspace_id UUID := '0530a9a3-843d-4832-b919-6b9380310c9a';
  v_owner_id UUID := '15d36040-32aa-448b-a34d-43017cde51a7';
  v_account_id UUID := '562aea75-4337-4b49-958a-eff212cc2cc7'; -- Caixa Econômica Federal (Salário)
  v_category_id UUID := '789ef8d9-03a8-45be-9e9c-dc83c4443686'; -- Salários / Rendimentos
BEGIN

  -- 1. Transação financeira
  INSERT INTO transactions (
    workspace_id,
    owner_id,
    account_id,
    category_id,
    type,
    status,
    description,
    amount,
    interest_amount,
    competence_date,
    paid_at,
    notes
  ) VALUES (
    v_workspace_id,
    v_owner_id,
    v_account_id,
    v_category_id,
    'income',
    'paid',
    'Contracheque - Folha Mensal - Nova Era Comércio e Terceirizações Ltda',
    1509.86,
    0.00,
    '2026-08-01',
    '2026-09-04',
    'Bruto: R$ 2053.69 (HE R$ 21,19) | Descontos: Consignado (6/12) R$ 299,14, INSS R$ 160,43, VR R$ 83,30 (Total Descontos: R$ 543,83) | Líquido: R$ 1509.86 | Arquivo: Contracheque NE 08_26.pdf'
  ) RETURNING id INTO v_tx_id;

  -- 2. Registro do contracheque
  INSERT INTO payslips (
    workspace_id,
    owner_id,
    employer,
    competence,
    gross_amount,
    discounts_amount,
    net_amount,
    received_date,
    transaction_id,
    pdf_path,
    notes
  ) VALUES (
    v_workspace_id,
    v_owner_id,
    'Nova Era Comércio e Terceirizações Ltda',
    '2026-08-01',
    2053.69,
    543.83,
    1509.86,
    '2026-09-04',
    v_tx_id,
    'Nova Era/2026/Contracheque NE 08_26.pdf',
    'Folha Mensal'
  );

  RAISE NOTICE 'Contracheque Nova Era 08/2026 inserido com sucesso. Transaction ID: %', v_tx_id;

END $$;

COMMIT;
