# Plano de Implementação — Módulo 3: Gestão de Assinaturas e Recorrências

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 3).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 3 (Gestão de Assinaturas e Recorrências)**:
- Hub de assinaturas (Netflix, Spotify, ChatGPT, Academias, etc.).
- Visão anualizada do custo ("Você gasta R$ X/ano com assinaturas").
- Radar de vencimento antecipado e simulador de economia ao cancelar.

---

## 2. Entregas Verticais

### Task 1: Engine de Detecção e Custo Anualizado (`src/lib/finance/subscriptions.ts`)
- [ ] RED: Testes em `src/lib/finance/subscriptions.test.ts`.
- [ ] Implementar catalogação de serviços e detector por regex `detectSubscriptions(transactions, commitments)`.
- [ ] Implementar `computeSubscriptionMetrics(subscriptions, currentDate)`.
- [ ] Implementar `simulateSubscriptionCancellationSavings({ monthlyCost, annualRatePercent, years })`.
- [ ] GREEN: `npx vitest run src/lib/finance/subscriptions.test.ts`.

### Task 2: Componente `SubscriptionHubWidget` e Integração
- [ ] Criar `src/app/components/SubscriptionHubWidget.tsx`.
- [ ] Criar `src/app/components/SubscriptionHubWidget.test.tsx`.
- [ ] Integrar na aba "Recorrentes" de `src/app/gastos/page.tsx` e no `DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
