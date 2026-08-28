# Plano de Implementação — Módulo 9: Radar de Impostos & Estimador de IRPF / Carnê-Leão

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 9).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 9 (Radar de Impostos & Estimador de IRPF / Carnê-Leão)**:
- Tabela progressiva mensal do IRPF 2026.
- Livro-Caixa e deduções legais para autônomos/psicólogos.
- Alíquota efetiva vs nominal e valor do DARF estimado.

---

## 2. Entregas Verticais

### Task 1: Engine Tributária e Livro-Caixa (`src/lib/finance/tax-radar.ts`)
- [ ] RED: Testes em `src/lib/finance/tax-radar.test.ts`.
- [ ] Implementar `calculateProgressiveTax(taxableBase)`.
- [ ] Implementar `computeMonthlyTaxReport(input)`.
- [ ] Implementar `detectLivroCaixaDeductions(transactions)`.
- [ ] GREEN: `npx vitest run src/lib/finance/tax-radar.test.ts`.

### Task 2: Componente `TaxRadarWidget` e Integração
- [ ] Criar `src/app/components/TaxRadarWidget.tsx`.
- [ ] Criar `src/app/components/TaxRadarWidget.test.tsx`.
- [ ] Integrar em `src/app/ganhos/page.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
