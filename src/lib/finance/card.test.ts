import { describe, expect, it } from "vitest";
import { calculateInstallments, summarizeCardLimit } from "./card";

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
