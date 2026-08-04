# Task 3 Brief: Criação de Múltiplas Contas Bancárias (PJ / PF) no Supabase

## Contexto & Objetivos
Centralizar todas as movimentações financeiras em uma única conta estava gerando inconsistências para o usuário. Nesta tarefa, vamos adicionar suporte e estruturar formalmente múltiplas contas bancárias (PJ e PF/CPF) no workspace **"BS finanças"** (`4244e4ad-d527-4b98-84b8-6333d04a6ee4`).

## Especificações

### Contas a Cadastrar/Garantir no Supabase:
Workspace: `4244e4ad-d527-4b98-84b8-6333d04a6ee4`
Owner ID: `68f89053-fd7b-4803-826e-b01f1847265e`

1. **Conta Corrente PJ (Clínica / Empresa)**
   - Name: `Conta Corrente PJ - Clínica`
   - Type: `checking`
   - Initial Balance: `0.00`
   - System / Default: `false`
2. **Conta Corrente PF (Bruno CPF / Pessoal)**
   - Name: `Conta Corrente PF - Bruno CPF`
   - Type: `checking`
   - Initial Balance: `0.00`
   - System / Default: `false`
3. **Conta Santander (Legada / Principal)**
   - Name: `Banco Santander`
   - Type: `checking`
   - Manutenção do registro existente.

## Entregáveis
1. Módulo helper [`src/lib/finance/accounts.ts`](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/lib/finance/accounts.ts) para gerenciamento de contas, classificação entre PJ e PF e validação de tipos de conta.
2. Script idempotente CLI [`scripts/seed-bank-accounts.ts`](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/scripts/seed-bank-accounts.ts) para criar e atualizar as contas no Supabase para o workspace `4244e4ad-d527-4b98-84b8-6333d04a6ee4`.
3. Suíte de testes unitários em `src/lib/finance/__tests__/accounts.test.ts`.
4. Execução do script com sucesso contra a base Supabase.
5. Relatório detalhado em `.superpowers/sdd/task-3-report.md`.
