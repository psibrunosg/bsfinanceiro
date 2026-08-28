import { describe, it, expect } from "vitest";
import {
  extractInstallmentPurchases,
  buildInstallmentTimeline,
  computeFinancialReliefSchedule,
} from "./installment-timeline";

describe("installment-timeline", () => {
  describe("extractInstallmentPurchases", () => {
    it("extracts installment purchases from invoices with credit_card_installments", () => {
      const invoices = [
        {
          id: "inv-1",
          due_date: "2026-08-20",
          credit_card_installments: [
            {
              amount: 450.0,
              installment_number: 10,
              credit_card_purchases: {
                description: "iPhone 15 Pro",
                installment_count: 12,
              },
            },
            {
              amount: 200.0,
              installment_number: 2,
              credit_card_purchases: {
                description: "Geladeira Brastemp",
                installment_count: 10,
              },
            },
          ],
        },
      ];

      const purchases = extractInstallmentPurchases(invoices, []);
      expect(purchases).toHaveLength(2);

      const iphone = purchases.find((p) => p.description === "iPhone 15 Pro");
      expect(iphone).toBeDefined();
      expect(iphone?.installmentAmount).toBe(450);
      expect(iphone?.currentInstallment).toBe(10);
      expect(iphone?.totalInstallments).toBe(12);
      expect(iphone?.remainingInstallments).toBe(3); // 10, 11, 12
    });

    it("extracts installment purchases from transaction descriptions with regex", () => {
      const txs = [
        {
          id: "tx-1",
          description: "Passagem Aérea GOL 02/06",
          amount: 300.0,
          competence_date: "2026-08-15",
        },
        {
          id: "tx-2",
          description: "Curso de Psicologia (1 de 5)",
          amount: 500.0,
          competence_date: "2026-08-01",
        },
      ];

      const purchases = extractInstallmentPurchases([], txs);
      expect(purchases).toHaveLength(2);

      const gol = purchases.find((p) => p.description.includes("Passagem Aérea"));
      expect(gol?.currentInstallment).toBe(2);
      expect(gol?.totalInstallments).toBe(6);
      expect(gol?.installmentAmount).toBe(300);
    });
  });

  describe("buildInstallmentTimeline", () => {
    it("projects monthly totals and active installments for the next 6 months", () => {
      const purchases = [
        {
          id: "p1",
          description: "iPhone 15 Pro",
          installmentAmount: 450,
          currentInstallment: 10,
          totalInstallments: 12,
          remainingInstallments: 3, // Agosto (10), Setembro (11), Outubro (12)
          startMonth: "2026-08",
        },
        {
          id: "p2",
          description: "Geladeira Brastemp",
          installmentAmount: 200,
          currentInstallment: 2,
          totalInstallments: 4,
          remainingInstallments: 3, // Agosto (2), Setembro (3), Outubro (4)
          startMonth: "2026-08",
        },
      ];

      const timeline = buildInstallmentTimeline(purchases, "2026-08", 6);
      expect(timeline).toHaveLength(6);

      // Agosto (2026-08): iPhone (450) + Geladeira (200) = 650
      expect(timeline[0].month).toBe("2026-08");
      expect(timeline[0].totalAmount).toBe(650);
      expect(timeline[0].activeCount).toBe(2);

      // Outubro (2026-10): iPhone (450) + Geladeira (200) = 650
      expect(timeline[2].month).toBe("2026-10");
      expect(timeline[2].totalAmount).toBe(650);

      // Novembro (2026-11): Ambos acabaram, total = 0
      expect(timeline[3].month).toBe("2026-11");
      expect(timeline[3].totalAmount).toBe(0);
      expect(timeline[3].activeCount).toBe(0);
    });
  });

  describe("computeFinancialReliefSchedule", () => {
    it("identifies which purchases end when and how much budget is liberated", () => {
      const purchases = [
        {
          id: "p1",
          description: "iPhone 15 Pro",
          installmentAmount: 450,
          currentInstallment: 10,
          totalInstallments: 12,
          remainingInstallments: 3, // termina em 2026-10
          startMonth: "2026-08",
        },
      ];

      const relief = computeFinancialReliefSchedule(purchases, "2026-08");
      expect(relief.nextReliefMonth).toBe("2026-11");
      expect(relief.nextReliefAmount).toBe(450);
      expect(relief.reliefItems[0].finishedPurchaseName).toBe("iPhone 15 Pro");
      expect(relief.reliefItems[0].liberatedAmount).toBe(450);
    });
  });
});
