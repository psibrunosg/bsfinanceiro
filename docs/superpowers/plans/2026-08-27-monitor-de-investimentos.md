# Plano de Implementação — Módulo 2: Monitor de Investimentos (Crescimento Patrimonial)

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 2).

## 1. Visão Geral e Arquitetura

O objetivo é implementar as funcionalidades do **Módulo 2 (Monitor de Investimentos - Crescimento Patrimonial)**:
- Rentabilidade comparativa com o CDI e Poupança.
- Motor de projeção de juros compostos com aportes mensais.
- Alocação e balanceamento entre Renda Fixa e Renda Variável.

---

## 2. Entregas Verticais

### Task 1: Engine de Crescimento e Comparativo CDI (`src/lib/finance/investment-growth.ts`)
- [ ] RED: Testes em `src/lib/finance/investment-growth.test.ts`.
- [ ] Implementar `comparePortfolioYield({ gainPercent, benchmarkCDIPercent })`.
- [ ] Implementar `projectCompoundGrowth({ currentPrincipal, monthlyContribution, annualRatePercent, months })`.
- [ ] Implementar `computeAssetClassAllocation(assets, positions, latestQuotes)`.
- [ ] GREEN: `npx vitest run src/lib/finance/investment-growth.test.ts`.

### Task 2: Componente `InvestmentGrowthWidget` e Integração
- [ ] Criar `src/app/components/InvestmentGrowthWidget.tsx`.
- [ ] Criar `src/app/components/InvestmentGrowthWidget.test.tsx`.
- [ ] Integrar em `src/app/investimentos/page.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
