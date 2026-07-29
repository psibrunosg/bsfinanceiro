// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { StatementImportPanel } from "./StatementImportPanel";
import type { TransactionImportBatch } from "./types";

const mocks = vi.hoisted(() => ({
  from: vi.fn(),
  batchInsert: vi.fn(),
  itemInsert: vi.fn(),
  rpc: vi.fn(),
}));

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({ from: mocks.from, rpc: mocks.rpc }),
}));

const accounts = [
  { id: "account-1", name: "Conta corrente", type: "checking", initial_balance: 0 },
  { id: "card-1", name: "Cartão", type: "credit_card", initial_balance: 0 },
];

const pendingBatch = {
  id: "batch-pending",
  account_id: "account-1",
  file_name: "anterior.csv",
  status: "pending" as const,
  created_at: "2026-07-29T12:00:00Z",
  applied_at: null,
  discarded_at: null,
  transaction_import_items: [
    {
      id: "item-ready",
      batch_id: "batch-pending",
      row_number: 2,
      competence_date: "2026-07-29",
      description: "Salário",
      amount_cents: 100000,
      type: "income" as const,
      status: "ready" as const,
      reason: null,
      fingerprint: "2026-07-29|100000|income|salario",
      transaction_id: null,
      created_at: "2026-07-29T12:00:00Z",
    },
  ],
};

function renderPanel(batches: TransactionImportBatch[] = []) {
  return render(
    <StatementImportPanel
      workspaceId="workspace-1"
      ownerId="owner-1"
      accounts={accounts}
      batches={batches}
      onReload={vi.fn().mockResolvedValue(undefined)}
      onMessage={vi.fn()}
    />,
  );
}

beforeEach(() => {
  mocks.batchInsert.mockReset().mockReturnValue({
    select: () => ({ single: () => Promise.resolve({ data: { id: "batch-new" }, error: null }) }),
  });
  mocks.itemInsert.mockReset().mockResolvedValue({ error: null });
  mocks.rpc.mockReset().mockResolvedValue({ error: null });
  mocks.from.mockReset().mockImplementation((table: string) => {
    if (table === "transaction_import_batches") return { insert: mocks.batchInsert };
    if (table === "transaction_import_items") return { insert: mocks.itemInsert };
    throw new Error(`Unexpected table: ${table}`);
  });
});

afterEach(() => cleanup());

describe("StatementImportPanel", () => {
  it("reads a CSV after the account is selected, persists its preview and explains every status", async () => {
    renderPanel();
    const csv = "data,descricao,valor\n29/07/2026,Salário,1000\n29/07/2026,Salário,1000\n30/07/2026,Sem valor,0";
    const file = new File(
      [csv],
      "extrato.csv",
      { type: "text/csv" },
    );
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue(csv) });

    expect(screen.queryByRole("option", { name: "Cartão" })).toBeNull();
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV"), { target: { files: [file] } });
    const prepare = screen.getByRole<HTMLButtonElement>("button", { name: "Preparar prévia" });
    expect(prepare.disabled).toBe(false);
    fireEvent.submit(prepare.closest("form")!);

    await waitFor(() => expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 pronta"));
    expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 duplicada");
    expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 inválida");
    expect(screen.getByText("Duplicada no arquivo")).toBeTruthy();
    expect(screen.getByText("Valor inválido")).toBeTruthy();
    expect(mocks.batchInsert).toHaveBeenCalledWith({
      workspace_id: "workspace-1",
      owner_id: "owner-1",
      account_id: "account-1",
      file_name: "extrato.csv",
    });
    expect(mocks.itemInsert).toHaveBeenCalledWith(expect.arrayContaining([
      expect.objectContaining({ batch_id: "batch-new", status: "ready", owner_id: "owner-1" }),
      expect.objectContaining({ batch_id: "batch-new", status: "duplicate", reason: "duplicate_in_file" }),
      expect.objectContaining({ batch_id: "batch-new", status: "invalid", reason: "invalid_amount" }),
    ]));
  });

  it("confirms only pending batches with ready items through the protected RPC", async () => {
    renderPanel([pendingBatch]);

    fireEvent.click(screen.getByRole("button", { name: "Confirmar anterior.csv" }));

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith(
      "apply_transaction_import_batch",
      { p_batch_id: "batch-pending" },
    ));
  });

  it("discards a pending batch through the protected RPC", async () => {
    renderPanel([pendingBatch]);

    fireEvent.click(screen.getByRole("button", { name: "Descartar anterior.csv" }));

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith(
      "discard_transaction_import_batch",
      { p_batch_id: "batch-pending" },
    ));
  });
});
