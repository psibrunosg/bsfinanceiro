-- VPS-only: non-destructive onboarding and family invitation compatibility.
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;
-- Existing financial activity proves setup happened before the new marker existed.
-- Empty accounts created during registration do not count as completed onboarding.
UPDATE profiles p SET onboarding_completed_at = NOW()
WHERE p.onboarding_completed_at IS NULL AND EXISTS (
    SELECT 1 FROM workspaces w WHERE w.owner_id = p.id AND w.kind = 'personal'
    AND (EXISTS (SELECT 1 FROM transactions t WHERE t.workspace_id = w.id)
         OR EXISTS (SELECT 1 FROM credit_cards c WHERE c.workspace_id = w.id))
);
CREATE TABLE IF NOT EXISTS workspace_users (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
 user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin','editor','viewer')),
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), UNIQUE(workspace_id,user_id)
);
CREATE TABLE IF NOT EXISTS workspace_invites (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
 token TEXT UNIQUE NOT NULL, role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin','editor','viewer')),
 expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW()+INTERVAL '7 days'), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE workspace_invites ADD COLUMN IF NOT EXISTS accepted_by UUID REFERENCES users(id);
ALTER TABLE workspace_invites ADD COLUMN IF NOT EXISTS accepted_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_workspace_users_user ON workspace_users(user_id);
