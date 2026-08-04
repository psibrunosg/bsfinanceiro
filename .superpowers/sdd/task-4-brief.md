# Task 4 Brief: Tratamento de Movimentações Intercontas (PJ <-> CPF / Transferências Internas)

## Contexto & Objetivos
O usuário relatou: "as vezes faço movimentações entre elas e tudo mais. movo do PJ por CPF e tudo mais".
Quando existem múltiplas contas (ex: PJ e PF/CPF), transferências entre elas (ex: retirada de pro-labore, aporte ou transferência de liquidez) aparecem nos extratos bancários como uma saída na conta de origem e uma entrada na conta de destino.
Se essas movimentações não forem tratadas como **Transferências Internas / Intercontas**, o sistema registrará falsas receitas e falsas despesas no resultado consolidado.

## Especificações & Regras de Negócio

1. **Classificação e Identificação (`src/lib/finance/transfers.ts`):**
   - Identificar transações com categoria `Transferência Interna` / `Transferência entre Contas` ou marcadas com `is_transfer: true`.
   - Detecção/Pareamento de pares de transferência (débito na Conta A + crédito na Conta B de mesmo valor e data próxima).
   - Suporte a transferências PJ -> PF (Pró-labore / Distribuição de lucros) e PF -> PJ (Aporte de capital).

2. **Agregação e Consolidação Financeira (`src/lib/finance/aggregations.ts`):**
   - Atualizar/expandir as agregações do Dashboard e DRE para neutralizar transferências internas no total consolidado:
     - Saldo por conta individual: Conta Origem diminui R$ X, Conta Destino aumenta R$ X.
     - Resultado líquido consolidado: R$ 0,00 de impacto na receita/despesa operacional do workspace.
   - Função `calculateNetCashFlowExcludingTransfers(transactions)` e utilitários associados.

3. **Validação & Testes:**
   - Criar suíte de testes em `src/lib/finance/__tests__/transfers.test.ts` cobrindo pareamento de transferências, exclusão de receitas/despesas falsas no consolidado e cálculo correto de saldo por conta.
   - Atualizar suíte em `src/lib/finance/__tests__/aggregations.test.ts`.

4. **Entregáveis:**
   - Módulo [`src/lib/finance/transfers.ts`](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/lib/finance/transfers.ts)
   - Atualização em [`src/lib/finance/aggregations.ts`](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/lib/finance/aggregations.ts)
   - Testes unitários completos.
   - Relatório final em `.superpowers/sdd/task-4-report.md`.
