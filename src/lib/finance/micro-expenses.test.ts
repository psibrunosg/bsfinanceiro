import { describe, it, expect } from "vitest";
import {
  computeMicroExpenseSummary,
  calculateMicroSavingsChallenge,
} from "./micro-expenses";

describe("micro-expenses", () => {
  describe("computeMicroExpenseSummary", () => {
    it("identifies micro expenses below threshold and computes annualized impact", () => {
      const txs = [
        {
          id: "tx-1",
          description: "Cafeteria Starbucks",
          amount: 18.5,
          type: "expense",
          competence_date: "2026-08-02",
        },
        {
          id: "tx-2",
          description: "Uber Viagem Curta",
          amount: 14.2,
          type: "expense",
          competence_date: "2026-08-04",
        },
        {
          id: "tx-3",
          description: "Padaria Pão Quente",
          amount: 25.0,
          type: "expense",
          competence_date: "2026-08-10",
        },
        {
          id: "tx-4",
          description: "Supermercado Semanal",
          amount: 350.0,
          type: "expense",
          competence_date: "2026-08-12",
        },
        {
          id: "tx-5",
          description: "Cafeteria Starbucks",
          amount: 12.0,
          type: "expense",
          competence_date: "2026-08-15",
        },
      ];

      // Threshold padrão: R$ 30,00
      const summary = computeMicroExpenseSummary(txs, "2026-08", 30);

      expect(summary.count).toBe(4); // 18.5, 14.2, 25.0, 12.0
      expect(summary.totalMonthly).toBeCloseTo(69.7, 2);
      expect(summary.annualizedImpact).toBeCloseTo(836.4, 2); // 69.7 * 12
      expect(summary.totalExpensesMonth).toBeCloseTo(419.7, 2);
      expect(summary.percentageOfExpenses).toBeCloseTo(16.6, 1);
      expect(summary.topVendors[0].name).toBe("Cafeteria Starbucks");
      expect(summary.topVendors[0].total).toBeCloseTo(30.5, 2);
      expect(summary.topVendors[0].count).toBe(2);
    });

    it("respects custom threshold e.g. R$ 15", () => {
      const txs = [
        {
          id: "tx-1",
          description: "Café Expresso",
          amount: 8.0,
          type: "expense",
          competence_date: "2026-08-02",
        },
        {
          id: "tx-2",
          description: "Lanche",
          amount: 22.0,
          type: "expense",
          competence_date: "2026-08-04",
        },
      ];

      const summary = computeMicroExpenseSummary(txs, "2026-08", 15);
      expect(summary.count).toBe(1);
      expect(summary.totalMonthly).toBe(8.0);
    });
  });

  describe("calculateMicroSavingsChallenge", () => {
    it("calculates compound savings in CDI for weekly micro-savings", () => {
      // Economizar R$ 50/semana (~R$ 216.67/mês) a 12% a.a. por 1 e 3 anos
      const res = calculateMicroSavingsChallenge({
        weeklyTarget: 50,
        annualRatePercent: 12,
      });

      expect(res.monthlyEstimatedSavings).toBeCloseTo(216.67, 1);
      expect(res.accumulated1Year).toBeGreaterThan(2600);
      expect(res.accumulated3Years).toBeGreaterThan(9000);
      expect(res.accumulated5Years).toBeGreaterThan(17000);
    });
  });
});
