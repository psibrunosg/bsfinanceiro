/**
 * Generate automatic financial insights (pareceres) for the dashboard.
 * All functions are pure — they take data and return text insights.
 */

type Transaction = {
  type: string;
  amount: string | number;
  competence_date: string;
  category_id?: string | null;
};

type Category = {
  id: string;
  name: string;
  kind: string;
};

type Account = {
  id: string;
  name: string;
  initial_balance: number;
};

type Insight = {
  id: string;
  icon: string;
  text: string;
};

/**
 * Generate all insights from available data.
 */
export function generateInsights(
  transactions: Transaction[],
  categories: Category[],
  accounts: Account[],
  currentMonth: string,
): Insight[] {
  const insights: Insight[] = [];

  // 1. Variação vs período anterior
  const variation = comparePeriods(transactions, currentMonth);
  if (variation) insights.push(variation);

  // 2. Maior categoria de gasto
  const topCategory = topExpenseCategory(transactions, categories, currentMonth);
  if (topCategory) insights.push(topCategory);

  // 3. Peso das despesas fixas vs variáveis
  const fixedWeight = fixedExpenseWeight(transactions, currentMonth);
  if (fixedWeight) insights.push(fixedWeight);

  // 4. Saldo das contas
  const accountSummary = accountBalanceSummary(accounts, transactions);
  if (accountSummary) insights.push(accountSummary);

  // 5. Receitas vs despesas do mês
  const ratio = incomeExpenseRatio(transactions, currentMonth);
  if (ratio) insights.push(ratio);

  return insights.slice(0, 4); // Max 4 insights
}

function comparePeriods(
  transactions: Transaction[],
  currentMonth: string,
): Insight | null {
  const current = monthTotals(transactions, currentMonth);
  const prev = previousMonth(transactions, currentMonth);
  if (!prev || prev.total === 0) return null;

  const change = ((current.total - prev.total) / prev.total) * 100;
  if (Math.abs(change) < 5) return null; // Ignore small changes

  const direction = change > 0 ? "aumentaram" : "reduziram";
  const emoji = change > 0 ? "📈" : "📉";
  return {
    id: "period-variation",
    icon: emoji,
    text: `Seus gastos ${direction} ${Math.abs(Math.round(change))}% em relação ao mês anterior.`,
  };
}

function topExpenseCategory(
  transactions: Transaction[],
  categories: Category[],
  currentMonth: string,
): Insight | null {
  const expenses = transactions.filter(
    (t) => t.type === "expense" && t.competence_date >= currentMonth,
  );
  if (expenses.length === 0) return null;

  const byCategory = new Map<string, number>();
  for (const tx of expenses) {
    const catId = tx.category_id ?? "uncategorized";
    byCategory.set(catId, (byCategory.get(catId) ?? 0) + Number(tx.amount));
  }

  let topCatId = "";
  let topAmount = 0;
  for (const [catId, amount] of byCategory) {
    if (amount > topAmount) {
      topCatId = catId;
      topAmount = amount;
    }
  }

  if (topAmount === 0) return null;

  const catName = categories.find((c) => c.id === topCatId)?.name ?? "Sem categoria";
  const total = expenses.reduce((sum, t) => sum + Number(t.amount), 0);
  const percent = Math.round((topAmount / total) * 100);

  return {
    id: "top-category",
    icon: "🏷️",
    text: `"${catName}" é sua maior categoria de gasto (${percent}% do total).`,
  };
}

function fixedExpenseWeight(
  transactions: Transaction[],
  currentMonth: string,
): Insight | null {
  const expenses = transactions.filter(
    (t) => t.type === "expense" && t.competence_date >= currentMonth,
  );
  if (expenses.length === 0) return null;

  // Heuristic: transactions with fixed amounts (recurring) are "fixed"
  // For now, just report total expense ratio
  const total = expenses.reduce((sum, t) => sum + Number(t.amount), 0);
  const income = transactions
    .filter((t) => t.type === "income" && t.competence_date >= currentMonth)
    .reduce((sum, t) => sum + Number(t.amount), 0);

  if (income === 0) return null;

  const expenseRatio = Math.round((total / income) * 100);
  if (expenseRatio > 100) {
    return {
      id: "expense-ratio-high",
      icon: "⚠️",
      text: `Suas despesas representam ${expenseRatio}% das receitas deste mês.`,
    };
  }
  if (expenseRatio < 60) {
    return {
      id: "expense-ratio-low",
      icon: "✅",
      text: `Boa! Suas despesas são apenas ${expenseRatio}% das receitas.`,
    };
  }
  return null;
}

function accountBalanceSummary(
  accounts: Account[],
  transactions: Transaction[],
): Insight | null {
  if (accounts.length === 0) return null;
  const totalBalance = accounts.reduce((sum, a) => sum + Number(a.initial_balance), 0);
  const txDelta = transactions.reduce(
    (sum, t) => sum + (t.type === "income" ? Number(t.amount) : t.type === "expense" ? -Number(t.amount) : 0),
    0,
  );
  const finalBalance = totalBalance + txDelta;

  return {
    id: "account-balance",
    icon: "💰",
    text: `Saldo total das contas: ${formatBRL(finalBalance)}.`,
  };
}

function incomeExpenseRatio(
  transactions: Transaction[],
  currentMonth: string,
): Insight | null {
  const income = transactions
    .filter((t) => t.type === "income" && t.competence_date >= currentMonth)
    .reduce((sum, t) => sum + Number(t.amount), 0);
  const expense = transactions
    .filter((t) => t.type === "expense" && t.competence_date >= currentMonth)
    .reduce((sum, t) => sum + Number(t.amount), 0);

  if (income === 0 && expense === 0) return null;

  return {
    id: "income-expense-summary",
    icon: "📊",
    text: `Este mês: ${formatBRL(income)} em entradas e ${formatBRL(expense)} em saídas.`,
  };
}

function monthTotals(transactions: Transaction[], month: string) {
  const filtered = transactions.filter(
    (t) => t.competence_date >= month && t.type === "expense",
  );
  return {
    total: filtered.reduce((sum, t) => sum + Number(t.amount), 0),
  };
}

function previousMonth(transactions: Transaction[], currentMonth: string): { total: number } | null {
  const d = new Date(currentMonth);
  d.setMonth(d.getMonth() - 1);
  const prev = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-01`;
  const prevExpenses = transactions.filter(
    (t) => t.competence_date >= prev && t.competence_date < currentMonth && t.type === "expense",
  );
  if (prevExpenses.length === 0) return null;
  return {
    total: prevExpenses.reduce((sum, t) => sum + Number(t.amount), 0),
  };
}

function formatBRL(value: number): string {
  return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(value / 100);
}
