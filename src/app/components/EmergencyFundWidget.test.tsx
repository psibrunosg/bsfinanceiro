// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { EmergencyFundWidget } from "./EmergencyFundWidget";

describe("EmergencyFundWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders emergency fund metrics and runway months", () => {
    render(
      <EmergencyFundWidget
        monthlyFixedExpenses={5000}
        initialFundBalance={15000}
      />
    );

    expect(screen.getByText("Caixinha de Emergência Inteligente & Guardião de Reserva")).toBeDefined();
    expect(screen.getByText(/Fôlego:/i)).toBeDefined();
    expect(screen.getByText("Reserva Guardada")).toBeDefined();
    expect(screen.getByText("Guardião da Reserva (Trava Anti-Impulso)")).toBeDefined();
  });

  it("allows switching target profile to 12 months for freelancers", () => {
    render(
      <EmergencyFundWidget
        monthlyFixedExpenses={5000}
        initialFundBalance={15000}
      />
    );

    const btn12 = screen.getByRole("button", { name: /12 Meses/i });
    fireEvent.click(btn12);

    expect(screen.getByText(/de R\$ 60.000,00/i)).toBeDefined();
  });
});
