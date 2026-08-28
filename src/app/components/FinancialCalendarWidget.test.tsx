// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { FinancialCalendarWidget } from "./FinancialCalendarWidget";

describe("FinancialCalendarWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders visual calendar with daily flow and badges", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Salário Consultório",
        amount: 8000,
        type: "income",
        competence_date: "2026-08-05",
      },
      {
        id: "tx-2",
        description: "Aluguel Consultório",
        amount: 3000,
        type: "expense",
        competence_date: "2026-08-08",
      },
    ];

    render(<FinancialCalendarWidget transactions={txs} currentMonth="2026-08" />);

    expect(screen.getByText("Calendário Financeiro Visual")).toBeDefined();
    expect(screen.getByText(/dias positivos/i)).toBeDefined();
    expect(screen.getByText(/dias com saídas/i)).toBeDefined();
    expect(screen.getByText(/Pico: Dia 8/i)).toBeDefined();
  });

  it("allows clicking a day to view daily transactions breakdown", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Supermercado Mensal",
        amount: 600,
        type: "expense",
        competence_date: "2026-08-10",
      },
    ];

    render(<FinancialCalendarWidget transactions={txs} currentMonth="2026-08" />);

    const day10Btn = screen.getByRole("button", { name: /^10/i });
    fireEvent.click(day10Btn);

    expect(screen.getByText(/Movimentações do Dia 10/i)).toBeDefined();
    expect(screen.getByText("Supermercado Mensal")).toBeDefined();
  });
});
