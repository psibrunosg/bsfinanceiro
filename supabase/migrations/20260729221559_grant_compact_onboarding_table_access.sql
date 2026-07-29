-- The compact onboarding RPC runs as SECURITY INVOKER. Keep RLS ownership
-- checks in force and grant only the table operations it performs.
grant insert on table public.workspaces, public.transactions to authenticated;
grant update on table public.profiles to authenticated;
