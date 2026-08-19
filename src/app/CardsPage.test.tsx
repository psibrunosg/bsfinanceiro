// @vitest-environment jsdom
import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { CardsPage } from "./CardsPage";

vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams("cardId=card-1"),
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
vi.mock("./components/PageHeader", () => ({ PageHeader: () => null }));
vi.mock("./components/List", () => ({ List: ({ children }: { children: React.ReactNode }) => <div>{children}</div> }));
vi.mock("@/lib/supabase/client", () => ({ createClient: () => ({}) }));

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
