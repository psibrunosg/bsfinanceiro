// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { GoalPlannerWidget } from "./GoalPlannerWidget";

describe("GoalPlannerWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders goal planning with cdi comparison and milestones", () => {
    const goals = [
      {
        id: "g1",
        name: "Viagem para o Japão",
        target_amount: 30000,
        current_amount: 7500,
        deadline: "2027-12-01",
      },
    ];

    render(
      <GoalPlannerWidget
        goals={goals}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText(/Planejador de Metas & Sonhos/i)).toBeDefined();
    expect(screen.getByText("Viagem para o Japão")).toBeDefined();
    expect(screen.getByText(/O Poder do CDI/i)).toBeDefined();
    expect(screen.getByText("25%")).toBeDefined();
    expect(screen.getByText("50%")).toBeDefined();
  });
});
