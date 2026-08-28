export type MicroExpenseItem = {
  id: string;
  description: string;
  amount: number;
  date: string;
  category?: string | null;
};

export type MicroExpenseVendor = {
  name: string;
  total: number;
  count: number;
};

export type MicroExpenseSummary = {
  threshold: number;
  count: number;
  totalMonthly: number;
  annualizedImpact: number;
  totalExpensesMonth: number;
  percentageOfExpenses: number;
  items: MicroExpenseItem[];
  topVendors: MicroExpenseVendor[];
};

export type MicroSavingsChallengeInput = {
  weeklyTarget: number;
  annualRatePercent?: number; // Padrão: 12% a.a. CDI
};

export type MicroSavingsChallengeResult = {
  weeklyTarget: number;
  monthlyEstimatedSavings: number;
  accumulated1Year: number;
  accumulated3Years: number;
  accumulated5Years: number;
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date: string;
  category_id?: string | null;
};

/**
 * Calcula o resumo de micro-gastos ("gastos formiguinha" <= threshold) no mês.
 */
export function computeMicroExpenseSummary(
  transactions: InputTransaction[],
  month: string, // YYYY-MM
  threshold: number = 30
): MicroExpenseSummary {
  const monthPrefix = month.slice(0, 7);

  let totalExpensesMonth = 0;
  let totalMonthly = 0;
  const items: MicroExpenseItem[] = [];
  const vendorMap = new Map<string, { total: number; count: number }>();

  for (const tx of transactions) {
    const isExpense = !tx.type || tx.type === "expense";
    const datePrefix = (tx.competence_date || "").slice(0, 7);

    if (isExpense && datePrefix === monthPrefix) {
      const amt = Math.abs(Number(tx.amount) || 0);
      totalExpensesMonth += amt;

      if (amt > 0 && amt <= threshold) {
        totalMonthly += amt;
        items.push({
          id: tx.id,
          description: tx.description,
          amount: amt,
          date: tx.competence_date,
          category: tx.category_id,
        });

        const vKey = (tx.description || "Outros").trim();
        const current = vendorMap.get(vKey) || { total: 0, count: 0 };
        current.total += amt;
        current.count += 1;
        vendorMap.set(vKey, current);
      }
    }
  }

  const topVendors: MicroExpenseVendor[] = Array.from(vendorMap.entries())
    .map(([name, data]) => ({
      name,
      total: Math.round(data.total * 100) / 100,
      count: data.count,
    }))
    .sort((a, b) => b.total - a.total)
    .slice(0, 5);

  const percentageOfExpenses =
    totalExpensesMonth > 0
      ? Math.round((totalMonthly / totalExpensesMonth) * 1000) / 10
      : 0;

  return {
    threshold,
    count: items.length,
    totalMonthly: Math.round(totalMonthly * 100) / 100,
    annualizedImpact: Math.round(totalMonthly * 12 * 100) / 100,
    totalExpensesMonth: Math.round(totalExpensesMonth * 100) / 100,
    percentageOfExpenses,
    items,
    topVendors,
  };
}

/**
 * Simula a evolução no CDI caso uma meta semanal de redução de micro-gastos seja atingida e investida.
 */
export function calculateMicroSavingsChallenge(
  input: MicroSavingsChallengeInput
): MicroSavingsChallengeResult {
  const { weeklyTarget, annualRatePercent = 12 } = input;
  // 52 semanas / 12 meses = 4.3333 semanas/mês
  const monthlyEstimatedSavings = Math.round((weeklyTarget * (52 / 12)) * 100) / 100;
  const monthlyRate = Math.pow(1 + annualRatePercent / 100, 1 / 12) - 1;

  function projectMonths(months: number): number {
    let acc = 0;
    for (let m = 1; m <= months; m++) {
      acc = (acc + monthlyEstimatedSavings) * (1 + monthlyRate);
    }
    return Math.round(acc * 100) / 100;
  }

  return {
    weeklyTarget,
    monthlyEstimatedSavings,
    accumulated1Year: projectMonths(12),
    accumulated3Years: projectMonths(36),
    accumulated5Years: projectMonths(60),
  };
}
