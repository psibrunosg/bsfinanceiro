import { describe, it, expect } from "vitest";
import { calculateFireMetrics } from "./fire-calculator";

describe("fire-calculator", () => {
  it("calculates FIRE number using 4% rule (300x monthly expenses)", () => {
    // Custo de vida: R$ 8.000/mês -> Número FIRE = R$ 2.400.000 (8000 * 300)
    const res = calculateFireMetrics({
      monthlyExpenses: 8000,
      currentNetWorth: 240000, // 10% do caminho
      monthlyContribution: 4000,
      realAnnualReturnPercent: 7.0, // 7% a.a. real acima da inflação
      startMonth: "2026-08",
    });

    expect(res.fireNumberStandard).toBe(2400000);
    expect(res.fireNumberLean).toBe(1680000); // 70% de 2.4M
    expect(res.fireNumberFat).toBe(3600000); // 150% de 2.4M
    expect(res.fireProgressPercent).toBe(10);
    expect(res.currentPassiveIncomeMonthly).toBe(800); // 240.000 * 0.04 / 12
    expect(res.yearsToFire).toBeGreaterThan(15);
    expect(res.yearsToFire).toBeLessThan(25);
    expect(res.fireDateLabel).toBeDefined();
  });

  it("calculates instant completion when current net worth exceeds FIRE target", () => {
    const res = calculateFireMetrics({
      monthlyExpenses: 5000,
      currentNetWorth: 1600000, // Maior que 1.5M (5000 * 300)
      monthlyContribution: 1000,
    });

    expect(res.isFireAchieved).toBe(true);
    expect(res.fireProgressPercent).toBe(100);
    expect(res.yearsToFire).toBe(0);
  });
});
