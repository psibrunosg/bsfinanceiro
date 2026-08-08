# Design System Master File

> **LÓGICA:** Ao construir uma página específica, verifique antes `design-system/pages/[nome-da-pagina].md`.
> Se esse arquivo existir, as regras dele **sobrescrevem** este Master.
> Caso contrário, siga estritamente as regras abaixo.

> **FONTE DA VERDADE:** este documento é extraído da implementação real —
> `src/app/globals.css`, `src/app/management.css` e `src/app/components/`.
> Se o CSS e este documento divergirem, o CSS vence e este arquivo deve ser corrigido.

---

**Project:** BS Financeiro
**Generated:** 2026-08-08
**Category:** Banking/Traditional Finance
**Design Dials:** Variance 4/10 (Equilibrado / Moderno) | Motion 2/10 (Mínimo) | Density 6/10 (Padrão)

---

## Temas

O app tem **dois temas alternáveis**: claro (padrão) e escuro. O tema é aplicado
via atributo `data-theme` no `<html>` (`data-theme="light"` | `data-theme="dark"`)
pelo `ThemeProvider`, que persiste a preferência (`system` | `light` | `dark`) em
`profiles.theme_preference` e acompanha `prefers-color-scheme` quando a
preferência é `system`.

**Nunca escreva cor hexadecimal direto no componente.** Toda cor sai de uma
variável CSS, senão o tema escuro quebra.

### Tokens de cor

| Token | Claro (`:root`) | Escuro (`:root[data-theme="dark"]`) | Uso |
|-------|-----------------|--------------------------------------|-----|
| `--bg` | `#f4f7f5` | `#0c1714` | Fundo da aplicação |
| `--surface` | `#fff` | `#14211e` | Cartões, barra lateral, campos |
| `--surface-2` | `#e9f0ed` | `#1c302a` | Fundo secundário (abas, chips, cabeçalhos de grupo) |
| `--text` | `#172522` | `#eff7f4` | Texto principal |
| `--muted` | `#60716c` | `#afc0ba` | Texto secundário, rótulos, ícones inativos |
| `--border` | `#d6e2dd` | `#30463f` | Bordas e divisores |
| `--primary` | `#123f37` | `#d8eee6` | Marca; texto de item de navegação ativo |
| `--primary-2` | `#1d5a4e` | `#bce4d8` | Variação da marca |
| `--accent` | `#087f5b` | `#64d6ae` | Ação principal (botões, destaque) |
| `--accent-contrast` | `#fff` | `#0c1714` | Texto/ícone sobre `--accent` |
| `--positive` | `#087f5b` | `#64d6ae` | Valores positivos, sucesso, pago |
| `--warning` | `#a56a00` | `#f0bd57` | Alerta, pendente |
| `--danger` | `#b93636` | `#ff9c9c` | Erro, valores negativos, destrutivo |
| `--gold` | `#b88617` | `#e6bd62` | Destaque de investimento/meta |
| `--focus` | `#155eef` | `#81b8ff` | Anel de foco visível |
| `--shadow` | `0 10px 30px rgb(17 50 42 / .08)` | `0 12px 34px rgb(0 0 0 / .25)` | Elevação |
| `--tint` | `rgb(8 127 91 / .1)` | `rgb(100 214 174 / .14)` | Fundo suave do accent (ícone de linha, chip pago) |
| `--row-hover` | `rgb(17 50 42 / .04)` | `rgb(255 255 255 / .04)` | Hover de linha de lista |

**Notas de cor:** verde institucional (confiança + finanças), sem azul de marca.
O azul aparece apenas em `--focus`, para se destacar do verde.

### Espaçamento

| Token | Valor |
|-------|-------|
| `--space-1` | `4px` |
| `--space-2` | `8px` |
| `--space-3` | `12px` |
| `--space-4` | `16px` |
| `--space-5` | `24px` |
| `--space-6` | `32px` |

### Raios

| Token | Valor | Uso |
|-------|-------|-----|
| `--radius` | `16px` | Cartões (`.account-list`, `.dashboard-card`) |
| `--radius-md` | `14px` | Contêiner de abas (`.hub-tabs`) |
| `--radius-sm` | `10px` | Campos, botões, ícone de linha, botão de aba |

### Layout

| Token | Valor | Uso |
|-------|-------|-----|
| `--sidebar` | `264px` | Largura da navegação lateral fixa (desktop) |

Conteúdo de página: `.page-content` (`margin-left: var(--sidebar)`, `max-width: 1680px`);
colunas de conteúdo: `.management-page` / `.dashboard-shell` (`width: min(1180px, …)`).

### Breakpoints

- **`min-width: 901px`** — barra lateral fixa (`.app-nav`); as colunas de conteúdo
  ganham `margin-left: var(--sidebar)`.
- **`max-width: 900px`** — `.app-nav` some, entra a `.mobile-nav` (barra inferior
  fixa de 5 colunas, com botão central `.mobile-add`), e `.page-content` perde a
  margem lateral e ganha `padding-bottom: 104px` para não ficar sob a barra.
- **`max-width: 700px`** — ajustes de densidade: `.management-header` empilha,
  `.page-header__action` vira largura total, `.account-row` e cabeçalhos de
  `.account-list` reduzem o padding lateral para `var(--space-4)`.

---

## Tipografia

Carregada por `@import` do Google Fonts em `globals.css`.

- **Títulos (`h1`, `h2`, `h3`):** `Lexend`, fallback `"Source Sans 3", sans-serif`,
  `letter-spacing: -.025em`.
- **Corpo (`body`):** `Source Sans 3`, fallback `system-ui, sans-serif`,
  `font: 16px/1.5`.
- **Pesos disponíveis:** Lexend 400/500/600/700; Source Sans 3 400/600/700.
- `h1`: `font-size: clamp(1.7rem, 2vw, 2.25rem)`, `line-height: 1.18`.
- `h2`: `1.15rem`, `margin: 0`.
- **`.eyebrow`** — rótulo acima do título: `--accent`, `.75rem`, peso 700,
  `letter-spacing: .09em`.
- **`.muted`** — texto secundário em `--muted`.
- **Valores monetários:** sempre `font-variant-numeric: tabular-nums`
  (já aplicado em `.account-row b` / `.account-list b`), para alinhar as colunas
  de dinheiro verticalmente.

---

## Acessibilidade e movimento

- **Foco visível (obrigatório, já global):**
  `button, a, input, select, summary` em `:focus-visible` recebem
  `outline: 3px solid var(--focus); outline-offset: 3px`. Nunca remova.
- **Skip link:** `.skip` fixo, revelado no foco.
- **Movimento:** o projeto **não usa biblioteca de animação** (sem GSAP, sem
  Framer Motion). Só transições CSS curtas: `140–200ms ease` em background,
  cor e borda. Nada de animação de entrada/saída de rota.
- **`prefers-reduced-motion: reduce`:** regra global zera `scroll-behavior`,
  `animation-duration` e `transition-duration`. Não crie animação que dependa
  de rodar para o conteúdo ficar legível.
- **Ícones:** `lucide-react`, sempre com `aria-hidden="true"`; o rótulo
  acessível vem do texto ao lado ou de `aria-label` no elemento clicável.

---

## Primitivas de layout

**Regra:** página nova **NÃO** inventa layout com `style` inline. Usa estas
classes. Elas estão em `src/app/management.css`, no bloco "PADRÃO DE
APRESENTAÇÃO", e são compartilhadas por Gastos, Ganhos, Contas, Cartões,
Investimentos e Planejamento.

### `.account-list` — cartão que agrupa registros

Superfície com borda e raio `--radius`, `overflow: hidden`. O `> h2` vira o
cabeçalho do cartão (borda inferior, texto em `--muted`); `h4` interno vira
cabeçalho de agrupamento (mês/competência) sobre `--surface-2`.
Uma `ul.list` direta dentro dele vira lista simples de duas colunas
(`1fr auto`).

```jsx
<div className="account-list">
  <h2>Contas correntes</h2>
  <h4>Agosto 2026</h4>
  {/* linhas */}
</div>
```

Prefira o componente `List` quando só precisar de título + filhos.

### `.account-row` — uma linha de registro

Grid de três colunas: `[ícone] [descrição] [valor]` (`auto 1fr auto`).
O **primeiro `<span>`** é o slot do ícone (quadrado 40px, fundo `--tint`,
cor `--accent`). No meio, `<strong>` é o título e `<small>` a legenda.
O valor vai em `<b>` (tabular-nums, sem quebra). Hover usa `--row-hover`;
a última linha perde a borda inferior automaticamente.

```jsx
<div className="account-row">
  <span><Landmark aria-hidden="true" /></span>
  <div>
    <strong>Conta corrente</strong>
    <small>Banco X · atualizado hoje</small>
  </div>
  <b>{money(saldo)}</b>
</div>
```

### `.simple-form` — formulário de cadastro dentro de um Dialog

Empilha pares rótulo→campo. O respiro fica **entre** os pares
(`label { margin-top: var(--space-4) }`, o primeiro sem margem), então o rótulo
fica colado no seu campo. Campos (`input`/`select`/`textarea`) já vêm com
largura total, `min-height: 44px` (alvo de toque), borda `--border` e raio
`--radius-sm`. O botão de submit direto do form (ou do `fieldset`) já vem
estilizado com `--accent`. `p[role="status"]` e `p[role="alert"]` já têm
espaçamento próprio.

```jsx
<Dialog open={open} onClose={close} title="Nova conta">
  <SimpleForm onSubmit={salvar}>
    <label htmlFor="nome">Nome</label>
    <input id="nome" name="nome" required />
    <label htmlFor="saldo">Saldo inicial</label>
    <input id="saldo" name="saldo" inputMode="decimal" />
    <button type="submit">Salvar</button>
  </SimpleForm>
</Dialog>
```

### Auxiliares do padrão

| Classe | Papel |
|--------|-------|
| `.management-grid` | Grid vertical da página, `gap: var(--space-5)` |
| `.hub-overview` | Grid de cartões-resumo, `auto-fit minmax(230px, 1fr)` |
| `.hub-tabs` | Controle segmentado dos hubs; botão ativo recebe `.active` |
| `.hub-filters` | Linha de filtros (`label` + `select`) acima do conteúdo |
| `.dashboard-empty` | Estado vazio centralizado dentro de um cartão |
| `.chip`, `.chip--paid`, `.chip--pending` | Selo de status (pílula, caixa alta) |
| `.btn-primary` | Botão de ação principal (`--accent`) |
| `.btn-circle` | Botão de ícone circular 32px (`--accent`) |
| `.page-header__action` | Ação do cabeçalho de página; vira largura total ≤700px |
| `.finance-form` | Formulário curto embutido numa linha (ex.: pagar ocorrência) |
| `.form-success` / `.form-error` | Mensagens de resultado de formulário |

---

## Componentes compartilhados

Em `src/app/components/`.

| Componente | Contrato |
|------------|----------|
| `PageHeader` | Cabeçalho `.management-header`: link de voltar, logo, eyebrow (workspace), `title`, `subtitle` e `action` opcional (`{ label, onClick, ariaLabel }`) renderizada como `.page-header__action` com ícone `Plus`. |
| `Dialog` | Envolve o `<dialog>` nativo: sincroniza `open` com `showModal()`/`close()`, propaga o evento `close` para `onClose` (fecha com Esc), e monta `.dialog__header` com título e botão "Fechar". |
| `SimpleForm` | Cuida de `preventDefault`, estado `pending`, `fieldset disabled` + `aria-busy` durante o envio, mensagem `role="status"` ("Salvando...") e captura de erro em `role="alert"`. Recebe `onSubmit(formData) => Promise<void>`; o componente de página só lê o `FormData`. |
| `List` | Cartão `.account-list` com `<h2>{title}</h2>` e filhos; sem filhos, mostra o texto vazio padrão. |
| `Money` (`Money.tsx`) | Utilitários de dinheiro/data: `money()` formata BRL pt-BR; `parseMoney()` lê "1.234,56" e "1234.56" e nunca devolve `NaN`; `cents()`, `dateFmt`, `monthStart()`, `nextMonthStart()`. Toda exibição de valor passa por `money()`. |
| `DashboardChart` | `<canvas>` Chart.js (`bar` \| `line` \| `doughnut`) com `role="img"` e `aria-label` descrevendo a série. Lê `--muted`/`--border` do tema em runtime e **redesenha ao trocar de tema** (MutationObserver em `data-theme`). Precisa de contêiner com `min-width: 0`. |
| `Nav` | Barra lateral `.app-nav` (desktop) + `.mobile-nav` (≤900px) com os mesmos destinos; marca item ativo com `.active` e `aria-current="page"`; inclui alternador de tema e sair. |
| `ThemeProvider` / `useThemePreference` | Aplica `data-theme` no `<html>`, resolve `system` via `prefers-color-scheme`, carrega e persiste `theme_preference` no perfil Supabase. |

---

## Anti-Patterns (NÃO usar)

- ❌ Design "divertido"/lúdico
- ❌ UX de segurança descuidada
- ❌ Gradientes roxo/rosa de "IA"

### Proibições adicionais

- ❌ **Cor hexadecimal hardcoded** — sempre variável CSS, senão o tema escuro quebra
- ❌ **Layout com `style` inline em página nova** — use `.account-list`, `.account-row`, `.simple-form`
- ❌ **Emojis como ícones** — use SVG (`lucide-react`, o set do projeto)
- ❌ **Falta de `cursor: pointer`** — todo elemento clicável precisa dele
- ❌ **Hover que desloca o layout** — nada de `scale`/`translate` que empurre vizinhos
- ❌ **Texto de baixo contraste** — mínimo 4.5:1, nos dois temas
- ❌ **Mudança de estado instantânea** — use transições (140–300ms)
- ❌ **Estado de foco invisível** — nunca remova o `outline` de `:focus-visible`
- ❌ **Biblioteca de animação (GSAP, Framer Motion)** — o projeto não usa nenhuma

---

## Checklist de entrega

Antes de entregar qualquer código de UI, verifique:

- [ ] Nenhum emoji como ícone (SVG do `lucide-react`)
- [ ] Ícones de um único conjunto, com `aria-hidden="true"`
- [ ] `cursor: pointer` em todo elemento clicável
- [ ] Hover com transição suave (140–300ms)
- [ ] Contraste de texto ≥ 4.5:1 **nos dois temas** (claro e escuro)
- [ ] Nenhuma cor hardcoded — só variáveis CSS
- [ ] Testado com `data-theme="light"` **e** `data-theme="dark"`
- [ ] Foco visível na navegação por teclado
- [ ] `prefers-reduced-motion` respeitado
- [ ] Responsivo em 375px, 768px, 1024px, 1440px (atenção aos cortes 700/900/901px)
- [ ] Nenhum conteúdo escondido atrás da barra lateral fixa ou da barra inferior móvel
- [ ] Sem scroll horizontal no mobile (itens de grid com `min-width: 0`)
- [ ] Valores monetários via `money()` e com `tabular-nums`
