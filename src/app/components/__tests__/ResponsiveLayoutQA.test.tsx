// @vitest-environment jsdom
import React from "react";
import { render } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import { DashboardPage } from "../../DashboardPage";
import { CardsPage } from "../../CardsPage";
import { TransactionsPage } from "../../TransactionsPage";
import { ReportsPage } from "../../ReportsPage";
import { HealthPage } from "../../HealthPage";
import { MonthProvider } from "../MonthContext";

vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams(),
  usePathname: () => "/",
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    from: vi.fn(() => ({
      select: vi.fn().mockReturnThis(),
      order: vi.fn().mockReturnThis(),
      limit: vi.fn().mockReturnThis(),
      insert: vi.fn().mockResolvedValue({ error: null }),
    })),
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { id: "u1", user_metadata: { name: "User" } } } }),
    },
  }),
}));

vi.mock("../useFinance", () => ({
  useFinance: () => ({
    ownerId: "u1",
    workspace: { id: "w1", name: "Pessoal" },
    accounts: [{ id: "a1", name: "Conta 1", type: "checking", initial_balance: 1000 }],
    categories: [{ id: "c1", name: "Alimentação", type: "expense" }],
    categoryRules: [],
    cards: [{ id: "card1", name: "Cartão XPTO", credit_limit: 5000, closing_day: 5, due_day: 15 }],
    transactions: [
      { id: "t1", description: "Mercado", amount: 150, type: "expense", competence_date: "2026-09-01", account_id: "a1", category_id: "c1" },
      { id: "t2", description: "Salário", amount: 5000, type: "income", competence_date: "2026-09-05", account_id: "a1", category_id: "c1" },
    ],
    todayTransactions: [],
    operations: [],
    alertPrefs: null,
    goals: [],
    occurrences: [],
    budgets: [],
    invoices: [],
    monthSpent: {},
    commitments: [],
    statementImports: [],
    transactionImportBatches: [],
    cashPosition: { balanceCents: 100000, accountBalancesCents: {} },
    spendingPower: { availableCents: 50000, nextIncomeDate: null, reservedCommitmentsCents: 0, reservedExpenseCents: 0 },
    defaultCashAccountId: "a1",
    loading: false,
    reload: vi.fn().mockResolvedValue(undefined),
    message: "",
    setMessage: vi.fn(),
  }),
}));

vi.mock("../Nav", () => ({ Nav: () => <nav data-testid="mock-nav" /> }));
vi.mock("../PageHeader", () => ({ PageHeader: ({ title }: { title: string }) => <header><h1>{title}</h1></header> }));
vi.mock("../List", () => ({ List: ({ children }: { children: React.ReactNode }) => <div>{children}</div> }));
vi.mock("../DashboardChart", () => ({ DashboardChart: () => <div data-testid="mock-chart" /> }));
vi.mock("../CommandMenu", () => ({ CommandMenu: () => null }));

describe("ResponsiveLayoutQA - Grid & Apple Glass Tokens across pages", () => {
  it("DashboardPage uses .bento-row--4 for metrics and .bento-row--2 for goals without fragile inline 4-cols", () => {
    const { container } = render(
      <MonthProvider>
        <DashboardPage />
      </MonthProvider>
    );

    const metricGrid = container.querySelector(".bento-row--4");
    expect(metricGrid).toBeTruthy();
    expect(metricGrid?.getAttribute("style") || "").not.toContain("repeat(4, 1fr)");

    const metricCards = container.querySelectorAll(".metric-card");
    expect(metricCards.length).toBeGreaterThanOrEqual(4);

    const goalsGrid = container.querySelector(".bento-row--2");
    expect(goalsGrid).toBeTruthy();
  });

  it("CardsPage uses .bento-row--4 without inline repeat(4, 1fr)", () => {
    const { container } = render(
      <MonthProvider>
        <CardsPage />
      </MonthProvider>
    );

    const metricGrid = container.querySelector(".bento-row--4");
    expect(metricGrid).toBeTruthy();
    expect(metricGrid?.getAttribute("style") || "").not.toContain("repeat(4, 1fr)");
  });

  it("TransactionsPage uses .bento-row--filters for responsive search and filter controls", () => {
    const { container } = render(
      <MonthProvider>
        <TransactionsPage />
      </MonthProvider>
    );

    const filterGrid = container.querySelector(".bento-row--filters");
    expect(filterGrid).toBeTruthy();
    expect(filterGrid?.getAttribute("style") || "").not.toContain("2fr 1fr 1fr 1fr");
  });

  it("ReportsPage uses .bento-row--3 without rigid inline column constraints", () => {
    const { container } = render(
      <MonthProvider>
        <ReportsPage />
      </MonthProvider>
    );

    const bentoRows = container.querySelectorAll(".bento-row--3");
    expect(bentoRows.length).toBeGreaterThanOrEqual(1);
    bentoRows.forEach((row) => {
      expect(row.getAttribute("style") || "").not.toContain("repeat(3, 1fr)");
    });
  });

  it("HealthPage uses .bento-row--3 for status indicators", () => {
    const { container } = render(
      <MonthProvider>
        <HealthPage />
      </MonthProvider>
    );

    const statusGrid = container.querySelector(".bento-row--3");
    expect(statusGrid).toBeTruthy();
    expect(statusGrid?.getAttribute("style") || "").not.toContain("repeat(3, 1fr)");
  });
});
