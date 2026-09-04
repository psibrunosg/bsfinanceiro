// @vitest-environment jsdom
import React from "react";
import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent, waitFor, cleanup } from "@testing-library/react";
import ExpensesHubPage from "./page";
import { createClient } from "@/lib/supabase/client";
import { SupabaseClient } from "@supabase/supabase-js";
import { MonthProvider } from "../components/MonthContext";

vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams(),
}));

vi.mock("../components/useFinance", () => ({
  useFinance: () => ({
    workspace: { id: "workspace-1", name: "Finanças" },
    accounts: [], categories: [], cards: [], invoices: [], transactions: [], todayTransactions: [], budgets: [], goals: [], monthSpent: {}, commitments: [], occurrences: [], alertPrefs: null,
    statementImports: [], loading: false, message: "", setMessage: vi.fn(), reload: vi.fn().mockResolvedValue(undefined),
  }),
}));

vi.mock("../components/Nav", () => ({ Nav: () => null }));
vi.mock("../components/PageHeader", () => ({ 
  PageHeader: ({ action }: { action?: { label: string; onClick: () => void } }) => action ? <button onClick={action.onClick}>{action.label}</button> : null 
}));
vi.mock("../components/List", () => ({ List: ({ children }: { children: React.ReactNode }) => <div>{children}</div> }));
vi.mock("@/lib/supabase/client", () => ({ createClient: vi.fn() }));

describe("ExpensesHubPage recurrent form", () => {
  beforeEach(() => {
    HTMLDialogElement.prototype.showModal = vi.fn();
    HTMLDialogElement.prototype.close = vi.fn();
    vi.resetAllMocks();
  });
  afterEach(() => {
    cleanup();
  });

  it("submits a new recurrent commitment", async () => {
    const mockInsert = vi.fn().mockResolvedValue({ error: null });
    
    const mockQuery: Record<string, unknown> = {
      then: function(resolve: (val: unknown) => void) { resolve({ data: [] }); }
    };
    mockQuery.select = vi.fn().mockReturnValue(mockQuery);
    mockQuery.eq = vi.fn().mockReturnValue(mockQuery);
    mockQuery.not = vi.fn().mockReturnValue(mockQuery);
    mockQuery.gte = vi.fn().mockReturnValue(mockQuery);
    mockQuery.lte = vi.fn().mockReturnValue(mockQuery);
    mockQuery.order = vi.fn().mockReturnValue(mockQuery);
    mockQuery.limit = vi.fn().mockReturnValue(mockQuery);
    
    const mockFrom = vi.fn().mockReturnValue({ insert: mockInsert, select: () => mockQuery });
    
    vi.mocked(createClient).mockReturnValue({
      auth: { getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-1" } } }) },
      from: mockFrom,
      rpc: vi.fn().mockResolvedValue({ data: [], error: null })
    } as unknown as SupabaseClient);

    render(
      <MonthProvider>
        <ExpensesHubPage />
      </MonthProvider>
    );
    
    // Switch to Recorrentes tab
    const recurrentTab = await screen.findByRole("button", { name: "Recorrentes" });
    fireEvent.click(recurrentTab);
    
    // Open dialog via action button in the tab content
    // wait for the 'Adicionar' button to appear
    const addBtn = await screen.findByRole("button", { name: "Novo compromisso" });
    fireEvent.click(addBtn);
    
    // Fill the recurrent form
    const descInput = await screen.findByLabelText("Descrição");
    fireEvent.change(descInput, { target: { value: "Aluguel" } });
    
    const amountInput = screen.getByLabelText("Valor");
    fireEvent.change(amountInput, { target: { value: "2500,00" } });
    
    const dayInput = screen.getByLabelText("Dia do vencimento");
    fireEvent.change(dayInput, { target: { value: "5" } });
    
    // Submit
    fireEvent.submit(amountInput.closest("form")!);
    
    await waitFor(() => {
      expect(mockFrom).toHaveBeenCalledWith("fixed_commitments");
      expect(mockInsert).toHaveBeenCalledWith({
        workspace_id: "workspace-1",
        owner_id: "user-1",
        description: "Aluguel",
        amount: 2500,
        due_day: 5,
        account_id: null,
        category_id: null
      });
    });
  });

  it("submits a new recurrent commitment via API when available", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").mockImplementation(async (url: RequestInfo | URL) => {
      const urlStr = String(url);
      if (urlStr.includes("/api/commitments")) {
        return {
          ok: true,
          json: async () => ({ success: true, commitment: { id: "c-1" } }),
        } as Response;
      }
      if (urlStr.includes("/api/bootstrap")) {
        return {
          ok: true,
          json: async () => ({ commitments: [], occurrences: [], transactions: [] }),
        } as Response;
      }
      return { ok: false, json: async () => ({}) } as Response;
    });

    const mockQuery: Record<string, unknown> = {
      then: function(resolve: (val: unknown) => void) { resolve({ data: [] }); }
    };
    mockQuery.select = vi.fn().mockReturnValue(mockQuery);
    mockQuery.eq = vi.fn().mockReturnValue(mockQuery);
    mockQuery.not = vi.fn().mockReturnValue(mockQuery);
    mockQuery.gte = vi.fn().mockReturnValue(mockQuery);
    mockQuery.lte = vi.fn().mockReturnValue(mockQuery);
    mockQuery.order = vi.fn().mockReturnValue(mockQuery);
    mockQuery.limit = vi.fn().mockReturnValue(mockQuery);
    const mockFrom = vi.fn().mockReturnValue({ insert: vi.fn(), select: () => mockQuery });

    vi.mocked(createClient).mockReturnValue({
      auth: { getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-1" } } }) },
      from: mockFrom,
      rpc: vi.fn().mockResolvedValue({ data: [], error: null })
    } as unknown as SupabaseClient);

    render(
      <MonthProvider>
        <ExpensesHubPage />
      </MonthProvider>
    );

    const recurrentTab = await screen.findByRole("button", { name: "Recorrentes" });
    fireEvent.click(recurrentTab);

    const addBtn = await screen.findByRole("button", { name: "Novo compromisso" });
    fireEvent.click(addBtn);

    const descInput = await screen.findByLabelText("Descrição");
    fireEvent.change(descInput, { target: { value: "Internet Fibra" } });

    const amountInput = screen.getByLabelText("Valor");
    fireEvent.change(amountInput, { target: { value: "150,00" } });

    const dayInput = screen.getByLabelText("Dia do vencimento");
    fireEvent.change(dayInput, { target: { value: "10" } });

    fireEvent.submit(amountInput.closest("form")!);

    await waitFor(() => {
      expect(fetchSpy).toHaveBeenCalledWith(
        "/api/commitments",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            workspace_id: "workspace-1",
            description: "Internet Fibra",
            amount: 150,
            due_day: 10,
            account_id: null,
            category_id: null,
          }),
        })
      );
      expect(screen.getByRole("status").textContent).toContain("Compromisso criado.");
    });

    fetchSpy.mockRestore();
  });
});
