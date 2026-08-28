export type CoupleExpenseItem = {
  id: string;
  description: string;
  amount: number;
  payer: "partner_a" | "partner_b" | "both";
  date?: string;
  category?: string;
};

export type CoupleFinanceInput = {
  expenses: CoupleExpenseItem[];
  splitMode?: "equal_50_50" | "proportional_by_income";
  partnerAIncome?: number;
  partnerBIncome?: number;
  partnerAName?: string;
  partnerBName?: string;
};

export type CoupleFinanceResult = {
  totalSharedExpenses: number;
  totalPaidByPartnerA: number;
  totalPaidByPartnerB: number;
  partnerASharePercent: number;
  partnerBSharePercent: number;
  fairSharePartnerA: number;
  fairSharePartnerB: number;
  debtor: "partner_a" | "partner_b" | "settled";
  settlementAmount: number;
  statusMessage: string;
  expenses: CoupleExpenseItem[];
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
  context_name?: string;
};

const COUPLE_PATTERNS = [
  /\[casal\]/i,
  /\[juntos\]/i,
  /\[n[oó]s\]/i,
  /casal/i,
  /esposa|marido|namorad[oa]|parceir[oa]|c\/ esposa|c\/ namorad/i,
  /supermercado.*casal|jantar.*casal/i,
];

/**
 * Detecta transações compartilhadas do casal a partir do histórico de transações.
 */
export function detectCoupleTransactions(
  transactions: InputTransaction[],
  month?: string
): CoupleExpenseItem[] {
  const monthPrefix = month ? month.slice(0, 7) : null;
  const items: CoupleExpenseItem[] = [];

  for (const tx of transactions) {
    const isExpense = !tx.type || tx.type === "expense";
    const txDate = tx.competence_date || "";
    if (monthPrefix && txDate.slice(0, 7) !== monthPrefix) continue;

    if (isExpense) {
      const desc = tx.description || "";
      const isMatch =
        COUPLE_PATTERNS.some((p) => p.test(desc)) ||
        tx.context_name?.toLowerCase() === "casal";

      if (isMatch) {
        items.push({
          id: tx.id,
          description: desc,
          amount: Math.abs(Number(tx.amount) || 0),
          payer: "partner_a",
          date: txDate,
        });
      }
    }
  }

  return items;
}

/**
 * Computa a divisão justa de finanças a dois (50/50 ou Proporcional por Renda) e o saldo de acerto.
 */
export function computeCoupleFinances(
  input: CoupleFinanceInput
): CoupleFinanceResult {
  const {
    expenses,
    splitMode = "equal_50_50",
    partnerAIncome = 0,
    partnerBIncome = 0,
    partnerAName = "Parceiro A",
    partnerBName = "Parceiro B",
  } = input;

  let totalSharedExpenses = 0;
  let totalPaidByPartnerA = 0;
  let totalPaidByPartnerB = 0;

  for (const exp of expenses) {
    const amt = Math.abs(Number(exp.amount) || 0);
    totalSharedExpenses += amt;

    if (exp.payer === "partner_a") {
      totalPaidByPartnerA += amt;
    } else if (exp.payer === "partner_b") {
      totalPaidByPartnerB += amt;
    } else {
      // Both paid equally at the moment
      totalPaidByPartnerA += amt / 2;
      totalPaidByPartnerB += amt / 2;
    }
  }

  totalSharedExpenses = Math.round(totalSharedExpenses * 100) / 100;
  totalPaidByPartnerA = Math.round(totalPaidByPartnerA * 100) / 100;
  totalPaidByPartnerB = Math.round(totalPaidByPartnerB * 100) / 100;

  let partnerASharePercent = 50;
  let partnerBSharePercent = 50;

  if (splitMode === "proportional_by_income") {
    const totalIncome = partnerAIncome + partnerBIncome;
    if (totalIncome > 0) {
      partnerASharePercent = Math.round((partnerAIncome / totalIncome) * 1000) / 10;
      partnerBSharePercent = Math.round((100 - partnerASharePercent) * 10) / 10;
    }
  }

  const fairSharePartnerA =
    Math.round(((totalSharedExpenses * partnerASharePercent) / 100) * 100) / 100;
  const fairSharePartnerB =
    Math.round(((totalSharedExpenses * partnerBSharePercent) / 100) * 100) / 100;

  const netBalanceA = Math.round((totalPaidByPartnerA - fairSharePartnerA) * 100) / 100;

  let debtor: CoupleFinanceResult["debtor"] = "settled";
  let settlementAmount = 0;
  let statusMessage = "Contas do casal 100% equilibradas!";

  if (netBalanceA > 0.01) {
    debtor = "partner_b";
    settlementAmount = netBalanceA;
    statusMessage = `${partnerBName} transfere R$ ${settlementAmount.toFixed(2).replace(".", ",")} para ${partnerAName}`;
  } else if (netBalanceA < -0.01) {
    debtor = "partner_a";
    settlementAmount = Math.abs(netBalanceA);
    statusMessage = `${partnerAName} transfere R$ ${settlementAmount.toFixed(2).replace(".", ",")} para ${partnerBName}`;
  }

  return {
    totalSharedExpenses,
    totalPaidByPartnerA,
    totalPaidByPartnerB,
    partnerASharePercent,
    partnerBSharePercent,
    fairSharePartnerA,
    fairSharePartnerB,
    debtor,
    settlementAmount,
    statusMessage,
    expenses,
  };
}
