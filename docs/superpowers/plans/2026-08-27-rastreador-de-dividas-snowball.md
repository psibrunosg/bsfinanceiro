# Plano de Implementação — Módulo 7: Rastreador de Dívidas & Simulador Bola de Neve vs Avalanche

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 7).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 7 (Rastreador de Dívidas & Simulador Bola de Neve vs Avalanche)**:
- Métodos matemáticos de quitação acelerada (Bola de Neve vs Avalanche).
- Simulação de aportes extras mensais.
- Cálculo da Data da Liberdade Financeira (Debt-Free Date) e economia total de juros.

---

## 2. Entregas Verticais

### Task 1: Engine de Amortização e Estratégias (`src/lib/finance/debt-payoff.ts`)
- [ ] RED: Testes em `src/lib/finance/debt-payoff.test.ts`.
- [ ] Implementar `simulateDebtPayoff({ debts, strategy, extraMonthlyPayment, startMonth })`.
- [ ] Implementar `extractDebtsFromFinancialData(accounts, invoices, transactions)`.
- [ ] GREEN: `npx vitest run src/lib/finance/debt-payoff.test.ts`.

### Task 2: Componente `DebtPayoffWidget` e Integração
- [ ] Criar `src/app/components/DebtPayoffWidget.tsx`.
- [ ] Criar `src/app/components/DebtPayoffWidget.test.tsx`.
- [ ] Integrar em `src/app/CardsPage.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
