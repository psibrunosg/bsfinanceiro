import { describe, expect, it } from "vitest";
import {
  alertPreferencesFromRow,
  buildDashboardMoneyModel,
  buildTodayDashboard,
} from "./today-adapter";

describe("buildTodayDashboard", () => {
  it("uses the supplied cash balance and respects the low-balance preference", () => {
    const model = buildTodayDashboard(
      10_00,
      [
        { type: "expense", amount: 20, status: "planned", competence_date: "2026-07-28" },
        { type: "income", amount: 30, status: "planned", competence_date: "2026-07-29" },
      ],
      { budget_alerts: true, goal_alerts: true, fixed_commitment_alerts: true, credit_card_alerts: true, low_balance_alerts: false, low_balance_amount: 0 },
      "2026-07-28",
    );

    expect(model.currentBalanceCents).toBe(10_00);
    expect(model.alert).toBeNull();
  });

  it("uses enabled defaults when preferences do not exist", () => {
    expect(alertPreferencesFromRow(null).cashflow).toBe(true);
  });

  it("uses the cash position without replaying paid transactions in the projection", () => {
    const transactions = [
      {
        account_id: "cash",
        destination_account_id: null,
        type: "expense",
        amount: 10,
        status: "paid",
        competence_date: "2026-07-28",
      },
      {
        account_id: "cash",
        destination_account_id: null,
        type: "expense",
        amount: 20,
        status: "planned",
        competence_date: "2026-07-29",
      },
      {
        account_id: "cash",
        destination_account_id: null,
        type: "income",
        amount: 30,
        status: "planned",
        competence_date: "2026-07-30",
      },
    ];
    const cashPosition = buildDashboardMoneyModel({
      accounts: [{ id: "cash", type: "checking", initial_balance: 100 }],
      transactions,
      occurrences: [],
      today: "2026-07-28",
    }).cashPosition;

    const model = buildTodayDashboard(
      cashPosition.balanceCents,
      transactions,
      { budget_alerts: true, goal_alerts: true, fixed_commitment_alerts: true, credit_card_alerts: true, low_balance_alerts: true, low_balance_amount: 0 },
      "2026-07-28",
    );

    expect(model.currentBalanceCents).toBe(90_00);
    expect(model.projectedBalanceCents).toBe(100_00);
  });
});

describe("buildDashboardMoneyModel", () => {
  it("adapts posted balances and planned obligations into spending power", () => {
    expect(
      buildDashboardMoneyModel({
        accounts: [{ id: "cash", type: "checking", initial_balance: 100 }],
        transactions: [
          {
            account_id: "cash",
            destination_account_id: null,
            type: "expense",
            amount: 10,
            status: "paid",
            competence_date: "2026-07-28",
          },
          {
            account_id: "cash",
            destination_account_id: null,
            type: "income",
            amount: 500,
            status: "planned",
            competence_date: "2026-08-05",
          },
        ],
        occurrences: [{ amount: 30, due_date: "2026-08-01", status: "planned" }],
        today: "2026-07-28",
      }).spendingPower.availableCents
    ).toBe(60_00);
  });
});
