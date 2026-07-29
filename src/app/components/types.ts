export type Workspace = { id: string; name: string };
export type WorkspacePreference = {
  default_cash_account_id: string | null;
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
};
export type StatementImport = {
  id: string;
  file_name: string;
  status: "pending" | "processing" | "imported" | "failed";
  error_code: string | null;
  created_at: string;
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
