import { describe, it, expect } from "vitest";
import {
  comparePortfolioYield,
  projectCompoundGrowth,
  computeAssetClassAllocation,
} from "./investment-growth";

describe("investment-growth", () => {
  describe("comparePortfolioYield", () => {
    it("compares portfolio yield against CDI and Poupança", () => {
      // Carteira rendeu 14.5% no ano, com CDI a 12.25% a.a. e Poupança a 7.2% a.a.
      const result = comparePortfolioYield({
        portfolioYieldPercent: 14.5,
        annualCdiPercent: 12.25,
      });

      expect(result.percentOfCdi).toBeCloseTo(118.37, 1); // 14.5 / 12.25 * 100
      expect(result.beatsCdi).toBe(true);
      expect(result.beatsSavings).toBe(true);
      expect(result.cdiSpread).toBeCloseTo(2.25, 2);
    });

    it("handles zero or negative yield properly", () => {
      const result = comparePortfolioYield({
        portfolioYieldPercent: -3.0,
        annualCdiPercent: 12.0,
      });

      expect(result.percentOfCdi).toBe(-25);
      expect(result.beatsCdi).toBe(false);
      expect(result.beatsSavings).toBe(false);
    });
  });

  describe("projectCompoundGrowth", () => {
    it("projects compound interest with zero monthly contribution", () => {
      // R$ 10.000 a 12% a.a. por 12 meses (1 ano)
      const proj = projectCompoundGrowth({
        initialPrincipal: 10000,
        monthlyContribution: 0,
        annualRatePercent: 12,
        months: 12,
      });

      expect(proj.totalContributed).toBe(10000);
      expect(proj.totalAccumulated).toBeCloseTo(11200, 0);
      expect(proj.totalInterestGained).toBeCloseTo(1200, 0);
    });

    it("projects compound interest with monthly contributions", () => {
      // R$ 5.000 inicial + R$ 1.000/mês por 24 meses a 10% a.a.
      const proj = projectCompoundGrowth({
        initialPrincipal: 5000,
        monthlyContribution: 1000,
        annualRatePercent: 10,
        months: 24,
      });

      expect(proj.totalContributed).toBe(29000); // 5000 + 24 * 1000
      expect(proj.totalAccumulated).toBeGreaterThan(29000);
      expect(proj.totalInterestGained).toBeGreaterThan(0);
      expect(proj.milestones.length).toBe(24);
    });
  });

  describe("computeAssetClassAllocation", () => {
    it("groups assets into fixed income and variable income", () => {
      const assets = [
        { id: "a1", type: "fixed_income", name: "CDB 110% CDI" },
        { id: "a2", type: "stock", name: "VALE3" },
        { id: "a3", type: "reit", name: "HGLG11" },
      ];
      const positions = {
        a1: { quantity: 1, costCents: 700000 }, // R$ 7.000
        a2: { quantity: 100, costCents: 200000 }, // R$ 2.000
        a3: { quantity: 10, costCents: 100000 }, // R$ 1.000
      };
      const quotes = {
        a1: 7000,
        a2: 20,
        a3: 100,
      };

      const alloc = computeAssetClassAllocation(assets, positions, quotes);
      expect(alloc.fixedIncomeTotal).toBe(7000);
      expect(alloc.variableIncomeTotal).toBe(3000);
      expect(alloc.total).toBe(10000);
      expect(alloc.fixedIncomePercent).toBe(70);
      expect(alloc.variableIncomePercent).toBe(30);
    });
  });
});
