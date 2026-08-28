# Plano de Implementação — Módulo 4: Rastreador de Parcelamentos (Linha do Tempo das Parcelas)

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 4).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 4 (Rastreador de Parcelamentos - Linha do Tempo das Parcelas)**:
- Visualização consolidada de todas as compras parceladas no cartão de crédito.
- Linha do tempo dos próximos meses com total comprometido.
- Métrica de "Alívio Financeiro": quando cada compra termina e quanto é liberado no orçamento mensal.

---

## 2. Entregas Verticais

### Task 1: Engine de Linha do Tempo e Alívio (`src/lib/finance/installment-timeline.ts`)
- [ ] RED: Testes em `src/lib/finance/installment-timeline.test.ts`.
- [ ] Implementar `extractInstallmentPurchases(invoices, transactions)`.
- [ ] Implementar `buildInstallmentTimeline(purchases, startMonth, totalMonths)`.
- [ ] Implementar `computeFinancialReliefSchedule(purchases, currentMonth)`.
- [ ] GREEN: `npx vitest run src/lib/finance/installment-timeline.test.ts`.

### Task 2: Componente `InstallmentTimelineWidget` e Integração
- [ ] Criar `src/app/components/InstallmentTimelineWidget.tsx`.
- [ ] Criar `src/app/components/InstallmentTimelineWidget.test.tsx`.
- [ ] Integrar em `src/app/CardsPage.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
