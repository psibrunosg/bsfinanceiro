// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { CoupleFinanceWidget } from "./CoupleFinanceWidget";

describe("CoupleFinanceWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders couple finances widget with detected shared expenses and settlement message", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Jantar Romântico [Casal]",
        amount: 300,
        type: "expense",
        competence_date: "2026-08-10",
      },
    ];

    render(
      <CoupleFinanceWidget
        transactions={txs}
        currentMonth="2026-08"
        partnerAName="Bruno"
        partnerBName="Esposa"
      />
    );

    expect(screen.getByText("Modo Casal & Finanças a Dois")).toBeDefined();
    expect(screen.getByText("Total Gasto Juntos no Mês")).toBeDefined();
    expect(screen.getByText("Jantar Romântico [Casal]")).toBeDefined();
    expect(screen.getByText(/Esposa transfere R\$ 150,00 para Bruno/i)).toBeDefined();
  });

  it("allows switching to proportional income mode", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Mercado do Mês [Casal]",
        amount: 1000,
        type: "expense",
        competence_date: "2026-08-10",
      },
    ];

    render(
      <CoupleFinanceWidget
        transactions={txs}
        currentMonth="2026-08"
      />
    );

    const btn = screen.getByRole("button", { name: "Por Renda" });
    fireEvent.click(btn);

    expect(screen.getAllByText(/Cota justa/i).length).toBeGreaterThan(0);
  });
});
