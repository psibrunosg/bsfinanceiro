import { describe, expect, it } from "vitest";
import { extractSelectablePdfText } from "./pdf-text";
import { textualPdfWithText } from "./pdf-test-fixture";

const parserModule = await import("./santander-statement").catch(() => null);
const parseSantanderStatement = async (text: string) => {
  expect(parserModule).not.toBeNull();
  return parserModule!.parseSantanderStatement(text);
};
const parseBrazilianCurrencyCents = (value: string) => {
  expect(parserModule).not.toBeNull();
  return parserModule!.parseBrazilianCurrencyCents(value);
};

const statement = `
  Esta é a fatura do seu cartão SANTANDER
  Fatura de agosto de 2026
  Total a Pagar R$ 223,35
  VENCIMENTO 22/08/2026
  Compras e pagamentos realizados até 15/08/2026
  Lançamentos
  10/08 MERCADO EXEMPLO R$ 23,45
  12/08 LIVRARIA MODELO 02/10 R$ 199,90 Total da compra R$ 1.999,00
  Limites
  Limite disponível R$ 1.000,00
`;

describe("parseSantanderStatement", () => {
  it("parses the allow-listed Santander layout without confusing installment and purchase totals", async () => {
    const parsed = await parseSantanderStatement(statement);

    expect(parsed).toMatchObject({
      parserName: "santander",
      parserVersion: "1",
      closingDate: "2026-08-15",
      dueDate: "2026-08-22",
      declaredTotalCents: 22335,
      items: [
        {
          ordinal: 1,
          purchasedOn: "2026-08-10",
          description: "MERCADO EXEMPLO",
          installmentAmountCents: 2345,
          installmentNumber: 1,
          installmentCount: 1,
          totalAmountCents: 2345,
          needsReview: false,
        },
        {
          ordinal: 2,
          purchasedOn: "2026-08-12",
          description: "LIVRARIA MODELO",
          installmentAmountCents: 19990,
          installmentNumber: 2,
          installmentCount: 10,
          totalAmountCents: 199900,
          needsReview: false,
        },
      ],
    });
    expect(parsed.items[0].sourceFingerprint).toMatch(/^[a-f0-9]{64}$/);
    expect(parsed.items[1].sourceFingerprint).toMatch(/^[a-f0-9]{64}$/);
    expect((await parseSantanderStatement(statement)).items.map((item) => item.sourceFingerprint))
      .toEqual(parsed.items.map((item) => item.sourceFingerprint));
  });

  it("parses text extracted from a fictitious Santander-shaped PDF", async () => {
    const { text } = await extractSelectablePdfText(textualPdfWithText(statement
      .replaceAll("é", "e").replaceAll("ã", "a").replaceAll("ç", "c").replaceAll("á", "a").replaceAll("í", "i")));
    await expect(parseSantanderStatement(text)).resolves.toMatchObject({
      declaredTotalCents: 22335,
      dueDate: "2026-08-22",
      items: [{ description: "MERCADO EXEMPLO" }, { installmentNumber: 2, installmentCount: 10 }],
    });
  });

  it("never fabricates the original total when an installment line omits it", async () => {
    const parsed = await parseSantanderStatement(statement.replace(" Total da compra R$ 1.999,00", ""));

    expect(parsed.items[1]).toMatchObject({
      installmentAmountCents: 19990,
      installmentNumber: 2,
      installmentCount: 10,
      totalAmountCents: null,
      needsReview: true,
    });
  });

  it("infers a purchase year locally across the statement year boundary", async () => {
    const parsed = await parseSantanderStatement(statement
      .replace("15/08/2026", "15/01/2027")
      .replace("22/08/2026", "22/01/2027")
      .replace("10/08 MERCADO", "20/12 MERCADO")
      .replace("12/08 LIVRARIA", "02/01 LIVRARIA"));

    expect(parsed.items.map((item) => item.purchasedOn)).toEqual(["2026-12-20", "2027-01-02"]);
  });

  it.each([
    [statement.replace("SANTANDER", "OUTRO BANCO"), "unsupported_layout"],
    [statement.replace("R$ 199,90 Total", "Total"), "ambiguous_financial_fields"],
    [statement.replace("Total da compra R$ 1.999,00", "Total da compra R$ 1.999,00 Total da compra R$ 2.000,00"), "ambiguous_financial_fields"],
    [statement.replace("15/08/2026", "31/02/2026"), "ambiguous_financial_fields"],
  ])("fails closed for unsupported, missing, duplicate, or impossible fields", async (text, code) => {
    await expect(parseSantanderStatement(text)).rejects.toThrow(code);
  });
});

describe("parseBrazilianCurrencyCents", () => {
  it.each([
    ["R$ 1.234,56", 123456],
    ["1.234,56", 123456],
    ["12,34", 1234],
  ])("parses %s without floating-point rounding", (value, cents) => {
    expect(parseBrazilianCurrencyCents(value)).toBe(cents);
  });

  it.each(["1,234.56", "-12,34", "12,345", "1.23,45"])("rejects ambiguous money %s", (value) => {
    expect(() => parseBrazilianCurrencyCents(value)).toThrow("ambiguous_financial_fields");
  });
});
