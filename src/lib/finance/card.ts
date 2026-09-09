export type CardInstallment = {
  number: number;
  amountCents: number;
  competenceDate: string;
};

export type CardLimitSummary = {
  limitCents: number;
  usedCents: number;
  availableCents: number;
  utilizationPercent: number;
};

function assertNonNegativeInteger(value: number, field: string) {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(`${field} must be a non-negative safe integer`);
  }
}

function parseDateOnly(value: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) throw new RangeError("startDate must use YYYY-MM-DD");
  const [year, month, day] = value.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) {
    throw new RangeError("startDate must be a valid date");
  }
  return { year, month: month - 1, day };
}

function addMonthsClamped(start: ReturnType<typeof parseDateOnly>, offset: number) {
  const first = new Date(Date.UTC(start.year, start.month + offset, 1));
  const lastDay = new Date(Date.UTC(first.getUTCFullYear(), first.getUTCMonth() + 1, 0)).getUTCDate();
  const date = new Date(Date.UTC(first.getUTCFullYear(), first.getUTCMonth(), Math.min(start.day, lastDay)));
  return date.toISOString().slice(0, 10);
}

/** Splits an integer cent amount exactly, assigning remainder cents to the first installments. */
export function calculateInstallments(totalCents: number, count: number, startDate: string): CardInstallment[] {
  assertNonNegativeInteger(totalCents, "totalCents");
  if (!Number.isSafeInteger(count) || count < 1 || count > 120) {
    throw new RangeError("count must be an integer between 1 and 120");
  }

  const start = parseDateOnly(startDate);
  const base = Math.floor(totalCents / count);
  const remainder = totalCents % count;

  return Array.from({ length: count }, (_, index) => ({
    number: index + 1,
    amountCents: base + (index < remainder ? 1 : 0),
    competenceDate: addMonthsClamped(start, index),
  }));
}

/** Creates a stable card-limit summary without allowing available credit below zero. */
export function summarizeCardLimit(limitCents: number, usedCents: number): CardLimitSummary {
  assertNonNegativeInteger(limitCents, "limitCents");
  assertNonNegativeInteger(usedCents, "usedCents");

  return {
    limitCents,
    usedCents,
    availableCents: Math.max(0, limitCents - usedCents),
    utilizationPercent: limitCents === 0 ? 0 : (usedCents / limitCents) * 100,
  };
}

export type InvoiceForLimit = {
  id?: string;
  credit_card_id?: string;
  account_id?: string;
  status: string;
  due_date?: string | null;
  month?: number | null;
  year?: number | null;
  total_amount?: number | null;
  credit_card_installments?:
    | Array<{
        amount: number | string;
        installment_number: number;
        competence_date?: string | null;
        credit_card_purchases?:
          | { description: string; installment_count: number }
          | { description: string; installment_count: number }[]
          | null;
      }>
    | null;
};

export type TransactionForLimit = {
  id?: string;
  account_id?: string;
  type: string;
  status?: string;
  amount: number | string;
  description?: string | null;
  invoice_id?: string | null;
  competence_date?: string | null;
};

export type CardLimitUsage = {
  creditLimit: number;
  openInvoicesDebt: number;
  futureInstallmentsCommitted: number;
  unbilledTransactionsDebt: number;
  totalUsedLimit: number;
  availableLimit: number;
  utilizationPercent: number;
  activeInstallmentsCount: number;
};

export function normalizePurchaseDescription(desc: string): string {
  return (desc || "")
    .replace(/^Antecipada\s*-\s*/i, "")
    .replace(/\s*-\s*Parcela\s*\d+\s*\/\s*\d+/gi, "")
    .replace(/\s*-\s*\d+\s*\/\s*\d+/gi, "")
    .replace(/\s*\(\s*\d+\s*\/\s*\d+\s*\)/gi, "")
    .replace(/\s*Parcela\s*\d+\s*\/\s*\d+/gi, "")
    .replace(/\s*\(?\d+\s*de\s*\d+\)?/gi, "")
    .trim()
    .toUpperCase();
}

/**
 * Calculates current credit card limit usage, including open invoices and future unbilled installments.
 * As each monthly installment is billed and paid, that portion of the limit is freed up.
 */
export function calculateCardLimitUsage(
  creditLimit: number,
  invoices: InvoiceForLimit[] = [],
  transactions: TransactionForLimit[] = [],
  currentYearMonth?: string
): CardLimitUsage {
  const refYM = currentYearMonth || new Date().toISOString().slice(0, 7);
  const [curYear, curMonth] = refYM.split("-").map(Number);
  const currentYMIndex = (curYear || new Date().getFullYear()) * 12 + (curMonth || new Date().getMonth() + 1);

  // 1. Dívida de faturas abertas / não pagas
  let openInvoicesDebt = 0;
  for (const inv of invoices) {
    if (inv.status !== "paid") {
      const installmentsSum = (inv.credit_card_installments || []).reduce(
        (s, i) => s + Number(i.amount || 0),
        0
      );
      openInvoicesDebt += installmentsSum > 0 ? installmentsSum : Number(inv.total_amount || 0);
    }
  }

  // 2. Parcelas futuras comprometidas de compras parceladas ativas
  type GroupedPurchase = {
    description: string;
    totalInstallments: number;
    billedInstallments: Set<number>;
    installmentAmounts: number[];
    latestYear: number;
    latestMonth: number;
  };

  const purchasesMap = new Map<string, GroupedPurchase>();

  for (const inv of invoices) {
    const invYear = inv.year || (inv.due_date ? Number(inv.due_date.slice(0, 4)) : 0);
    const invMonth = inv.month || (inv.due_date ? Number(inv.due_date.slice(5, 7)) : 0);

    for (const inst of inv.credit_card_installments || []) {
      const p = Array.isArray(inst.credit_card_purchases)
        ? inst.credit_card_purchases[0]
        : inst.credit_card_purchases;

      const rawDesc = (p?.description || "").trim();
      const total = Number(p?.installment_count || 1);
      if (total <= 1) continue;

      const normDesc = normalizePurchaseDescription(rawDesc);
      const key = `${normDesc}|${total}`;

      let item = purchasesMap.get(key);
      if (!item) {
        item = {
          description: normDesc,
          totalInstallments: total,
          billedInstallments: new Set<number>(),
          installmentAmounts: [],
          latestYear: 0,
          latestMonth: 0,
        };
        purchasesMap.set(key, item);
      }

      item.billedInstallments.add(Number(inst.installment_number) || 1);
      item.installmentAmounts.push(Number(inst.amount) || 0);
      if (
        invYear > item.latestYear ||
        (invYear === item.latestYear && invMonth > item.latestMonth)
      ) {
        item.latestYear = invYear;
        item.latestMonth = invMonth;
      }
    }
  }

  // Transações avulsas com parcelamento no texto
  const installmentRegex1 = /^(.*?)\s*\(?(\d{1,2})\s*(?:\/|de)\s*(\d{1,2})\)?\s*$/i;
  const installmentRegex2 = /^(.*?)\s*-\s*Parcela\s*(\d{1,2})\s*\/\s*(\d{1,2})/i;

  for (const tx of transactions) {
    const desc = (tx.description || "").trim();
    const match = desc.match(installmentRegex1) || desc.match(installmentRegex2);
    if (match) {
      const normDesc = normalizePurchaseDescription(match[1]);
      const current = Number(match[2]);
      const total = Number(match[3]);
      const amount = Number(tx.amount) || 0;
      const txYear = tx.competence_date ? Number(tx.competence_date.slice(0, 4)) : 0;
      const txMonth = tx.competence_date ? Number(tx.competence_date.slice(5, 7)) : 0;

      if (total > 1 && current <= total) {
        const key = `${normDesc}|${total}`;
        let item = purchasesMap.get(key);
        if (!item) {
          item = {
            description: normDesc,
            totalInstallments: total,
            billedInstallments: new Set<number>(),
            installmentAmounts: [],
            latestYear: 0,
            latestMonth: 0,
          };
          purchasesMap.set(key, item);
        }

        item.billedInstallments.add(current);
        item.installmentAmounts.push(amount);
        if (
          txYear > item.latestYear ||
          (txYear === item.latestYear && txMonth > item.latestMonth)
        ) {
          item.latestYear = txYear;
          item.latestMonth = txMonth;
        }
      }
    }
  }

  let futureInstallmentsCommitted = 0;
  let activeInstallmentsCount = 0;

  for (const item of purchasesMap.values()) {
    const maxBilled = Math.max(...item.billedInstallments);
    const remaining = Math.max(0, item.totalInstallments - maxBilled);
    const avgAmount =
      item.installmentAmounts.length > 0
        ? item.installmentAmounts.reduce((a, b) => a + b, 0) / item.installmentAmounts.length
        : 0;

    if (remaining > 0 && item.latestYear > 0) {
      const finalMonthIndex = item.latestYear * 12 + item.latestMonth + remaining;
      // Se a última parcela vence no mês de referência ou no futuro, compromete o limite
      if (finalMonthIndex >= currentYMIndex) {
        futureInstallmentsCommitted += remaining * avgAmount;
        activeInstallmentsCount++;
      }
    }
  }

  // 3. Despesas avulsas não vinculadas a fatura e não incluídas em parcelamentos
  let unbilledTransactionsDebt = 0;
  for (const tx of transactions) {
    if (tx.type === "expense" && !tx.invoice_id) {
      const desc = (tx.description || "").trim();
      const match = desc.match(installmentRegex1) || desc.match(installmentRegex2);
      if (!match) {
        unbilledTransactionsDebt += Number(tx.amount) || 0;
      }
    }
  }

  const totalUsedLimit =
    Math.round((openInvoicesDebt + futureInstallmentsCommitted + unbilledTransactionsDebt) * 100) / 100;
  const availableLimit = Math.max(0, Math.round((creditLimit - totalUsedLimit) * 100) / 100);
  const utilizationPercent =
    creditLimit > 0 ? Math.min(100, Math.round((totalUsedLimit / creditLimit) * 10000) / 100) : 0;

  return {
    creditLimit,
    openInvoicesDebt: Math.round(openInvoicesDebt * 100) / 100,
    futureInstallmentsCommitted: Math.round(futureInstallmentsCommitted * 100) / 100,
    unbilledTransactionsDebt: Math.round(unbilledTransactionsDebt * 100) / 100,
    totalUsedLimit,
    availableLimit,
    utilizationPercent,
    activeInstallmentsCount,
  };
}
