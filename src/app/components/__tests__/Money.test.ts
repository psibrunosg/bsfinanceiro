import { describe, expect, it } from "vitest";
import { money, parseMoney, cents, monthStart, nextMonthStart } from "../Money";

describe("parseMoney", () => {
  it("converte valor brasileiro com vírgula para número", () => {
    expect(parseMoney("1.234,56")).toBe(1234.56);
  });

  it("converte valor simples", () => {
    expect(parseMoney("150,00")).toBe(150);
  });

  it("retorna 0 para null e vazio", () => {
    expect(parseMoney(null)).toBe(0);
    expect(parseMoney("")).toBe(0);
  });

  it("trata valor sem decimais", () => {
    expect(parseMoney("500")).toBe(500);
  });
});

describe("money", () => {
  it("formata valor em BRL", () => {
    expect(money(1234.56)).toContain("1.234,56");
  });

  it("formata zero como R$ 0,00", () => {
    expect(money(0)).toContain("0,00");
  });

  it("trata null/undefined como zero", () => {
    expect(money(null)).toContain("0,00");
    expect(money(undefined)).toContain("0,00");
  });
});

describe("cents", () => {
  it("converte reais para centavos", () => {
    expect(cents(10.50)).toBe(1050);
  });

  it("arredonda centavos fracionados", () => {
    expect(cents(10.005)).toBe(1001);
  });

  it("retorna 0 para falsy", () => {
    expect(cents(0)).toBe(0);
    expect(cents(NaN)).toBe(0);
  });
});

describe("monthStart and nextMonthStart", () => {
  it("monthStart retorna primeiro dia do mês atual", () => {
    const result = monthStart();
    expect(result).toMatch(/^\d{4}-\d{2}-01$/);
  });

  it("nextMonthStart retorna primeiro dia do próximo mês", () => {
    const result = nextMonthStart();
    expect(result).toMatch(/^\d{4}-\d{2}-01$/);
    const [, m] = result.split("-").map(Number);
    const now = new Date();
    const expectedMonth = now.getMonth() === 11 ? 1 : now.getMonth() + 2;
    expect(m).toBe(expectedMonth);
  });

  it("nextMonthStart é posterior a monthStart", () => {
    expect(nextMonthStart() > monthStart()).toBe(true);
  });
});
