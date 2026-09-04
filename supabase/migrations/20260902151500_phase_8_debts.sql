-- Migration: Phase 8 - Debts Table
-- Cria tabela para controle de dívidas e parcelamentos

CREATE TABLE debts (
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

-- RLS
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view debts in their workspaces"
    ON debts FOR SELECT
    USING (workspace_id IN (
        SELECT id FROM public.workspaces WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can insert debts in their workspaces"
    ON debts FOR INSERT
    WITH CHECK (workspace_id IN (
        SELECT id FROM public.workspaces WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can update debts in their workspaces"
    ON debts FOR UPDATE
    USING (workspace_id IN (
        SELECT id FROM public.workspaces WHERE owner_id = auth.uid()
    ));

CREATE POLICY "Users can delete debts in their workspaces"
    ON debts FOR DELETE
    USING (workspace_id IN (
        SELECT id FROM public.workspaces WHERE owner_id = auth.uid()
    ));

-- Trigger para updated_at
CREATE TRIGGER debts_set_updated_at BEFORE UPDATE ON debts
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

