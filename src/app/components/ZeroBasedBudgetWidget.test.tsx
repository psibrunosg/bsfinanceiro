// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ZeroBasedBudgetWidget } from "./ZeroBasedBudgetWidget";
import { BudgetEnvelope } from "@/lib/finance/zero-based-budget";

describe("ZeroBasedBudgetWidget", () => {
  afterEach(() => {
    cleanup();
  });

  const sampleEnvelopes: BudgetEnvelope[] = [
    { id: "env-1", name: "Moradia & Contas", allocated: 3500, spent: 3200, category: "Moradia" },
    { id: "env-2", name: "Alimentação & Mercado", allocated: 2000, spent: 2150, category: "Alimentação" },
    { id: "env-3", name: "Lazer & Restaurantes", allocated: 1500, spent: 800, category: "Lazer" },
    { id: "env-4", name: "Saúde & Farmácia", allocated: 1000, spent: 650, category: "Saúde" },
    { id: "env-5", name: "Aportes & F.I.R.E.", allocated: 2000, spent: 2000, category: "Investimentos" },
  ];

  it("renders zero-based budget widget and envelopes", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={10000} initialEnvelopes={sampleEnvelopes} />);

    expect(screen.getByText("Orçamento Base Zero (Envelopes Virtuais)")).toBeDefined();
    expect(screen.getByText("Moradia & Contas")).toBeDefined();
    expect(screen.getByText("Alimentação & Mercado")).toBeDefined();
    expect(screen.getByText(/Não Alocado/i)).toBeDefined();
  });

  it("allows transferring budget between envelopes", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={10000} initialEnvelopes={sampleEnvelopes} />);

    const moveBtn = screen.getByRole("button", { name: /^Mover$/i });
    fireEvent.click(moveBtn);

    expect(screen.getByText(/Gasto R\$ 2\.150,00 de R\$ 2\.050,00/i)).toBeDefined();
  });

  it("renders empty state when no envelopes exist", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={5000} initialEnvelopes={[]} />);

    expect(screen.getByText("Orçamento Base Zero (Envelopes Virtuais)")).toBeDefined();
    expect(screen.getByText(/Nenhum envelope virtual criado/i)).toBeDefined();
    expect(screen.queryByText("Moradia & Contas")).toBeNull();
  });

  it("allows deleting an envelope", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={10000} initialEnvelopes={sampleEnvelopes} />);
    expect(screen.getByText("Moradia & Contas")).toBeDefined();

    fireEvent.click(screen.getByRole("button", { name: /Remover envelope Moradia & Contas/i }));
    expect(screen.queryByText("Moradia & Contas")).toBeNull();
  });
});
