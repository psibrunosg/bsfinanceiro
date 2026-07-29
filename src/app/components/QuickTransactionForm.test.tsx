// @vitest-environment jsdom
import React from "react";
import {
  cleanup,
  fireEvent,
  render,
  screen,
  waitFor,
} from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { QuickTransactionForm } from "./QuickTransactionForm";

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  insert: vi.fn(),
  randomUUID: vi.fn(),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({ from: mocks.from }),
}));

const accounts = [
  { id: "a", name: "Principal", type: "checking", initial_balance: 0 },
  { id: "b", name: "Dinheiro", type: "cash", initial_balance: 0 },
];

const categories = [
  { id: "food", name: "Alimentação", kind: "expense" },
  { id: "salary", name: "Salário", kind: "income" },
];

function renderForm(
  overrides: Partial<React.ComponentProps<typeof QuickTransactionForm>> = {},
) {
  const onSaved = vi.fn().mockResolvedValue(undefined);
  render(
    <QuickTransactionForm
      workspaceId="w"
      ownerId="u"
      defaultCashAccountId="a"
      accounts={accounts}
      categories={categories}
      onSubmitStart={vi.fn()}
      onSaved={onSaved}
      {...overrides}
    />,
  );
  return { onSaved };
}

function fillRequiredFields(amount = "12,50", description = "Café") {
  fireEvent.change(screen.getByLabelText("Valor"), {
    target: { value: amount },
  });
  fireEvent.change(screen.getByLabelText("Descrição"), {
    target: { value: description },
  });
}

beforeEach(() => {
  vi.useFakeTimers({ shouldAdvanceTime: true });
  vi.setSystemTime(new Date("2026-07-28T12:00:00Z"));
  mocks.insert.mockReset().mockResolvedValue({ error: null });
  mocks.from.mockReset().mockReturnValue({ insert: mocks.insert });
  mocks.randomUUID
    .mockReset()
    .mockReturnValue("00000000-0000-4000-8000-000000000001");
  vi.stubGlobal("crypto", { randomUUID: mocks.randomUUID });
});

afterEach(() => {
  cleanup();
  vi.useRealTimers();
  vi.unstubAllGlobals();
});

describe("QuickTransactionForm", () => {
  it("uses the default account and São Paulo today with details closed", async () => {
    const { onSaved } = renderForm();
    fillRequiredFields();

    expect(screen.getByText("Mais detalhes").closest("details")?.open).toBe(
      false,
    );
    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    await waitFor(() =>
      expect(mocks.insert).toHaveBeenCalledWith({
        workspace_id: "w",
        owner_id: "u",
        account_id: "a",
        category_id: null,
        destination_account_id: null,
        type: "expense",
        amount: 12.5,
        description: "Café",
        competence_date: "2026-07-28",
        paid_at: "2026-07-28",
        status: "paid",
        idempotency_key: "00000000-0000-4000-8000-000000000001",
      }),
    );
    expect(mocks.from).toHaveBeenCalledWith("transactions");
    expect(mocks.randomUUID).toHaveBeenCalledTimes(1);
    expect(onSaved).toHaveBeenCalledTimes(1);
  });

  it("requires an account when there is no default", async () => {
    renderForm({
      defaultCashAccountId: null,
      accounts: [],
      categories: [],
    });

    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    expect((await screen.findByRole("alert")).textContent).toContain(
      "Escolha uma conta",
    );
    const accountSelect =
      screen.getByLabelText<HTMLSelectElement>("Conta");
    const accountError = screen.getByRole("alert");
    expect(screen.getByText("Mais detalhes").closest("details")?.open).toBe(
      true,
    );
    expect(document.activeElement).toBe(accountSelect);
    expect(accountSelect.getAttribute("aria-invalid")).toBe("true");
    expect(accountSelect.getAttribute("aria-describedby")).toBe(
      accountError.id,
    );
    expect(mocks.insert).not.toHaveBeenCalled();
  });

  it.each([
    ["0", "Café", "Informe um valor maior que zero"],
    ["12,50", "   ", "Informe uma descrição"],
  ])(
    "validates amount and description before inserting",
    async (amount, description, expectedMessage) => {
      renderForm();
      fillRequiredFields(amount, description);

      fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

      expect((await screen.findByRole("alert")).textContent).toContain(
        expectedMessage,
      );
      expect(mocks.insert).not.toHaveBeenCalled();
    },
  );

  it("uses the expanded account, category, date and income selection", async () => {
    renderForm();
    fillRequiredFields("1.234,56", " Salário ");

    fireEvent.click(screen.getByText("Mais detalhes"));
    expect(screen.getByText("Mais detalhes").closest("details")?.open).toBe(
      true,
    );
    fireEvent.click(screen.getByLabelText("Receita"));
    fireEvent.change(screen.getByLabelText("Conta"), {
      target: { value: "b" },
    });
    fireEvent.change(screen.getByLabelText("Categoria"), {
      target: { value: "salary" },
    });
    fireEvent.change(screen.getByLabelText("Data"), {
      target: { value: "2026-07-27" },
    });
    expect(screen.queryByText("Pago hoje")).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    await waitFor(() =>
      expect(mocks.insert).toHaveBeenCalledWith(
        expect.objectContaining({
          account_id: "b",
          category_id: "salary",
          type: "income",
          amount: 1234.56,
          description: "Salário",
          competence_date: "2026-07-27",
          paid_at: "2026-07-27",
        }),
      ),
    );
  });

  it("announces a database error and does not reload", async () => {
    mocks.insert.mockResolvedValueOnce({ error: { message: "offline" } });
    const { onSaved } = renderForm();
    fillRequiredFields();

    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    expect((await screen.findByRole("alert")).textContent).toContain(
      "Não foi possível registrar",
    );
    expect(onSaved).not.toHaveBeenCalled();
  });

  it("announces success, reloads and clears the compact fields", async () => {
    const { onSaved } = renderForm();
    fillRequiredFields();

    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    expect((await screen.findByRole("status")).textContent).toContain(
      "Movimentação registrada",
    );
    expect(onSaved).toHaveBeenCalledTimes(1);
    expect(screen.getByLabelText<HTMLInputElement>("Valor").value).toBe("");
    expect(screen.getByLabelText<HTMLInputElement>("Descrição").value).toBe("");
  });

  it("does not insert twice while the first submission is pending", async () => {
    let resolveInsert: ((value: { error: null }) => void) | undefined;
    mocks.insert.mockReturnValueOnce(
      new Promise((resolve) => {
        resolveInsert = resolve;
      }),
    );
    renderForm();
    fillRequiredFields();
    const form = screen
      .getByRole("button", { name: "Registrar" })
      .closest("form");

    fireEvent.submit(form!);
    fireEvent.submit(form!);

    expect(mocks.insert).toHaveBeenCalledTimes(1);
    expect(
      screen.getByRole<HTMLButtonElement>("button", {
        name: "Registrando...",
      }).disabled,
    ).toBe(true);
    resolveInsert?.({ error: null });
    await screen.findByText("Movimentação registrada.");
  });
});
