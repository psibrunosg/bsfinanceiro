import { describe, expect, it } from "vitest";
import { projectUntilNextIncome } from "./today";

describe("projectUntilNextIncome", () => {
  it("includes events from today through the first later income", () => {
    expect(projectUntilNextIncome([
      { date: "2026-07-28", type: "expense", amountCents: 30_00 },
      { date: "2026-07-29", type: "expense", amountCents: 40_00 },
      { date: "2026-07-30", type: "income", amountCents: 100_00 },
      { date: "2026-08-01", type: "expense", amountCents: 90_00 },
    ], 50_00, "2026-07-28")).toMatchObject({
      nextIncomeDate: "2026-07-30",
      projectedBalanceCents: 80_00,
      lowestBalanceCents: -20_00,
      lowestBalanceDate: "2026-07-29",
    });
  });

  it("returns an empty-state projection without a later income", () => {
    expect(projectUntilNextIncome([{ date: "2026-07-28", type: "expense", amountCents: 10_00 }], 50_00, "2026-07-28")).toMatchObject({
      nextIncomeDate: null,
      projectedBalanceCents: 50_00,
    });
  });
});
