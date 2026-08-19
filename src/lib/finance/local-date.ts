/** Returns the calendar date in the product's Brazilian time zone. */
export function todayInSaoPaulo(now = new Date()): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "America/Sao_Paulo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  const value = (type: "year" | "month" | "day") => parts.find((part) => part.type === type)?.value;
  return `${value("year")}-${value("month")}-${value("day")}`;
}

/** Returns the current and following calendar months for a São Paulo date. */
export function monthStartsForSaoPauloDate(today: string): [string, string] {
  const [year, month] = today.split("-").map(Number);
  const nextYear = month === 12 ? year + 1 : year;
  const nextMonth = month === 12 ? 1 : month + 1;

  return [
    `${year}-${String(month).padStart(2, "0")}-01`,
    `${nextYear}-${String(nextMonth).padStart(2, "0")}-01`,
  ];
}

/** Shifts a `YYYY-MM-01` month start by `delta` months. */
export function addMonths(monthStart: string, delta: number): string {
  const [year, month] = monthStart.split("-").map(Number);
  const total = year * 12 + (month - 1) + delta;
  return `${Math.floor(total / 12)}-${String((total % 12) + 1).padStart(2, "0")}-01`;
}

/** Half-open range for a month start: `from <= date < toExclusive`. */
export function monthRangeOf(monthStart: string): { from: string; toExclusive: string } {
  return { from: monthStart, toExclusive: addMonths(monthStart, 1) };
}

/** `2026-08-01` -> `ago/2026`. */
export function monthLabel(monthStart: string): string {
  return new Intl.DateTimeFormat("pt-BR", { month: "short", year: "numeric", timeZone: "UTC" })
    .format(new Date(`${monthStart}T12:00:00Z`));
}

/** Lists every calendar month intersecting an inclusive ISO date interval. */
export function monthStartsThroughDate(from: string, through: string): string[] {
  const [fromYear, fromMonth] = from.split("-").map(Number);
  const [throughYear, throughMonth] = through.split("-").map(Number);
  const months: string[] = [];
  let year = fromYear;
  let month = fromMonth;

  while (year < throughYear || (year === throughYear && month <= throughMonth)) {
    months.push(`${year}-${String(month).padStart(2, "0")}-01`);
    if (month === 12) {
      year += 1;
      month = 1;
    } else {
      month += 1;
    }
  }

  return months;
}
