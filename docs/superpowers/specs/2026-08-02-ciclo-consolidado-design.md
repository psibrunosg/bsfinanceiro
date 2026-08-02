# Ciclo de desenvolvimento — 3 entregas verticais consolidadas

> **Data:** 2026-08-02  
> **Escopo:** Validação manual P2 + Gráficos interativos Dashboard + Painel Ganhos/Gastos (hubs analíticos)

## Contexto

**Estado atual (P0-P2 implementados):**
- Migrations: `financial_contexts`, `patients`, `payslips`, `investments`, RPCs atômicas (`ebf74c0`).
- UI refatorada: nav reorganizada, hubs Ganhos/Gastos, contexts, RLS por `owner_id` (`24e79bd`, `4e43761`).
- Testes: 54 smoke tests passando (auth guards, console limpo, screenshots multi-viewport), baseline visual atualizado (`6f4e563`).
- **Pendente:** validação manual P2.7 (cenário autenticado contra Supabase configurado).

**Roadmap:** P2 quase concluído; P4 (gráficos + alertas) declarado alta prioridade. PLAN-evolution seção 1-3 implementadas (nav, hubs, migrations), seção 2 (painel com gráficos) parcialmente pendente.

**Objetivo deste ciclo:** consolidar P2 com validação manual + entregar P4 parcial (gráficos dashboard + estrutura hubs Ganhos/Gastos) antes de seguir P3 (deploy/PWA).

---

## Entrega vertical 1: Validação manual P2.7 (decisão diária)

### Objetivo
Executar cenário manual reproduzível do `README.md` contra Supabase autenticado, cobrindo conta principal, disponibilidade projetada, registro rápido e histórico pesquisável.

### Critérios de aceite
1. Conta corrente criada e definida como conta principal via UI.
2. Renda planejada futura + compromisso fixo pré-renda registrados.
3. Painel mostra `Disponível para gastar` com data da próxima entrada e explicação da reserva.
4. Despesa pelo registro rápido usa conta principal + data de hoje sem abrir campos adicionais.
5. Movimentações encontra a despesa por descrição.
6. Validação sem errors no console, screenshots capturados para evidência.

### Dependências
- `.env.local` com `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` válidos.
- Usuário de teste autenticado no Supabase remoto (`wgntlhzjyriwhncumjsv`).

### Riscos
- **Médio:** credencial Supabase ausente/expirada (pausar p/ usuário fornecer).
- **Baixo:** bugs em `SpendingPowerCard` ou `QuickTransactionForm` descobertos durante validação (fix incremental).

### Skills previstas
- **qa** (fase verificação): executar cenário, capturar screenshots, anotar console.
- **browser-testing-with-devtools** (se MCP disponível): inspecionar DOM/console em tempo real; senão Playwright headless.

### Ordem de execução
Executar **antes** das entregas 2-3 (baseline de qualidade antes de adicionar features).

---

## Entrega vertical 2: Gráficos interativos no Dashboard

### Objetivo
Substituir indicadores estáticos por gráficos interativos: fluxo de caixa (linha/barras), gastos por categoria (rosca), composição de ganhos (barras empilhadas). Usar Chart.js já instalado (`package.json` v4.5.1).

### Critérios de aceite
1. **Fluxo de caixa:** gráfico de linha/barras mostra receitas, despesas e saldo por período (últimos 6 meses ou mês atual detalhado).
2. **Gastos por categoria:** rosca com top 5 categorias + "Outros", clicável para filtrar lista de movimentações.
3. **Composição de ganhos:** barras empilhadas com contracheques, pacientes (quando houver) e outras receitas.
4. Gráficos responsivos (mobile 375px, tablet 768px, desktop 1440px), tema dark/light aplicado.
5. Acessibilidade: `role="img"`, `aria-label` descrevendo o gráfico, tabela de dados alternativa (sr-only).
6. Testes: cobertura de `buildChartData` (função pura), snapshot visual dos gráficos (Playwright).

### Modelo de dados
Consultas reutilizam agregações existentes em `src/lib/finance/`:
- `balance.ts` — saldos por conta.
- `projection.ts` — fluxo de caixa projetado.
- Novas funções puras: `aggregateByCategory`, `aggregateByMonth`, `groupEarnings` (centavos).

### Dependências
- Chart.js já instalado; criar adapter `src/app/components/DashboardChart.tsx` (já existe stub, expandir).
- `DashboardPage.tsx` já renderiza placeholder; trocar por gráficos reais.

### Riscos
- **Baixo:** Chart.js SSR/hidratação (`use client`, carregar só no navegador).
- **Baixo:** performance com datasets grandes (limitar a 12 meses, agregação no cliente).

### Skills previstas
- **executing-plans** (implementação): escrever `aggregateByCategory`, integrar Chart.js.
- **ui-ux-pro-max** (review): verificar responsividade, cores acessíveis, interação clicável.
- **ponytail-review** (review): simplificação de transformações de dados.

### Ordem de execução
Executar **após** entrega 1 (validação manual OK) e **antes** de entrega 3 (hubs Ganhos/Gastos dependem de padrões de gráfico estabelecidos aqui).

---

## Entrega vertical 3: Estrutura de hubs Ganhos e Gastos

### Objetivo
Transformar páginas `/ganhos` e `/gastos` em hubs analíticos com abas (Visão geral, sub-módulos), seguindo PLAN-evolution seção 2. Visão geral mostra resumo + gráfico; abas específicas ficam preparadas para próximos ciclos (Contracheques, Pacientes, Outras receitas em Ganhos; Lançamentos, Recorrentes em Gastos).

### Critérios de aceite — Ganhos
1. `/ganhos` abre na aba "Visão geral".
2. Abas: Visão geral | Contracheques | Pacientes | Outras receitas (nav horizontal desktop, dropdown mobile).
3. Visão geral mostra composição de ganhos (gráfico de barras, reutiliza da entrega 2) + totais do mês.
4. Abas Contracheques/Pacientes/Outras receitas mostram `<EmptyState>` com "Em breve" (implementação em ciclo futuro).
5. Acessível: nav por teclado, `aria-current="page"` na aba ativa.

### Critérios de aceite — Gastos
1. `/gastos` abre na aba "Visão geral".
2. Abas: Visão geral | Lançamentos | Recorrentes.
3. Visão geral mostra gastos por categoria (rosca, reutiliza da entrega 2) + separação Pessoal/Clínica se houver contextos.
4. Aba "Recorrentes" lista compromissos fixos (já implementado, migrar de `/compromissos`).
5. Aba "Lançamentos" lista movimentações do tipo despesa (filtro sobre `TransactionsPage`, componente compartilhado).
6. `/compromissos` redireciona para `/gastos?tab=recorrentes` (middleware ou `redirect()` no page.tsx).

### Modelo de dados
- Consultas agregadas por `financial_context` (Pessoal/Clínica) quando `context_id` presente.
- Reutilizar queries de `transactions`, `commitments`, `payslips`, `patient_earnings` (já com RLS).

### Dependências
- Gráficos da entrega 2 prontos (reutilização).
- Componente `<Tabs>` ou similar (criar genérico em `src/app/components/`).

### Riscos
- **Baixo:** abas sem conteúdo (mitigado com `<EmptyState>` explícito).
- **Médio:** redirect `/compromissos` quebra links externos (adicionar aviso no README).

### Skills previstas
- **executing-plans** (implementação): criar `<Tabs>`, integrar gráficos, redirect.
- **ui-ux-pro-max** (review): navegação por abas, responsividade, estados vazios.
- **verification-before-completion** (gates): screenshots multi-viewport, console limpo.

### Ordem de execução
Executar **após** entrega 2 (gráficos prontos para reutilizar).

---

## Mapa de arquivos críticos

| Arquivo | Responsabilidade | Entregas |
|---|---|---|
| `README.md` | Cenário manual validação | 1 |
| `src/lib/finance/balance.ts`, `projection.ts` | Agregações financeiras (saldos, fluxo) | 2 |
| `src/lib/finance/aggregations.ts` (novo) | `aggregateByCategory`, `aggregateByMonth`, `groupEarnings` | 2 |
| `src/app/components/DashboardChart.tsx` | Adapter Chart.js → React component | 2 |
| `src/app/DashboardPage.tsx` | Integração de gráficos no painel | 2 |
| `src/app/ganhos/page.tsx` (novo) | Hub Ganhos com abas | 3 |
| `src/app/gastos/page.tsx` | Hub Gastos com abas, redirect de compromissos | 3 |
| `src/app/components/Tabs.tsx` (novo) | Componente genérico de abas acessível | 3 |
| `e2e/dashboard-charts.e2e.ts` (novo) | Snapshots visuais de gráficos | 2 |
| `e2e/hubs.e2e.ts` (novo) | Smoke test de abas Ganhos/Gastos | 3 |

---

## Gates mínimos (todos as entregas)

1. **Lint:** `npm run lint` — 0 erros (2 warnings `@typescript-eslint/no-explicit-any` existentes em testes, não bloqueantes).
2. **Testes:** `npm test` — preservar 52 testes existentes + novos para agregações/gráficos.
3. **Build:** `npm run build` — exit 0.
4. **Acessibilidade:** gráficos com `aria-label`, abas navegáveis por teclado, `role="img"`.
5. **Responsividade:** 375 / 768 / 1440 px, dark/light, screenshots Playwright.
6. **Segurança:** sem novas queries públicas; RLS já estabelecido nas migrations existentes.
7. **Migrations:** nenhuma necessária (reutiliza tabelas existentes).
8. **Verificação manual:** entrega 1 executada com screenshots + console limpo.

---

## Recuperação de falhas

- **Entrega 1 (validação) falha:** registrar findings no handoff, criar issue `needs-triage` para bugs descobertos, seguir para entregas 2-3 (não são bloqueadas).
- **Entrega 2 (gráficos) falha:** reverter commits de gráficos, manter dashboard com indicadores estáticos, postergar para próximo ciclo.
- **Entrega 3 (hubs) falha:** manter páginas `/ganhos` e `/gastos` simples (sem abas), não aplicar redirect `/compromissos`.

---

## Skills previstas por fase

| Fase | Skills | Evidência |
|---|---|---|
| **Implementação (TERRA)** | `executing-plans`, `tdd` | diffs em working tree, testes novos passando |
| **Gates** | `verification-before-completion`, `qa`, `browser-testing-with-devtools` | screenshots, console logs, lint/test/build OK |
| **Review (LUA)** | `ponytail-review`, `ui-ux-pro-max`, `code-review` | veredito `ACCEPTED` / `CHANGES_REQUESTED` |

---

## Ordem de execução consolidada

1. **Entrega 1:** validação manual P2.7 (baseline de qualidade, screenshots para evidência).
2. **Entrega 2:** gráficos dashboard (estabelece padrões de Chart.js, cores, responsividade).
3. **Entrega 3:** hubs Ganhos/Gastos (reutiliza gráficos da entrega 2, estrutura para próximos ciclos).

**Paralelização:** TERRA pode trabalhar em entrega 2 enquanto aguarda credenciais/usuário para entrega 1 (pausar em caso de bloqueio por credencial ausente, conforme workflow).

---

## Definição de pronto

Ciclo concluído quando:
- Entrega 1: cenário manual executado, screenshots salvos em `test-results/manual-validation/`, console limpo.
- Entrega 2: gráficos renderizam corretamente, snapshots visuais em `e2e/dashboard-charts.e2e.ts` passando.
- Entrega 3: abas navegáveis, redirect `/compromissos` funcional, smoke test `e2e/hubs.e2e.ts` passando.
- Gates 1-8 passam, LUA retorna `ACCEPTED`, commit + handoff atualizado, `package-lock.json` commitado (deps inalteradas).
