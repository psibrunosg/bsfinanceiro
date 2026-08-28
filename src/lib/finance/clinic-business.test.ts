import { describe, it, expect } from "vitest";
import {
  computeClinicDRE,
  computePartnerLoanBalance,
  computeCashFlowGap,
} from "./clinic-business";

describe("clinic-business", () => {
  describe("computeClinicDRE", () => {
    it("calculates clinic gross revenue, direct costs, net profit and margin", () => {
      const txs = [
        { id: "1", description: "Consulta Paciente Ana", amount: 2500, type: "income", competence_date: "2026-08-10" },
        { id: "2", description: "Consulta Paciente Carlos", amount: 3500, type: "income", competence_date: "2026-08-12" },
        { id: "3", description: "Aluguel Consultório Sala 402", amount: 1800, type: "expense", competence_date: "2026-08-08" },
        { id: "4", description: "Supervisão Clínica Dr. Marcos", amount: 400, type: "expense", competence_date: "2026-08-15" },
        { id: "5", description: "Sistema de Prontuário PsicoManager", amount: 120, type: "expense", competence_date: "2026-08-05" },
        { id: "6", description: "Retirada Pró-Labore Sócio Bruno", amount: 2000, type: "expense", competence_date: "2026-08-20" },
      ];

      const dre = computeClinicDRE(txs, "2026-08");

      expect(dre.grossRevenue).toBe(6000); // 2500 + 3500
      expect(dre.operatingExpenses).toBe(2320); // 1800 + 400 + 120
      expect(dre.operatingProfit).toBe(3680); // 6000 - 2320
      expect(dre.profitMarginPercent).toBeCloseTo(61.3, 1);
      expect(dre.proLaboreWithdrawn).toBe(2000);
      expect(dre.retainedEarnings).toBe(1680); // 3680 - 2000
    });
  });

  describe("computePartnerLoanBalance", () => {
    it("tracks clinic expenses paid from personal account/card and calculates reimbursable balance", () => {
      const txs = [
        // Despesa da clínica paga no cartão pessoal
        {
          id: "tx-p1",
          description: "Aluguel Consultório [Clínica]",
          amount: 1800,
          type: "expense",
          competence_date: "2026-08-08",
          context_name: "Pessoal",
          is_clinic_expense_on_personal: true,
        },
        // Compra de testes psicológicos no cartão pessoal
        {
          id: "tx-p2",
          description: "Kit Testes WISC-IV [Clínica]",
          amount: 650,
          type: "expense",
          competence_date: "2026-08-14",
          context_name: "Pessoal",
          is_clinic_expense_on_personal: true,
        },
        // Reembolso já efetuado da clínica para o sócio
        {
          id: "tx-p3",
          description: "Reembolso Despesas Sócio",
          amount: 500,
          type: "income",
          competence_date: "2026-08-20",
          context_name: "Pessoal",
          is_partner_reimbursement: true,
        },
      ];

      const loan = computePartnerLoanBalance(txs);

      expect(loan.totalLentByPartner).toBe(2450); // 1800 + 650
      expect(loan.totalReimbursed).toBe(500);
      expect(loan.pendingBalance).toBe(1950); // 2450 - 500
      expect(loan.status).toBe("clinic_owes_partner");
      expect(loan.unreimbursedItems).toHaveLength(2);
    });
  });

  describe("computeCashFlowGap", () => {
    it("detects liquidity deficit when expenses fall due on day 8 before patient payments on day 15", () => {
      const txs = [
        { id: "1", description: "Aluguel Consultório", amount: 1800, type: "expense", competence_date: "2026-08-08" },
        { id: "2", description: "Condomínio Consultório", amount: 400, type: "expense", competence_date: "2026-08-05" },
        { id: "3", description: "Recebimento Paciente 1", amount: 1500, type: "income", competence_date: "2026-08-12" },
        { id: "4", description: "Recebimento Paciente 2", amount: 2000, type: "income", competence_date: "2026-08-15" },
      ];

      const gap = computeCashFlowGap(txs, "2026-08", 500); // Saldo inicial PJ = 500

      // No dia 08: 500 - 400 (dia 5) - 1800 (dia 8) = -1700 (Déficit temporário)
      expect(gap.hasLiquidityGap).toBe(true);
      expect(gap.maxDeficitDay).toBe(8);
      expect(gap.maxDeficitAmount).toBe(1700);
      expect(gap.workingCapitalNeeded).toBe(1700);
      expect(gap.gapResolutionDay).toBe(15); // Dia 12 recebe 1500 (saldo -200), dia 15 recebe 2000 (saldo +1800, resolvido)
    });
  });
});
