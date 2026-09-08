# Modernização dos Botões & UI Kit Minimalista (Apple / 21st.dev)

Substituição definitiva dos botões cinzas, retos e sem estilo por um sistema moderno de botões e controles interativos minimalistas (estilo Apple Human Interface Guidelines e 21st.dev), mantendo arquitetura leve em **CSS Nativo com Design Tokens**, sem dependências externas nem sobrecarga no bundle.

## User Review Required

> [!NOTE]
> Conforme solicitado pelo usuário, adotaremos a **Opção 1 (CSS Nativo & Tokens)** para garantir zero peso extra no bundle, deploy ultrarrápido e zero risco de quebra de compatibilidade com o Next.js 15 e React 19.

- **Identidade Visual**: Os botões adotarão cantos arredondados contínuos (*squircles* com `border-radius: 12px` ou formato de cápsula *pill* `9999px`), gradientes sutis de alta fidelidade, realces especulares superiores e microinterações de clique e hover táteis (`scale(0.975)` e brilho difuso).
- **Componentes `src/components/ui/`**: Criação de uma pasta padronizada para componentes atômicos modernos:
  - `src/components/ui/button.tsx` (Componente flexível com variantes `primary`, `secondary`, `glass`, `ghost`, `danger` e prop `glow`).
  - `src/components/ui/gradient-menu.tsx` (Componente interativo em cápsulas expansíveis com gradiente vibrante e brilho difuso, adaptado com ícones Lucide).

## Open Questions

Nenhuma pergunta bloqueante em aberto. O usuário já selecionou a abordagem leve e nativa.

## Proposed Changes

---

### Componentes de UI (`src/components/ui/`)

#### [NEW] [button.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/components/ui/button.tsx)
- Componente universal de botão com suporte a acessibilidade (`forwardRef`, tipos nativos de botão e link).
- Suporte a variantes:
  - `primary`: Gradiente de destaque roxo/índigo com realce especular e opção de *ambient glow*.
  - `secondary` / `glass`: Acabamento de vidro fosco translúcido (*frosted glass*), substituindo os antigos blocos cinzas opacos.
  - `ghost`: Transparente com realce sutil ao passar o cursor.
  - `danger`: Vidro avermelhado translúcido para ações destrutivas.
- Suporte a tamanhos: `sm`, `md`, `lg`, `pill`, `icon`.

#### [NEW] [gradient-menu.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/components/ui/gradient-menu.tsx)
- Implementação fiel da estética do 21st.dev trazida no prompt do usuário:
  - Cápsulas circulares que expandem suavemente em *pill* ao passar o mouse.
  - Gradiente vibrante dinâmico e brilho difuso no hover (`blur` atmosférico).
  - Uso dos ícones de `lucide-react` já presentes no projeto para não inchar o `node_modules`.

#### [NEW] [button.test.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/components/ui/__tests__/button.test.tsx)
- Testes unitários para o novo componente de botão cobrindo renderização, variantes, estados desabilitados e disparos de clique.

#### [NEW] [gradient-menu.test.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/components/ui/__tests__/gradient-menu.test.tsx)
- Testes unitários para o menu de gradiente cobrindo acessibilidade, lista de itens e estados interativos.

---

### Design System & Estilos Globais (`src/app/`)

#### [MODIFY] [globals.css](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/globals.css)
- Adicionar estilização base para a tag `<button>` garantindo que nenhum botão no app volte a ser cinza ou quadrado:
  - `border-radius: 12px;`
  - Fundo padrão limpo com transição suave de opacidade e escala.
  - Remoção de bordas padrão chanfradas do navegador.
- Definir classes utilitárias globais para compatibilidade retroativa:
  - `.primary-button`, `.button-primary`: cápsula/squircle com gradiente e specular highlight.
  - `.secondary-button`, `.button-secondary`: estilo *glass* translúcido com borda acetinada.
  - `.ghost-button`, `.button-ghost`: estilo minimalista sem preenchimento.

#### [MODIFY] [components.css](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/components.css)
- Ajustar os botões de formulário `.simple-form button[type="submit"]` e `.simple-form button[type="button"]` para usarem o design de cápsula moderna, feedback de foco e estados táteis.

#### [MODIFY] [dialog.css](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/dialog.css)
- Refinar botões de cabeçalho e fechamento de modais com visual minimalista de botão circular translúcido.

---

### Telas e Páginas Integradas

#### [MODIFY] [PageHeader.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/components/PageHeader.tsx)
- Substituir o botão com estilo inline rígido pelo novo componente `Button` com variante primária e efeito tátil.

#### [MODIFY] [CardsPage.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/CardsPage.tsx)
- Substituir os botões "Espelho da fatura" (antigamente cinzas e quadrados via `.button-secondary`) por cápsulas translúcidas refinadas.

#### [MODIFY] [ReportsPage.tsx](file:///c:/Users/ACPO%20Empreendimentos/Documents/Github/bsfinanceiro/src/app/ReportsPage.tsx)
- Integrar as novas classes e componentes de botão nas ações de exportação, compartilhamento e filtros.

---

## Skills previstas

| Etapa | Skill | Evidência a produzir |
| :--- | :--- | :--- |
| 1. Design & Componentes | `test-driven-development` | Testes unitários para `Button` e `GradientMenu` criados e passando |
| 2. Refatoração Visual | `subagent-driven-development` | Código limpo em `src/components/ui/` e integração global no CSS |
| 3. Verificação de Qualidade | `verification-before-completion` | Execução de lint (`0 errors`), vitest (`100% pass`) e build estático Next.js |
| 4. Deploy & Validação | Deploy via SSH/Docker | Container da VPS atualizado e verificação de status `HTTP 200 OK` |

---

## Workflow Autônomo & Definição de Pronto

1. **Preparação**: Garantir branch `main` limpa e testada.
2. **Execução**:
   - Criação da pasta `src/components/ui/` e dos componentes `button.tsx` e `gradient-menu.tsx`.
   - Atualização das regras em `globals.css`, `components.css`, `dialog.css`.
   - Integração nas telas (`PageHeader.tsx`, `CardsPage.tsx`, `ReportsPage.tsx`).
3. **Testes**: Executar suíte de testes com `npm test` garantindo regressão zero.
4. **Gates Mínimos**:
   - Lint: `npm run lint` (0 erros, 0 avisos).
   - Testes: `npm test` (100% dos testes aprovados).
   - Build: `npm run build` (geração estática sem falhas).
   - Acessibilidade & Responsividade: Botões com `focus-visible`, targets de toque mínimos de 44px e redimensionamento fluido.
5. **Versionamento e Deploy**:
   - Commit semântico das alterações.
   - Push para `origin/main`.
   - Rebuild do container Docker de frontend na VPS Oracle (`oraclevps2`).
   - Verificação em tempo real da URL de produção (`https://financeiro.bssaude.com.br/`).
6. **Autorização**: O agente está autorizado a proceder autonomamente com decisões reversíveis e dentro deste escopo aprovado.

---

## Verification Plan

### Automated Tests
- `npm test`: Execução da suíte completa de testes unitários (Vitest).
- `npm run lint`: Checagem rigorosa de tipagem e boas práticas ESLint.
- `npm run build`: Validação da compilação estática do Next.js.

### Manual & Visual Verification
- Verificação do botão "Espelho da fatura" na aba de Cartões (não mais cinza/quadrado).
- Verificação do botão de ação principal ("Nova Transação", "Adicionar conta") nos cabeçalhos.
- Verificação dos botões de ação e exportação em Relatórios.
- Verificação do componente interativo `GradientMenu`.
- Teste de produção com `curl` e navegação no site oficial.
