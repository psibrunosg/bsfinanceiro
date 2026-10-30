// @vitest-environment jsdom
import React from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import ExpensesHubPage from "./page";
import { MonthProvider } from "../components/MonthContext";
import { apiFetch } from "@/lib/api-client";

vi.mock("@/lib/api-client", () => ({ apiFetch: vi.fn() }));

vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams(),
}));

const reload = vi.fn().mockResolvedValue(undefined);

vi.mock("../components/useFinance", () => ({
  useFinance: () => ({
    workspace: { id: "workspace-1", name: "Finanças" },
    accounts: [],
    categories: [],
    cards: [],
    invoices: [],
    transactions: [],
    todayTransactions: [],
    budgets: [],
    goals: [],
    monthSpent: {},
    commitments: [],
    occurrences: [],
    contexts: [],
    alertPrefs: null,
    statementImports: [],
    payslips: [],
    loading: false,
    message: "",
    setMessage: vi.fn(),
    reload,
  }),
}));

vi.mock("../components/Nav", () => ({ Nav: () => null }));
vi.mock("../components/PageHeader", () => ({
  PageHeader: ({
    action,
  }: {
    action?: { label: string; onClick: () => void };
  }) =>
    action ? <button onClick={action.onClick}>{action.label}</button> : null,
}));
vi.mock("../components/List", () => ({
  List: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
}));

async function fillRecurrentForm(description: string, amount: string, day: string) {
  fireEvent.click(await screen.findByRole("button", { name: "Recorrentes" }));
  fireEvent.click(await screen.findByRole("button", { name: "Novo compromisso" }));

  const descriptionInput = await screen.findByLabelText("Descrição");
  fireEvent.change(descriptionInput, { target: { value: description } });

  const amountInput = screen.getByLabelText("Valor");
  fireEvent.change(amountInput, { target: { value: amount } });

  fireEvent.change(screen.getByLabelText("Dia do vencimento"), {
    target: { value: day },
  });
  fireEvent.submit(amountInput.closest("form")!);
}

describe("ExpensesHubPage recurrent form", () => {
  beforeEach(() => {
    HTMLDialogElement.prototype.showModal = vi.fn();
    HTMLDialogElement.prototype.close = vi.fn();
    vi.resetAllMocks();
    reload.mockResolvedValue(undefined);
  });

  afterEach(() => cleanup());

  it("does not fall back to a second backend when the VPS request fails", async () => {
    vi.mocked(apiFetch).mockRejectedValue(new Error("API indisponível"));

    render(
      <MonthProvider>
        <ExpensesHubPage />
      </MonthProvider>,
    );

    await fillRecurrentForm("Aluguel", "2500,00", "5");

    await waitFor(() => {
      expect(apiFetch).toHaveBeenCalledWith(
        "/api/commitments",
        expect.objectContaining({ method: "POST" }),
      );
      expect(screen.getByRole("status").textContent).toContain("API indisponível");
    });
    expect(reload).not.toHaveBeenCalled();
  });

  it("submits a new recurrent commitment via the VPS API", async () => {
    vi.mocked(apiFetch).mockResolvedValue({
      ok: true,
      json: async () => ({ success: true, commitment: { id: "c-1" } }),
    } as Response);

    render(
      <MonthProvider>
        <ExpensesHubPage />
      </MonthProvider>,
    );

    await fillRecurrentForm("Internet Fibra", "150,00", "10");

    await waitFor(() => {
      expect(apiFetch).toHaveBeenCalledWith(
        "/api/commitments",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({
            workspace_id: "workspace-1",
            description: "Internet Fibra",
            amount: 150,
            due_day: 10,
            account_id: null,
            category_id: null,
          }),
        }),
      );
      expect(screen.getByRole("status").textContent).toContain(
        "Compromisso criado.",
      );
    });
    expect(reload).toHaveBeenCalledTimes(1);
  });
});
