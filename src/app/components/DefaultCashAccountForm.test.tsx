// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { DefaultCashAccountForm } from "./DefaultCashAccountForm";

const mocks = vi.hoisted(() => ({
  apiFetch: vi.fn(),
}));

vi.mock("@/lib/api-client", () => ({ apiFetch: mocks.apiFetch }));

const accounts = [
  { id: "checking", name: "Conta corrente", type: "checking", initial_balance: 0, is_shared: false },
  { id: "cash", name: "Carteira", type: "cash", initial_balance: 0, is_shared: false },
  { id: "card", name: "Cartão", type: "credit_card", initial_balance: 0, is_shared: false },
  { id: "investment", name: "Corretora", type: "investment", initial_balance: 0, is_shared: false },
];

beforeEach(() => {
  mocks.apiFetch.mockReset().mockResolvedValue({ ok: true });
});

afterEach(() => cleanup());

describe("DefaultCashAccountForm", () => {
  it("saves the selected active cash account through the VPS", async () => {
    const onSaved = vi.fn().mockResolvedValue(undefined);
    render(
      <DefaultCashAccountForm
        workspaceId="workspace"
        ownerId="owner"
        defaultCashAccountId={null}
        accounts={accounts}
        onSaved={onSaved}
      />,
    );

    const select = screen.getByLabelText<HTMLSelectElement>("Conta principal");
    expect(select.querySelector('option[value="checking"]')).toBeTruthy();
    expect(select.querySelector('option[value="cash"]')).toBeTruthy();
    expect(select.querySelector('option[value="card"]')).toBeNull();
    expect(select.querySelector('option[value="investment"]')).toBeNull();

    fireEvent.change(select, { target: { value: "checking" } });
    fireEvent.click(
      screen.getByRole("button", { name: "Salvar conta principal" }),
    );

    await waitFor(() => expect(mocks.apiFetch).toHaveBeenCalledTimes(1));
    const [url, init] = mocks.apiFetch.mock.calls[0];
    expect(url).toBe("/api/preferences");
    expect(init.method).toBe("POST");
    expect(JSON.parse(init.body)).toEqual({
      workspace_id: "workspace", workspace_preferences: { default_cash_account_id: "checking" },
    });
    expect(onSaved).toHaveBeenCalledTimes(1);
  });

  it("rejects a value that is not an eligible account", async () => {
    render(
      <DefaultCashAccountForm
        workspaceId="workspace"
        ownerId="owner"
        defaultCashAccountId={null}
        accounts={accounts}
        onSaved={vi.fn()}
      />,
    );

    fireEvent.change(screen.getByLabelText("Conta principal"), {
      target: { value: "card" },
    });
    fireEvent.submit(
      screen.getByRole("button", { name: "Salvar conta principal" }).closest("form")!,
    );

    expect((await screen.findByRole("alert")).textContent).toContain(
      "conta de caixa ativa",
    );
    expect(mocks.apiFetch).not.toHaveBeenCalled();
  });
});
