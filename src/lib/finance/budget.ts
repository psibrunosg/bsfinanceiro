export type BudgetStatus = "ok" | "attention" | "exceeded";

export type BudgetConsumption = {
  limitCents: number;
  spentCents: number;
  remainingCents: number;
  consumedPercentage: number;
  status: BudgetStatus;
};

export type GoalProgress = {
  targetCents: number;
  savedCents: number;
  remainingCents: number;
  progressPercentage: number;
  completed: boolean;
};

function assertNonNegativeCents(value: number, field: string): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(`${field} must be a non-negative safe integer.`);
  }
}

function percentage(valueCents: number, totalCents: number): number {
  if (totalCents === 0) {
    return valueCents === 0 ? 0 : 100;
  }

  return (valueCents / totalCents) * 100;
}

export function calculateBudgetConsumption(
  limitCents: number,
  spentCents: number,
): BudgetConsumption {
  assertNonNegativeCents(limitCents, "Budget limit");
  assertNonNegativeCents(spentCents, "Budget spending");

  const consumedPercentage = percentage(spentCents, limitCents);
  const status: BudgetStatus =
    spentCents > limitCents
      ? "exceeded"
      : consumedPercentage >= 80
        ? "attention"
        : "ok";

  return {
    limitCents,
    spentCents,
    remainingCents: Math.max(limitCents - spentCents, 0),
    consumedPercentage,
    status,
  };
}

export function calculateGoalProgress(
  targetCents: number,
  savedCents: number,
): GoalProgress {
  assertNonNegativeCents(targetCents, "Goal target");
  assertNonNegativeCents(savedCents, "Goal savings");

  const completed = savedCents >= targetCents;

  return {
    targetCents,
    savedCents,
    remainingCents: Math.max(targetCents - savedCents, 0),
    progressPercentage: Math.min(percentage(savedCents, targetCents), 100),
    completed,
  };
}
