import type { ProjectionEvent } from "./projection";

export type TodayProjection = {
  nextIncomeDate: string | null;
  projectedBalanceCents: number;
  lowestBalanceCents: number;
  lowestBalanceDate: string | null;
};

function assertDate(value: string, field: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value) || Number.isNaN(new Date(`${value}T00:00:00.000Z`).getTime())) {
    throw new RangeError(`${field} must use a valid YYYY-MM-DD date.`);
  }
}

function assertCents(value: number, field: string) {
  if (!Number.isSafeInteger(value) || value < 0) throw new RangeError(`${field} must be a non-negative safe integer.`);
}

/** Projects dated income and expenses from today through the first later income, inclusively. */
export function projectUntilNextIncome(
  events: readonly ProjectionEvent[],
  currentBalanceCents: number,
  today: string,
): TodayProjection {
  assertDate(today, "Today");
  if (!Number.isSafeInteger(currentBalanceCents)) throw new RangeError("Current balance must be a safe integer.");

  for (const event of events) {
    assertDate(event.date, "Event date");
    assertCents(event.amountCents, "Event amount");
  }

  const nextIncomeDate = events
    .filter((event) => event.type === "income" && event.date > today)
    .map((event) => event.date)
    .sort()[0] ?? null;

  if (!nextIncomeDate) {
    return { nextIncomeDate: null, projectedBalanceCents: currentBalanceCents, lowestBalanceCents: currentBalanceCents, lowestBalanceDate: today };
  }

  let balanceCents = currentBalanceCents;
  let lowestBalanceCents = currentBalanceCents;
  let lowestBalanceDate = today;
  for (const event of events.filter((event) => event.date >= today && event.date <= nextIncomeDate).sort((a, b) => a.date.localeCompare(b.date))) {
    balanceCents += event.type === "income" ? event.amountCents : -event.amountCents;
    if (balanceCents < lowestBalanceCents) {
      lowestBalanceCents = balanceCents;
      lowestBalanceDate = event.date;
    }
  }

  return { nextIncomeDate, projectedBalanceCents: balanceCents, lowestBalanceCents, lowestBalanceDate };
}
