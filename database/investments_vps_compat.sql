BEGIN;
ALTER TABLE investment_assets ADD COLUMN IF NOT EXISTS broker VARCHAR(100);
ALTER TABLE investment_assets ADD COLUMN IF NOT EXISTS exchange VARCHAR(100);
ALTER TABLE investment_assets DROP CONSTRAINT IF EXISTS investment_assets_type_check;
ALTER TABLE investment_assets ADD CONSTRAINT investment_assets_type_check
    CHECK (type IN ('stock','reit','fund','cdb','treasury','crypto','fixed_income','real_estate'));
ALTER TABLE investment_operations ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE investment_operations ADD COLUMN IF NOT EXISTS transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL;
COMMIT;
