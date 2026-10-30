-- Additive, repeatable migration. Existing PDF paths are preserved.
BEGIN;
CREATE TABLE IF NOT EXISTS payslip_documents (
    payslip_id UUID PRIMARY KEY REFERENCES payslips(id) ON DELETE CASCADE,
    content BYTEA NOT NULL CHECK (octet_length(content) <= 10485760),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
REVOKE ALL ON payslip_documents FROM PUBLIC;
COMMIT;
