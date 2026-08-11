// @vitest-environment jsdom
import React from "react";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { CardsPage } from "./CardsPage";

const mocks = vi.hoisted(() => ({
  statementImports: [] as Record<string, unknown>[],
  rpc: vi.fn(),
  reload: vi.fn().mockResolvedValue(undefined),
}));

vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams("cardId=card-1"),
}));

vi.mock("./components/useFinance", () => ({
  useFinance: () => ({
    workspace: { id: "workspace-1", name: "Finanças" },
    accounts: [], categories: [],
    cards: [{ id: "card-1", name: "Cartão", credit_limit: 1000, closing_day: 10, due_day: 20 }],
    invoices: [], transactions: [], todayTransactions: [], budgets: [], goals: [], monthSpent: {}, commitments: [], occurrences: [], alertPrefs: null,
    statementImports: mocks.statementImports, loading: false, message: "", setMessage: vi.fn(), reload: mocks.reload,
  }),
}));

vi.mock("./components/Nav", () => ({ Nav: () => null }));
vi.mock("./components/PageHeader", () => ({ PageHeader: () => null }));
vi.mock("./components/List", () => ({ List: ({ children }: { children: React.ReactNode }) => <div>{children}</div> }));
vi.mock("@/lib/supabase/client", () => ({ createClient: () => ({ rpc: mocks.rpc }) }));

describe("CardsPage statement upload", () => {
  beforeEach(() => {
    mocks.statementImports.length = 0;
    mocks.rpc.mockReset();
    mocks.reload.mockClear();
  });

  it("references feedback only after the upload form renders feedback", async () => {
    render(<CardsPage />);

    const fileInput = screen.getByLabelText("Arquivo de fatura");
    expect(fileInput.getAttribute("aria-describedby")).toBe("statement-import-help");

    fireEvent.submit(fileInput.closest("form")!);

    await waitFor(() => expect(screen.getByRole("alert").textContent).toContain("Selecione um arquivo"));
    expect(fileInput.getAttribute("aria-describedby")).toBe("statement-import-help statement-import-feedback");
  });

  it("shows an editable pending review and sends one corrected structured batch", async () => {
    mocks.statementImports.push({
      id: "import-1",
      file_name: "fatura.pdf",
      status: "pending_review",
      error_code: null,
      declared_total_cents: 22335,
      created_at: "2026-08-11T00:00:00Z",
      credit_card_statement_import_items: [
        {
          ordinal: 1,
          purchased_on: "2026-08-10",
          description: "PADARIA CENTRAL",
          installment_amount_cents: 2345,
          installment_number: 1,
          installment_count: 1,
          total_amount_cents: 2345,
          needs_review: false,
          source_fingerprint: "a".repeat(64),
        },
        {
          ordinal: 2,
          purchased_on: "2026-08-12",
          description: "LOJA EXEMPLO",
          installment_amount_cents: 19990,
          installment_number: 2,
          installment_count: 10,
          total_amount_cents: null,
          needs_review: true,
          source_fingerprint: "b".repeat(64),
        },
      ],
    });
    mocks.rpc.mockResolvedValue({ data: ["purchase-1", "purchase-2"], error: null });

    render(<CardsPage />);

    expect(screen.getByRole("status").textContent).toContain("Revisão necessária");
    expect(screen.getByText(/Diferença: R\$\s*0,00/)).toBeTruthy();
    const totalInput = screen.getByLabelText("Total original de LOJA EXEMPLO");
    expect(totalInput).toHaveProperty("value", "");
    fireEvent.change(totalInput, { target: { value: "1.999,00" } });
    fireEvent.click(screen.getByRole("button", { name: "Confirmar fatura revisada" }));

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledTimes(1));
    expect(mocks.rpc).toHaveBeenCalledWith("apply_credit_card_statement_import", {
      p_import_id: "import-1",
      p_items: [
        {
          ordinal: 1,
          purchasedOn: "2026-08-10",
          description: "PADARIA CENTRAL",
          installmentAmountCents: 2345,
          installmentNumber: 1,
          installmentCount: 1,
          totalAmountCents: 2345,
          sourceFingerprint: "a".repeat(64),
        },
        {
          ordinal: 2,
          purchasedOn: "2026-08-12",
          description: "LOJA EXEMPLO",
          installmentAmountCents: 19990,
          installmentNumber: 2,
          installmentCount: 10,
          totalAmountCents: 199900,
          sourceFingerprint: "b".repeat(64),
        },
      ],
    });
    expect(mocks.rpc).not.toHaveBeenCalledWith("pay_credit_card_invoice", expect.anything());
  });
});
