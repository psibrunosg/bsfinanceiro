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
- [ ] Adicionar link "Compromissos" na navegação principal.
- [ ] Adicionar link "Configurações" na navegação.
- [ ] Verificar que todas as rotas têm `page.tsx` e renderizam o componente correto.

### 2.3 Validar cartões com dados reais
- [ ] Criar conta do tipo `credit_card` → vincular ao cartão.
- [ ] Registrar compra parcelada → verificar que faturas são geradas corretamente.
- [ ] Pagar fatura → verificar que transação é criada e fatura muda para `paid`.

### 2.4 Validar compromissos fixos
- [ ] Criar compromisso com `due_day` dentro do mês atual → verificar ocorrência materializada.
- [ ] Pagar ocorrência → verificar que transação é criada e status muda para `paid`.
- [ ] Criar compromisso com `due_day` 31 em mês com 30 dias → verificar clamping.

### 2.5 Validar orçamento e metas
- [ ] Criar orçamento para uma categoria → registrar despesa nessa categoria → verificar consumo.
- [ ] Criar meta com valor inicial → registrar aporte → verificar progresso.
- [ ] Atingir valor da meta → verificar que status muda para `completed`.

### 2.6 Configurações
- [ ] Implementar tela de preferências de alertas (ler/salvar `alert_preferences`).
- [ ] Implementar logout funcional na página de configurações.

## P3. Preparar uma primeira liberação

### 3.1 Testes
- [ ] Testes de integração para fluxo de autenticação (login, cadastro, callback).
- [ ] Testes de componente para formulários críticos (transação, cartão, compromisso).
- [ ] Cobrir com testes as funções de `src/lib/finance/` que ainda não têm cobertura total.
- [ ] Meta: `npm test` sem falhas, cobertura mínima nos caminhos críticos.

### 3.2 Qualidade
- [ ] `npm run lint` sem warnings.
- [ ] `npm run build` sem erros em produção.
- [ ] Revisar tipos TypeScript — eliminar `any` e `unknown` desnecessários.

### 3.3 PWA
- [ ] Verificar `manifest.webmanifest` com ícones corretos.
- [ ] Testar instalação em Android (Chrome) e iOS (Safari).
- [ ] Verificar que offline básico funciona para páginas estáticas.
- [ ] Corrigir problemas que impedirem uso básico como PWA.

### 3.4 Segurança
- [ ] Remover fallback de chave Supabase hardcoded em `client.ts`.
- [ ] Verificar que `service_role` nunca é usado no cliente.
- [ ] Revisar que todas as RPCs têm `revoke` de `public` e `anon`.

## Depois da primeira liberação

Importação de extrato, Open Finance, alertas push, relatórios avançados e exportação de dados ficam fora do ciclo atual. Só entram quando o fluxo básico estiver estável com dados reais.
