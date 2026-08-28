import { describe, it, expect } from "vitest";
import {
  computeCoupleFinances,
  detectCoupleTransactions,
} from "./couple-finance";

describe("couple-finance", () => {
  describe("detectCoupleTransactions", () => {
    it("identifies transactions tagged as couple or with shared partner keywords", () => {
      const txs = [
        { id: "1", description: "Restaurante Outback [Casal]", amount: 260, type: "expense", competence_date: "2026-08-05" },
        { id: "2", description: "Supermercado Mensal Pão de Açúcar [Casal]", amount: 800, type: "expense", competence_date: "2026-08-08" },
        { id: "3", description: "Cinema e Pipoca c/ Esposa", amount: 120, type: "expense", competence_date: "2026-08-15" },
        { id: "4", description: "Gasolina Carro Pessoal", amount: 200, type: "expense", competence_date: "2026-08-18" },
      ];

      const detected = detectCoupleTransactions(txs, "2026-08");
      expect(detected).toHaveLength(3);
      expect(detected[0].amount).toBe(260);
    });
  });

  describe("computeCoupleFinances", () => {
    it("calculates 50/50 split and balance when one partner paid more", () => {
      const expenses = [
        { id: "1", description: "Restaurante", amount: 200, payer: "partner_a" as const },
        { id: "2", description: "Supermercado", amount: 600, payer: "partner_a" as const },
        { id: "3", description: "Padaria", amount: 100, payer: "partner_b" as const },
      ];

      const res = computeCoupleFinances({
        expenses,
        splitMode: "equal_50_50",
        partnerAName: "Bruno",
        partnerBName: "Esposa",
      });

      expect(res.totalSharedExpenses).toBe(900); // 200 + 600 + 100
      expect(res.totalPaidByPartnerA).toBe(800); // 200 + 600
      expect(res.totalPaidByPartnerB).toBe(100);
      expect(res.fairSharePartnerA).toBe(450); // 50% de 900
      expect(res.fairSharePartnerB).toBe(450);
      expect(res.debtor).toBe("partner_b");
      expect(res.settlementAmount).toBe(350); // 450 - 100 = 350 que Esposa deve ao Bruno
      expect(res.statusMessage).toContain("Esposa transfere R$ 350,00 para Bruno");
    });

    it("calculates proportional split based on income ratio (ex: 60% / 40%)", () => {
      const expenses = [
        { id: "1", description: "Aluguel Apartamento", amount: 3000, payer: "partner_a" as const },
        { id: "2", description: "Supermercado", amount: 1000, payer: "partner_b" as const },
      ];

      const res = computeCoupleFinances({
        expenses,
        splitMode: "proportional_by_income",
        partnerAIncome: 12000, // 60% da renda total
        partnerBIncome: 8000,  // 40% da renda total
        partnerAName: "Bruno",
        partnerBName: "Esposa",
      });

      expect(res.totalSharedExpenses).toBe(4000);
      expect(res.fairSharePartnerA).toBe(2400); // 60% de 4000
      expect(res.fairSharePartnerB).toBe(1600); // 40% de 4000
      expect(res.debtor).toBe("partner_b");
      expect(res.settlementAmount).toBe(600); // 1600 - 1000 = 600
    });
  });
});
