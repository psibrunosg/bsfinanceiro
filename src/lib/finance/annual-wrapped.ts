export type WrappedCategory = {
  categoryName: string;
  amount: number;
  percent: number;
};

export type WrappedBestMonth = {
  monthKey: string; // YYYY-MM
  monthName: string;
  savedAmount: number;
};

export type FinancialPersonality = {
  badgeTitle: string;
  tagline: string;
  iconName: string;
};

export type AnnualWrappedResult = {
  year: number;
  totalIncomeYear: number;
  totalExpenseYear: number;
  totalSavedYear: number;
  investmentsTotal: number;
  savingsRatePercent: number;
  topCategories: WrappedCategory[];
  bestMonth: WrappedBestMonth | null;
  financialPersonality: FinancialPersonality;
  shareableSummaryText: string;
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
  category_name?: string;
};

const MONTH_NAMES = [
  "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
  "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
];

/**
 * Computa a retrospectiva anual estilo Wrapped (Spotify do Dinheiro).
 */
export function computeAnnualWrapped(
  transactions: InputTransaction[],
  investmentsTotal: number = 0,
  year: number = new Date().getFullYear()
): AnnualWrappedResult {
  const yearPrefix = String(year);
  let totalIncomeYear = 0;
  let totalExpenseYear = 0;

  const categoryMap = new Map<string, number>();
  const monthlyFlowMap = new Map<string, { income: number; expense: number }>();

  for (const tx of transactions) {
    const txDate = tx.competence_date || "";
    if (!txDate.startsWith(yearPrefix)) continue;

    const amt = Math.abs(Number(tx.amount) || 0);
    const isIncome = tx.type === "income";
    const monthKey = txDate.slice(0, 7);

    if (!monthlyFlowMap.has(monthKey)) {
      monthlyFlowMap.set(monthKey, { income: 0, expense: 0 });
    }
    const mEntry = monthlyFlowMap.get(monthKey)!;

    if (isIncome) {
      totalIncomeYear += amt;
      mEntry.income += amt;
    } else {
      totalExpenseYear += amt;
      mEntry.expense += amt;

      const cat = tx.category_name || "Outros";
      categoryMap.set(cat, (categoryMap.get(cat) ?? 0) + amt);
    }
  }

  totalIncomeYear = Math.round(totalIncomeYear * 100) / 100;
  totalExpenseYear = Math.round(totalExpenseYear * 100) / 100;
  const totalSavedYear = Math.round((totalIncomeYear - totalExpenseYear) * 100) / 100;

  const savingsRatePercent =
    totalIncomeYear > 0
      ? Math.max(0, Math.round((totalSavedYear / totalIncomeYear) * 1000) / 10)
      : 0;

  // Top 3 Categorias
  const sortedCategories = Array.from(categoryMap.entries()).sort(
    (a, b) => b[1] - a[1]
  );
  const topCategories: WrappedCategory[] = sortedCategories.slice(0, 3).map(([categoryName, amount]) => ({
    categoryName,
    amount: Math.round(amount * 100) / 100,
    percent:
      totalExpenseYear > 0
        ? Math.round((amount / totalExpenseYear) * 1000) / 10
        : 0,
  }));

  // Melhor Mês
  let bestMonth: WrappedBestMonth | null = null;
  let maxSaved = -Infinity;
  for (const [mKey, data] of monthlyFlowMap.entries()) {
    const saved = data.income - data.expense;
    if (saved > maxSaved) {
      maxSaved = saved;
      const mNum = parseInt(mKey.split("-")[1], 10) - 1;
      bestMonth = {
        monthKey: mKey,
        monthName: MONTH_NAMES[mNum] || mKey,
        savedAmount: Math.round(saved * 100) / 100,
      };
    }
  }

  // Personalidade Financeira
  let financialPersonality: FinancialPersonality = {
    badgeTitle: "O Equilibrista Prudente",
    tagline: "Você manteve seus gastos sob controle e fechou o ano com as contas no verde.",
    iconName: "Scale",
  };

  if (savingsRatePercent >= 30) {
    financialPersonality = {
      badgeTitle: "O Mestre do F.I.R.E. & Investimentos",
      tagline: `Incrível! Você poupou ${savingsRatePercent}% de toda sua renda anual e acelerou sua liberdade financeira.`,
      iconName: "Flame",
    };
  } else if (savingsRatePercent >= 15) {
    financialPersonality = {
      badgeTitle: "O Guardião Construtor de Riqueza",
      tagline: `Muito bom! Você poupou ${savingsRatePercent}% no ano e fortaleceu seu patrimônio.`,
      iconName: "ShieldCheck",
    };
  }

  const shareableSummaryText = `Meu Wrapped Financeiro ${year}: Guardei R$ ${totalSavedYear.toLocaleString(
    "pt-BR"
  )} (${savingsRatePercent}% da renda). Perfil: ${financialPersonality.badgeTitle}! 🚀`;

  return {
    year,
    totalIncomeYear,
    totalExpenseYear,
    totalSavedYear,
    investmentsTotal: Math.round(investmentsTotal * 100) / 100,
    savingsRatePercent,
    topCategories,
    bestMonth,
    financialPersonality,
    shareableSummaryText,
  };
}
