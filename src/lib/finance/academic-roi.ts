export type AcademicCourse = {
  id: string;
  title: string;
  cost: number;
  completionDate: string; // YYYY-MM-DD ou YYYY-MM
  monthlyIncomeBefore: number;
  monthlyIncomeAfter: number;
  institution?: string;
  category?: string;
};

export type AcademicCourseWithRoi = AcademicCourse & {
  monthlyGain: number;
  paybackMonths: number;
  monthsActive: number;
  totalReturnToDate: number;
  netProfitToDate: number;
  roiPercent: number;
  isPaidOff: boolean;
};

export type AcademicRoiResult = {
  totalInvested: number;
  totalMonthlyGain: number;
  totalNetProfitToDate: number;
  overallRoiPercent: number;
  averagePaybackMonths: number;
  coursesWithRoi: AcademicCourseWithRoi[];
  topPerformingCourse: AcademicCourseWithRoi | null;
};

export type NextInvestmentSimulationInput = {
  courseCost: number;
  expectedIncomeIncreasePercent: number;
  currentMonthlyIncome: number;
};

export type NextInvestmentSimulationResult = {
  courseCost: number;
  monthlyGain: number;
  paybackMonths: number;
  annualGain: number;
  verdict: string;
};

function getMonthsDifference(startDateStr: string, endDateStr: string): number {
  const start = new Date(startDateStr.slice(0, 7) + "-01T12:00:00");
  const end = new Date(endDateStr.slice(0, 7) + "-01T12:00:00");

  const months = (end.getFullYear() - start.getFullYear()) * 12 + (end.getMonth() - start.getMonth());
  return Math.max(1, months);
}

/**
 * Computa o retorno sobre investimento (ROI), payback e ganhos de cursos, especializações e supervisões.
 */
export function computeAcademicRoi(
  courses: AcademicCourse[],
  currentMonth: string = new Date().toISOString().slice(0, 7)
): AcademicRoiResult {
  let totalInvested = 0;
  let totalMonthlyGain = 0;
  let totalNetProfitToDate = 0;
  const coursesWithRoi: AcademicCourseWithRoi[] = [];

  for (const c of courses) {
    const cost = Math.max(0, Number(c.cost) || 0);
    const gain = Math.max(0, (Number(c.monthlyIncomeAfter) || 0) - (Number(c.monthlyIncomeBefore) || 0));
    const paybackMonths = gain > 0 ? Math.round((cost / gain) * 10) / 10 : 0;

    const monthsActive = getMonthsDifference(c.completionDate, currentMonth);
    const totalReturnToDate = Math.round(gain * monthsActive * 100) / 100;
    const netProfitToDate = Math.round((totalReturnToDate - cost) * 100) / 100;
    const roiPercent = cost > 0 ? Math.round((netProfitToDate / cost) * 1000) / 10 : 0;
    const isPaidOff = totalReturnToDate >= cost;

    totalInvested += cost;
    totalMonthlyGain += gain;
    totalNetProfitToDate += netProfitToDate;

    coursesWithRoi.push({
      ...c,
      cost,
      monthlyGain: gain,
      paybackMonths,
      monthsActive,
      totalReturnToDate,
      netProfitToDate,
      roiPercent,
      isPaidOff,
    });
  }

  totalInvested = Math.round(totalInvested * 100) / 100;
  totalMonthlyGain = Math.round(totalMonthlyGain * 100) / 100;
  totalNetProfitToDate = Math.round(totalNetProfitToDate * 100) / 100;

  const overallRoiPercent =
    totalInvested > 0
      ? Math.round((totalNetProfitToDate / totalInvested) * 1000) / 10
      : 0;

  const averagePaybackMonths =
    coursesWithRoi.length > 0
      ? Math.round(
          (coursesWithRoi.reduce((sum, c) => sum + c.paybackMonths, 0) /
            coursesWithRoi.length) *
            10
        ) / 10
      : 0;

  let topPerformingCourse: AcademicCourseWithRoi | null = null;
  if (coursesWithRoi.length > 0) {
    topPerformingCourse = [...coursesWithRoi].sort(
      (a, b) => b.netProfitToDate - a.netProfitToDate
    )[0];
  }

  return {
    totalInvested,
    totalMonthlyGain,
    totalNetProfitToDate,
    overallRoiPercent,
    averagePaybackMonths,
    coursesWithRoi,
    topPerformingCourse,
  };
}

/**
 * Simula o payback de um próximo investimento acadêmico (curso/pós) pretendido.
 */
export function simulateNextAcademicInvestment(
  input: NextInvestmentSimulationInput
): NextInvestmentSimulationResult {
  const { courseCost, expectedIncomeIncreasePercent, currentMonthlyIncome } = input;

  const cost = Math.max(0, courseCost);
  const income = Math.max(0, currentMonthlyIncome);
  const pct = Math.max(0, expectedIncomeIncreasePercent);

  const monthlyGain = Math.round(((income * pct) / 100) * 100) / 100;
  const annualGain = Math.round(monthlyGain * 12 * 100) / 100;
  const paybackMonths = monthlyGain > 0 ? Math.round((cost / monthlyGain) * 10) / 10 : 0;

  const verdict =
    paybackMonths > 0
      ? `Investimento de R$ ${cost.toLocaleString("pt-BR")} gera +R$ ${monthlyGain.toLocaleString("pt-BR")}/mês e se paga em ${paybackMonths} meses.`
      : "Informe um percentual de aumento para calcular o retorno.";

  return {
    courseCost: cost,
    monthlyGain,
    paybackMonths,
    annualGain,
    verdict,
  };
}
