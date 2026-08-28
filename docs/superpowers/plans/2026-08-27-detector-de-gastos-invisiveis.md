# Plano de Implementação — Módulo 5: Detector de Gastos Invisíveis (Micro-gastos "Formiguinha")

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 5).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 5 (Detector de Gastos Invisíveis - Micro-gastos "Formiguinha")**:
- Identificação de pequenas despesas ($\le$ R$ 30) que acumulam e corroem o orçamento.
- Cálculo de impacto anualizado ("Seus micro-gastos somam R$ 3.600/ano").
- Desafio semanal de economia com simulação de investimento no CDI.

---

## 2. Entregas Verticais

### Task 1: Engine de Detecção e Métricas de Micro-gastos (`src/lib/finance/micro-expenses.ts`)
- [ ] RED: Testes em `src/lib/finance/micro-expenses.test.ts`.
- [ ] Implementar `computeMicroExpenseSummary(transactions, month, threshold)`.
- [ ] Implementar `calculateMicroSavingsChallenge({ weeklyTarget, annualRatePercent })`.
- [ ] GREEN: `npx vitest run src/lib/finance/micro-expenses.test.ts`.

### Task 2: Componente `MicroExpenseRadarWidget` e Integração
- [ ] Criar `src/app/components/MicroExpenseRadarWidget.tsx`.
- [ ] Criar `src/app/components/MicroExpenseRadarWidget.test.tsx`.
- [ ] Integrar em `src/app/gastos/page.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
