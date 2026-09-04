-- Fase 9: Family Workspaces

-- 1. Create tables
CREATE TABLE public.workspace_users (
    id uuid primary key default gen_random_uuid(),
    workspace_id uuid not null references public.workspaces(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,
    role text not null default 'member' check(role in ('admin', 'editor', 'viewer')),
    created_at timestamptz not null default now(),
    unique(workspace_id, user_id)
);
ALTER TABLE public.workspace_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own workspace_users" 
    ON public.workspace_users FOR SELECT 
    USING (user_id = auth.uid() OR workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid()));

CREATE POLICY "Admins can manage workspace_users" 
    ON public.workspace_users FOR ALL 
    USING (EXISTS (
        SELECT 1 FROM public.workspace_users wu 
        WHERE wu.workspace_id = workspace_users.workspace_id 
        AND wu.user_id = auth.uid() 
        AND wu.role = 'admin'
    ));

CREATE TABLE public.workspace_invites (
    id uuid primary key default gen_random_uuid(),
    workspace_id uuid not null references public.workspaces(id) on delete cascade,
    token text not null unique,
    role text not null default 'member' check(role in ('admin', 'editor', 'viewer')),
    expires_at timestamptz not null default (now() + interval '7 days'),
    created_at timestamptz not null default now()
);
ALTER TABLE public.workspace_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage invites" 
    ON public.workspace_invites FOR ALL 
    USING (EXISTS (
        SELECT 1 FROM public.workspace_users wu 
        WHERE wu.workspace_id = workspace_invites.workspace_id 
        AND wu.user_id = auth.uid() 
        AND wu.role = 'admin'
    ));

CREATE POLICY "Anyone authenticated can read invites" 
    ON public.workspace_invites FOR SELECT 
    TO authenticated 
    USING (true);

-- 2. Populate owners
INSERT INTO public.workspace_users (workspace_id, user_id, role)
SELECT id, owner_id, 'admin' FROM public.workspaces;

-- 3. Drop overly strict composite constraints
ALTER TABLE public.accounts DROP CONSTRAINT IF EXISTS accounts_workspace_id_owner_id_fkey;
ALTER TABLE public.categories DROP CONSTRAINT IF EXISTS categories_workspace_id_owner_id_fkey;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_workspace_id_owner_id_fkey;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_account_id_workspace_id_owner_id_fkey;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_category_id_workspace_id_owner_id_fkey;
ALTER TABLE public.transactions DROP CONSTRAINT IF EXISTS transactions_destination_account_id_workspace_id_owner_id_fkey;
ALTER TABLE public.fixed_commitments DROP CONSTRAINT IF EXISTS fixed_commitments_workspace_id_owner_id_fkey;
ALTER TABLE public.fixed_commitments DROP CONSTRAINT IF EXISTS fixed_commitments_account_id_workspace_id_owner_i_fkey;
ALTER TABLE public.fixed_commitments DROP CONSTRAINT IF EXISTS fixed_commitments_category_id_workspace_id_owner__fkey;

-- Replace with simpler single-key constraints
ALTER TABLE public.accounts ADD CONSTRAINT accounts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.categories ADD CONSTRAINT categories_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;
ALTER TABLE public.transactions ADD CONSTRAINT transactions_destination_account_id_fkey FOREIGN KEY (destination_account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;
ALTER TABLE public.fixed_commitments ADD CONSTRAINT fixed_commitments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.fixed_commitments ADD CONSTRAINT fixed_commitments_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;
ALTER TABLE public.fixed_commitments ADD CONSTRAINT fixed_commitments_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;

-- 4. Add is_shared to accounts
ALTER TABLE public.accounts ADD COLUMN is_shared boolean NOT NULL DEFAULT false;

-- Add RLS for shared workspace components
CREATE POLICY "workspaces_family_read" ON public.workspaces FOR SELECT USING (
    id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
);

CREATE POLICY "accounts_family_read" ON public.accounts FOR SELECT USING (
    is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
);
CREATE POLICY "accounts_family_all" ON public.accounts FOR ALL USING (
    is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);

CREATE POLICY "categories_family_read" ON public.categories FOR SELECT USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
);
CREATE POLICY "categories_family_all" ON public.categories FOR ALL USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);

CREATE POLICY "transactions_family_read" ON public.transactions FOR SELECT USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
    AND (account_id IN (SELECT id FROM public.accounts WHERE is_shared = true) OR destination_account_id IN (SELECT id FROM public.accounts WHERE is_shared = true))
);
CREATE POLICY "transactions_family_all" ON public.transactions FOR ALL USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
    AND account_id IN (SELECT id FROM public.accounts WHERE is_shared = true)
);

CREATE POLICY "debts_family_read" ON public.debts FOR SELECT USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
);
CREATE POLICY "debts_family_all" ON public.debts FOR ALL USING (
    workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);

-- 5. RPC to accept invite
CREATE OR REPLACE FUNCTION accept_workspace_invite(invite_token text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    invite_record record;
BEGIN
    SELECT * INTO invite_record FROM public.workspace_invites WHERE token = invite_token AND expires_at > now();
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;

    INSERT INTO public.workspace_users (workspace_id, user_id, role)
    VALUES (invite_record.workspace_id, auth.uid(), invite_record.role)
    ON CONFLICT (workspace_id, user_id) DO NOTHING;

    DELETE FROM public.workspace_invites WHERE id = invite_record.id;

    RETURN true;
END;
$$;

