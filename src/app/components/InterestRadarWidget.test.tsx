// @vitest-environment jsdom
import { describe, it, expect } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { InterestRadarWidget } from "./InterestRadarWidget";
import type { Transaction } from "./types";

describe("InterestRadarWidget", () => {
  it("renders with zero interest when no interest transactions exist", () => {
    render(<InterestRadarWidget transactions={[]} currentMonth="2026-08-01" />);
    expect(screen.getByText("Radar de Juros & Custos Ocultos")).toBeDefined();
    expect(screen.getByText("0 juros pagos")).toBeDefined();
  });

  it("renders detected interest and updates prepayment simulation on user input", () => {
    const txs: Partial<Transaction>[] = [
      {
        id: "tx-1",
        type: "expense",
        amount: 50.00,
        description: "Juros de cartão de crédito",
        competence_date: "2026-08-15",
      },
    ];

    render(
      <InterestRadarWidget
        transactions={txs as Transaction[]}
        currentMonth="2026-08-01"
      />
    );

    expect(screen.getByText("Juros detectados")).toBeDefined();
    expect(screen.getByText("Juros de cartão de crédito")).toBeDefined();

    // Testa interação com o simulador de parcelas
    const valInput = screen.getByLabelText("Valor da Parcela (R$)");
    fireEvent.change(valInput, { target: { value: "300" } });
    expect(screen.getByText("Total original: R$ 1.800,00")).toBeDefined();
  });
});
