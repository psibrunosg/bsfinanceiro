# Graph Report - bsfinanceiro  (2026-07-15)

## Corpus Check
- 69 files · ~64,744 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 290 nodes · 444 edges · 20 communities (16 shown, 4 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `719f8319`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- devDependencies
- compilerOptions
- Design System Master File
- dependencies
- package.json
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
- actions.ts
- page.tsx
- preferences-form.tsx
- alerts.ts

## God Nodes (most connected - your core abstractions)
1. `requireFinanceContext()` - 42 edges
2. `compilerOptions` - 16 edges
3. `createClient()` - 14 edges
4. `projectWeekly()` - 8 edges
5. `Roadmap` - 7 edges
6. `Design System Master File` - 7 edges
7. `scripts` - 6 edges
8. `calculateBudgetConsumption()` - 6 edges
9. `calculateGoalProgress()` - 6 edges
10. `BS Financeiro` - 6 edges

## Surprising Connections (you probably didn't know these)
- `middleware()` --calls--> `updateSession()`  [EXTRACTED]
  middleware.ts → src/lib/supabase/middleware.ts
- `Page()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/cartoes/[id]/page.tsx → src/lib/finance/context.ts
- `Page()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/cartoes/page.tsx → src/lib/finance/context.ts
- `CommitmentsPage()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/compromissos/page.tsx → src/lib/finance/context.ts
- `Page()` --calls--> `requireFinanceContext()`  [EXTRACTED]
  src/app/configuracoes/page.tsx → src/lib/finance/context.ts

## Import Cycles
- None detected.

## Communities (20 total, 4 thin omitted)

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
Cohesion: 0.06
Nodes (31): dependencies, lucide-react, next, react, react-dom, @supabase/ssr, @supabase/supabase-js, zod (+23 more)

### Community 4 - "package.json"
Cohesion: 0.19
Nodes (16): archiveCommitment(), commitmentSchema, CommitmentState, createCommitment(), money, nullableUuid, referencesBelongToWorkspace(), refreshCommitments() (+8 more)

### Community 6 - "include"
Cohesion: 0.12
Nodes (20): archiveCard(), CardState, createCard(), createPurchase(), money, payInvoice(), paymentSchema, purchaseSchema (+12 more)

### Community 7 - "BS Financeiro"
Cohesion: 0.13
Nodes (13): Banco, BS Financeiro, Começar, Estado atual, Plano de desenvolvimento, Verificação, Depois da primeira liberação, P0. Vincular e validar o banco (+5 more)

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
Cohesion: 0.11
Nodes (25): archiveCategory(), CategoryState, createCategory(), schema, CategoryForm(), Page(), AccountForm(), types (+17 more)

### Community 20 - "page.tsx"
Cohesion: 0.13
Nodes (22): addToGoal(), budgetSchema, contributionSchema, createGoal(), goalSchema, money, PlanningState, saveBudget() (+14 more)

### Community 25 - "preferences-form.tsx"
Cohesion: 0.25
Nodes (8): saveAlertPreferences(), schema, SettingsState, defaults, Page(), items, Preferences, PreferencesForm()

### Community 26 - "alerts.ts"
Cohesion: 0.27
Nodes (8): AlertPreference, AlertPreferences, AlertSeverity, FinancialAlert, selectAlerts(), severityPriority, alerts, allEnabled

## Knowledge Gaps
- **127 isolated node(s):** `compat`, `config`, `config`, `nextConfig`, `name` (+122 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `requireFinanceContext()` connect `actions.ts` to `package.json`, `include`, `actions.ts`, `createClient`, `page.tsx`, `preferences-form.tsx`?**
  _High betweenness centrality (0.178) - this node is a cross-community bridge._
- **Why does `createClient()` connect `createClient` to `actions.ts`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **What connects `compat`, `config`, `config` to the rest of the system?**
  _128 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Design System Master File` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.0625 - nodes in this community are weakly interconnected._
- **Should `include` be split into smaller, more focused modules?**
  _Cohesion score 0.12307692307692308 - nodes in this community are weakly interconnected._