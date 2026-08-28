# Plano de Implementação — Módulo 8: Planejador de Metas & Sonhos (Com Motor de Aportes)

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 8).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 8 (Planejador de Metas & Sonhos com Motor de Aportes e CDI)**:
- Cálculo do aporte mensal necessário com e sem rendimento no CDI.
- Métrica "O CDI Paga Seu Sonho" (rendimento que abate o esforço de poupança).
- Simulador de prazos e marcos (milestones).

---

## 2. Entregas Verticais

### Task 1: Engine de Planejamento de Metas e CDI (`src/lib/finance/goal-planner.ts`)
- [ ] RED: Testes em `src/lib/finance/goal-planner.test.ts`.
- [ ] Implementar `computeGoalPlan(input)`.
- [ ] Implementar `computeGoalMilestones(input)`.
- [ ] GREEN: `npx vitest run src/lib/finance/goal-planner.test.ts`.

### Task 2: Componente `GoalPlannerWidget` e Integração
- [ ] Criar `src/app/components/GoalPlannerWidget.tsx`.
- [ ] Criar `src/app/components/GoalPlannerWidget.test.tsx`.
- [ ] Integrar em `src/app/PlanningPage.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
