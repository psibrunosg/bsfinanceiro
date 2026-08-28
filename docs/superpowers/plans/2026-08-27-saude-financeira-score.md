# Plano de Implementação — Módulo 6: Saúde Financeira & Score Inteligente (0 a 1000)

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 6).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 6 (Saúde Financeira & Score Inteligente 0-1000)**:
- Score gamificado de 0 a 1000 baseado em 4 pilares de 250 pontos (Reserva, Endividamento, Poupança, Investimentos).
- Classificação em 4 faixas (Crítico, Atenção, Saudável, Excelente).
- Diagnóstico inteligente com ações prescritivas para ganhar pontos.

---

## 2. Entregas Verticais

### Task 1: Engine de Score e Diagnóstico (`src/lib/finance/health-score.ts`)
- [ ] RED: Testes em `src/lib/finance/health-score.test.ts`.
- [ ] Implementar cálculo dos 4 pilares: `calculateEmergencyReserveScore`, `calculateDebtRatioScore`, `calculateSavingsRateScore`, `calculateInvestmentScore`.
- [ ] Implementar `computeFinancialHealthScore(input)`.
- [ ] GREEN: `npx vitest run src/lib/finance/health-score.test.ts`.

### Task 2: Componente `HealthScoreWidget` e Integração
- [ ] Criar `src/app/components/HealthScoreWidget.tsx`.
- [ ] Criar `src/app/components/HealthScoreWidget.test.tsx`.
- [ ] Integrar em `src/app/HealthPage.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
