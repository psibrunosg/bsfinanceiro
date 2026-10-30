# ORQUESTRAÇÃO, ECONOMIA DE TOKENS & SUB-AGENTES

Vale para todos os projetos. O usuário otimiza **limite de uso e tokens**, não geração: o maior gargalo medido é **contexto relido**.

## 1. COMUNICAÇÃO & HIGIENE DE RESPOSTA
- Seja direto, conciso e técnico. Omita saudações, preâmbulos e resumos prolixos.
- Responda diretamente com código, diffs cirúrgicos ou respostas concretas.
- Edições cirúrgicas sempre: nunca reescreva arquivos inteiros para alterações localizadas.

## 2. MATRIZ DE ESCALONAMENTO DE MODELOS & AGENTES (POR DEMANDA)
Mapeamento funcional dinâmico (resolve para a versão ativa mais recente de cada família):
- **Fast Tier (Haiku-class / agentes `investigador` e `verificador`)**:
  - Leitura, busca de arquivos, mapeamento de símbolos, varredura de logs/traces e validação de sintaxe.
  - Regra de Ouro: **Sempre delegue leituras pesadas ao Fast Tier**, independente do tamanho da tarefa. As dezenas de leituras nunca entram na sessão principal (evita inflar o contexto relido a cada turno).
- **Standard Tier (Sonnet-class / agente `construtor` / Sessão Principal)**:
  - Raciocínio central, arquitetura da tarefa, implementação de código e refatorações padrão.
- **Deep Reasoning Tier (Opus-class / Extended Thinking)**:
  - Acionamento estritamente sob demanda para impasses sistêmicos após >2 iterações falhas ou decisões arquiteturais críticas.
- *Nota de chamada*: Definidos em `~/.claude/agents/`. Não passe `model:` na chamada se o agente já possuir modelo definido no frontmatter.

## 3. QUANDO DELEGAR VS QUANDO FAZER DIRETO
Sub-agente também consome tokens (inicia do zero e relê arquivos).
- **Fazer Direto**: Correção de 1 linha, ajuste de texto, rename mecânico ou quando o código já estiver inteiro no contexto da sessão. Resposta correta: *"Fiz direto, era menor que o custo de delegar."*
- **Delegar para Sub-Agente**: Tarefa toca 2+ arquivos, passa de ~40 linhas, ou mexe em dinheiro/segurança/migration.
- **Não rodar pipeline sobre o que já está pronto**: Se o objetivo já estiver majoritariamente cumprido, execute apenas o que resta.

## 4. QUARENTENA DE CONTEXTO & PROTOCOLO DE VALIDAÇÃO (LANGFLOW PATTERN)
- **Payloads Isolados**: Prompts de subagente devem ser autocontidos; nunca repasse histórico conversacional desnecessário.
- **Retornos Filtrados**: Subagentes nunca despejam saídas brutas de ferramentas na sessão principal. Limite de retorno a 5–10 linhas sintetizadas ou diff cirúrgico.
- **Respostas Estritas em Validação**: Agentes verificadores respondem estritamente:
  `{"status":"PASS"}` ou `{"status":"FAIL","reason":"<até 10 palavras>"}`
- **Conferência Crítica**: Conferir PASS por conta própria antes de consolidar (PASS de subagente é sinal, não prova definitiva).
- **Loop Autônomo de Correção**: Subagentes devem depurar erros de build/lint/teste internamente no seu contexto antes de reportar.
- **Reaproveitamento de Agente**: Reutilizar um subagente já finalizado com `SendMessage` + `agentId` reaproveita o contexto e sai bem mais barato do que abrir um novo.

## 5. LAZY LOADING & DISCIPLINA DE FERRAMENTAS (PLANDEX PATTERN)
- **Outline First**: Proibido ler arquivos inteiros >100 linhas na sessão principal. Use grep, busca de símbolos ou leitura fatiada (`start_line`/`end_line`).
- **Silenciamento de Shell**: Redirecione comandos verbosos para arquivo temporário (`cmd > /tmp/run.log 2>&1 || tail -n 25 /tmp/run.log`). Avalie exit codes primeiro; inspecione logs apenas em falhas.
- **Escada do Ponytail**: Parar no primeiro degrau que resolve. Marcar atalho deliberado com comentário `ponytail:` e deixar verificação executável para lógica não trivial.
- **Imutabilidade de Cache**: Mantenha este cabeçalho estático para preservar o cache hit de prompt (>90%).

## 6. PARALELISMO POR ONDAS & SESSÕES LONGAS
- **Onda 0 (Direto)**: Fundação compartilhada (imports, tokens, types, helpers base). É pequena e serializa o restante se delegada.
- **Onda 1 (Paralelo)**: Subagentes em paralelo numa única mensagem, cada um com conjunto de arquivos **disjunto** e lista explícita de "DO NOT EDIT" para evitar conflito. Fatiar por arquivo, nunca por camada abstrata.
- **Corte de Sessões Longas via Issues**: Tarefa que sobrevive a uma sessão vira **Issue no GitHub** (`gh issue`). A issue preserva o estado entre sessões; encerre sessões longas para evitar estourar o limite de contexto relido.

---


# BS Financeiro

Planejador e controlador financeiro pessoal — Next.js 15, React 19, TypeScript, Supabase (Postgres/RLS/Auth), Vitest, Playwright. Deploy estático via GitHub Pages. Projeto Supabase: `wgntlhzjyriwhncumjsv`. Node >= 22.

## Comandos

```bash
npm run dev                      # servidor de desenvolvimento
npm run lint                     # eslint src
npm test                         # vitest run --passWithNoTests
npm run build                    # next build (export estático para out/)
npx tsc --noEmit                 # typecheck; NÃO faz parte do `build`, rode à parte
```

Testes pontuais (o script `test` não repassa argumentos — chame o vitest direto):

```bash
npx vitest run src/lib/finance/health.test.ts
npx vitest run -t "taxa de poupança"
npx vitest                       # watch
```

Visual/e2e (Playwright, 4 viewports: mobile/tablet/laptop/desktop):

```bash
npm run test:visual
npx playwright test e2e/smoke.e2e.ts
npx playwright test --update-snapshots   # regrava baseline; confirme com o usuário antes
```

## Arquitetura

**Export estático muda tudo.** `next.config.ts` usa `output: "export"` + `trailingSlash`. Não existe server component buscando dados, route handler, nem middleware do Next — **toda leitura de dados é client-side**. `src/lib/supabase/server.ts` e `middleware.ts` existem mas não participam do runtime publicado. Links e redirects passam por `appPath()` / `appUrl()` (`src/lib/app-path.ts`), que detecta o basePath `/bsfinanceiro` do GitHub Pages em runtime.

**Rotas são cascas.** `src/app/<rota>/page.tsx` é um re-export de duas linhas; o componente real mora em `src/app/XxxPage.tsx` (agregados em `src/app/pages.ts`). Ao procurar a tela de `/contas`, abra `src/app/AccountsPage.tsx`.

**`useFinance(route)` é a camada de dados inteira.** `src/app/components/useFinance.ts` é um único hook client-side que faz `switch` numa string de rota (`"dashboard" | "transactions" | "card" | "cards" | "planning" | "commitments"`) e dispara queries supabase-js diretas. Sem react-query, sem SWR. A branch `"dashboard"` carrega **todas** as transações em lotes de 500 — por isso relatórios e agregações são filtragem client-side pura, e adicionar uma query nova quase nunca é necessário. Retorna `reload()` para revalidar após escrita.

**Lógica pura vive em `src/lib/finance/`** e é onde ficam os testes. Componentes devem chamar essas funções, não reimplementar cálculo:
- `aggregations.ts` — gastos por categoria, fluxo mensal, evolução de saldo, decisão diária.
- `transfers.ts` — transferência entre contas **não é receita nem despesa**. Passe por `filterOutTransfers` / `isTransferTransaction` antes de somar qualquer coisa, senão o dinheiro é contado em dobro.
- `local-date.ts` — fuso America/Sao_Paulo. `todayInSaoPaulo`, `addMonths`, `monthRangeOf`, `monthLabel`.
- `health.ts` — indicadores da página `/saude`.

**Convenções de dados que já causaram bug:**
- Valores monetários são **strings numéricas em reais** (`numeric(14,2)`), não centavos — sempre `Number(t.amount)`. A exceção é `cashPosition`, em centavos.
- `competence_date` é a competência. Não existe coluna `mes`/`competencia`.
- Filtro de mês é **intervalo semiaberto** `>= "YYYY-MM-01" && < próximo mês`. O padrão antigo `<= "YYYY-MM-31"` era comparação de string e vazava.
- `Money.monthStart()` usa UTC; o resto do app usa São Paulo. Prefira `local-date.ts`.

**Mês global.** `src/app/components/MonthContext.tsx` (`MonthProvider` montado no `layout.tsx`) guarda o mês selecionado em `YYYY-MM-01`, persistido em localStorage e compartilhado por dashboard, gastos, ganhos, relatórios e saúde. Telas com recorte mensal consomem `useMonth()` e renderizam `<MonthPicker />` em vez de calcular "mês atual" sozinhas.

**CSS puro, sem Tailwind e sem shadcn.** Folhas colocadas em `src/app/*.css`. **Toda folha precisa ser importada explicitamente em `src/app/layout.tsx`** — `dialog.css` ficou órfã por meses e todos os modais renderizavam sem estilo. Tokens de cor ficam só em `globals.css` (`:root` e `:root[data-theme="dark"]`); `ThemeProvider` apenas alterna `data-theme`. Diretrizes visuais em `design-system/bs-financeiro/MASTER.md`. Modais usam `Dialog` + `SimpleForm`; gráficos usam o wrapper `DashboardChart` (chart.js), que lê os tokens do tema ativo.

**Testes.** Vitest sem setup global: cada arquivo que precisa de DOM declara `// @vitest-environment jsdom` na linha 1. Duas convenções de colocação convivem — `*.test.ts` ao lado do fonte e `__tests__/`. Testes de componente mockam `@/lib/supabase/client` e o `useFinance` inteiro.

**Banco.** Migrations em `supabase/migrations/`, RLS por proprietário, operações compostas em RPCs atômicas (ex.: `create_credit_card`, `materialize_fixed_commitment_occurrences`). Não há `database.types.ts` gerado — os tipos são escritos à mão em `src/app/components/types.ts` e precisam ser atualizados junto com a migration. Scripts de seed pontuais em `scripts/`.

## Workflow

- **Workflow canônico:** `docs/dev-workflow.md` — ciclo Preparação → Brainstorm → Spec+Plano → Aprovação → Implementação → Gates → Review (LUA) → Commit+Handoff → Deploy. Roles SOL/TERRA/LUA.
- **Fonte de candidatos:** `ROADMAP.md` (fases P0–P7) e `docs/PLAN-evolution.md`.
- **Planos/specs:** `docs/superpowers/plans/` e `docs/superpowers/specs/`. Handoffs em `work/handoffs/`.
- **Agente:** `docs/agents/` e `AGENTS.md`. Issues em GitHub (`ready-for-agent`).

## Gates mínimos

`npm run lint && npm test && npm run build` — sem erros, antes de integrar.

## Conservação e pausas

- Preservar alterações locais não relacionadas; nunca incluí-las no commit do ciclo.
- Pausar (pedir ao usuário) somente para: risco destrutivo, custo externo, credencial ausente, mudança de escopo ou decisão de negócio sem resposta segura. Decisões reversíveis e dentro do escopo: seguir sozinho.

## Deploy

Branch `main` publica no GitHub Pages (`.github/workflows/nextjs.yml`). Secrets: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` (nunca `service_role`). Migrations aplicadas e validadas no Supabase **antes** de publicar o frontend.
