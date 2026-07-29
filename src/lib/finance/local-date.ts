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
