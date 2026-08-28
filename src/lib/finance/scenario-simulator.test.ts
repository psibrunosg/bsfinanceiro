import { describe, it, expect } from "vitest";
import {
  compareCashVsInstallment,
  simulateWhatIfScenario,
} from "./scenario-simulator";

describe("scenario-simulator", () => {
  describe("compareCashVsInstallment", () => {
    it("identifies when paying cash with discount is better than installments with CDI yield", () => {
      // Produto de R$ 10.000 por R$ 9.000 à vista (10% desc) vs 10x de R$ 1.000
      const res = compareCashVsInstallment({
        fullPrice: 10000,
        cashDiscountPercent: 10,
        installmentsCount: 10,
        annualCdiPercent: 12.0,
      });

      expect(res.cashPrice).toBe(9000);
      expect(res.bestChoice).toBe("cash");
      expect(res.cashSavings).toBeGreaterThan(0);
      expect(res.recommendation).toContain("À vista");
    });

    it("identifies when parceling in 12x with 0% discount is better keeping money in CDI", () => {
      // Produto de R$ 10.000 sem desconto à vista vs 12x de R$ 833,33
      const res = compareCashVsInstallment({
        fullPrice: 10000,
        cashDiscountPercent: 0,
        installmentsCount: 12,
        annualCdiPercent: 12.0,
      });

      expect(res.bestChoice).toBe("installment");
      expect(res.installmentAdvantage).toBeGreaterThan(0);
    });
  });

  describe("simulateWhatIfScenario", () => {
    it("simulates future cash flow with a new car installment and warns if it leads to deficit", () => {
      // Renda 8000, Despesas 7000 (Sobra 1000). Nova Parcela de 1500 -> Déficit mensal de 500
      const res = simulateWhatIfScenario({
        currentMonthlyIncome: 8000,
        currentMonthlyExpenses: 7000,
        newMonthlyCost: 1500,
        durationMonths: 12,
        initialBalance: 2000,
      });

      expect(res.isSafe).toBe(false);
      expect(res.deficitMonthIndex).toBe(5); // 2000 - 500*4 = 0, no 5º mês fica negativo
      expect(res.lowestBalance).toBeLessThan(0);
    });
  });
});
