import { describe, expect, it } from "vitest";

import { periodRange, type PeriodKey } from "./PeriodFilter";

const ISO = /^\d{4}-\d{2}-\d{2}$/;

/** Primeiro dia do mês deslocado, derivado da data atual (nada fixo). */
const monthStartOffset = (offset: number) => {
  const now = new Date();
  const date = new Date(now.getFullYear(), now.getMonth() + offset, 1);
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-01`;
};

const KEYS: PeriodKey[] = ["month", "last-month", "3months", "year", "all"];

describe("periodRange", () => {
  it("devolve um label não vazio para todas as chaves", () => {
    for (const key of KEYS) {
      expect(periodRange(key).label.length).toBeGreaterThan(0);
    }
  });

  it("usa o formato YYYY-MM-DD e start < end quando há limites", () => {
    for (const key of KEYS) {
      const { start, end } = periodRange(key);
      if (start === null || end === null) continue;
      expect(start).toMatch(ISO);
      expect(end).toMatch(ISO);
      expect(start < end).toBe(true);
    }
  });

  it("cobre o mês corrente em 'month'", () => {
    const range = periodRange("month");
    expect(range.start).toBe(monthStartOffset(0));
    expect(range.end).toBe(monthStartOffset(1));
    expect(range.label).toBe("Este mês");
  });

  it("cobre o mês anterior em 'last-month'", () => {
    const range = periodRange("last-month");
    expect(range.start).toBe(monthStartOffset(-1));
    expect(range.end).toBe(monthStartOffset(0));
    expect(range.label).toBe("Mês passado");
  });

  it("cobre três meses em '3months'", () => {
    const range = periodRange("3months");
    expect(range.start).toBe(monthStartOffset(-2));
    expect(range.end).toBe(monthStartOffset(1));
    expect(range.label).toBe("Últimos 3 meses");
  });

  it("cobre o ano corrente em 'year'", () => {
    const year = new Date().getFullYear();
    const range = periodRange("year");
    expect(range.start).toBe(`${year}-01-01`);
    expect(range.end).toBe(`${year + 1}-01-01`);
    expect(range.label).toBe("Este ano");
  });

  it("não impõe limites em 'all'", () => {
    expect(periodRange("all")).toEqual({
      start: null,
      end: null,
      label: "Todo o período",
    });
  });
});
