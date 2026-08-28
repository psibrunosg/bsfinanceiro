import { describe, it, expect } from "vitest";
import {
  calculateEmergencyFundMetrics,
  simulateWithdrawalImpact,
} from "./emergency-fund";

describe("emergency-fund", () => {
  it("calculates emergency target, runway months and safety status", () => {
    // Custo de vida: R$ 5.000/mês, 6 meses meta = R$ 30.000. Saldo atual: R$ 15.000 (3 meses de runway)
    const res = calculateEmergencyFundMetrics({
      monthlyFixedExpenses: 5000,
      currentFundBalance: 15000,
      targetMonths: 6,
      annualCdiPercent: 12.0,
    });

    expect(res.targetAmount).toBe(30000);
    expect(res.currentRunwayMonths).toBe(3.0);
    expect(res.progressPercent).toBe(50);
    expect(res.safetyStatus).toBe("moderate");
    expect(res.monthlyYieldCdi).toBeGreaterThan(140);
  });

  it("simulates withdrawal impact on runway (Guardian alert)", () => {
    const res = simulateWithdrawalImpact({
      currentFundBalance: 20000,
      monthlyFixedExpenses: 5000,
      withdrawAmount: 5000,
    });

    expect(res.newBalance).toBe(15000);
    expect(res.currentRunwayMonths).toBe(4.0);
    expect(res.newRunwayMonths).toBe(3.0);
    expect(res.lostRunwayMonths).toBe(1.0);
    expect(res.warningMessage).toContain("reduz seu fôlego de sobrevivência de 4,0 para 3,0 meses");
  });
});
