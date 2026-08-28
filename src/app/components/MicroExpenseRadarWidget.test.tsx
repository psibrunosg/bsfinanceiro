// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { MicroExpenseRadarWidget } from "./MicroExpenseRadarWidget";

describe("MicroExpenseRadarWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders micro expense summary and top vendors", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Cafeteria Starbucks",
        amount: 18.5,
        type: "expense",
        competence_date: "2026-08-02",
      },
      {
        id: "tx-2",
        description: "Uber Curto",
        amount: 14.0,
        type: "expense",
        competence_date: "2026-08-05",
      },
    ];

    render(
      <MicroExpenseRadarWidget
        transactions={txs}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText(/Detector de Gastos Invisíveis/i)).toBeDefined();
    expect(screen.getByText(/Impacto Anualizado:/i)).toBeDefined();
    expect(screen.getByText("Cafeteria Starbucks")).toBeDefined();
    expect(screen.getByText("Uber Curto")).toBeDefined();
  });

  it("updates threshold when user clicks different threshold buttons", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Cafezinho",
        amount: 8.0,
        type: "expense",
        competence_date: "2026-08-02",
      },
      {
        id: "tx-2",
        description: "Lanche",
        amount: 25.0,
        type: "expense",
        competence_date: "2026-08-05",
      },
    ];

    render(
      <MicroExpenseRadarWidget
        transactions={txs}
        currentMonth="2026-08"
      />
    );

    const btn15 = screen.getByText("≤ R$ 15");
    fireEvent.click(btn15);

    expect(screen.getByText(/Total em compras ≤ R\$ 15/i)).toBeDefined();
  });
});
