"use client";

import { useSearchParams } from "next/navigation";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { Dialog } from "./components/Dialog";
import { money, parseMoney, dateFmt } from "./components/Money";
import { BrandLogo, CARD_BRANDS } from "./brand-logo";
import { createClient } from "@/lib/supabase/client";
import { useMemo, Suspense, useState } from "react";
import { CalendarClock, CreditCard, TrendingDown, Wallet } from "lucide-react";
import { InterestRadarWidget } from "./components/InterestRadarWidget";
import { InstallmentTimelineWidget } from "./components/InstallmentTimelineWidget";
import { DebtPayoffWidget } from "./components/DebtPayoffWidget";

function statementImportErrorMessage(errorCode: string | null) {
  switch (errorCode) {
    case "unsupported_format": return "Formato não suportado; nenhuma compra foi criada.";
    case "checksum_mismatch": return "O arquivo enviado não corresponde ao arquivo validado. Envie-o novamente.";
    case "purchase_creation_failed": return "A compra não pôde ser criada. Tente novamente.";
    case "processing_failed": return "A importação foi interrompida e poderá ser tentada novamente.";
    default: return "Não foi possível enviar a importação.";
  }
}

function CardsPageInner() {
  const searchParams = useSearchParams();
  const selectedCardId = searchParams.get("cardId");
  const focusNewCard = searchParams.get("focus") === "new-card";
  const [importingStatement, setImportingStatement] = useState(false);
  const [statementImportFeedback, setStatementImportFeedback] = useState("");
  const [statementImportFailed, setStatementImportFailed] = useState(false);
  const [editingCardId, setEditingCardId] = useState<string | null>(null);
  const [openDialog, setOpenDialog] = useState(false);
  const {
    workspace,
    accounts,
    categories,
    cards,
    invoices,
    loading,
    message,
    setMessage,
    reload,
    statementImports,
    transactions,
  } = useFinance(selectedCardId ? "card" : "cards", selectedCardId || undefined);
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="dashboard-shell">
        <p className="muted">Carregando...</p>
      </main>
    );

  const selectedCard = selectedCardId ? cards.find((c) => c.id === selectedCardId) : null;
  const editingCard = cards.find((c) => c.id === editingCardId);
  const statementImportDescribedBy = statementImportFeedback
    ? "statement-import-help statement-import-feedback"
    : "statement-import-help";

  // ponytail: agregação client-side sobre os dados que a página já carregou; sem query nova.
  const invoiceTotal = (inv: (typeof invoices)[number]) =>
    (inv.credit_card_installments || []).reduce((s, i) => s + Number(i.amount), 0);
  const scopedCards = selectedCard ? [selectedCard] : cards;
  const openInvoices = invoices.filter((inv) => inv.status !== "paid");
  const limitTotal = scopedCards.reduce((s, c) => s + Number(c.credit_limit), 0);
  const usedTotal = openInvoices.reduce((s, inv) => s + invoiceTotal(inv), 0);
  const nextInvoice = [...openInvoices].sort((a, b) => a.due_date.localeCompare(b.due_date))[0];

  const renderInvoice = (inv: (typeof invoices)[number], cardName?: string) => {
    const items = inv.credit_card_installments || [];
    return (
      <article className="account-row" key={inv.id}>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", justifyContent: "space-between", gap: 12, marginBottom: 4 }}>
            <strong>
              {cardName ? `${cardName} · vence ` : "Vence "}
              {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}
            </strong>
            <b>{money(invoiceTotal(inv))}</b>
          </div>
          <small className="muted" data-status={inv.status}>
            {inv.status === "paid" ? "Paga" : "Em aberto"}
          </small>
          <ul className="list" style={{ marginTop: 8 }}>
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
        </div>
      </article>
    );
  };

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
    setMessage(
      error ? "Não foi possível adicionar o cartão." : "Cartão adicionado."
    );
    if (!error) {
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
    setMessage(error ? "Não foi possível editar o cartão." : "Cartão atualizado.");
    if (!error) {
      setEditingCardId(null);
      setOpenDialog(false);
    }
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
    setMessage(
      error ? "Não foi possível registrar a compra." : "Compra registrada."
    );
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
      setStatementImportFailed(result?.status !== "imported");
      setStatementImportFeedback(result?.status === "imported" ? "Importação concluída." : statementImportErrorMessage(result?.error));
    } catch {
      setStatementImportFeedback(statementImportErrorMessage("request_failed"));
      setStatementImportFailed(true);
    } finally {
      setImportingStatement(false);
      await reload();
    }
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
    <main className="dashboard-shell">
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
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

      <div className="bento-row" style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}>
        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Limite total</span>
            <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}><CreditCard size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(limitTotal)}</strong>
        </article>
        <article className="metric-card metric-card--negative">
          <div className="metric-card__head">
            <span className="muted">Total usado</span>
            <span className="metric-icon-badge" style={{ background: "rgba(239,68,68,.15)", color: "#EF4444" }}><TrendingDown size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(usedTotal)}</strong>
        </article>
        <article className="metric-card metric-card--positive">
          <div className="metric-card__head">
            <span className="muted">Disponível</span>
            <span className="metric-icon-badge" style={{ background: "rgba(34,197,94,.15)", color: "#22C55E" }}><Wallet size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(limitTotal - usedTotal)}</strong>
        </article>
        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Próxima fatura</span>
            <span className="metric-icon-badge" style={{ background: "rgba(245,166,35,.15)", color: "#F5A623" }}><CalendarClock size={18} aria-hidden="true" /></span>
          </div>
          <strong>{money(nextInvoice ? invoiceTotal(nextInvoice) : 0)}</strong>
          <small className="muted">
            {nextInvoice ? `Vence ${dateFmt.format(new Date(`${nextInvoice.due_date}T12:00:00`))}` : "Sem fatura em aberto"}
          </small>
        </article>
      </div>

      {!selectedCardId && (
        <section className="bento-row" style={{ gridTemplateColumns: '1fr' }}>
          <List title="Cartões ativos">
            {cards.map((c) => {
              const cardInvoices = invoices.filter(inv => inv.credit_card_id === c.id);
              const openInvoice = cardInvoices.find(inv => inv.status !== 'paid') || cardInvoices[0];
              const openInvoiceTotal = openInvoice?.credit_card_installments?.reduce((sum, item) => sum + Number(item.amount), 0) || 0;
              const usedLimit = cardInvoices.reduce((sum, inv) => 
                inv.status !== 'paid' ? sum + (inv.credit_card_installments?.reduce((s, i) => s + Number(i.amount), 0) || 0) : sum, 0
              );
              const limitPercentage = c.credit_limit > 0 ? Math.min(100, (usedLimit / c.credit_limit) * 100) : 0;

              return (
                <article className="account-row" key={c.id}>
                  <span className="brand-badge">
                    <BrandLogo brand={c.brand} />
                  </span>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                      <strong>
                        {c.name}
                        {c.last_four ? ` • ${c.last_four}` : ""}
                      </strong>
                      <b>{money(c.credit_limit)}</b>
                    </div>
                    <small style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span>Fatura atual: <strong>{money(openInvoiceTotal)}</strong></span>
                      <span>Disponível: {money(c.credit_limit - usedLimit)}</span>
                    </small>
                    <div
                      className={`progress-bar${limitPercentage >= 90 ? " progress-bar--danger" : limitPercentage >= 70 ? " progress-bar--warning" : ""}`}
                      style={{ marginTop: 8 }}
                    >
                      <span style={{ width: `${limitPercentage}%` }} />
                    </div>
                  </div>
                  <button type="button" onClick={() => openEditCard(c.id)}>
                    Editar
                  </button>
                </article>
              );
            })}
            {cards.length === 0 && (
              <p className="dashboard-empty" style={{ margin: "2rem 0" }}>Nenhum cartão cadastrado.</p>
            )}
          </List>
          
          <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title={editingCard ? "Editar cartão" : "Adicionar cartão"}>
            <SimpleForm key={editingCard?.id ?? "new"} onSubmit={editingCard ? updateCard : submitCard}>
              <label htmlFor="card-name">Nome do cartão</label>
              <input id="card-name" name="name" placeholder="Nome do cartão" defaultValue={editingCard?.name} required autoFocus={focusNewCard} />
              <div className="form-pair">
                <label htmlFor="card-brand">Bandeira
                  <select id="card-brand" name="brand" defaultValue={editingCard?.brand ?? ""}>
                    <option value="">Bandeira</option>
                    {CARD_BRANDS.map((b) => (
                      <option key={b} value={b}>
                        {b}
                      </option>
                    ))}
                  </select>
                </label>
                <label htmlFor="card-last-four">Final do cartão
                  <input id="card-last-four" name="last_four" placeholder="Final" defaultValue={editingCard?.last_four ?? ""} />
                </label>
              </div>
              <label htmlFor="card-credit-limit">Limite de crédito</label>
              <input id="card-credit-limit" name="credit_limit" placeholder="0,00" defaultValue={editingCard ? String(editingCard.credit_limit).replace(".", ",") : ""} required />
              <div className="form-pair">
                <label htmlFor="card-closing-day">Dia de fechamento
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
                </label>
                <label htmlFor="card-due-day">Dia de vencimento
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
                </label>
              </div>
              <button>{editingCard ? "Salvar alterações" : "Cadastrar cartão"}</button>
            </SimpleForm>
          </Dialog>
        </section>
      )}

      {selectedCardId && (
        <section className="bento-row" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))' }}>
          <List title="Faturas">
            {invoices.length === 0 && (
              <p className="dashboard-empty">Nenhuma fatura para este cartão.</p>
            )}
            {invoices.map((inv) => renderInvoice(inv))}
          </List>
          <aside className="dashboard-card">
            <h3>Nova compra</h3>
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
                defaultValue={new Date().toISOString().slice(0, 10)}
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
        <section className="dashboard-card" aria-labelledby="statement-import-title">
          <div>
            <h3 id="statement-import-title">Importar fatura experimental</h3>
            <p className="muted">Aceita apenas a fixture sintética documentada. PDFs e layouts reais serão recusados sem criar compras.</p>
          </div>
          <form className="simple-form" aria-busy={importingStatement} onSubmit={(event) => { event.preventDefault(); void submitStatementImport(new FormData(event.currentTarget)); }}>
            <label htmlFor="statement-file">Arquivo de fatura</label>
            <input id="statement-file" name="statement" type="file" accept="application/pdf,text/plain,.txt,.bsf-fixture" required disabled={importingStatement} aria-invalid={statementImportFailed || undefined} aria-describedby={statementImportDescribedBy} />
            <small id="statement-import-help">Até 5 MB. Apenas a fixture sintética é processada nesta etapa.</small>
            <button disabled={importingStatement}>{importingStatement ? "Enviando..." : "Enviar para importação"}</button>
            {statementImportFeedback && <p id="statement-import-feedback" className={statementImportFailed ? "form-error" : "form-success"} role={statementImportFailed ? "alert" : "status"}>{statementImportFeedback}</p>}
          </form>
          {statementImports.length > 0 && (
            <ul className="list" style={{ marginTop: 16 }} aria-label="Importações recentes">
              {statementImports.map((item) => <li key={item.id}><span>{item.file_name}</span><strong data-status={item.status}>{item.status === "failed" ? "Falhou: formato não suportado" : item.status}</strong></li>)}
            </ul>
          )}
        </section>
      )}

      {!selectedCardId && (
        <InstallmentTimelineWidget
          invoices={invoices}
          transactions={transactions}
          currentMonth={new Date().toISOString().slice(0, 7)}
        />
      )}

      {!selectedCardId && (
        <InterestRadarWidget
          transactions={transactions}
          currentMonth={new Date().toISOString().slice(0, 7) + "-01"}
        />
      )}

      {!selectedCardId && (
        <DebtPayoffWidget
          accounts={accounts}
          invoices={invoices}
          transactions={transactions}
          currentMonth={new Date().toISOString().slice(0, 7)}
        />
      )}

      {!selectedCardId && (
        <section className="dashboard-card">
          <h3>Faturas</h3>
          {invoices.length === 0 && (
            <p className="dashboard-empty">Nenhuma fatura registrada.</p>
          )}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {invoices.map((inv) =>
              renderInvoice(inv, cards.find((c) => c.id === inv.credit_card_id)?.name || "Cartão"),
            )}
          </div>
        </section>
      )}
    </main>
  );
}

export function CardsPage() {
  return (
    <Suspense fallback={<main className="dashboard-shell"><p className="muted">Carregando...</p></main>}>
      <CardsPageInner />
    </Suspense>
  );
}
