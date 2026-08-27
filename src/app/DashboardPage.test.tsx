// @vitest-environment jsdom
import React from "react";
import {
  cleanup,
  render,
  screen,
} from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { DashboardPage } from "./DashboardPage";
import { MonthProvider } from "./components/MonthContext";

const renderDashboard = () => render(<MonthProvider><DashboardPage /></MonthProvider>);

vi.mock("./components/Dialog", () => ({
  Dialog: ({ children, open }: { children: React.ReactNode; open: boolean }) => open ? <div data-testid="dialog">{children}</div> : null
}));

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  insert: vi.fn(),
  resolveReload: undefined as (() => void) | undefined,
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    from: mocks.from,
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { user_metadata: { name: "Bruno" } } } }),
    },
  }),
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
vi.mock("./components/DashboardChart", () => ({ DashboardChart: () => null }));
vi.mock("./components/List", () => ({ List: () => null }));
vi.mock("./brand-logo", () => ({ BrandLogo: () => null }));
vi.mock("./components/TodayPanel", () => ({ TodayPanel: () => null }));
vi.mock("./components/SpendingPowerCard", () => ({
  SpendingPowerCard: () => null,
}));

beforeEach(() => {
  mocks.resolveReload = undefined;
  mocks.insert.mockReset().mockResolvedValue({ error: null });
  const chain = {
    select: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    insert: mocks.insert,
    then: (resolve: (val: unknown) => unknown) => resolve({ data: [] }),
  };
  mocks.from.mockReset().mockReturnValue(chain);
  vi.stubGlobal("crypto", {
    randomUUID: vi.fn(() => "00000000-0000-4000-8000-000000000001"),
  });
});

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
});

describe("DashboardPage integration", () => {
  it("renders dashboard header, metrics, and interest radar", async () => {
    renderDashboard();

    expect(screen.getByText(/Aqui está o resumo das suas finanças/i)).toBeDefined();
    expect(screen.getByText("Patrimônio líquido")).toBeDefined();
    expect(screen.getByText("Receitas")).toBeDefined();
    expect(screen.getByText("Despesas")).toBeDefined();
    expect(screen.getByText("Radar de Juros & Custos Ocultos")).toBeDefined();
  });
});
