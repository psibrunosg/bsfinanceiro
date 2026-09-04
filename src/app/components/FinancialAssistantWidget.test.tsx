// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { FinancialAssistantWidget } from "./FinancialAssistantWidget";

describe("FinancialAssistantWidget (Fase 12)", () => {
  afterEach(() => {
    cleanup();
  });

  const mockData = {
    accounts: [
      { id: "acc-1", name: "Nubank", type: "checking", initial_balance: 2500 },
    ],
    categories: [
      { id: "cat-1", name: "Alimentação" },
    ],
    transactions: [
      {
        id: "tx-1",
        description: "Almoço Restaurante",
        amount: 45.0,
        type: "expense" as const,
        competence_date: "2026-08-10",
        category_id: "cat-1",
      },
    ],
    commitments: [],
  };

  it("renders the assistant widget and initial greeting", () => {
    render(<FinancialAssistantWidget data={mockData} />);
    expect(screen.getByText("Assistente Financeiro IA")).toBeDefined();
    expect(screen.getByText(/Como posso te ajudar/i)).toBeDefined();
  });

  it("allows clicking a chip to ask a question and renders response", () => {
    render(<FinancialAssistantWidget data={mockData} />);
    const chip = screen.getByText("Qual meu saldo total?");
    fireEvent.click(chip);

    expect(screen.getByText(/saldo total atual/i)).toBeDefined();
    expect(screen.getByText(/2.500,00/)).toBeDefined();
  });

  it("allows typing a custom question in the input", () => {
    render(<FinancialAssistantWidget data={mockData} />);
    const input = screen.getByPlaceholderText("Faça uma pergunta sobre seus gastos...");
    fireEvent.change(input, { target: { value: "Quanto gastei com alimentação?" } });
    fireEvent.submit(input.closest("form")!);

    expect(screen.getByText(/Alimentação/)).toBeDefined();
    expect(screen.getAllByText(/45,00/).length).toBeGreaterThanOrEqual(1);
  });
});
