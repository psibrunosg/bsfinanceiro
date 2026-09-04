-- Fix infinite recursion in workspace_users RLS policies
-- When workspace_users policies query workspace_users, Postgres triggers error 42P17 (infinite recursion).
-- Using SECURITY DEFINER helper functions avoids RLS recursion because they run with table owner privileges.

-- 1. Helper functions
CREATE OR REPLACE FUNCTION public.get_auth_user_workspaces()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.is_auth_user_workspace_admin(lookup_workspace_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.workspace_users
    WHERE workspace_id = lookup_workspace_id
      AND user_id = auth.uid()
      AND role = 'admin'
  );
$$;

CREATE OR REPLACE FUNCTION public.is_auth_user_workspace_editor_or_admin(lookup_workspace_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.workspace_users
    WHERE workspace_id = lookup_workspace_id
      AND user_id = auth.uid()
      AND role IN ('admin', 'editor')
  );
$$;

GRANT EXECUTE ON FUNCTION public.get_auth_user_workspaces() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_auth_user_workspace_admin(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_auth_user_workspace_editor_or_admin(uuid) TO authenticated;

-- 2. Drop recursive policies on workspace_users and workspace_invites
DROP POLICY IF EXISTS "Users can read own workspace_users" ON public.workspace_users;
DROP POLICY IF EXISTS "Admins can manage workspace_users" ON public.workspace_users;
DROP POLICY IF EXISTS "Admins can manage invites" ON public.workspace_invites;

-- 3. Recreate workspace_users and workspace_invites policies without recursion
CREATE POLICY "Users can read own workspace_users" 
    ON public.workspace_users FOR SELECT 
    USING (user_id = auth.uid() OR workspace_id IN (SELECT public.get_auth_user_workspaces()));

CREATE POLICY "Admins can manage workspace_users" 
    ON public.workspace_users FOR ALL 
    USING (public.is_auth_user_workspace_admin(workspace_id));

CREATE POLICY "Admins can manage invites" 
    ON public.workspace_invites FOR ALL 
    USING (public.is_auth_user_workspace_admin(workspace_id));

-- 4. Optimize family policies on accounts, categories, transactions, debts to use helper functions
DROP POLICY IF EXISTS "accounts_family_read" ON public.accounts;
DROP POLICY IF EXISTS "accounts_family_all" ON public.accounts;
CREATE POLICY "accounts_family_read" ON public.accounts FOR SELECT USING (
    is_shared = true AND workspace_id IN (SELECT public.get_auth_user_workspaces())
);
CREATE POLICY "accounts_family_all" ON public.accounts FOR ALL USING (
    is_shared = true AND public.is_auth_user_workspace_editor_or_admin(workspace_id)
);

DROP POLICY IF EXISTS "categories_family_read" ON public.categories;
DROP POLICY IF EXISTS "categories_family_all" ON public.categories;
CREATE POLICY "categories_family_read" ON public.categories FOR SELECT USING (
    workspace_id IN (SELECT public.get_auth_user_workspaces())
);
CREATE POLICY "categories_family_all" ON public.categories FOR ALL USING (
    public.is_auth_user_workspace_editor_or_admin(workspace_id)
);

DROP POLICY IF EXISTS "transactions_family_read" ON public.transactions;
DROP POLICY IF EXISTS "transactions_family_all" ON public.transactions;
CREATE POLICY "transactions_family_read" ON public.transactions FOR SELECT USING (
    workspace_id IN (SELECT public.get_auth_user_workspaces())
    AND (account_id IN (SELECT id FROM public.accounts WHERE is_shared = true) OR destination_account_id IN (SELECT id FROM public.accounts WHERE is_shared = true))
);
CREATE POLICY "transactions_family_all" ON public.transactions FOR ALL USING (
    public.is_auth_user_workspace_editor_or_admin(workspace_id)
    AND account_id IN (SELECT id FROM public.accounts WHERE is_shared = true)
);

DROP POLICY IF EXISTS "debts_family_read" ON public.debts;
DROP POLICY IF EXISTS "debts_family_all" ON public.debts;
CREATE POLICY "debts_family_read" ON public.debts FOR SELECT USING (
    workspace_id IN (SELECT public.get_auth_user_workspaces())
);
CREATE POLICY "debts_family_all" ON public.debts FOR ALL USING (
    public.is_auth_user_workspace_editor_or_admin(workspace_id)
);
