import { describe, expect, test } from "vitest";
import {
  isTransferTransaction,
  classifyTransferType,
  pairTransfers,
  filterOutTransfers,
  calculateTransfersSummary,
  calculateNetCashFlowExcludingTransfers,
  TransferTransaction,
  AccountInfo,
  CategoryInfo,
} from "../transfers";

describe("src/lib/finance/transfers.ts", () => {
  const mockAccounts: AccountInfo[] = [
    { id: "acc-pj", name: "Conta Corrente PJ - Clínica", scope: "pj" },
    { id: "acc-pf", name: "Banco Santander PF", scope: "pf" },
    { id: "acc-pj2", name: "Conta Reserva PJ", scope: "pj" },
  ];

  const mockCategories: CategoryInfo[] = [
    { id: "cat-transf", name: "Transferência entre Contas", kind: "expense" },
    { id: "cat-prolabore", name: "Pró-labore", kind: "expense" },
    { id: "cat-aporte", name: "Aporte de Capital", kind: "income" },
    { id: "cat-alimentacao", name: "Alimentação", kind: "expense" },
    { id: "cat-consultas", name: "Consultas Médicas", kind: "income" },
  ];

  describe("isTransferTransaction", () => {
    test("reconhece por tipo explícito ou flag is_transfer", () => {
      expect(
        isTransferTransaction({
          id: "t1",
          type: "transfer",
          amount: 500,
          competence_date: "2026-07-01",
        })
      ).toBe(true);

      expect(
        isTransferTransaction({
          id: "t2",
          type: "expense",
          amount: 500,
          competence_date: "2026-07-01",
          is_transfer: true,
        })
      ).toBe(true);
    });

    test("reconhece por destination_account_id presente", () => {
      expect(
        isTransferTransaction({
          id: "t3",
          type: "expense",
          amount: 1000,
          competence_date: "2026-07-01",
          account_id: "acc-pj",
          destination_account_id: "acc-pf",
        })
      ).toBe(true);
    });

    test("reconhece por nome ou ID de categoria de transferência", () => {
      expect(
        isTransferTransaction(
          {
            id: "t4",
            type: "expense",
            amount: 2000,
            competence_date: "2026-07-01",
            category_id: "cat-prolabore",
          },
          mockCategories
        )
      ).toBe(true);

      expect(
        isTransferTransaction({
          id: "t5",
          type: "expense",
          amount: 2000,
          competence_date: "2026-07-01",
          category_name: "Transferência Interna",
        })
      ).toBe(true);
    });

    test("reconhece por palavras-chave na descrição", () => {
      expect(
        isTransferTransaction({
          id: "t6",
          type: "expense",
          amount: 1500,
          competence_date: "2026-07-01",
          description: "PIX TRANSF CONTA PF BRUNO",
        })
      ).toBe(true);

      expect(
        isTransferTransaction({
          id: "t7",
          type: "income",
          amount: 3000,
          competence_date: "2026-07-01",
          description: "APORTE SOCIO PJ",
        })
      ).toBe(true);
    });

    test("retorna falso para receitas e despesas normais operacionais", () => {
      expect(
        isTransferTransaction(
          {
            id: "t8",
            type: "expense",
            amount: 150,
            competence_date: "2026-07-01",
            category_id: "cat-alimentacao",
            description: "Supermercado Zaffari",
          },
          mockCategories
        )
      ).toBe(false);

      expect(
        isTransferTransaction(
          {
            id: "t9",
            type: "income",
            amount: 500,
            competence_date: "2026-07-01",
            category_id: "cat-consultas",
            description: "Consulta paciente Maria",
          },
          mockCategories
        )
      ).toBe(false);
    });
  });

  describe("classifyTransferType", () => {
    test("classifica PJ -> PF quando a origem é PJ e destino é PF", () => {
      const type = classifyTransferType(
        {
          sourceAccountId: "acc-pj",
          destinationAccountId: "acc-pf",
        },
        mockAccounts
      );
      expect(type).toBe("pj_to_pf");
    });

    test("classifica PF -> PJ quando a origem é PF e destino é PJ", () => {
      const type = classifyTransferType(
        {
          sourceAccountId: "acc-pf",
          destinationAccountId: "acc-pj",
        },
        mockAccounts
      );
      expect(type).toBe("pf_to_pj");
    });

    test("classifica como internal quando ambas as contas são PJ", () => {
      const type = classifyTransferType(
        {
          sourceAccountId: "acc-pj",
          destinationAccountId: "acc-pj2",
        },
        mockAccounts
      );
      expect(type).toBe("internal");
    });

    test("fallback por descrição e categoria quando não há metadados de contas", () => {
      expect(
        classifyTransferType({
          description: "Retirada de Pró-labore mês 07",
        })
      ).toBe("pj_to_pf");

      expect(
        classifyTransferType({
          description: "Aporte de capital caixa",
        })
      ).toBe("pf_to_pj");
    });
  });

  describe("pairTransfers", () => {
    test("pareia lançamento de débito na PJ e crédito na PF de mesmo valor em datas próximas", () => {
      const txs: TransferTransaction[] = [
        {
          id: "out-1",
          type: "expense",
          amount: 5000,
          competence_date: "2026-07-10",
          account_id: "acc-pj",
          description: "PIX TRANSF PF",
        },
        {
          id: "in-1",
          type: "income",
          amount: 5000,
          competence_date: "2026-07-10",
          account_id: "acc-pf",
          description: "PIX RECEBIDO PJ",
        },
        {
          id: "normal-exp",
          type: "expense",
          amount: 200,
          competence_date: "2026-07-11",
          account_id: "acc-pj",
          description: "Energia elétrica",
        },
      ];

      const { pairs, unpaired } = pairTransfers(txs, mockAccounts, { categories: mockCategories });

      expect(pairs).toHaveLength(1);
      expect(pairs[0].outflowTransactionId).toBe("out-1");
      expect(pairs[0].inflowTransactionId).toBe("in-1");
      expect(pairs[0].amount).toBe(5000);
      expect(pairs[0].transferType).toBe("pj_to_pf");

      expect(unpaired).toHaveLength(1);
      expect(unpaired[0].id).toBe("normal-exp");
    });

    test("suporta transações explícitas com destination_account_id", () => {
      const txs: TransferTransaction[] = [
        {
          id: "explicit-1",
          type: "transfer",
          amount: 3000,
          competence_date: "2026-07-05",
          account_id: "acc-pf",
          destination_account_id: "acc-pj",
          description: "Aporte de liquidez",
        },
      ];

      const { pairs } = pairTransfers(txs, mockAccounts);

      expect(pairs).toHaveLength(1);
      expect(pairs[0].amount).toBe(3000);
      expect(pairs[0].transferType).toBe("pf_to_pj");
    });
  });

  describe("filterOutTransfers e calculateNetCashFlowExcludingTransfers", () => {
    test("filtra movimentações intercontas mantendo apenas receitas/despesas operacionais", () => {
      const txs: TransferTransaction[] = [
        { id: "1", type: "income", amount: 10000, competence_date: "2026-07-01", description: "Receita de Serviços" },
        { id: "2", type: "expense", amount: 3000, competence_date: "2026-07-05", description: "Aluguel consultório" },
        { id: "3", type: "expense", amount: 4000, competence_date: "2026-07-10", description: "Pró-labore PJ -> PF", is_transfer: true, account_id: "acc-pj" },
        { id: "4", type: "income", amount: 4000, competence_date: "2026-07-10", description: "Pró-labore entrada PF", is_transfer: true, account_id: "acc-pf" },
      ];

      const nonTransfers = filterOutTransfers(txs, mockCategories, mockAccounts);
      expect(nonTransfers).toHaveLength(2);
      expect(nonTransfers.map((t) => t.id)).toEqual(["1", "2"]);

      const flow = calculateNetCashFlowExcludingTransfers(txs, mockCategories, mockAccounts);
      expect(flow.totalIncome).toBe(10000);
      expect(flow.totalExpense).toBe(3000);
      expect(flow.netCashFlow).toBe(7000);
      expect(flow.transferVolume).toBe(4000);
    });

    test("calcula o resumo de transferências (PJ -> PF e PF -> PJ)", () => {
      const txs: TransferTransaction[] = [
        {
          id: "t-pj-pf",
          type: "expense",
          amount: 5000,
          competence_date: "2026-07-10",
          account_id: "acc-pj",
          destination_account_id: "acc-pf",
          description: "Retirada pro-labore",
        },
        {
          id: "t-pf-pj",
          type: "expense",
          amount: 2000,
          competence_date: "2026-07-15",
          account_id: "acc-pf",
          destination_account_id: "acc-pj",
          description: "Aporte no caixa PJ",
        },
      ];

      const summary = calculateTransfersSummary(txs, mockAccounts, mockCategories);
      expect(summary.pjToPfTotal).toBe(5000);
      expect(summary.pfToPjTotal).toBe(2000);
      expect(summary.totalVolume).toBe(7000);
      expect(summary.count).toBe(2);
    });
  });
});
