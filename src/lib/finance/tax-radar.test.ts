import { describe, it, expect } from "vitest";
import {
  calculateProgressiveTax,
  computeMonthlyTaxReport,
  detectLivroCaixaDeductions,
} from "./tax-radar";

describe("tax-radar", () => {
  describe("calculateProgressiveTax", () => {
    it("is exempt (R$ 0) for incomes up to R$ 2.259,20", () => {
      const res = calculateProgressiveTax(2000);
      expect(res.taxDue).toBe(0);
      expect(res.marginalRate).toBe(0);
    });

    it("calculates 7.5% bracket with deduction", () => {
      // Base: R$ 2.500 -> 2500 * 0.075 - 169.44 = 187.50 - 169.44 = 18.06
      const res = calculateProgressiveTax(2500);
      expect(res.marginalRate).toBe(7.5);
      expect(res.taxDue).toBeCloseTo(18.06, 2);
    });

    it("calculates 27.5% bracket with deduction", () => {
      // Base: R$ 10.000 -> 10000 * 0.275 - 896.00 = 2750 - 896 = 1854.00
      const res = calculateProgressiveTax(10000);
      expect(res.marginalRate).toBe(27.5);
      expect(res.taxDue).toBeCloseTo(1854.0, 2);
    });
  });

  describe("detectLivroCaixaDeductions", () => {
    it("detects clinic rent, professional council (CRP), courses and internet", () => {
      const txs = [
        { id: "tx-1", description: "Aluguel Consultório Sala 402", amount: 1500, type: "expense", competence_date: "2026-08-05" },
        { id: "tx-2", description: "Anuidade CRP Conselho de Psicologia", amount: 650, type: "expense", competence_date: "2026-08-10" },
        { id: "tx-3", description: "Curso de Especialização TCC", amount: 400, type: "expense", competence_date: "2026-08-15" },
        { id: "tx-4", description: "Supermercado Pessoal", amount: 300, type: "expense", competence_date: "2026-08-18" },
      ];

      const deductions = detectLivroCaixaDeductions(txs, "2026-08");
      expect(deductions.totalDeductible).toBe(2550); // 1500 + 650 + 400
      expect(deductions.items).toHaveLength(3);
    });
  });

  describe("computeMonthlyTaxReport", () => {
    it("calculates DARF, effective tax rate, and tax savings from Livro-Caixa", () => {
      const report = computeMonthlyTaxReport({
        grossIncome: 12000,
        deductibleExpenses: 2550,
        inssDeduction: 500,
        dependentsCount: 1, // 189.59
        month: "2026-08",
      });

      // Base tributável: 12000 - 2550 - 500 - 189.59 = 8760.41
      expect(report.taxableBase).toBeCloseTo(8760.41, 2);
      expect(report.estimatedDARF).toBeGreaterThan(0);
      expect(report.effectiveRatePercent).toBeLessThan(report.marginalRatePercent);
      expect(report.taxSavingsFromDeductions).toBeGreaterThan(0);
      expect(report.darfDueDateLabel).toBeDefined();
    });
  });
});
