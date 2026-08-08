"use client";

export type PeriodKey = "month" | "last-month" | "3months" | "year" | "all";

export type PeriodRange = {
  start: string | null;
  end: string | null;
  label: string;
};

/** Formata um Date local como `YYYY-MM-DD`, sem passar por UTC. */
const ymd = (date: Date) =>
  `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(
    date.getDate(),
  ).padStart(2, "0")}`;

/** Primeiro dia do mês deslocado em `offset` meses a partir do mês corrente. */
const monthStartOffset = (offset: number, now = new Date()) =>
  ymd(new Date(now.getFullYear(), now.getMonth() + offset, 1));

/**
 * Intervalo `[start, end)` de cada período. `end` é EXCLUSIVO, para casar com o
 * padrão `>= start && < end` já usado no projeto. `"all"` não tem limites.
 */
export function periodRange(key: PeriodKey): PeriodRange {
  switch (key) {
    case "month":
      return {
        start: monthStartOffset(0),
        end: monthStartOffset(1),
        label: "Este mês",
      };
    case "last-month":
      return {
        start: monthStartOffset(-1),
        end: monthStartOffset(0),
        label: "Mês passado",
      };
    case "3months":
      return {
        start: monthStartOffset(-2),
        end: monthStartOffset(1),
        label: "Últimos 3 meses",
      };
    case "year": {
      const year = new Date().getFullYear();
      return {
        start: `${year}-01-01`,
        end: `${year + 1}-01-01`,
        label: "Este ano",
      };
    }
    case "all":
    default:
      return { start: null, end: null, label: "Todo o período" };
  }
}

const OPTIONS: PeriodKey[] = ["month", "last-month", "3months", "year", "all"];

export function PeriodFilter({
  value,
  onChange,
}: {
  value: PeriodKey;
  onChange: (key: PeriodKey) => void;
}) {
  return (
    <div className="hub-filters">
      <label>
        Período
        <select
          aria-label="Filtrar por período"
          value={value}
          onChange={(event) => onChange(event.target.value as PeriodKey)}
        >
          {OPTIONS.map((key) => (
            <option key={key} value={key}>
              {periodRange(key).label}
            </option>
          ))}
        </select>
      </label>
    </div>
  );
}
