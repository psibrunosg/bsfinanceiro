// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ClinicBusinessWidget } from "./ClinicBusinessWidget";

describe("ClinicBusinessWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders clinic DRE and allows switching to Partner Loans and Cash Gap tabs", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Consulta Paciente Beatriz",
        amount: 3000,
        type: "income",
        competence_date: "2026-08-10",
      },
      {
        id: "tx-2",
        description: "Aluguel Consultório Sala 402 [Clínica]",
        amount: 1500,
        type: "expense",
        competence_date: "2026-08-08",
        context_name: "Pessoal",
        is_clinic_expense_on_personal: true,
      },
    ];

    render(
      <ClinicBusinessWidget
        transactions={txs}
        currentMonth="2026-08"
        initialCashBalance={200}
      />
    );

    expect(screen.getByText("Módulo Empresa (Consultório & PJ)")).toBeDefined();
    expect(screen.getByText("Faturamento Bruto")).toBeDefined();
    expect(screen.getByText("Lucro Líquido da Clínica")).toBeDefined();

    // Alternar para aba de Empréstimos de Sócio
    const loanBtn = screen.getByRole("button", { name: /Empréstimos de Sócio/i });
    fireEvent.click(loanBtn);
    expect(screen.getByText(/A clínica deve ao sócio/i)).toBeDefined();

    // Alternar para aba de Descasamento de Caixa
    const gapBtn = screen.getByRole("button", { name: /Descasamento de Caixa/i });
    fireEvent.click(gapBtn);
    expect(screen.getByText(/Alerta de Descasamento de Liquidez!/i)).toBeDefined();
  });
});
