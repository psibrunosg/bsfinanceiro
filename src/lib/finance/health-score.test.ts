import { describe, it, expect } from "vitest";
import {
  computeFinancialHealthScore,
  calculateEmergencyReserveScore,
  calculateDebtRatioScore,
  calculateSavingsRateScore,
  calculateInvestmentScore,
} from "./health-score";

describe("health-score", () => {
  describe("individual pillar calculators", () => {
    it("calculates emergency reserve score (0 to 250)", () => {
      // 6 meses ou mais de reserva = 250 pontos
      expect(calculateEmergencyReserveScore(6)).toBe(250);
      expect(calculateEmergencyReserveScore(8)).toBe(250);

      // 3 meses de reserva = ~180 pontos
      expect(calculateEmergencyReserveScore(3)).toBeCloseTo(180, 0);

      // 0 meses = 0 pontos
      expect(calculateEmergencyReserveScore(0)).toBe(0);
    });

    it("calculates debt / commitment ratio score (0 to 250)", () => {
      // Compromisso <= 30% da renda = 250 pontos
      expect(calculateDebtRatioScore(25)).toBe(250);

      // Compromisso = 50% = 150 pontos
      expect(calculateDebtRatioScore(50)).toBeCloseTo(150, 0);

      // Compromisso > 80% = < 50 pontos
      expect(calculateDebtRatioScore(85)).toBeLessThanOrEqual(50);
    });

    it("calculates savings rate score (0 to 250)", () => {
      // Poupando >= 25% da renda = 250 pontos
      expect(calculateSavingsRateScore(30)).toBe(250);

      // Poupando 15% da renda = ~180 pontos
      expect(calculateSavingsRateScore(15)).toBeCloseTo(180, 0);

      // Poupando 0% ou negativo = 0 pontos
      expect(calculateSavingsRateScore(-5)).toBe(0);
    });

    it("calculates investment score (0 to 250)", () => {
      // Investimento equivalente a 6x ou mais a renda mensal = 250 pontos
      expect(calculateInvestmentScore(60000, 10000)).toBe(250);

      // Investimento equivalente a 1x a renda = ~120 pontos
      expect(calculateInvestmentScore(10000, 10000)).toBeCloseTo(120, 0);

      // Zero investimentos = 0 pontos
      expect(calculateInvestmentScore(0, 10000)).toBe(0);
    });
  });

  describe("computeFinancialHealthScore", () => {
    it("computes overall score and assigns proper tier and actionable tips", () => {
      const result = computeFinancialHealthScore({
        monthlyIncome: 10000,
        monthlyExpenses: 7000,
        availableCash: 30000, // 30k cash = ~4.2 meses de custo de 7k
        fixedCommitments: 2500, // 25% da renda
        investedTotal: 40000, // 4x a renda
      });

      expect(result.overallScore).toBeGreaterThanOrEqual(851);
      expect(result.tier).toBe("excelente"); // > 850
      expect(result.pillars).toHaveLength(4);
      expect(result.tips.length).toBeGreaterThan(0);
    });

    it("identifies critical financial state when income is low and debt is high", () => {
      const result = computeFinancialHealthScore({
        monthlyIncome: 5000,
        monthlyExpenses: 5200,
        availableCash: 500,
        fixedCommitments: 4000, // 80% da renda
        investedTotal: 0,
      });

      expect(result.overallScore).toBeLessThanOrEqual(400);
      expect(result.tier).toBe("critico");
    });
  });
});
