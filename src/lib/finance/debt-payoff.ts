import { addMonths, monthLabel } from "./local-date";

export type DebtCategory = "cartao" | "emprestimo" | "financiamento" | "outros";

export type DebtItem = {
  id: string;
  name: string;
  balance: number;
  interestRateAnnual: number; // Porcentagem ao ano (ex: 45 para 45% a.a.)
  minimumMonthlyPayment: number;
  category: DebtCategory;
};

export type DebtPayoffOrder = {
  debtId: string;
  debtName: string;
  monthsToPayoff: number;
  payoffMonth: string; // YYYY-MM
  payoffMonthLabel: string;
  totalInterestPaid: number;
};

export type DebtPayoffSimulation = {
  strategy: "snowball" | "avalanche";
  extraMonthlyPayment: number;
  totalInitialDebt: number;
  totalMonths: number;
  debtFreeDate: string; // YYYY-MM
  debtFreeDateLabel: string;
  totalInterestPaid: number;
  interestSaved: number;
  monthsSaved: number;
  payoffOrder: DebtPayoffOrder[];
};

export type SimulateDebtPayoffInput = {
  debts: DebtItem[];
  strategy?: "snowball" | "avalanche";
  extraMonthlyPayment?: number;
  startMonth?: string; // YYYY-MM
};

/**
 * Simula a amortização com juros compostos mês a mês sob uma dada estratégia.
 */
export function simulateDebtPayoff(input: SimulateDebtPayoffInput): DebtPayoffSimulation {
  const {
    debts,
    strategy = "avalanche",
    extraMonthlyPayment = 0,
    startMonth = new Date().toISOString().slice(0, 7),
  } = input;

  const validDebts = debts.filter((d) => d.balance > 0);
  const totalInitialDebt = validDebts.reduce((sum, d) => sum + d.balance, 0);

  if (validDebts.length === 0) {
    const monthStart = startMonth.length === 7 ? `${startMonth}-01` : startMonth;
    return {
      strategy,
      extraMonthlyPayment,
      totalInitialDebt: 0,
      totalMonths: 0,
      debtFreeDate: startMonth.slice(0, 7),
      debtFreeDateLabel: monthLabel(monthStart),
      totalInterestPaid: 0,
      interestSaved: 0,
      monthsSaved: 0,
      payoffOrder: [],
    };
  }

  // 1. Simulação Base (sem aporte extra) para calcular economia
  const baseline = runSimulationLoop(validDebts, strategy, 0, startMonth);

  // 2. Simulação com o aporte extra especificado
  const simulated =
    extraMonthlyPayment > 0
      ? runSimulationLoop(validDebts, strategy, extraMonthlyPayment, startMonth)
      : baseline;

  const interestSaved = Math.max(0, baseline.totalInterestPaid - simulated.totalInterestPaid);
  const monthsSaved = Math.max(0, baseline.totalMonths - simulated.totalMonths);

  return {
    strategy,
    extraMonthlyPayment,
    totalInitialDebt: Math.round(totalInitialDebt * 100) / 100,
    totalMonths: simulated.totalMonths,
    debtFreeDate: simulated.debtFreeDate,
    debtFreeDateLabel: simulated.debtFreeDateLabel,
    totalInterestPaid: Math.round(simulated.totalInterestPaid * 100) / 100,
    interestSaved: Math.round(interestSaved * 100) / 100,
    monthsSaved,
    payoffOrder: simulated.payoffOrder,
  };
}

type SimulationInternalResult = {
  totalMonths: number;
  debtFreeDate: string;
  debtFreeDateLabel: string;
  totalInterestPaid: number;
  payoffOrder: DebtPayoffOrder[];
};

function runSimulationLoop(
  initialDebts: DebtItem[],
  strategy: "snowball" | "avalanche",
  extraMonthlyPayment: number,
  startMonth: string
): SimulationInternalResult {
  // Ordena as dívidas conforme a estratégia
  // Snowball: Menor saldo primeiro
  // Avalanche: Maior taxa de juros primeiro
  const sortedDebts = [...initialDebts].sort((a, b) => {
    if (strategy === "snowball") {
      return a.balance - b.balance;
    } else {
      return b.interestRateAnnual - a.interestRateAnnual;
    }
  });

  // Estado mutável de trabalho
  const debtsState = sortedDebts.map((d) => ({
    id: d.id,
    name: d.name,
    balance: d.balance,
    monthlyRate: Math.pow(1 + d.interestRateAnnual / 100, 1 / 12) - 1,
    minPayment: Math.max(10, d.minimumMonthlyPayment),
    interestPaid: 0,
    isPaid: false,
    monthsToPayoff: 0,
  }));

  const startNormalized = startMonth.length === 7 ? `${startMonth}-01` : startMonth;
  let currentMonthIndex = 0;
  let totalInterest = 0;
  const payoffOrder: DebtPayoffOrder[] = [];

  // Limite máximo de 360 meses (30 anos) para evitar loop infinito
  const maxMonths = 360;

  while (debtsState.some((d) => !d.isPaid) && currentMonthIndex < maxMonths) {
    currentMonthIndex++;
    const currentMonthStart = addMonths(startNormalized, currentMonthIndex - 1);
    const currentMonthKey = currentMonthStart.slice(0, 7);

    // 1. Aplica juros mensais
    for (const d of debtsState) {
      if (!d.isPaid) {
        const monthlyInterest = d.balance * d.monthlyRate;
        d.balance += monthlyInterest;
        d.interestPaid += monthlyInterest;
        totalInterest += monthlyInterest;
      }
    }

    // 2. Paga os mínimos de cada dívida e acumula o rollover das já quitadas
    let availableExtra = extraMonthlyPayment;

    for (const d of debtsState) {
      if (d.isPaid) {
        // Efeito Bola de Neve: o valor que pagava na dívida quitada vira aporte extra!
        availableExtra += d.minPayment;
      } else {
        const payment = Math.min(d.balance, d.minPayment);
        d.balance -= payment;

        if (d.balance <= 0.01) {
          d.isPaid = true;
          d.monthsToPayoff = currentMonthIndex;
          payoffOrder.push({
            debtId: d.id,
            debtName: d.name,
            monthsToPayoff: currentMonthIndex,
            payoffMonth: currentMonthKey,
            payoffMonthLabel: monthLabel(currentMonthStart),
            totalInterestPaid: Math.round(d.interestPaid * 100) / 100,
          });
        }
      }
    }

    // 3. Aplica o valor extra acumulado na dívida prioritária ativa
    for (const d of debtsState) {
      if (!d.isPaid && availableExtra > 0) {
        const extraPay = Math.min(d.balance, availableExtra);
        d.balance -= extraPay;
        availableExtra -= extraPay;

        if (d.balance <= 0.01) {
          d.isPaid = true;
          d.monthsToPayoff = currentMonthIndex;
          payoffOrder.push({
            debtId: d.id,
            debtName: d.name,
            monthsToPayoff: currentMonthIndex,
            payoffMonth: currentMonthKey,
            payoffMonthLabel: monthLabel(currentMonthStart),
            totalInterestPaid: Math.round(d.interestPaid * 100) / 100,
          });
        }
      }
    }
  }

  const finalMonthStart = addMonths(startNormalized, Math.max(0, currentMonthIndex - 1));
  const finalMonthKey = finalMonthStart.slice(0, 7);

  return {
    totalMonths: currentMonthIndex,
    debtFreeDate: finalMonthKey,
    debtFreeDateLabel: monthLabel(finalMonthStart),
    totalInterestPaid: totalInterest,
    payoffOrder,
  };
}

type FinancialDataInput = {
  accounts?: { id: string; name: string; type: string; initial_balance: number }[];
  invoices?: {
    id: string;
    due_date: string;
    credit_card_installments?:
      | {
          amount: number | string;
          installment_number: number;
          credit_card_purchases?:
            | { description: string; installment_count: number }
            | { description: string; installment_count: number }[]
            | null;
        }[]
      | null;
  }[];
  transactions?: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
  }[];
};

/**
 * Extrai dívidas e passivos a partir das contas bancárias (cheque especial) e faturas.
 */
export function extractDebtsFromFinancialData(data: FinancialDataInput): DebtItem[] {
  const debts: DebtItem[] = [];

  // 1. Contas bancárias no vermelho (cheque especial)
  const accounts = data.accounts || [];
  for (const acc of accounts) {
    const bal = Number(acc.initial_balance) || 0;
    if (bal < 0) {
      debts.push({
        id: `acc-debt-${acc.id}`,
        name: `Cheque Especial (${acc.name})`,
        balance: Math.abs(bal),
        interestRateAnnual: 140, // Cheque especial médio ~140% a.a. no Brasil
        minimumMonthlyPayment: Math.max(50, Math.round(Math.abs(bal) * 0.15)),
        category: "outros",
      });
    }
  }

  return debts;
}
