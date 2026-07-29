// @vitest-environment jsdom
import { cleanup, renderHook, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useFinance } from "./useFinance";

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  transactionQueries: [] as Array<{ limit: ReturnType<typeof vi.fn> }>,
}));

function createQuery(table: string) {
  const result =
    table === "workspaces"
      ? { data: { id: "workspace-1", name: "Pessoal" } }
      : { data: [] };
  const query = {
    select: vi.fn(),
    eq: vi.fn(),
    order: vi.fn(),
    limit: vi.fn(),
    maybeSingle: vi.fn(),
    or: vi.fn(),
    then: vi.fn(),
  };

  query.select.mockReturnValue(query);
  query.eq.mockReturnValue(query);
  query.order.mockReturnValue(query);
  query.limit.mockReturnValue(query);
  query.or.mockReturnValue(query);
  query.maybeSingle.mockResolvedValue(result);
  query.then.mockImplementation((resolve, reject) =>
    Promise.resolve(result).then(resolve, reject),
  );

  if (table === "transactions") {
    mocks.transactionQueries.push(query);
  }

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
  }),
}));

beforeEach(() => {
  mocks.transactionQueries.length = 0;
  mocks.from.mockReset().mockImplementation(createQuery);
});

afterEach(() => cleanup());

describe("useFinance transaction history query", () => {
  it("loads the complete history on the transactions route", async () => {
    const { result } = renderHook(() => useFinance("transactions"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(mocks.transactionQueries).toHaveLength(1);
    expect(mocks.transactionQueries[0].limit).not.toHaveBeenCalled();
  });

  it("keeps the transaction cap on lightweight routes", async () => {
    const { result } = renderHook(() => useFinance("accounts"));

    await waitFor(() => expect(result.current.loading).toBe(false));

    expect(mocks.transactionQueries).toHaveLength(1);
    expect(mocks.transactionQueries[0].limit).toHaveBeenCalledWith(30);
  });
});
