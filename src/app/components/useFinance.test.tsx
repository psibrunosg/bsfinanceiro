// @vitest-environment jsdom
import { cleanup, renderHook, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { apiFetch } from "@/lib/api-client";
import {
  clearFinanceCache,
  TRANSACTION_HISTORY_PAGE_SIZE,
  useFinance,
} from "./useFinance";

vi.mock("@/lib/api-client", () => ({ apiFetch: vi.fn() }));

function tx(
  id: string,
  overrides: Partial<{
    account_id: string;
    destination_account_id: string | null;
    type: string;
    status: string;
    description: string;
    amount: number;
    competence_date: string;
    category_id: string | null;
  }> = {},
) {
  return {
    id,
    account_id: "cash",
    destination_account_id: null,
    type: "expense",
    status: "paid",
    description: id,
    amount: 1,
    competence_date: "2026-09-01",
    category_id: null,
    invoice_id: null,
    ...overrides,
  };
}

function response(body: unknown, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    json: vi.fn().mockResolvedValue(body),
  } as unknown as Response;
}

function bootstrap(overrides: Record<string, unknown> = {}) {
  return {
    accounts: [
      {
        id: "cash",
        name: "Principal",
        type: "checking",
        initial_balance: 100,
        is_shared: false,
      },
    ],
    categories: [
      { id: "food", name: "Alimentação", kind: "expense", color: "#f00" },
    ],
    cards: [],
    invoices: [],
    transactions: [
      tx("income", {
        type: "income",
        description: "Receita",
        amount: 1000,
        competence_date: "2026-09-05",
      }),
      tx("market", {
        description: "Mercado Central",
        amount: 200,
        competence_date: "2026-09-10",
        category_id: "food",
      }),
    ],
    budgets: [{ id: "budget-1", category_id: "food", amount: 500 }],
    goals: [],
    commitments: [],
    occurrences: [],
    debts: [],
    investments: [],
    investment_operations: [],
    workspace_users: [],
    workspace_invites: [
      {
        id: "invite-1",
        workspace_id: "workspace-1",
        token: "abc",
        role: "viewer",
        expires_at: "2026-10-01T00:00:00Z",
        created_at: "2026-09-01T00:00:00Z",
      },
    ],
    category_rules: [
      { id: "rule-1", pattern: "mercado", category_id: "food" },
    ],
    contexts: [
      {
        id: "ctx-1",
        workspace_id: "workspace-1",
        owner_id: "user-1",
        kind: "personal",
        name: "Pessoal",
        color: "#8b5cf6",
        active: true,
        created_at: "2026-09-01T00:00:00Z",
      },
    ],
    payslips: [
      {
        id: "pay-1",
        employer: "Clínica",
        competence: "2026-09-01",
        gross_amount: "7500",
        discounts_amount: "300",
        net_amount: "7200",
        received_date: "2026-09-05",
        transaction_id: null,
      },
    ],
    workspace_preferences: { default_cash_account_id: "cash" },
    alert_preferences: null,
    ...overrides,
  };
}

beforeEach(() => {
  clearFinanceCache();
  localStorage.clear();
  localStorage.setItem(
    "bsfinanceiro_user",
    JSON.stringify({ id: "user-1", email: "qa@example.com" }),
  );
  localStorage.setItem(
    "bsfinanceiro_workspace",
    JSON.stringify({ id: "workspace-1", name: "Pessoal", kind: "personal" }),
  );
  localStorage.setItem("bsfinanceiro_token", "test-token");
  vi.mocked(apiFetch).mockReset();
  vi.mocked(apiFetch).mockResolvedValue(response(bootstrap()));
});

afterEach(() => {
  cleanup();
  localStorage.clear();
});

describe("useFinance via VPS bootstrap", () => {
  it("loads the authenticated VPS bootstrap and exposes auxiliary workspace data", async () => {
    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(apiFetch).toHaveBeenCalledWith(
      "/api/bootstrap?workspace_id=workspace-1",
    );
    expect(result.current.accounts).toHaveLength(1);
    expect(result.current.transactions).toHaveLength(2);
    expect(result.current.categoryRules).toEqual([
      { id: "rule-1", pattern: "mercado", category_id: "food" },
    ]);
    expect(result.current.contexts).toHaveLength(1);
    expect(result.current.workspaceInvites).toHaveLength(1);
    expect(result.current.defaultCashAccountId).toBe("cash");
    expect(result.current.payslips[0]).toMatchObject({
      gross_amount: 7500,
      discounts_amount: 300,
      net_amount: 7200,
    });
    expect(result.current.message).toBe("");
  });

  it("loads transaction import batches from the VPS bootstrap", async () => {
    vi.mocked(apiFetch).mockResolvedValue(
      response(
        bootstrap({
          transaction_import_batches: [
            {
              id: "batch-1",
              account_id: "cash",
              file_name: "extrato.csv",
              status: "pending",
              created_at: "2026-09-30T12:00:00Z",
              applied_at: null,
              discarded_at: null,
              transaction_import_items: [
                {
                  id: "item-1",
                  batch_id: "batch-1",
                  row_number: 2,
                  competence_date: "2026-09-29",
                  description: "Mercado",
                  amount_cents: 4590,
                  type: "expense",
                  status: "ready",
                  reason: null,
                  fingerprint: "2026-09-29|4590|expense|mercado",
                  category_id: "food",
                  transaction_id: null,
                  created_at: "2026-09-30T12:00:00Z",
                },
              ],
            },
          ],
        }),
      ),
    );

    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.transactionImportBatches).toEqual([
      expect.objectContaining({
        id: "batch-1",
        file_name: "extrato.csv",
        status: "pending",
        transaction_import_items: [
          expect.objectContaining({
            id: "item-1",
            row_number: 2,
            status: "ready",
            category_id: "food",
          }),
        ],
      }),
    ]);
  });

  it("filters and paginates transaction history without falling back to Supabase", async () => {
    const rows = Array.from({ length: 70 }, (_, index) =>
      tx(`row-${index}`, {
        description: index % 2 === 0 ? `Mercado ${index}` : `Outro ${index}`,
        type: index % 3 === 0 ? "income" : "expense",
        competence_date:
          index < 60
            ? `2026-09-${String((index % 28) + 1).padStart(2, "0")}`
            : "2026-08-15",
      }),
    );
    vi.mocked(apiFetch).mockResolvedValue(
      response(bootstrap({ transactions: rows })),
    );

    const { result } = renderHook(() =>
      useFinance("transactions", undefined, {
        transactionFilters: {
          query: "mercado",
          type: "expense",
          from: "2026-09-01",
          to: "2026-09-30",
        },
        transactionPage: 0,
      }),
    );

    await waitFor(() => expect(result.current.loading).toBe(false));

    const expected = rows.filter(
      (row) =>
        row.description.toLowerCase().includes("mercado") &&
        row.type === "expense" &&
        row.competence_date >= "2026-09-01" &&
        row.competence_date <= "2026-09-30",
    );

    expect(result.current.transactionTotal).toBe(expected.length);
    expect(result.current.transactions).toEqual(
      expected.slice(0, TRANSACTION_HISTORY_PAGE_SIZE),
    );
    expect(apiFetch).toHaveBeenCalledTimes(1);
  });

  it("returns the requested second transaction page", async () => {
    const rows = Array.from({ length: 60 }, (_, index) =>
      tx(`row-${index}`, { description: "Mercado" }),
    );
    vi.mocked(apiFetch).mockResolvedValue(
      response(bootstrap({ transactions: rows })),
    );

    const { result } = renderHook(() =>
      useFinance("transactions", undefined, { transactionPage: 1 }),
    );

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.transactionTotal).toBe(60);
    expect(result.current.transactions).toHaveLength(
      TRANSACTION_HISTORY_PAGE_SIZE,
    );
    expect(result.current.transactions[0].id).toBe(
      `row-${TRANSACTION_HISTORY_PAGE_SIZE}`,
    );
  });

  it("reload fetches a fresh bootstrap from the VPS", async () => {
    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(apiFetch).toHaveBeenCalledTimes(1);

    await result.current.reload();

    expect(apiFetch).toHaveBeenCalledTimes(2);
  });

  it("stops loading and surfaces a VPS error instead of querying a legacy backend", async () => {
    vi.mocked(apiFetch).mockRejectedValue(new Error("rede indisponível"));

    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.message).toContain("Não foi possível carregar seus dados");
    expect(result.current.message).toContain("rede indisponível");
    expect(apiFetch).toHaveBeenCalledTimes(1);
  });

  it("rejects malformed bootstrap responses cleanly", async () => {
    vi.mocked(apiFetch).mockResolvedValue(response({ transactions: [] }));

    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(result.current.message).toContain("bootstrap inválido");
  });
});
