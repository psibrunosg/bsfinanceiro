import { describe, it, expect } from "vitest";
import {
  computeGoalPlan,
  computeGoalMilestones,
} from "./goal-planner";

describe("goal-planner", () => {
  describe("computeGoalPlan", () => {
    it("calculates required monthly contribution without interest and with CDI interest", () => {
      // Meta: R$ 15.000 em 12 meses, começando do zero
      const plan = computeGoalPlan({
        targetAmount: 15000,
        currentAmount: 0,
        startMonth: "2026-08",
        deadlineMonth: "2027-08", // 12 meses
        annualRatePercent: 12.0, // 12% a.a. CDI
      });

      expect(plan.monthsRemaining).toBe(12);
      expect(plan.requiredMonthlyNoInterest).toBe(1250); // 15000 / 12
      // Com CDI a 12% a.a., o aporte necessário é menor que 1250
      expect(plan.requiredMonthlyWithCDI).toBeLessThan(1250);
      expect(plan.requiredMonthlyWithCDI).toBeGreaterThan(1150);
      expect(plan.cdiYieldBenefit).toBeGreaterThan(0);
    });

    it("projects completion date when user provides custom monthly contribution", () => {
      // Meta: R$ 20.000 com saldo de R$ 5.000 (falta 15.000). Aporte de R$ 1.500/mês
      const plan = computeGoalPlan({
        targetAmount: 20000,
        currentAmount: 5000,
        startMonth: "2026-08",
        deadlineMonth: "2027-12", // 16 meses
        monthlyContribution: 1500,
        annualRatePercent: 12.0,
      });

      // Em vez de 16 meses, com 1500/mês + CDI deve atingir em ~9 meses
      expect(plan.projectedMonths).toBeLessThan(12);
      expect(plan.monthsAhead).toBeGreaterThan(0);
      expect(plan.status).toBe("ahead");
    });
  });

  describe("computeGoalMilestones", () => {
    it("generates milestone targets at 25%, 50%, 75% and 100%", () => {
      const milestones = computeGoalMilestones(20000, 5000);
      expect(milestones).toHaveLength(4);
      expect(milestones[0].percentage).toBe(25);
      expect(milestones[0].amount).toBe(5000);
      expect(milestones[0].achieved).toBe(true);

      expect(milestones[1].percentage).toBe(50);
      expect(milestones[1].amount).toBe(10000);
      expect(milestones[1].achieved).toBe(false);
    });
  });
});
