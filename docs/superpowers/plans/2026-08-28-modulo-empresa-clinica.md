# Plano de Implementação — Módulo 10: Módulo EMPRESA (Autônomos / Clínicas de Psicologia / Empréstimos de Sócio & Descasamento de Fluxo)

> **Workflow:** superpowers:test-driven-development, executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 10).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 10 (Módulo EMPRESA / Consultórios / Empréstimos de Sócio)**:
- Descasamento de datas (aluguel dia 8 vs recebimento dia 15).
- Empréstimos de sócio (gastos da clínica pagos no cartão pessoal e saldo devedor/a receber).
- DRE gerencial simplificado da clínica (faturamento, custos fixos, lucro e pró-labore).

---

## 2. Entregas Verticais

### Task 1: Engine Financeira Empresarial da Clínica (`src/lib/finance/clinic-business.ts`)
- [ ] RED: Testes em `src/lib/finance/clinic-business.test.ts`.
- [ ] Implementar `computeClinicDRE(transactions, month)`.
- [ ] Implementar `computePartnerLoanBalance(transactions)`.
- [ ] Implementar `computeCashFlowGap(transactions, month)`.
- [ ] GREEN: `npx vitest run src/lib/finance/clinic-business.test.ts`.

### Task 2: Componente `ClinicBusinessWidget` e Integração
- [ ] Criar `src/app/components/ClinicBusinessWidget.tsx`.
- [ ] Criar `src/app/components/ClinicBusinessWidget.test.tsx`.
- [ ] Integrar em `src/app/ganhos/page.tsx` e `src/app/DashboardPage.tsx`.

### Task 3: Verificação e Gates
- [ ] `npm test`, `npx tsc --noEmit`, `npm run lint`, `npm run build`.
