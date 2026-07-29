// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { DefaultCashAccountForm } from "./DefaultCashAccountForm";

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  upsert: vi.fn(),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({ from: mocks.from }),
}));

const accounts = [
  { id: "checking", name: "Conta corrente", type: "checking", initial_balance: 0 },
  { id: "cash", name: "Carteira", type: "cash", initial_balance: 0 },
  { id: "card", name: "Cartão", type: "credit_card", initial_balance: 0 },
  { id: "investment", name: "Corretora", type: "investment", initial_balance: 0 },
];

beforeEach(() => {
  mocks.upsert.mockReset().mockResolvedValue({ error: null });
  mocks.from.mockReset().mockReturnValue({ upsert: mocks.upsert });
});

afterEach(() => cleanup());

describe("DefaultCashAccountForm", () => {
  it("upserts the selected active cash account for the workspace", async () => {
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

    await waitFor(() =>
      expect(mocks.upsert).toHaveBeenCalledWith(
        {
          workspace_id: "workspace",
          owner_id: "owner",
          default_cash_account_id: "checking",
        },
        { onConflict: "workspace_id,owner_id" },
      ),
    );
    expect(mocks.from).toHaveBeenCalledWith("workspace_preferences");
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
    expect(mocks.upsert).not.toHaveBeenCalled();
  });
});
