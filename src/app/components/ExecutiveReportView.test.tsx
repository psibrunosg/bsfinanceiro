// @vitest-environment jsdom
import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { ExecutiveReportView } from "./ExecutiveReportView";

describe("ExecutiveReportView", () => {
  afterEach(() => {
    cleanup();
  });
  const defaultProps = {
    workspaceName: "Minhas Finanças",
    label: "Setembro de 2026",
    month: "2026-09-01",
    income: 10000,
    expense: 4000,
    rows: [
      { name: "Alimentação", total: 1500, share: 37.5, delta: 5.2 },
      { name: "Moradia", total: 2500, share: 62.5, delta: 0 },
    ],
    topExpenses: [
      {
        id: "tx-1",
        account_id: "acc-1",
        destination_account_id: null,
        type: "expense" as const,
        status: "paid" as const,
        description: "Aluguel",
        amount: 2500,
        competence_date: "2026-09-05",
        category_id: "cat-moradia",
      },
    ],
    categories: [
      { id: "cat-moradia", name: "Moradia", kind: "expense", color: "#ef4444" },
      { id: "cat-alim", name: "Alimentação", kind: "expense", color: "#f59e0b" },
    ],
    accounts: [
      {
        id: "acc-1",
        name: "Nubank Principal",
        type: "checking" as const,
        initial_balance: 500,
        is_shared: false,
      },
    ],
  };

  it("renders executive header, workspace name, and period", () => {
    render(<ExecutiveReportView {...defaultProps} isScreenPreview={true} />);

    expect(screen.getByText("BS FINANCEIRO")).toBeDefined();
    expect(screen.getByText(/Relatório Executivo Mensal · Minhas Finanças/i)).toBeDefined();
    expect(screen.getByText("Setembro de 2026")).toBeDefined();
    expect(screen.getByText("Competência: 2026-09-01")).toBeDefined();
  });

  it("renders KPI summary cards with savings rate", () => {
    render(<ExecutiveReportView {...defaultProps} isScreenPreview={true} />);

    expect(screen.getByText("Receitas Totais")).toBeDefined();
    expect(screen.getByText("Despesas Totais")).toBeDefined();
    expect(screen.getByText("Resultado Líquido")).toBeDefined();
    expect(screen.getByText("Taxa de Poupança")).toBeDefined();
    // 60,0% savings rate (10000 - 4000 = 6000 / 10000 = 60%)
    expect(screen.getByText("60,0%")).toBeDefined();
  });

  it("renders category breakdown table and top expenses", () => {
    render(<ExecutiveReportView {...defaultProps} isScreenPreview={true} />);

    expect(screen.getByText("Distribuição de Despesas por Categoria")).toBeDefined();
    expect(screen.getByText("Alimentação")).toBeDefined();
    expect(screen.getAllByText("Moradia").length).toBeGreaterThanOrEqual(1);

    expect(screen.getByText("Maiores Lançamentos do Período")).toBeDefined();
    expect(screen.getByText("Aluguel")).toBeDefined();
  });

  it("handles zero income gracefully without NaN in savings rate", () => {
    render(
      <ExecutiveReportView
        {...defaultProps}
        income={0}
        expense={500}
        rows={[]}
        topExpenses={[]}
        isScreenPreview={true}
      />
    );

    expect(screen.getAllByText("0,0%").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("Nenhuma despesa registrada nesta competência.")).toBeDefined();
  });
});
