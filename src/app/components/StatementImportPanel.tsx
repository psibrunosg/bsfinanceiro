"use client";

import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import {
  parseStatementCsv,
  type StatementCsvInvalidItem,
  type StatementCsvPreview,
  type StatementCsvValidItem,
} from "@/lib/finance/statement-csv";
import { money } from "./Money";
import type { Account, TransactionImportBatch, TransactionImportItem } from "./types";

type StatementImportPanelProps = {
  workspaceId: string;
  ownerId: string | null;
  accounts: Account[];
  batches: TransactionImportBatch[];
  onReload: () => Promise<void>;
  onMessage: (message: string) => void;
};

type ClassifiedValidItem = StatementCsvValidItem & { duplicate?: true; reason?: string };
type PreviewItem = ClassifiedValidItem | StatementCsvInvalidItem;
type PreviewBatch = { id: string; fileName: string; status: "pending"; items: PreviewItem[] };

const CASH_ACCOUNT_TYPES = new Set(["checking", "cash", "savings"]);

export function StatementImportPanel({
  workspaceId,
  ownerId,
  accounts,
  batches,
  onReload,
  onMessage,
}: StatementImportPanelProps) {
  const supabase = useMemo(() => createClient(), []);
  const [accountId, setAccountId] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<PreviewBatch | null>(null);
  const [selectedBatchId, setSelectedBatchId] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<string | null>(null);
  const [reloadFailed, setReloadFailed] = useState(false);
  const cashAccounts = accounts.filter((account) => CASH_ACCOUNT_TYPES.has(account.type));
  const selectedInboxBatch = batches.find((batch) => batch.id === selectedBatchId) ?? null;
  const previewItems = preview?.items ?? selectedInboxBatch?.transaction_import_items ?? [];
  const previewTitle = preview ? `Prévia de ${preview.fileName}` : selectedInboxBatch ? `Prévia de ${selectedInboxBatch.file_name}` : null;

  async function preparePreview(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!file || !accountId || !ownerId || pendingAction) return;

    let batchId: string | null = null;
    setPendingAction("preparing");
    try {
      const parsed = parseStatementCsv(await file.text());
      const classified = classifyPreview(parsed);
      const { data: batch, error: batchError } = await supabase
        .from("transaction_import_batches")
        .insert({ workspace_id: workspaceId, owner_id: ownerId, account_id: accountId, file_name: file.name })
        .select("id")
        .single();
      if (batchError || !batch) throw batchError ?? new Error("batch_creation_failed");
      batchId = batch.id;

      const { error: itemError } = await supabase.from("transaction_import_items").insert(
        classified.items.map((item) => toImportItem(item, batch.id, workspaceId, ownerId)),
      );
      if (itemError) throw itemError;

      setPreview({ id: batch.id, fileName: file.name, status: "pending", items: classified.items });
      setSelectedBatchId(null);
      await reloadAfterSuccess("Prévia criada. A confirmação ainda será revalidada pelo banco.");
    } catch {
      const cleaned = batchId ? await discardFailedBatch(batchId) : true;
      onMessage(cleaned
        ? "Não foi possível preparar a prévia do CSV."
        : "Não foi possível preparar a prévia do CSV e limpar o lote pendente.");
    } finally {
      setPendingAction(null);
    }
  }

  async function actOnBatch(batch: { id: string; fileName: string }, action: "apply" | "discard") {
    if (pendingAction) return;
    setPendingAction(`${action}:${batch.id}`);
    const rpc = action === "apply" ? "apply_transaction_import_batch" : "discard_transaction_import_batch";
    try {
      const { error } = await supabase.rpc(rpc, { p_batch_id: batch.id });
      if (error) throw error;
      setPreview(null);
      setSelectedBatchId(null);
      await reloadAfterSuccess(action === "apply" ? `Importação ${batch.fileName} confirmada.` : `Importação ${batch.fileName} descartada.`);
    } catch {
      onMessage(action === "apply" ? "Não foi possível confirmar a importação." : "Não foi possível descartar a importação.");
    } finally {
      setPendingAction(null);
    }
  }

  async function discardFailedBatch(batchId: string) {
    try {
      const { error } = await supabase.rpc("discard_transaction_import_batch", { p_batch_id: batchId });
      return !error;
    } catch {
      return false;
    }
  }

  async function reloadAfterSuccess(successMessage: string) {
    onMessage(successMessage);
    try {
      await onReload();
      setReloadFailed(false);
    } catch {
      setReloadFailed(true);
    }
  }

  return <section className="statement-import-panel" aria-labelledby="statement-import-title">
    <div>
      <h2 id="statement-import-title">Importar extrato CSV</h2>
      <p className="muted">Escolha uma conta de caixa e revise as linhas antes de confirmar.</p>
    </div>
    <form className="statement-import-form" onSubmit={preparePreview}>
      <div className="statement-import-field">
        <label htmlFor="statement-import-account">Conta do extrato</label>
        <select id="statement-import-account" value={accountId} onChange={(event) => setAccountId(event.target.value)} required>
          <option value="">Selecione uma conta</option>
          {cashAccounts.map((account) => <option key={account.id} value={account.id}>{account.name}</option>)}
        </select>
      </div>
      <div className="statement-import-field">
        <label htmlFor="statement-import-file">Arquivo CSV</label>
        <input id="statement-import-file" type="file" accept=".csv,text/csv" onChange={(event) => setFile(event.target.files?.[0] ?? null)} required />
      </div>
      <button disabled={!file || !accountId || !ownerId || pendingAction === "preparing"}>
        {pendingAction === "preparing" ? "Preparando prévia..." : "Preparar prévia"}
      </button>
    </form>
    {reloadFailed ? <p className="form-error" role="alert">A ação foi concluída, mas a tela não foi atualizada. <button type="button" onClick={() => void reloadAfterSuccess("Atualização solicitada.")}>Tentar atualizar</button></p> : null}
    {previewTitle ? <ImportPreview
      title={previewTitle}
      items={previewItems}
      onConfirm={preview?.status === "pending" || selectedInboxBatch?.status === "pending"
        ? () => actOnBatch({ id: preview?.id ?? selectedInboxBatch!.id, fileName: preview?.fileName ?? selectedInboxBatch!.file_name }, "apply")
        : undefined}
      onDiscard={preview?.status === "pending" || selectedInboxBatch?.status === "pending"
        ? () => actOnBatch({ id: preview?.id ?? selectedInboxBatch!.id, fileName: preview?.fileName ?? selectedInboxBatch!.file_name }, "discard")
        : undefined}
      busy={pendingAction !== null}
    /> : null}
    <ImportInbox
      batches={batches}
      selectedBatchId={selectedBatchId}
      busy={pendingAction !== null}
      onReview={(batch) => { setPreview(null); setSelectedBatchId(batch.id); }}
      onConfirm={(batch) => actOnBatch({ id: batch.id, fileName: batch.file_name }, "apply")}
      onDiscard={(batch) => actOnBatch({ id: batch.id, fileName: batch.file_name }, "discard")}
    />
  </section>;
}

function ImportInbox({ batches, selectedBatchId, busy, onReview, onConfirm, onDiscard }: {
  batches: TransactionImportBatch[]; selectedBatchId: string | null; busy: boolean;
  onReview: (batch: TransactionImportBatch) => void; onConfirm: (batch: TransactionImportBatch) => void; onDiscard: (batch: TransactionImportBatch) => void;
}) {
  return <section className="statement-import-inbox" aria-labelledby="statement-import-inbox-title">
    <h3 id="statement-import-inbox-title">Importações recentes</h3>
    {batches.length === 0 ? <p className="muted" role="status">Nenhuma importação para revisar.</p> : <ul className="statement-import-batches">
      {batches.map((batch) => {
        const summary = summarize(batch.transaction_import_items);
        const canConfirm = batch.status === "pending" && summary.ready > 0;
        return <li key={batch.id} className={selectedBatchId === batch.id ? "selected" : undefined}>
          <div><strong>{batch.file_name}</strong><span>{batch.status} · {summary.ready} prontas · {summary.duplicate} duplicadas · {summary.invalid} inválidas</span></div>
          <div className="statement-import-actions">
            <button type="button" onClick={() => onReview(batch)}>Revisar {batch.file_name}</button>
            <button type="button" disabled={!canConfirm || busy} onClick={() => onConfirm(batch)}>Confirmar {batch.file_name}</button>
            <button type="button" disabled={batch.status !== "pending" || busy} onClick={() => onDiscard(batch)}>Descartar {batch.file_name}</button>
          </div>
        </li>;
      })}
    </ul>}
  </section>;
}

function ImportPreview({ title, items, onConfirm, onDiscard, busy }: {
  title: string; items: PreviewItem[] | TransactionImportItem[]; onConfirm?: () => void; onDiscard?: () => void; busy: boolean;
}) {
  const summary = summarize(items);
  const canConfirm = summary.ready > 0 && Boolean(onConfirm);
  return <section className="statement-import-preview" aria-labelledby="statement-import-preview-title">
    <div><h3 id="statement-import-preview-title">{title}</h3><p className="statement-import-summary" role="status">{summary.ready} pronta{summary.ready === 1 ? "" : "s"} · {summary.duplicate} duplicada{summary.duplicate === 1 ? "" : "s"} · {summary.invalid} inválida{summary.invalid === 1 ? "" : "s"}</p></div>
    <div className="statement-import-actions">
      {onConfirm ? <button type="button" disabled={!canConfirm || busy} onClick={onConfirm}>{busy ? "Processando..." : "Confirmar importação"}</button> : null}
      {onDiscard ? <button type="button" disabled={busy} onClick={onDiscard}>Descartar</button> : null}
    </div>
    <div className="statement-import-table-wrap">
      <table><caption>Linhas da prévia{items.length > 50 ? "; mostrando as primeiras 50" : ""}.</caption><thead><tr><th>Data</th><th>Descrição</th><th>Valor</th><th>Status</th></tr></thead><tbody>
        {items.slice(0, 50).map((item) => <tr key={getItemKey(item)}><td>{getDate(item)}</td><td>{getDescription(item)}</td><td>{getAmount(item)}</td><td>{getStatusLabel(item)}</td></tr>)}
      </tbody></table>
    </div>
  </section>;
}

function classifyPreview(preview: StatementCsvPreview): { items: PreviewItem[] } {
  const fingerprints = new Set<string>();
  return { items: preview.items.map((item) => {
    if (!("fingerprint" in item)) return item;
    if (fingerprints.has(item.fingerprint)) return { ...item, reason: "duplicate_in_file", duplicate: true };
    fingerprints.add(item.fingerprint);
    return item;
  }) };
}

function toImportItem(item: PreviewItem, batchId: string, workspaceId: string, ownerId: string) {
  if ("fingerprint" in item) {
    return { batch_id: batchId, workspace_id: workspaceId, owner_id: ownerId, row_number: item.rowNumber, competence_date: item.competenceDate, description: item.description, amount_cents: item.amountCents, type: item.type, status: "ready", reason: null, fingerprint: item.fingerprint };
  }
  return { batch_id: batchId, workspace_id: workspaceId, owner_id: ownerId, row_number: item.rowNumber, competence_date: null, description: null, amount_cents: null, type: null, status: "invalid", reason: item.reason, fingerprint: null };
}

function summarize(items: Array<PreviewItem | TransactionImportItem>) {
  return items.reduce((summary, item) => {
    const status = getStatus(item);
    summary[status] += 1;
    return summary;
  }, { ready: 0, duplicate: 0, invalid: 0 });
}

function isPersistedItem(item: PreviewItem | TransactionImportItem): item is TransactionImportItem { return "id" in item; }
function isValidPreviewItem(item: PreviewItem): item is ClassifiedValidItem { return "fingerprint" in item; }
function getItemKey(item: PreviewItem | TransactionImportItem) { return isPersistedItem(item) ? item.id : item.rowNumber; }
function getStatus(item: PreviewItem | TransactionImportItem): "ready" | "duplicate" | "invalid" {
  if (isPersistedItem(item)) return item.status;
  return isValidPreviewItem(item) && item.duplicate ? "duplicate" : isValidPreviewItem(item) ? "ready" : "invalid";
}

function getDate(item: PreviewItem | TransactionImportItem) {
  return isPersistedItem(item) ? item.competence_date ?? "—" : isValidPreviewItem(item) ? item.competenceDate : "—";
}
function getDescription(item: PreviewItem | TransactionImportItem) {
  return isPersistedItem(item) ? item.description ?? "—" : isValidPreviewItem(item) ? item.description : "—";
}
function getAmount(item: PreviewItem | TransactionImportItem) {
  const cents = isPersistedItem(item) ? item.amount_cents : isValidPreviewItem(item) ? item.amountCents : null;
  return cents === null ? "—" : money(cents / 100);
}
function getStatusLabel(item: PreviewItem | TransactionImportItem) {
  const status = getStatus(item);
  if (status === "ready") return "Pronta";
  const reason = isPersistedItem(item) ? item.reason : item.reason;
  if (status === "duplicate") return reason === "duplicate_in_file" ? "Duplicada no arquivo" : "Duplicada";
  return invalidReason(reason);
}

function invalidReason(reason: string | null | undefined) {
  return ({ missing_mapping: "Mapeamento ausente", invalid_date: "Data inválida", missing_description: "Descrição ausente", invalid_amount: "Valor inválido" } as Record<string, string>)[reason ?? ""] ?? "Inválida";
}
