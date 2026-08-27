# Plano de Implementação — Módulo 1: Radar de Juros e Custos Ocultos

> **Workflow:** superpowers:test-driven-development, subagent-driven-development / executing-plans.
> **Roteiro Ref:** `docs/superpowers/specs/2026-08-27-roadmap-ideias.md` (Módulo 1).

## 1. Visão Geral e Arquitetura

O objetivo é implementar o **Módulo 1 (Radar de Juros e Custos Ocultos)** no BS Financeiro, permitindo que o usuário identifique custos bancários (juros de rotativo, parcelamentos, Pix no crédito, IOF) e simule a economia de antecipação de parcelas.

### Tech Stack
- TypeScript, React 19, Next.js 15, Vitest, Lucide React.
- Design System Apple-style com classes globais e CSS puro.

---

## 2. Entregas Verticais

### Task 1: Core Engine de Cálculo de Juros e Simulação (`src/lib/finance/interest-radar.ts`)
- [ ] RED: Criar suite de testes em `src/lib/finance/interest-radar.test.ts`.
- [ ] Implementar `computeInterestSummary(transactions, month)` para consolidar juros, taxas e multas.
- [ ] Implementar `simulatePrepaymentDiscount({ installmentValue, remainingCount, monthlyDiscountRate })` usando cálculo de valor presente financeiro real.
- [ ] Implementar `detectHiddenCosts(transactions)` para flagar Pix no crédito e juros de parcelamento.
- [ ] GREEN: `npx vitest run src/lib/finance/interest-radar.test.ts`.

### Task 2: Componente `InterestRadarWidget` e Integração
- [ ] Criar `src/app/components/InterestRadarWidget.tsx` com visual Apple Glass, cards de alerta e simulador dinâmico de parcelas.
- [ ] Integrar o widget no `DashboardPage.tsx` e `CardsPage.tsx`.
- [ ] Validar acessibilidade (`aria-label`, contraste, teclado) e responsividade (mobile 375px / desktop 1440px).

### Task 3: Verificação e Gates
- [ ] Executar `npx vitest run src/lib/finance/interest-radar.test.ts`.
- [ ] Validar lint e typecheck.
- [ ] Criar `walkthrough.md` com evidências.
