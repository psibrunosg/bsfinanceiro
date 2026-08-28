// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ScenarioSimulatorWidget } from "./ScenarioSimulatorWidget";

describe("ScenarioSimulatorWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders cash vs installment comparison by default", () => {
    render(
      <ScenarioSimulatorWidget
        estimatedMonthlyIncome={8000}
        estimatedMonthlyExpenses={6000}
        currentBalance={5000}
      />
    );

    expect(screen.getByText("Simulador de Cenários & Máquina do Tempo")).toBeDefined();
    expect(screen.getByText("Parâmetros da Compra")).toBeDefined();
    expect(screen.getByText("Veredito Financeiro")).toBeDefined();
  });

  it("allows switching to What-If simulation tab and viewing timeline", () => {
    render(
      <ScenarioSimulatorWidget
        estimatedMonthlyIncome={8000}
        estimatedMonthlyExpenses={6000}
        currentBalance={5000}
      />
    );

    const whatIfBtn = screen.getByRole("button", { name: /What-If/i });
    fireEvent.click(whatIfBtn);

    expect(screen.getByText("Nova Despesa / Compromisso Futuro")).toBeDefined();
    expect(screen.getByText(/Saldo final projetado após 12 meses:/i)).toBeDefined();
  });
});
