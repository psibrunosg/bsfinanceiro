# Graph Report - bsfinanceiro  (2026-07-15)

## Corpus Check
- 67 files · ~64,724 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 286 nodes · 387 edges · 24 communities (20 shown, 4 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 10 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `3a41d271`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- devDependencies
- compilerOptions
- Design System Master File
- dependencies
- package.json
- actions.ts
- include
- BS Financeiro
- layout.tsx
- page.tsx
- eslint.config.mjs
- next.config.ts
- next-env.d.ts
- client.ts
- actions.ts
- createClient
- finance-client.tsx
- actions.ts
- devDependencies
- page.tsx
- budget.ts
- actions.ts
- alerts.ts

## God Nodes (most connected - your core abstractions)
1. `requireFinanceContext()` - 24 edges
2. `compilerOptions` - 16 edges
3. `FinanceClientPage()` - 11 edges
4. `createClient()` - 8 edges
5. `createClient()` - 7 edges
6. `Roadmap` - 7 edges
7. `Design System Master File` - 7 edges
8. `scripts` - 6 edges
9. `projectWeekly()` - 6 edges
10. `BS Financeiro` - 6 edges

## Surprising Connections (you probably didn't know these)
- `archiveAccount()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/contas/actions.ts → src/lib/finance/context.ts
- `login()` --calls--> `createClient()`  [EXTRACTED]
  src/app/(auth)/actions.ts → src/lib/supabase/server.ts
- `AuthCallbackPage()` --calls--> `createClient()`  [EXTRACTED]
  src/app/auth/callback/page.tsx → src/lib/supabase/client.ts
- `PaymentForm()` --indirect_call--> `payInvoice()`  [INFERRED]
  src/app/cartoes/[id]/payment-form.tsx → src/app/cartoes/actions.ts
- `PurchaseForm()` --indirect_call--> `createPurchase()`  [INFERRED]
  src/app/cartoes/[id]/purchase-form.tsx → src/app/cartoes/actions.ts

## Import Cycles
- None detected.

## Communities (24 total, 4 thin omitted)

### Community 0 - "devDependencies"
Cohesion: 0.39
Nodes (6): assertNonNegativeCents(), assertQuantity(), calculateInvestmentPosition(), centsFor(), InvestmentOperation, InvestmentPosition

### Community 1 - "compilerOptions"
Cohesion: 0.10
Nodes (19): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+11 more)

### Community 2 - "Design System Master File"
Cohesion: 0.11
Nodes (17): Additional Forbidden Patterns, Anti-Patterns (Do NOT Use), Buttons, Cards, Color Palette, Component Specs, Design System Master File, Global Rules (+9 more)

### Community 3 - "dependencies"
Cohesion: 0.10
Nodes (20): dependencies, lucide-react, next, react, react-dom, @supabase/ssr, @supabase/supabase-js, zod (+12 more)

### Community 4 - "package.json"
Cohesion: 0.21
Nodes (13): archiveCommitment(), commitmentSchema, CommitmentState, createCommitment(), money, nullableUuid, referencesBelongToWorkspace(), refreshCommitments() (+5 more)

### Community 5 - "actions.ts"
Cohesion: 0.31
Nodes (7): AccountForm(), types, AccountState, archiveAccount(), createAccount(), money, schema

### Community 6 - "include"
Cohesion: 0.13
Nodes (21): archiveCard(), CardState, createCard(), createPurchase(), money, payInvoice(), paymentSchema, purchaseSchema (+13 more)

### Community 7 - "BS Financeiro"
Cohesion: 0.13
Nodes (13): Banco, BS Financeiro, Começar, Estado atual, Plano de desenvolvimento, Verificação, Depois da primeira liberação, P0. Vincular e validar o banco (+5 more)

### Community 9 - "page.tsx"
Cohesion: 0.39
Nodes (7): addMonthsClamped(), assertNonNegativeInteger(), calculateInstallments(), CardInstallment, CardLimitSummary, parseDateOnly(), summarizeCardLimit()

### Community 13 - "client.ts"
Cohesion: 0.33
Nodes (4): AuthCallbackPage(), goals, OnboardingForm(), createClient()

### Community 14 - "actions.ts"
Cohesion: 0.36
Nodes (7): assertCents(), formatIsoDate(), getWeekStart(), parseIsoDate(), ProjectionEvent, projectWeekly(), WeeklyProjection

### Community 16 - "createClient"
Cohesion: 0.17
Nodes (10): AuthState, login(), signup(), AuthForm(), completeOnboarding(), OnboardingState, schema, createClient() (+2 more)

### Community 17 - "finance-client.tsx"
Cohesion: 0.08
Nodes (11): Account, brl, Card, Category, date, FinanceClientPage(), Invoice, money() (+3 more)

### Community 18 - "actions.ts"
Cohesion: 0.36
Nodes (6): saveAlertPreferences(), schema, SettingsState, items, Preferences, PreferencesForm()

### Community 19 - "devDependencies"
Cohesion: 0.18
Nodes (11): devDependencies, eslint, eslint-config-next, @eslint/eslintrc, jsdom, @testing-library/react, @types/node, @types/react (+3 more)

### Community 20 - "page.tsx"
Cohesion: 0.22
Nodes (12): addToGoal(), budgetSchema, contributionSchema, createGoal(), goalSchema, money, PlanningState, saveBudget() (+4 more)

### Community 21 - "budget.ts"
Cohesion: 0.39
Nodes (7): assertNonNegativeCents(), BudgetConsumption, BudgetStatus, calculateBudgetConsumption(), calculateGoalProgress(), GoalProgress, percentage()

### Community 22 - "actions.ts"
Cohesion: 0.36
Nodes (6): createTransaction(), money, schema, TransactionState, Item, TransactionForm()

### Community 26 - "alerts.ts"
Cohesion: 0.27
Nodes (8): AlertPreference, AlertPreferences, AlertSeverity, FinancialAlert, selectAlerts(), severityPriority, alerts, allEnabled

## Knowledge Gaps
- **126 isolated node(s):** `compat`, `config`, `nextConfig`, `name`, `version` (+121 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `requireFinanceContext()` connect `include` to `package.json`, `actions.ts`, `createClient`, `actions.ts`, `page.tsx`, `actions.ts`?**
  _High betweenness centrality (0.129) - this node is a cross-community bridge._
- **Why does `createClient()` connect `createClient` to `include`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Why does `createClient()` connect `client.ts` to `createClient`, `finance-client.tsx`?**
  _High betweenness centrality (0.062) - this node is a cross-community bridge._
- **What connects `compat`, `config`, `NOTE: This file should not be edited` to the rest of the system?**
  _127 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Design System Master File` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._