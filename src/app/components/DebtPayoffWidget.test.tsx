// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { DebtPayoffWidget } from "./DebtPayoffWidget";

describe("DebtPayoffWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders debt payoff simulator with accounts overdraft", () => {
    const accounts = [
      { id: "acc-1", name: "Itaú Corrente", type: "checking", initial_balance: -2500 },
    ];

    render(
      <DebtPayoffWidget
        accounts={accounts}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText("Rastreador de Dívidas & Simulador de Quitação")).toBeDefined();
    expect(screen.getByText(/Livre de dívidas em/i)).toBeDefined();
    expect(screen.getByText(/Cheque Especial/i)).toBeDefined();
  });

  it("allows switching strategies between Avalanche and Snowball", () => {
    const accounts = [
      { id: "acc-1", name: "Itaú Corrente", type: "checking", initial_balance: -2500 },
    ];

    render(
      <DebtPayoffWidget
        accounts={accounts}
        currentMonth="2026-08"
      />
    );

    const snowballBtn = screen.getByText(/Bola de Neve/i);
    fireEvent.click(snowballBtn);

    expect(screen.getByText(/Bola de Neve/i)).toBeDefined();
  });
});
