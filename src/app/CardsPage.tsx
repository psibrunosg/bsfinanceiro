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
    categories,
    cards,
    invoices,
    loading,
    message,
    setMessage,
    reload,
    statementImports,
  } = useFinance(selectedCardId ? "card" : "cards", selectedCardId || undefined);
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const selectedCard = selectedCardId ? cards.find((c) => c.id === selectedCardId) : null;
  const editingCard = cards.find((c) => c.id === editingCardId);
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
    setMessage(
      error
        ? `Não foi possível adicionar o cartão: ${error.message}`
        : "Cartão adicionado."
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
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

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
                    <div className="progress-bar" style={{ marginTop: '8px', height: '6px', background: 'var(--border-color)', borderRadius: '3px', overflow: 'hidden' }}>
                      <div style={{ width: `${limitPercentage}%`, height: '100%', background: limitPercentage > 90 ? 'var(--danger-color)' : 'var(--primary-color)' }} />
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
        </section>
      )}

      {selectedCardId && (
        <section className="management-grid">
          <List title="Faturas">
            {invoices.length === 0 && (
              <p className="muted">Nenhuma fatura para este cartão.</p>
            )}
            {invoices.map((inv) => {
              const items = inv.credit_card_installments || [];
              const total = items.reduce((s, i) => s + Number(i.amount), 0);
              return (
                <article className="invoice-card" key={inv.id}>
                  <header>
                    <strong>
                      Vence{" "}
                      {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}
                    </strong>
                    <b>{money(total)}</b>
                    <span data-status={inv.status}>
                      {inv.status === "paid" ? "Paga" : "Em aberto"}
                    </span>
                  </header>
                  <ul>
                    {items.map((i, n) => {
                      const p = Array.isArray(i.credit_card_purchases)
                        ? i.credit_card_purchases[0]
                        : i.credit_card_purchases;
                      return (
                        <li key={n}>
                          <span>
                            {p?.description || "Compra"} ·{" "}
                            {i.installment_number}/{p?.installment_count || 1}
                          </span>
                          <b>{money(i.amount)}</b>
                        </li>
                      );
                    })}
                  </ul>
                </article>
              );
            })}
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
              {statementImports.map((item) => <li key={item.id}><span>{item.file_name}</span><strong data-status={item.status}>{item.status === "failed" ? "Falhou: formato não suportado" : item.status}</strong></li>)}
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
            return (
              <article className="invoice-card" key={inv.id}>
                <header>
                  <strong>
                    {card?.name || "Cartão"} · vence{" "}
                    {dateFmt.format(new Date(`${inv.due_date}T12:00:00`))}
                  </strong>
                  <b>{money(total)}</b>
                  <span data-status={inv.status}>
                    {inv.status === "paid" ? "Paga" : "Em aberto"}
                  </span>
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
