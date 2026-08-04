/**
 * Pure aggregation functions extracted from DashboardPage and DRE reports.
 * All monetary values are in the original unit (reais, not centavos) for
 * compatibility with the existing useFinance hook which stores amounts as strings.
 */

import {
  isTransferTransaction,
  filterOutTransfers,
  calculateNetCashFlowExcludingTransfers,
  TransferTransaction,
} from "./transfers";

export type Transaction = TransferTransaction;

export type Category = {
  id: string;
  name: string;
  kind: string;
};

export { calculateNetCashFlowExcludingTransfers };

/**
 * Aggregate expenses by category for a given month range.
 * Neutralizes inter-account transfers from category expense calculations.
 * Returns the top N categories sorted by value descending.
 */
export function aggregateExpensesByCategory(
  transactions: Transaction[],
  categories: Category[],
  currentMonth: string,
  topN = 5,
): { label: string; value: number }[] {
  const filteredTxs = transactions.filter((t) => !isTransferTransaction(t, categories));

  return categories
    .filter((c) => c.kind === "expense")
    .map((category) => ({
      label: category.name,
      value: filteredTxs
        .filter((t) => t.type === "expense" && t.competence_date >= currentMonth && t.category_id === category.id)
        .reduce((sum, t) => sum + Number(t.amount), 0),
    }))
    .filter((item) => item.value > 0)
    .sort((a, b) => b.value - a.value)
    .slice(0, topN);
}

/**
 * Compute income vs expense flow for an array of month start dates.
 * Neutralizes inter-account transfers when options.excludeTransfers is true (default).
 * months should be Date objects representing the first day of each month.
 */
export function computeMonthlyFlow(
  transactions: Transaction[],
  months: Date[],
  options: { excludeTransfers?: boolean; categories?: Category[] } = {}
): { flowIn: number[]; flowOut: number[] } {
  const excludeTransfers = options.excludeTransfers ?? true;
  const categories = options.categories ?? [];
  const activeTxs = excludeTransfers ? filterOutTransfers(transactions, categories) : transactions;

  const toKey = (d: Date) =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;

  const flowIn = months.map((month) => {
    const key = toKey(month);
    return activeTxs
      .filter(
        (t) =>
          t.type === "income" &&
          t.competence_date >= `${key}-01` &&
          t.competence_date <= `${key}-31`,
      )
      .reduce((sum, t) => sum + Number(t.amount), 0);
  });

  const flowOut = months.map((month) => {
    const key = toKey(month);
    return activeTxs
      .filter(
        (t) =>
          t.type === "expense" &&
          t.competence_date >= `${key}-01` &&
          t.competence_date <= `${key}-31`,
      )
      .reduce((sum, t) => sum + Number(t.amount), 0);
  });

  return { flowIn, flowOut };
}

/**
 * Compute cumulative balance evolution over months.
 * Starts from the sum of account initial balances.
 * Maintains individual account balance movements correctly.
 */
export function computeEvolution(
  transactions: Transaction[],
  initialBalance: number,
  months: Date[],
): number[] {
  return months.map(
    (month) =>
      transactions
        .filter((t) => t.competence_date <= `${month.getFullYear()}-${String(month.getMonth() + 1).padStart(2, "0")}-31`)
        .reduce(
          (sum, t) =>
            sum +
            (t.type === "income"
              ? Number(t.amount)
              : t.type === "expense"
                ? -Number(t.amount)
                : 0),
          initialBalance,
        ),
  );
}

/**
 * Generate month labels and Date objects for the last N months.
 */
export function lastNMonths(n = 6): { months: Date[]; labels: string[] } {
  const formatter = new Intl.DateTimeFormat("pt-BR", { month: "short" });
  const months = Array.from({ length: n }, (_, index) => {
    const date = new Date();
    date.setMonth(date.getMonth() - (n - 1 - index));
    return date;
  });
  return { months, labels: months.map(formatter.format) };
}

/**
 * Aggregate income by source: payslips, patients, other.
 * Neutralizes inter-account transfer inflows.
 */
export function aggregateIncomeBySource(
  transactions: Transaction[],
  categories: Category[],
): { labels: string[]; values: number[] } {
  const income = transactions.filter(
    (t) => t.type === "income" && !isTransferTransaction(t, categories)
  );

  const byCategory = categories
    .filter((c) => c.kind === "income")
    .map((cat) => ({
      label: cat.name,
      value: income
        .filter((t) => t.category_id === cat.id)
        .reduce((sum, t) => sum + Number(t.amount), 0),
    }))
    .filter((item) => item.value > 0)
    .sort((a, b) => b.value - a.value);

  // If no income categories, group as "Outras receitas"
  if (byCategory.length === 0 && income.length > 0) {
    return {
      labels: ["Outras receitas"],
      values: [income.reduce((sum, t) => sum + Number(t.amount), 0)],
    };
  }

  return {
    labels: byCategory.map((item) => item.label),
    values: byCategory.map((item) => item.value),
  };
}
