// @vitest-environment jsdom
import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import { CardsPage } from "./CardsPage";


let mockSearchParams = new URLSearchParams("cardId=card-1");
vi.mock("next/navigation", () => ({
  useSearchParams: () => mockSearchParams,
}));

vi.mock("./components/useFinance", () => ({
  useFinance: () => ({
    workspace: { id: "workspace-1", name: "Finanças" },
    accounts: [], categories: [],
    cards: [{ id: "card-1", name: "Cartão", credit_limit: 1000, closing_day: 10, due_day: 20 }],
    invoices: [], transactions: [], todayTransactions: [], budgets: [], goals: [], monthSpent: {}, commitments: [], occurrences: [], alertPrefs: null,
    statementImports: [], loading: false, message: "", setMessage: vi.fn(), reload: vi.fn().mockResolvedValue(undefined),
  }),
}));

vi.mock("./components/Nav", () => ({ Nav: () => null }));
vi.mock("./components/PageHeader", () => ({ 
  PageHeader: ({ action }: { action?: { label: string; onClick: () => void } }) => action ? <button onClick={action.onClick}>{action.label}</button> : null 
}));
vi.mock("./components/List", () => ({ List: ({ children }: { children: React.ReactNode }) => <div>{children}</div> }));
vi.mock("@/lib/supabase/client", () => ({ createClient: vi.fn(() => ({})) }));

describe("CardsPage statement upload", () => {
  it("references feedback only after the upload form renders feedback", async () => {
    render(<CardsPage />);

    const fileInput = screen.getByLabelText("Arquivo de fatura");
    expect(fileInput.getAttribute("aria-describedby")).toBe("statement-import-help");

    fireEvent.submit(fileInput.closest("form")!);

    await waitFor(() => expect(screen.getByRole("alert").textContent).toContain("Selecione um arquivo"));
    expect(fileInput.getAttribute("aria-describedby")).toBe("statement-import-help statement-import-feedback");
  });
});

describe("CardsPage card form", () => {
  beforeEach(() => {
    HTMLDialogElement.prototype.showModal = vi.fn();
    HTMLDialogElement.prototype.close = vi.fn();
  });

  it("allows opening the form and saving a new card", async () => {
    mockSearchParams = new URLSearchParams();
    
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ success: true })
    });
    
    render(<CardsPage />);
    
    // Open dialog
    fireEvent.click(screen.getAllByText("Cadastrar cartão")[0]);
    expect(screen.getByText("Nome do cartão")).toBeDefined();
    
    // Fill the form
    const nameInputs = screen.getAllByPlaceholderText("Nome do cartão");
    fireEvent.change(nameInputs[0], { target: { value: "Nubank" } });
    
    const limitInput = screen.getByLabelText("Limite de crédito");
    fireEvent.change(limitInput, { target: { value: "5000,00" } });
    
    // Submit the form
    fireEvent.submit(limitInput.closest("form")!);
    
    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith("/api/cards", expect.any(Object));
    });
  });
});
