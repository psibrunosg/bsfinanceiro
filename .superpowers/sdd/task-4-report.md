# Task 4 Report: Tratamento de Movimentações Intercontas (PJ <-> CPF / Transferências Internas)

## Contexto & Objetivos
Quando usuários movimentam valores entre suas próprias contas (ex: Pró-labore ou distribuição de lucros da conta PJ para a conta PF, ou aportes da PF na PJ), os extratos bancários registram um débito em uma conta e um crédito na outra. Se tratadas isoladamente como receita ou despesa operacional, essas movimentações geram distorções no resultado consolidado (falsas receitas e falsas despesas).

O objetivo da Task 4 foi implementar a inteligência de identificação, pareamento, classificação e neutralização de movimentações intercontas, mantendo os saldos individuais das contas corretos.

## Implementações Realizadas

1. **Módulo `src/lib/finance/transfers.ts`**:
   - `isTransferTransaction`: Identifica transações de transferência por flag `is_transfer`, `type: 'transfer'`, presença de `destination_account_id`, categorias específicas ("Transferência", "Pró-labore", "Aporte de Capital") ou termos na descrição (ex: `PIX TRANSF`, `APORTE`).
   - `classifyTransferType`: Classifica transferências em:
     - `pj_to_pf`: Retiradas de Pró-labore, distribuição de lucros ou saídas PJ para PF.
     - `pf_to_pj`: Aportes de capital ou aportes de liquidez da PF para PJ.
     - `internal`: Transferências entre contas do mesmo escopo (PJ -> PJ ou PF -> PF).
     - `other`: Outras movimentações internas sem escopo definido.
   - `pairTransfers`: Pareia automaticamente débitos e créditos correspondentes em contas distintas com mesmo valor e datas próximas (+/- 3 dias), ou processa transações de registro único com `destination_account_id`.
   - `filterOutTransfers`: Filtra transações intercontas para relatórios consolidados de DRE/DFA.
   - `calculateTransfersSummary`: Gera resumo do volume de transferências (PJ->PF, PF->PJ, internal).
   - `calculateNetCashFlowExcludingTransfers`: Calcula a receita operacional, despesa operacional e fluxo de caixa líquido neutralizando transferências internas.

2. **Atualização em `src/lib/finance/aggregations.ts`**:
   - `aggregateExpensesByCategory`: Ignora movimentações intercontas na agregação de despesas por categoria.
   - `computeMonthlyFlow`: Filtra transferências por padrão nas entradas (`flowIn`) e saídas (`flowOut`) mensais do workspace.
   - `aggregateIncomeBySource`: Ignora transferências de entrada ao listar fontes de receita.
   - Re-exporta `calculateNetCashFlowExcludingTransfers`.

3. **Suíte de Testes Unitários**:
   - `src/lib/finance/__tests__/transfers.test.ts`: 12 testes dedicados cobrindo detecção, pareamento, classificação PJ/PF e neutralização.
   - `src/lib/finance/aggregations.test.ts`: Atualizado com testes de integração neutralizando movimentações intercontas.

## Resumo dos Entregáveis

- `src/lib/finance/transfers.ts` (Novo)
- `src/lib/finance/__tests__/transfers.test.ts` (Novo)
- `src/lib/finance/aggregations.ts` (Atualizado)
- `src/lib/finance/aggregations.test.ts` (Atualizado)
- `.superpowers/sdd/task-4-report.md` (Este relatório)
