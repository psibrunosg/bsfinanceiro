# Hubs Gastos e Ganhos — Referência Funcional e Auditoria

> **Propósito.** Documentar, funcionalidade por funcionalidade, o que as páginas
> `/gastos` e `/ganhos` fazem hoje, **por que foram pensadas assim**, e onde o
> comportamento atual diverge da intenção. Serve como base para editar o projeto
> sem reabrir a investigação.
>
> **Data da auditoria:** 2026-08-08 · **Commit base:** `67bf3cc`
> **Fontes:** [src/app/gastos/page.tsx](../src/app/gastos/page.tsx),
> [src/app/ganhos/page.tsx](../src/app/ganhos/page.tsx),
> [src/app/components/useFinance.ts](../src/app/components/useFinance.ts),
> e consultas diretas ao projeto Supabase `wgntlhzjyriwhncumjsv`.

---

## 0. Como esta auditoria foi feita

| Etapa | Método | Resultado |
|---|---|---|
| Design publicado | Navegador interno, **sessão autenticada** no workspace "Minhas finanças", tema escuro, viewport 1280×860 | Percorrido: `/gastos` (3 abas + filtro de contexto) e `/ganhos` (4 abas). Achados em §9. |
| Design base | Snapshots Playwright versionados (`e2e/visual.e2e.ts-snapshots/`) | 6 snapshots, todos de `/entrar`. Nenhuma cobertura visual de `/gastos` ou `/ganhos`. |
| Persistência | SQL direto no Supabase, comparado com as queries das páginas | 4 divergências confirmadas (§3) |
| Complexidade | `ponytail-audit` sobre a árvore inteira | ~450 linhas removíveis (§6) |
| Gates | `npm run lint && npm test` | lint: 2 warnings · **test: 1 falha** (§6.1) |

---

## 1. Modelo de dados que os dois hubs compartilham

```
workspaces ──┬── accounts        (11 linhas)  contas de caixa/banco
             ├── categories      (25)         kind: 'expense' | 'income'
             ├── financial_contexts (4)       kind: 'pessoal' | 'clinica'
             ├── transactions   (155)         ← livro-razão único
             ├── fixed_commitments (2)  ──── fixed_commitment_occurrences (13)
             ├── patients        (13)  ──── patient_earnings (4)
             └── payslips        (31)
```

**Decisão central do projeto:** `transactions` é a **única fonte de verdade de
dinheiro**. Tudo o mais (contracheque, atendimento de paciente, ocorrência de
compromisso fixo) é um *documento de origem* que, ao ser liquidado, **gera** uma
linha em `transactions` via RPC atômica. É por isso que `payslips.transaction_id`
e `patient_earnings.transaction_id` existem.

Consequência prática: **`/gastos` e `/ganhos` são duas janelas sobre a mesma
tabela**, separadas por `type`. Qualquer regra de exibição que uma página aplique
e a outra não gera divergência de totais — e é exatamente onde estão os bugs de §3.

### RPCs envolvidas

| RPC | Chamada por | O que faz |
|---|---|---|
| `materialize_fixed_commitment_occurrences(workspace, month)` | `/gastos` (carga) | Cria/retorna as ocorrências do mês a partir dos compromissos ativos. Idempotente. |
| `pay_fixed_commitment_occurrence(occurrence, account, paid_on, idem_key)` | `/gastos` → Pagar | Marca ocorrência como `paid` **e** insere a `transaction` de despesa. |
| `receive_patient_earning(earning, account, received_date)` | `/ganhos` → Receber | Marca `patient_earnings.status = 'received'` **e** insere a `transaction` de receita. |
| `register_payslip(...)` | `/ganhos` → Contracheque | Insere `payslips` **e**, se houver `received_date` + conta, a `transaction` de receita. |

> **Regra de edição:** nunca inserir em `transactions` em paralelo a esses fluxos.
> Se um novo documento de origem for criado, ele ganha uma RPC própria — não um
> `insert` no cliente.

---

## 2. `/gastos` — funcionalidade por funcionalidade

Arquivo: [src/app/gastos/page.tsx](../src/app/gastos/page.tsx) (433 linhas, client component)

### 2.1 Carregamento

```ts
useFinance("dashboard")          // workspace, accounts, categories, defaultCashAccountId
loadHub()                        // 4 queries próprias em Promise.all
```

**Como foi pensada:** o hub precisa de contas e categorias para os selects e de
dados próprios que o `useFinance` não conhece. A solução foi compor: hook global
para o básico + `loadHub()` local para o específico.

**O que deu errado:** `defaultCashAccountId` só é preenchido pelo `useFinance`
quando `route === "dashboard" | "settings"`. Para obter esse único campo, a
página se declara "dashboard" e passa a pagar pela carga inteira do painel —
paginação de **todas** as transações pagas, todas as planejadas da janela de
decisão, metas, preferências de alerta e uma RPC de materialização por mês.
Nada disso é usado aqui. Ver §6, item 1.

### 2.2 Abas

| Aba | Estado inicial | Conteúdo |
|---|---|---|
| Visão geral | padrão | 2 cartões de métrica + rosca por categoria + barras 6 meses |
| Lançamentos | — | lista plana de despesas |
| Recorrentes | via `?tab=recorrentes` | compromissos fixos + ocorrências do mês |

A aba inicial é lida de `window.location.search` **dentro do inicializador de
`useState`**, deliberadamente, para evitar `useSearchParams` — que exigiria um
`<Suspense>` e quebraria a exportação estática do GitHub Pages. O comentário no
código registra isso; **manter**.

### 2.3 Filtro de contexto (Pessoal / Clínica)

**Intenção:** separar finanças pessoais das da clínica.

**Implementação atual** (`gastos:116-125`): carrega os contextos ativos, guarda o
`id` do de `kind = 'pessoal'`, e classifica cada transação como pessoal se
`context_id` for `null` **ou** igual a esse id; qualquer outro valor vira "clínica".

**Estado real dos dados:** 119 transações com `context_id = NULL`, 35 no contexto
pessoal, 0 no contexto clínica. E o formulário de registro de gasto **sempre**
grava `context_id: defaultContextId` (pessoal), sem campo na UI.

> **Portanto o filtro "Clínica" nunca terá resultado**, e nunca terá, porque não
> existe caminho na interface para criar uma despesa de clínica. O filtro é uma
> promessa vazia. Decisão a tomar: adicionar o seletor de contexto ao formulário,
> ou remover o filtro. Ver §5.1.

**Verificado ao vivo (sessão autenticada):** selecionar "Clínica" no filtro
produz *"Nenhum gasto registrado. Registrar primeiro gasto"* — enquanto existem
**33 lançamentos de clínica** no workspace ("Aluguel Clínica (Parcela 1..24/24)",
"Energia Elétrica - Clínica"), todos com `context_id = NULL` e portanto exibidos
sob "Pessoal".

O filtro não está apenas vazio: ele **classifica errado**. Custos de clínica
aparecem como pessoais, e o estado vazio ainda convida a "Registrar primeiro
gasto" — que criaria mais uma despesa pessoal, aprofundando o erro.

### 2.4 Métricas da Visão geral

| Cartão | Fórmula | Observação |
|---|---|---|
| Gasto no mês | soma de `filteredExpenses` com `competence_date` no mês corrente | **Não filtra por `status`.** Ver abaixo. |
| Compromissos fixos/mês | soma de `fixed_commitments.amount` ativos | Valor contratado, não realizado. Não considera se a ocorrência foi paga. |

#### O cartão "Gasto no mês" está mostrando um número falso — hoje, na tela

Verificado na sessão autenticada, workspace "Minhas finanças", 2026-08-08:

| | |
|---|---|
| Exibido no cartão vermelho "Gasto no mês" | **R$ 1.529,45** |
| Efetivamente pago no mês (`status = 'paid'`) | **R$ 0,00** |
| Composição real | "Aluguel Clínica (Parcela 12/24)" R$ 958,72 + "Dívida Mercado Pago (CCB 1457515471 - Parc 1/10)" R$ 570,73 — ambos `status = 'pending'` |

**100% do valor exibido são parcelas futuras**, semeadas mês a mês até 2027 (24
parcelas de aluguel + 10 da dívida). Nada foi gasto neste mês, e a tela afirma
que R$ 1.529,45 saíram.

O efeito se propaga para o Painel, que consome a mesma base e exibe
*"Saídas R$ 1.529,45"*, *"⚠️ Suas despesas representam 482% das receitas deste
mês"* e *"📈 Seus gastos aumentaram 1206% em relação ao mês anterior"* — três
alertas construídos sobre dinheiro que não saiu.

> Note também a incoerência interna: o Painel mostra *"Registre despesas para ver
> categorias"* (usa só `paid`) enquanto `/gastos` desenha uma rosca de categorias
> para o mesmo mês (usa todos os status). Duas telas, dois números, mesma pergunta.

**Correção:** filtrar por `status = 'paid'` no total realizado, e separar
"Previsto" num segundo cartão. O `status` já vem na query — só falta usá-lo.

### 2.5 Gráficos

- **Por categoria (mês)** — rosca, só categorias com valor > 0, ordenadas desc.
  Oculta o card inteiro quando não há dados (`byCategory.length > 0`).
- **Evolução mensal** — barras dos últimos 6 meses, rótulo `Intl.DateTimeFormat("pt-BR", { month: "short" })`.
  Usa `filteredExpenses`, que está limitado a 500 linhas — a partir desse volume
  os meses mais antigos passam a ficar truncados silenciosamente.

### 2.6 Registrar gasto

| Campo | Tipo | Obrigatório | Destino |
|---|---|---|---|
| Descrição | texto, máx 160 | sim | `description` |
| Valor | texto livre `0,00` | sim | `parseMoney()` → `amount` |
| Conta | select | sim | `account_id` |
| Categoria | select | não | `category_id` |
| Data | `type="date"` | sim | `competence_date` **e** `paid_at` |

Fixos no código: `type: 'expense'`, `status: 'paid'`, `context_id: defaultContextId`,
`idempotency_key: crypto.randomUUID()`.

**Como foi pensada:** cadastro de uma tela só, sem etapas, para que registrar um
gasto no celular custe segundos. `status: 'paid'` presume que se você está
digitando, já pagou.

**Limitações:** não há como lançar uma despesa futura pela UI (só `paid`), não há
seleção de contexto, não há máscara de moeda, e **não há edição nem exclusão** —
um valor digitado errado só se corrige no banco.

### 2.7 Recorrentes

Compromissos fixos listados por `due_day`. As ocorrências do mês vêm da RPC de
materialização; cada ocorrência `planned` ganha um `<form>` inline com select de
conta e botão Pagar, que chama `pay_fixed_commitment_occurrence`.

Bem desenhado: o pagamento é atômico no banco e a chave de idempotência impede
duplicidade em clique duplo. Sem edição/desativação de compromisso pela UI.

---

## 3. `/gastos` — o que **não** está sendo mostrado

A query de despesas exclui, por texto de descrição:

```ts
.not("description", "ilike", "Pagamento de fatura%")
.not("description", "ilike", "Fatura %")
```

**Intenção documentada no código:** evitar contagem dupla entre o pagamento da
fatura e as parcelas do cartão.

**Realidade no banco:**

| | |
|---|---|
| Transações `expense` correspondentes ao filtro | **15** |
| Soma oculta | **R$ 9.679,43** (18,3% do total de despesas) |
| Linhas em `credit_card_installments` | **0** |

Não existe nenhuma parcela de cartão no sistema. O filtro protege contra uma
dupla contagem que **não pode ocorrer**, e o efeito líquido é esconder R$ 9,7 mil
de gastos reais do total, dos gráficos e da lista de lançamentos — sem qualquer
indicação de que algo foi omitido.

**Ainda que houvesse parcelas**, filtrar por `ilike` em texto livre é frágil: um
gasto legítimo chamado "Fatura do restaurante" desapareceria da página.

> **Correção recomendada:** trocar o filtro textual por um critério estrutural.
> Ou marcar a transação de pagamento de fatura com uma coluna
> (`transactions.kind = 'invoice_payment'`), ou excluir por `category_id`
> dedicada. E, enquanto houver exclusão, exibir uma linha
> "R$ X em pagamentos de fatura não exibidos" para que o número nunca minta.

---

## 4. `/ganhos` — funcionalidade por funcionalidade

Arquivo: [src/app/ganhos/page.tsx](../src/app/ganhos/page.tsx) (563 linhas, client component)

### 4.1 Carregamento

Mesmo padrão de `/gastos`: `useFinance("dashboard")` + `loadHub()` com 5 queries
em `Promise.all` (contexto pessoal, pacientes ativos, 50 contracheques,
200 atendimentos, 100 receitas manuais).

A query de "outras receitas" exclui por texto `Contracheque %` e
`Recebimento de paciente%` — as descrições que as RPCs geram. **Aqui a exclusão
está correta**: essas transações já são contadas via `payslips` e
`patient_earnings`, e incluí-las duplicaria. Mas o acoplamento é o mesmo tipo
frágil de §3: a regra de negócio mora numa string literal repetida entre a RPC
(SQL) e a página (TS). Se alguém mudar o texto da RPC, o total dobra silenciosamente.

Hoje o filtro deixa passar exatamente 1 transação ("Movimentação", R$ 10,00).

### 4.2 Abas

| Aba | Conteúdo | Ação do cabeçalho |
|---|---|---|
| Visão geral | cartão "Total recebido" + rosca de composição + lista de fontes | Registrar ganho |
| Contracheques | agrupados por mês de competência, desc | Cadastrar contracheque |
| Pacientes | um bloco por paciente com seus atendimentos | Cadastrar paciente |
| Outras receitas | lista plana | Registrar receita |

O botão do cabeçalho muda conforme a aba — bom padrão, a ação primária segue o
contexto. `/gastos` faz o mesmo.

### 4.3 Total recebido — a fórmula

```ts
payslipTotal  = payslips.filter(p => p.transaction_id).reduce(...net_amount)  // só liquidados ✔
patientTotal  = earnings.reduce(...)                                          // TODOS os status ✘
otherTotal    = otherIncome.reduce(...)                                       // só manuais ✔
totalIncome   = payslipTotal + patientTotal + otherTotal
```

`patientTotal` soma **todos** os atendimentos, incluindo `pending` e `cancelled`,
sob o rótulo "Total recebido".

**Por que o número está certo hoje:** os 4 atendimentos existentes estão todos
com `status = 'received'`. A conferência bate:

| Fonte | Valor |
|---|---|
| Contracheques liquidados (31) | R$ 47.230,90 |
| Atendimentos (4, todos recebidos) | R$ 305,00 |
| Outras receitas (1) | R$ 10,00 |
| **Total da página** | **R$ 47.545,90** |
| `sum(transactions where type='income')` | **R$ 47.545,90** ✔ |

**O bug é latente:** no primeiro atendimento registrado e não recebido, o card
"Total recebido" passa a contar dinheiro que não entrou, e a rosca de composição
infla junto. Correção: `earnings.filter(e => e.status === 'received')` — a
variável `earningsReceived` **já existe na linha 157 e não é usada** (o lint
sinaliza).

### 4.4 Escopo temporal — inconsistência entre os hubs

`/gastos` mostra **o mês corrente**. `/ganhos` mostra **todo o histórico**, sem
filtro de período e sem gráfico de evolução mensal. Os dois hubs, lado a lado, não
são comparáveis: não dá para responder "quanto entrou e quanto saiu neste mês?"
navegando entre eles. Ver §5.2.

### 4.5 Contracheques

Formulário mais rico do app: empregador, competência, bruto, descontos, líquido,
data de recebimento, conta, PDF e observação.

**Decisões acertadas, manter:**
- Upload para bucket **privado** `payslips`, caminho prefixado com `ownerId` para
  que a policy de storage isole por dono.
- Validação de tipo (`application/pdf`) e tamanho (10 MB) **antes** do upload.
- Se a RPC falhar depois do upload, o PDF é removido — sem órfãos no storage.
- Leitura por `createSignedUrl(path, 120)`, nunca URL pública.
- Regra de consistência: `received_date` sem conta é rejeitado no cliente, porque
  a RPC não teria onde creditar a receita.

**Faltas:** bruto − descontos ≠ líquido não é validado (nem no cliente, nem
aparentemente na RPC); não há edição nem exclusão; não há como liquidar depois um
contracheque cadastrado como não recebido — só recadastrando.

### 4.6 Pacientes e atendimentos

Cada paciente vira um bloco com contadores de recebido/pendente e a lista completa
dos seus atendimentos. Botão `+` abre "Registrar atendimento"; atendimento
pendente ganha botão "Receber", que abre o diálogo de conta + data e chama
`receive_patient_earning`.

**Decisão de privacidade, manter e destacar:** o formulário traz o texto
*"Registre apenas os dados financeiros do atendimento, sem informações clínicas"*
e o modelo não tem campo clínico algum. Isso é deliberado — dados de saúde
elevariam muito a exigência regulatória sobre o banco. **Não adicionar campos
clínicos.**

**Limitações:** sem paginação (200 atendimentos carregados de uma vez, todos
renderizados); sem como cancelar um atendimento pela UI, apesar de
`status = 'cancelled'` existir no modelo; sem desativar paciente.

---

## 5. Padrão proposto de cadastro

O que existe hoje já é um padrão implícito — só não está escrito nem é uniforme.
Formalizando:

### 5.1 Anatomia de um cadastro

```
PageHeader(action) ──abre──▶ Dialog(title) ──contém──▶ SimpleForm(onSubmit)
                                                          └─ <label htmlFor> + <input/select>
                                                          └─ <button> ação primária
```

- **`SimpleForm`** já entrega: `preventDefault`, estado `pending`, `fieldset
  disabled` durante o envio, `aria-busy`, `role="status"` no "Salvando…" e
  `role="alert"` no erro. **É o contrato — todo cadastro passa por ele.**
- **`Dialog`** usa `<dialog>` nativo com `showModal()`, o que dá foco preso, Esc e
  backdrop de graça. Nada de modal customizado.
- **Mensagem de resultado** hoje é uma string no estado da página, com o hack
  `message.startsWith("Não")` para decidir se é erro. Frágil e não localizável.

### 5.2 Regras a adotar (checklist para qualquer cadastro novo ou editado)

| # | Regra | Situação hoje |
|---|---|---|
| 1 | Toda escrita passa por `SimpleForm` | ✔ cumprido |
| 2 | Valor monetário usa um único componente `<MoneyInput>` com máscara e validação | ✘ hoje é `<input placeholder="0,00">` cru + `parseMoney()` |
| 3 | Resultado é `{ ok: boolean, text: string }`, não `startsWith("Não")` | ✘ |
| 4 | Erro exibe o motivo do Postgres quando for de validação (constraint), não "Não foi possível" genérico | ✘ |
| 5 | Toda entidade listada tem editar e excluir | ✘ **nenhuma tem** |
| 6 | Escritas em `transactions` derivadas de documento passam por RPC | ✔ cumprido |
| 7 | Inserts diretos carregam `idempotency_key` | ✔ cumprido em gasto e receita |
| 8 | Datas gravadas como `YYYY-MM-DD`, exibidas com `T12:00:00` para não deslocar fuso | ✔ cumprido consistentemente |
| 9 | Campos de contexto (`pessoal`/`clinica`) explícitos quando a entidade tem contexto | ✘ sempre implícito = pessoal |
| 10 | Todo hub oferece o mesmo recorte de período | ✘ gastos = mês, ganhos = tudo |

### 5.3 `parseMoney` — risco a corrigir junto com a regra 2

```ts
parseMoney("1.234,56")  // → 1234.56  ✔
parseMoney("1234.56")   // → 123456   ✘ dez mil vezes maior
parseMoney("abc")       // → NaN      ✘ vai para o insert
```

Remove todos os pontos e troca vírgula por ponto. Quem digitar no formato inglês
— ou colar de uma planilha — grava um valor cem ou mil vezes maior sem nenhum
aviso. Um `<MoneyInput>` com máscara resolve entrada e validação de uma vez.

---

## 6. Infraestrutura — o que muda o custo de manutenção

### 6.1 Gates vermelhos agora

```
npm run lint  → 2 warnings (AccountsPage:16 transactions, ganhos:157 earningsReceived)
npm test      → 1 falha: useFinance.test.tsx:393
                "keeps a small recent query on lightweight routes" — esperado 30, recebido 1
```

O `CLAUDE.md` exige `lint && test && build` verdes antes de integrar. **Hoje `main`
não passa no próprio gate.** Resolver antes de qualquer mudança nos hubs, senão
não há linha de base.

### 6.2 Sobrecarga do `useFinance`

`useFinance` tem 530 linhas e um `switch` por string de rota que decide o que
carregar. `/gastos`, `/ganhos` e `/investimentos` mentem a rota (`"dashboard"`)
só para receber `defaultCashAccountId`, e pagam por:

- paginação de **todas** as transações pagas do workspace, em lotes de 500;
- todas as despesas planejadas da janela de decisão;
- metas ativas, `alert_preferences`, `workspace_preferences`;
- uma RPC `materialize_fixed_commitment_occurrences` **por mês** da janela;
- cartões e faturas.

E então cada hub roda ainda 4–5 queries próprias. São ~10 round-trips por
carregamento de página para exibir dois números.

**Correção:** extrair `useWorkspaceBasics()` — workspace, contas, categorias,
`defaultCashAccountId` — e usar nos três hubs. `useFinance` fica só no dashboard e
nas rotas que realmente precisam do modelo completo.

### 6.3 CSS

13 arquivos `.css` importados **todos** em `layout.tsx`, nove deles com menos de
2,6 KB. O split por página não entrega nada: toda página baixa todo o CSS.
`globals.css` está minificado numa linha única de ~4 KB, o que torna qualquer
edição um exercício de paciência.

Além disso, não existem tokens de espaçamento — daí as **37 ocorrências de
`style={{ }}` inline** nos três hubs, cada uma repetindo `display:flex;
justifyContent:space-between; gap:12`. Um par de classes utilitárias
(`.row-between`, `.stack`) elimina quase todas.

### 6.4 `design-system/bs-financeiro/MASTER.md` está obsoleto

O documento descreve um app que não existe:

| MASTER.md diz | Implementação real |
|---|---|
| Primária `#1E40AF` (azul) | `--primary: #123f37` (verde) |
| Fundo `#0F172A` (escuro fixo) | `--bg: #f4f7f5` claro + tema escuro por `data-theme` |
| Tokens `--color-*`, `--space-*`, `--shadow-*` | `--bg`, `--surface`, `--accent`; **nenhum token de espaço ou sombra escalonado** |
| Motion com GSAP | GSAP não é dependência do projeto |

Um design system que contradiz o código é pior que nenhum: quem seguir o
documento produz UI fora do padrão. **Reescrever a partir do `globals.css` real,
ou remover o arquivo.** As seções de anti-padrões e o checklist de entrega (linhas
198-229) são bons e valem preservar — e, pelo que dá para verificar no código, já
são cumpridos: ícones Lucide (sem emoji), `cursor:pointer`, `:focus-visible` com
outline de 3px, `prefers-reduced-motion` respeitado.

### 6.5 Cobertura visual

Os 6 snapshots Playwright cobrem apenas `/entrar`. Nenhuma regressão visual em
`/gastos` ou `/ganhos` seria detectada. Como as rotas exigem sessão, cobri-las
exige um usuário de teste semeado — decisão pendente (§7).

---

## 7. Cobertura visual automatizada

A auditoria manual desta rodada foi feita com sessão aberta pelo usuário (§9),
mas isso não é repetível em CI. Os 6 snapshots Playwright existentes cobrem
apenas `/entrar`; nenhuma regressão em `/gastos` ou `/ganhos` seria detectada.

Para fechar: **usuário de teste semeado** no Supabase (credenciais em `.env.local`
como `E2E_EMAIL`/`E2E_PASSWORD`) + `storageState` do Playwright. Destrava
snapshots visuais dos hubs e e2e dos fluxos de cadastro — e evita depender de
alguém logar à mão a cada auditoria.

---

## 8. Backlog priorizado

> **Estado em 2026-08-08, commit `1ad4fd3` (publicado).** Concluídos: 1, 2, 3, 4,
> 5, 10, 12, 14, 15, 17, 18. Em aberto: 6, 7, 8, 9, 11, 13, 16, 19, 20 — sendo 9
> e 20 decisões suas, não trabalho de implementação.

| # | Item | Tipo | Esforço | Modelo sugerido |
|---|---|---|---|---|
| 1 | Consertar `useFinance.test.tsx` e os 2 warnings de lint | correção | P | Haiku |
| 2 | `earningsReceived` no `patientTotal` (§4.3) | **bug** | P | Haiku |
| 3 | Remover o filtro `ilike "Fatura %"` de `/gastos` ou torná-lo estrutural (§3) | **bug, R$ 9,7 mil ocultos** | M | Sonnet |
| 4 | Distinguir `paid` de `planned` na lista e no total de `/gastos` (§2.4) | **bug** | M | Sonnet |
| 5 | `<MoneyInput>` com máscara + `parseMoney` seguro (§5.3) | risco de dado | M | Sonnet |
| 6 | Editar/excluir em todas as listas dos dois hubs (§5.2 regra 5) | funcionalidade | G | Sonnet |
| 7 | `useWorkspaceBasics()` e desmontagem do `useFinance` (§6.2) | infra | M | Sonnet |
| 8 | Filtro de período unificado nos dois hubs (§4.4) | funcionalidade | M | Sonnet |
| 9 | Decidir contexto Pessoal/Clínica: expor no formulário ou remover o filtro (§2.3) | **decisão de produto** | M | — |
| 10 | Reescrever ou remover `MASTER.md` (§6.4) | infra | P | Haiku |
| 11 | Consolidar os 13 CSS + tokens de espaçamento (§6.3) | infra | M | Sonnet |
| 12 | Remover código morto: `investments.ts`, `context.ts`, `EmptyState`, `Dialog.variant`, `graphify-out/` | limpeza | P | Haiku |
| 13 | Usuário de teste + snapshots visuais dos hubs (§7) | teste | M | Sonnet |
| 14 | `.dashboard-card{min-width:0}` — mata o scroll horizontal de `/gastos` (§9.1) | **bug visual** | P | Haiku |
| 15 | Cores do Chart.js lidas de `--muted` em vez de `#60716c` fixo (§9.2) | **a11y, 3,23:1** | P | Haiku |
| 16 | Ordenar Lançamentos por proximidade de hoje + chip de status (§9.4) | UX | M | Sonnet |
| 17 | Manter Nav/PageHeader durante o carregamento, skeleton só no conteúdo (§9.3) | UX | P | Haiku |
| 18 | Filtrar fatias de valor zero na rosca de `/ganhos` (§9.5) | polimento | P | Haiku |
| 19 | Pacientes: ordenar por atividade, recolher inativos, permitir desativar (§9.6) | UX | M | Sonnet |
| 20 | Decidir o destino do campo livre `notes` do atendimento (§9.6) | **decisão de privacidade** | P | — |

Itens 1–4 são pré-requisito de qualquer conversa sobre os números: enquanto eles
existirem, a tela mostra valores que não correspondem ao banco.

---

## 9. Auditoria visual — sessão autenticada

Workspace "Minhas finanças", tema escuro, viewport 1280×860, 2026-08-08.

### 9.1 Overflow horizontal em `/gastos`

```
document.documentElement.scrollWidth  1366
                        clientWidth   1280      → 86px de scroll horizontal
culpado: article.dashboard-card "Evolução mensal", right = 1365
```

**Causa:** `.dashboard-columns{grid-template-columns:1.35fr .65fr}`
([dashboard-extra.css](../src/app/dashboard-extra.css)). Itens de grid têm
`min-width:auto` por padrão; o Chart.js fixa a largura do `<canvas>` em pixels
após medir o pai, e a trilha `.65fr` não consegue encolher abaixo dessa largura
intrínseca. O canvas empurra a coluna para fora da viewport.

**Correção:** `.dashboard-card{min-width:0}`. Uma linha.

`/ganhos` **não** apresenta o problema (`scrollWidth == 1280`) porque suas duas
colunas são rosca + lista de texto — só o gráfico de barras dispara o efeito.

Isso viola o próprio checklist do design system: *"No horizontal scroll on mobile"*
e *"No content hidden behind fixed navbars"* ([MASTER.md:227-228](../design-system/bs-financeiro/MASTER.md)).

### 9.2 Contraste dos rótulos de gráfico no tema escuro

[DashboardChart.tsx](../src/app/components/DashboardChart.tsx) fixa a cor dos
ticks e da legenda em `#60716c` — que é o `--muted` do tema **claro**, escrito
direto no código, sem ler a variável CSS.

| | |
|---|---|
| Texto | `#60716c` |
| Fundo (`--surface` escuro) | `#14211e` |
| Contraste | **3,23:1** |
| Exigido (WCAG AA, texto) | 4,5:1 |

Os rótulos dos eixos e as legendas da rosca ficam quase ilegíveis no escuro — dá
para ver nos prints. Viola o item *"Low contrast text — maintain 4.5:1"* do
próprio checklist.

**Correção:** ler `getComputedStyle(document.documentElement).getPropertyValue('--muted')`
no efeito, e recriar o gráfico quando `data-theme` mudar.

### 9.3 Estado de carregamento apaga a interface

```tsx
if (loading || !workspace || hubLoading)
  return <main className="management-page"><p className="muted">Carregando...</p></main>;
```

Os dois hubs devolvem **só** esse parágrafo — sem `<Nav>`, sem `PageHeader`. Ao
entrar em `/gastos`, a tela fica preta com "Carregando..." no canto superior
esquerdo, a navegação lateral some e volta. Como o `useFinance("dashboard")` faz
~10 round-trips antes de liberar (§6.2), a piscada é longa.

**Correção:** renderizar `<Nav>` e `<PageHeader>` sempre, e trocar só a região de
conteúdo por skeletons. Some com a piscada e reduz o CLS.

### 9.4 A lista de Lançamentos abre em agosto de **2027**

Ordenada por `competence_date DESC` sem recorte, a primeira linha da aba
Lançamentos é *"Aluguel Clínica (Parcela 24/24) · 08/08/2027 · Aluguel"*. Os
gastos reais e recentes começam ~24 linhas abaixo, depois de toda a esteira de
parcelas futuras.

Nada distingue visualmente uma parcela `pending` de 2027 de uma despesa paga
ontem: mesma tipografia, mesma cor, mesmo peso. É o bug de §2.4 na sua forma mais
visível.

**Correção:** ordenar por proximidade da data de hoje (ou filtrar para o período
selecionado), e marcar `pending`/`paid` com um chip.

### 9.5 `/ganhos` — desequilíbrio da Visão geral

- **Um único cartão de métrica** ocupando a faixa inteira, contra dois em
  `/gastos`. A `hub-overview` fica com um bloco largo e vazio à direita do valor.
- A rosca "Composição dos ganhos" recebe uma fatia de **valor zero**
  ("Outras receitas R$ 0,00"), que vira entrada de legenda sem representação
  gráfica. Filtrar `value > 0` antes de montar o dataset — `/gastos` já faz isso
  em `byCategory`.
- **O confronto temporal fica gritante em uso real:** `/ganhos` exibe
  "Total recebido **R$ 47.535,90**" (histórico inteiro) e `/gastos` exibe
  "Gasto no mês **R$ 1.529,45**". Alternando entre as abas do menu, a leitura
  imediata é "ganhei 47 mil e gastei 1,5 mil" — e nenhum dos dois números é o que
  parece. É o item §4.4, e é o problema de UX mais caro dos dois hubs.

### 9.6 `/ganhos` — aba Pacientes

**9 dos 13 pacientes** aparecem como *"0 recebido(s) · R$ 0,00 · 0 pendente(s) ·
R$ 0,00"*. A lista é majoritariamente ruído: sem ordenação por atividade, sem
agrupar inativos, e sem caminho na UI para desativar um paciente — apesar de
`patients.active` existir no modelo.

**Ponto de privacidade a decidir:** o campo livre `notes` do atendimento já está
sendo usado para conteúdo de sessão — um registro traz *"3x Sessões pagas + 2 que
ele não veio"*. O formulário pede explicitamente "sem informações clínicas"
(§4.6), mas um `<input>` livre não sustenta essa regra. Ou o rótulo fica mais
firme ("apenas referência de cobrança"), ou o campo vira estruturado
(nº de sessões, faltas) e sai do texto livre.

### 9.7 O que está bem resolvido

Registrar em contraponto, para não se perder numa refatoração:

- **Contracheques** é o melhor fluxo do app. Agrupamento por mês com cabeçalho em
  português, empregador em destaque, competência + data de recebimento em linha
  secundária, líquido em negrito com bruto/descontos abaixo. Os 31 registros
  conferem: `gross - discounts = net` em **todos**, zero divergências, zero sem
  transação vinculada.
- **Navegação lateral** com item ativo destacado, atalhos de Tema e Sair no rodapé
  da barra — estrutura clara e estável.
- **Ícones Lucide** em todo lugar, nenhum emoji como ícone na interface (os emojis
  aparecem só no texto dos insights do Painel).
- **`:focus-visible`** com outline de 3px e `prefers-reduced-motion` respeitado no
  `globals.css`.
- **Nenhum erro de console** durante toda a navegação autenticada.
- **Formulário de contracheque** com PDF em bucket privado, URL assinada de 120s e
  rollback do upload em caso de falha da RPC (§4.5).
