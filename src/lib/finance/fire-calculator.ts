import { addMonths, monthLabel } from "./local-date";

export type FireInput = {
  monthlyExpenses: number;
  currentNetWorth: number;
  monthlyContribution?: number;
  realAnnualReturnPercent?: number; // Padrão: 7% a.a. acima da inflação
  startMonth?: string; // YYYY-MM
};

export type FireResult = {
  monthlyExpenses: number;
  currentNetWorth: number;
  monthlyContribution: number;
  fireNumberStandard: number; // 300x gastos
  fireNumberLean: number;     // 70% do standard (210x gastos)
  fireNumberFat: number;      // 150% do standard (450x gastos)
  currentPassiveIncomeMonthly: number;
  fireProgressPercent: number;
  monthsToFire: number;
  yearsToFire: number;
  fireDate: string;
  fireDateLabel: string;
  isFireAchieved: boolean;
};

/**
 * Computa as métricas de independência financeira (F.I.R.E.) baseadas na Regra dos 4% / Trinity Study.
 */
export function calculateFireMetrics(input: FireInput): FireResult {
  const {
    monthlyExpenses,
    currentNetWorth,
    monthlyContribution = 0,
    realAnnualReturnPercent = 7.0,
    startMonth = new Date().toISOString().slice(0, 7),
  } = input;

  const expenses = Math.max(0, monthlyExpenses);
  const netWorth = Math.max(0, currentNetWorth);
  const pmt = Math.max(0, monthlyContribution);

  const fireNumberStandard = Math.round(expenses * 300 * 100) / 100;
  const fireNumberLean = Math.round(expenses * 210 * 100) / 100;
  const fireNumberFat = Math.round(expenses * 450 * 100) / 100;

  const currentPassiveIncomeMonthly =
    Math.round(((netWorth * 0.04) / 12) * 100) / 100;

  const fireProgressPercent =
    fireNumberStandard > 0
      ? Math.min(100, Math.round((netWorth / fireNumberStandard) * 1000) / 10)
      : 100;

  const isFireAchieved = netWorth >= fireNumberStandard;

  let monthsToFire = 0;
  if (!isFireAchieved) {
    const monthlyRealRate = Math.pow(1 + realAnnualReturnPercent / 100, 1 / 12) - 1;
    let balance = netWorth;
    const maxSimulationMonths = 720; // 60 anos

    while (balance < fireNumberStandard && monthsToFire < maxSimulationMonths) {
      monthsToFire++;
      balance = (balance + pmt) * (1 + monthlyRealRate);
    }
  }

  const yearsToFire = Math.round((monthsToFire / 12) * 10) / 10;

  const startNormalized = startMonth.length === 7 ? `${startMonth}-01` : startMonth;
  const fireDateStart = addMonths(startNormalized, monthsToFire);
  const fireDate = fireDateStart.slice(0, 7);
  const fireDateLabel = monthLabel(fireDateStart);

  return {
    monthlyExpenses: expenses,
    currentNetWorth: netWorth,
    monthlyContribution: pmt,
    fireNumberStandard,
    fireNumberLean,
    fireNumberFat,
    currentPassiveIncomeMonthly,
    fireProgressPercent,
    monthsToFire,
    yearsToFire,
    fireDate,
    fireDateLabel,
    isFireAchieved,
  };
}
