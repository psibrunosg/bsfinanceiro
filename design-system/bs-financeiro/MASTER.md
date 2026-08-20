# Design System Master File

> **FONTE DA VERDADE:** `src/app/globals.css`.
> Este documento é uma leitura do CSS que existe hoje. Se o CSS e este arquivo
> divergirem, **o CSS vence** e este arquivo deve ser corrigido — nunca o contrário.
> Todo valor abaixo (hex, px, breakpoint, nome de classe) foi lido de um arquivo
> do repositório; a referência `arquivo:linha` está ao lado.

---

**Projeto:** BS Financeiro
**Atualizado:** 2026-08-20
**Tema:** único, dark roxo (não há alternância)

---

## Tema

O app tem **um tema só**. O `<html>` é escrito com `data-theme="dark"` fixo em
`src/app/layout.tsx:32`; não existe `ThemeProvider`, `useThemePreference` nem
alternador na UI — foram deletados. Os temas claro / cyberpunk / corporate /
neumorphism também não existem mais: viviam em `themes.css` e `dark-override.css`,
e o override aplicava `!important` no `:root`, então nenhum deles chegava a valer.
`app.css`, `themes.css`, `dark-override.css`, `dashboard-extra.css` e
`projection.css` foram dobrados em `globals.css` e removidos.

A coluna `profiles.theme_preference` continua no banco
(`supabase/migrations/20260730000000_profile_theme_preference.sql`), **sem uso
algum no frontend**. Não escreva código novo contra ela.

Consequência prática: `:root` é a única declaração de tokens. Não existe bloco
`:root[data-theme="dark"]` — testar "nos dois temas" deixou de fazer sentido.

---

## Tokens (`src/app/globals.css:12` e `:15`)

### Cor, elevação e layout — `globals.css:12`

| Token | Valor | Uso |
|-------|-------|-----|
| `color-scheme` | `dark` | Widgets nativos (scrollbar, `input[type=month]`) em dark |
| `--bg` | `#0B0E14` | Fundo da aplicação |
| `--surface` | `#11151F` | Sidebar, campos, toast, `.filter-card`, `.month-picker` |
| `--surface-2` | `rgba(255,255,255,.03)` | Vidro dos cards, hover de linha, badges neutros |
| `--text` | `#F8FAFC` | Texto principal |
| `--muted` | `#94A3B8` | Texto secundário, rótulos, ícones inativos |
| `--border` | `rgba(255,255,255,.08)` | Bordas e divisores |
| `--primary` | `#8B5CF6` | Marca; item de nav ativo; botão primário |
| `--primary-2` | `#7C3AED` | Segunda parada do gradiente da marca |
| `--accent` | `#8B5CF6` | Ação de destaque (mesmo hex de `--primary`) |
| `--accent-contrast` | `#fff` | Texto/ícone sobre `--accent` |
| `--positive` | `#22C55E` | Receita, sucesso, tendência de alta |
| `--warning` | `#F59E0B` | Alerta |
| `--danger` | `#EF4444` | Erro, despesa, tendência de queda |
| `--gold` | `#F5A623` | Série secundária de gráfico, investimento |
| `--focus` | `#3B82F6` | Anel de foco visível |
| `--shadow` | `0 8px 32px rgb(0 0 0 / .3)` | Elevação de card, toast, dialog |
| `--radius` | `24px` | Raio de card (`.dashboard-card`, `.metric-card`, `.install-prompt`) |
| `--sidebar` | `264px` | Largura da sidebar; vira `84px` quando recolhida |

`--sidebar` é reescrito em runtime, não no CSS: um script inline no `<head>`
(`layout.tsx:32`) lê `localStorage['bsf-nav-collapsed']` antes da hidratação e
seta `84px` ou `264px`; o `Nav` repete isso ao alternar
(`src/app/components/Nav.tsx:23-24,34,41`). Por isso o offset da sidebar é
`var(--sidebar)` em todo lugar — nunca um número.

### Aliases e espaçamento — `globals.css:15`

Vários componentes foram escritos contra nomes `--*-color` que nunca existiram.
`var()` resolve preguiçosamente, então os aliases apontam para os tokens acima:

| Alias | Aponta para |
|-------|-------------|
| `--border-color` | `var(--border)` |
| `--primary-color` | `var(--primary)` |
| `--danger-color` | `var(--danger)` |
| `--positive-color` | `var(--positive)` |
| `--text-color` | `var(--text)` |
| `--accent-color` | `var(--accent)` |
| `--muted-color` | `var(--muted)` |

| Espaço | Valor |
|--------|-------|
| `--space-xs` | `4px` |
| `--space-sm` | `8px` |
| `--space-md` | `16px` |
| `--space-lg` | `24px` |
| `--space-xl` | `32px` |

Não existem `--space-1..6`, `--radius-md`, `--radius-sm`, `--tint` nem
`--row-hover`. Eram do sistema antigo.

---

## Tipografia

Fontes vêm de `next/font/google` (`layout.tsx:2,17-18`), **auto-hospedadas no
build**: nenhuma request a terceiro em runtime e nenhum `@import` bloqueante.

| Fonte | Pesos | Variável CSS gerada |
|-------|-------|---------------------|
| `Lexend` | 400, 500, 600, 700 | `--font-lexend` |
| `Source_Sans_3` | 400, 600, 700 | `--font-sans` |

Ambas com `subsets: ["latin"]` e `display: "swap"`. As classes das variáveis são
aplicadas no `<html>` (`layout.tsx:32`).

| Regra | Onde |
|-------|------|
| `body { font: 16px/1.5 var(--font-sans),"Source Sans 3",system-ui,sans-serif }` | `globals.css:18` |
| `h1,h2,h3 { font-family: var(--font-lexend),Lexend,sans-serif; letter-spacing:-.025em }` | `globals.css:18` |
| `h1 { font-size: clamp(1.7rem,2vw,2.25rem); line-height:1.18 }` | `globals.css:18` |
| `h2 { font-size: 1.15rem; margin:0 }` | `globals.css:18` |
| `.dashboard-card h3 { font-size:1rem; font-family: var(--font-lexend) }` | `globals.css:51` |
| `.metric-card strong { 2.25rem / 700 / letter-spacing -.02em }` | `globals.css:53` |
| `.eyebrow { color:var(--accent); .75rem; 700; letter-spacing:.09em }` | `globals.css:18` |
| `.muted { color: var(--muted) }` | `globals.css:18` |

Na prática as páginas sobrescrevem os títulos por `style` inline: `h1` do
`PageHeader` e do Dashboard vira `1.75rem` (`PageHeader.tsx:30`,
`DashboardPage.tsx:168`) e os `h3` de card viram `1.2rem`.

**Dinheiro é sempre `tabular-nums`.** Já aplicado em:

| Seletor | Onde |
|---------|------|
| `.metric-card strong` | `globals.css:53` |
| `.donut-legend__item strong` | `globals.css:72` |
| `.data-table td.num` | `globals.css:111` |
| `.health-row__value` | `reports.css:53` |
| `.transaction-list-row > b` | `transaction.css:350` |

Todo valor exibido passa por `money()` (`src/app/components/Money.tsx:6`).

---

## Classes canônicas

Papel → classe → onde a regra vive.

### Shell e navegação

| Papel | Classe | Regra |
|-------|--------|-------|
| Raiz de página (dá o offset da sidebar) | `.dashboard-shell` | `globals.css:34` + `globals.css:37` |
| Sidebar fixa desktop | `.app-nav` | `globals.css:21` |
| Sidebar recolhida (84px, só ícones) | `.app-nav.collapsed` | `globals.css:21` |
| Linha da marca + botão de recolher | `.nav-brand-row`, `.nav-brand`, `.nav-collapse-toggle` | `globals.css:21` |
| Item de nav ativo | `nav a.active` | `globals.css:21` |
| Barra inferior móvel (≤900px) | `.mobile-nav` | `globals.css:22` |
| Botão central "+" da barra móvel | `.mobile-add` | `globals.css:22` |
| Avatar/menu do usuário no topo | `.user-menu`, `.user-menu__text`, `.user-menu__avatar` | `globals.css:26-31` |
| Skip link | `.skip` | `globals.css:18` |

`.dashboard-shell` é `<main>`, e o `<Nav />` é renderizado **dentro** dele
(`DashboardPage.tsx:157-160`). É usado por 13 páginas.

### Bento grid

| Papel | Classe | Regra |
|-------|--------|-------|
| Grid principal 2 colunas (`1fr 380px`) | `.dashboard-bento-grid` | `globals.css:38` |
| Fila de cards iguais (3 colunas por padrão) | `.bento-row` | `globals.css:39` |
| Coluna larga / coluna estreita | `.bento-main`, `.bento-sidebar` | `globals.css:41` |

`.bento-main` / `.bento-sidebar` carregam `min-width:0` **obrigatório**: sem ele
o canvas do Chart.js estoura a coluna `1fr` (`globals.css:40`).
Contagem de colunas diferente de 3 é feita por `style` inline no `.bento-row`
(ex.: `repeat(4,1fr)` em `DashboardPage.tsx:185`).

### Cards e métricas

| Papel | Classe | Regra |
|-------|--------|-------|
| Card de vidro (glassmorphism) | `.dashboard-card` | `globals.css:50` |
| Card de métrica grande | `.metric-card` | `globals.css:50,52-53` |
| Cabeçalho do card de métrica (rótulo + badge) | `.metric-card__head` | `globals.css:54` |
| Badge de ícone 40px do card | `.metric-icon-badge` | `globals.css:55` |
| Variação percentual | `.metric-card__trend` + `.up` / `.down` | `globals.css:56-58` |
| Faixa lateral verde / vermelha | `.metric-card--positive` / `--negative` | `globals.css:59-60` |

O vidro é `background: var(--surface-2)` + `backdrop-filter: blur(12px)` +
borda `--border` + `--shadow` + `--radius`.

### Gráficos

| Papel | Classe | Regra |
|-------|--------|-------|
| Contêiner do canvas (240px) | `.chart-wrap` | `globals.css:64` |
| Legenda horizontal abaixo do gráfico | `.chart-legend`, `.chart-legend__item`, `.chart-legend__dot` | `globals.css:65-67` |
| Rosca + legenda lado a lado | `.donut-layout` | `globals.css:68-69` |
| Legenda vertical da rosca | `.donut-legend`, `.donut-legend__item` | `globals.css:70-72` |

A legenda nativa do Chart.js costuma ser desligada (`legend={false}`) e trocada
por `.chart-legend` / `.donut-legend` em HTML. A paleta da rosca é a constante
`DONUT_COLORS` (`DashboardPage.tsx:27`):
`#8B5CF6`, `#3B82F6`, `#F97316`, `#F5A623`, `#22C55E`.

### Linhas de lista

| Papel | Classe | Regra |
|-------|--------|-------|
| `<ul>` sem marcador, grid com gap 8px | `.list` | `components.css:72,89` |
| Linha de lista (cartão de vidro) | `.list > li`, `.account-row` | `components.css:78` |
| Linha de transação (badge + texto + valor) | `.tx-row`, `.tx-row__body`, `.tx-row__amount` | `globals.css:90-94` |
| Badge de ícone 38px da transação | `.tx-icon-badge` | `globals.css:89` |
| Linha de meta com barra | `.goal-row`, `.goal-row__top`, `.goal-row__percent`, `.goal-row__bar`, `.goal-row__bar-fill` | `globals.css:80-86` |
| Barra de progresso genérica | `.progress-bar` + `--warning` / `--danger` | `components.css:153-167` |
| Atalho/insight clicável | `.insight-link` | `globals.css:75-77` |

`.account-row` e `.list > li` compartilham exatamente a mesma regra: flex
`space-between`, padding `16px 20px`, borda `--border`, raio `16px`, fundo
`--surface-2`.

### Tabela

| Papel | Classe | Regra |
|-------|--------|-------|
| Tabela de dados | `.data-table` | `globals.css:101-104` |
| Célula com ícone + título + legenda | `.cell-source` | `globals.css:105-107` |
| Pílula de tipo | `.type-pill` | `globals.css:108` |
| Coluna numérica alinhada à direita | `td.num` | `globals.css:111` |
| Valores de desconto / líquido | `.amount-discount`, `.amount-net` | `globals.css:109-110` |
| **Envelope de rolagem horizontal** | `.table-scroll` | `globals.css:112` |

Usada em `src/app/ganhos/page.tsx` e `src/app/gastos/page.tsx`.

### Abas, filtros, período

| Papel | Classe | Regra |
|-------|--------|-------|
| Faixa de abas | `.hub-tabs` (alias `.tabs-nav`) | `components.css:5-40` |
| Linha de filtros | `.hub-filters` | `components.css:43-69` |
| Card "Período" | `.filter-card` | `globals.css:97-98` |
| Navegador de mês | `.month-picker` | `components.css:170-198` |

Aba ativa aceita `.active` **ou** `aria-pressed="true"` (`components.css:32-35`).

### Estado vazio, toast, instalação

| Papel | Classe | Regra |
|-------|--------|-------|
| Estado vazio dentro de card | `.dashboard-empty` | `globals.css:61` |
| Fila de toasts (canto inferior direito) | `.toast-viewport` | `globals.css:117` |
| Toast | `.toast` + `.toast--success` / `.toast--error` | `globals.css:118-122` |
| Banner "instalar app" (PWA) | `.install-prompt`, `.install-prompt__actions`, `.install-prompt__install`, `.install-prompt__dismiss` | `globals.css:123-126` |

Toast e banner sobem para `bottom:88px` em ≤900px para não ficar sob a
`.mobile-nav` (`globals.css:127`).

### Diálogo

| Papel | Classe | Regra |
|-------|--------|-------|
| `<dialog>` modal | `.dialog` | `dialog.css:1` |
| Backdrop borrado | `.dialog::backdrop` | `dialog.css:11` |
| Cabeçalho com título + fechar | `.dialog__header` | `dialog.css:15-40` |
| Corpo | `.dialog__body` | `dialog.css:41` |
| Variante bottom sheet (≤700px) | `.dialog--sheet` | `dialog.css:44-63` |
| Formulário dentro do diálogo | `.simple-form` | `components.css:92-149` |

---

## Breakpoints

Todas as media queries do projeto, na ordem em que as folhas são importadas.

| Consulta | Arquivo | O que faz |
|----------|---------|-----------|
| `max-width:900px` | `globals.css:22` | Esconde `.app-nav`; mostra `.mobile-nav` (5 colunas, `env(safe-area-inset-*)`, `.mobile-add` flutuante de 52px) |
| `prefers-reduced-motion:reduce` | `globals.css:23` | Zera `scroll-behavior`, `animation-duration`, `animation-iteration-count` e `transition-duration` globalmente |
| `min-width:901px` | `globals.css:37` | Offset da sidebar: `.dashboard-shell` ganha `margin-left:var(--sidebar)`, largura `min(1180px, 100% - var(--sidebar))`, padding lateral `clamp(24px,4vw,56px)` e `padding-top:36px` |
| `max-width:1024px` | `globals.css:46` | `.dashboard-bento-grid` vira 1 coluna |
| `max-width:768px` | `globals.css:47` | `.bento-row` vira 1 coluna |
| `max-width:760px` | `globals.css:114` | `.chart-wrap` cai para 210px; cards passam a `padding:18px`; `.donut-layout` empilha |
| `max-width:900px` | `globals.css:127` | `.toast-viewport` e `.install-prompt` sobem para `bottom:88px` |
| `max-width:800px` | `auth.css:1` | `.auth-page` vira 1 coluna e `.auth-aside` some |
| `max-width:600px` | `onboarding.css:1` | Onboarding vira tela cheia sem borda |
| `max-width:700px` | `management.css:43` | `.management-header` empilha; `.page-header__action` vira largura total |
| `max-width:820px` | `transaction.css:354` | Formulários de importação e `.transaction-filters` viram 2 colunas |
| `max-width:520px` | `transaction.css:376` | Os mesmos viram 1 coluna; `.transaction-list-row` vira `2.625rem 1fr` |
| `max-width:480px` | `card.css:1` | `.form-pair` vira 1 coluna |
| `max-width:700px` | `dialog.css:44` | `.dialog--sheet` vira bottom sheet (animação `sheet-up`, 220ms) |

`components.css` e `reports.css` não têm media query nenhuma.

O par que importa para layout de página é **900 / 901**: abaixo de 901px não há
offset de sidebar; acima, o offset existe e é obrigatório passar por
`.dashboard-shell`.

---

## Ordem de import das folhas (`layout.tsx:3-11`)

```
1  globals.css                       6  card.css
2  auth.css                          7  dialog.css
3  onboarding.css                    8  components.css
4  management.css                    9  reports.css
5  transaction.css
```

**Por que a ordem importa:** não há CSS Modules aqui (a única exceção é
`preview-design/preview.module.css`, que não é importada no layout). Todas as
folhas caem no mesmo escopo global, então **regras de mesma especificidade em
folha posterior sobrescrevem as anteriores**. `globals.css` vem primeiro de
propósito: é a base que as folhas de página podem ajustar, nunca o contrário.

Dois casos concretos que já morderam:

1. **`projection.css` redefinia `.metric-card`** com o design antigo. Como era
   importada depois de `globals.css`, o card de métrica inteiro voltava ao visual
   antigo em todas as páginas — o sistema quebrava por causa de uma folha que
   ninguém lembrava que existia. A folha foi deletada (junto com
   `dashboard-extra.css`) no commit `2dacd4e`.
2. **Dentro do próprio `globals.css`**, a media query `min-width:901px` do offset
   da sidebar (`:37`) precisa vir **depois** da regra base de `.dashboard-shell`
   (`:34`). Mesma especificidade: quem vem por último vence. Invertido, o
   `margin-left` some e o conteúdo de **todas** as páginas fica atrás da sidebar
   no desktop. O comentário em `globals.css:35-36` existe exatamente para isso.

**Folha nova precisa ser importada explicitamente em `layout.tsx`.**
`dialog.css` ficou órfã por meses e todos os modais renderizavam sem estilo.

---

## Contrato dos componentes compartilhados

Em `src/app/components/`.

| Componente | Contrato real |
|------------|---------------|
| `PageHeader` | Fragmento com duas partes: (1) uma `<div>` com `style` inline alinhando `<UserMenu />` à direita; (2) `<div className="page-header">` com `style` inline (`flex`, `space-between`, `flex-wrap`, `gap:16px`, `margin-bottom:32px`) contendo `.eyebrow` com o `workspaceName` (cor sobrescrita para `--muted` inline), `<h1>` `1.75rem` com `title`, `<p className="muted">` com `subtitle`, e opcionalmente um `<button className="page-header__action">` com ícone `Plus` e `style` inline. Props: `{ title, subtitle, workspaceName, action?: { label, onClick, ariaLabel? } }`. **Não renderiza mais `.management-header`** e **não tem link de voltar**. `.page-header` não tem regra CSS — todo o layout é inline. |
| `List` | `<div className="dashboard-card">` com `<h3 style={{fontSize:'1.2rem'}}>{title}</h3>` e uma coluna flex `gap:8px` para os filhos; sem filhos, mostra `<p className="muted">Nada por aqui ainda.</p>`. **Não é mais `.account-list` com `<h2>`.** Props: `{ title, children }`. |
| `Dialog` | Envolve o `<dialog>` nativo: sincroniza `open` com `showModal()`/`close()`, escuta o evento `close` e propaga para `onClose` (fecha com Esc), renderiza `.dialog__header` (`<h2>` com o título + botão `aria-label="Fechar"` com ícone `X`) e `.dialog__body`. `aria-label={title}` no próprio `<dialog>`. Props: `{ open, onClose, title, children, variant?: "desktop" \| "bottom-sheet" }` — `bottom-sheet` adiciona `.dialog--sheet`, que só muda de forma em ≤700px. |
| `SimpleForm` | `<form className="simple-form">` que faz `preventDefault`, mantém estado `pending`, envolve os filhos num `<fieldset disabled aria-busy>`, mostra `<p role="status">Salvando...</p>` durante o envio e `<p className="form-error" role="alert">` com texto fixo "Não foi possível salvar. Tente novamente." em caso de exceção. Props: `{ children, onSubmit(form: FormData): Promise<void> }`. Estilo dos campos (`min-height:48px`, `font-size:16px`, foco roxo com `box-shadow`) vem de `components.css:110-129`. |
| `Nav` | Fragmento com `<aside className="app-nav">` (desktop) + `<nav className="mobile-nav">` (≤900px). Desktop: 11 destinos (`/`, `/ganhos`, `/gastos`, `/contas`, `/cartoes`, `/investimentos`, `/planejamento`, `/relatorios`, `/saude`, `/categorias`, `/configuracoes`), item ativo com `.active` + `aria-current="page"`, mais um item sintético "Compromissos" quando a rota é `/compromissos`. Botão `.nav-collapse-toggle` alterna `.collapsed`, persiste em `localStorage['bsf-nav-collapsed']` e escreve `--sidebar` (`264px` ↔ `84px`) no `documentElement`. Móvel: 5 destinos com `.mobile-add` central para `/movimentacoes`. **Não tem alternador de tema nem botão de sair.** |
| `MonthPicker` | `.month-picker` com dois botões de seta (`aria-label` "Mês anterior"/"Próximo mês") em volta de um `<input type="month">` nativo — sem biblioteca de calendário. Lê e escreve o mês global de `useMonth()` (`MonthContext`), no formato `YYYY-MM-01`. |
| `DashboardChart` | `<canvas>` Chart.js (`bar` \| `line` \| `doughnut`). Aceita série única (`labels`/`values`/`label`/`color`) ou múltiplas (`series: {label,values,color}[]`), mais `legend`, `compactY`, `tooltipTitles`. Lê os tokens vivos do `:root` em runtime via `getComputedStyle` com fallback embutido (SSR/jsdom). Tooltip formata em BRL. Precisa de contêiner com `min-width:0`. |
| `EmptyState` | `<div className="dashboard-empty">` com `<h3>{title}</h3>` e `<p>{description}</p>` opcional. |
| `Toast` / `ToastProvider` | Contexto com `toast(text, kind?)`; renderiza `.toast-viewport` com `aria-live="polite"` e cada item como `.toast toast--{kind}` (ícone `CircleCheck`/`CircleAlert`), `role="alert"` só para erro. Duração: 4000ms sucesso, 6000ms erro. |
| `Money` | `money()` formata BRL pt-BR; `parseMoney()` lê "1.234,56" e "1234.56" sem devolver `NaN`; `cents()`, `dateFmt`, `monthStart()`, `nextMonthStart()`. |

---

## Badges de ícone: hex inline é o padrão

O par fundo translúcido + ícone sólido é escrito **direto no `style` do TSX**,
não em token. Este é o padrão vigente do sistema, não uma violação:

| Cor | Fundo | Ícone | Uso |
|-----|-------|-------|-----|
| Roxo | `rgba(139,92,246,.15)` | `#8B5CF6` | Patrimônio, neutro/marca |
| Verde | `rgba(34,197,94,.15)` | `#22C55E` | Receita, entrada |
| Vermelho | `rgba(239,68,68,.15)` | `#EF4444` | Despesa, saída |
| Âmbar | `rgba(245,166,35,.15)` | `#F5A623` | Investimento, destaque |

```jsx
<span className="metric-icon-badge" style={{ background: "rgba(34,197,94,.15)", color: "#22C55E" }}>
  <DollarSign size={18} aria-hidden="true" />
</span>
```

Ver `DashboardPage.tsx:189,197,205,213` (`.metric-icon-badge`), `:301` (`.tx-icon-badge`)
e `ganhos/page.tsx:548,552` (`.type-pill`). O **texto** de valor continua saindo
de token (`var(--danger)` / `var(--positive)`), só o par do badge é literal.

---

## Página de referência

`src/app/DashboardPage.tsx:157-318` é a implementação canônica do sistema.
Estrutura:

```
<main className="dashboard-shell">
  <Nav />
  <div style={…flex-end}><UserMenu /></div>
  <div className="page-header" style={…}>  h1 + subtítulo + <MonthPicker /></div>
  [<Link className="insight-link">…</Link>]         alerta opcional
  <div className="bento-row" style={{gridTemplateColumns:'repeat(4,1fr)'}}>
     4 × <article className="metric-card"> com .metric-card__head + .metric-icon-badge + <strong> + .metric-card__trend
  </div>
  <div className="dashboard-bento-grid">
     <div className="bento-main">   <article className="dashboard-card"> gráfico + .chart-legend </article></div>
     <div className="bento-sidebar"><article className="dashboard-card"> .donut-layout + .donut-legend </article></div>
  </div>
  <div className="dashboard-bento-grid" style={{gridTemplateColumns:'1fr 1fr'}}>
     .goal-row × N   |   .tx-row × N
  </div>
</main>
```

---

## Anti-patterns

- ❌ **Emoji como ícone.** Só `lucide-react`, sempre com `aria-hidden="true"`;
  o rótulo acessível vem do texto ao lado ou de `aria-label` no clicável.
- ❌ **Remover o foco.** `button, a, input, select, summary` em `:focus-visible`
  recebem `outline:3px solid var(--focus); outline-offset:3px`
  (`globals.css:18`). Nunca sobrescreva com `outline:none` sem substituto
  visível — `.simple-form` faz isso e compensa com `box-shadow`
  (`components.css:123-129`).
- ❌ **Animação que precisa rodar para o conteúdo ficar legível.**
  `prefers-reduced-motion:reduce` zera duração de animação e transição
  (`globals.css:23`). O projeto não usa GSAP nem Framer Motion.
- ❌ **Envolver a página num wrapper extra.** Quem dá o offset da sidebar é
  `.dashboard-shell`, e ele é a raiz `<main>`. Um wrapper por fora empurra o
  conteúdo duas vezes; um wrapper por dentro come o offset.
- ❌ **Scroll horizontal no mobile.** Itens de grid precisam de `min-width:0`.
- ❌ **Tabela larga solta.** Sempre dentro de `.table-scroll`
  (`globals.css:112`).
- ❌ **Folha nova sem import em `layout.tsx`.** Sem o import explícito ela
  simplesmente não existe no bundle.
- ❌ **`@import` de host remoto em `globals.css`.** As fontes vêm de
  `next/font`. Há um teste — `src/app/globals.test.ts` — que falha se uma URL de
  `fonts.googleapis.com` ou `fonts.gstatic.com` reaparecer no arquivo.
- ❌ **Redefinir classe canônica (`.metric-card`, `.dashboard-card`,
  `.dashboard-shell`) em folha de página.** Foi assim que `projection.css`
  quebrou o sistema.
- ❌ **Alternador de tema / regra `[data-theme="light"]`.** Tema é um só.

---

## Checklist de entrega

- [ ] Nenhum emoji como ícone; ícones só de `lucide-react`, com `aria-hidden="true"`
- [ ] `cursor: pointer` em todo elemento clicável
- [ ] Foco visível preservado na navegação por teclado
- [ ] `prefers-reduced-motion` respeitado
- [ ] Cor de token, exceto o par de badge de ícone documentado acima
- [ ] Página é `<main className="dashboard-shell">`, sem wrapper extra
- [ ] Responsivo em 375 / 768 / 1024 / 1440px (atenção aos cortes 760, 768, 900/901, 1024)
- [ ] Nada escondido atrás da sidebar fixa nem da barra móvel inferior
- [ ] Sem scroll horizontal no mobile (`min-width:0` nos itens de grid)
- [ ] Tabela larga dentro de `.table-scroll`
- [ ] Valores por `money()` e com `tabular-nums`
- [ ] Folha nova importada em `layout.tsx`, na posição certa da cascata
- [ ] `npm test` passando (inclui `globals.test.ts`)

---

## Dívida conhecida

Levantada comparando os `className` dos `.tsx` em `src/` com os seletores das
folhas em `src/app/`.

### Classes usadas em TSX sem regra em CSS nenhum

| Classe | Usada em |
|--------|----------|
| `.page-header` | `src/app/components/PageHeader.tsx:27`, `src/app/DashboardPage.tsx:166` — todo o layout é `style` inline |
| `.auth-shell`, `.auth-card` | `src/app/auth/callback/page.tsx` |
| `.brand-badge` | `src/app/CardsPage.tsx` |
| `.default-account-card`, `.default-account-form` | `src/app/components/DefaultCashAccountForm.tsx` |
| `.quick-transaction-card`, `.quick-transaction-form`, `.quick-transaction-heading`, `.quick-transaction-details`, `.quick-transaction-field`, `.quick-transaction-type`, `.quick-transaction-message`, `.quick-description`, `.quick-default-account-help` | `src/app/components/QuickTransactionForm.tsx` |
| `.spending-power-card` | `src/app/components/SpendingPowerCard.tsx` |
| `.today-panel`, `.today-alert`, `.today-actions`, `.today-projection` | `src/app/components/TodayPanel.tsx` |

Nenhuma dessas quebra a tela — herdam o visual do pai — mas também não têm
contrato: mexer nelas não faz nada.

### Seletores em CSS sem nenhum consumidor em TSX

Em `transaction.css` estão mortos o bloco de navegação antigo e os formulários
que ele servia: `.finance-nav`, `.quick-link`, `.nav-more`, `.nav-more-links`,
`.nav-signout`, `.finance-form`, `.transaction-filters`,
`.transaction-entry-details`, `.transaction-list-row` e `.transaction-types`.
Os `.statement-import-*`, que ocupam a maior parte da folha, continuam em uso.
Em `management.css` só `.page-header__action` ainda é usada —
`.management-header` está morta. Também sem consumidor: `.tabs-nav`, `.skip` e
`.brand-logo` (`globals.css:18`). Continuam sendo baixadas por todo usuário.

### Outros

- `profiles.theme_preference` existe no banco e nenhum código lê ou escreve.
- `src/app/preview-design/` usa CSS Module próprio (`preview.module.css`), fora
  do sistema e fora do `layout.tsx`.
