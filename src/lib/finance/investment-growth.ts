export type YieldComparisonInput = {
  portfolioYieldPercent: number;
  annualCdiPercent?: number; // Padrão: 12.25% a.a.
  annualSavingsPercent?: number; // Padrão: 7.2% a.a.
};

export type YieldComparisonResult = {
  percentOfCdi: number;
  beatsCdi: boolean;
  beatsSavings: boolean;
  cdiSpread: number;
  savingsSpread: number;
};

export type GrowthProjectionInput = {
  initialPrincipal: number;
  monthlyContribution: number;
  annualRatePercent: number;
  months: number;
};

export type GrowthMilestone = {
  month: number;
  contributed: number;
  accumulated: number;
  interest: number;
};

export type GrowthProjectionResult = {
  totalContributed: number;
  totalAccumulated: number;
  totalInterestGained: number;
  milestones: GrowthMilestone[];
};

export type AssetSummaryItem = {
  id: string;
  type: string;
  name: string;
};

export type PositionItem = {
  quantity: number;
  costCents: number;
};

export type AssetClassAllocation = {
  fixedIncomeTotal: number;
  variableIncomeTotal: number;
  total: number;
  fixedIncomePercent: number;
  variableIncomePercent: number;
};

/**
 * Compara a rentabilidade da carteira com o benchmark CDI e a Poupança.
 */
export function comparePortfolioYield(input: YieldComparisonInput): YieldComparisonResult {
  const {
    portfolioYieldPercent,
    annualCdiPercent = 12.25,
    annualSavingsPercent = 7.2,
  } = input;

  const percentOfCdi =
    annualCdiPercent > 0
      ? Math.round((portfolioYieldPercent / annualCdiPercent) * 10000) / 100
      : 0;

  const cdiSpread = Math.round((portfolioYieldPercent - annualCdiPercent) * 100) / 100;
  const savingsSpread =
    Math.round((portfolioYieldPercent - annualSavingsPercent) * 100) / 100;

  return {
    percentOfCdi,
    beatsCdi: portfolioYieldPercent > annualCdiPercent,
    beatsSavings: portfolioYieldPercent > annualSavingsPercent,
    cdiSpread,
    savingsSpread,
  };
}

/**
 * Simula a evolução patrimonial com juros compostos e aportes mensais.
 */
export function projectCompoundGrowth(input: GrowthProjectionInput): GrowthProjectionResult {
  const {
    initialPrincipal,
    monthlyContribution,
    annualRatePercent,
    months,
  } = input;

  // Taxa mensal equivalente: (1 + i_ano)^(1/12) - 1
  const monthlyRate =
    annualRatePercent > 0
      ? Math.pow(1 + annualRatePercent / 100, 1 / 12) - 1
      : 0;

  let currentAccumulated = initialPrincipal;
  let totalContributed = initialPrincipal;
  const milestones: GrowthMilestone[] = [];

  for (let m = 1; m <= months; m++) {
    const interest = currentAccumulated * monthlyRate;
    currentAccumulated = currentAccumulated + interest + monthlyContribution;
    totalContributed += monthlyContribution;

    milestones.push({
      month: m,
      contributed: Math.round(totalContributed * 100) / 100,
      accumulated: Math.round(currentAccumulated * 100) / 100,
      interest: Math.round((currentAccumulated - totalContributed) * 100) / 100,
    });
  }

  const totalAccumulated = Math.round(currentAccumulated * 100) / 100;
  const finalContributed = Math.round(totalContributed * 100) / 100;
  const totalInterestGained = Math.round((totalAccumulated - finalContributed) * 100) / 100;

  return {
    totalContributed: finalContributed,
    totalAccumulated,
    totalInterestGained,
    milestones,
  };
}

/**
 * Agrupa os ativos entre Renda Fixa e Renda Variável e calcula suas participações percentuais.
 */
export function computeAssetClassAllocation(
  assets: AssetSummaryItem[],
  positions: Record<string, PositionItem | undefined>,
  latestQuotes: Record<string, number | undefined>
): AssetClassAllocation {
  let fixedIncomeTotal = 0;
  let variableIncomeTotal = 0;

  for (const asset of assets) {
    const pos = positions[asset.id];
    if (!pos || pos.quantity <= 0) continue;

    const unitPrice =
      latestQuotes[asset.id] ?? (pos.costCents > 0 ? pos.costCents / 100 / pos.quantity : 0);
    const value = pos.quantity * unitPrice;

    if (asset.type === "fixed_income") {
      fixedIncomeTotal += value;
    } else {
      // stock, reit, fund, real_estate
      variableIncomeTotal += value;
    }
  }

  const total = fixedIncomeTotal + variableIncomeTotal;
  const fixedIncomePercent = total > 0 ? Math.round((fixedIncomeTotal / total) * 1000) / 10 : 0;
  const variableIncomePercent = total > 0 ? Math.round((variableIncomeTotal / total) * 1000) / 10 : 0;

  return {
    fixedIncomeTotal: Math.round(fixedIncomeTotal * 100) / 100,
    variableIncomeTotal: Math.round(variableIncomeTotal * 100) / 100,
    total: Math.round(total * 100) / 100,
    fixedIncomePercent,
    variableIncomePercent,
  };
}
