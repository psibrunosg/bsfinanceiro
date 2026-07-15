# Graph Report - bsfinanceiro  (2026-07-13)

## Corpus Check
- 64 files · ~10,676 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 346 nodes · 511 edges · 28 communities (23 shown, 5 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `216f934a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- devDependencies
- compilerOptions
- Design System Master File
- dependencies
- package.json
- 20260712230000_initial_finance_schema.sql
- include
- BS Financeiro
- layout.tsx
- page.tsx
- eslint.config.mjs
- next.config.ts
- next-env.d.ts
- actions.ts
- middleware.ts
- createClient
- 20260712232500_user_onboarding.sql
- actions.ts
- 20260712235500_core_hardening.sql
- page.tsx
- 20260713030238_credit_cards_invoices_installments.sql
- 20260713030928_card_purchase_and_invoice_rpcs.sql
- 20260713032430_budgets_and_goals.sql
- 20260713234753_add_reliability_controls.sql
- preferences-form.tsx
- alerts.ts
- actions.ts

## God Nodes (most connected - your core abstractions)
1. `requireFinanceContext()` - 42 edges
2. `compilerOptions` - 16 edges
3. `createClient()` - 14 edges
4. `projectWeekly()` - 8 edges
5. `Design System Master File` - 7 edges
6. `scripts` - 6 edges
7. `calculateBudgetConsumption()` - 6 edges
8. `calculateGoalProgress()` - 6 edges
9. `setActive()` - 5 edges
10. `calculateInstallments()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `middleware()` --calls--> `updateSession()`  [EXTRACTED]
  middleware.ts → src/lib/supabase/middleware.ts
- `Page()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/categorias/page.tsx → src/lib/finance/context.ts
- `CommitmentsPage()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/compromissos/page.tsx → src/lib/finance/context.ts
- `Page()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/configuracoes/page.tsx → src/lib/finance/context.ts
- `GET()` --calls--> `createClient()`  [EXTRACTED]
  src/app/auth/callback/route.ts → src/lib/supabase/server.ts

## Import Cycles
- None detected.

## Communities (28 total, 5 thin omitted)

### Community 0 - "devDependencies"
Cohesion: 0.10
Nodes (21): eslint, eslint-config-next, @eslint/eslintrc, jsdom, devDependencies, eslint, eslint-config-next, @eslint/eslintrc (+13 more)

### Community 1 - "compilerOptions"
Cohesion: 0.07
Nodes (28): dom, dom.iterable, esnext, next-env.d.ts, .next/types/**/*.ts, node_modules, ./src/*, **/*.ts (+20 more)

### Community 2 - "Design System Master File"
Cohesion: 0.11
Nodes (17): Additional Forbidden Patterns, Anti-Patterns (Do NOT Use), Buttons, Cards, Color Palette, Component Specs, Design System Master File, Global Rules (+9 more)

### Community 3 - "dependencies"
Cohesion: 0.07
Nodes (27): lucide-react, next, dependencies, lucide-react, next, react, react-dom, @supabase/ssr (+19 more)

### Community 4 - "package.json"
Cohesion: 0.19
Nodes (16): archiveCommitment(), commitmentSchema, CommitmentState, createCommitment(), money, nullableUuid, referencesBelongToWorkspace(), refreshCommitments() (+8 more)

### Community 5 - "20260712230000_initial_finance_schema.sql"
Cohesion: 0.47
Nodes (8): public.accounts, public.categories, public.fixed_commitments, public.profiles, public.set_updated_at(), public.transactions, public.workspaces, transactions_set_updated_at

### Community 6 - "include"
Cohesion: 0.09
Nodes (33): archiveCard(), CardState, createCard(), createPurchase(), money, payInvoice(), paymentSchema, purchaseSchema (+25 more)

### Community 7 - "BS Financeiro"
Cohesion: 0.33
Nodes (5): Banco, BS Financeiro, Começar, Estado atual, Verificação

### Community 9 - "page.tsx"
Cohesion: 0.39
Nodes (7): addMonthsClamped(), assertNonNegativeInteger(), calculateInstallments(), CardInstallment, CardLimitSummary, parseDateOnly(), summarizeCardLimit()

### Community 14 - "actions.ts"
Cohesion: 0.24
Nodes (11): money, monthOccurrence(), Page(), shortDate, assertCents(), formatIsoDate(), getWeekStart(), parseIsoDate() (+3 more)

### Community 15 - "middleware.ts"
Cohesion: 0.60
Nodes (3): config, middleware(), updateSession()

### Community 16 - "createClient"
Cohesion: 0.14
Nodes (14): AuthState, login(), signup(), AuthForm(), GET(), POST(), completeOnboarding(), OnboardingState (+6 more)

### Community 18 - "actions.ts"
Cohesion: 0.39
Nodes (6): archiveCategory(), CategoryState, createCategory(), schema, CategoryForm(), Page()

### Community 19 - "20260712235500_core_hardening.sql"
Cohesion: 0.50
Nodes (3): public.accounts, public.categories, public.transactions

### Community 20 - "page.tsx"
Cohesion: 0.13
Nodes (22): addToGoal(), budgetSchema, contributionSchema, createGoal(), goalSchema, money, PlanningState, saveBudget() (+14 more)

### Community 21 - "20260713030238_credit_cards_invoices_installments.sql"
Cohesion: 0.33
Nodes (8): credit_card_installments_set_updated_at, credit_card_invoices_set_updated_at, credit_card_purchases_set_updated_at, credit_cards_set_updated_at, public.credit_card_installments, public.credit_card_invoices, public.credit_card_purchases, public.credit_cards

### Community 22 - "20260713030928_card_purchase_and_invoice_rpcs.sql"
Cohesion: 0.83
Nodes (3): public.create_installment_purchase(), public.credit_card_invoices, public.transactions

### Community 23 - "20260713032430_budgets_and_goals.sql"
Cohesion: 0.40
Nodes (5): financial_goals_set_updated_at, monthly_budgets_set_updated_at, public.categories, public.financial_goals, public.monthly_budgets

### Community 24 - "20260713234753_add_reliability_controls.sql"
Cohesion: 0.22
Nodes (12): alert_preferences_set_updated_at, financial_goals_enforce_progress, fixed_commitment_occurrences_set_updated_at, goal_contributions_set_updated_at, goal_contributions_sync_goal, public.alert_preferences, public.enforce_financial_goal_progress(), public.fixed_commitment_occurrences (+4 more)

### Community 25 - "preferences-form.tsx"
Cohesion: 0.25
Nodes (8): saveAlertPreferences(), schema, SettingsState, defaults, Page(), items, Preferences, PreferencesForm()

### Community 26 - "alerts.ts"
Cohesion: 0.27
Nodes (8): AlertPreference, AlertPreferences, AlertSeverity, FinancialAlert, selectAlerts(), severityPriority, alerts, allEnabled

### Community 27 - "actions.ts"
Cohesion: 0.36
Nodes (6): createTransaction(), money, schema, TransactionState, Item, TransactionForm()

## Knowledge Gaps
- **139 isolated node(s):** `compat`, `config`, `config`, `nextConfig`, `name` (+134 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `requireFinanceContext()` connect `include` to `package.json`, `actions.ts`, `createClient`, `actions.ts`, `page.tsx`, `preferences-form.tsx`, `actions.ts`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Why does `createClient()` connect `createClient` to `include`?**
  _High betweenness centrality (0.051) - this node is a cross-community bridge._
- **Why does `devDependencies` connect `devDependencies` to `dependencies`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `compat`, `config`, `config` to the rest of the system?**
  _139 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._
- **Should `Design System Master File` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._