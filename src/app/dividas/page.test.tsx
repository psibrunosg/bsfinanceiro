// @vitest-environment jsdom
import React from "react";
import { render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import DividasPage from "./page";

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    from: vi.fn().mockReturnValue({
      select: vi.fn().mockReturnThis(),
      insert: vi.fn().mockResolvedValue({ error: null }),
    }),
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-1" } } }),
    },
  }),
}));

vi.mock("@/app/components/Nav", () => ({
  Nav: () => <nav data-testid="app-nav">Mock Nav</nav>,
}));

const mockFinance = {
  workspace: { id: "ws-1", name: "Workspace Teste" },
  debts: [
    {
      id: "debt-1",
      workspace_id: "ws-1",
      name: "Empréstimo Carro",
      total_amount: 10000,
      outstanding_balance: 5000,
      monthly_installment: 500,
      interest_rate_percent_monthly: 1.5,
      due_date_day: 10,
    },
  ],
  loading: false,
};

vi.mock("@/app/components/useFinance", () => ({
  useFinance: () => mockFinance,
}));

describe("DividasPage", () => {
  it("renders Nav sidebar and dashboard-shell with page header and debt widgets", () => {
    const { container } = render(<DividasPage />);

    expect(screen.getByTestId("app-nav")).toBeDefined();
    expect(screen.getByText("Dívidas e Parcelamentos")).toBeDefined();
    expect(screen.getByText("Empréstimo Carro")).toBeDefined();
    expect(container.querySelector("main.dashboard-shell")).toBeDefined();
  });
});