import { describe, expect, it } from "vitest";
import { alertPreferencesFromRow, buildTodayDashboard } from "./today-adapter";

describe("buildTodayDashboard", () => {
  it("excludes credit-card accounts and respects the low-balance preference", () => {
    const model = buildTodayDashboard(
      [{ type: "checking", initial_balance: 10 }, { type: "credit_card", initial_balance: 9_999 }],
      [{ type: "expense", amount: 20, competence_date: "2026-07-28" }, { type: "income", amount: 30, competence_date: "2026-07-29" }],
      { budget_alerts: true, goal_alerts: true, fixed_commitment_alerts: true, credit_card_alerts: true, low_balance_alerts: false, low_balance_amount: 0 },
      "2026-07-28",
    );

    expect(model.currentBalanceCents).toBe(10_00);
    expect(model.alert).toBeNull();
  });

  it("uses enabled defaults when preferences do not exist", () => {
    expect(alertPreferencesFromRow(null).cashflow).toBe(true);
  });
});
