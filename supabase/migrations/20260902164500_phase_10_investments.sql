-- Migration Phase 10: Fix Investments Schema & RLS for Family Workspaces

-- 1. Alter investment_assets
ALTER TABLE public.investment_assets DROP CONSTRAINT IF EXISTS investment_assets_workspace_id_owner_id_fkey;
ALTER TABLE public.investment_assets ADD CONSTRAINT investment_assets_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.investment_assets ADD COLUMN IF NOT EXISTS is_shared BOOLEAN NOT NULL DEFAULT true;

-- 2. Alter investment_operations
ALTER TABLE public.investment_operations DROP CONSTRAINT IF EXISTS investment_operations_workspace_id_owner_id_fkey;
ALTER TABLE public.investment_operations DROP CONSTRAINT IF EXISTS investment_operations_asset_id_workspace_id_owner_id_fkey;
ALTER TABLE public.investment_operations ADD CONSTRAINT investment_operations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.investment_operations ADD CONSTRAINT investment_operations_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.investment_assets(id) ON DELETE CASCADE;

-- 3. Alter investment_quotes
ALTER TABLE public.investment_quotes DROP CONSTRAINT IF EXISTS investment_quotes_workspace_id_owner_id_fkey;
ALTER TABLE public.investment_quotes DROP CONSTRAINT IF EXISTS investment_quotes_asset_id_workspace_id_owner_id_fkey;
ALTER TABLE public.investment_quotes ADD CONSTRAINT investment_quotes_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;
ALTER TABLE public.investment_quotes ADD CONSTRAINT investment_quotes_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.investment_assets(id) ON DELETE CASCADE;

-- 4. Rewrite RLS Policies for Family Workspaces

-- Drop old strict policies
DROP POLICY IF EXISTS "investment_assets_own" ON public.investment_assets;
DROP POLICY IF EXISTS "investment_operations_own" ON public.investment_operations;
DROP POLICY IF EXISTS "investment_quotes_own" ON public.investment_quotes;

-- RLS: investment_assets
CREATE POLICY "investment_assets_select" ON public.investment_assets FOR SELECT TO authenticated USING (
  owner_id = auth.uid() OR
  (is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid()))
);
CREATE POLICY "investment_assets_insert" ON public.investment_assets FOR INSERT TO authenticated WITH CHECK (
  owner_id = auth.uid() AND
  workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);
CREATE POLICY "investment_assets_update" ON public.investment_assets FOR UPDATE TO authenticated USING (
  owner_id = auth.uid() OR
  (is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor')))
);
CREATE POLICY "investment_assets_delete" ON public.investment_assets FOR DELETE TO authenticated USING (
  owner_id = auth.uid() OR
  (is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role = 'admin'))
);

-- RLS: investment_operations
CREATE POLICY "investment_operations_select" ON public.investment_operations FOR SELECT TO authenticated USING (
  owner_id = auth.uid() OR
  workspace_id IN (SELECT workspace_id FROM public.investment_assets WHERE is_shared = true AND workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid()))
);
CREATE POLICY "investment_operations_insert" ON public.investment_operations FOR INSERT TO authenticated WITH CHECK (
  owner_id = auth.uid() AND
  workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);
CREATE POLICY "investment_operations_update" ON public.investment_operations FOR UPDATE TO authenticated USING (
  owner_id = auth.uid() OR
  workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);
CREATE POLICY "investment_operations_delete" ON public.investment_operations FOR DELETE TO authenticated USING (
  owner_id = auth.uid() OR
  workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid() AND role IN ('admin', 'editor'))
);

-- RLS: investment_quotes
CREATE POLICY "investment_quotes_all" ON public.investment_quotes FOR ALL TO authenticated USING (
  owner_id = auth.uid() OR
  workspace_id IN (SELECT workspace_id FROM public.workspace_users WHERE user_id = auth.uid())
);

-- 5. Drop broken RPCs from Phase 0
DROP FUNCTION IF EXISTS public.register_investment_operation;
DROP FUNCTION IF EXISTS public.get_investment_position;

