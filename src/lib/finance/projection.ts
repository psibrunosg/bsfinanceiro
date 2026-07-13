export type ProjectionEvent = {
  date: string;
  type: "income" | "expense";
  amountCents: number;
};

export type WeeklyProjection = {
  weekStart: string;
  weekEnd: string;
  incomeCents: number;
  expenseCents: number;
  netCents: number;
  balanceCents: number;
};

const DAY_IN_MS = 24 * 60 * 60 * 1_000;

function parseIsoDate(date: string): Date {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    throw new RangeError("Event date must use YYYY-MM-DD format.");
  }

  const parsed = new Date(`${date}T00:00:00.000Z`);
  if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== date) {
    throw new RangeError("Event date must be a valid calendar date.");
  }

  return parsed;
}

function formatIsoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function getWeekStart(date: Date): Date {
  const day = date.getUTCDay();
  const daysSinceMonday = day === 0 ? 6 : day - 1;
  return new Date(date.getTime() - daysSinceMonday * DAY_IN_MS);
}

function assertCents(value: number, field: string): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(`${field} must be a non-negative safe integer.`);
  }
}

export function projectWeekly(
  events: readonly ProjectionEvent[],
  initialBalanceCents = 0,
): WeeklyProjection[] {
  if (!Number.isSafeInteger(initialBalanceCents)) {
    throw new RangeError("Initial balance must be a safe integer.");
  }

  const weeks = new Map<string, Omit<WeeklyProjection, "netCents" | "balanceCents">>();

  for (const event of events) {
    assertCents(event.amountCents, "Event amount");
    const weekStartDate = getWeekStart(parseIsoDate(event.date));
    const weekStart = formatIsoDate(weekStartDate);
    const current = weeks.get(weekStart) ?? {
      weekStart,
      weekEnd: formatIsoDate(new Date(weekStartDate.getTime() + 6 * DAY_IN_MS)),
      incomeCents: 0,
      expenseCents: 0,
    };

    if (event.type === "income") {
      current.incomeCents += event.amountCents;
    } else {
      current.expenseCents += event.amountCents;
    }

    weeks.set(weekStart, current);
  }

  let balanceCents = initialBalanceCents;
  return [...weeks.values()]
    .sort((left, right) => left.weekStart.localeCompare(right.weekStart))
    .map((week) => {
      const netCents = week.incomeCents - week.expenseCents;
      balanceCents += netCents;
      return { ...week, netCents, balanceCents };
    });
}
