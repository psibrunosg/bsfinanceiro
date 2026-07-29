# Pessoa física: decisão diária e registro simples Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir que uma pessoa física veja quanto pode gastar até a próxima receita e registre uma movimentação com o mínimo de campos.

**Architecture:** O banco ganha uma única preferência persistente para a conta principal. Regras de saldo e disponibilidade permanecem funções puras em `src/lib/finance/`; a interface apenas carrega dados tipados, transforma-os no modelo do painel e apresenta o formulário compacto. A navegação é reduzida sem remover nenhuma rota existente.

**Tech Stack:** Next.js 16, React 19, TypeScript 5, Supabase/Postgres com RLS, Vitest, Testing Library.

## Global Constraints

- Node.js `>=22`; usar apenas dependências já declaradas em `package.json`.
- Valores monetários nas funções puras usam centavos inteiros; a camada de UI continua usando `parseMoney` e `money`.
- Datas de negócio usam `todayInSaoPaulo()` e strings ISO `YYYY-MM-DD`.
- Não implementar Open Finance, OFX, CSV, OCR, PDF, IA, voz, WhatsApp ou pagamentos neste plano.
- Preservar RLS por `owner_id`, chaves de idempotência de transações e os testes existentes.

---

## File structure

| File | Responsibility |
|---|---|
| `supabase/migrations/20260728000009_default_cash_account.sql` | Persiste a conta principal por workspace e mantém RLS/índices. |
| `src/lib/finance/cash-position.ts` | Calcula saldo atual de contas de caixa a partir do saldo inicial e lançamentos pagos. |
| `src/lib/finance/spending-power.ts` | Calcula dinheiro disponível até a próxima receita e as reservas descontadas. |
| `src/lib/finance/cash-position.test.ts` | Testa saldo consolidado sem interface ou Supabase. |
| `src/lib/finance/spending-power.test.ts` | Testa projeção, reservas e exclusões de conta/tipo. |
| `src/app/components/types.ts` | Declara tipos tipados usados pelo hook e componentes. |
| `src/app/components/useFinance.ts` | Carrega conta principal, lançamentos relevantes e compromissos do painel. |
| `src/app/components/SpendingPowerCard.tsx` | Exibe disponível, data de referência e explicação auditável. |
| `src/app/components/SpendingPowerCard.test.tsx` | Testa o conteúdo acessível do card. |
| `src/app/components/QuickTransactionForm.tsx` | Registra receita/despesa com defaults seguros e detalhes expansíveis. |
| `src/app/components/QuickTransactionForm.test.tsx` | Testa defaults, validação e payload de inserção. |
| `src/app/DashboardPage.tsx` | Compõe o painel diário, card e registro rápido. |
| `src/app/TransactionsPage.tsx` | Converte lançamentos em histórico pesquisável e mantém o formulário completo em detalhes. |
| `src/app/components/Nav.tsx` | Agrupa rotas principais e secundárias sem remover links. |
| `src/app/dashboard-extra.css` | Estilos locais do card de disponibilidade e formulário compacto. |
| `src/app/transaction.css` | Estilos locais de filtros e detalhes do histórico. |

### Task 1: Persistir a conta principal do workspace

**Files:**
- Create: `supabase/migrations/20260728000009_default_cash_account.sql`
- Modify: `src/app/components/types.ts`
- Test: `supabase/rls-smoke-test.sql`

**Interfaces:**
- Produces: tabela `public.workspace_preferences(workspace_id uuid, owner_id uuid, default_cash_account_id uuid)` com uma linha por workspace.
- Produces: tipo `WorkspacePreference = { default_cash_account_id: string | null }`.

- [ ] **Step 1: Escrever o caso de isolamento RLS antes da migration**

Adicione ao bloco de smoke test uma tentativa de o segundo usuário selecionar ou alterar a preferência do primeiro. O teste deve falhar por não retornar linha e por violar RLS na alteração.

```sql
select count(*) as foreign_preferences
from public.workspace_preferences
where owner_id = v_user_a;
-- Expected for v_user_b: 0
```

- [ ] **Step 2: Executar o smoke test no projeto Supabase de validação**

Run: execute `supabase/rls-smoke-test.sql` no SQL Editor do projeto vinculado.

Expected: FAIL porque `workspace_preferences` ainda não existe.

- [ ] **Step 3: Criar a migration mínima**

Crie a tabela com RLS, unicidade de `(workspace_id, owner_id)`, chave estrangeira composta para `workspaces(id, owner_id)` e chave estrangeira composta para `accounts(id, workspace_id, owner_id)`. A conta principal deve aceitar `null`; quando preenchida, a aplicação só aceitará conta ativa de caixa.

```sql
create table public.workspace_preferences (
  workspace_id uuid not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  default_cash_account_id uuid,
  primary key (workspace_id, owner_id),
  foreign key (workspace_id, owner_id)
    references public.workspaces(id, owner_id) on delete cascade,
  foreign key (default_cash_account_id, workspace_id, owner_id)
    references public.accounts(id, workspace_id, owner_id) on delete set null
);

alter table public.workspace_preferences enable row level security;
create policy "workspace_preferences_own" on public.workspace_preferences
for all to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);
grant select, insert, update, delete on public.workspace_preferences to authenticated;
```

- [ ] **Step 4: Declarar o tipo de preferência**

```ts
export type WorkspacePreference = {
  default_cash_account_id: string | null;
};
```

- [ ] **Step 5: Reexecutar o smoke test**

Run: execute `supabase/rls-smoke-test.sql` após aplicar a migration.

Expected: PASS, inclusive o caso de preferência inacessível ao segundo usuário.

- [ ] **Step 6: Commit**

```bash
git add supabase/migrations/20260728000009_default_cash_account.sql supabase/rls-smoke-test.sql src/app/components/types.ts
git commit -m "feat: persist default cash account"
```

### Task 2: Calcular o saldo de caixa atual como regra pura

**Files:**
- Create: `src/lib/finance/cash-position.ts`
- Create: `src/lib/finance/cash-position.test.ts`

**Interfaces:**
- Consumes: `CashAccount = { id: string; type: string; initial_balance: number }` e `PostedTransaction = { account_id: string; destination_account_id: string | null; type: string; amount: number; status: string }`.
- Produces: `calculateCashPosition(accounts, transactions): { balanceCents: number; accountBalancesCents: Record<string, number> }`.

- [ ] **Step 1: Escrever os testes de saldo antes da implementação**

```ts
it("subtracts paid expenses and adds paid income only for cash accounts", () => {
  expect(calculateCashPosition(
    [{ id: "a", type: "checking", initial_balance: 100 }],
    [
      { account_id: "a", destination_account_id: null, type: "expense", amount: 20, status: "paid" },
      { account_id: "a", destination_account_id: null, type: "income", amount: 35, status: "paid" },
      { account_id: "a", destination_account_id: null, type: "expense", amount: 50, status: "planned" },
    ],
  ).balanceCents).toBe(115_00);
});

it("moves money between eligible cash accounts without changing the total", () => {
  expect(calculateCashPosition(
    [{ id: "a", type: "checking", initial_balance: 100 }, { id: "b", type: "savings", initial_balance: 0 }],
    [{ account_id: "a", destination_account_id: "b", type: "transfer", amount: 40, status: "paid" }],
  ).accountBalancesCents).toEqual({ a: 60_00, b: 40_00 });
});
```

- [ ] **Step 2: Executar os testes para confirmar a falha**

Run: `npm test -- src/lib/finance/cash-position.test.ts`

Expected: FAIL com erro de módulo inexistente.

- [ ] **Step 3: Implementar contas elegíveis e operações do livro-caixa**

Considere elegíveis apenas `checking`, `cash` e `savings`; ignore `credit_card` e `investment`. Converta valores decimais para centavos com `Math.round(Number(amount) * 100)`. Movimentações não pagas não alteram saldo; uma transferência paga debita a origem e credita o destino somente quando ambas forem contas de caixa.

```ts
export function calculateCashPosition(accounts: CashAccount[], transactions: PostedTransaction[]) {
  const accountBalancesCents = Object.fromEntries(
    accounts.filter((account) => CASH_ACCOUNT_TYPES.has(account.type))
      .map((account) => [account.id, Math.round(Number(account.initial_balance) * 100)]),
  );
  for (const transaction of transactions.filter((row) => row.status === "paid")) {
    const amountCents = Math.round(Number(transaction.amount) * 100);
    if (transaction.type === "income" && transaction.account_id in accountBalancesCents) accountBalancesCents[transaction.account_id] += amountCents;
    if (transaction.type === "expense" && transaction.account_id in accountBalancesCents) accountBalancesCents[transaction.account_id] -= amountCents;
    if (transaction.type === "transfer") {
      if (transaction.account_id in accountBalancesCents) accountBalancesCents[transaction.account_id] -= amountCents;
      if (transaction.destination_account_id && transaction.destination_account_id in accountBalancesCents) accountBalancesCents[transaction.destination_account_id] += amountCents;
    }
  }
  return { balanceCents: Object.values(accountBalancesCents).reduce((sum, value) => sum + value, 0), accountBalancesCents };
}
```

- [ ] **Step 4: Executar os testes focados**

Run: `npm test -- src/lib/finance/cash-position.test.ts`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/lib/finance/cash-position.ts src/lib/finance/cash-position.test.ts
git commit -m "feat: calculate current cash position"
```

### Task 3: Calcular disponibilidade até a próxima receita

**Files:**
- Create: `src/lib/finance/spending-power.ts`
- Create: `src/lib/finance/spending-power.test.ts`

**Interfaces:**
- Consumes: `SpendingPowerInput = { currentBalanceCents: number; today: string; plannedTransactions: PlannedTransaction[]; commitments: PlannedCommitment[] }`.
- Produces: `buildSpendingPower(input): SpendingPower`, onde `SpendingPower` contém `availableCents`, `nextIncomeDate`, `reservedCommitmentsCents` e `reservedExpenseCents`.

- [ ] **Step 1: Escrever testes para a janela de decisão**

```ts
it("reserves obligations before the next planned income", () => {
  expect(buildSpendingPower({
    currentBalanceCents: 1_000_00,
    today: "2026-07-28",
    plannedTransactions: [
      { type: "expense", amount: 100, competence_date: "2026-07-29", status: "planned" },
      { type: "income", amount: 900, competence_date: "2026-08-05", status: "planned" },
    ],
    commitments: [{ amount: 300, due_date: "2026-08-01", status: "planned" }],
  })).toMatchObject({ availableCents: 600_00, nextIncomeDate: "2026-08-05", reservedCommitmentsCents: 300_00, reservedExpenseCents: 100_00 });
});

it("does not reserve items after the next income or paid items", () => {
  expect(buildSpendingPower({ currentBalanceCents: 500_00, today: "2026-07-28", plannedTransactions: [{ type: "expense", amount: 90, competence_date: "2026-08-06", status: "planned" }], commitments: [{ amount: 60, due_date: "2026-07-29", status: "paid" }] }).availableCents).toBe(500_00);
});
```

- [ ] **Step 2: Executar para confirmar a falha**

Run: `npm test -- src/lib/finance/spending-power.test.ts`

Expected: FAIL com erro de módulo inexistente.

- [ ] **Step 3: Implementar a regra explícita**

Encontre a primeira receita `planned` com data maior ou igual a hoje. Reserve despesas planejadas e compromissos planejados com data entre hoje e essa receita, inclusive. Se não houver receita futura, use `null` e reserve somente compromissos/despesas dos próximos 30 dias; exponha `nextIncomeDate: null`.

```ts
export function buildSpendingPower(input: SpendingPowerInput): SpendingPower {
  const nextIncomeDate = input.plannedTransactions
    .filter((row) => row.type === "income" && row.status === "planned" && row.competence_date >= input.today)
    .map((row) => row.competence_date).sort()[0] ?? null;
  const cutoff = nextIncomeDate ?? addIsoDays(input.today, 30);
  // Sum only planned expenses and planned commitments in [today, cutoff].
}
```

- [ ] **Step 4: Executar os testes focados**

Run: `npm test -- src/lib/finance/spending-power.test.ts`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/lib/finance/spending-power.ts src/lib/finance/spending-power.test.ts
git commit -m "feat: calculate daily spending power"
```

### Task 4: Carregar o modelo do painel sem consultas duplicadas

**Files:**
- Modify: `src/app/components/types.ts`
- Modify: `src/app/components/useFinance.ts`
- Modify: `src/app/DashboardPage.tsx`
- Modify: `src/lib/finance/today-adapter.ts`
- Modify: `src/lib/finance/today-adapter.test.ts`

**Interfaces:**
- Consumes: `WorkspacePreference`, transações completas com `account_id`, `destination_account_id` e `status`, e ocorrências de compromissos.
- Produces: `FinanceData.defaultCashAccountId`, `FinanceData.cashPosition`, `FinanceData.spendingPower`.

- [ ] **Step 1: Escrever o teste do adaptador antes de mudar o hook**

```ts
it("adapts posted balances and planned obligations into spending power", () => {
  expect(buildDashboardMoneyModel({
    accounts: [{ id: "cash", type: "checking", initial_balance: 100 }],
    transactions: [
      { account_id: "cash", destination_account_id: null, type: "expense", amount: 10, status: "paid", competence_date: "2026-07-28" },
      { account_id: "cash", destination_account_id: null, type: "income", amount: 500, status: "planned", competence_date: "2026-08-05" },
    ],
    occurrences: [{ amount: 30, due_date: "2026-08-01", status: "planned" }],
    today: "2026-07-28",
  }).spendingPower.availableCents).toBe(60_00);
});
```

- [ ] **Step 2: Executar para confirmar a falha**

Run: `npm test -- src/lib/finance/today-adapter.test.ts`

Expected: FAIL porque `buildDashboardMoneyModel` ainda não existe.

- [ ] **Step 3: Expandir tipos, queries e adaptador**

No caminho `dashboard`, carregue em paralelo: preferência do workspace, lançamentos pagos e planejados que possam afetar o cálculo, e ocorrências materializadas para o mês atual e o próximo. Se a preferência apontar para conta inativa, trate-a como `null`; não altere a preferência silenciosamente. Faça `DashboardPage` usar `buildDashboardMoneyModel` em vez de somar `initial_balance` diretamente.

```ts
export function buildDashboardMoneyModel(input: DashboardMoneyInput) {
  const cashPosition = calculateCashPosition(input.accounts, input.transactions);
  return {
    cashPosition,
    spendingPower: buildSpendingPower({
      currentBalanceCents: cashPosition.balanceCents,
      today: input.today,
      plannedTransactions: input.transactions,
      commitments: input.occurrences,
    }),
  };
}
```

- [ ] **Step 4: Executar testes da regra e do adaptador**

Run: `npm test -- src/lib/finance/cash-position.test.ts src/lib/finance/spending-power.test.ts src/lib/finance/today-adapter.test.ts`

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/app/components/types.ts src/app/components/useFinance.ts src/app/DashboardPage.tsx src/lib/finance/today-adapter.ts src/lib/finance/today-adapter.test.ts
git commit -m "feat: load daily money decision model"
```

### Task 5: Exibir a decisão diária de forma auditável

**Files:**
- Create: `src/app/components/SpendingPowerCard.tsx`
- Create: `src/app/components/SpendingPowerCard.test.tsx`
- Modify: `src/app/DashboardPage.tsx`
- Modify: `src/app/dashboard-extra.css`

**Interfaces:**
- Consumes: `SpendingPower` de `src/lib/finance/spending-power.ts`.
- Produces: `<SpendingPowerCard spendingPower={...} />`.

- [ ] **Step 1: Escrever os testes de conteúdo acessível**

```tsx
it("states the available amount and the next income date", () => {
  render(<SpendingPowerCard spendingPower={{ availableCents: 600_00, nextIncomeDate: "2026-08-05", reservedCommitmentsCents: 300_00, reservedExpenseCents: 100_00 }} />);
  expect(screen.getByRole("heading", { name: "Disponível para gastar" })).toBeTruthy();
  expect(screen.getByText(/R\$\s?600,00/)).toBeTruthy();
  expect(screen.getByText(/05\/08/)).toBeTruthy();
});
```

- [ ] **Step 2: Executar para confirmar a falha**

Run: `npm test -- src/app/components/SpendingPowerCard.test.tsx`

Expected: FAIL com erro de módulo inexistente.

- [ ] **Step 3: Implementar card e explicação**

O card deve apresentar valor, `até DD/MM` quando houver próxima receita, ou `nos próximos 30 dias` quando não houver. Um `details` deve explicar separadamente as reservas de compromissos e despesas planejadas; não use gráfico para esse único número.

```tsx
export function SpendingPowerCard({ spendingPower }: { spendingPower: SpendingPower }) {
  return <section className="spending-power-card" aria-labelledby="spending-power-title">
    <p id="spending-power-title">Disponível para gastar</p>
    <strong>{money(spendingPower.availableCents / 100)}</strong>
    <small>{spendingPower.nextIncomeDate ? `Até ${dateFmt.format(localDate(spendingPower.nextIncomeDate))}` : "Considerando os próximos 30 dias"}</small>
    <details><summary>Como calculamos</summary>
      <p>Compromissos reservados: {money(spendingPower.reservedCommitmentsCents / 100)}</p>
      <p>Despesas planejadas: {money(spendingPower.reservedExpenseCents / 100)}</p>
    </details>
  </section>;
}
```

- [ ] **Step 4: Inserir o card antes do `TodayPanel` e estilizar estados responsivos**

Mantenha o `TodayPanel` para alertas e ações contextuais. O novo card é o primeiro elemento financeiro após o resumo do cabeçalho e deve ter foco visível, contraste adequado e não depender apenas de cor.

- [ ] **Step 5: Executar os testes de componente**

Run: `npm test -- src/app/components/SpendingPowerCard.test.tsx src/app/components/TodayPanel.test.tsx`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/app/components/SpendingPowerCard.tsx src/app/components/SpendingPowerCard.test.tsx src/app/DashboardPage.tsx src/app/dashboard-extra.css
git commit -m "feat: show available daily spending"
```

### Task 6: Criar registro rápido com defaults seguros

**Files:**
- Create: `src/app/components/QuickTransactionForm.tsx`
- Create: `src/app/components/QuickTransactionForm.test.tsx`
- Modify: `src/app/DashboardPage.tsx`
- Modify: `src/app/components/useFinance.ts`
- Modify: `src/app/dashboard-extra.css`

**Interfaces:**
- Consumes: `workspaceId`, `defaultCashAccountId`, `accounts`, `categories`, `onSaved(): Promise<void>`.
- Produces: `<QuickTransactionForm ... />`, que insere somente `expense` ou `income` como `paid` na data de São Paulo.

- [ ] **Step 1: Escrever os testes de fluxo rápido**

Mocke `createClient` e teste o payload observável.

```tsx
it("uses the default account and today when only amount and description are filled", async () => {
  render(<QuickTransactionForm workspaceId="w" ownerId="u" defaultCashAccountId="a" accounts={[{ id: "a", name: "Principal", type: "checking", initial_balance: 0 }]} categories={[]} onSaved={vi.fn()} />);
  await userEvent.type(screen.getByLabelText("Valor"), "12,50");
  await userEvent.type(screen.getByLabelText("Descrição"), "Café");
  await userEvent.click(screen.getByRole("button", { name: "Registrar" }));
  expect(insert).toHaveBeenCalledWith(expect.objectContaining({ account_id: "a", type: "expense", amount: 12.5, status: "paid", competence_date: "2026-07-28" }));
});

it("requires an account when there is no default", async () => {
  render(<QuickTransactionForm workspaceId="w" ownerId="u" defaultCashAccountId={null} accounts={[]} categories={[]} onSaved={vi.fn()} />);
  await userEvent.click(screen.getByRole("button", { name: "Registrar" }));
  expect(screen.getByRole("alert").textContent).toContain("Escolha uma conta");
});
```

- [ ] **Step 2: Executar para confirmar a falha**

Run: `npm test -- src/app/components/QuickTransactionForm.test.tsx`

Expected: FAIL com erro de módulo inexistente.

- [ ] **Step 3: Implementar o formulário compacto**

Campos visíveis: seletor `Despesa`/`Receita`, `Valor`, `Descrição` e botão `Registrar`. Em `Mais detalhes`, renderize conta, categoria e data. A conta padrão deve ser usada mesmo que o seletor permaneça fechado. Gere `idempotency_key` com `crypto.randomUUID()` e mostre sucesso/erro com `role="status"`/`role="alert"`.

```ts
await supabase.from("transactions").insert({
  workspace_id: workspaceId,
  owner_id: ownerId,
  account_id: selectedAccountId,
  category_id: selectedCategoryId || null,
  destination_account_id: null,
  type,
  amount: parseMoney(form.get("amount")),
  description: String(form.get("description")).trim(),
  competence_date: selectedDate,
  paid_at: selectedDate,
  status: "paid",
  idempotency_key: crypto.randomUUID(),
});
```

- [ ] **Step 4: Carregar a preferência no dashboard e compor o formulário**

Obtenha `ownerId` uma vez no hook e exponha-o apenas após autenticação; não repita `auth.getUser()` no componente. Faça `DashboardPage` passar a preferência e `reload` para o formulário.

- [ ] **Step 5: Executar testes de formulário e painel**

Run: `npm test -- src/app/components/QuickTransactionForm.test.tsx src/app/components/SpendingPowerCard.test.tsx`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/app/components/QuickTransactionForm.tsx src/app/components/QuickTransactionForm.test.tsx src/app/components/useFinance.ts src/app/DashboardPage.tsx src/app/dashboard-extra.css
git commit -m "feat: add quick daily transaction entry"
```

### Task 7: Simplificar navegação e tornar o histórico encontrável

**Files:**
- Modify: `src/app/components/Nav.tsx`
- Modify: `src/app/TransactionsPage.tsx`
- Modify: `src/app/transaction.css`
- Create: `src/app/TransactionsPage.test.tsx`

**Interfaces:**
- Consumes: a lista existente de `Transaction` do `useFinance("transactions")`.
- Produces: navegação `Painel`, `Movimentações`, `Planejamento`, `Mais`; filtros locais `query`, `type`, `from`, `to`.

- [ ] **Step 1: Escrever o teste de busca e filtro**

```tsx
it("shows only matching expenses in the selected period", () => {
  render(<TransactionsPage />);
  fireEvent.change(screen.getByLabelText("Buscar movimentações"), { target: { value: "mercado" } });
  fireEvent.change(screen.getByLabelText("Tipo"), { target: { value: "expense" } });
  expect(screen.getByText("Mercado Central")).toBeTruthy();
  expect(screen.queryByText("Salário")).toBeNull();
});
```

- [ ] **Step 2: Executar para confirmar a falha**

Run: `npm test -- src/app/TransactionsPage.test.tsx`

Expected: FAIL porque os controles de filtro ainda não existem.

- [ ] **Step 3: Implementar navegação agrupada**

Preserve cada URL atual. Renderize três links diretos e um `<details>` com Contas, Cartões, Categorias, Compromissos e Configurações; mantenha `Sair` como botão separado. Use o mesmo `appPath` e estado ativo atual.

- [ ] **Step 4: Implementar filtros locais do histórico**

Adicione estado React para texto, tipo, data inicial e final. Filtre `transactions` por descrição case-insensitive, igualdade de tipo e intervalo ISO inclusivo antes de renderizar `List`. Mostre estado vazio específico quando o filtro não retornar linhas. Mova o formulário completo para um `<details>` com resumo `Mais detalhes para registrar` e não remova suporte a transferências.

```ts
const visibleTransactions = transactions.filter((transaction) =>
  transaction.description.toLocaleLowerCase("pt-BR").includes(query.trim().toLocaleLowerCase("pt-BR")) &&
  (!type || transaction.type === type) &&
  (!from || transaction.competence_date >= from) &&
  (!to || transaction.competence_date <= to),
);
```

- [ ] **Step 5: Executar teste e suíte de componentes**

Run: `npm test -- src/app/TransactionsPage.test.tsx src/app/components/QuickTransactionForm.test.tsx src/app/components/TodayPanel.test.tsx`

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add src/app/components/Nav.tsx src/app/TransactionsPage.tsx src/app/transaction.css src/app/TransactionsPage.test.tsx
git commit -m "feat: simplify finance navigation and history"
```

### Task 8: Verificar o ciclo completo e documentar a próxima fronteira

**Files:**
- Modify: `README.md`
- Modify: `ROADMAP.md`
- Modify: `docs/superpowers/specs/2026-07-28-financas-pessoais-simples-design.md`

**Interfaces:**
- Consumes: os entregáveis das tarefas 1 a 7.
- Produces: verificação reproduzível e backlog explícito para importação/revisão, sem fingir que Open Finance foi entregue.

- [ ] **Step 1: Adicionar cenário manual de aceitação ao README**

Documente exatamente: criar conta corrente como principal, registrar renda planejada futura, criar compromisso fixo, abrir painel, conferir reserva, lançar despesa rápida e localizar a despesa pelo histórico.

- [ ] **Step 2: Atualizar roadmap com o limite da entrega**

Marque a entrega como concluída apenas depois da verificação e acrescente a próxima fase: `Importação OFX/CSV com prévia, deduplicação e inbox de revisão`. Não mencione Open Finance como implementado.

- [ ] **Step 3: Executar verificações automáticas**

Run: `npm run lint`

Expected: exit code 0, sem warnings.

Run: `npm test`

Expected: exit code 0.

Run: `npm run build`

Expected: exit code 0.

- [ ] **Step 4: Executar a validação manual**

Run: `npm run dev`

Expected: o painel mostra disponibilidade explicada; o registro rápido cria a despesa na conta principal; busca no histórico a encontra; nenhuma rota secundária foi perdida.

- [ ] **Step 5: Commit**

```bash
git add README.md ROADMAP.md docs/superpowers/specs/2026-07-28-financas-pessoais-simples-design.md
git commit -m "docs: describe simple personal finance flow"
```

## Self-review

- Cobertura: conta principal (Tarefa 1), saldo real (Tarefa 2), disponibilidade projetada (Tarefas 3–5), registro simples (Tarefa 6), navegação e histórico (Tarefa 7), verificação e documentação (Tarefa 8).
- Limites: importação, regras e contexto MEI foram explicitamente excluídos; cada um precisa de plano próprio porque envolve modelo de dados e fluxos de erro independentes.
- Consistência: todos os cálculos usam centavos nas funções puras, datas ISO de São Paulo e lançamentos `paid`/`planned` já existentes.
