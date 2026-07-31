// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { TransactionsPage } from "./TransactionsPage";

vi.mock("./components/Dialog", () => ({
  Dialog: ({ children, open }: any) => open ? <div data-testid="dialog">{children}</div> : null
}));

const navigationMocks = vi.hoisted(() => ({
  pathname: "/movimentacoes",
  useFinance: vi.fn(),
}));

vi.mock("next/navigation", () => ({
  usePathname: () => navigationMocks.pathname,
  useSearchParams: () => new URLSearchParams(),
}));

vi.mock("./components/useFinance", () => ({
  useFinance: navigationMocks.useFinance,
}));

const transactions = [
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
];

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
  navigationMocks.useFinance.mockReset().mockImplementation(
    (
      _route: string,
      _cardId: string | undefined,
      options: {
        transactionFilters?: {
          query?: string;
          type?: string;
          from?: string;
          to?: string;
        };
        transactionPage?: number;
      } = {},
    ) => {
      const filters = options.transactionFilters ?? {};
      const normalizedQuery =
        filters.query?.trim().toLocaleLowerCase("pt-BR") ?? "";
      const filtered = transactions.filter(
        (transaction) =>
          transaction.description
            .toLocaleLowerCase("pt-BR")
            .includes(normalizedQuery) &&
          (!filters.type || transaction.type === filters.type) &&
          (!filters.from || transaction.competence_date >= filters.from) &&
          (!filters.to || transaction.competence_date <= filters.to),
      );
      const pageSize = 3;
      const page = options.transactionPage ?? 0;
      return {
        ownerId: "owner-1",
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
        transactions: filtered.slice(page * pageSize, (page + 1) * pageSize),
        transactionTotal: filtered.length,
        transactionPageSize: pageSize,
        transactionImportBatches: [],
        loading: false,
        message: "",
        setMessage: vi.fn(),
        reload: vi.fn().mockResolvedValue(undefined),
      };
    },
  );
});

afterEach(() => cleanup());

describe("TransactionsPage", () => {
  it("sends inclusive search, type and date filters to the server", () => {
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
    expect(navigationMocks.useFinance).toHaveBeenLastCalledWith(
      "transactions",
      undefined,
      {
        transactionFilters: {
          query: "mercado",
          type: "expense",
          from: "2026-07-01",
          to: "2026-07-31",
        },
        transactionPage: 0,
      },
    );
  });

  it("continues through server pages without repeating rows", () => {
    render(<TransactionsPage />);

    expect(screen.getByText("Mercado na abertura")).toBeTruthy();
    expect(screen.queryByText("Mercado do bairro")).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Próxima" }));

    expect(screen.queryByText("Mercado na abertura")).toBeNull();
    expect(screen.getByText("Mercado do bairro")).toBeTruthy();
    expect(screen.getByText("Salário")).toBeTruthy();
    expect(screen.getByText("Página 2 de 2")).toBeTruthy();
  });

  it("keeps secondary destinations and the full transfer form discoverable", async () => {
    navigationMocks.pathname = "/categorias";
    render(<TransactionsPage />);

    expect(screen.getAllByRole("link", { name: "Mais" })[0].getAttribute("href")).toBe(
      "/configuracoes",
    );
    expect(
      screen.getByRole("link", { name: "Categorias" }).getAttribute("aria-current"),
    ).toBe("page");
    expect(screen.getByRole("link", { name: "Contas" })).toBeTruthy();
    expect(screen.getByRole("link", { name: "Cartões" })).toBeTruthy();

    const newTransactionButton = screen.getByRole("button", { name: /Nova movimentação/i });
    fireEvent.click(newTransactionButton);

    const entryType = await screen.findByLabelText<HTMLSelectElement>(
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
