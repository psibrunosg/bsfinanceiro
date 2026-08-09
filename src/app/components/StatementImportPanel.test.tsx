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
  transactionSelect: vi.fn(),
  transactionWorkspaceFilter: vi.fn(),
  transactionAccountFilter: vi.fn(),
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

function renderPanel({
  batches = [],
  onReload = vi.fn().mockResolvedValue(undefined),
  onMessage = vi.fn(),
}: {
  batches?: TransactionImportBatch[];
  onReload?: () => Promise<void>;
  onMessage?: (message: string, kind?: "success" | "error") => void;
} = {}) {
  return render(
    <StatementImportPanel
      workspaceId="workspace-1"
      ownerId="owner-1"
      accounts={accounts}
      batches={batches}
      onReload={onReload}
      onMessage={onMessage}
    />,
  );
}

beforeEach(() => {
  mocks.batchInsert.mockReset().mockReturnValue({
    select: () => ({ single: () => Promise.resolve({ data: { id: "batch-new" }, error: null }) }),
  });
  mocks.itemInsert.mockReset().mockResolvedValue({ error: null });
  mocks.rpc.mockReset().mockResolvedValue({ error: null });
  mocks.transactionAccountFilter.mockReset().mockResolvedValue({ data: [], error: null });
  mocks.transactionWorkspaceFilter.mockReset().mockReturnValue({ eq: mocks.transactionAccountFilter });
  mocks.transactionSelect.mockReset().mockReturnValue({ eq: mocks.transactionWorkspaceFilter });
  mocks.from.mockReset().mockImplementation((table: string) => {
    if (table === "transaction_import_batches") return { insert: mocks.batchInsert };
    if (table === "transaction_import_items") return { insert: mocks.itemInsert };
    if (table === "transactions") return { select: mocks.transactionSelect };
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
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
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
    expect(mocks.itemInsert).toHaveBeenCalledTimes(1);
    expect(mocks.itemInsert.mock.calls[0][0]).toEqual([
      expect.objectContaining({
        batch_id: "batch-new", owner_id: "owner-1", row_number: 2,
        fingerprint: "2026-07-29|100000|income|salario", status: "ready", reason: null,
      }),
      expect.objectContaining({
        batch_id: "batch-new", owner_id: "owner-1", row_number: 3,
        fingerprint: "2026-07-29|100000|income|salario", status: "ready", reason: null,
      }),
      expect.objectContaining({ batch_id: "batch-new", row_number: 4, status: "invalid", reason: "invalid_amount" }),
    ]);
  });

  it("confirms only pending batches with ready items through the protected RPC", async () => {
    renderPanel({ batches: [pendingBatch] });

    fireEvent.click(screen.getByRole("button", { name: "Confirmar anterior.csv" }));

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith(
      "apply_transaction_import_batch",
      { p_batch_id: "batch-pending" },
    ));
  });

  it("maps unrecognized headers and persists existing-history duplicates for review", async () => {
    mocks.transactionAccountFilter.mockResolvedValueOnce({
      data: [{ competence_date: "2026-07-29", description: "Salário", amount: 1000, type: "income" }],
      error: null,
    });
    renderPanel();
    const csv = "quando,detalhe,total\n2026-07-29,Salário,1000";
    const file = new File([csv], "mapeado.csv", { type: "text/csv" });
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue(csv) });
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await screen.findByText("Mapeie as colunas do CSV");
    fireEvent.change(screen.getByLabelText("Coluna da data"), { target: { value: "quando" } });
    fireEvent.change(screen.getByLabelText("Coluna da descrição"), { target: { value: "detalhe" } });
    fireEvent.change(screen.getByLabelText("Coluna do valor"), { target: { value: "total" } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await screen.findByText("Duplicada no histórico");
    expect(mocks.itemInsert.mock.calls[0][0]).toEqual([
      expect.objectContaining({ row_number: 2, status: "duplicate", reason: "duplicate_existing" }),
    ]);
    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar importação" }).disabled).toBe(true);
  });

  it("discards a pending batch through the protected RPC", async () => {
    renderPanel({ batches: [pendingBatch] });

    fireEvent.click(screen.getByRole("button", { name: "Descartar anterior.csv" }));

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith(
      "discard_transaction_import_batch",
      { p_batch_id: "batch-pending" },
    ));
  });

  it("compensates a created batch when item persistence fails", async () => {
    const onMessage = vi.fn();
    mocks.itemInsert.mockResolvedValueOnce({ error: new Error("item_insert_failed") });
    renderPanel({ onMessage });
    const file = new File(["data,descricao,valor\n29/07/2026,Salário,1000"], "falha.csv", { type: "text/csv" });
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue("data,descricao,valor\n29/07/2026,Salário,1000") });
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith(
      "discard_transaction_import_batch",
      { p_batch_id: "batch-new" },
    ));
    expect(onMessage).toHaveBeenCalledWith("Não foi possível preparar a prévia do CSV.", "error");
    expect(screen.queryByText("Prévia de falha.csv")).toBeNull();
  });

  it("limits the preview table to fifty rows", async () => {
    const csv = ["data,descricao,valor", ...Array.from({ length: 51 }, (_, index) => `29/07/2026,Linha ${index + 1},1`)].join("\n");
    renderPanel();
    const file = new File([csv], "longo.csv", { type: "text/csv" });
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue(csv) });
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await screen.findByText("Prévia de longo.csv");
    expect(screen.getAllByRole("row")).toHaveLength(51);
    expect(screen.getByText("Linhas da prévia; mostrando as primeiras 50.")).toBeTruthy();
  });

  it("disables confirmation with no ready item and while confirmation is pending", () => {
    const invalidBatch: TransactionImportBatch = { ...pendingBatch, transaction_import_items: [{ ...pendingBatch.transaction_import_items[0], status: "invalid", reason: "invalid_amount" }] };
    renderPanel({ batches: [invalidBatch] });
    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar anterior.csv" }).disabled).toBe(true);
    cleanup();

    mocks.rpc.mockReturnValueOnce(new Promise(() => undefined));
    renderPanel({ batches: [pendingBatch] });
    fireEvent.click(screen.getByRole("button", { name: "Revisar anterior.csv" }));
    fireEvent.click(screen.getByRole("button", { name: "Confirmar importação" }));
    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar anterior.csv" }).disabled).toBe(true);
    expect(screen.getByRole("button", { name: "Processando..." })).toBeTruthy();
  });

  it("opens an inbox preview and preserves success when reload fails", async () => {
    const onMessage = vi.fn();
    const onReload = vi.fn().mockRejectedValue(new Error("reload_failed"));
    renderPanel({ batches: [pendingBatch], onReload, onMessage });
    fireEvent.click(screen.getByRole("button", { name: "Revisar anterior.csv" }));
    expect(screen.getByText("Prévia de anterior.csv")).toBeTruthy();
    fireEvent.click(screen.getAllByRole("button", { name: "Confirmar anterior.csv" })[0]);

    await screen.findByRole("alert");
    expect(screen.getByRole("alert").textContent).toContain("A ação foi concluída");
    expect(onMessage).toHaveBeenCalledWith("Importação anterior.csv confirmada.");
    fireEvent.click(screen.getByRole("button", { name: "Tentar atualizar" }));
    expect(onReload).toHaveBeenCalledTimes(2);
  });
});
