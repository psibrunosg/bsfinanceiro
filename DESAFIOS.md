# DESAFIOS

Pontos de fricção recorrentes neste projeto. Ler ao iniciar uma sessão nova.

## Auditar telas autenticadas do site publicado

`/gastos`, `/ganhos` e as demais rotas de `psibrunosg.github.io/bsfinanceiro`
redirecionam para `/entrar` sem sessão, e o agente **não pode inserir credenciais**.
Fluxo que funciona: **pedir ao usuário para logar no navegador interno** — a
sessão persiste e todas as rotas ficam navegáveis a partir dali.

**Como destravar sem depender disso:** usuário de teste no Supabase +
`storageState` do Playwright (`E2E_EMAIL` / `E2E_PASSWORD` em `.env.local`).
Rastreado como item 13 em `docs/hubs-gastos-ganhos.md`.

## Quirks do navegador interno (confirmados nesta sessão)

- **`navigate` funciona com a rota completa.** O retorno da ferramenta e o campo
  `URL` do `get_page_text` mostram só a origem (`https://psibrunosg.github.io`),
  mas `location.pathname` confirma que a rota profunda carregou. Não confiar na
  URL reportada — checar via `javascript_tool`.
- **Cliques por `ref` erram o alvo.** O mapeamento ref→coordenada está deslocado
  neste app. Clicar por `coordinate` lida do screenshot funciona.
- **O canvas do screenshot não está na escala do viewport** (viewport 1280×860 sai
  como 800×537 cobrindo uma área maior). Não julgar proporções por print —
  medir com `getBoundingClientRect()` via `javascript_tool`.
- **`get_page_text` devolve conteúdo obsoleto** logo após uma troca de aba ou
  navegação. Ler `document.querySelector('main').innerText` via `javascript_tool`.
- **`computer{action:"zoom"}` com `region` não é suportado** — devolve o print
  inteiro.

## `npm test` vermelho na `main`

Em 2026-08-08, `useFinance.test.tsx:393` falhava na `main` (esperado 30, recebido 1)
com 2 warnings de lint. O `CLAUDE.md` exige os gates verdes antes de integrar —
**rodar `npm run lint && npm test` no início da sessão** para saber se a falha é
sua ou herdada, antes de investigar.

## `useFinance` mente a rota

`/gastos`, `/ganhos` e `/investimentos` chamam `useFinance("dashboard")` só para
receber `defaultCashAccountId`, que o hook só preenche nas rotas `dashboard` e
`settings`. Ao ler qualquer um desses hubs, não presuma que a página é um
dashboard — é um workaround, e ele carrega o painel inteiro sem necessidade.

## `design-system/bs-financeiro/MASTER.md` não descreve o app

Paleta azul/escura, tokens `--color-*`/`--space-*` e GSAP — nada disso existe no
código, que usa verde, `--bg`/`--surface`/`--accent` e nenhum token de espaçamento.
**Não usar como fonte para UI nova.** A fonte real é `src/app/globals.css`.

## Regras de negócio escondidas em `ilike` de descrição

`/gastos` e `/ganhos` excluem transações por texto (`"Fatura %"`,
`"Contracheque %"`, `"Recebimento de paciente%"`) para evitar dupla contagem. As
strings estão duplicadas entre as RPCs SQL e o TSX. Ao mexer no texto de descrição
gerado por qualquer RPC, procurar o `ilike` correspondente no cliente — senão os
totais dobram ou somem em silêncio.
