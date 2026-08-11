"use client";

import { useSearchParams } from "next/navigation";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { Dialog } from "./components/Dialog";
import { useToast } from "./components/Toast";
import { money, parseMoney, dateFmt } from "./components/Money";
import { BrandLogo, CARD_BRANDS } from "./brand-logo";
import type { Invoice, StatementImport, StatementImportItem } from "./components/types";
import { createClient } from "@/lib/supabase/client";
import { useMemo, Suspense, useState } from "react";
import { ChevronDown, Pencil, Trash2 } from "lucide-react";

/** O Postgres devolve 23503 quando a exclusão esbarra numa chave estrangeira
 *  (ex.: lançamentos apontando para a conta técnica do cartão). */
function isForeignKeyViolation(error: { code?: string; message?: string }) {
  return error.code === "23503" || /foreign key|chave estrangeira/i.test(error.message ?? "");
}

function statementImportErrorMessage(errorCode: string | null) {
  switch (errorCode) {
    case "unsupported_format": return "Formato não suportado; nenhuma compra foi criada.";
    case "checksum_mismatch": return "O arquivo enviado não corresponde ao arquivo validado. Envie-o novamente.";
    case "purchase_creation_failed": return "A compra não pôde ser criada. Tente novamente.";
    case "processing_failed": return "A importação foi interrompida e poderá ser tentada novamente.";
    default: return "Não foi possível enviar a importação.";
  }
}

type StatementReviewDraft = Pick<StatementImportItem, "purchased_on" | "description" | "installment_amount_cents" | "installment_number" | "installment_count" | "total_amount_cents">;

function reviewDraft(item: StatementImportItem, draft?: Partial<StatementReviewDraft>): StatementReviewDraft {
  return { ...item, ...draft };
}

/** Soma das parcelas da fatura — é este o valor que a RPC de pagamento lança. */
function invoiceTotal(invoice: Invoice) {
  return (invoice.credit_card_installments || []).reduce((sum, item) => sum + Number(item.amount), 0);
}

/** Data de hoje como `YYYY-MM-DD` no fuso local, para comparar direto com `due_date`
 *  (comparar strings evita o deslocamento de fuso de `new Date(due_date)`). */
function todayIso() {
  return new Date().toLocaleDateString("en-CA");
}

type InvoiceStatusLabel = { texto: string; variante: "paid" | "pending" | "neutral" };

/** O enum `credit_card_invoice_status` tem cinco valores; tratar tudo que não é
 *  `paid` como "Em aberto" marcava como pendente até fatura fechada e sem valor. */
function invoiceStatusLabel(invoice: Invoice): InvoiceStatusLabel {
  const venceu = invoice.due_date < todayIso();
  switch (invoice.status) {
    case "paid":
      return { texto: "Paga", variante: "paid" };
    case "cancelled":
      return { texto: "Cancelada", variante: "neutral" };
    case "overdue":
      return { texto: "Em atraso", variante: "pending" };
    case "closed":
      if (invoiceTotal(invoice) === 0) return { texto: "Sem valor", variante: "neutral" };
      return venceu ? { texto: "Em aberto", variante: "pending" } : { texto: "Fechada", variante: "neutral" };
    default:
      return venceu ? { texto: "Em aberto", variante: "pending" } : { texto: "A vencer", variante: "neutral" };
  }
}

function invoiceChipClass(variante: InvoiceStatusLabel["variante"]) {
  return variante === "neutral" ? "chip" : `chip chip--${variante}`;
}

/** "Sem valor", paga ou cancelada não têm o que pagar: a RPC recusa com
 *  'invoice has no payable installments'. */
function canPayInvoice(invoice: Invoice) {
  return invoice.status !== "paid" && invoice.status !== "cancelled" && invoiceTotal(invoice) > 0;
}

/** Único lugar que desenha uma fatura: a rota de detalhe e o bloco expansível
 *  do cartão usam este mesmo markup. */
function InvoiceCard({
  invoice,
  title,
  onPay,
}: {
  invoice: Invoice;
  title: string;
  onPay: () => void;
}) {
  const items = invoice.credit_card_installments || [];
  const statusLabel = invoiceStatusLabel(invoice);
  return (
    <article className="invoice-card">
      <header>
        <strong>{title}</strong>
        <b>{money(invoiceTotal(invoice))}</b>
        <span data-status={invoice.status}>
          <span className={invoiceChipClass(statusLabel.variante)}>{statusLabel.texto}</span>
        </span>
        {canPayInvoice(invoice) && (
          <div>
            <button type="button" onClick={onPay}>
              Pagar fatura
            </button>
          </div>
        )}
      </header>
      <ul>
        {items.map((item, index) => {
          const purchase = Array.isArray(item.credit_card_purchases)
            ? item.credit_card_purchases[0]
            : item.credit_card_purchases;
          return (
            <li key={index}>
              <span>
                {purchase?.description || "Compra"} · {item.installment_number}/
                {purchase?.installment_count || 1}
              </span>
              <b>{money(item.amount)}</b>
            </li>
          );
        })}
      </ul>
    </article>
  );
}

function CardsPageInner() {
  const searchParams = useSearchParams();
  const selectedCardId = searchParams.get("cardId");
  const focusNewCard = searchParams.get("focus") === "new-card";
  const [importingStatement, setImportingStatement] = useState(false);
  const [statementImportFeedback, setStatementImportFeedback] = useState("");
  const [statementImportFailed, setStatementImportFailed] = useState(false);
  const [statementReviewDrafts, setStatementReviewDrafts] = useState<Record<string, Partial<StatementReviewDraft>>>({});
  const [applyingStatementId, setApplyingStatementId] = useState<string | null>(null);
  const [editingCardId, setEditingCardId] = useState<string | null>(null);
  const [deletingCardId, setDeletingCardId] = useState<string | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const [payingInvoiceId, setPayingInvoiceId] = useState<string | null>(null);
  const {
    workspace,
    accounts,
    categories,
    cards,
    invoices,
    loading,
    reload,
    statementImports,
  } = useFinance(selectedCardId ? "card" : "cards", selectedCardId || undefined);
  const { toast } = useToast();
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const selectedCard = selectedCardId ? cards.find((c) => c.id === selectedCardId) : null;
  const editingCard = cards.find((c) => c.id === editingCardId);
  const deletingCard = cards.find((c) => c.id === deletingCardId);
  const payingInvoice = invoices.find((inv) => inv.id === payingInvoiceId);
  // A RPC lança sempre a soma das parcelas da fatura; é este o valor mostrado no diálogo.
  const payingInvoiceTotal = payingInvoice ? invoiceTotal(payingInvoice) : 0;
  const statementImportDescribedBy = statementImportFeedback
    ? "statement-import-help statement-import-feedback"
    : "statement-import-help";

  async function submitCard(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.rpc("create_credit_card", {
      p_workspace_id: workspace.id,
      p_owner_id: userData.user?.id,
      p_name: form.get("name"),
      p_brand: form.get("brand") || null,
      p_last_four: form.get("last_four") || null,
      p_credit_limit: parseMoney(form.get("credit_limit")),
      p_closing_day: Number(form.get("closing_day")),
      p_due_day: Number(form.get("due_day")),
    });
    if (error) {
      toast(`Não foi possível adicionar o cartão: ${error.message}`, "error");
    } else {
      toast("Cartão adicionado.");
      setEditingCardId(null);
      setOpenDialog(false);
    }
    await reload();
  }

  async function updateCard(form: FormData) {
    if (!editingCardId) return;
    const { error } = await supabase
      .from("credit_cards")
      .update({
        name: form.get("name"),
        brand: form.get("brand") || null,
        last_four: form.get("last_four") || null,
        credit_limit: parseMoney(form.get("credit_limit")),
        closing_day: Number(form.get("closing_day")),
        due_day: Number(form.get("due_day")),
      })
      .eq("id", editingCardId)
      .eq("workspace_id", workspace.id);
    if (error) {
      toast(`Não foi possível editar o cartão: ${error.message}`, "error");
    } else {
      toast("Cartão atualizado.");
      setEditingCardId(null);
      setOpenDialog(false);
    }
    await reload();
  }

  async function confirmDeleteCard() {
    const card = cards.find((c) => c.id === deletingCardId);
    if (!card) return;
    const { error } = await supabase
      .from("credit_cards")
      .delete()
      .eq("id", card.id)
      .eq("workspace_id", workspace.id);
    if (error) {
      toast(`Não foi possível excluir o cartão: ${error.message}`, "error");
      await reload();
      return;
    }
    // A RPC create_credit_card cria uma conta técnica junto com o cartão; ela
    // só pode ser removida depois do cartão, e pode ter lançamentos presos.
    let technicalAccountNote = "";
    if (card.account_id) {
      const { error: accountError } = await supabase
        .from("accounts")
        .delete()
        .eq("id", card.account_id)
        .eq("workspace_id", workspace.id);
      if (accountError) {
        technicalAccountNote = isForeignKeyViolation(accountError)
          ? " A conta técnica foi mantida por ter lançamentos vinculados."
          : ` A conta técnica não pôde ser removida: ${accountError.message}`;
      }
    }
    toast(`Cartão excluído.${technicalAccountNote}`);
    setDeletingCardId(null);
    await reload();
  }

  async function submitPurchase(form: FormData) {
    const { error } = await supabase.rpc("create_installment_purchase", {
      p_credit_card_id: selectedCardId,
      p_description: form.get("description"),
      p_total_amount: parseMoney(form.get("total_amount")),
      p_purchased_on: form.get("purchased_on"),
      p_installment_count: Number(form.get("installment_count") || 1),
      p_category_id: form.get("category_id") || null,
      p_notes: form.get("notes") || null,
      p_idempotency_key: crypto.randomUUID(),
    });
    if (error) toast("Não foi possível registrar a compra.", "error");
    else toast("Compra registrada.");
    await reload();
  }

  async function submitInvoicePayment(form: FormData) {
    if (!payingInvoiceId) return;
    const { error } = await supabase.rpc("pay_credit_card_invoice", {
      p_invoice_id: payingInvoiceId,
      p_account_id: form.get("account_id"),
      p_paid_on: form.get("paid_on"),
      p_idempotency_key: crypto.randomUUID(),
    });
    if (error) {
      toast(`Não foi possível pagar a fatura: ${error.message}`, "error");
      return;
    }
    toast("Fatura paga.");
    setPayingInvoiceId(null);
    await reload();
  }

  async function submitStatementImport(form: FormData) {
    const file = form.get("statement") as File | null;
    setStatementImportFeedback("");
    setStatementImportFailed(false);
    if (!file || file.size === 0) {
      setStatementImportFeedback("Selecione um arquivo para importar.");
      setStatementImportFailed(true);
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      setStatementImportFeedback("O arquivo deve ter no máximo 5 MB.");
      setStatementImportFailed(true);
      return;
    }
    const contentType = file.type === "application/pdf" ? "application/pdf" : "text/plain";
    const checksum = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", await file.arrayBuffer())))
      .map((value) => value.toString(16).padStart(2, "0"))
      .join("");

    setImportingStatement(true);
    try {
      const { data: created, error: createError } = await supabase.rpc("create_credit_card_statement_import", {
        p_credit_card_id: selectedCardId,
        p_file_name: file.name,
        p_content_type: contentType,
        p_size_bytes: file.size,
        p_sha256: checksum,
      });
      const job = Array.isArray(created) ? created[0] : created;
      if (createError || !job) throw new Error("create_import_failed");
      if (job.status !== "pending") {
        setStatementImportFeedback("Este arquivo já possui uma importação em andamento ou concluída.");
        await reload();
        return;
      }

      await supabase.storage.from("credit-card-statements").remove([job.storage_path]);
      const { error: uploadError } = await supabase.storage.from("credit-card-statements").upload(job.storage_path, file, { contentType });
      if (uploadError) throw uploadError;
      const { error: queueError } = await supabase.rpc("queue_credit_card_statement_import", { p_import_id: job.id });
      if (queueError) throw queueError;
      const { data: result, error: workerError } = await supabase.functions.invoke("process-credit-card-statement-import", { body: { importId: job.id } });
      if (workerError) throw workerError;
      setStatementImportFailed(result?.status !== "pending_review");
      setStatementImportFeedback(result?.status === "pending_review" ? "Fatura extraída. Revise antes de importar." : statementImportErrorMessage(result?.error));
    } catch {
      setStatementImportFeedback(statementImportErrorMessage("request_failed"));
      setStatementImportFailed(true);
    } finally {
      setImportingStatement(false);
      await reload();
    }
  }

  function updateStatementReview(importId: string, ordinal: number, patch: Partial<StatementReviewDraft>) {
    const key = `${importId}:${ordinal}`;
    setStatementReviewDrafts((current) => ({ ...current, [key]: { ...current[key], ...patch } }));
  }

  async function applyStatementReview(item: StatementImport) {
    const payload = (item.credit_card_statement_import_items || []).map((candidate) => {
      const draft = reviewDraft(candidate, statementReviewDrafts[`${item.id}:${candidate.ordinal}`]);
      return { ordinal: candidate.ordinal, purchasedOn: draft.purchased_on, description: draft.description, installmentAmountCents: draft.installment_amount_cents, installmentNumber: draft.installment_number, installmentCount: draft.installment_count, totalAmountCents: draft.total_amount_cents, sourceFingerprint: candidate.source_fingerprint };
    });
    if (payload.some((candidate) => !candidate.totalAmountCents || candidate.totalAmountCents < candidate.installmentAmountCents)) {
      toast("Informe o total original de cada compra antes de confirmar.", "error");
      return;
    }
    setApplyingStatementId(item.id);
    const { error } = await supabase.rpc("apply_credit_card_statement_import", { p_import_id: item.id, p_items: payload });
    if (error) toast(statementImportErrorMessage(error.message), "error");
    else toast("Fatura importada. O pagamento continua uma ação separada.");
    setApplyingStatementId(null);
    await reload();
  }

  const openNewCard = () => {
    setEditingCardId(null);
    setOpenDialog(true);
  };
  const openEditCard = (id: string) => {
    setEditingCardId(id);
    setOpenDialog(true);
  };

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title={selectedCard ? selectedCard.name : "Cartões"}
        subtitle={selectedCard ? "Faturas e compras." : "Limites e vencimentos em um só lugar."}
        workspaceName={workspace.name}
        action={!selectedCardId ? {
          label: "Cadastrar cartão",
          onClick: openNewCard,
        } : undefined}
      />

      {!selectedCardId && (
        <section className="management-grid" style={{ gridTemplateColumns: '1fr' }}>
          <List title="Cartões ativos">
            {cards.map((c) => {
              const cardInvoices = invoices.filter(inv => inv.credit_card_id === c.id);
              const openInvoice = cardInvoices.find(inv => inv.status !== 'paid') || cardInvoices[0];
              const openInvoiceTotal = openInvoice?.credit_card_installments?.reduce((sum, item) => sum + Number(item.amount), 0) || 0;
              const usedLimit = cardInvoices.reduce((sum, inv) => 
                inv.status !== 'paid' ? sum + (inv.credit_card_installments?.reduce((s, i) => s + Number(i.amount), 0) || 0) : sum, 0
              );
              const limitPercentage = c.credit_limit > 0 ? Math.min(100, (usedLimit / c.credit_limit) * 100) : 0;

              // As faturas do cartão só são desenhadas quando o bloco abre.
              // <details> nativo dá teclado e acessibilidade sem estado React.
              return (
                <details className="card-block" key={c.id}>
                  <summary className="account-row">
                    <span className="brand-badge">
                      <BrandLogo brand={c.brand} />
                    </span>
                    <div className="card-block__info">
                      <div className="card-block__line">
                        <strong>
                          {c.name}
                          {c.last_four ? ` • ${c.last_four}` : ""}
                        </strong>
                        <b>{money(c.credit_limit)}</b>
                      </div>
                      <small className="card-block__line muted">
                        <span>Fatura atual: <strong>{money(openInvoiceTotal)}</strong></span>
                        <span>Disponível: {money(c.credit_limit - usedLimit)}</span>
                      </small>
                      <div className="progress-bar">
                        <div
                          className={limitPercentage > 90 ? "progress-bar__fill progress-bar__fill--alert" : "progress-bar__fill"}
                          style={{ width: `${limitPercentage}%` }}
                        />
                      </div>
                    </div>
                    <span className="row-actions">
                      {/* Sem stopPropagation, clicar em editar/excluir abriria o bloco. */}
                      <button
                        type="button"
                        aria-label="Editar cartão"
                        title="Editar cartão"
                        onClick={(e) => { e.preventDefault(); e.stopPropagation(); openEditCard(c.id); }}
                      >
                        <Pencil aria-hidden="true" />
                      </button>
                      <button
                        type="button"
                        className="danger"
                        aria-label="Excluir cartão"
                        title="Excluir cartão"
                        onClick={(e) => { e.preventDefault(); e.stopPropagation(); setDeletingCardId(c.id); }}
                      >
                        <Trash2 aria-hidden="true" />
                      </button>
                    </span>
                    <ChevronDown className="chevron" aria-hidden="true" />
                  </summary>

                  <div className="card-block__body">
                    {cardInvoices.length === 0 ? (
                      <p className="dashboard-empty">Nenhuma fatura importada.</p>
                    ) : (
                      cardInvoices.map((inv) => (
                        <InvoiceCard
                          key={inv.id}
                          invoice={inv}
                          title={`Vence ${dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}`}
                          onPay={() => setPayingInvoiceId(inv.id)}
                        />
                      ))
                    )}
                  </div>
                </details>
              );
            })}
            {cards.length === 0 && (
              <p className="dashboard-empty" style={{ margin: "2rem 0" }}>Nenhum cartão cadastrado.</p>
            )}
          </List>
          
          <Dialog open={openDialog} onClose={() => { setOpenDialog(false); setEditingCardId(null); }} title={editingCard ? "Editar cartão" : "Adicionar cartão"}>
            <SimpleForm key={editingCard?.id ?? "new"} onSubmit={editingCard ? updateCard : submitCard}>
              <label htmlFor="card-name">Nome do cartão</label>
              <input id="card-name" name="name" placeholder="Nome do cartão" defaultValue={editingCard?.name} required autoFocus={focusNewCard} />
              <label htmlFor="card-brand">Bandeira</label>
              <select id="card-brand" name="brand" defaultValue={editingCard?.brand ?? ""}>
                <option value="">Bandeira</option>
                {CARD_BRANDS.map((b) => (
                  <option key={b} value={b}>
                    {b}
                  </option>
                ))}
              </select>
              <label htmlFor="card-last-four">Final do cartão (4 dígitos, opcional)</label>
              {/* O banco exige ^[0-9]{4}$; sem estas restrições o cadastro
                  falhava no CHECK e a tela só dizia "não foi possível". */}
              <input
                id="card-last-four"
                name="last_four"
                inputMode="numeric"
                pattern="[0-9]{4}"
                maxLength={4}
                title="Informe exatamente 4 dígitos, ou deixe em branco."
                placeholder="1234"
                defaultValue={editingCard?.last_four ?? ""}
              />
              <label htmlFor="card-credit-limit">Limite de crédito</label>
              <input id="card-credit-limit" name="credit_limit" placeholder="0,00" defaultValue={editingCard ? String(editingCard.credit_limit).replace(".", ",") : ""} required />
              <label htmlFor="card-closing-day">Dia de fechamento</label>
              <input
                id="card-closing-day"
                name="closing_day"
                type="number"
                min="1"
                max="31"
                placeholder="Fecha dia"
                defaultValue={editingCard?.closing_day}
                required
              />
              <label htmlFor="card-due-day">Dia de vencimento</label>
              <input
                id="card-due-day"
                name="due_day"
                type="number"
                min="1"
                max="31"
                placeholder="Vence dia"
                defaultValue={editingCard?.due_day}
                required
              />
              <button>{editingCard ? "Salvar alterações" : "Cadastrar cartão"}</button>
            </SimpleForm>
          </Dialog>

          <Dialog open={deletingCardId !== null} onClose={() => setDeletingCardId(null)} title="Excluir cartão">
            {deletingCard && (
              <>
                <p>
                  Excluir o cartão <strong>{deletingCard.name}</strong>
                  {deletingCard.last_four ? ` • ${deletingCard.last_four}` : ""}, com limite de{" "}
                  <b>{money(deletingCard.credit_limit)}</b>? Esta ação não pode ser desfeita.
                </p>
                <SimpleForm onSubmit={confirmDeleteCard}>
                  <button>Excluir cartão</button>
                  <button type="button" onClick={() => setDeletingCardId(null)}>
                    Cancelar
                  </button>
                </SimpleForm>
              </>
            )}
          </Dialog>
        </section>
      )}

      {selectedCardId && (
        <section className="management-grid">
          <List title="Faturas">
            {invoices.length === 0 && (
              <p className="muted">Nenhuma fatura para este cartão.</p>
            )}
            {invoices.map((inv) => (
              <InvoiceCard
                key={inv.id}
                invoice={inv}
                title={`Vence ${dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}`}
                onPay={() => setPayingInvoiceId(inv.id)}
              />
            ))}
          </List>
          <aside className="form-card">
            <h2>Nova compra</h2>
            <SimpleForm onSubmit={submitPurchase}>
              <label htmlFor="purchase-description">Descrição</label>
              <input id="purchase-description" name="description" placeholder="Descrição" required />
              <label htmlFor="purchase-total">Valor total</label>
              <input id="purchase-total" name="total_amount" placeholder="0,00" required />
              <label htmlFor="purchase-date">Data da compra</label>
              <input
                id="purchase-date"
                name="purchased_on"
                type="date"
                defaultValue={todayIso()}
                required
              />
              <label htmlFor="purchase-installments">Quantidade de parcelas</label>
              <input
                id="purchase-installments"
                name="installment_count"
                type="number"
                min="1"
                max="120"
                defaultValue="1"
                required
              />
              <label htmlFor="purchase-category">Categoria</label>
              <select id="purchase-category" name="category_id">
                <option value="">Sem categoria</option>
                {categories
                  .filter((c) => c.kind === "expense")
                  .map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
              </select>
              <label htmlFor="purchase-notes">Observação</label>
              <input id="purchase-notes" name="notes" placeholder="Observação" />
              <button>Registrar</button>
            </SimpleForm>
          </aside>
        </section>
      )}

      {selectedCardId && (
        <section className="card-import" aria-labelledby="statement-import-title">
          <div>
            <h2 id="statement-import-title">Importar fatura experimental</h2>
            <p className="muted">Aceita apenas a fixture sintética documentada. PDFs e layouts reais serão recusados sem criar compras.</p>
          </div>
          <form className="finance-form" aria-busy={importingStatement} onSubmit={(event) => { event.preventDefault(); void submitStatementImport(new FormData(event.currentTarget)); }}>
            <label htmlFor="statement-file">Arquivo de fatura</label>
            <input id="statement-file" name="statement" type="file" accept="application/pdf,text/plain,.txt,.bsf-fixture" required disabled={importingStatement} aria-invalid={statementImportFailed || undefined} aria-describedby={statementImportDescribedBy} />
            <small id="statement-import-help">Até 5 MB. Apenas a fixture sintética é processada nesta etapa.</small>
            <button disabled={importingStatement}>{importingStatement ? "Enviando..." : "Enviar para importação"}</button>
            {statementImportFeedback && <p id="statement-import-feedback" className={statementImportFailed ? "form-error" : "form-success"} role={statementImportFailed ? "alert" : "status"}>{statementImportFeedback}</p>}
          </form>
          {statementImports.length > 0 && (
            <ul className="statement-import-list" aria-label="Importações recentes">
              {statementImports.map((item) => {
                const candidates = item.credit_card_statement_import_items || [];
                const currentCents = candidates.reduce((total, candidate) => total + reviewDraft(candidate, statementReviewDrafts[`${item.id}:${candidate.ordinal}`]).installment_amount_cents, 0);
                const difference = currentCents - (item.declared_total_cents || 0);
                return <li key={item.id}>
                  <span>{item.file_name}</span>
                  <strong data-status={item.status}>{item.status === "pending_review" ? "Revisão necessária" : item.status === "failed" ? "Falhou: formato não suportado" : item.status}</strong>
                  {item.status === "pending_review" && <div className="statement-review">
                    <p role="status">Revisão necessária. Diferença: {money(difference / 100)}</p>
                    {candidates.map((candidate) => {
                      const draft = reviewDraft(candidate, statementReviewDrafts[`${item.id}:${candidate.ordinal}`]);
                      return <fieldset key={candidate.ordinal}>
                        <label>Descrição <input value={draft.description} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { description: event.target.value })} /></label>
                        <label>Data <input type="date" value={draft.purchased_on} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { purchased_on: event.target.value })} /></label>
                        <label>Valor da parcela <input inputMode="decimal" value={money(draft.installment_amount_cents / 100).replace(/^R\$\s*/, "")} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { installment_amount_cents: Math.round(parseMoney(event.target.value) * 100) })} /></label>
                        <label>Parcela <input type="number" min="1" max="120" value={draft.installment_number} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { installment_number: Number(event.target.value) })} /></label>
                        <label>Total de parcelas <input type="number" min="1" max="120" value={draft.installment_count} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { installment_count: Number(event.target.value) })} /></label>
                        <label htmlFor={`statement-total-${item.id}-${candidate.ordinal}`}>Total original de {candidate.description}</label>
                        <input id={`statement-total-${item.id}-${candidate.ordinal}`} inputMode="decimal" value={draft.total_amount_cents === null ? "" : money(draft.total_amount_cents / 100).replace(/^R\$\s*/, "")} onChange={(event) => updateStatementReview(item.id, candidate.ordinal, { total_amount_cents: event.target.value ? Math.round(parseMoney(event.target.value) * 100) : null })} />
                      </fieldset>;
                    })}
                    <button type="button" disabled={applyingStatementId === item.id} onClick={() => void applyStatementReview(item)}>{applyingStatementId === item.id ? "Confirmando..." : "Confirmar fatura revisada"}</button>
                  </div>}
                </li>;
              })}
            </ul>
          )}
        </section>
      )}

      {!selectedCardId && (
        <section className="account-list">
          <h2>Faturas</h2>
          {invoices.length === 0 && (
            <p className="muted">Nenhuma fatura registrada.</p>
          )}
          {invoices.map((inv) => {
            const card = cards.find((c) => c.id === inv.credit_card_id);
            const items = inv.credit_card_installments || [];
            const total = items.reduce((s, i) => s + Number(i.amount), 0);
            const statusLabel = invoiceStatusLabel(inv);
            return (
              <article className="invoice-card" key={inv.id}>
                <header>
                  <strong>
                    {card?.name || "Cartão"} · vence{" "}
                    {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}
                  </strong>
                  <b>{money(total)}</b>
                  <span data-status={inv.status}>
                    <span className={invoiceChipClass(statusLabel.variante)}>{statusLabel.texto}</span>
                  </span>
                  {canPayInvoice(inv) && (
                    <div>
                      <button type="button" onClick={() => setPayingInvoiceId(inv.id)}>
                        Pagar fatura
                      </button>
                    </div>
                  )}
                </header>
                <ul>
                  {items.map((i, n) => {
                    const p = Array.isArray(i.credit_card_purchases)
                      ? i.credit_card_purchases[0]
                      : i.credit_card_purchases;
                    return (
                      <li key={n}>
                        <span>
                          {p?.description || "Compra"} · {i.installment_number}/
                          {p?.installment_count || 1}
                        </span>
                        <b>{money(i.amount)}</b>
                      </li>
                    );
                  })}
                </ul>
              </article>
            );
          })}
        </section>
      )}

      <Dialog open={payingInvoiceId !== null} onClose={() => setPayingInvoiceId(null)} title="Pagar fatura">
        {payingInvoice && (
          <SimpleForm key={payingInvoice.id} onSubmit={submitInvoicePayment}>
            <p>
              Será lançada uma despesa de <b>{money(payingInvoiceTotal)}</b> referente à fatura que vence em{" "}
              {dateFmt.format(new Date(`${payingInvoice.due_date}T12:00:00`))}.
            </p>
            <p className="muted">
              O valor lançado é sempre o total da fatura. Pagamentos parciais ou rotativo precisam ser ajustados
              depois em Movimentações.
            </p>
            <label htmlFor="invoice-payment-account">Conta de pagamento</label>
            <select id="invoice-payment-account" name="account_id" required defaultValue="">
              <option value="" disabled>
                Selecione a conta
              </option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.name}
                </option>
              ))}
            </select>
            <label htmlFor="invoice-payment-date">Data do pagamento</label>
            <input
              id="invoice-payment-date"
              name="paid_on"
              type="date"
              defaultValue={todayIso()}
              required
            />
            <button>Confirmar pagamento</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}

export function CardsPage() {
  return (
    <Suspense fallback={<main className="management-page"><p className="muted">Carregando...</p></main>}>
      <CardsPageInner />
    </Suspense>
  );
}
