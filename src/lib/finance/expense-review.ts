export type ExpenseReviewItem = {
  id: string;
  description: string;
  amount: number;
  category?: string;
  date?: string;
  rating: "liked" | "regretted" | "unreviewed";
};

export type ExpenseReviewResult = {
  totalReviewedCount: number;
  unreviewedCount: number;
  likedCount: number;
  regrettedCount: number;
  totalRegrettedAmount: number;
  totalLikedAmount: number;
  totalAmountReviewed: number;
  satisfactionRatePercent: number;
  topRegretCategory: string | null;
  behavioralInsight: string;
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
  category_id?: string | null;
  category_name?: string;
};

const FIXED_EXPENSE_PATTERNS = [
  /aluguel|condom[ií]nio|iptu|ipva|plano de sa[uú]de|escola|faculdade|seguro/i,
];

/**
 * Filtra despesas variáveis elegíveis para a revisão mensal (excluindo custos fixos óbvios).
 */
export function getReviewableTransactions(
  transactions: InputTransaction[],
  month?: string
): ExpenseReviewItem[] {
  const monthPrefix = month ? month.slice(0, 7) : null;
  const list: ExpenseReviewItem[] = [];

  for (const tx of transactions) {
    const isExpense = !tx.type || tx.type === "expense";
    const txDate = tx.competence_date || "";
    if (monthPrefix && txDate.slice(0, 7) !== monthPrefix) continue;

    if (isExpense) {
      const desc = tx.description || "";
      const isFixed = FIXED_EXPENSE_PATTERNS.some((p) => p.test(desc));
      if (!isFixed) {
        list.push({
          id: tx.id,
          description: desc,
          amount: Math.abs(Number(tx.amount) || 0),
          category: tx.category_name || "Geral",
          date: txDate,
          rating: "unreviewed",
        });
      }
    }
  }

  return list;
}

/**
 * Computa as métricas de inteligência comportamental da revisão de gastos (Tinder dos Gastos).
 */
export function computeExpenseReviewMetrics(
  items: ExpenseReviewItem[]
): ExpenseReviewResult {
  let likedCount = 0;
  let regrettedCount = 0;
  let unreviewedCount = 0;
  let totalRegrettedAmount = 0;
  let totalLikedAmount = 0;

  const regretByCategory = new Map<string, number>();

  for (const item of items) {
    const amt = Math.abs(Number(item.amount) || 0);

    if (item.rating === "liked") {
      likedCount++;
      totalLikedAmount += amt;
    } else if (item.rating === "regretted") {
      regrettedCount++;
      totalRegrettedAmount += amt;

      const cat = item.category || "Outros";
      regretByCategory.set(cat, (regretByCategory.get(cat) ?? 0) + amt);
    } else {
      unreviewedCount++;
    }
  }

  totalRegrettedAmount = Math.round(totalRegrettedAmount * 100) / 100;
  totalLikedAmount = Math.round(totalLikedAmount * 100) / 100;
  const totalAmountReviewed =
    Math.round((totalLikedAmount + totalRegrettedAmount) * 100) / 100;
  const totalReviewedCount = likedCount + regrettedCount;

  const satisfactionRatePercent =
    totalAmountReviewed > 0
      ? Math.round((totalLikedAmount / totalAmountReviewed) * 1000) / 10
      : 100;

  let topRegretCategory: string | null = null;
  let maxRegret = 0;
  for (const [cat, amt] of regretByCategory.entries()) {
    if (amt > maxRegret) {
      maxRegret = amt;
      topRegretCategory = cat;
    }
  }

  let behavioralInsight = "Parabéns! Suas compras trouxeram 100% de satisfação.";
  if (totalRegrettedAmount > 0) {
    behavioralInsight = `Você identificou R$ ${totalRegrettedAmount.toFixed(2).replace(".", ",")} em compras que não valeram a pena. Categoria com maior arrependimento: ${topRegretCategory || "Geral"}.`;
  }

  return {
    totalReviewedCount,
    unreviewedCount,
    likedCount,
    regrettedCount,
    totalRegrettedAmount,
    totalLikedAmount,
    totalAmountReviewed,
    satisfactionRatePercent,
    topRegretCategory,
    behavioralInsight,
  };
}
