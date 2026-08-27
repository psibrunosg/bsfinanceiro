import { describe, it, expect } from "vitest";
import {
  computeInterestSummary,
  simulatePrepaymentDiscount,
  detectHiddenCosts,
} from "./interest-radar";
import type { Transaction } from "@/app/components/types";

describe("interest-radar", () => {
  describe("computeInterestSummary", () => {
    it("returns zero metrics when there are no transactions", () => {
      const summary = computeInterestSummary([], "2026-08-01");
      expect(summary.totalInterestAndFees).toBe(0);
      expect(summary.items).toHaveLength(0);
      expect(summary.hasAlert).toBe(false);
    });

    it("identifies transactions that are interest, fees, IOF, or fines", () => {
      const txs: Partial<Transaction>[] = [
        {
          id: "tx-1",
          type: "expense",
          amount: 45.50,
          description: "Juros de cartão de crédito",
          competence_date: "2026-08-10",
        },
        {
          id: "tx-2",
          type: "expense",
          amount: 12.30,
          description: "IOF rotativo",
          competence_date: "2026-08-12",
        },
        {
          id: "tx-3",
          type: "expense",
          amount: 89.00,
          description: "Supermercado Pão de Açúcar",
          competence_date: "2026-08-15",
        },
        {
          id: "tx-4",
          type: "expense",
          amount: 35.00,
          description: "Tarifa / Encargos de parcelamento Pix",
          competence_date: "2026-08-20",
        },
        {
          id: "tx-5",
          type: "expense",
          amount: 50.00,
          description: "Multa por atraso fatura",
          competence_date: "2026-07-28", // Outro mês
        },
      ];

      const summary = computeInterestSummary(txs as Transaction[], "2026-08-01");
      expect(summary.totalInterestAndFees).toBe(92.8); // 45.50 + 12.30 + 35.00
      expect(summary.items).toHaveLength(3);
      expect(summary.hasAlert).toBe(true);
    });
  });

  describe("simulatePrepaymentDiscount", () => {
    it("returns zero savings if count is 0 or rate is 0", () => {
      const res = simulatePrepaymentDiscount({
        installmentValue: 100,
        remainingCount: 0,
        annualDiscountRate: 10,
      });
      expect(res.totalOriginal).toBe(0);
      expect(res.totalWithDiscount).toBe(0);
      expect(res.totalSaved).toBe(0);
      expect(res.discountPercent).toBe(0);
    });

    it("calculates compound present value discount correctly for future installments", () => {
      // 5 parcelas de R$ 200 a uma taxa de desconto de 12% a.a. (~0.9488% a.m.)
      const res = simulatePrepaymentDiscount({
        installmentValue: 200,
        remainingCount: 5,
        annualDiscountRate: 12,
      });

      expect(res.totalOriginal).toBe(1000);
      expect(res.totalSaved).toBeGreaterThan(0);
      expect(res.totalWithDiscount).toBeLessThan(1000);
      expect(res.totalWithDiscount + res.totalSaved).toBeCloseTo(1000, 2);
      expect(res.discountPercent).toBeGreaterThan(0);
    });
  });

  describe("detectHiddenCosts", () => {
    it("flags pix installments with interest and calculates estimated extra cost", () => {
      const txs: Partial<Transaction>[] = [
        {
          id: "tx-pix",
          type: "expense",
          amount: 150.00,
          description: "Pix no crédito 3x",
          competence_date: "2026-08-05",
        },
      ];

      const detected = detectHiddenCosts(txs as Transaction[]);
      expect(detected).toHaveLength(1);
      expect(detected[0].type).toBe("pix_credit");
    });
  });
});
