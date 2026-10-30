// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { apiFetch } from "@/lib/api-client";
import { StatementImportPanel } from "./StatementImportPanel";
import type { Transaction, TransactionImportBatch } from "./types";

vi.mock("@/lib/api-client", () => ({
  apiFetch: vi.fn(),
}));

const accounts = [
  { id: "account-1", name: "Conta corrente", type: "checking", initial_balance: 0, is_shared: false },
  { id: "card-1", name: "Cartão", type: "credit_card", initial_balance: 0, is_shared: false },
];

const pendingBatch: TransactionImportBatch = {
  id: "batch-pending",
  account_id: "account-1",
  file_name: "anterior.csv",
  status: "pending",
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
      type: "income",
      status: "ready",
      reason: null,
      category_id: null,
      fingerprint: "2026-07-29|100000|income|salario",
      transaction_id: null,
      created_at: "2026-07-29T12:00:00Z",
    },
  ],
};

function ok(body: unknown = { success: true }) {
  return new Response(JSON.stringify(body), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

function renderPanel({
  batches = [],
  historyTransactions = [],
  onReload = vi.fn().mockResolvedValue(undefined),
  onMessage = vi.fn(),
}: {
  batches?: TransactionImportBatch[];
  historyTransactions?: Transaction[];
  onReload?: () => Promise<void>;
  onMessage?: (message: string) => void;
} = {}) {
  return render(
    <StatementImportPanel
      workspaceId="workspace-1"
      ownerId="owner-1"
      accounts={accounts}
      categories={[]}
      categoryRules={[]}
      historyTransactions={historyTransactions}
      batches={batches}
      onReload={onReload}
      onMessage={onMessage}
    />,
  );
}

beforeEach(() => {
  vi.mocked(apiFetch).mockReset().mockImplementation(async (input) => {
    const url = String(input);
    if (url === "/api/imports/preview") {
      return ok({ success: true, batch: { id: "batch-new" } });
    }
    return ok({ success: true });
  });
});

afterEach(() => cleanup());

describe("StatementImportPanel", () => {
  it("prepara CSV pela API VPS e mantém o resumo da prévia", async () => {
    renderPanel();
    const csv = "data,descricao,valor\n29/07/2026,Salário,1000\n29/07/2026,Salário,1000\n30/07/2026,Sem valor,0";
    const file = new File([csv], "extrato.csv", { type: "text/csv" });
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue(csv) });

    expect(screen.queryByRole("option", { name: "Cartão" })).toBeNull();
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await waitFor(() => expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 pronta"));
    expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 duplicada");
    expect(document.querySelector(".statement-import-summary")?.textContent).toContain("1 inválida");

    const [endpoint, options] = vi.mocked(apiFetch).mock.calls[0];
    expect(endpoint).toBe("/api/imports/preview");
    const body = JSON.parse(String(options?.body));
    expect(body.workspace_id).toBe("workspace-1");
    expect(body.account_id).toBe("account-1");
    expect(body.file_name).toBe("extrato.csv");
    expect(body.items).toEqual([
      expect.objectContaining({ row_number: 2, status: "ready" }),
      expect.objectContaining({ row_number: 3, status: "ready" }),
      expect.objectContaining({ row_number: 4, status: "invalid", reason: "invalid_amount" }),
    ]);
  });

  it("confirma lote pendente pelo endpoint apply", async () => {
    renderPanel({ batches: [pendingBatch] });
    fireEvent.click(screen.getByRole("button", { name: "Confirmar anterior.csv" }));
    await waitFor(() =>
      expect(apiFetch).toHaveBeenCalledWith("/api/imports/batch-pending/apply", { method: "POST" }),
    );
  });

  it("mapeia cabeçalhos e classifica duplicata já existente no histórico", async () => {
    const historyTransactions = [
      {
        id: "tx-1",
        account_id: "account-1",
        destination_account_id: null,
        invoice_id: null,
        type: "income",
        status: "paid",
        description: "Salário",
        amount: 1000,
        interest_amount: 0,
        competence_date: "2026-07-29",
        due_date: null,
        installment_current: null,
        installment_total: null,
        category_id: null,
        context_id: null,
        paid_at: "2026-07-29",
      } as Transaction,
    ];
    renderPanel({ historyTransactions });
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
    const [, options] = vi.mocked(apiFetch).mock.calls.find(([url]) => url === "/api/imports/preview")!;
    const body = JSON.parse(String(options?.body));
    expect(body.items).toEqual([
      expect.objectContaining({ row_number: 2, status: "duplicate", reason: "duplicate_existing" }),
    ]);
    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar importação" }).disabled).toBe(true);
  });

  it("descarta lote pendente pelo endpoint discard", async () => {
    renderPanel({ batches: [pendingBatch] });
    fireEvent.click(screen.getByRole("button", { name: "Descartar anterior.csv" }));
    await waitFor(() =>
      expect(apiFetch).toHaveBeenCalledWith("/api/imports/batch-pending/discard", { method: "POST" }),
    );
  });

  it("exibe erro quando a criação da prévia falha", async () => {
    const onMessage = vi.fn();
    vi.mocked(apiFetch).mockResolvedValueOnce(
      new Response(JSON.stringify({ success: false, error: "falha" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }),
    );
    renderPanel({ onMessage });
    const csv = "data,descricao,valor\n29/07/2026,Salário,1000";
    const file = new File([csv], "falha.csv", { type: "text/csv" });
    Object.defineProperty(file, "text", { value: vi.fn().mockResolvedValue(csv) });
    fireEvent.change(screen.getByLabelText("Conta do extrato"), { target: { value: "account-1" } });
    fireEvent.change(screen.getByLabelText("Arquivo CSV ou OFX"), { target: { files: [file] } });
    fireEvent.submit(screen.getByRole("button", { name: "Preparar prévia" }).closest("form")!);

    await waitFor(() => expect(onMessage).toHaveBeenCalledWith("Não foi possível preparar a prévia do CSV."));
    expect(screen.queryByText("Prévia de falha.csv")).toBeNull();
  });

  it("limita a tabela de prévia a cinquenta linhas", async () => {
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

  it("desabilita confirmação sem item pronto e durante requisição pendente", () => {
    const invalidBatch: TransactionImportBatch = {
      ...pendingBatch,
      transaction_import_items: [
        { ...pendingBatch.transaction_import_items[0], status: "invalid", reason: "invalid_amount" },
      ],
    };
    renderPanel({ batches: [invalidBatch] });
    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar anterior.csv" }).disabled).toBe(true);
    cleanup();

    vi.mocked(apiFetch).mockReturnValueOnce(new Promise(() => undefined));
    renderPanel({ batches: [pendingBatch] });
    fireEvent.click(screen.getByRole("button", { name: "Revisar anterior.csv" }));
    fireEvent.click(screen.getByRole("button", { name: "Confirmar importação" }));

    expect(screen.getByRole<HTMLButtonElement>("button", { name: "Confirmar anterior.csv" }).disabled).toBe(true);
    expect(screen.getByRole("button", { name: "Processando..." })).toBeTruthy();
  });

  it("preserva sucesso quando o reload falha", async () => {
    const onMessage = vi.fn();
    const onReload = vi.fn().mockRejectedValue(new Error("reload_failed"));
    renderPanel({ batches: [pendingBatch], onReload, onMessage });
    fireEvent.click(screen.getByRole("button", { name: "Revisar anterior.csv" }));
    fireEvent.click(screen.getAllByRole("button", { name: "Confirmar anterior.csv" })[0]);

    await screen.findByRole("alert");
    expect(screen.getByRole("alert").textContent).toContain("A ação foi concluída");
    expect(onMessage).toHaveBeenCalledWith("Importação anterior.csv confirmada.");
    fireEvent.click(screen.getByRole("button", { name: "Tentar atualizar" }));
    expect(onReload).toHaveBeenCalledTimes(2);
  });
});
