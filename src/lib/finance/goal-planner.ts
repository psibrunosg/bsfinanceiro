import { addMonths, monthLabel } from "./local-date";

export type GoalMilestone = {
  percentage: number;
  label: string;
  amount: number;
  achieved: boolean;
};

export type GoalPlanInput = {
  targetAmount: number;
  currentAmount: number;
  startMonth?: string; // YYYY-MM
  deadlineMonth?: string | null; // YYYY-MM ou YYYY-MM-DD
  annualRatePercent?: number; // Padrão: 12% a.a. CDI
  monthlyContribution?: number; // Aporte mensal simulado
};

export type GoalPlanResult = {
  targetAmount: number;
  currentAmount: number;
  remainingAmount: number;
  progressPercentage: number;
  monthsRemaining: number;
  deadlineMonth: string | null;
  deadlineMonthLabel: string | null;
  requiredMonthlyNoInterest: number;
  requiredMonthlyWithCDI: number;
  cdiYieldBenefit: number;
  projectedMonths: number;
  projectedCompletionDate: string;
  projectedCompletionLabel: string;
  monthsAhead: number;
  status: "completed" | "ahead" | "on_track" | "delayed";
};

/**
 * Calcula o planejamento financeiro de uma meta com juros compostos no CDI e projeções de prazo.
 */
export function computeGoalPlan(input: GoalPlanInput): GoalPlanResult {
  const {
    targetAmount,
    currentAmount,
    startMonth = new Date().toISOString().slice(0, 7),
    deadlineMonth = null,
    annualRatePercent = 12.0,
    monthlyContribution,
  } = input;

  const target = Math.max(0, targetAmount);
  const current = Math.max(0, currentAmount);
  const remaining = Math.max(0, target - current);
  const progressPercentage =
    target > 0 ? Math.min(100, Math.round((current / target) * 1000) / 10) : 100;

  const startNormalized = startMonth.length === 7 ? `${startMonth}-01` : startMonth;

  // Calcula meses restantes até o deadline
  let monthsRemaining = 12;
  let deadlineLabel: string | null = null;
  let cleanDeadlineMonth: string | null = null;

  if (deadlineMonth) {
    cleanDeadlineMonth = deadlineMonth.slice(0, 7);
    const deadlineNormalized = `${cleanDeadlineMonth}-01`;
    deadlineLabel = monthLabel(deadlineNormalized);

    const [sYear, sMonth] = startNormalized.split("-").map(Number);
    const [dYear, dMonth] = deadlineNormalized.split("-").map(Number);
    const diff = (dYear - sYear) * 12 + (dMonth - sMonth);
    monthsRemaining = Math.max(1, diff);
  }

  // Taxa mensal equivalente
  const monthlyRate = Math.pow(1 + annualRatePercent / 100, 1 / 12) - 1;

  // Aporte necessário sem juros
  const requiredMonthlyNoInterest =
    monthsRemaining > 0 ? Math.round((remaining / monthsRemaining) * 100) / 100 : remaining;

  // Aporte necessário com CDI:
  // FV = PV * (1+i)^n + PMT * [((1+i)^n - 1) / i]
  // PMT = [FV - PV * (1+i)^n] / [((1+i)^n - 1) / i]
  let requiredMonthlyWithCDI = requiredMonthlyNoInterest;
  let cdiYieldBenefit = 0;

  if (monthsRemaining > 0 && remaining > 0) {
    const compoundFactor = Math.pow(1 + monthlyRate, monthsRemaining);
    const futureValueOfCurrent = current * compoundFactor;
    const annuityFactor = (compoundFactor - 1) / monthlyRate;

    const neededFutureFromPMT = Math.max(0, target - futureValueOfCurrent);
    const pmt = neededFutureFromPMT / annuityFactor;

    requiredMonthlyWithCDI = Math.round(pmt * 100) / 100;

    // Total que o usuário aporta vs o valor do sonho
    const totalDepositedByHuman = current + requiredMonthlyWithCDI * monthsRemaining;
    cdiYieldBenefit = Math.max(0, Math.round((target - totalDepositedByHuman) * 100) / 100);
  }

  // Simulação de prazo com aporte mensal fornecido
  const activePMT =
    monthlyContribution != null && monthlyContribution > 0
      ? monthlyContribution
      : requiredMonthlyWithCDI;

  let simulatedBalance = current;
  let projectedMonths = 0;
  const maxSimulationMonths = 360;

  while (simulatedBalance < target && projectedMonths < maxSimulationMonths) {
    projectedMonths++;
    simulatedBalance = (simulatedBalance + activePMT) * (1 + monthlyRate);
  }

  const projectedDateStart = addMonths(startNormalized, Math.max(0, projectedMonths));
  const projectedCompletionDate = projectedDateStart.slice(0, 7);
  const projectedCompletionLabel = monthLabel(projectedDateStart);

  const monthsAhead = Math.max(0, monthsRemaining - projectedMonths);

  let status: GoalPlanResult["status"] = "on_track";
  if (remaining <= 0) {
    status = "completed";
  } else if (monthsAhead > 0) {
    status = "ahead";
  } else if (projectedMonths > monthsRemaining) {
    status = "delayed";
  }

  return {
    targetAmount: target,
    currentAmount: current,
    remainingAmount: remaining,
    progressPercentage,
    monthsRemaining,
    deadlineMonth: cleanDeadlineMonth,
    deadlineMonthLabel: deadlineLabel,
    requiredMonthlyNoInterest,
    requiredMonthlyWithCDI,
    cdiYieldBenefit,
    projectedMonths,
    projectedCompletionDate,
    projectedCompletionLabel,
    monthsAhead,
    status,
  };
}

/**
 * Divide a meta em 4 marcos (25%, 50%, 75%, 100%).
 */
export function computeGoalMilestones(targetAmount: number, currentAmount: number): GoalMilestone[] {
  const steps = [
    { pct: 25, label: "Primeiro Passo (25%)" },
    { pct: 50, label: "Metade do Caminho (50%)" },
    { pct: 75, label: "Reta Final (75%)" },
    { pct: 100, label: "Sonho Conquistado (100%)" },
  ];

  return steps.map((s) => {
    const amt = Math.round(((targetAmount * s.pct) / 100) * 100) / 100;
    return {
      percentage: s.pct,
      label: s.label,
      amount: amt,
      achieved: currentAmount >= amt,
    };
  });
}
