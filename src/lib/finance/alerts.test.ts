import { describe, expect, it } from "vitest";
import {
  selectAlerts,
  selectTopAlert,
  type AlertPreferences,
  type FinancialAlert,
} from "./alerts";

const allEnabled: AlertPreferences = {
  budget: true,
  cashflow: true,
  invoice: true,
  goal: true,
  recurring: true,
};

const alerts: FinancialAlert[] = [
  { title: "Test", message: "...", id: "budget-low", preference: "budget", severity: "warning", impactCents: 10_00 },
  { title: "Test", message: "...", id: "invoice", preference: "invoice", severity: "critical", impactCents: 20_00 },
  { title: "Test", message: "...", id: "cashflow", preference: "cashflow", severity: "critical", impactCents: 50_00 },
  { title: "Test", message: "...", id: "goal", preference: "goal", severity: "info", impactCents: 100_00 },
  { title: "Test", message: "...", id: "budget-high", preference: "budget", severity: "warning", impactCents: 30_00 },
];

describe("selectAlerts", () => {
  it("prioritizes severity, then financial impact, and returns at most three", () => {
    expect(selectAlerts(alerts, allEnabled).map(({ id }) => id)).toEqual([
      "cashflow",
      "invoice",
      "budget-high",
    ]);
  });

  it("removes alert groups disabled by the user", () => {
    expect(
      selectAlerts(alerts, { ...allEnabled, cashflow: false, budget: false }).map(
        ({ id }) => id,
      ),
    ).toEqual(["invoice", "goal"]);
  });

  it("returns no alerts when every preference is disabled", () => {
    const allDisabled: AlertPreferences = {
      budget: false,
      cashflow: false,
      invoice: false,
      goal: false,
      recurring: false,
    };

    expect(selectAlerts(alerts, allDisabled)).toEqual([]);
  });

  it("preserves the input order when severity and impact are tied", () => {
    const tied: FinancialAlert[] = [
      { title: "Test", message: "...", id: "first", preference: "goal", severity: "info", impactCents: 0 },
      { title: "Test", message: "...", id: "second", preference: "goal", severity: "info", impactCents: 0 },
    ];

    expect(selectAlerts(tied, allEnabled).map(({ id }) => id)).toEqual([
      "first",
      "second",
    ]);
    expect(tied.map(({ id }) => id)).toEqual(["first", "second"]);
  });

  it("uses the earliest due date after severity and impact when selecting one alert", () => {
    expect(selectTopAlert([
      { title: "Test", message: "...", id: "later", preference: "cashflow", severity: "warning", impactCents: 10_00, dueDate: "2026-08-10" },
      { title: "Test", message: "...", id: "earlier", preference: "cashflow", severity: "warning", impactCents: 10_00, dueDate: "2026-08-02" },
    ], allEnabled)?.id).toBe("earlier");
  });
});
