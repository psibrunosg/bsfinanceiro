# BS Financeiro

Planejador e controlador financeiro visual, simples e preparado para múltiplos usuários com dados privados.

## Começar
Requer Node.js 22 ou superior.

1. Copie `.env.example` para `.env.local`.
2. Preencha a publishable key disponível em Project Settings > API Keys. Nunca use `service_role` no cliente.
3. Execute `npm install` e `npm run dev`.
4. Para teste completo de cadastro, confirme o e-mail do usuário antes de tentar login.

## Verificação
Use `npm run lint`, `npm test` e `npm run build` antes de integrar mudanças.
Use `supabase/rls-smoke-test.sql` para conferir isolamento básico de RLS no banco remoto vinculado.

## Banco
O projeto Supabase é `wgntlhzjyriwhncumjsv`, o mesmo ref usado em `.env.example`. Em 15/07/2026, o banco remoto foi resetado e recriado a partir das oito migrations locais em `supabase/migrations`. As tabelas de RH que estavam no schema `public` foram removidas no reset. Os advisors de segurança e desempenho não apontaram issues após a recriação.

## Estado atual
- Dashboard responsivo com temas claro/escuro e dados reais do Supabase.
- PWA básica.
- Cliente Supabase browser e server configurados com sessão SSR.
- Rotas de login, cadastro, callback de confirmação e logout.
- Middleware protege o dashboard e valida tokens com `getClaims()`.
- Migrations para contas, categorias, transações, compromissos fixos, cartões, faturas, parcelas, orçamentos e metas, com RLS por proprietário.
- Banco remoto resetado e recriado apenas com as migrations financeiras.
- RLS validado no banco remoto com dois usuários simulados em transação com rollback.
- Telas e ações para onboarding, contas, categorias, movimentações, cartões, compromissos e planejamento.
- A navegação mostra apenas rotas disponíveis no app.

## Plano de desenvolvimento
O plano priorizado está em [ROADMAP.md](./ROADMAP.md). O próximo passo é validar o fluxo real de cadastro, onboarding e primeiro lançamento financeiro.
