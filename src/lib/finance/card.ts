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
