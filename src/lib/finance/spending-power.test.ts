import { describe, expect, it } from "vitest";
import { buildSpendingPower } from "./spending-power";

describe("buildSpendingPower", () => {
  it("reserves obligations before the next planned income", () => {
    expect(
      buildSpendingPower({
        currentBalanceCents: 1_000_00,
        today: "2026-07-28",
        plannedTransactions: [
          { type: "expense", amount: 100, competence_date: "2026-07-29", status: "planned" },
          { type: "income", amount: 900, competence_date: "2026-08-05", status: "planned" },
        ],
        commitments: [{ amount: 300, due_date: "2026-08-01", status: "planned" }],
      }),
    ).toMatchObject({
      availableCents: 600_00,
      nextIncomeDate: "2026-08-05",
      reservedCommitmentsCents: 300_00,
      reservedExpenseCents: 100_00,
    });
  });

  it("does not reserve items after the next income or paid items", () => {
    expect(
      buildSpendingPower({
        currentBalanceCents: 500_00,
        today: "2026-07-28",
        plannedTransactions: [
          { type: "income", amount: 700, competence_date: "2026-08-05", status: "planned" },
          { type: "expense", amount: 90, competence_date: "2026-08-06", status: "planned" },
        ],
        commitments: [{ amount: 60, due_date: "2026-07-29", status: "paid" }],
      }).availableCents,
    ).toBe(500_00);
  });

  it("uses a 30-day window when there is no future planned income", () => {
    expect(
      buildSpendingPower({
        currentBalanceCents: 1_000_00,
        today: "2026-07-28",
        plannedTransactions: [
          { type: "expense", amount: 120, competence_date: "2026-08-27", status: "planned" },
          { type: "expense", amount: 90, competence_date: "2026-08-28", status: "planned" },
        ],
        commitments: [{ amount: 80, due_date: "2026-08-27", status: "planned" }],
      }),
    ).toMatchObject({
      availableCents: 800_00,
      nextIncomeDate: null,
      reservedCommitmentsCents: 80_00,
      reservedExpenseCents: 120_00,
    });
  });
});
