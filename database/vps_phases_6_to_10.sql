-- Migração complementar para o PostgreSQL dedicado na VPS (Fases 6 a 10)

CREATE TABLE IF NOT EXISTS transaction_category_rules (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE NOT NULL,
    pattern text NOT NULL,
    category_id uuid REFERENCES categories(id) ON DELETE CASCADE NOT NULL,
    match_type text NOT NULL DEFAULT 'contains' CHECK (match_type IN ('contains', 'starts_with', 'exact', 'regex')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS shared_reports (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    token text NOT NULL UNIQUE,
    workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE NOT NULL,
    data jsonb NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS debts (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    workspace_id uuid REFERENCES workspaces(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    total_amount numeric(15,2) NOT NULL,
    outstanding_balance numeric(15,2) NOT NULL,
    interest_rate_percent_monthly numeric(5,2) DEFAULT 0,
    due_date_day integer NOT NULL CHECK (due_date_day >= 1 AND due_date_day <= 31),
    monthly_installment numeric(15,2) NOT NULL,
    type text NOT NULL CHECK (type IN ('credit_card', 'loan', 'financing', 'other')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS workspace_users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role text NOT NULL DEFAULT 'member' CHECK(role IN ('admin', 'editor', 'viewer')),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(workspace_id, user_id)
);

CREATE TABLE IF NOT EXISTS workspace_invites (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    token text NOT NULL UNIQUE,
    role text NOT NULL DEFAULT 'member' CHECK(role IN ('admin', 'editor', 'viewer')),
    expires_at timestamptz NOT NULL DEFAULT (now() + interval '7 days'),
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO workspace_users (workspace_id, user_id, role)
SELECT id, owner_id, 'admin' FROM workspaces
ON CONFLICT (workspace_id, user_id) DO NOTHING;

ALTER TABLE accounts ADD COLUMN IF NOT EXISTS is_shared boolean DEFAULT false;
ALTER TABLE investment_assets ADD COLUMN IF NOT EXISTS is_shared boolean DEFAULT false;
