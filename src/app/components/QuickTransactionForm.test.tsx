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
import { apiFetch } from "@/lib/api-client";
import { QuickTransactionForm } from "./QuickTransactionForm";

vi.mock("@/lib/api-client", () => ({
  apiFetch: vi.fn(),
}));

const accounts = [
  { id: "a", name: "Principal", type: "checking", initial_balance: 0, is_shared: false },
  { id: "b", name: "Dinheiro", type: "cash", initial_balance: 0, is_shared: false },
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
  vi.mocked(apiFetch).mockReset().mockResolvedValue(
    new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    }),
  );
});

afterEach(() => {
  cleanup();
  vi.useRealTimers();
});

describe("QuickTransactionForm", () => {
  it("uses the default account and São Paulo today with details closed", async () => {
    const { onSaved } = renderForm();
    fillRequiredFields();

    expect(screen.getByText("Mais detalhes").closest("details")?.open).toBe(
      false,
    );
    fireEvent.click(screen.getByRole("button", { name: "Registrar" }));

    await waitFor(() => expect(apiFetch).toHaveBeenCalledTimes(1));
    const [endpoint, options] = vi.mocked(apiFetch).mock.calls[0];
    expect(endpoint).toBe("/api/transactions");
    expect(options?.method).toBe("POST");
    expect(JSON.parse(String(options?.body))).toEqual({
      workspace_id: "w",
      account_id: "a",
      category_id: "food",
      destination_account_id: null,
      type: "expense",
      amount: 12.5,
      description: "Café",
      competence_date: "2026-07-28",
      status: "paid",
    });
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
    expect(apiFetch).not.toHaveBeenCalled();
    expect(
      screen.getByRole("link", { name: "defina a conta principal" }).getAttribute(
        "href",
      ),
    ).toBe("#definir-conta-principal");
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
      expect(apiFetch).not.toHaveBeenCalled();
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

    await waitFor(() => expect(apiFetch).toHaveBeenCalledTimes(1));
    const [, options] = vi.mocked(apiFetch).mock.calls[0];
    expect(JSON.parse(String(options?.body))).toEqual(
      expect.objectContaining({
        account_id: "b",
        category_id: "salary",
        type: "income",
        amount: 1234.56,
        description: "Salário",
        competence_date: "2026-07-27",
      }),
    );
  });

  it("announces a database error and does not reload", async () => {
    vi.mocked(apiFetch).mockResolvedValueOnce(
      new Response(JSON.stringify({ error: "offline" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }),
    );
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
    let resolveRequest: ((value: Response) => void) | undefined;
    vi.mocked(apiFetch).mockReturnValueOnce(
      new Promise((resolve) => {
        resolveRequest = resolve;
      }),
    );
    renderForm();
    fillRequiredFields();
    const form = screen
      .getByRole("button", { name: "Registrar" })
      .closest("form");

    fireEvent.submit(form!);
    fireEvent.submit(form!);

    expect(apiFetch).toHaveBeenCalledTimes(1);
    expect(
      screen.getByRole<HTMLButtonElement>("button", {
        name: "Registrando...",
      }).disabled,
    ).toBe(true);
    resolveRequest?.(
      new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }),
    );
    await screen.findByText("Movimentação registrada.");
  });
});
