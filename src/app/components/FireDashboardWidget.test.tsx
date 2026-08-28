// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { FireDashboardWidget } from "./FireDashboardWidget";

describe("FireDashboardWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders FIRE number, passive income and freedom date", () => {
    render(
      <FireDashboardWidget
        monthlyExpenses={6000}
        currentNetWorth={360000}
        estimatedMonthlyContribution={2500}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText("Dashboard F.I.R.E. (Independência Financeira)")).toBeDefined();
    expect(screen.getByText(/Liberdade em:/i)).toBeDefined();
    expect(screen.getAllByText(/renda passiva perpétua/i).length).toBeGreaterThan(0);
    expect(screen.getByText("Lean FIRE")).toBeDefined();
    expect(screen.getAllByText("Standard").length).toBeGreaterThan(0);
    expect(screen.getByText("Fat FIRE")).toBeDefined();
  });

  it("allows switching between Lean, Standard and Fat FIRE targets", () => {
    render(
      <FireDashboardWidget
        monthlyExpenses={6000}
        currentNetWorth={360000}
        estimatedMonthlyContribution={2500}
      />
    );

    const leanBtn = screen.getByRole("button", { name: "Lean" });
    fireEvent.click(leanBtn);

    expect(screen.getByText("Lean")).toBeDefined();
  });
});
