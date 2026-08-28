import { monthLabel } from "./local-date";

export type ClinicTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
  context_name?: string;
  is_clinic_expense_on_personal?: boolean;
  is_partner_reimbursement?: boolean;
};

export type ClinicDREResult = {
  month: string;
  monthLabel: string;
  grossRevenue: number;
  operatingExpenses: number;
  operatingProfit: number;
  profitMarginPercent: number;
  proLaboreWithdrawn: number;
  retainedEarnings: number;
};

export type PartnerLoanItem = {
  id: string;
  description: string;
  amount: number;
  date: string;
};

export type PartnerLoanResult = {
  totalLentByPartner: number;
  totalReimbursed: number;
  pendingBalance: number;
  status: "settled" | "clinic_owes_partner" | "partner_owes_clinic";
  unreimbursedItems: PartnerLoanItem[];
};

export type CashFlowGapDay = {
  day: number;
  date: string;
  inflow: number;
  outflow: number;
  accumulatedBalance: number;
};

export type CashFlowGapResult = {
  hasLiquidityGap: boolean;
  maxDeficitAmount: number;
  maxDeficitDay: number | null;
  workingCapitalNeeded: number;
  gapResolutionDay: number | null;
  dailyTimeline: CashFlowGapDay[];
};

// Regex de identificação de despesas operacionais da clínica/consultório
const CLINIC_EXPENSE_PATTERNS = [
  /aluguel/i,
  /consult[oó]rio/i,
  /cl[ií]nica/i,
  /sala/i,
  /condom[ií]nio/i,
  /crp|crm|oab/i,
  /supervis[aã]o/i,
  /prontu[aá]rio|psicomanager/i,
  /teste|wisc|palogr[aá]fico|hta/i,
  /curso|especializa[cç][aã]o/i,
  /internet|telefonia/i,
  /limpeza|faxina/i,
  /papelaria|insumo/i,
];

// Regex para pró-labore
const PRO_LABORE_PATTERNS = [/pr[oó]-?labore/i, /retirada|distribui[cç][aã]o de lucro/i];

// Regex para reembolso de sócio
const REIMBURSEMENT_PATTERNS = [/reembolso/i, /devolu[cç][aã]o/i, /ressarcimento/i];

/**
 * Computa o DRE gerencial simplificado da clínica no mês selecionado.
 */
export function computeClinicDRE(
  transactions: ClinicTransaction[],
  month: string
): ClinicDREResult {
  const monthPrefix = month.slice(0, 7);
  let grossRevenue = 0;
  let operatingExpenses = 0;
  let proLaboreWithdrawn = 0;

  for (const tx of transactions) {
    const txMonth = (tx.competence_date || "").slice(0, 7);
    if (txMonth !== monthPrefix) continue;

    const amt = Math.abs(Number(tx.amount) || 0);
    const desc = tx.description || "";
    const isIncome = tx.type === "income";

    if (isIncome) {
      if (!REIMBURSEMENT_PATTERNS.some((p) => p.test(desc))) {
        grossRevenue += amt;
      }
    } else {
      if (PRO_LABORE_PATTERNS.some((p) => p.test(desc))) {
        proLaboreWithdrawn += amt;
      } else {
        operatingExpenses += amt;
      }
    }
  }

  grossRevenue = Math.round(grossRevenue * 100) / 100;
  operatingExpenses = Math.round(operatingExpenses * 100) / 100;
  proLaboreWithdrawn = Math.round(proLaboreWithdrawn * 100) / 100;

  const operatingProfit = Math.round((grossRevenue - operatingExpenses) * 100) / 100;
  const profitMarginPercent =
    grossRevenue > 0
      ? Math.round((operatingProfit / grossRevenue) * 1000) / 10
      : 0;
  const retainedEarnings = Math.round((operatingProfit - proLaboreWithdrawn) * 100) / 100;

  const monthStart = month.length === 7 ? `${month}-01` : month;

  return {
    month: monthPrefix,
    monthLabel: monthLabel(monthStart),
    grossRevenue,
    operatingExpenses,
    operatingProfit,
    profitMarginPercent,
    proLaboreWithdrawn,
    retainedEarnings,
  };
}

/**
 * Apura empréstimos de sócio: despesas da clínica pagas com dinheiro/cartão pessoal
 * vs reembolsos efetuados pela clínica para o sócio.
 */
export function computePartnerLoanBalance(
  transactions: ClinicTransaction[]
): PartnerLoanResult {
  let totalLentByPartner = 0;
  let totalReimbursed = 0;
  const unreimbursedItems: PartnerLoanItem[] = [];

  for (const tx of transactions) {
    const amt = Math.abs(Number(tx.amount) || 0);
    const desc = tx.description || "";

    const isExplicitClinicExpense =
      tx.is_clinic_expense_on_personal === true ||
      /\[cl[ií]nica\]|\[pj\]|\[consult[oó]rio\]/i.test(desc) ||
      (CLINIC_EXPENSE_PATTERNS.some((p) => p.test(desc)) &&
        (tx.context_name?.toLowerCase() === "pessoal" || !tx.context_name));

    const isExplicitReimbursement =
      tx.is_partner_reimbursement === true || REIMBURSEMENT_PATTERNS.some((p) => p.test(desc));

    if (isExplicitClinicExpense && tx.type !== "income") {
      totalLentByPartner += amt;
      unreimbursedItems.push({
        id: tx.id,
        description: desc,
        amount: amt,
        date: tx.competence_date || "",
      });
    } else if (isExplicitReimbursement && tx.type === "income") {
      totalReimbursed += amt;
    }
  }

  totalLentByPartner = Math.round(totalLentByPartner * 100) / 100;
  totalReimbursed = Math.round(totalReimbursed * 100) / 100;
  const pendingBalance = Math.round((totalLentByPartner - totalReimbursed) * 100) / 100;

  let status: PartnerLoanResult["status"] = "settled";
  if (pendingBalance > 0) {
    status = "clinic_owes_partner";
  } else if (pendingBalance < 0) {
    status = "partner_owes_clinic";
  }

  return {
    totalLentByPartner,
    totalReimbursed,
    pendingBalance: Math.abs(pendingBalance),
    status,
    unreimbursedItems,
  };
}

/**
 * Calcula o descasamento de liquidez ao longo dos dias do mês (Cash Flow Gap).
 */
export function computeCashFlowGap(
  transactions: ClinicTransaction[],
  month: string,
  initialCashBalance = 0
): CashFlowGapResult {
  const monthPrefix = month.slice(0, 7);

  // Agrupa entradas e saídas por dia do mês (1..31)
  const dailyFlow: Record<number, { inflow: number; outflow: number; date: string }> = {};

  for (let d = 1; d <= 31; d++) {
    const padDay = String(d).padStart(2, "0");
    dailyFlow[d] = {
      inflow: 0,
      outflow: 0,
      date: `${monthPrefix}-${padDay}`,
    };
  }

  for (const tx of transactions) {
    const txDate = tx.competence_date || "";
    if (txDate.slice(0, 7) !== monthPrefix) continue;

    const day = Number(txDate.slice(8, 10)) || 1;
    if (day >= 1 && day <= 31) {
      const amt = Math.abs(Number(tx.amount) || 0);
      if (tx.type === "income") {
        dailyFlow[day].inflow += amt;
      } else {
        dailyFlow[day].outflow += amt;
      }
    }
  }

  let runningBalance = initialCashBalance;
  let maxDeficitAmount = 0;
  let maxDeficitDay: number | null = null;
  let gapResolutionDay: number | null = null;
  const dailyTimeline: CashFlowGapDay[] = [];

  for (let d = 1; d <= 31; d++) {
    const dayData = dailyFlow[d];
    runningBalance += dayData.inflow - dayData.outflow;
    runningBalance = Math.round(runningBalance * 100) / 100;

    dailyTimeline.push({
      day: d,
      date: dayData.date,
      inflow: dayData.inflow,
      outflow: dayData.outflow,
      accumulatedBalance: runningBalance,
    });

    if (runningBalance < 0) {
      const deficit = Math.abs(runningBalance);
      if (deficit > maxDeficitAmount) {
        maxDeficitAmount = deficit;
        maxDeficitDay = d;
      }
    } else if (maxDeficitDay !== null && gapResolutionDay === null && runningBalance >= 0) {
      gapResolutionDay = d;
    }
  }

  return {
    hasLiquidityGap: maxDeficitAmount > 0,
    maxDeficitAmount: Math.round(maxDeficitAmount * 100) / 100,
    maxDeficitDay,
    workingCapitalNeeded: Math.round(maxDeficitAmount * 100) / 100,
    gapResolutionDay,
    dailyTimeline,
  };
}
