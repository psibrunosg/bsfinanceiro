import { describe, expect, it } from "vitest";
import { parseStatementCsv } from "./statement-csv";

describe("parseStatementCsv", () => {
  it("recognizes common headers and parses income and expense amounts into cents", () => {
    const preview = parseStatementCsv(
      "date,description,amount\n2026-07-29,Salário,1000\n2026-07-30,Café,-12,50",
    );

    expect(preview).toMatchObject({
      headers: ["date", "description", "amount"],
      valid: 2,
      invalid: 0,
    });
    expect(preview.items).toEqual([
      expect.objectContaining({
        rowNumber: 2,
        competenceDate: "2026-07-29",
        description: "Salário",
        amountCents: 100_000,
        type: "income",
        fingerprint: "2026-07-29|100000|income|salario",
      }),
      expect.objectContaining({
        rowNumber: 3,
        competenceDate: "2026-07-30",
        description: "Café",
        amountCents: 1_250,
        type: "expense",
        fingerprint: "2026-07-30|1250|expense|cafe",
      }),
    ]);
  });

  it("accepts semicolon-delimited Brazilian columns and explicit mappings", () => {
    const preview = parseStatementCsv(
      "Lançamento;Histórico;Valor (R$)\n29/07/2026;Mercado;1.234,56\n30/07/2026;Estorno;+10,00",
      { date: "Lançamento", description: "Histórico", amount: "Valor (R$)" },
    );

    expect(preview).toMatchObject({ valid: 2, invalid: 0 });
    expect(preview.items).toEqual([
      expect.objectContaining({
        competenceDate: "2026-07-29",
        amountCents: 123_456,
        type: "income",
      }),
      expect.objectContaining({
        competenceDate: "2026-07-30",
        amountCents: 1_000,
        type: "income",
      }),
    ]);
  });

  it("keeps invalid rows in the preview without preventing valid rows", () => {
    const preview = parseStatementCsv(
      "date,description,amount\n31/02/2026,Data impossível,10\n2026-07-30,,20\n2026-07-31,Valor inválido,abc\n2026-08-01,Válida,-0,01",
    );

    expect(preview).toMatchObject({ valid: 1, invalid: 3 });
    expect(preview.items).toEqual([
      expect.objectContaining({ rowNumber: 2, reason: "invalid_date" }),
      expect.objectContaining({ rowNumber: 3, reason: "missing_description" }),
      expect.objectContaining({ rowNumber: 4, reason: "invalid_amount" }),
      expect.objectContaining({
        rowNumber: 5,
        competenceDate: "2026-08-01",
        amountCents: 1,
        type: "expense",
      }),
    ]);
  });

  it("rejects malformed and incomplete monetary separators instead of truncating them", () => {
    const preview = parseStatementCsv(
      "date,description,amount\n2026-08-01,Pontos,12.3.4\n2026-08-02,Virgulas,1,2,3\n2026-08-03,Vazio,12,",
    );

    expect(preview).toMatchObject({ valid: 0, invalid: 3 });
    expect(preview.items).toEqual([
      expect.objectContaining({ rowNumber: 2, reason: "invalid_amount" }),
      expect.objectContaining({ rowNumber: 3, reason: "invalid_amount" }),
      expect.objectContaining({ rowNumber: 4, reason: "invalid_amount" }),
    ]);
  });

  it("accepts isolated thousands separators", () => {
    const preview = parseStatementCsv(
      "date;description;amount\n2026-08-01;Milhar americano;1,234\n2026-08-02;Milhar brasileiro;1.234",
    );

    expect(preview).toMatchObject({ valid: 2, invalid: 0 });
    expect(preview.items).toEqual([
      expect.objectContaining({ amountCents: 123_400 }),
      expect.objectContaining({ amountCents: 123_400 }),
    ]);
  });

  it("reports every data row as invalid when required columns cannot be mapped", () => {
    const preview = parseStatementCsv("quando,narrativa,total\n2026-07-29,Teste,10");

    expect(preview).toMatchObject({ valid: 0, invalid: 1 });
    expect(preview.items[0]).toMatchObject({ rowNumber: 2, reason: "missing_mapping" });
  });

  it("marks descriptions and amounts that violate import-item limits as invalid", () => {
    const preview = parseStatementCsv(
      `date,description,amount\n2026-07-29,${"a".repeat(161)},10\n2026-07-30,Valor alto,1000000000000`,
    );

    expect(preview).toMatchObject({ valid: 0, invalid: 2 });
    expect(preview.items).toEqual([
      expect.objectContaining({ rowNumber: 2, reason: "invalid_description" }),
      expect.objectContaining({ rowNumber: 3, reason: "invalid_amount" }),
    ]);
  });
});
