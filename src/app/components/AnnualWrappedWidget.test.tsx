// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { AnnualWrappedWidget } from "./AnnualWrappedWidget";

describe("AnnualWrappedWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders Annual Wrapped retrospective widget and allows copying share text", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Salário Janeiro",
        amount: 15000,
        type: "income",
        competence_date: "2026-01-05",
      },
      {
        id: "tx-2",
        description: "Aluguel",
        amount: 3000,
        type: "expense",
        competence_date: "2026-01-10",
        category_name: "Moradia",
      },
    ];

    render(<AnnualWrappedWidget transactions={txs} year={2026} />);

    expect(screen.getByText("Relatório Anual Wrapped 2026")).toBeDefined();
    expect(screen.getByText(/Taxa de Poupança/i)).toBeDefined();
    expect(screen.getByText(/Top 3 Categorias/i)).toBeDefined();

    const shareBtn = screen.getByRole("button", { name: /Compartilhar Meu Wrapped/i });
    fireEvent.click(shareBtn);

    expect(screen.getByText(/Copiado para a área de transferência!/i)).toBeDefined();
  });
});
