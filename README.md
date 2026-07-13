# BS Financeiro

Planejador e controlador financeiro visual, simples e preparado para múltiplos usuários com dados privados.

## Começar
Requer Node.js 22 ou superior.

1. Copie `.env.example` para `.env.local`.
2. Preencha a publishable key disponível em Project Settings > API Keys. Nunca use `service_role` no cliente.
3. Execute `npm install` e `npm run dev`.

## Verificação
Use `npm run lint`, `npm test` e `npm run build` antes de integrar mudanças.

## Banco
A migration inicial está em `supabase/migrations`. Ela ainda não foi aplicada remotamente. Quando o Supabase CLI estiver vinculado ao projeto, valide o histórico, aplique em ambiente seguro e execute os advisors de segurança e desempenho.

## Estado atual
- Dashboard responsivo com temas claro/escuro e dados demonstrativos.
- PWA básica.
- Cliente Supabase preparado.
- Migration inicial com contas, categorias, transações, compromissos fixos e RLS por proprietário.
- O schema remoto ainda não foi aplicado.
