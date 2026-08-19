// @vitest-environment jsdom
import { cleanup, renderHook, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useFinance } from "./useFinance";

type QueryState = {
  table: string;
  selectOptions?: { count?: string };
  filters: Array<[string, string, string]>;
  orders: Array<[string, boolean]>;
  limitValue?: number;
  rangeValue?: [number, number];
};

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  rpc: vi.fn(),
  queries: [] as QueryState[],
  rpcMonths: [] as string[],
}));

function filterValue(state: QueryState, operator: string, column: string) {
  return state.filters.find(
    ([entryOperator, entryColumn]) =>
      entryOperator === operator && entryColumn === column,
  )?.[2];
}

function transaction(
  id: string,
  overrides: Partial<{
    account_id: string;
    destination_account_id: string | null;
    type: string;
    status: string;
    description: string;
    amount: number;
    competence_date: string;
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
    competence_date: "2026-01-01",
    ...overrides,
  };
}

function resolveQuery(state: QueryState, single = false) {
  if (state.table === "workspaces") {
    return { data: single ? { id: "workspace-1", name: "Pessoal" } : [] };
  }
  if (state.table === "accounts") {
    return {
      data: [
        {
          id: "cash",
          name: "Principal",
          type: "checking",
          initial_balance: 100,
        },
      ],
    };
  }
  if (state.table === "workspace_preferences") {
    return { data: single ? { default_cash_account_id: "cash" } : [] };
  }
  if (state.table === "transaction_import_batches") {
    return {
      data: [
        {
          id: "batch-2",
          account_id: "cash",
          file_name: "julho.csv",
          status: "pending",
          created_at: "2026-07-29T12:00:00Z",
          applied_at: null,
          discarded_at: null,
          transaction_import_items: [
            {
              id: "item-1",
              batch_id: "batch-2",
              row_number: 1,
              competence_date: "2026-07-29",
              description: "Mercado",
              amount_cents: 1250,
              type: "expense",
              status: "ready",
              reason: null,
              fingerprint: "fingerprint-1",
              transaction_id: null,
              created_at: "2026-07-29T12:00:00Z",
            },
          ],
        },
      ],
    };
  }
  if (state.table !== "transactions") return { data: single ? null : [] };

  const status = filterValue(state, "eq", "status");
  const type = filterValue(state, "eq", "type");
  if (single && status === "planned" && type === "income") {
    return {
      data: transaction("next-income", {
        type: "income",
        status: "planned",
        amount: 1000,
        competence_date: "2026-10-03",
      }),
    };
  }
  if (status === "paid") {
    const start = state.rangeValue?.[0] ?? 0;
    return {
      data:
        start === 0
          ? Array.from({ length: 500 }, (_, index) =>
              transaction(`paid-${index}`),
            )
          : start === 500
            ? [
                transaction("paid-oldest", {
                  competence_date: "2010-01-01",
                }),
              ]
            : [],
    };
  }
  if (status === "planned" && type === "expense") {
    return {
      data: [
        transaction("planned-expense", {
          status: "planned",
          amount: 10,
          competence_date: "2026-09-15",
        }),
      ],
    };
  }
  if (state.limitValue === 30) {
    return {
      data: Array.from({ length: 30 }, (_, index) =>
        transaction(`recent-${index}`, {
          competence_date: "2026-07-29",
        }),
      ),
    };
  }

  return {
    data: [
      transaction("history-row", {
        description: "Mercado",
        competence_date: "2026-07-31",
      }),
    ],
    count: 51,
  };
}

function createQuery(table: string) {
  const state: QueryState = {
    table,
    filters: [],
    orders: [],
  };
  mocks.queries.push(state);
  const query = {
    select: vi.fn(
      (_columns: string, options?: { count?: string }) => {
        state.selectOptions = options;
        return query;
      },
    ),
    eq: vi.fn((column: string, value: string) => {
      state.filters.push(["eq", column, value]);
      return query;
    }),
    gte: vi.fn((column: string, value: string) => {
      state.filters.push(["gte", column, value]);
      return query;
    }),
    lte: vi.fn((column: string, value: string) => {
      state.filters.push(["lte", column, value]);
      return query;
    }),
    lt: vi.fn((column: string, value: string) => {
      state.filters.push(["lt", column, value]);
      return query;
    }),
    neq: vi.fn((column: string, value: string) => {
      state.filters.push(["neq", column, value]);
      return query;
    }),
    ilike: vi.fn((column: string, value: string) => {
      state.filters.push(["ilike", column, value]);
      return query;
    }),
    order: vi.fn(
      (column: string, options?: { ascending?: boolean }) => {
        state.orders.push([column, options?.ascending ?? true]);
        return query;
      },
    ),
    limit: vi.fn((value: number) => {
      state.limitValue = value;
      return query;
    }),
    range: vi.fn((from: number, to: number) => {
      state.rangeValue = [from, to];
      return query;
    }),
    maybeSingle: vi.fn(() => Promise.resolve(resolveQuery(state, true))),
    then: (
      resolve: (value: ReturnType<typeof resolveQuery>) => unknown,
      reject: (reason: unknown) => unknown,
    ) => Promise.resolve(resolveQuery(state)).then(resolve, reject),
  };
  return query;
}

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: {
      getUser: vi.fn().mockResolvedValue({
        data: { user: { id: "user-1" } },
      }),
    },
    from: mocks.from,
    rpc: mocks.rpc,
  }),
}));

beforeEach(() => {
  mocks.queries.length = 0;
  mocks.rpcMonths.length = 0;
  mocks.from.mockReset().mockImplementation(createQuery);
  mocks.rpc.mockReset().mockImplementation(
    (_name: string, args: { p_month: string }) => {
      mocks.rpcMonths.push(args.p_month);
      return Promise.resolve({ data: [] });
    },
  );
  vi.useFakeTimers({ shouldAdvanceTime: true });
  vi.setSystemTime(new Date("2026-07-29T12:00:00Z"));
});

afterEach(() => {
  cleanup();
  vi.useRealTimers();
});

describe("useFinance transaction loading", () => {
  it("loads the ten newest import batches from the current workspace and reloads the inbox", async () => {
    const { result } = renderHook(() => useFinance("transactions"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    const importBatchQuery = () =>
      mocks.queries.filter(
        (query) => query.table === "transaction_import_batches",
      );
    expect(importBatchQuery()).toHaveLength(1);
    expect(importBatchQuery()[0]).toMatchObject({
      filters: [["eq", "workspace_id", "workspace-1"]],
      orders: [["created_at", false]],
      limitValue: 10,
    });
    expect(result.current.transactionImportBatches).toMatchObject([
      {
        id: "batch-2",
        file_name: "julho.csv",
        transaction_import_items: [
          { id: "item-1", row_number: 1, amount_cents: 1250 },
        ],
      },
    ]);

    await result.current.reload();

    expect(importBatchQuery()).toHaveLength(2);
    expect(importBatchQuery()[1]).toMatchObject({
      filters: [["eq", "workspace_id", "workspace-1"]],
      orders: [["created_at", false]],
      limitValue: 10,
    });
  });

  it("applies inclusive server filters and a stable second history page", async () => {
    const { result } = renderHook(() =>
      useFinance("transactions", undefined, {
        transactionFilters: {
          query: "Mercado",
          type: "expense",
          from: "2026-07-01",
          to: "2026-07-31",
        },
        transactionPage: 1,
      }),
    );

    await waitFor(() => expect(result.current.loading).toBe(false));

    const historyQuery = mocks.queries.find(
      (query) =>
        query.table === "transactions" &&
        query.selectOptions?.count === "exact",
    );
    expect(historyQuery).toMatchObject({
      filters: expect.arrayContaining([
        ["ilike", "description", "%Mercado%"],
        ["eq", "type", "expense"],
        ["gte", "competence_date", "2026-07-01"],
        ["lte", "competence_date", "2026-07-31"],
      ]),
      orders: [
        ["competence_date", false],
        ["id", false],
      ],
      rangeValue: [25, 49],
    });
    expect(historyQuery?.limitValue).toBeUndefined();
    expect(result.current.transactionTotal).toBe(51);
  });

  it("keeps complete dashboard data separate from the recent list", async () => {
    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    const transactionQueries = mocks.queries.filter(
      (query) => query.table === "transactions",
    );
    expect(
      transactionQueries
        .filter(
          (query) => filterValue(query, "eq", "status") === "paid",
        )
        .map((query) => query.rangeValue),
    ).toEqual([
      [0, 499],
      [500, 999],
    ]);
    expect(
      transactionQueries.find((query) => query.limitValue === 30)?.orders,
    ).toEqual([
      ["competence_date", false],
      ["id", false],
    ]);
    expect(
      transactionQueries.find(
        (query) =>
          filterValue(query, "eq", "status") === "planned" &&
          filterValue(query, "eq", "type") === "expense",
      )?.filters,
    ).toEqual(
      expect.arrayContaining([
        ["gte", "competence_date", "2026-07-29"],
        ["lte", "competence_date", "2026-10-03"],
      ]),
    );
    expect(result.current.transactions).toHaveLength(30);
    expect(result.current.cashPosition.balanceCents).toBe(-401_00);
  });

  it("materializes every commitment month through the actual cutoff", async () => {
    const { result } = renderHook(() => useFinance("dashboard"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(mocks.rpcMonths).toEqual([
      "2026-07-01",
      "2026-08-01",
      "2026-09-01",
      "2026-10-01",
    ]);
  });

  it("keeps a small recent query on lightweight routes", async () => {
    const { result } = renderHook(() => useFinance("accounts"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    const transactionQuery = mocks.queries.find(
      (query) => query.table === "transactions",
    );
    expect(transactionQuery?.limitValue).toBe(30);
  });
});
