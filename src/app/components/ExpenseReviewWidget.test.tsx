// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ExpenseReviewWidget } from "./ExpenseReviewWidget";

describe("ExpenseReviewWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders Tinder dos Gastos widget and allows reviewing items", () => {
    const txs = [
      {
        id: "tx-1",
        description: "iFood Pizza",
        amount: 80,
        type: "expense",
        competence_date: "2026-08-10",
      },
    ];

    render(<ExpenseReviewWidget transactions={txs} currentMonth="2026-08" />);

    expect(screen.getByText("Tinder dos Gastos (Revisão de Arrependimentos)")).toBeDefined();
    expect(screen.getByText("iFood Pizza")).toBeDefined();

    const likeBtn = screen.getByRole("button", { name: /Valeu a Pena!/i });
    fireEvent.click(likeBtn);

    expect(screen.getByText(/Revisão Mensal Concluída!/i)).toBeDefined();
  });
});
