# Plano de Desenvolvimento: QA Avançado de Frontend, Redimensionamento & Redesign Apple / 21st.dev

Estruturação de um sistema avançado de QA de frontend focado em redimensionamento e comportamento responsivo (especialmente com o menu lateral expandido a 264px), acompanhado da elevação do design visual para a estética Apple Human Interface Guidelines e componentes modernos inspirados no 21st.dev (frosted glassmorphism, bordas especulares, cards táteis, hierarquia tipográfica precisa e segmented controls).

## User Review Required

> [!IMPORTANT]
> **Substituição de estilos inline por classes de grid responsivo**: O app atualmente possui regras inline como `style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}` em `DashboardPage`, `CardsPage`, `TransactionsPage`, `ReportsPage` e `HealthPage`. Essas regras serão substituídas por classes de layout fluido (`.bento-row--4`, `.bento-row--3`, `.bento-row--filters`), garantindo que em telas de 900px–1280px com a sidebar estendida os cards se reorganizem em 2 colunas em vez de serem espremidos em 140px.

> [!NOTE]
> **Preservação de arquivos locais**: Conforme as diretrizes de governança, o arquivo não rastreado `src/app/api/shortcuts` será preservado e não fará parte do commit desta entrega.

---

## Skills previstas

| Skill | Etapa de Uso | Evidência Produzida |
| :--- | :--- | :--- |
| **systematic-debugging** | Investigação e diagnóstico do comportamento da sidebar e dos grids | Mapeamento exato de overflow e quebra de colunas em 900px–1280px |
| **brainstorming** / **generative_ui** | Definição da paleta de glassmorphism, sombras especulares e tokens Apple | Design tokens de cards, badges, botões táteis e segmented controls |
| **writing-plans** | Estruturação formal das entregas verticais, riscos e critérios de aceite | Artefato do plano em `docs/superpowers/plans/` e no workspace |
| **subagent-driven-development** / **executing-plans** | Implementação modular dos estilos, componentes e testes E2E | Commits incrementais, testes passando sem regressões |
| **verification-before-completion** | Execução de lint, testes unitários, build e suíte E2E de redimensionamento | 451+ testes unitários passando + Next.js build limpo + testes E2E de viewport |

---

## Entregas Verticais

### Vertical 1: Layout Shell Fluido & Engine de Grid Responsivo (Menu Estendido)
- **Problema**: Com o menu lateral estendido (`--sidebar: 264px`), telas de 901px a 1280px (laptops e tablets em modo paisagem) ficam com largura útil entre 650px e 950px. O uso de `repeat(4, 1fr)` em linha esmaga os cards de métricas em ~140px, causando quebra de texto em valores numéricos (`R$ 123.456,78` em 3 linhas) e sobreposição de badges. Além disso, `.app-nav` tem transição de 180ms, mas `.dashboard-shell` não tem transição em `margin-left` ou `width`, gerando saltos bruscos.
- **Solução**:
  1. Adicionar transição suave em `.dashboard-shell`: `transition: margin-left 0.2s cubic-bezier(0.16, 1, 0.3, 1), width 0.2s cubic-bezier(0.16, 1, 0.3, 1);`.
  2. Implementar classes de grid fluido em `globals.css`:
     - `.bento-row--4`: `grid-template-columns: repeat(auto-fit, minmax(min(100%, 220px), 1fr))` com media query adaptativa para 2 colunas entre 640px e 1200px quando a barra estiver expandida.
     - `.bento-row--3`: `grid-template-columns: repeat(auto-fit, minmax(min(100%, 280px), 1fr))`.
     - `.bento-row--filters`: grid adaptativo para formulários e filtros de busca (substituindo o rígido `2fr 1fr 1fr 1fr`).
     - Atualização do `.dashboard-bento-grid`: colapso seguro da coluna lateral de 380px para 1 coluna quando a largura útil for inferior a 850px.
  3. Refatorar as páginas `DashboardPage.tsx`, `CardsPage.tsx`, `TransactionsPage.tsx`, `ReportsPage.tsx`, `HealthPage.tsx`, `CategoriesPage.tsx` e `PlanningPage.tsx` para utilizarem as novas classes sem sobrescrever via inline.

### Vertical 2: Design System Apple HIG & 21st.dev
- **Objetivo**: Elevar a qualidade visual do aplicativo para o patamar dos produtos Apple (macOS / iOS) e referências modernas do 21st.dev.
- **Implementação**:
  1. **Frosted Glass & Depth**:
     - `background: rgba(17, 21, 31, 0.75); backdrop-filter: blur(20px) saturate(180%); -webkit-backdrop-filter: blur(20px) saturate(180%);`
     - Borda especular interna dual-layer:
       `box-shadow: inset 0 1px 0 0 rgba(255, 255, 255, 0.1), 0 8px 32px rgba(0, 0, 0, 0.36); border: 1px solid rgba(255, 255, 255, 0.08);`
  2. **Cards de Métricas & Tipografia**:
     - Arredondamento harmônico `border-radius: 20px`.
     - Badges de ícones em squircle com preenchimento translúcido e borda sutil correspondente (`rgba(139, 92, 246, 0.15)` com `border: 1px solid rgba(139, 92, 246, 0.25)`).
     - Valores monetários tabulares com clamp responsivo: `font-size: clamp(1.45rem, 2.2vw, 2.15rem); font-variant-numeric: tabular-nums; letter-spacing: -0.025em; line-height: 1.15;`.
     - Indicadores de tendência (Trend pills) no estilo Apple Health / Stocks: cápsulas translúcidas com micro-ícones e cantos `9999px`.
  3. **Sidebar no Estilo macOS**:
     - Fundo translúcido acrílico com blur.
     - Destaque ativo com pílula de iluminação suave (`background: rgba(139, 92, 246, 0.16); border: 1px solid rgba(139, 92, 246, 0.32); color: #fff;`).
     - Ícone da marca refinado com gradiente suave Apple-like.
  4. **Segmented Controls & Botões Táteis**:
     - `.hub-tabs` e `.tabs-nav` transformados em autênticos *Segmented Controls* Apple (contêiner em cápsula/superelipse com fundo suave, borda sutil e aba ativa destacada em pílula contrastante).
     - Botões primários e secundários com micro-interações táteis: `:active { transform: scale(0.98); }` e transições de 150ms.

### Vertical 3: Suíte Automatizada de QA Avançado de Frontend (Redimensionamento & E2E)
- **Objetivo**: Garantir que nenhuma alteração futura quebre o layout com menu aberto ou fechado em qualquer dispositivo.
- **Implementação**:
  1. Criação do teste automatizado Playwright `e2e/qa-responsive-resizing.e2e.ts`:
     - **Matriz de Viewports**:
       * `390 x 844` (Mobile retrato - iPhone 14/15/16)
       * `768 x 1024` (Tablet retrato - iPad)
       * `1024 x 768` (Tablet paisagem / Laptop pequeno)
       * `1280 x 800` (Laptop comum - MacBook Air / 13")
       * `1440 x 900` (Desktop - MacBook Pro 14"/16")
       * `1920 x 1080` (Widescreen Full HD)
     - **Estados Testados**: Menu recolhido (`84px`) E Menu expandido (`264px`).
     - **Verificações Automáticas**:
       1. Ausência de scroll horizontal no documento (`scrollWidth <= clientWidth`).
       2. Nenum elemento filho de `.dashboard-shell` ultrapassando as bordas da viewport (`boundingClientRect().right <= clientWidth`).
       3. Integridade dos cards de métricas (nenhum valor monetário quebrado em 3+ linhas, altura consistente).
       4. Transição suave ao alternar o botão de colapso do menu.
  2. Adição de testes unitários de CSS e tokens em `src/app/globals.test.ts`.

### Vertical 4: Homologação, Gates de CI/CD e Deploy em Produção
- Execução dos gates obrigatórios:
  1. Lint: `npm run lint`
  2. Testes unitários / regressão: `npm test` (100% de sucesso nos 451+ testes)
  3. Build estático Next.js: `npm run build`
  4. Suíte de QA de redimensionamento Playwright
  5. Deploy: Commit e push para `origin/main` + deploy no container Docker da VPS Oracle + verificação de saúde HTTP 200.

---

## Workflow Autônomo & Gates

1. **Preparação**:
   - Backup/checagem do repositório limpo (`git status`).
   - Isolamento das alterações fora de escopo (`src/app/api/shortcuts`).
2. **Execução**:
   - Atualizar tokens em `src/app/globals.css`, `src/app/components.css`, `src/app/transaction.css`.
   - Ajustar classes responsivas nos componentes (`DashboardPage.tsx`, `CardsPage.tsx`, etc.).
   - Criar a suíte E2E em `e2e/qa-responsive-resizing.e2e.ts`.
3. **Gates de Validação**:
   - `npm test` -> 0 falhas.
   - `npm run build` -> 0 erros de compilação.
   - `npm run lint` -> código limpo.
4. **Deploy & Auditoria**:
   - Salvar cópia do plano em `docs/superpowers/plans/2026-09-08-qa-frontend-redimensionamento-apple-design.md`.
   - Executar deploy na VPS Oracle.

## Autorização para Decisões Autônomas
O agente está expressamente autorizado a tomar de forma autônoma todas as decisões de estilo, classes CSS, ajustes de flex/grid, micro-animações táteis e seletores de teste que sejam reversíveis e necessárias para o perfeito cumprimento dos requisitos, pausando apenas em caso de impedimentos externos irreversíveis.
