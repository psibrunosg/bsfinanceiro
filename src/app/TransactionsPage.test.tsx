// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { TransactionsPage } from "./TransactionsPage";

const navigationMocks = vi.hoisted(() => ({
  pathname: "/movimentacoes",
}));

vi.mock("next/navigation", () => ({
  usePathname: () => navigationMocks.pathname,
  useSearchParams: () => new URLSearchParams(),
}));

vi.mock("./components/useFinance", () => ({
  useFinance: () => ({
    workspace: { id: "workspace-1", name: "Pessoal" },
    accounts: [
      {
        id: "account-1",
        name: "Conta principal",
        type: "checking",
        initial_balance: 0,
      },
    ],
    categories: [],
    transactions: [
      {
        id: "expense-at-start",
        account_id: "account-1",
        destination_account_id: null,
        type: "expense",
        status: "paid",
        description: "Mercado na abertura",
        amount: 80,
        competence_date: "2026-07-01",
      },
      {
        id: "expense-in-period",
        account_id: "account-1",
        destination_account_id: null,
        type: "expense",
        status: "paid",
        description: "Mercado Central",
        amount: 125.5,
        competence_date: "2026-07-15",
      },
      {
        id: "expense-at-end",
        account_id: "account-1",
        destination_account_id: null,
        type: "expense",
        status: "paid",
        description: "Mercado no fechamento",
        amount: 90,
        competence_date: "2026-07-31",
      },
      {
        id: "expense-outside-period",
        account_id: "account-1",
        destination_account_id: null,
        type: "expense",
        status: "paid",
        description: "Mercado do bairro",
        amount: 30,
        competence_date: "2026-06-30",
      },
      {
        id: "income-in-period",
        account_id: "account-1",
        destination_account_id: null,
        type: "income",
        status: "paid",
        description: "Salário",
        amount: 5000,
        competence_date: "2026-07-10",
      },
    ],
    loading: false,
    message: "",
    setMessage: vi.fn(),
    reload: vi.fn().mockResolvedValue(undefined),
  }),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      getUser: vi.fn(),
      signOut: vi.fn(),
    },
    from: vi.fn(),
  }),
}));

beforeEach(() => {
  navigationMocks.pathname = "/movimentacoes";
});

afterEach(() => cleanup());

describe("TransactionsPage", () => {
  it("shows only matching expenses in the selected period", () => {
    render(<TransactionsPage />);

    fireEvent.change(screen.getByLabelText("Buscar movimentações"), {
      target: { value: "mercado" },
    });
    fireEvent.change(screen.getByLabelText("Tipo"), {
      target: { value: "expense" },
    });
    fireEvent.change(screen.getByLabelText("Data inicial"), {
      target: { value: "2026-07-01" },
    });
    fireEvent.change(screen.getByLabelText("Data final"), {
      target: { value: "2026-07-31" },
    });

    expect(screen.getByText("Mercado na abertura")).toBeTruthy();
    expect(screen.getByText("Mercado Central")).toBeTruthy();
    expect(screen.getByText("Mercado no fechamento")).toBeTruthy();
    expect(screen.queryByText("Mercado do bairro")).toBeNull();
    expect(screen.queryByText("Salário")).toBeNull();
  });

  it("keeps secondary destinations and the full transfer form discoverable", () => {
    navigationMocks.pathname = "/categorias";
    render(<TransactionsPage />);

    const moreNavigation = screen.getByText("Mais").closest("details");
    expect(moreNavigation).toBeTruthy();
    expect(moreNavigation?.open).toBe(true);
    expect(screen.getByText("Mais").classList.contains("active")).toBe(true);
    expect(
      screen.getByRole("link", { name: "Categorias" }).getAttribute("aria-current"),
    ).toBe("page");
    expect(moreNavigation?.querySelector('a[href="/contas"]')).toBeTruthy();
    expect(moreNavigation?.querySelector('a[href="/cartoes"]')).toBeTruthy();
    expect(
      screen
        .getByText("Mais detalhes para registrar")
        .closest("details"),
    ).toBeTruthy();
    const entryType = screen.getByLabelText<HTMLSelectElement>(
      "Tipo de movimentação",
    );
    expect(
      entryType.querySelector('option[value="transfer"]')?.textContent,
    ).toBe("Transferência");
  });

  it("explains when no transaction matches the filters", () => {
    render(<TransactionsPage />);

    fireEvent.change(screen.getByLabelText("Buscar movimentações"), {
      target: { value: "inexistente" },
    });

    expect(
      screen.getByText("Nenhuma movimentação corresponde aos filtros."),
    ).toBeTruthy();
  });
});
