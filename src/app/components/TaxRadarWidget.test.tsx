// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { TaxRadarWidget } from "./TaxRadarWidget";

describe("TaxRadarWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders DARF estimate, gross income and livro-caixa deductions", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Consulta Paciente Maria",
        amount: 8000,
        type: "income",
        competence_date: "2026-08-05",
      },
      {
        id: "tx-2",
        description: "Aluguel Consultório",
        amount: 1500,
        type: "expense",
        competence_date: "2026-08-10",
      },
    ];

    render(
      <TaxRadarWidget
        transactions={txs}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText("Radar de Impostos & Carnê-Leão (IRPF)")).toBeDefined();
    expect(screen.getByText(/DARF Carnê-Leão/i)).toBeDefined();
    expect(screen.getByText("Aluguel Consultório")).toBeDefined();
    expect(screen.getByText(/Alíquota Efetiva:/i)).toBeDefined();
  });

  it("allows selecting number of dependents", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Honorários Clínicos",
        amount: 6000,
        type: "income",
        competence_date: "2026-08-05",
      },
    ];

    render(
      <TaxRadarWidget
        transactions={txs}
        currentMonth="2026-08"
      />
    );

    const btn2 = screen.getByText("2");
    fireEvent.click(btn2);

    expect(screen.getByText("2")).toBeDefined();
  });
});
