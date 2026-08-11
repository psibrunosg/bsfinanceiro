export type Workspace = { id: string; name: string };
export type WorkspacePreference = {
  default_cash_account_id: string | null;
  default_context_id: string | null;
  default_period: string;
  hide_values: boolean;
  compact_mode: boolean;
  personal_color: string | null;
  clinic_color: string | null;
  default_category_id: string | null;
  default_appointment_value: number;
  default_billing_deadline_days: number;
  alert_overdue_earnings: boolean;
  alert_stale_quotes: boolean;
  theme: string | null;
};
export type Account = {
  id: string;
  name: string;
  type: string;
  initial_balance: number;
};
export type Category = {
  id: string;
  name: string;
  kind: string;
  color?: string | null;
};
export type Card = {
  id: string;
  account_id?: string;
  name: string;
  brand?: string | null;
  last_four?: string | null;
  credit_limit: number;
  closing_day: number;
  due_day: number;
};
export type Invoice = {
  id: string;
  credit_card_id?: string;
  due_date: string;
  status: string;
  credit_card_installments?:
    | {
        amount: number;
        installment_number: number;
        credit_card_purchases?:
          | { description: string; installment_count: number }
          | { description: string; installment_count: number }[]
          | null;
      }[]
    | null;
};
export type Transaction = {
  id: string;
  account_id: string;
  destination_account_id: string | null;
  type: string;
  status: string;
  description: string;
  amount: number;
  competence_date: string;
  category_id?: string | null;
};
export type StatementImport = {
  id: string;
  file_name: string;
  status: "pending" | "processing" | "pending_review" | "imported" | "failed";
  error_code: string | null;
  declared_total_cents?: number | null;
  credit_card_statement_import_items?: StatementImportItem[];
  created_at: string;
};
export type StatementImportItem = {
  ordinal: number;
  purchased_on: string;
  description: string;
  installment_amount_cents: number;
  installment_number: number;
  installment_count: number;
  total_amount_cents: number | null;
  needs_review: boolean;
  source_fingerprint: string;
};
export type TransactionImportItem = {
  id: string;
  batch_id: string;
  row_number: number;
  competence_date: string | null;
  description: string | null;
  amount_cents: number | null;
  type: "income" | "expense" | null;
  status: "ready" | "duplicate" | "invalid";
  reason: string | null;
  fingerprint: string | null;
  transaction_id: string | null;
  created_at: string;
};
export type TransactionImportBatch = {
  id: string;
  account_id: string;
  file_name: string;
  status: "pending" | "applied" | "discarded";
  created_at: string;
  applied_at: string | null;
  discarded_at: string | null;
  transaction_import_items: TransactionImportItem[];
};
export type Budget = {
  id: string;
  category_id: string;
  amount: number;
};
export type Goal = {
  id: string;
  name: string;
  target_amount: number;
  current_amount: number;
  deadline: string | null;
  status: string;
};
export type Commitment = {
  id: string;
  description: string;
  amount: number;
  due_day: number;
  account_id: string | null;
  category_id: string | null;
};
export type Occurrence = {
  id: string;
  fixed_commitment_id: string;
  description: string;
  amount: number;
  due_date: string;
  status: string;
  paid_at: string | null;
};
export type AlertPreference = {
  id: string;
  budget_alerts: boolean;
  goal_alerts: boolean;
  fixed_commitment_alerts: boolean;
  credit_card_alerts: boolean;
  low_balance_alerts: boolean;
  weekly_digest: boolean;
  budget_warning_percent: number;
  low_balance_amount: number;
  weekly_digest_day: number;
};

export const ACCOUNT_TYPE_LABEL: Record<string, string> = {
  checking: "Conta bancária",
  cash: "Dinheiro",
  savings: "Poupança",
  credit_card: "Cartão de Crédito",
  investment: "Investimento",
};

export const CATEGORY_KIND_LABEL: Record<string, string> = {
  expense: "Despesa",
  income: "Receita",
};
