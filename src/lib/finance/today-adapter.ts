import { selectTopAlert, type AlertPreferences, type FinancialAlert } from "./alerts";
import { projectUntilNextIncome, type TodayProjection } from "./today";

type AccountRow = { type: string; initial_balance: number };
type TransactionRow = { type: string; amount: number; competence_date: string };
type PreferenceRow = {
  budget_alerts: boolean;
  goal_alerts: boolean;
  fixed_commitment_alerts: boolean;
  credit_card_alerts: boolean;
  low_balance_alerts: boolean;
  low_balance_amount: number;
} | null;

export type TodayDashboardModel = TodayProjection & {
  currentBalanceCents: number;
  alert: FinancialAlert | null;
};

function toCents(value: number) {
  return Math.round(Number(value || 0) * 100);
}

export function alertPreferencesFromRow(row: PreferenceRow): AlertPreferences {
  return {
    budget: row?.budget_alerts ?? true,
    cashflow: row?.low_balance_alerts ?? true,
    invoice: row?.credit_card_alerts ?? true,
    goal: row?.goal_alerts ?? true,
    recurring: row?.fixed_commitment_alerts ?? true,
  };
}

export function buildTodayDashboard(
  accounts: readonly AccountRow[],
  transactions: readonly TransactionRow[],
  preferences: PreferenceRow,
  today: string,
): TodayDashboardModel {
  const currentBalanceCents = accounts
    .filter((account) => account.type !== "credit_card")
    .reduce((sum, account) => sum + toCents(account.initial_balance), 0);
  const projection = projectUntilNextIncome(
    transactions
      .filter((transaction) => transaction.type === "income" || transaction.type === "expense")
      .map((transaction) => ({
        date: transaction.competence_date,
        type: transaction.type as "income" | "expense",
        amountCents: toCents(transaction.amount),
      })),
    currentBalanceCents,
    today,
  );
  const thresholdCents = toCents(preferences?.low_balance_amount ?? 0);
  const alert: FinancialAlert[] = projection.lowestBalanceCents < thresholdCents
    ? [{
      id: "cashflow-low-balance",
      preference: "cashflow",
      severity: projection.lowestBalanceCents < 0 ? "critical" : "warning",
      impactCents: Math.abs(projection.lowestBalanceCents - thresholdCents),
      dueDate: projection.lowestBalanceDate || today,
    }]
    : [];

  return { currentBalanceCents, ...projection, alert: selectTopAlert(alert, alertPreferencesFromRow(preferences)) };
}
