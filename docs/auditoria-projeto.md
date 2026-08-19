# Auditoria do Projeto — BS Financeiro

Data da auditoria: sessão atual (repositório em `C:\Users\bruno\Documents\GitHub\bsfinanceiro`, branch `main`, último commit `46e64ab`).

---

## 1. Visão Geral do Projeto

**BS Financeiro** é um planejador e controlador financeiro pessoal (com contexto adicional "Clínica") — single-page app estático com backend Supabase.

### Stack

| Camada | Tecnologia |
|---|---|
| Frontend | Next.js 15 (`output: "export"`, trailingSlash, basePath via env), React 19, TypeScript 5.7 strict |
| Backend | Supabase (Postgres + RLS + Auth), projeto `wgntlhzjyriwhncumjsv` |
| Banco | 29 migrations SQL em `supabase/migrations` + 2 Edge Functions (process/cleanup de importação de faturas) |
| Testes | Vitest (unitários, `--passWithNoTests`), Playwright (e2e/visual, 5 projetos com setup autenticado opcional) |
| Lint | ESLint 9 flat config + `eslint-config-next` |
| Deploy | GitHub Pages via `.github/workflows/nextjs.yml` (branch `main`) |
| PWA | `public/manifest.webmanifest` + `public/sw.js` |

### Arquitetura

- **App Router** com rotas estáticas em `src/app/`: `(auth)/entrar`, `(auth)/cadastro`, `auth/callback`, `page.tsx` (Painel), `contas`, `categorias`, `movimentacoes`, `cartoes`, `compromissos`, `ganhos`, `gastos`, `investimentos`, `planejamento`, `configuracoes`, `mais`, `onboarding`.
- **Re-exports**: as rotas importam páginas de `src/app/pages.ts` (barrel com `DashboardPage`, `AccountsPage` etc.), que vivem como `*Page.tsx` na raiz de `src/app/`.
- **Componentes** em `src/app/components/` (Nav, QuickTransactionForm, StatementImportPanel, DashboardChart com Chart.js, Toast, Dialog etc.) + hooks `useFinance` e `useWorkspaceBasics`.
- **Lógica de domínio pura e testada** em `src/lib/finance/` (balance, budget, card, cash-position, projection, spending-power, today, statement-csv/ofx…) — 19 módulos, todos com `.test.ts` ao lado.
- **Supabase clients** em `src/lib/supabase/` (browser, server, middleware helper).
- **Validação** com zod em `src/lib/validation/auth.ts`.

### Workflow de desenvolvimento

Documentado em `docs/dev-workflow.md`, com roles SOL/TERRA/LUA, gates `npm run lint && npm test && npm run build`, planos em `docs/superpowers/plans/`, specs em `docs/superpowers/specs/` e handoffs em `work/handoffs/`. Issues no GitHub com triage por labels (`docs/agents/`).

## 2. Estrutura de Pastas

```
├── src/app/            Rotas + páginas + componentes (App Router)
├── src/lib/            finance/ (domínio), supabase/, validation/
├── supabase/           migrations (29), functions (2), validation (3 SQL), config.toml, rls-smoke-test.sql
├── e2e/                Playwright: smoke, visual, visual-hubs, validation-p27 + snapshots
├── docs/               dev-workflow, PLAN-evolution, superpowers/{plans,specs}, agents/, archive/
├── design-system/      bs-financeiro/MASTER.md (ver incongruências)
├── public/             ícones, manifest, sw.js
├── .github/workflows/  deploy GitHub Pages
├── .claude/            config de agente (parcialmente commitada)
├── .claude-flow/       estado de daemon commitado (lixo)
├── graphify-out/       relatórios de análise de código (ignorado, 1,3 MB em disco)
├── work/               handoffs + SQL pessoal (NÃO rastreado e NÃO ignorado)
└── .next/, out/, test-results/  artefatos de build/teste (ignorados, 295 MB em disco)
```

## 3. Arquivos Descartáveis

| Caminho | Motivo | Ação sugerida |
|---|---|---|
| `.claude-flow/daemon-state.json`, `daemon.pid`, `harness-active-policy.json`, `metrics/*` (7 arquivos) | Estado de runtime de daemon local **commitado** (PID, timestamps, métricas voláteis) | `git rm -r --cached .claude-flow` e adicionar `.claude-flow/` ao `.gitignore` |
| `.claude/proven-config.json`, `.claude/.proven-config-version` | Config local de ferramenta de agente commitada; `.claude/settings.local.json` já é ignorado | Avaliar mover para ignore; manter apenas `.claude/workflows/bsfinanceiro-loop.md` se for intencional |
| `docs/PLAN-evolution-copy.md` | Cópia **idêntica** (diff vazio) de `docs/PLAN-evolution.md` | Deletar a cópia |
| `work/` (inclui `importar_faturas_agosto.sql`) | Aparece como `?? work/` no `git status`: não rastreado nem ignorado; contém SQL com dados pessoais | Adicionar `work/` ao `.gitignore` (handoffs devem ficar locais) ou commitar só `work/handoffs/` se forem artefatos do workflow — decidir e documentar |
| `tsconfig.tsbuildinfo` (161 KB) e `next-env.d.ts` em disco | tsbuildinfo já está no ignore; `next-env.d.ts` está **commitado** (gerado automaticamente pelo Next) | Opcional: remover `next-env.d.ts` do git (é regenerado); baixa prioridade |
| `.next/` (291 MB), `out/` (3,4 MB), `test-results/`, `graphify-out/` (1,3 MB) | Artefatos locais ignorados — corretos, mas ocupam ~296 MB | Limpar localmente quando preciso (`git clean -fdX` remove tudo de uma vez) |
| `e2e/visual.e2e.ts-snapshots/*-win32.png` | Snapshots visuais Windows commitados — quebram em CI Linux se o job rodar lá | Confirmar que testes visuais só rodam localmente; senão, parametrizar por OS |

## 4. Incongruências Encontradas

| # | Item | Evidência | Impacto | Recomendação |
|---|---|---|---|---|
| 1 | README/ROADMAP dizem "oito migrations" | `README.md:45`, `ROADMAP.md` ("recriado a partir das oito migrations"); existem **29** migrations (até `20260803000001`) | Documentação desatualizada induz erro sobre o estado real do banco | Atualizar contagem e lista nos dois arquivos |
| 2 | README diz "Middleware protege o dashboard e valida tokens com `getClaims()`" | Existe `src/lib/supabase/middleware.ts`, mas **não existe `src/middleware.ts`** e nada importa o helper; com `output: "export"` + GitHub Pages, middleware Next não executa | Proteção de rotas descrita no README não existe em produção — risco de falsa sensação de segurança (RLS ainda protege os dados) | Corrigir README; documentar que a guarda é client-side + RLS |
| 3 | README diz "OFX … ainda não faz parte desta entrega" | `src/lib/finance/statement-ofx.ts` existe e `StatementImportPanel.tsx` importa `parseOfxStatement`, aceita `.ofx/.qfx` e exibe "Aceita CSV e OFX" | Doc contradiz a feature entregue | Atualizar README seção de importação |
| 4 | `design-system/bs-financeiro/MASTER.md` não descreve o app | DESAFIOS.md confirma: paleta azul/GSAP/tokens `--color-*` no doc vs. verde/`--bg`/`--surface`/`--accent` em `src/app/globals.css` | Design system falso leva agentes/devs a gerar UI errada | Marcar como obsoleto, arquivar ou reescrever a partir de `globals.css` |
| 5 | Teste quebrado herdado na `main` | `DESAFIOS.md`: em 2026-08-08 `useFinance.test.tsx:393` falhava na main (esperado 30, recebido 1) + 2 warnings de lint | Gate `npm test` vermelho na base quebra a regra dos próprios gates | Corrigir o teste e os warnings; considerar CI rodando os gates |
| 6 | `work/handoffs/` referenciado pelo workflow mas não versionado | `CLAUDE.md:9` manda handoffs para `work/handoffs/`; pasta é untracked e não ignorada | Handoffs somem de `git status` limpo ou viram ruído (`?? work/`) | Decidir: versionar handoffs (parte do processo) ou ignorar `work/` inteiro |
| 7 | Duplicação de testes | `src/app/components/Money.test.ts` **e** `src/app/components/__tests__/Money.test.ts`; idem `SimpleForm.test.tsx` | Dois padrões de colocação de teste convivendo; risco de suites divergirem | Padronizar (colocado ao lado do módulo, como o resto do projeto) e remover duplicatas |
| 8 | `.claude-flow` e `.claude` commitados vs. `.claude/settings.local.json` ignorado | `git ls-files` inclui `.claude-flow/*` e `.claude/proven-config.json` | Política inconsistente de o que é config de ferramenta vs. do projeto | Definir política única no `.gitignore` |
| 9 | `pages.ts` como barrel dentro de `app/` | `src/app/pages.ts` re-exporta páginas; padrão incomum no App Router (arquivos soltos `*Page.tsx` na raiz de `app/` sem serem rotas) | Confunde a convenção Next (tudo em `app/` parece rota) | Mover `*Page.tsx` para `src/pages/` ou `src/components/pages/` fora do App Router |
| 10 | Regras de negócio em `ilike` duplicadas SQL ↔ TSX | `DESAFIOS.md`: `"Fatura %"`, `"Contracheque %"`, `"Recebimento de paciente%"` duplicados entre RPCs e cliente | Mudança de texto gera dupla contagem silenciosa | Centralizar marcadores (coluna `kind`/flag) em vez de pattern matching de descrição |
| 11 | `useFinance("dashboard")` usado como workaround | `/gastos`, `/ganhos`, `/investimentos` chamam o hook do dashboard só para obter `defaultCashAccountId` (DESAFIOS.md) | Carrega o painel inteiro sem necessidade | Extrair query leve de `defaultCashAccountId` |
| 12 | Datas futuras coerentes internamente, mas confusas | Migrations e docs usam 2026-07/08; `README.md:45` cita "15/07/2026" | Não é bug, mas dificulta auditoria cronológica externa | Nenhuma ação obrigatória; registrar convenção |

## 5. Recomendações Prioritárias

1. **Limpar o git de lixo de ferramentas**: `git rm -r --cached .claude-flow` (+ ignore), decidir `.claude/` e `work/`, deletar `docs/PLAN-evolution-copy.md`. Commit único de higiene.
2. **Corrigir documentação crítica**: README (nº de migrations, middleware inexistente, OFX entregue) e ROADMAP — itens 1–3 da tabela de incongruências.
3. **Resolver o gate vermelho**: rodar `npm run lint && npm test && npm run build`, corrigir `useFinance.test.tsx` e os warnings; sem isso todo o workflow de gates é teoria.
4. **Arquivar ou reescrever `design-system/MASTER.md`** a partir de `src/app/globals.css` — hoje ele ativamente induz a erro.
5. **Padronizar testes duplicados** (`__tests__/` vs. colocado) e consolidar o barrel `pages.ts` fora de `src/app/`.
6. **Médio prazo**: substituir regras `ilike` por colunas tipadas; extrair `defaultCashAccountId` do `useFinance`; avaliar CI para rodar os gates (hoje o workflow só faz build+deploy, sem lint/test).

---

*Relatório gerado por auditoria automatizada do repositório. Nenhum arquivo foi modificado além deste documento.*
