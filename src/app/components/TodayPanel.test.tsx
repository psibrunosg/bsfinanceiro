// @vitest-environment jsdom
import React from "react";
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { TodayPanel } from "./TodayPanel";
import { buildTodayDashboard } from "../../lib/finance/today-adapter";

describe("TodayPanel", () => {
  it("shows the empty state when there is no next income", () => {
    render(<TodayPanel today={{ currentBalanceCents: 50_00, nextIncomeDate: null, projectedBalanceCents: 50_00, lowestBalanceCents: 50_00, lowestBalanceDate: "2026-07-28", alert: null }} />);
    expect(screen.getByText("Nenhuma próxima receita agendada.")).toBeTruthy();
  });

  it("shows the selected alert", () => {
    const today = buildTodayDashboard(
      [{ type: "checking", initial_balance: 10 }],
      [{ type: "expense", amount: 20, competence_date: "2026-07-28" }, { type: "income", amount: 30, competence_date: "2026-07-29" }],
      { budget_alerts: true, goal_alerts: true, fixed_commitment_alerts: true, credit_card_alerts: true, low_balance_alerts: true, low_balance_amount: 0 },
      "2026-07-28",
    );

    expect(today.alert).toMatchObject({ severity: "critical", dueDate: "2026-07-28" });
    render(<TodayPanel today={today} />);
    expect(screen.getByRole("status").textContent).toContain("Atenção:");
  });
});
