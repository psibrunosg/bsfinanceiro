# Guia de Manutenção — BS Financeiro

> Documento de apoio para quem for dar manutenção no projeto. Derivado da
> auditoria de `docs/auditoria-projeto.md` e revalidado contra o código em
> 2026-08 (gates rodados de fato, ver seção 3). Se algo aqui divergir do
> código, o código vence — e este doc deve ser corrigido (ver seção 7).

---

## 1. Visão rápida

| Item | Valor |
|---|---|
| Stack | Next.js 15 (`output: "export"`, site 100% estático), React 19, TypeScript 5.7 strict |
| Backend | Supabase (Postgres + RLS + Auth), projeto `wgntlhzjyriwhncumjsv` |
| Banco | 29 migrations em `supabase/migrations/` (até `20260803000001`) + 2 Edge Functions (importação de faturas) |
| Testes | Vitest (unitários) + Playwright (e2e/visual) |
| Deploy | GitHub Pages via `.github/workflows/nextjs.yml`, branch `main` publica automaticamente |
| PWA | `public/manifest.webmanifest` + `public/sw.js` |

**Docs-chave:**

- `README.md` — setup, deploy, cenário manual de aceitação.
- `CLAUDE.md` (raiz) — resumo operacional: workflow, gates, pausas, deploy.
- `docs/dev-workflow.md` — ciclo completo SOL/TERRA/LUA, fases, handoffs.
- `docs/auditoria-projeto.md` — auditoria completa (incongruências, dívidas).
- `DESAFIOS.md` — pontos de fricção confirmados; **ler no início de qualquer sessão**.
- `docs/agents/` — issue tracker, triage labels, domain docs.
- `ROADMAP.md` / `docs/PLAN-evolution.md` — fonte de trabalho futuro.

## 2. Comandos do dia a dia

Comandos reais do `package.json` (Node ≥ 22, npm 11):

| Comando | O que faz | Notas |
|---|---|---|
| `npm run dev` | `next dev` — servidor local | Precisa de `.env.local` (copiar de `.env.example`) |
| `npm run build` | `next build` — export estático em `out/` | **Sem rotas dinâmicas nem server features** — quebra o build |
| `npm run lint` | `eslint src` | ESLint 9 flat config + `eslint-config-next` |
| `npm test` | `vitest run --passWithNoTests` | Unitários; roda em ~30 s |
| `npm run test:visual` | `playwright test` | e2e/visual; setup autenticado opcional via `E2E_EMAIL`/`E2E_PASSWORD` em `.env.local` |
| `supabase db push` | aplica migrations no remoto | Só após revisão de rollback; validar no remoto **antes** de publicar o frontend |

**Armadilhas conhecidas:**

- **Export estático**: o app é um site estático no GitHub Pages. **Não existe middleware Next.js** — o helper antigo `src/lib/supabase/middleware.ts` era código morto e já foi removido. A proteção é guarda client-side + RLS no Supabase. Não adicione `src/middleware.ts` esperando que execute em produção.
- **Variáveis de ambiente**: só `NEXT_PUBLIC_*` chegam ao build. Nunca use `service_role` no cliente nem nos secrets do GitHub Actions.
- **Migrations antes do frontend**: mudança que depende de migration nova só pode ser publicada depois do `supabase db push` validado.
- **RLS**: conferir isolamento com `supabase/rls-smoke-test.sql` ao tocar em tabelas/policies.
- **Snapshots visuais Windows**: `e2e/visual.e2e.ts-snapshots/*-win32.png` quebrariam em CI Linux; hoje os testes visuais rodam só localmente.
- **`useFinance("dashboard")` fora do dashboard**: `/gastos`, `/ganhos` e `/investimentos` chamam o hook do dashboard só para obter `defaultCashAccountId` — carrega o painel inteiro. É workaround conhecido, não padrão a copiar (ver DESAFIOS.md).

## 3. Estado atual dos gates

**Revalidado hoje (sessão da criação deste doc):**

| Gate | Estado | Evidência |
|---|---|---|
| `npm run lint` | ✅ verde | 0 erros, 0 warnings |
| `npm test` | ✅ verde | 32 arquivos, **168 testes passando** |
| `npm run build` | não revalidado nesta sessão | último deploy em produção ok |

> A auditoria registrava 1 teste quebrado em `useFinance.test.tsx:393` (esperado 30, recebido 1) e 2 warnings de lint, vindos do `DESAFIOS.md` (2026-08-08). **Isso já foi resolvido** — os gates estão verdes. Se encontrar o gate vermelho de novo, rode lint+test no início da sessão para saber se a falha é sua ou herdada antes de investigar.

## 4. Dívidas e cuidados conhecidos

Lista viva. Ao tocar numa área, resolva ou atualize o item correspondente.

### Testes duplicados em dois padrões

- **O que é**: `src/app/components/Money.test.ts` **e** `src/app/components/__tests__/Money.test.ts` coexistem (idem `SimpleForm.test.tsx`). O resto do projeto coloca o `.test.ts` ao lado do módulo.
- **Onde**: `src/app/components/`.
- **Ao tocar**: padronize no padrão colocado-ao-lado e remova a duplicata de `__tests__/`; confira que os dois não divergiram em cobertura.

### Docs que congelam rápido

- **O que é**: README/ROADMAP já disseram "oito migrations" quando eram 29; o design system (`design-system/bs-financeiro/MASTER.md`) descreve um app que não existe (paleta azul, GSAP, tokens `--color-*`).
- **Onde**: contagens de migrations em `README.md`/`ROADMAP.md`; UI real em `src/app/globals.css`.
- **Ao tocar**: ao adicionar migration, atualize a contagem nos docs. **Nunca use `design-system/bs-financeiro/MASTER.md` como fonte de UI** — a fonte real é `globals.css`. Ideal: arquivar ou reescrever o MASTER.md.

### `work/` com dados pessoais

- **O que é**: `work/` contém handoffs do workflow e SQL pessoal (ex.: `importar_faturas_agosto.sql`). Hoje está **ignorado** no `.gitignore` (decisão tomada no commit de higiene `045684d`).
- **Ao tocar**: nunca commite `work/` — contém dados pessoais. Handoffs ficam locais.

### Regras de negócio em `ilike` duplicadas SQL ↔ TSX

- **O que é**: exclusões por texto (`"Fatura %"`, `"Contracheque %"`, `"Recebimento de paciente%"`) duplicadas entre RPCs SQL e cliente, para evitar dupla contagem em `/gastos` e `/ganhos`.
- **Onde**: RPCs em `supabase/migrations/` e hubs em `src/app/`.
- **Ao tocar**: ao mudar qualquer texto de descrição gerado por RPC, procure o `ilike` correspondente no cliente — senão totais dobram ou somem em silêncio. Solução de médio prazo: coluna `kind`/flag tipada.

### Barrel `pages.ts` dentro do App Router

- **O que é**: `src/app/pages.ts` re-exporta páginas; arquivos `*Page.tsx` soltos na raiz de `src/app/` não são rotas, mas parecem.
- **Ao tocar**: não se confunda — rotas são só as pastas com `page.tsx`. Solução pendente: mover `*Page.tsx` para fora de `src/app/`.

### Itens resolvidos no commit de higiene (045684d / beac32e)

- `.claude-flow/` removido do git e ignorado; `docs/PLAN-evolution-copy.md` deletado; README corrigido (migrations, middleware, OFX).

## 5. Convenções do repositório

- **Workflow de dev**: `docs/dev-workflow.md` — ciclo Preparação → Brainstorm → Spec+Plano → Aprovação → Implementação → Gates → Review (LUA) → Commit+Handoff → Deploy, com roles SOL/TERRA/LUA estritas.
- **Planos/specs**: `docs/superpowers/plans/` e `docs/superpowers/specs/` (nomeados `<data>-<slug>.md`). Handoffs em `work/handoffs/` (locais, não versionados).
- **Issue tracker**: GitHub Issues, via app GitHub conectado ou `gh` CLI (`docs/agents/issue-tracker.md`). PRs **não** são superfície de triage.
- **Triage labels**: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix` (`docs/agents/triage-labels.md`).
- **Commits**: mensagens em pt-BR com prefixo convencional (`feat:`, `fix:`, `docs:`, `chore:`), uma entrega vertical por commit.
- **Alterações locais não relacionadas**: **preservar sempre** — nunca incluí-las no commit do ciclo/plano (regra do `AGENTS.md` e `CLAUDE.md`).
- **Domain docs**: `CONTEXT.md` na raiz e `docs/adr/` **não existem hoje**; criar só quando um termo de domínio ou decisão arquitetural for de fato resolvido (`docs/agents/domain.md`).
- **Pausas obrigatórias**: risco destrutivo, custo externo, credencial ausente, mudança de escopo, decisão de negócio sem resposta segura. O resto: seguir sozinho.

## 6. Checklist antes de commitar

- [ ] `npm run lint` — 0 erros, 0 warnings.
- [ ] `npm test` — todos passando (168 no momento desta escrita).
- [ ] `npm run build` — exit 0 (obrigatório se tocou em rotas/exports).
- [ ] Migration nova? Aplicada e validada no Supabase remoto **antes** do frontend.
- [ ] Acessibilidade: estados de loading/erro com texto e semântica, nunca só cor.
- [ ] Responsividade: 375 / 768 / 1024 / 1440 px, claro/escuro.
- [ ] `git status` limpo de coisas alheias: **não commitar** `work/`, `.claude-flow/`, `.env*`, `out/`, `.next/`, `test-results/`.
- [ ] Alterações locais não relacionadas ficaram fora do commit.
- [ ] Handoff atualizado em `work/handoffs/` quando o ciclo do workflow se aplicar.

## 7. Onde atualizar este doc

Este documento **desatualiza rápido** — é a lição da auditoria. Regras:

- **Mudou comando no `package.json`, gate, convenção ou dívida?** Atualize a seção correspondente **no mesmo commit**.
- **Resolveu uma dívida da seção 4?** Remova o item (ou mova para "itens resolvidos" com o hash do commit).
- **Rodou os gates?** Atualize a seção 3 com a data e o resultado.
- **Não revalidou algo que está citando?** Marque explicitamente como "não revalidado" com a data da fonte.
- Contagem de migrations: manter sincronizada com `supabase/migrations/` (e com `README.md`/`ROADMAP.md`).
