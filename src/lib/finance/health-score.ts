export type HealthScoreTier = "critico" | "atencao" | "saudavel" | "excelente";

export type HealthScorePilar = {
  id: "reserva" | "endividamento" | "poupanca" | "investimentos";
  title: string;
  score: number;
  maxScore: number;
  status: "critico" | "atencao" | "bom" | "excelente";
  description: string;
  metricLabel: string;
};

export type HealthScoreActionTip = {
  id: string;
  pilarId: string;
  pointsPotential: number;
  title: string;
  actionText: string;
};

export type FinancialHealthScoreInput = {
  monthlyIncome: number;
  monthlyExpenses: number;
  availableCash: number;
  fixedCommitments?: number;
  investedTotal?: number;
};

export type FinancialHealthScoreResult = {
  overallScore: number; // 0 a 1000
  tier: HealthScoreTier;
  tierLabel: string;
  tierColor: string;
  pillars: HealthScorePilar[];
  tips: HealthScoreActionTip[];
};

/**
 * 1. Pilar Reserva de Emergência (0 a 250 pontos)
 * Mede quantos meses de despesa o usuário tem em saldo/caixa disponível.
 */
export function calculateEmergencyReserveScore(monthsOfCoverage: number): number {
  if (monthsOfCoverage <= 0) return 0;
  if (monthsOfCoverage >= 6) return 250;
  if (monthsOfCoverage >= 3) {
    // 3 meses = 180 pts, 6 meses = 250 pts
    return Math.round(180 + ((monthsOfCoverage - 3) / 3) * 70);
  }
  // 0 a 3 meses: 0 -> 180 pts
  return Math.round((monthsOfCoverage / 3) * 180);
}

/**
 * 2. Pilar Endividamento / Comprometimento de Renda (0 a 250 pontos)
 * Quanto menor o % de gastos fixos/dívidas sobre a renda, maior a nota.
 */
export function calculateDebtRatioScore(debtOrCommitmentPercent: number): number {
  if (debtOrCommitmentPercent <= 30) return 250;
  if (debtOrCommitmentPercent >= 90) return 0;
  if (debtOrCommitmentPercent <= 50) {
    // 30% = 250 pts, 50% = 150 pts
    return Math.round(250 - ((debtOrCommitmentPercent - 30) / 20) * 100);
  }
  // 50% = 150 pts, 90% = 0 pts
  return Math.max(0, Math.round(150 - ((debtOrCommitmentPercent - 50) / 40) * 150));
}

/**
 * 3. Pilar Taxa de Poupança / Fluxo Livre (0 a 250 pontos)
 * Quanto sobra da renda no mês: (Receita - Despesa) / Receita.
 */
export function calculateSavingsRateScore(savingsPercent: number): number {
  if (savingsPercent <= 0) return 0;
  if (savingsPercent >= 25) return 250;
  if (savingsPercent >= 15) {
    // 15% = 180 pts, 25% = 250 pts
    return Math.round(180 + ((savingsPercent - 15) / 10) * 70);
  }
  // 0% a 15%: 0 -> 180 pts
  return Math.round((savingsPercent / 15) * 180);
}

/**
 * 4. Pilar Investimentos & Construção Patrimonial (0 a 250 pontos)
 * Mede o patrimônio investido como múltiplo da renda mensal.
 */
export function calculateInvestmentScore(investedTotal: number, monthlyIncome: number): number {
  if (investedTotal <= 0 || monthlyIncome <= 0) return 0;
  const multiple = investedTotal / monthlyIncome;
  if (multiple >= 6) return 250;
  if (multiple >= 1) {
    // 1x = 120 pts, 6x = 250 pts
    return Math.round(120 + ((multiple - 1) / 5) * 130);
  }
  // 0x a 1x: 0 -> 120 pts
  return Math.round(multiple * 120);
}

/**
 * Calcula o Score Geral de Saúde Financeira (0 a 1000) e gera recomendações acionáveis.
 */
export function computeFinancialHealthScore(
  input: FinancialHealthScoreInput
): FinancialHealthScoreResult {
  const {
    monthlyIncome,
    monthlyExpenses,
    availableCash,
    fixedCommitments = 0,
    investedTotal = 0,
  } = input;

  const costOfLiving = monthlyExpenses > 0 ? monthlyExpenses : 1;
  const reserveMonths = availableCash > 0 ? availableCash / costOfLiving : 0;
  const reserveScore = calculateEmergencyReserveScore(reserveMonths);

  const commitmentPercent =
    monthlyIncome > 0 ? (fixedCommitments / monthlyIncome) * 100 : 100;
  const debtScore = calculateDebtRatioScore(commitmentPercent);

  const savingsRate =
    monthlyIncome > 0 ? ((monthlyIncome - monthlyExpenses) / monthlyIncome) * 100 : 0;
  const savingsScore = calculateSavingsRateScore(savingsRate);

  const investmentScore = calculateInvestmentScore(investedTotal, monthlyIncome);

  const overallScore = Math.min(
    1000,
    Math.max(0, reserveScore + debtScore + savingsScore + investmentScore)
  );

  let tier: HealthScoreTier = "critico";
  let tierLabel = "Crítico";
  let tierColor = "var(--destructive, #ef4444)";

  if (overallScore >= 851) {
    tier = "excelente";
    tierLabel = "Excelente";
    tierColor = "var(--accent, #8b5cf6)";
  } else if (overallScore >= 701) {
    tier = "saudavel";
    tierLabel = "Saudável";
    tierColor = "var(--positive, #22c55e)";
  } else if (overallScore >= 401) {
    tier = "atencao";
    tierLabel = "Atenção";
    tierColor = "var(--warning, #f59e0b)";
  }

  function getStatus(score: number): HealthScorePilar["status"] {
    if (score >= 220) return "excelente";
    if (score >= 170) return "bom";
    if (score >= 100) return "atencao";
    return "critico";
  }

  const pillars: HealthScorePilar[] = [
    {
      id: "reserva",
      title: "Reserva de Emergência",
      score: reserveScore,
      maxScore: 250,
      status: getStatus(reserveScore),
      description: `${reserveMonths.toFixed(1)} meses de custo de vida cobertos`,
      metricLabel: `${reserveMonths.toFixed(1)} meses`,
    },
    {
      id: "endividamento",
      title: "Controle de Gastos Fixos",
      score: debtScore,
      maxScore: 250,
      status: getStatus(debtScore),
      description: `${commitmentPercent.toFixed(0)}% da renda comprometida com contas fixas`,
      metricLabel: `${commitmentPercent.toFixed(0)}% da renda`,
    },
    {
      id: "poupanca",
      title: "Taxa de Poupança",
      score: savingsScore,
      maxScore: 250,
      status: getStatus(savingsScore),
      description: `${savingsRate > 0 ? "+" : ""}${savingsRate.toFixed(0)}% de sobra líquida no mês`,
      metricLabel: `${savingsRate.toFixed(0)}%`,
    },
    {
      id: "investimentos",
      title: "Investimentos & Patrimônio",
      score: investmentScore,
      maxScore: 250,
      status: getStatus(investmentScore),
      description:
        monthlyIncome > 0
          ? `${(investedTotal / monthlyIncome).toFixed(1)}x a renda mensal investida`
          : "Sem investimentos registrados",
      metricLabel: monthlyIncome > 0 ? `${(investedTotal / monthlyIncome).toFixed(1)}x` : "0x",
    },
  ];

  // Gera dicas práticas de gamificação
  const tips: HealthScoreActionTip[] = [];

  if (reserveScore < 220) {
    const missingMonths = Math.max(0, 6 - reserveMonths);
    tips.push({
      id: "tip-reserva",
      pilarId: "reserva",
      pointsPotential: Math.round(250 - reserveScore),
      title: "Fortalecer a Caixinha de Emergência",
      actionText: `Guarde mais ${missingMonths.toFixed(1)} meses de custo para atingir 6 meses de segurança e ganhar até +${Math.round(250 - reserveScore)} pts.`,
    });
  }

  if (debtScore < 200) {
    tips.push({
      id: "tip-dividas",
      pilarId: "endividamento",
      pointsPotential: Math.round(250 - debtScore),
      title: "Desafogar o Orçamento Fixo",
      actionText: `Reduza compromissos fixos para abaixo de 30% da renda para ganhar até +${Math.round(250 - debtScore)} pts.`,
    });
  }

  if (savingsScore < 220) {
    tips.push({
      id: "tip-poupanca",
      pilarId: "poupanca",
      pointsPotential: Math.round(250 - savingsScore),
      title: "Aumentar a Taxa de Poupança",
      actionText: `Economize 25% da sua renda mensal para atingir a pontuação máxima no pilar de poupança.`,
    });
  }

  if (investmentScore < 200) {
    tips.push({
      id: "tip-investimentos",
      pilarId: "investimentos",
      pointsPotential: Math.round(250 - investmentScore),
      title: "Acelerar Construção Patrimonial",
      actionText: `Mantenha aportes regulares em CDB/Tesouro/Ações para construir mais de 6x sua renda em patrimônio.`,
    });
  }

  return {
    overallScore,
    tier,
    tierLabel,
    tierColor,
    pillars,
    tips: tips.slice(0, 3),
  };
}
