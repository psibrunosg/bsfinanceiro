# Roadmap

Atualizado em 24/07/2026.

## Situação confirmada

O projeto Supabase do BS Financeiro é `wgntlhzjyriwhncumjsv`, que também aparece em `.env.example`. Em 15/07/2026, o banco remoto foi resetado e recriado a partir das oito migrations financeiras locais. As tabelas de RH que estavam misturadas no schema `public` foram removidas no reset. Depois da recriação, os advisors de segurança e desempenho não apontaram issues.

## P0. Vincular e validar o banco — Concluído

1. Banco remoto vinculado, resetado e recriado apenas com as migrations financeiras.
2. Histórico remoto alinhado com as oito migrations locais.
3. Advisors de segurança e desempenho sem issues.
4. RLS validado com dois usuários simulados em `supabase/rls-smoke-test.sql`.
5. Validação de produção pela interface: cadastro, login, onboarding, conta, categoria e primeira movimentação.

## P1. Colocar o fluxo financeiro em uso real — Concluído

1. Dashboard busca saldos, receitas, despesas e próximos vencimentos no banco.
2. Login e cadastro carregam com `.env.local` apontando para o Supabase remoto.
3. Cadastro via Supabase Auth cria usuário com confirmação de e-mail.
4. Percurso confirmado: e-mail, login, onboarding, conta, movimentação e dashboard.
5. Segundo usuário confirmado sem cruzamento de dados.
6. Estados vazios e erros claros nas telas principais.
7. Navegação sem links para rotas não implementadas.

## P2. Fechar os ciclos financeiros já modelados — Em andamento

### 2.1 Refatorar componentes
- [x] Extrair `finance-client.tsx` monolítico em componentes por página.
- [x] Criar componente `DashboardPage` (resumo + cards + movs recentes).
- [x] Criar componente `AccountsPage` (lista + formulário).
- [x] Criar componente `CategoriesPage` (lista + formulário).
- [x] Criar componente `TransactionsPage` (lista + formulário).
- [x] Criar componente `CardsPage` (lista + faturas + formulário).
- [x] Criar componente `CardDetailPage` (faturas + compras).
- [x] Criar componente `CommitmentsPage` (compromissos + ocorrências + pagamento).
- [x] Criar componente `PlanningPage` (orçamento + metas).
- [x] Criar componente `SettingsPage` funcional (preferências de alertas).
- [x] Extrair componentes compartilhados (`Nav`, `PageHeader`, `EmptyState`, `SimpleForm`).

### 2.2 Navegação e rotas
- [x] Adicionar link "Compromissos" na navegação principal.
- [x] Adicionar link "Configurações" na navegação.
- [x] Verificar que todas as rotas têm `page.tsx` e renderizam o componente correto.

### 2.3 Validar cartões com dados reais
- [ ] Criar conta do tipo `credit_card` → vincular ao cartão.
- [ ] Registrar compra parcelada → verificar que faturas são geradas corretamente.
- [ ] Pagar fatura → verificar que transação é criada e fatura muda para `paid`.

> **Script de validação:** `supabase/validation/P2_3_credit_cards.sql` — execute no SQL Editor do Supabase.

### 2.4 Validar compromissos fixos
- [ ] Criar compromisso com `due_day` dentro do mês atual → verificar ocorrência materializada.
- [ ] Pagar ocorrência → verificar que transação é criada e status muda para `paid`.
- [ ] Criar compromisso com `due_day` 31 em mês com 30 dias → verificar clamping.

> **Script de validação:** `supabase/validation/P2_4_commitments.sql` — execute no SQL Editor do Supabase.

### 2.5 Validar orçamento e metas
- [ ] Criar orçamento para uma categoria → registrar despesa nessa categoria → verificar consumo.
- [ ] Criar meta com valor inicial → registrar aporte → verificar progresso.
- [ ] Atingir valor da meta → verificar que status muda para `completed`.

> **Script de validação:** `supabase/validation/P2_5_budgets_goals.sql` — execute no SQL Editor do Supabase.

### 2.6 Configurações
- [x] Implementar tela de preferências de alertas (ler/salvar `alert_preferences`).
- [x] Implementar logout funcional na página de configurações.

## P3. Preparar uma primeira liberação

### 3.1 Testes
- [ ] Testes de integração para fluxo de autenticação (login, cadastro, callback).
- [ ] Testes de componente para formulários críticos (transação, cartão, compromisso).
- [x] Cobrir com testes as funções de `src/lib/finance/` que ainda não têm cobertura total.
- [x] Meta: `npm test` sem falhas, cobertura mínima nos caminhos críticos. (52 testes, 7 arquivos)

### 3.2 Qualidade
- [x] `npm run lint` sem warnings.
- [x] `npm run build` sem erros em produção.
- [ ] Revisar tipos TypeScript — eliminar `any` e `unknown` desnecessários.

### 3.3 PWA
- [x] Verificar `manifest.webmanifest` com ícones corretos.
- [ ] Testar instalação em Android (Chrome) e iOS (Safari).
- [ ] Verificar que offline básico funciona para páginas estáticas.
- [ ] Corrigir problemas que impedirem uso básico como PWA.

### 3.4 Segurança
- [x] Remover fallback de chave Supabase hardcoded em `client.ts`.
- [x] Verificar que `service_role` nunca é usado no cliente.
- [x] Revisar que todas as RPCs têm `revoke` de `public` e `anon`. (8/8 RPCs com revoke)

## Depois da primeira liberação — Plano de features inspiradas no mercado

Baseado em pesquisa dos principais apps brasileiros (Mobills, Organizze, Guiabolso, Minhas Economias, Financinha) e projetos open source (Actual Budget, Firefly III, MoneyMatter, Cashew), além de tendências de UX fintech 2026.

### Fase 4. Visualização de dados e gráficos

> **Inspiração:** Mobills (gráficos interativos), Organizze (relatórios de evolução), Guiabolso (diagnóstico financeiro)

- [ ] **Dashboard com gráficos interativos** — Gráfico de pizza (gastos por categoria), barra (receitas vs despesas mensais), linha (evolução do saldo nos últimos 6 meses).
- [ ] **Relatório mensal comparativo** — "Em relação ao mês passado, seus gastos com alimentação diminuíram 12%". Data storytelling, não apenas números.
- [ ] **Gráfico de fluxo de caixa** — Visualização semanal/mensal de entradas vs saídas com saldo projetado.
- [ ] **Resumo por categoria** — Top 5 categorias de despesa com percentual e valor, comparativo mês a mês.
- [ ] **Evolução de metas** — Barra de progresso visual com previsão de conclusão baseada no ritmo atual.

### Fase 5. Alertas e notificações inteligentes

> **Inspiração:** Mobills (alerta de fatura), Organizze (limite por categoria), Financinha (alertas via WhatsApp)

- [ ] **Alerta de orçamento 80%** — Notificação quando uma categoria atingir 80% do limite mensal.
- [ ] **Alerta de fatura próxima do vencimento** — 3 dias antes do vencimento da fatura do cartão.
- [ ] **Alerta de compromisso fixo** — 2 dias antes do vencimento de contas fixas.
- [ ] **Alerta de meta atingida** — Celebração quando completar 100% de uma meta financeira.
- [ ] **Resumo semanal automático** — Domingo à noite: resumo do semana (gastos, receitas, saldo).
- [ ] **Alerta de saldo baixo** — Quando o saldo de uma conta cair abaixo do limite configurado.
- [ ] **Notificações push** — Web Push API para notificações mesmo com o app fechado.

### Fase 6. Importação de dados

> **Inspiração:** Organizze (importação OFX/CSV), Mobills (sync bancário), Minhas Economias (importação manual)

- [ ] **Importação de extrato OFX** — Upload de arquivo OFX gerado pelo internet banking.
- [ ] **Importação de CSV** — Upload de planilha com colunas mapeáveis (data, valor, descrição, categoria).
- [ ] **Categorização automática por regras** — "Se a descrição contém 'iFood', categorizar como 'Alimentação'".
- [ ] **Mapeamento inteligente de categorias** — Sugerir categorias baseado em descrições históricas.
- [ ] **Deduplicação de transações** — Evitar duplicatas ao importar o mesmo extrato duas vezes.
- [ ] **Preview antes de importar** — Mostrar transações que serão importadas antes de confirmar.

### Fase 7. Exportação e relatórios

> **Inspiração:** Organizze (export CSV/PDF), Mobills (relatórios premium), Minhas Economias (relatórios detalhados)

- [ ] **Exportar transações em CSV** — Filtro por período, categoria, tipo e conta.
- [ ] **Exportar transações em PDF** — Relatório formatado com gráficos e resumo.
- [ ] **Relatório anual** — Resumo de 12 meses: total recebido, total gasto, saldo, top categorias.
- [ ] **Relatório por período personalizado** — Selecionar período livre (ex: 15/03 a 20/06).
- [ ] **Relatório de imposto de renda** — Resumo de despesas dedutíveis por categoria (saúde, educação, moradia).
- [ ] **Compartilhar relatório** — Gerar link temporário para compartilhar resumo com contador ou parceiro.

### Fase 8. Controle de dívidas e parcelamentos

> **Inspiração:** Mobills (módulo de dívidas), Organizze (acompanhamento de parcelas)

- [ ] **Painel de dívidas** — Lista de todas as dívidas ativas com saldo devedor, parcela mensal e previsão de quitação.
- [ ] **Simulação de quitação antecipada** — "Se eu pagar R$ 200 a mais por mês, quito em X meses e economizo R$ Y de juros."
- [ ] **Hierarquia de dívidas** — Método snowball (menor saldo primeiro) ou avalanche (maior juros primeiro).
- [ ] **Gráfico de progresso de quitação** — Visualização do saldo devedor caindo mês a mês.
- [ ] **Alerta de parcela próxima** — Notificação antes do vencimento de cada parcela.

### Fase 9. Compartilhamento familiar

> **Inspiração:** Organizze (contas compartilhadas), Mobills (modo família), Financinha (controle familiar)

- [ ] **Workspace familiar** — Tipo de workspace "family" com múltiplos membros.
- [ ] **Convite por e-mail** — Convidar cônjuge ou familiar para o workspace.
- [ ] **Permissões por nível** — Admin (tudo), Editor (lançamentos), Visualizador (somente leitura).
- [ ] **Contas compartilhadas** — Contas que todos os membros podem ver e movimentar.
- [ ] **Contas individuais** — Cada membro tem contas privadas que só ele vê.
- [ ] **Dashboard consolidado** — Visão de todas as finanças da família em um só lugar.

### Fase 10. Investimentos e patrimônio

> **Inspiração:** Minhas Economias (controle de investimentos), GhostFolio (portfolio tracking)

- [ ] **Cadastro de investimentos** — Tipo de conta "investment" com sub-tipo (CDB, Tesouro, Ação, Fundo).
- [ ] **Registro de operações** — Compra/venda com quantidade, preço unitário e data.
- [ ] **Cálculo de posição** — Custo médio ponderado (já implementado em `investments.ts`).
- [ ] **Rentabilidade** — Ganho percentual e absoluto por investimento.
- [ ] **Patrimônio líquido total** — Soma de contas + investimentos - dívidas.
- [ ] **Evolução do patrimônio** — Gráfico de linha mostrando crescimento ao longo do tempo.

### Fase 11. UX e design avançado

> **Inspiração:** Fintech UX Best Practices 2026, Fuselab Creative, Eleken

- [ ] **Modo escuro como padrão** — Tema escuro já existe, mas tornar padrão no primeiro acesso.
- [ ] **Onboarding guiado** — Passo a passo interativo no primeiro login (conectar conta, criar categoria, registrar primeira transação).
- [ ] **Widgets PWA** — Widget para tela inicial com saldo e próximo vencimento.
- [ ] **Biometria** — Login biométrico (Face ID / Touch ID) via WebAuthn.
- [ ] **Animações de feedback** — Microinterações: check ao salvar, shake ao erro, confetti ao atingir meta.
- [ ] **Sidebar colapsável** — Em mobile, nav inferior; em desktop, sidebar fixa.
- [ ] **Busca global** — Encontrar transações, categorias ou contas por texto.
- [ ] **Atalhos de teclado** — `N` para nova transação, `K` para nova conta, `/` para buscar.

### Fase 12. Automação e inteligência

> **Inspiração:** Financinha (IA via WhatsApp), Guiabolso (diagnóstico com IA), MoneyMatter (categorização com IA)

- [ ] **Categorização automática por IA** — Modelo simples que aprende com categorizações anteriores.
- [ ] **Detecção de gastos recorrentes** — Identificar automaticamente assinaturas e contas fixas.
- [ ] **Previsão de saldo** — Projetar saldo baseado em compromissos e receitas futuras.
- [ ] **Sugestões de orçamento** — "Baseado nos seus gastos, sugerimos R$ X para Alimentação".
- [ ] **Diagnóstico financeiro** — Score de 0-1000 baseado em regularidade, poupança e comprometimento.
- [ ] **Assistente financeiro** — Chat simples que responde perguntas sobre seus gastos ("Quanto gastei com delivery este mês?").

### Priorização sugerida

| Fase | Impacto | Esforço | Prioridade |
|------|---------|---------|------------|
| 4. Gráficos | Alto | Médio | 🔴 P4 |
| 5. Alertas | Alto | Baixo | 🔴 P4 |
| 6. Importação | Alto | Médio | 🟡 P5 |
| 7. Exportação | Médio | Baixo | 🟡 P5 |
| 8. Dívidas | Alto | Médio | 🟡 P5 |
| 9. Família | Médio | Alto | 🟢 P6 |
| 10. Investimentos | Médio | Médio | 🟢 P6 |
| 11. UX avançado | Médio | Médio | 🟢 P6 |
| 12. Automação | Alto | Alto | ⚪ P7 |

**Recomendação:** Começar pelas Fases 4 e 5 (gráficos + alertas) — são os recursos que mais diferenciais de engagement trazem com menor esforço. Seguidas pela Fase 6 (importação), que é o maior motivo de abandono de apps financeiros (usuários não querem registrar manualmente).
