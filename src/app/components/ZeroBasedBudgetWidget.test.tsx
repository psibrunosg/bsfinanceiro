// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ZeroBasedBudgetWidget } from "./ZeroBasedBudgetWidget";

describe("ZeroBasedBudgetWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders zero-based budget widget and envelopes", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={10000} />);

    expect(screen.getByText("Orçamento Base Zero (Envelopes Virtuais)")).toBeDefined();
    expect(screen.getByText("Moradia & Contas")).toBeDefined();
    expect(screen.getByText("Alimentação & Mercado")).toBeDefined();
    expect(screen.getByText(/Não Alocado/i)).toBeDefined();
  });

  it("allows transferring budget between envelopes", () => {
    render(<ZeroBasedBudgetWidget monthlyIncome={10000} />);

    const moveBtn = screen.getByRole("button", { name: /Mover/i });
    fireEvent.click(moveBtn);

    // Alimentação meta aumentou em R$ 150 (de 2000 para 2150)
    expect(screen.getByText(/Gasto R\$ 2\.150,00 de R\$ 2\.150,00/i)).toBeDefined();
  });
});
