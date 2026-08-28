-- 1. Atualizar nome e profissao no perfil
UPDATE users SET display_name = 'Bruno de Souza Gonçalves' WHERE email = 'brunosg2711@icloud.com';
INSERT INTO profiles (id, display_name, profession) VALUES ('15d36040-32aa-448b-a34d-43017cde51a7', 'Bruno de Souza Gonçalves', 'Psicólogo(a)')
ON CONFLICT (id) DO UPDATE SET display_name = 'Bruno de Souza Gonçalves', profession = 'Psicólogo(a)';

-- 2. Atualizar nome da conta para Caixa Economica Federal (Conta Salario)
UPDATE accounts SET name = 'Caixa Econômica Federal (Salário)' WHERE workspace_id = '0530a9a3-843d-4832-b919-6b9380310c9a';

-- 3. Inserir os 4 contracheques em transactions
INSERT INTO transactions (workspace_id, owner_id, account_id, category_id, type, status, description, amount, competence_date, notes)
VALUES 
('0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', '562aea75-4337-4b49-958a-eff212cc2cc7', '789ef8d9-03a8-45be-9e9c-dc83c4443686', 'income', 'paid', 'Salário ACPO - Abril/2026', 2120.89, '2026-04-30', 'Salário Bruto: R$ 2.329,52 | Descontos: INSS R$ 185,33, Mens. Sindical R$ 23,30 (Total Descontos: R$ 208,63)'),
('0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', '562aea75-4337-4b49-958a-eff212cc2cc7', '789ef8d9-03a8-45be-9e9c-dc83c4443686', 'income', 'paid', 'Salário ACPO - Maio/2026', 2174.81, '2026-05-31', 'Salário Bruto: R$ 2.389,42 (Antecipação Dissídio) | Descontos: INSS R$ 190,72, Mens. Sindical R$ 23,89 (Total Descontos: R$ 214,61)'),
('0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', '562aea75-4337-4b49-958a-eff212cc2cc7', '789ef8d9-03a8-45be-9e9c-dc83c4443686', 'income', 'paid', 'Salário ACPO - Junho/2026', 2174.81, '2026-06-30', 'Salário Bruto: R$ 2.389,42 | Descontos: INSS R$ 190,72, Mens. Sindical R$ 23,89 (Total Descontos: R$ 214,61)'),
('0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', '562aea75-4337-4b49-958a-eff212cc2cc7', '789ef8d9-03a8-45be-9e9c-dc83c4443686', 'income', 'paid', 'Salário ACPO - Julho/2026', 1982.09, '2026-07-31', 'Salário Bruto: R$ 2.389,42 | Descontos: Convênio Farmácia R$ 192,72, INSS R$ 190,72, Mens. Sindical R$ 23,89 (Total Descontos: R$ 407,33)');

-- 4. Inserir compromisso fixo recorrente de salario
INSERT INTO fixed_commitments (workspace_id, owner_id, category_id, type, name, expected_amount, frequency, due_day, active)
VALUES ('0530a9a3-843d-4832-b919-6b9380310c9a', '15d36040-32aa-448b-a34d-43017cde51a7', '789ef8d9-03a8-45be-9e9c-dc83c4443686', 'income', 'Salário Mensal - Construtora ACPO', 2174.81, 'monthly', 5, true);
