-- Compatibilidade da importação de extratos para a API VPS.
-- Se a instalação ainda usa o schema legado, preserva as tabelas antigas
-- com sufixo _legacy e cria o contrato novo usado pelo frontend.

DO $$
BEGIN
  IF to_regclass('public.transaction_import_batches') IS NOT NULL
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = 'public'
         AND table_name = 'transaction_import_batches'
         AND column_name = 'file_name'
     ) THEN

    IF to_regclass('public.transaction_import_items_legacy') IS NULL
       AND to_regclass('public.transaction_import_items') IS NOT NULL THEN
      ALTER TABLE public.transaction_import_items
        RENAME TO transaction_import_items_legacy;
    END IF;

    IF to_regclass('public.transaction_import_batches_legacy') IS NULL THEN
      ALTER TABLE public.transaction_import_batches
        RENAME TO transaction_import_batches_legacy;
    END IF;
  END IF;
END
$$;

CREATE TABLE IF NOT EXISTS public.transaction_import_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES public.accounts(id) ON DELETE RESTRICT,
  file_name VARCHAR(255) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'applied', 'discarded')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  applied_at TIMESTAMPTZ,
  discarded_at TIMESTAMPTZ,
  CHECK (
    (status = 'pending' AND applied_at IS NULL AND discarded_at IS NULL)
    OR (status = 'applied' AND applied_at IS NOT NULL AND discarded_at IS NULL)
    OR (status = 'discarded' AND applied_at IS NULL AND discarded_at IS NOT NULL)
  )
);
CREATE TABLE IF NOT EXISTS public.transaction_import_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  batch_id UUID NOT NULL REFERENCES public.transaction_import_batches(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  row_number INTEGER NOT NULL CHECK (row_number > 0),
  competence_date DATE,
  description VARCHAR(160),
  amount_cents BIGINT,
  type VARCHAR(20),
  status VARCHAR(20) NOT NULL
    CHECK (status IN ('ready', 'duplicate', 'invalid')),
  reason TEXT,
  fingerprint TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  transaction_id UUID REFERENCES public.transactions(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (batch_id, row_number),
  CHECK (type IS NULL OR type IN ('income', 'expense')),
  CHECK (amount_cents IS NULL OR amount_cents > 0),
  CHECK (
    (
      status IN ('ready', 'duplicate')
      AND competence_date IS NOT NULL
      AND description IS NOT NULL
      AND amount_cents IS NOT NULL
      AND type IS NOT NULL
      AND NULLIF(TRIM(fingerprint), '') IS NOT NULL
    )
    OR (
      status = 'invalid'
      AND NULLIF(TRIM(reason), '') IS NOT NULL
    )
  ),
  CHECK (transaction_id IS NULL OR status = 'ready')
);

CREATE INDEX IF NOT EXISTS idx_transaction_import_batches_workspace_status
  ON public.transaction_import_batches(workspace_id, owner_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_transaction_import_items_batch_status
  ON public.transaction_import_items(batch_id, status, row_number);
