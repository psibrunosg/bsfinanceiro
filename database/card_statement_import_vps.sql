-- API owns access checks. Uploaded bytes live only in PHP private request temp storage.
CREATE TABLE IF NOT EXISTS credit_card_purchases (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
 owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, credit_card_id UUID NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
 category_id UUID REFERENCES categories(id) ON DELETE SET NULL, description VARCHAR(160) NOT NULL,
 total_amount NUMERIC(14,2) NOT NULL CHECK(total_amount>0), purchased_on DATE NOT NULL,
 installment_count INTEGER NOT NULL CHECK(installment_count BETWEEN 1 AND 120), notes TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS credit_card_installments (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(), workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
 owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, credit_card_id UUID NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
 purchase_id UUID NOT NULL REFERENCES credit_card_purchases(id) ON DELETE CASCADE,
 invoice_id UUID REFERENCES credit_card_invoices(id) ON DELETE RESTRICT, installment_number INTEGER NOT NULL CHECK(installment_number>0),
 amount NUMERIC(14,2) NOT NULL CHECK(amount>0), competence_date DATE NOT NULL,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(purchase_id,installment_number)
);
CREATE TABLE IF NOT EXISTS credit_card_statement_imports (
 id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
 workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
 owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 credit_card_id UUID NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
 file_name TEXT NOT NULL CHECK (length(file_name) BETWEEN 1 AND 120),
 content_type TEXT NOT NULL, size_bytes INTEGER NOT NULL CHECK(size_bytes BETWEEN 1 AND 5242880),
 sha256 TEXT NOT NULL CHECK(sha256 ~ '^[a-f0-9]{64}$'),
 status TEXT NOT NULL DEFAULT 'pending_review' CHECK(status IN ('pending_review','imported','failed','discarded')),
 error_code TEXT, closing_date DATE, due_date DATE, declared_total_cents BIGINT,
 items JSONB NOT NULL DEFAULT '[]', applied_hash TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT now(), completed_at TIMESTAMPTZ,
 UNIQUE(credit_card_id, sha256)
);
ALTER TABLE credit_card_statement_imports ADD COLUMN IF NOT EXISTS items JSONB NOT NULL DEFAULT '[]';
ALTER TABLE credit_card_statement_imports ADD COLUMN IF NOT EXISTS applied_hash TEXT;
CREATE INDEX IF NOT EXISTS card_statement_import_workspace_idx ON credit_card_statement_imports(workspace_id, created_at DESC);
