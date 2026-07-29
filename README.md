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

### Cenário manual de aceitação: decisão diária

Com uma conta de teste autenticada, percorra o fluxo abaixo para validar a experiência de pessoa física:

1. Crie uma conta corrente ativa e defina-a como conta principal.
2. Registre uma renda planejada futura.
3. Crie um compromisso fixo ainda não pago, com vencimento antes dessa renda.
4. Abra o Painel e confira `Disponível para gastar`, a data da próxima entrada e a explicação da reserva do compromisso.
5. Lance uma despesa pelo registro rápido, informando somente valor e descrição; ela deve usar a conta principal e a data de hoje.
6. Abra Movimentações, pesquise pela descrição e confirme que a despesa aparece no histórico.

O ciclo não inclui importação bancária. A próxima fronteira é importação OFX/CSV com prévia, deduplicação e inbox de revisão.

## Deploy no GitHub Pages
Configure estes Repository secrets em `Settings > Secrets and variables > Actions`:

- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

O workflow usa esses valores somente durante o build estático. Nunca configure `service_role` nesses secrets.

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
