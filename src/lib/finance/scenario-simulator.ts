export type CashVsInstallmentInput = {
  fullPrice: number;
  cashDiscountPercent: number; // Ex: 5% ou 10%
  installmentsCount: number;   // Ex: 10 ou 12
  annualCdiPercent?: number;   // Padrão: 12% a.a.
};

export type CashVsInstallmentResult = {
  fullPrice: number;
  cashPrice: number;
  cashDiscountPercent: number;
  installmentsCount: number;
  installmentValue: number;
  totalYieldInCdi: number;
  effectiveInstallmentCost: number;
  bestChoice: "cash" | "installment" | "indifferent";
  cashSavings: number;
  installmentAdvantage: number;
  recommendation: string;
};

export type WhatIfScenarioInput = {
  currentMonthlyIncome: number;
  currentMonthlyExpenses: number;
  newMonthlyCost?: number;     // Nova despesa (ex: parcela de carro)
  newMonthlyIncome?: number;   // Novo ganho (ex: aumento de salário)
  durationMonths?: number;     // Padrão: 12 meses
  initialBalance?: number;     // Saldo em conta inicial
};

export type WhatIfProjectionMonth = {
  monthIndex: number;
  income: number;
  expense: number;
  monthlyNet: number;
  runningBalance: number;
  status: "safe" | "tight" | "deficit";
};

export type WhatIfScenarioResult = {
  isSafe: boolean;
  lowestBalance: number;
  finalBalance: number;
  deficitMonthIndex: number | null;
  monthlyNet: number;
  projections: WhatIfProjectionMonth[];
  verdict: string;
};

/**
 * Compara matematicamente a decisão entre Pagar à Vista com Desconto vs Parcelar Sem Juros no CDI.
 */
export function compareCashVsInstallment(
  input: CashVsInstallmentInput
): CashVsInstallmentResult {
  const {
    fullPrice,
    cashDiscountPercent,
    installmentsCount,
    annualCdiPercent = 12.0,
  } = input;

  const validPrice = Math.max(0, fullPrice);
  const n = Math.max(1, installmentsCount);
  const discount = Math.max(0, cashDiscountPercent);
  const cashPrice = Math.round(validPrice * (1 - discount / 100) * 100) / 100;
  const installmentValue = Math.round((validPrice / n) * 100) / 100;

  const monthlyRate = Math.pow(1 + annualCdiPercent / 100, 1 / 12) - 1;

  // Simulação: Começa com validPrice investido e saca installmentValue todo mês
  let investedBalance = validPrice;
  let totalYieldInCdi = 0;

  for (let i = 0; i < n; i++) {
    const monthYield = investedBalance * monthlyRate;
    totalYieldInCdi += monthYield;
    investedBalance = Math.max(0, investedBalance + monthYield - installmentValue);
  }

  totalYieldInCdi = Math.round(totalYieldInCdi * 100) / 100;
  const effectiveInstallmentCost =
    Math.round((validPrice - totalYieldInCdi) * 100) / 100;

  let bestChoice: CashVsInstallmentResult["bestChoice"] = "indifferent";
  let cashSavings = 0;
  let installmentAdvantage = 0;
  let recommendation = "";

  if (cashPrice < effectiveInstallmentCost - 0.5) {
    bestChoice = "cash";
    cashSavings = Math.round((effectiveInstallmentCost - cashPrice) * 100) / 100;
    recommendation = `À vista é mais vantajoso! Você economiza R$ ${cashSavings.toFixed(2).replace(".", ",")} em relação ao rendimento do CDI.`;
  } else if (effectiveInstallmentCost < cashPrice - 0.5) {
    bestChoice = "installment";
    installmentAdvantage = Math.round((cashPrice - effectiveInstallmentCost) * 100) / 100;
    recommendation = `Parcelar em ${n}x no CDI é mais vantajoso! O dinheiro rendendo gera R$ ${installmentAdvantage.toFixed(2).replace(".", ",")} a mais que o desconto.`;
  } else {
    recommendation = "Os dois cenários são financeiramente equivalentes.";
  }

  return {
    fullPrice: validPrice,
    cashPrice,
    cashDiscountPercent: discount,
    installmentsCount: n,
    installmentValue,
    totalYieldInCdi,
    effectiveInstallmentCost,
    bestChoice,
    cashSavings,
    installmentAdvantage,
    recommendation,
  };
}

/**
 * Simula o impacto financeiro de novos compromissos (What-If) no fluxo de caixa dos próximos meses.
 */
export function simulateWhatIfScenario(
  input: WhatIfScenarioInput
): WhatIfScenarioResult {
  const {
    currentMonthlyIncome,
    currentMonthlyExpenses,
    newMonthlyCost = 0,
    newMonthlyIncome = 0,
    durationMonths = 12,
    initialBalance = 0,
  } = input;

  const totalIncome = currentMonthlyIncome + newMonthlyIncome;
  const totalExpense = currentMonthlyExpenses + newMonthlyCost;
  const monthlyNet = Math.round((totalIncome - totalExpense) * 100) / 100;

  let runningBalance = initialBalance;
  let lowestBalance = initialBalance;
  let deficitMonthIndex: number | null = null;
  const projections: WhatIfProjectionMonth[] = [];

  for (let m = 1; m <= durationMonths; m++) {
    runningBalance += monthlyNet;
    runningBalance = Math.round(runningBalance * 100) / 100;

    if (runningBalance < lowestBalance) {
      lowestBalance = runningBalance;
    }

    let status: WhatIfProjectionMonth["status"] = "safe";
    if (runningBalance < 0) {
      status = "deficit";
      if (deficitMonthIndex === null) {
        deficitMonthIndex = m;
      }
    } else if (runningBalance < totalExpense * 0.5) {
      status = "tight";
    }

    projections.push({
      monthIndex: m,
      income: totalIncome,
      expense: totalExpense,
      monthlyNet,
      runningBalance,
      status,
    });
  }

  const isSafe = deficitMonthIndex === null;
  let verdict = "Cenário Seguro! Seu caixa suporta a nova despesa com folga.";
  if (!isSafe) {
    verdict = `Atenção! No ${deficitMonthIndex}º mês seu saldo ficará negativo em R$ ${Math.abs(lowestBalance).toFixed(2).replace(".", ",")}.`;
  }

  return {
    isSafe,
    lowestBalance,
    finalBalance: runningBalance,
    deficitMonthIndex,
    monthlyNet,
    projections,
    verdict,
  };
}
