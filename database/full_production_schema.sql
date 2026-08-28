-- ==============================================================================
-- BS Financeiro - Schema de Produção Completo e Consolidado (PostgreSQL na VPS)
-- Contempla todos os 20 Módulos e Funcionalidades do Sistema
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Tipos Enumerados
DO $$ BEGIN
    CREATE TYPE account_type AS ENUM ('checking', 'cash', 'savings', 'credit_card', 'investment');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE transaction_type AS ENUM ('income', 'expense', 'transfer');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE transaction_status AS ENUM ('planned', 'pending', 'paid', 'cancelled');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. Usuários e Autenticação
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Perfis
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    theme_preference VARCHAR(30) DEFAULT 'system',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Workspaces (Pessoal, Clínica / PJ, Casal)
CREATE TABLE IF NOT EXISTS workspaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    kind VARCHAR(20) NOT NULL DEFAULT 'personal' CHECK (kind IN ('personal', 'family', 'business', 'couple')),
    currency CHAR(3) NOT NULL DEFAULT 'BRL',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id, owner_id)
);

-- 5. Preferências de Workspace
CREATE TABLE IF NOT EXISTS workspace_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    default_cash_account_id UUID,
    primary_color VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, owner_id)
);

-- 6. Preferências de Alertas (Radar de Juros, Faturas, Assinaturas)
CREATE TABLE IF NOT EXISTS alert_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interest_alerts BOOLEAN DEFAULT true,
    invoice_closing_alerts BOOLEAN DEFAULT true,
    subscription_alerts BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, owner_id)
);

-- 7. Contextos Financeiros (Pessoal, Empresa, Casal, Projetos)
CREATE TABLE IF NOT EXISTS financial_contexts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kind VARCHAR(30) NOT NULL DEFAULT 'personal',
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#0ea5e9',
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Contas Bancárias e Carteiras
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type account_type NOT NULL DEFAULT 'checking',
    initial_balance NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    active BOOLEAN NOT NULL DEFAULT true,
    is_system BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id, workspace_id, owner_id)
);

-- 9. Categorias
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    kind transaction_type NOT NULL CHECK (kind <> 'transfer'),
    color VARCHAR(20) DEFAULT '#8b5cf6',
    budget_limit NUMERIC(14, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (id, workspace_id, owner_id)
);

-- 10. Cartões de Crédito
CREATE TABLE IF NOT EXISTS credit_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100),
    closing_day SMALLINT NOT NULL CHECK (closing_day BETWEEN 1 AND 31),
    due_day SMALLINT NOT NULL CHECK (due_day BETWEEN 1 AND 31),
    limit_amount NUMERIC(14, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Faturas de Cartão (Invoices)
CREATE TABLE IF NOT EXISTS credit_card_invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'closed', 'paid')),
    total_amount NUMERIC(14, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. Movimentações Financeiras (Transações)
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    destination_account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    invoice_id UUID REFERENCES credit_card_invoices(id) ON DELETE SET NULL,
    type transaction_type NOT NULL,
    status transaction_status NOT NULL DEFAULT 'paid',
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    interest_amount NUMERIC(14, 2) DEFAULT 0.00,
    competence_date DATE NOT NULL,
    due_date DATE,
    paid_at DATE,
    installment_current INTEGER,
    installment_total INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. Compromissos Fixos e Assinaturas
CREATE TABLE IF NOT EXISTS fixed_commitments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    due_day SMALLINT NOT NULL CHECK (due_day BETWEEN 1 AND 31),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. Ocorrências de Compromissos Fixos
CREATE TABLE IF NOT EXISTS fixed_commitment_occurrences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    commitment_id UUID NOT NULL REFERENCES fixed_commitments(id) ON DELETE CASCADE,
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    month_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'skipped')),
    transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. Orçamentos Mensais (Envelopes Virtuais / YNAB Style)
CREATE TABLE IF NOT EXISTS monthly_budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    category_kind VARCHAR(20) NOT NULL DEFAULT 'expense',
    month DATE NOT NULL,
    amount NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, owner_id, category_id, month)
);

-- 16. Metas Financeiras (Sonhos / Motor CDI)
CREATE TABLE IF NOT EXISTS financial_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    target_amount NUMERIC(14, 2) NOT NULL CHECK (target_amount > 0),
    current_amount NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    deadline DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    color VARCHAR(20) DEFAULT '#10b981',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 17. Aportes em Metas
CREATE TABLE IF NOT EXISTS goal_contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    financial_goal_id UUID NOT NULL REFERENCES financial_goals(id) ON DELETE CASCADE,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    note VARCHAR(255),
    idempotency_key VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 18. Módulo Clínica / Psicologia (Pacientes e Sessões)
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    session_price NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    payment_day SMALLINT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 19. Módulo Investimentos (Ativos e Operações)
CREATE TABLE IF NOT EXISTS investment_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ticker VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(30) NOT NULL DEFAULT 'stock' CHECK (type IN ('stock', 'reit', 'fund', 'cdb', 'treasury', 'crypto')),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS investment_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    asset_id UUID NOT NULL REFERENCES investment_assets(id) ON DELETE CASCADE,
    operation_type VARCHAR(20) NOT NULL CHECK (operation_type IN ('buy', 'sell', 'dividend', 'yield')),
    quantity NUMERIC(14, 6) NOT NULL DEFAULT 0,
    unit_price NUMERIC(14, 4) NOT NULL DEFAULT 0,
    operation_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 20. Importação de Extratos e Conciliação
CREATE TABLE IF NOT EXISTS transaction_import_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    filename VARCHAR(255),
    total_items INTEGER DEFAULT 0,
    imported_items INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transaction_import_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES transaction_import_batches(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    amount NUMERIC(14, 2) NOT NULL,
    suggested_category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'imported', 'ignored')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices de Alta Performance
CREATE INDEX IF NOT EXISTS idx_workspaces_owner ON workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_accounts_workspace ON accounts(workspace_id, owner_id);
CREATE INDEX IF NOT EXISTS idx_categories_workspace ON categories(workspace_id, owner_id);
CREATE INDEX IF NOT EXISTS idx_transactions_workspace_date ON transactions(workspace_id, owner_id, competence_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_commitments_workspace ON fixed_commitments(workspace_id, owner_id);
CREATE INDEX IF NOT EXISTS idx_budgets_workspace ON monthly_budgets(workspace_id, owner_id, month);
CREATE INDEX IF NOT EXISTS idx_goals_workspace ON financial_goals(workspace_id, owner_id);
CREATE INDEX IF NOT EXISTS idx_investments_workspace ON investment_assets(workspace_id, owner_id);
