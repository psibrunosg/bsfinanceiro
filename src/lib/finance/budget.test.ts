import { describe, expect, it } from "vitest";
import { calculateBudgetConsumption, calculateGoalProgress } from "./budget";

describe("calculateBudgetConsumption", () => {
  it("handles a zero budget without division by zero", () => {
    expect(calculateBudgetConsumption(0, 0)).toEqual({
      limitCents: 0,
      spentCents: 0,
      remainingCents: 0,
      consumedPercentage: 0,
      status: "ok",
    });
  });

  it("changes to attention at 80%", () => {
    expect(calculateBudgetConsumption(100_00, 80_00)).toMatchObject({
      remainingCents: 20_00,
      consumedPercentage: 80,
      status: "attention",
    });
  });

  it("keeps attention when the budget reaches exactly 100%", () => {
    expect(calculateBudgetConsumption(100_00, 100_00)).toMatchObject({
      remainingCents: 0,
      consumedPercentage: 100,
      status: "attention",
    });
  });

  it("marks spending above the limit as exceeded", () => {
    expect(calculateBudgetConsumption(100_00, 125_00)).toMatchObject({
      remainingCents: 0,
      consumedPercentage: 125,
      status: "exceeded",
    });
  });
});

describe("calculateGoalProgress", () => {
  it("caps a completed goal at 100% and leaves no remaining amount", () => {
    expect(calculateGoalProgress(100_00, 120_00)).toEqual({
      targetCents: 100_00,
      savedCents: 120_00,
      remainingCents: 0,
      progressPercentage: 100,
      completed: true,
    });
  });

  it("reports progress and remaining amount for an active goal", () => {
    expect(calculateGoalProgress(100_00, 80_00)).toMatchObject({
      remainingCents: 20_00,
      progressPercentage: 80,
      completed: false,
    });
  });

  it("handles a zero target as already completed", () => {
    expect(calculateGoalProgress(0, 0)).toMatchObject({
      remainingCents: 0,
      progressPercentage: 0,
      completed: true,
    });
  });
});
