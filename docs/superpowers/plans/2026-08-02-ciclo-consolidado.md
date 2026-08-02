# Ciclo consolidado — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Validação manual P2.7 + Gráficos interativos Dashboard + Hubs Ganhos/Gastos com abas.

**Architecture:** Validação manual primeiro (baseline qualidade), gráficos Chart.js em Dashboard, abas nos hubs reutilizando gráficos. Agregações puras em `src/lib/finance/`, componentes React em `src/app/`.

**Tech Stack:** Next.js 15, React 19, TypeScript, Vitest, Playwright, Chart.js 4.5.1, Supabase.

## Global Constraints

- Preservar alterações locais não relacionadas (`package-lock.json` já modificado — não commitar até fim do ciclo).
- Nunca inserir em tabelas fora de RPCs/idempotência.
- Valores monetários em centavos nas funções puras.
- Acessibilidade: `aria-label` em gráficos, `aria-current` em abas, navegação por teclado.
- Responsividade: testar 375 / 768 / 1440 px, dark/light.

---

## Task 1: Validação manual P2.7 (decisão diária)

**Files:** `README.md` (cenário), `test-results/manual-validation/` (screenshots), `work/handoffs/bsfinanceiro_<timestamp>.md` (evidências).

**Dependencies:** `.env.local` válido, usuário autenticado no Supabase remoto `wgntlhzjyriwhncumjsv`.

### Step 1: Preparar ambiente de validação

- [ ] Conferir `.env.local` tem `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
- [ ] Criar diretório `test-results/manual-validation/`.

```bash
mkdir -p test-results/manual-validation
cat .env.local | grep NEXT_PUBLIC_SUPABASE
```

**Expected:** URLs/keys válidas, diretório criado.

### Step 2: Iniciar dev server e autenticar

- [ ] Rodar `npm run dev`, abrir `http://127.0.0.1:3000/entrar` em navegador.
- [ ] Login com usuário de teste (criar novo ou usar existente).

```bash
npm run dev
```

**Expected:** Server rodando, login bem-sucedido, redirecionado para `/`.

### Step 3: Executar cenário manual (README.md)

- [ ] Criar conta corrente ativa via `/contas`.
- [ ] Definir como conta principal em `/configuracoes` (se UI existir) ou diretamente na tabela `workspace_preferences`.
- [ ] Registrar renda planejada futura via `/movimentacoes` (tipo receita, status `planned`).
- [ ] Criar compromisso fixo com vencimento antes da renda via `/compromissos` (ou `/gastos?tab=recorrentes`).
- [ ] Abrir `/` (Painel) e verificar:
  - `Disponível para gastar` exibido.
  - Data da próxima entrada visível.
  - Explicação da reserva do compromisso.
- [ ] Registrar despesa pelo registro rápido: valor + descrição, sem abrir "Mais detalhes".
- [ ] Abrir `/movimentacoes`, pesquisar pela descrição, confirmar que a despesa aparece.

**Expected:** Cada passo executado sem errors no console; funcionalidades conforme README.

### Step 4: Capturar screenshots e console

- [ ] DevTools aberto (F12), aba Console.
- [ ] Screenshot de cada tela: Contas, Painel com disponibilidade, Movimentações com despesa encontrada.
- [ ] Salvar screenshots em `test-results/manual-validation/` com nomes descritivos (`01-contas.png`, `02-painel-disponibilidade.png`, etc.).
- [ ] Copiar saída do console (se houver warnings/errors) para arquivo `console.log`.

```bash
# Após capturas manuais
ls test-results/manual-validation/
```

**Expected:** 5-6 screenshots salvos, console sem errors (warnings de dep são OK se não bloqueantes).

### Step 5: Registrar evidências no handoff

- [ ] Criar `work/handoffs/bsfinanceiro_2026-08-02_<hora>.md` com:
  - Título: "Validação manual P2.7 — Entrega 1".
  - Checklist: cada passo do cenário com ✅ ou ❌.
  - Anexos: referência aos screenshots.
  - Console: "limpo" ou lista de warnings/errors encontrados.
  - Veredito: `VALIDADO` ou `ISSUES_FOUND`.

**Expected:** Handoff criado, evidências registradas.

---

## Task 2: Gráficos interativos Dashboard

**Files:** Create `src/lib/finance/aggregations.ts`, `src/lib/finance/aggregations.test.ts`, `src/app/components/DashboardChart.tsx`, modify `src/app/DashboardPage.tsx`, create `e2e/dashboard-charts.e2e.ts`.

**Dependencies:** Task 1 concluída (baseline de qualidade), Chart.js já instalado.

### Step 1: Escrever testes para agregações financeiras

- [ ] Criar `src/lib/finance/aggregations.test.ts` com cenários:
  - `aggregateByCategory`: lista de transações → mapa `categoryId → total em centavos`.
  - `aggregateByMonth`: lista de transações → array de `{month: string, income: number, expense: number}`.
  - `groupEarnings`: lista de payslips/patient_earnings/outras → `{payslips: number, patients: number, other: number}`.

```typescript
// aggregations.test.ts
import { expect, test } from "vitest";
import { aggregateByCategory, aggregateByMonth, groupEarnings } from "./aggregations";

test("aggregateByCategory soma por categoria", () => {
  const txs = [
    { category_id: "cat1", amount_cents: 5000, transaction_type: "expense" },
    { category_id: "cat1", amount_cents: 3000, transaction_type: "expense" },
    { category_id: "cat2", amount_cents: 2000, transaction_type: "expense" },
  ];
  const result = aggregateByCategory(txs);
  expect(result.get("cat1")).toBe(8000);
  expect(result.get("cat2")).toBe(2000);
});

// ... mais testes para aggregateByMonth e groupEarnings
```

Run: `npm test src/lib/finance/aggregations.test.ts`

**Expected:** FAIL porque funções não existem.

### Step 2: Implementar agregações puras

- [ ] Criar `src/lib/finance/aggregations.ts`:

```typescript
export function aggregateByCategory(
  transactions: Array<{ category_id: string | null; amount_cents: number; transaction_type: string }>
): Map<string, number> {
  const map = new Map<string, number>();
  for (const tx of transactions) {
    if (tx.transaction_type !== "expense" || !tx.category_id) continue;
    const current = map.get(tx.category_id) ?? 0;
    map.set(tx.category_id, current + tx.amount_cents);
  }
  return map;
}

export function aggregateByMonth(
  transactions: Array<{ occurred_on: string; amount_cents: number; transaction_type: string }>
): Array<{ month: string; income: number; expense: number }> {
  const byMonth = new Map<string, { income: number; expense: number }>();
  for (const tx of transactions) {
    const month = tx.occurred_on.slice(0, 7); // YYYY-MM
    const current = byMonth.get(month) ?? { income: 0, expense: 0 };
    if (tx.transaction_type === "income") current.income += tx.amount_cents;
    else if (tx.transaction_type === "expense") current.expense += tx.amount_cents;
    byMonth.set(month, current);
  }
  return Array.from(byMonth.entries())
    .map(([month, data]) => ({ month, ...data }))
    .sort((a, b) => a.month.localeCompare(b.month));
}

export function groupEarnings(data: {
  payslips: Array<{ net_amount_cents: number }>;
  patientEarnings: Array<{ amount_cents: number }>;
  otherIncome: Array<{ amount_cents: number }>;
}): { payslips: number; patients: number; other: number } {
  return {
    payslips: data.payslips.reduce((sum, p) => sum + p.net_amount_cents, 0),
    patients: data.patientEarnings.reduce((sum, pe) => sum + pe.amount_cents, 0),
    other: data.otherIncome.reduce((sum, tx) => sum + tx.amount_cents, 0),
  };
}
```

Run: `npm test src/lib/finance/aggregations.test.ts`

**Expected:** PASS.

### Step 3: Criar componente DashboardChart (adapter Chart.js)

- [ ] Expandir `src/app/components/DashboardChart.tsx`:

```typescript
"use client";

import { useEffect, useRef } from "react";
import { Chart, ChartConfiguration } from "chart.js/auto";

export function DashboardChart({ config, ariaLabel }: { config: ChartConfiguration; ariaLabel: string }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const chartRef = useRef<Chart | null>(null);

  useEffect(() => {
    if (!canvasRef.current) return;
    if (chartRef.current) chartRef.current.destroy();
    chartRef.current = new Chart(canvasRef.current, config);
    return () => chartRef.current?.destroy();
  }, [config]);

  return <canvas ref={canvasRef} role="img" aria-label={ariaLabel} />;
}
```

**Expected:** Componente aceita `config` (Chart.js) e renderiza com acessibilidade.

### Step 4: Integrar gráficos no DashboardPage

- [ ] Modificar `src/app/DashboardPage.tsx`:
  - Buscar transações/payslips/patient_earnings dos últimos 6 meses.
  - Chamar `aggregateByCategory`, `aggregateByMonth`, `groupEarnings`.
  - Renderizar 3 gráficos: fluxo de caixa (linha), gastos por categoria (rosca), composição de ganhos (barras).

```typescript
// Exemplo simplificado no DashboardPage
const monthlyData = aggregateByMonth(transactions);
const categoryData = aggregateByCategory(transactions);
const earningsData = groupEarnings({ payslips, patientEarnings, otherIncome });

<DashboardChart
  config={{
    type: "line",
    data: {
      labels: monthlyData.map((m) => m.month),
      datasets: [
        { label: "Receitas", data: monthlyData.map((m) => m.income / 100), borderColor: "green" },
        { label: "Despesas", data: monthlyData.map((m) => m.expense / 100), borderColor: "red" },
      ],
    },
  }}
  ariaLabel="Fluxo de caixa dos últimos 6 meses"
/>
```

Run: `npm run dev`, abrir `/`, verificar gráficos renderizando.

**Expected:** Gráficos visíveis, responsivos, sem console errors.

### Step 5: Escrever snapshot visual Playwright

- [ ] Criar `e2e/dashboard-charts.e2e.ts`:

```typescript
import { expect, test } from "@playwright/test";

for (const scheme of ["light", "dark"] as const) {
  test(`Dashboard com gráficos ${scheme}`, async ({ page }) => {
    await page.emulateMedia({ colorScheme: scheme, reducedMotion: "reduce" });
    await page.goto("/entrar");
    // TODO: autenticar usuário de teste (ou mock Supabase)
    await page.goto("/");
    await expect(page.getByRole("img", { name: /fluxo de caixa/i })).toBeVisible();
    await page.screenshot({ path: `test-results/charts/dashboard-${scheme}.png`, fullPage: true });
  });
}
```

Run: `npx playwright test e2e/dashboard-charts.e2e.ts --update-snapshots`

**Expected:** Screenshots salvos, baseline criado.

### Step 6: Commit entrega 2

```bash
git add src/lib/finance/aggregations.* src/app/components/DashboardChart.tsx src/app/DashboardPage.tsx e2e/dashboard-charts.e2e.ts
git commit -m "feat: add interactive charts to dashboard

Implementa fluxo de caixa (linha), gastos por categoria (rosca) e
composição de ganhos (barras) usando Chart.js. Agregações puras em
aggregations.ts com testes. Componente DashboardChart acessível
(role=img, aria-label). Snapshots visuais Playwright.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 3: Hubs Ganhos e Gastos com abas

**Files:** Create `src/app/components/Tabs.tsx`, `src/app/ganhos/page.tsx`, modify `src/app/gastos/page.tsx`, `src/app/compromissos/page.tsx`, create `e2e/hubs.e2e.ts`.

**Dependencies:** Task 2 concluída (gráficos prontos para reutilizar).

### Step 1: Criar componente genérico Tabs

- [ ] Criar `src/app/components/Tabs.tsx`:

```typescript
"use client";

import { ReactNode } from "react";

export function Tabs({
  tabs,
  activeTab,
  onChange,
}: {
  tabs: Array<{ id: string; label: string }>;
  activeTab: string;
  onChange: (id: string) => void;
}) {
  return (
    <nav className="tabs" aria-label="Navegação de abas">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => onChange(tab.id)}
          className={activeTab === tab.id ? "active" : ""}
          aria-current={activeTab === tab.id ? "page" : undefined}
        >
          {tab.label}
        </button>
      ))}
    </nav>
  );
}

export function TabPanel({ id, activeTab, children }: { id: string; activeTab: string; children: ReactNode }) {
  if (id !== activeTab) return null;
  return <div role="tabpanel">{children}</div>;
}
```

**Expected:** Componente acessível, navegável por teclado.

### Step 2: Criar hub Ganhos com abas

- [ ] Criar `src/app/ganhos/page.tsx`:

```typescript
"use client";

import { useState } from "react";
import { Tabs, TabPanel } from "../components/Tabs";
import { DashboardChart } from "../components/DashboardChart";
import { EmptyState } from "../components/EmptyState";
import { groupEarnings } from "@/lib/finance/aggregations";

export default function GanhosPage() {
  const [activeTab, setActiveTab] = useState("visao-geral");
  // TODO: buscar payslips, patient_earnings, outras receitas
  const earningsData = groupEarnings({ payslips: [], patientEarnings: [], otherIncome: [] });

  return (
    <main>
      <Tabs
        tabs={[
          { id: "visao-geral", label: "Visão geral" },
          { id: "contracheques", label: "Contracheques" },
          { id: "pacientes", label: "Pacientes" },
          { id: "outras", label: "Outras receitas" },
        ]}
        activeTab={activeTab}
        onChange={setActiveTab}
      />
      <TabPanel id="visao-geral" activeTab={activeTab}>
        <h1>Ganhos</h1>
        <DashboardChart
          config={{
            type: "bar",
            data: {
              labels: ["Contracheques", "Pacientes", "Outras"],
              datasets: [{ data: [earningsData.payslips / 100, earningsData.patients / 100, earningsData.other / 100] }],
            },
          }}
          ariaLabel="Composição de ganhos"
        />
      </TabPanel>
      <TabPanel id="contracheques" activeTab={activeTab}>
        <EmptyState message="Contracheques serão exibidos aqui em breve." />
      </TabPanel>
      <TabPanel id="pacientes" activeTab={activeTab}>
        <EmptyState message="Pacientes serão exibidos aqui em breve." />
      </TabPanel>
      <TabPanel id="outras" activeTab={activeTab}>
        <EmptyState message="Outras receitas serão exibidas aqui em breve." />
      </TabPanel>
    </main>
  );
}
```

Run: `npm run dev`, abrir `/ganhos`, verificar abas funcionam.

**Expected:** Abas navegáveis, gráfico na aba "Visão geral", empty states nas demais.

### Step 3: Atualizar hub Gastos com abas

- [ ] Modificar `src/app/gastos/page.tsx`:
  - Adicionar abas: Visão geral | Lançamentos | Recorrentes.
  - Aba "Visão geral": gráfico rosca (gastos por categoria, reutiliza `aggregateByCategory`).
  - Aba "Lançamentos": lista de movimentações tipo despesa.
  - Aba "Recorrentes": lista de compromissos fixos (já implementado em `CommitmentsPage`, reutilizar componente).

**Expected:** Abas funcionam, gráfico e listas renderizam.

### Step 4: Redirect /compromissos → /gastos?tab=recorrentes

- [ ] Modificar `src/app/compromissos/page.tsx`:

```typescript
import { redirect } from "next/navigation";

export default function CompromissosPage() {
  redirect("/gastos?tab=recorrentes");
}
```

Run: `npm run dev`, navegar para `/compromissos`, verificar redirect.

**Expected:** Redirect imediato para `/gastos?tab=recorrentes`.

### Step 5: Escrever smoke test de hubs

- [ ] Criar `e2e/hubs.e2e.ts`:

```typescript
import { expect, test } from "@playwright/test";

test("Hub Ganhos com abas navegáveis", async ({ page }) => {
  await page.goto("/ganhos");
  await expect(page.getByRole("button", { name: "Visão geral" })).toHaveAttribute("aria-current", "page");
  await page.click('button:has-text("Contracheques")');
  await expect(page.getByText(/em breve/i)).toBeVisible();
});

test("Hub Gastos redireciona compromissos", async ({ page }) => {
  await page.goto("/compromissos");
  await expect(page).toHaveURL(/\/gastos\?tab=recorrentes/);
});
```

Run: `npx playwright test e2e/hubs.e2e.ts`

**Expected:** Testes passam.

### Step 6: Commit entrega 3

```bash
git add src/app/components/Tabs.tsx src/app/ganhos/page.tsx src/app/gastos/page.tsx src/app/compromissos/page.tsx e2e/hubs.e2e.ts
git commit -m "feat: add Ganhos and Gastos hubs with tabs

Transforma /ganhos e /gastos em hubs analíticos com abas (Visão geral,
sub-módulos). Visão geral mostra gráficos (reutiliza DashboardChart).
/compromissos redireciona para /gastos?tab=recorrentes. Componente Tabs
genérico acessível. Smoke test Playwright para navegação de abas.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 4: Verificação final e handoff

**Files:** Modify `work/handoffs/bsfinanceiro_2026-08-02_<hora>.md`, add `package-lock.json`.

### Step 1: Executar gates

```bash
npm run lint
npm test
npm run build
```

**Expected:** Lint 0 erros (2 warnings existentes OK), testes passando, build exit 0.

### Step 2: Screenshots multi-viewport

```bash
npx playwright test e2e/smoke.e2e.ts e2e/dashboard-charts.e2e.ts e2e/hubs.e2e.ts --project=mobile --project=tablet --project=desktop
```

**Expected:** Todos passam, screenshots gerados.

### Step 3: Atualizar handoff consolidado

- [ ] Completar `work/handoffs/bsfinanceiro_2026-08-02_<hora>.md` com:
  - Entrega 1: veredito validação, screenshots referenciados.
  - Entrega 2: gráficos implementados, testes passando.
  - Entrega 3: hubs com abas, redirect funcional.
  - Gates: lint/test/build OK.
  - Riscos residuais: nenhum (ou listar se houver).
  - `READY_FOR_LUA`.

### Step 4: Commit final

```bash
git add package-lock.json work/handoffs/
git commit -m "chore: update handoff and lock file for consolidated cycle

Registra evidências das 3 entregas verticais: validação manual P2.7,
gráficos dashboard, hubs Ganhos/Gastos. Gates passando. READY_FOR_LUA.

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Self-review

- Cobertura: validação manual (1), gráficos (2), hubs (3), gates (4), handoff (4).
- Sem dependências novas (Chart.js já instalado).
- Tipos consistentes: agregações retornam centavos (number), gráficos convertem para reais.
- Acessibilidade: `aria-label`, `aria-current`, `role="img"`, navegação por teclado.
- Ordem respeitada: 1 → 2 → 3 → 4 (validação primeiro, gráficos antes de hubs).
