import { describe, expect, it } from "vitest";
import { calculateInstallments, summarizeCardLimit, calculateCardLimitUsage } from "./card";

describe("calculateInstallments", () => {
  it("distributes 100 cents across three installments without losing cents", () => {
    const installments = calculateInstallments(100, 3, "2026-07-15");

    expect(installments.map((item) => item.amountCents)).toEqual([34, 33, 33]);
    expect(installments.reduce((sum, item) => sum + item.amountCents, 0)).toBe(100);
    expect(installments.map((item) => item.number)).toEqual([1, 2, 3]);
    expect(installments.map((item) => item.competenceDate)).toEqual([
      "2026-07-15",
      "2026-08-15",
      "2026-09-15",
    ]);
  });

  it("clamps end-of-month dates and handles leap years", () => {
    expect(calculateInstallments(300, 3, "2028-01-31").map((item) => item.competenceDate)).toEqual([
      "2028-01-31",
      "2028-02-29",
      "2028-03-31",
    ]);
  });

  it("supports a zero-value purchase while preserving installment dates", () => {
    expect(calculateInstallments(0, 2, "2026-11-30")).toEqual([
      { number: 1, amountCents: 0, competenceDate: "2026-11-30" },
      { number: 2, amountCents: 0, competenceDate: "2026-12-30" },
    ]);
  });

  it.each([
    [-1, 1, "2026-01-01"],
    [100, 0, "2026-01-01"],
    [100, 121, "2026-01-01"],
    [100.5, 2, "2026-01-01"],
    [100, 2, "2026-02-30"],
  ] as const)("rejects invalid values", (total, count, date) => {
    expect(() => calculateInstallments(total, count, date)).toThrow(RangeError);
  });
});

describe("summarizeCardLimit", () => {
  it("calculates available limit and utilization", () => {
    expect(summarizeCardLimit(100_00, 2_500)).toEqual({
      limitCents: 100_00,
      usedCents: 2_500,
      availableCents: 7_500,
      utilizationPercent: 25,
    });
  });

  it("clamps available credit when usage exceeds the limit", () => {
    expect(summarizeCardLimit(1_000, 1_250)).toEqual({
      limitCents: 1_000,
      usedCents: 1_250,
      availableCents: 0,
      utilizationPercent: 125,
    });
  });

  it("defines zero limit utilization as zero", () => {
    expect(summarizeCardLimit(0, 0).utilizationPercent).toBe(0);
  });

  it.each([[-1, 0], [100, -1], [100.2, 0]])("rejects non-cent values", (limit, used) => {
    expect(() => summarizeCardLimit(limit, used)).toThrow(RangeError);
  });
});

describe("calculateCardLimitUsage", () => {
  it("commits remaining installments against credit limit and releases limit as installments are paid", () => {
    // Exemplo: Limite de R$ 5.000,00.
    // Compra parcelada de 10x de R$ 100,00 (total R$ 1.000,00).
    // Fatura de 08/2026 com parcela 2 de 10 paga.
    // Restam 8 parcelas de R$ 100,00 = R$ 800,00 comprometidos no limite futuro.
    const invoices = [
      {
        status: "paid",
        year: 2026,
        month: 8,
        due_date: "2026-08-10",
        credit_card_installments: [
          {
            amount: 100,
            installment_number: 2,
            credit_card_purchases: {
              description: "Geladeira Nova - Parcela 2/10",
              installment_count: 10,
            },
          },
        ],
      },
    ];

    // Em 09/2026: restam 8 parcelas de R$ 100 = R$ 800 comprometidos.
    const usageSep = calculateCardLimitUsage(5000, invoices, [], "2026-09");
    expect(usageSep.creditLimit).toBe(5000);
    expect(usageSep.openInvoicesDebt).toBe(0);
    expect(usageSep.futureInstallmentsCommitted).toBe(800);
    expect(usageSep.totalUsedLimit).toBe(800);
    expect(usageSep.availableLimit).toBe(4200);
    expect(usageSep.utilizationPercent).toBe(16);

    // Quando a fatura seguinte (09/2026) fatura a parcela 3 de 10 e é paga:
    // Restam 7 parcelas de R$ 100 = R$ 700 comprometidos (R$ 100 liberados!)
    const invoicesOct = [
      ...invoices,
      {
        status: "paid",
        year: 2026,
        month: 9,
        due_date: "2026-09-10",
        credit_card_installments: [
          {
            amount: 100,
            installment_number: 3,
            credit_card_purchases: {
              description: "Geladeira Nova - Parcela 3/10",
              installment_count: 10,
            },
          },
        ],
      },
    ];

    const usageOct = calculateCardLimitUsage(5000, invoicesOct, [], "2026-10");
    expect(usageOct.futureInstallmentsCommitted).toBe(700);
    expect(usageOct.availableLimit).toBe(4300); // R$ 100 liberados de acordo com o pagamento!
  });

  it("does not commit expired installment purchases from previous years", () => {
    const oldInvoices = [
      {
        status: "paid",
        year: 2021,
        month: 5,
        due_date: "2021-05-10",
        credit_card_installments: [
          {
            amount: 50,
            installment_number: 1,
            credit_card_purchases: {
              description: "Compra Antiga 2021",
              installment_count: 3,
            },
          },
        ],
      },
    ];

    // Em 2026, uma compra de 3x de 2021 já terminou há anos e não deve prender limite
    const usage = calculateCardLimitUsage(1000, oldInvoices, [], "2026-09");
    expect(usage.futureInstallmentsCommitted).toBe(0);
    expect(usage.availableLimit).toBe(1000);
  });
});
