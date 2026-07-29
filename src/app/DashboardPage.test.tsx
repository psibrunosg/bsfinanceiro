// @vitest-environment jsdom
import React from "react";
import {
  act,
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { DashboardPage } from "./DashboardPage";

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  insert: vi.fn(),
  resolveReload: undefined as (() => void) | undefined,
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({ from: mocks.from }),
}));

vi.mock("./components/useFinance", () => ({
  useFinance: () => {
    const [loading, setLoading] = React.useState(false);
    const reload = async () => {
      setLoading(true);
      await new Promise<void>((resolve) => {
        mocks.resolveReload = resolve;
      });
      setLoading(false);
    };

    return {
      ownerId: "u",
      workspace: { id: "w", name: "Pessoal" },
      accounts: [
        {
          id: "a",
          name: "Principal",
          type: "checking",
          initial_balance: 0,
        },
      ],
      categories: [],
      cards: [],
      transactions: [],
      todayTransactions: [],
      alertPrefs: null,
      goals: [],
      cashPosition: { balanceCents: 0, accountBalancesCents: {} },
      spendingPower: {
        availableCents: 0,
        nextIncomeDate: null,
        reservedCommitmentsCents: 0,
        reservedExpenseCents: 0,
      },
      defaultCashAccountId: "a",
      loading,
      reload,
    };
  },
}));

vi.mock("./components/Nav", () => ({ Nav: () => null }));
vi.mock("./components/List", () => ({ List: () => null }));
vi.mock("./brand-logo", () => ({ BrandLogo: () => null }));
vi.mock("./components/TodayPanel", () => ({ TodayPanel: () => null }));
vi.mock("./components/SpendingPowerCard", () => ({
  SpendingPowerCard: () => null,
}));

beforeEach(() => {
  mocks.resolveReload = undefined;
  mocks.insert.mockReset().mockResolvedValue({ error: null });
  mocks.from.mockReset().mockReturnValue({ insert: mocks.insert });
  vi.stubGlobal("crypto", {
    randomUUID: vi.fn(() => "00000000-0000-4000-8000-000000000001"),
  });
});

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
});

describe("DashboardPage quick transaction integration", () => {
  it("keeps success feedback visible after reload unmounts the form", async () => {
    render(<DashboardPage />);
    fireEvent.change(screen.getByLabelText("Valor"), {
      target: { value: "12,50" },
    });
    fireEvent.change(screen.getByLabelText("Descrição"), {
      target: { value: "Café" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    await waitFor(() => expect(mocks.insert).toHaveBeenCalledTimes(1));
    expect(await screen.findByText("Carregando...")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Registrar" })).toBeNull();

    act(() => mocks.resolveReload?.());

    expect((await screen.findByRole("status")).textContent).toContain(
      "Movimentação registrada",
    );
    expect(screen.getByRole("button", { name: "Registrar" })).toBeTruthy();
  });
});
