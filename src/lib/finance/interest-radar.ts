import type { Transaction } from "@/app/components/types";
import { filterOutTransfers } from "./transfers";

export type InterestItem = {
  id: string;
  description: string;
  amount: number;
  date: string;
  category: "interest" | "fee" | "fine" | "iof" | "other_charge";
};

export type InterestSummary = {
  totalInterestAndFees: number;
  items: InterestItem[];
  hasAlert: boolean;
};

export type PrepaymentSimulationInput = {
  installmentValue: number;
  remainingCount: number;
  annualDiscountRate?: number; // Ex: 10% a.a. Nubank/Itaú standard
};

export type PrepaymentSimulationResult = {
  totalOriginal: number;
  totalWithDiscount: number;
  totalSaved: number;
  discountPercent: number;
};

export type HiddenCostAlert = {
  transactionId: string;
  description: string;
  amount: number;
  type: "pix_credit" | "revolving_card" | "high_fee";
  reason: string;
};

const INTEREST_KEYWORDS = [
  { pattern: /\bjuros\b/i, category: "interest" as const },
  { pattern: /\biof\b/i, category: "iof" as const },
  { pattern: /\bmulta\b/i, category: "fine" as const },
  { pattern: /\bencargos?\b/i, category: "interest" as const },
  { pattern: /\btarifa\b/i, category: "fee" as const },
  { pattern: /\banuidade\b/i, category: "fee" as const },
  { pattern: /\bcheque especial\b/i, category: "interest" as const },
];

/**
 * Agrupa todos os juros, taxas, multas e encargos bancários pagos na competência.
 */
export function computeInterestSummary(
  transactions: Transaction[],
  monthStartStr: string
): InterestSummary {
  const nextMonth = new Date(monthStartStr);
  nextMonth.setMonth(nextMonth.getMonth() + 1);
  const nextMonthStr = nextMonth.toISOString().slice(0, 10);

  const monthTxs = filterOutTransfers(transactions).filter(
    (t) =>
      t.type === "expense" &&
      t.competence_date >= monthStartStr &&
      t.competence_date < nextMonthStr
  );

  const items: InterestItem[] = [];
  let total = 0;

  for (const tx of monthTxs) {
    const desc = (tx.description || "").toLowerCase();
    for (const kw of INTEREST_KEYWORDS) {
      if (kw.pattern.test(desc)) {
        const val = Number(tx.amount) || 0;
        items.push({
          id: tx.id,
          description: tx.description || "Sem descrição",
          amount: val,
          date: tx.competence_date,
          category: kw.category,
        });
        total += val;
        break;
      }
    }
  }

  return {
    totalInterestAndFees: Math.round(total * 100) / 100,
    items,
    hasAlert: total > 0,
  };
}

/**
 * Simula a economia ao adiantar parcelas usando a fórmula de juros compostos
 * a valor presente (desconto bancário padrão Nubank/Itaú).
 * VP = PMT / (1 + i_mensal)^n
 */
export function simulatePrepaymentDiscount(
  input: PrepaymentSimulationInput
): PrepaymentSimulationResult {
  const { installmentValue, remainingCount, annualDiscountRate = 12 } = input;

  if (remainingCount <= 0 || installmentValue <= 0 || annualDiscountRate <= 0) {
    return {
      totalOriginal: 0,
      totalWithDiscount: 0,
      totalSaved: 0,
      discountPercent: 0,
    };
  }

  const totalOriginal = installmentValue * remainingCount;
  // Taxa mensal equivalente: (1 + i_ano)^(1/12) - 1
  const monthlyRate = Math.pow(1 + annualDiscountRate / 100, 1 / 12) - 1;

  let totalPV = 0;
  for (let n = 1; n <= remainingCount; n++) {
    const pv = installmentValue / Math.pow(1 + monthlyRate, n);
    totalPV += pv;
  }

  const totalWithDiscount = Math.round(totalPV * 100) / 100;
  const totalSaved = Math.round((totalOriginal - totalWithDiscount) * 100) / 100;
  const discountPercent =
    totalOriginal > 0 ? Math.round((totalSaved / totalOriginal) * 10000) / 100 : 0;

  return {
    totalOriginal: Math.round(totalOriginal * 100) / 100,
    totalWithDiscount,
    totalSaved,
    discountPercent,
  };
}

/**
 * Detecta despesas com custos ocultos como parcelamento de Pix ou juros embutidos.
 */
export function detectHiddenCosts(transactions: Transaction[]): HiddenCostAlert[] {
  const alerts: HiddenCostAlert[] = [];

  for (const tx of transactions) {
    const desc = (tx.description || "").toLowerCase();
    const isPixCredit = /pix.*(cr[ée]dito|parcelado|\d+x)/i.test(desc);

    if (isPixCredit) {
      alerts.push({
        transactionId: tx.id,
        description: tx.description || "Pix no crédito",
        amount: Number(tx.amount) || 0,
        type: "pix_credit",
        reason: "Pix parcelado no cartão costuma ter taxas entre 3.99% e 9.99% ao mês.",
      });
    }
  }

  return alerts;
}
