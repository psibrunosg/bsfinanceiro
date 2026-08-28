import { describe, it, expect } from "vitest";
import {
  simulateDebtPayoff,
  extractDebtsFromFinancialData,
  type DebtItem,
} from "./debt-payoff";

describe("debt-payoff", () => {
  const sampleDebts: DebtItem[] = [
    {
      id: "d1",
      name: "Cartão de Crédito Rotativo",
      balance: 3000,
      interestRateAnnual: 400, // 400% a.a. (~14% a.m.)
      minimumMonthlyPayment: 450,
      category: "cartao",
    },
    {
      id: "d2",
      name: "Empréstimo Pessoal",
      balance: 8000,
      interestRateAnnual: 45, // 45% a.a. (~3.1% a.m.)
      minimumMonthlyPayment: 380,
      category: "emprestimo",
    },
    {
      id: "d3",
      name: "Cheque Especial",
      balance: 1200,
      interestRateAnnual: 150, // 150% a.a. (~8% a.m.)
      minimumMonthlyPayment: 200,
      category: "outros",
    },
  ];

  describe("simulateDebtPayoff - Snowball vs Avalanche", () => {
    it("orders debts by smallest balance first in Snowball method", () => {
      const result = simulateDebtPayoff({
        debts: sampleDebts,
        strategy: "snowball",
        extraMonthlyPayment: 0,
        startMonth: "2026-08",
      });

      // Snowball: d3 (1200), d1 (3000), d2 (8000)
      expect(result.payoffOrder[0].debtId).toBe("d3");
      expect(result.totalMonths).toBeGreaterThan(0);
      expect(result.debtFreeDate).toBeDefined();
    });

    it("orders debts by highest interest rate first in Avalanche method and saves more interest", () => {
      const snowball = simulateDebtPayoff({
        debts: sampleDebts,
        strategy: "snowball",
        extraMonthlyPayment: 300,
        startMonth: "2026-08",
      });

      const avalanche = simulateDebtPayoff({
        debts: sampleDebts,
        strategy: "avalanche",
        extraMonthlyPayment: 300,
        startMonth: "2026-08",
      });

      // Avalanche: d1 (400%), d3 (150%), d2 (45%)
      expect(avalanche.payoffOrder[0].debtId).toBe("d1");
      // Avalanche saves more or equal interest than Snowball
      expect(avalanche.totalInterestPaid).toBeLessThanOrEqual(snowball.totalInterestPaid);
    });

    it("accelerates debt freedom when extra monthly payment is added", () => {
      const withoutExtra = simulateDebtPayoff({
        debts: sampleDebts,
        strategy: "avalanche",
        extraMonthlyPayment: 0,
        startMonth: "2026-08",
      });

      const withExtra = simulateDebtPayoff({
        debts: sampleDebts,
        strategy: "avalanche",
        extraMonthlyPayment: 500,
        startMonth: "2026-08",
      });

      expect(withExtra.totalMonths).toBeLessThan(withoutExtra.totalMonths);
      expect(withExtra.monthsSaved).toBeGreaterThan(0);
      expect(withExtra.interestSaved).toBeGreaterThan(0);
    });
  });

  describe("extractDebtsFromFinancialData", () => {
    it("extracts overdraft from negative bank accounts", () => {
      const accounts = [
        { id: "acc-1", name: "Itaú Corrente", type: "checking", initial_balance: -1500 },
        { id: "acc-2", name: "Nubank", type: "checking", initial_balance: 2000 },
      ];

      const debts = extractDebtsFromFinancialData({
        accounts,
        invoices: [],
        transactions: [],
      });

      expect(debts).toHaveLength(1);
      expect(debts[0].name).toContain("Itaú Corrente");
      expect(debts[0].balance).toBe(1500);
      expect(debts[0].category).toBe("outros");
    });
  });
});
