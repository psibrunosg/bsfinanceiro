"use client";

import { useMemo, useState } from "react";
import { createClient } from "@/lib/supabase/client";
import {
  parseStatementCsv,
  statementTransactionFingerprint,
  type StatementCsvMapping,
  type StatementCsvInvalidItem,
  type StatementCsvPreview,
  type StatementCsvValidItem,
} from "@/lib/finance/statement-csv";
import { parseOfxStatement } from "@/lib/finance/statement-ofx";
import { money } from "./Money";
import type { Account, TransactionImportBatch, TransactionImportItem, Category, TransactionCategoryRule, Transaction } from "./types";

type StatementImportPanelProps = {
  workspaceId: string;
  ownerId: string | null;
  accounts: Account[];
  categories: Category[];
  categoryRules: TransactionCategoryRule[];
  historyTransactions: Transaction[];
  batches: TransactionImportBatch[];
  onReload: () => Promise<void>;
  onMessage: (message: string) => void;
};

type ClassifiedValidItem = StatementCsvValidItem & { duplicate?: true; duplicateSource?: "existing" | "file"; reason?: string; categoryId?: string };
type PreviewItem = ClassifiedValidItem | StatementCsvInvalidItem;
type PreviewBatch = { id: string; fileName: string; status: "pending"; items: PreviewItem[] };

const CASH_ACCOUNT_TYPES = new Set(["checking", "cash", "savings"]);

export function StatementImportPanel({
  workspaceId,
  ownerId,
  accounts,
  categories,
  categoryRules,
  historyTransactions,
  batches,
  onReload,
  onMessage,
}: StatementImportPanelProps) {
  const supabase = useMemo(() => createClient(), []);
  const [accountId, setAccountId] = useState("");
  const [file, setFile] = useState<File | null>(null);
  const [csvText, setCsvText] = useState<string | null>(null);
  const [headers, setHeaders] = useState<string[]>([]);
  const [mapping, setMapping] = useState<StatementCsvMapping>({});
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
      const text = csvText ?? await file.text();
      const isOfx = file.name.toLowerCase().endsWith(".ofx") || file.name.toLowerCase().endsWith(".qfx");

      let parsed: StatementCsvPreview;
      if (isOfx) {
        const items = parseOfxStatement(text);
        parsed = { headers: [], items, valid: items.length, invalid: 0 };
      } else {
        parsed = parseStatementCsv(text, mapping);
        if (parsed.items.some((item) => "reason" in item && item.reason === "missing_mapping")) {
          setCsvText(text);
          setHeaders(parsed.headers);
          return;
        }
      }
      const existingTransactions = await loadExistingTransactions();
      const classified = classifyPreview(parsed, existingTransactions, historyTransactions, categoryRules);
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

  async function loadExistingTransactions() {
    const { data, error } = await supabase
      .from("transactions")
      .select("competence_date,description,amount,type")
      .eq("workspace_id", workspaceId)
      .eq("account_id", accountId);
    if (error) throw error;
    return data ?? [];
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
      <h2 id="statement-import-title">Importar extrato</h2>
      <p className="muted">Escolha uma conta de caixa e revise as linhas antes de confirmar. Aceita CSV e OFX.</p>
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
        <label htmlFor="statement-import-file">Arquivo CSV ou OFX</label>
        <input id="statement-import-file" type="file" accept=".csv,text/csv,.ofx,.qfx,application/x-ofx" onChange={(event) => {
          setFile(event.target.files?.[0] ?? null);
          setCsvText(null);
          setHeaders([]);
          setMapping({});
        }} required />
      </div>
      <button disabled={!file || !accountId || !ownerId || pendingAction === "preparing"}>
        {pendingAction === "preparing" ? "Preparando prévia..." : "Preparar prévia"}
      </button>
    </form>
    {headers.length > 0 ? <fieldset className="statement-import-mapping">
      <legend>Mapeie as colunas do CSV</legend>
      <p className="muted">Escolha data, descrição e valor para continuar.</p>
      <ColumnMapping label="Coluna da data" value={mapping.date ?? ""} headers={headers} onChange={(value) => setMapping((current) => ({ ...current, date: value || undefined }))} />
      <ColumnMapping label="Coluna da descrição" value={mapping.description ?? ""} headers={headers} onChange={(value) => setMapping((current) => ({ ...current, description: value || undefined }))} />
      <ColumnMapping label="Coluna do valor" value={mapping.amount ?? ""} headers={headers} onChange={(value) => setMapping((current) => ({ ...current, amount: value || undefined }))} />
    </fieldset> : null}
    {reloadFailed ? <p className="form-error" role="alert">A ação foi concluída, mas a tela não foi atualizada. <button type="button" onClick={() => void reloadAfterSuccess("Atualização solicitada.")}>Tentar atualizar</button></p> : null}
    {previewTitle ? <ImportPreview
      title={previewTitle}
      items={previewItems}
      categories={categories}
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

function ColumnMapping({ label, value, headers, onChange }: { label: string; value: string; headers: string[]; onChange: (value: string) => void }) {
  const id = `statement-import-${label.toLocaleLowerCase("pt-BR").replace(/\s+/g, "-")}`;
  return <label htmlFor={id}>{label}<select id={id} value={value} onChange={(event) => onChange(event.target.value)}><option value="">Selecione uma coluna</option>{headers.map((header) => <option key={header} value={header}>{header}</option>)}</select></label>;
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

function ImportPreview({ title, items, categories, onConfirm, onDiscard, busy }: {
  title: string; items: PreviewItem[] | TransactionImportItem[]; categories: Category[]; onConfirm?: () => void; onDiscard?: () => void; busy: boolean;
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
      <table><caption>Linhas da prévia{items.length > 50 ? "; mostrando as primeiras 50" : ""}.</caption><thead><tr><th>Data</th><th>Descrição</th><th>Valor</th><th>Categoria</th><th>Status</th></tr></thead><tbody>
        {items.slice(0, 50).map((item) => {
          const categoryId = "categoryId" in item ? item.categoryId : (item as TransactionImportItem).category_id;
          const categoryName = categories.find(c => c.id === categoryId)?.name ?? "—";
          return <tr key={getItemKey(item)}><td>{getDate(item)}</td><td>{getDescription(item)}</td><td>{getAmount(item)}</td><td>{categoryName}</td><td>{getStatusLabel(item)}</td></tr>
        })}
      </tbody></table>
    </div>
  </section>;
}

function classifyPreview(
  preview: StatementCsvPreview, 
  existingTransactions: Array<{ competence_date: string; description: string; amount: number; type: "income" | "expense" }>,
  historyTransactions: Transaction[],
  categoryRules: TransactionCategoryRule[]
): { items: PreviewItem[] } {
  const fingerprints = new Set<string>();
  const existingFingerprints = new Set(existingTransactions.map((transaction) => statementTransactionFingerprint(
    transaction.competence_date,
    Math.round(Number(transaction.amount) * 100),
    transaction.type,
    transaction.description,
  )));
  
  function suggestCategory(description: string | null): string | undefined {
    if (!description) return undefined;
    const lowerDesc = description.toLowerCase();
    
    for (const rule of categoryRules) {
      if (lowerDesc.includes(rule.pattern.toLowerCase())) return rule.category_id;
    }
    
    const exactMatch = historyTransactions.find(t => t.description?.toLowerCase() === lowerDesc && t.category_id);
    if (exactMatch) return exactMatch.category_id!;
    
    const tokens = lowerDesc.split(/\s+/).filter(t => t.length > 3);
    for (const token of tokens) {
      const tokenMatch = historyTransactions.find(t => t.description?.toLowerCase().includes(token) && t.category_id);
      if (tokenMatch) return tokenMatch.category_id!;
    }
    
    return undefined;
  }

  return { items: preview.items.map((item) => {
    if (!("fingerprint" in item)) return item;
    
    const categoryId = suggestCategory(item.description);
    
    if (existingFingerprints.has(item.fingerprint)) return { ...item, reason: "duplicate_existing", duplicate: true, duplicateSource: "existing", categoryId };
    if (fingerprints.has(item.fingerprint)) return { ...item, reason: "duplicate_file", duplicate: true, duplicateSource: "file", categoryId };
    fingerprints.add(item.fingerprint);
    return { ...item, categoryId };
  }) };
}

function toImportItem(item: PreviewItem, batchId: string, workspaceId: string, ownerId: string) {
  if ("fingerprint" in item) {
    const existingDuplicate = item.duplicateSource === "existing";
    return { batch_id: batchId, workspace_id: workspaceId, owner_id: ownerId, row_number: item.rowNumber, competence_date: item.competenceDate, description: item.description, amount_cents: item.amountCents, type: item.type, status: existingDuplicate ? "duplicate" : "ready", reason: existingDuplicate ? "duplicate_existing" : null, fingerprint: item.fingerprint, category_id: item.categoryId ?? null };
  }
  return { batch_id: batchId, workspace_id: workspaceId, owner_id: ownerId, row_number: item.rowNumber, competence_date: null, description: null, amount_cents: null, type: null, status: "invalid", reason: item.reason, fingerprint: null, category_id: null };
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
  const reason = item.reason;
  if (status === "duplicate") return (reason === "duplicate_file" || reason === "duplicate_in_file") ? "Duplicada no arquivo" : reason === "duplicate_existing" ? "Duplicada no histórico" : "Duplicada";
  return invalidReason(reason);
}

function invalidReason(reason: string | null | undefined) {
  return ({ missing_mapping: "Mapeamento ausente", invalid_date: "Data inválida", missing_description: "Descrição ausente", invalid_description: "Descrição muito longa", invalid_amount: "Valor inválido" } as Record<string, string>)[reason ?? ""] ?? "Inválida";
}
