-- A migration inicial (20260712230000) já concedia UPDATE/DELETE em
-- transactions para authenticated, mas o projeto vivo nunca teve o
-- privilégio (has_table_privilege confirmava upd=false, del=false).
-- Sem isso, qualquer UPDATE/DELETE direto em transactions falha com
-- 42501 mesmo passando pela RLS. Reaplica de forma idempotente.
grant update, delete on public.transactions to authenticated;
