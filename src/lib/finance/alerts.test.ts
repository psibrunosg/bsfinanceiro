import { describe, expect, it } from "vitest";
import {
  selectAlerts,
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
  { id: "budget-low", preference: "budget", severity: "warning", impactCents: 10_00 },
  { id: "invoice", preference: "invoice", severity: "critical", impactCents: 20_00 },
  { id: "cashflow", preference: "cashflow", severity: "critical", impactCents: 50_00 },
  { id: "goal", preference: "goal", severity: "info", impactCents: 100_00 },
  { id: "budget-high", preference: "budget", severity: "warning", impactCents: 30_00 },
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
      { id: "first", preference: "goal", severity: "info", impactCents: 0 },
      { id: "second", preference: "goal", severity: "info", impactCents: 0 },
    ];

    expect(selectAlerts(tied, allEnabled).map(({ id }) => id)).toEqual([
      "first",
      "second",
    ]);
    expect(tied.map(({ id }) => id)).toEqual(["first", "second"]);
  });
});
