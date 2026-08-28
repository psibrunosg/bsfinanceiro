// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { HealthScoreWidget } from "./HealthScoreWidget";

describe("HealthScoreWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders health score, 4 pillars and action tips", () => {
    render(
      <HealthScoreWidget
        monthlyIncome={10000}
        monthlyExpenses={6000}
        availableCash={36000}
        fixedCommitments={2000}
        investedTotal={60000}
      />
    );

    expect(screen.getByText("Score de Saúde Financeira")).toBeDefined();
    expect(screen.getByText(/Nível Excelente/i)).toBeDefined();
    expect(screen.getByText("Reserva de Emergência")).toBeDefined();
    expect(screen.getByText("Controle de Gastos Fixos")).toBeDefined();
    expect(screen.getByText("Taxa de Poupança")).toBeDefined();
    expect(screen.getByText("Investimentos & Patrimônio")).toBeDefined();
  });
});
