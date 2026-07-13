# Graph Report - bsfinanceiro  (2026-07-12)

## Corpus Check
- 11 files · ~2,178 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 128 nodes · 126 edges · 14 communities (9 shown, 5 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

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

## God Nodes (most connected - your core abstractions)
1. `compilerOptions` - 16 edges
2. `Design System Master File` - 7 edges
3. `scripts` - 6 edges
4. `public.workspaces` - 5 edges
5. `include` - 5 edges
6. `BS Financeiro` - 5 edges
7. `Global Rules` - 5 edges
8. `Component Specs` - 5 edges
9. `public.accounts` - 4 edges
10. `public.categories` - 4 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (14 total, 5 thin omitted)

### Community 0 - "devDependencies"
Cohesion: 0.10
Nodes (21): eslint, eslint-config-next, @eslint/eslintrc, jsdom, devDependencies, eslint, eslint-config-next, @eslint/eslintrc (+13 more)

### Community 1 - "compilerOptions"
Cohesion: 0.10
Nodes (21): dom, dom.iterable, esnext, ./src/*, compilerOptions, allowJs, esModuleInterop, incremental (+13 more)

### Community 2 - "Design System Master File"
Cohesion: 0.11
Nodes (17): Additional Forbidden Patterns, Anti-Patterns (Do NOT Use), Buttons, Cards, Color Palette, Component Specs, Design System Master File, Global Rules (+9 more)

### Community 3 - "dependencies"
Cohesion: 0.13
Nodes (15): lucide-react, next, dependencies, lucide-react, next, react, react-dom, @supabase/ssr (+7 more)

### Community 4 - "package.json"
Cohesion: 0.15
Nodes (12): engines, node, name, packageManager, private, scripts, build, dev (+4 more)

### Community 5 - "20260712230000_initial_finance_schema.sql"
Cohesion: 0.47
Nodes (8): public.accounts, public.categories, public.fixed_commitments, public.profiles, public.set_updated_at(), public.transactions, public.workspaces, transactions_set_updated_at

### Community 6 - "include"
Cohesion: 0.25
Nodes (7): next-env.d.ts, .next/types/**/*.ts, node_modules, **/*.ts, **/*.tsx, exclude, include

### Community 7 - "BS Financeiro"
Cohesion: 0.33
Nodes (5): Banco, BS Financeiro, Começar, Estado atual, Verificação

## Knowledge Gaps
- **73 isolated node(s):** `compat`, `config`, `nextConfig`, `name`, `version` (+68 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **5 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `devDependencies` connect `devDependencies` to `package.json`?**
  _High betweenness centrality (0.092) - this node is a cross-community bridge._
- **Why does `dependencies` connect `dependencies` to `package.json`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **Why does `compilerOptions` connect `compilerOptions` to `include`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **What connects `compat`, `config`, `nextConfig` to the rest of the system?**
  _73 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `devDependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `compilerOptions` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `Design System Master File` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._