// @vitest-environment jsdom
import React from "react";
import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { AccountsPage } from "./AccountsPage";

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    from: vi.fn().mockReturnValue({
      select: vi.fn().mockReturnThis(),
      eq: vi.fn().mockReturnThis(),
      insert: vi.fn().mockResolvedValue({ error: null }),
    }),
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-1" } } }),
    },
  }),
}));

vi.mock("./components/Nav", () => ({ Nav: () => null }));
vi.mock("./components/Dialog", () => ({
  Dialog: ({ children, open }: { children: React.ReactNode; open: boolean }) =>
    open ? <div data-testid="dialog">{children}</div> : null,
}));
vi.mock("./components/EmergencyFundWidget", () => ({
  EmergencyFundWidget: ({ initialFundBalance }: { initialFundBalance: number }) => (
    <div data-testid="emergency-fund">Fundo: {initialFundBalance}</div>
  ),
}));

const mockFinanceData = {
  ownerId: "user-1",
  workspace: { id: "ws-1", name: "Workspace Principal" },
  accounts: [
    {
      id: "acc-bank-1",
      name: "Caixa Econômica",
      type: "checking",
      initial_balance: 1000,
      is_shared: true,
    },
    {
      id: "acc-card-1",
      name: "Cartão Nubank",
      type: "credit_card",
      initial_balance: 0,
      is_shared: true,
    },
  ],
  cards: [
    {
      id: "card-1",
      account_id: "acc-card-1",
      name: "Nubank",
      brand: "Mastercard",
      last_four: "8511",
      credit_limit: 5000,
      closing_day: 1,
      due_day: 10,
    },
  ],
  invoices: [
    {
      id: "inv-paid-1",
      account_id: "acc-card-1",
      credit_card_id: "card-1",
      due_date: "2026-02-10",
      status: "paid",
      total_amount: 1500,
    },
  ],
  transactions: [
    {
      id: "tx-inc-1",
      account_id: "acc-bank-1",
      destination_account_id: null,
      type: "income",
      status: "paid",
      description: "Salário",
      amount: 5000,
      competence_date: "2026-03-05",
    },
    {
      id: "tx-card-past-1",
      account_id: "acc-card-1",
      destination_account_id: null,
      type: "expense",
      status: "paid",
      description: "Supermercado pago na fatura anterior",
      amount: 1500,
      competence_date: "2026-02-01",
      invoice_id: "inv-paid-1",
    },
  ],
  loading: false,
  message: null,
  setMessage: vi.fn(),
  reload: vi.fn(),
};

vi.mock("./components/useFinance", () => ({
  useFinance: () => mockFinanceData,
}));

describe("AccountsPage", () => {
  it("computes liquid bank balance and paid credit card balance without negative distortion", () => {
    render(<AccountsPage />);

    // Saldo bancário: 1000 (initial) + 5000 (income) = 6000
    // Fatura de cartão está 'paid', logo dívida aberta = 0
    // Saldo total consolidado = 6000 - 0 = 6000 (R$ 6.000,00)
    expect(screen.getByText("Saldo total consolidado")).toBeDefined();
    expect(screen.getByText("Saldo em bancos")).toBeDefined();
    expect(screen.getByText("Faturas de cartões")).toBeDefined();

    // R$ 6.000,00 aparece para o saldo consolidado e para a conta Caixa
    const formatted6000 = screen.getAllByText(/6\.000,00/);
    expect(formatted6000.length).toBeGreaterThanOrEqual(2);

    // O cartão deve exibir R$ 0,00 e status de fatura paga
    expect(screen.getByText("Fatura paga · Limite livre")).toBeDefined();
    expect(screen.getByText("Todas as faturas pagas")).toBeDefined();
  });

  it("deducts open credit card invoices from consolidated balance", async () => {
    const openInvoiceMock = {
      ...mockFinanceData,
      invoices: [
        {
          id: "inv-open-1",
          account_id: "acc-card-1",
          credit_card_id: "card-1",
          due_date: "2026-04-10",
          status: "open",
          total_amount: 500,
        },
      ],
    };

    vi.spyOn(mockFinanceData, "reload").mockImplementation(() => Promise.resolve());
    const useFinanceMod = await import("./components/useFinance");
    vi.spyOn(useFinanceMod, "useFinance").mockReturnValue(openInvoiceMock as unknown as ReturnType<typeof useFinanceMod.useFinance>);

    render(<AccountsPage />);

    // Banco: 6000. Dívida cartão: 500. Consolidado = 5500
    const formatted5500 = screen.getAllByText(/5\.500,00/);
    expect(formatted5500.length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText(/1 fatura\(s\) em aberto/)).toBeDefined();
  });
});
