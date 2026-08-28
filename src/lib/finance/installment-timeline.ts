import { addMonths, monthLabel } from "./local-date";

export type InstallmentPurchase = {
  id: string;
  description: string;
  installmentAmount: number;
  currentInstallment: number;
  totalInstallments: number;
  remainingInstallments: number;
  startMonth: string; // YYYY-MM
};

export type ActiveInstallmentItem = {
  purchaseId: string;
  description: string;
  amount: number;
  installmentNumber: number;
  totalInstallments: number;
};

export type TimelineMonth = {
  month: string; // YYYY-MM
  monthLabel: string;
  totalAmount: number;
  activeCount: number;
  items: ActiveInstallmentItem[];
};

export type FinancialReliefItem = {
  finishedPurchaseName: string;
  lastInstallmentMonth: string; // YYYY-MM
  reliefMonth: string; // YYYY-MM
  liberatedAmount: number;
};

export type FinancialReliefSchedule = {
  nextReliefMonth: string | null;
  nextReliefAmount: number;
  reliefItems: FinancialReliefItem[];
};

type InputInvoice = {
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
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  competence_date?: string;
};

/**
 * Normaliza e extrai compras parceladas de faturas de cartão de crédito e transações.
 */
export function extractInstallmentPurchases(
  invoices: InputInvoice[] = [],
  transactions: InputTransaction[] = []
): InstallmentPurchase[] {
  const purchasesMap = new Map<string, InstallmentPurchase>();

  // 1. Processa faturas com parcelas estruturadas
  for (const inv of invoices) {
    const month = inv.due_date ? inv.due_date.slice(0, 7) : new Date().toISOString().slice(0, 7);
    const installments = inv.credit_card_installments || [];

    for (const inst of installments) {
      const p = Array.isArray(inst.credit_card_purchases)
        ? inst.credit_card_purchases[0]
        : inst.credit_card_purchases;

      const desc = (p?.description || "Compra Parcelada").trim();
      const current = Number(inst.installment_number) || 1;
      const total = Number(p?.installment_count) || current;
      const amount = Number(inst.amount) || 0;
      const remaining = Math.max(0, total - current + 1);

      const key = `${desc}-${amount}-${total}`;
      if (!purchasesMap.has(key)) {
        purchasesMap.set(key, {
          id: `inst-inv-${purchasesMap.size + 1}`,
          description: desc,
          installmentAmount: Math.round(amount * 100) / 100,
          currentInstallment: current,
          totalInstallments: total,
          remainingInstallments: remaining,
          startMonth: month,
        });
      }
    }
  }

  // 2. Processa transações com padrão de parcela no texto (ex: "Compra 02/10" ou "(1 de 6)")
  const installmentRegex = /^(.*?)\s*\(?(\d{1,2})\s*(?:\/|de)\s*(\d{1,2})\)?\s*$/i;

  for (const tx of transactions) {
    const desc = (tx.description || "").trim();
    const match = desc.match(installmentRegex);

    if (match) {
      const baseDesc = match[1].trim() || "Compra Parcelada";
      const current = Number(match[2]);
      const total = Number(match[3]);
      const amount = Number(tx.amount) || 0;
      const month = tx.competence_date
        ? tx.competence_date.slice(0, 7)
        : new Date().toISOString().slice(0, 7);

      if (total >= 2 && current <= total) {
        const key = `${baseDesc}-${amount}-${total}`;
        if (!purchasesMap.has(key)) {
          purchasesMap.set(key, {
            id: `inst-tx-${tx.id}`,
            description: baseDesc,
            installmentAmount: Math.round(amount * 100) / 100,
            currentInstallment: current,
            totalInstallments: total,
            remainingInstallments: Math.max(0, total - current + 1),
            startMonth: month,
          });
        }
      }
    }
  }

  return Array.from(purchasesMap.values());
}

/**
 * Constrói a linha do tempo dos próximos meses com total de parcelas comprometidas.
 */
export function buildInstallmentTimeline(
  purchases: InstallmentPurchase[],
  startMonth: string, // YYYY-MM
  totalMonths: number = 6
): TimelineMonth[] {
  const normalizedStart = startMonth.length === 7 ? `${startMonth}-01` : startMonth;
  const timeline: TimelineMonth[] = [];

  for (let offset = 0; offset < totalMonths; offset++) {
    const currentMonthStart = addMonths(normalizedStart, offset);
    const monthKey = currentMonthStart.slice(0, 7);
    const label = monthLabel(currentMonthStart);

    let totalAmount = 0;
    const activeItems: ActiveInstallmentItem[] = [];

    for (const p of purchases) {
      // Quantas parcelas já se passaram desde startMonth do purchase até monthKey
      const purchaseStart = p.startMonth.length === 7 ? `${p.startMonth}-01` : p.startMonth;
      
      // Diferença em meses entre currentMonthStart e purchaseStart
      const [curYear, curMonth] = currentMonthStart.split("-").map(Number);
      const [purYear, purMonth] = purchaseStart.split("-").map(Number);
      const monthDiff = (curYear - purYear) * 12 + (curMonth - purMonth);

      const targetInstallmentNumber = p.currentInstallment + monthDiff;

      if (
        monthDiff >= 0 &&
        targetInstallmentNumber >= 1 &&
        targetInstallmentNumber <= p.totalInstallments
      ) {
        totalAmount += p.installmentAmount;
        activeItems.push({
          purchaseId: p.id,
          description: p.description,
          amount: p.installmentAmount,
          installmentNumber: targetInstallmentNumber,
          totalInstallments: p.totalInstallments,
        });
      }
    }

    timeline.push({
      month: monthKey,
      monthLabel: label,
      totalAmount: Math.round(totalAmount * 100) / 100,
      activeCount: activeItems.length,
      items: activeItems,
    });
  }

  return timeline;
}

/**
 * Identifica o término de cada compra parcelada e o valor liberado no orçamento futuro.
 */
export function computeFinancialReliefSchedule(
  purchases: InstallmentPurchase[],
  currentMonth: string // YYYY-MM
): FinancialReliefSchedule {
  const reliefItems: FinancialReliefItem[] = [];

  for (const p of purchases) {
    const purchaseStart = p.startMonth.length === 7 ? `${p.startMonth}-01` : p.startMonth;
    const remainingCount = p.totalInstallments - p.currentInstallment; // meses adicionais até o fim

    const lastMonthStart = addMonths(purchaseStart, remainingCount);
    const lastMonthKey = lastMonthStart.slice(0, 7);

    // O alívio ocorre no mês imediatamente seguinte ao pagamento da última parcela
    const reliefMonthStart = addMonths(lastMonthStart, 1);
    const reliefMonthKey = reliefMonthStart.slice(0, 7);

    reliefItems.push({
      finishedPurchaseName: p.description,
      lastInstallmentMonth: lastMonthKey,
      reliefMonth: reliefMonthKey,
      liberatedAmount: p.installmentAmount,
    });
  }

  reliefItems.sort((a, b) => a.reliefMonth.localeCompare(b.reliefMonth));

  const nextRelief = reliefItems.find((r) => r.reliefMonth > currentMonth) || reliefItems[0] || null;

  return {
    nextReliefMonth: nextRelief ? nextRelief.reliefMonth : null,
    nextReliefAmount: nextRelief ? nextRelief.liberatedAmount : 0,
    reliefItems,
  };
}
