"use client";

import { useSearchParams } from "next/navigation";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, dateFmt } from "./components/Money";
import { BrandLogo, CARD_BRANDS } from "./brand-logo";
import { createClient } from "@/lib/supabase/client";
import { useMemo, Suspense } from "react";

function CardsPageInner() {
  const searchParams = useSearchParams();
  const selectedCardId = searchParams.get("cardId");
  const focusNewCard = searchParams.get("focus") === "new-card";
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
  } = useFinance(selectedCardId ? "card" : "cards", selectedCardId || undefined);
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const selectedCard = selectedCardId ? cards.find((c) => c.id === selectedCardId) : null;

  async function submitCard(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("credit_cards").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      account_id: form.get("account_id"),
      name: form.get("name"),
      brand: form.get("brand") || null,
      last_four: form.get("last_four") || null,
      credit_limit: parseMoney(form.get("credit_limit")),
      closing_day: Number(form.get("closing_day")),
      due_day: Number(form.get("due_day")),
    });
    setMessage(
      error ? "Não foi possível adicionar o cartão." : "Cartão adicionado."
    );
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

  return (
    <main className="management-page">
      <PageHeader
        title={selectedCard ? selectedCard.name : "Cartões"}
        subtitle={selectedCard ? "Faturas e compras." : "Limites e vencimentos em um só lugar."}
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

      {!selectedCardId && (
        <section className="management-grid">
          <List title="Cartões ativos">
            {cards.map((c) => (
              <article className="account-row" key={c.id}>
                <span className="brand-badge">
                  <BrandLogo brand={c.brand} />
                </span>
                <div>
                  <strong>
                    {c.name}
                    {c.last_four ? ` • ${c.last_four}` : ""}
                  </strong>
                  <small>
                    {c.brand || "Cartão"} · fecha {c.closing_day} · vence{" "}
                    {c.due_day}
                  </small>
                </div>
                <b>{money(c.credit_limit)}</b>
              </article>
            ))}
          </List>
          <aside className="form-card">
            <h2>Adicionar cartão</h2>
            <SimpleForm onSubmit={submitCard}>
              <label htmlFor="card-account">Conta vinculada</label>
              <select id="card-account" name="account_id" required>
                <option value="">Conta vinculada</option>
                {accounts
                  .filter((a) => a.type === "credit_card")
                  .map((a) => (
                    <option key={a.id} value={a.id}>
                      {a.name}
                    </option>
                  ))}
              </select>
              <label htmlFor="card-name">Nome do cartão</label>
              <input id="card-name" name="name" placeholder="Nome do cartão" required autoFocus={focusNewCard} />
              <label htmlFor="card-brand">Bandeira</label>
              <select id="card-brand" name="brand" defaultValue="">
                <option value="">Bandeira</option>
                {CARD_BRANDS.map((b) => (
                  <option key={b} value={b}>
                    {b}
                  </option>
                ))}
              </select>
              <label htmlFor="card-last-four">Final do cartão</label>
              <input id="card-last-four" name="last_four" placeholder="Final" />
              <label htmlFor="card-credit-limit">Limite de crédito</label>
              <input id="card-credit-limit" name="credit_limit" placeholder="0,00" required />
              <label htmlFor="card-closing-day">Dia de fechamento</label>
              <input
                id="card-closing-day"
                name="closing_day"
                type="number"
                min="1"
                max="31"
                placeholder="Fecha dia"
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
                required
              />
              <button>Adicionar</button>
            </SimpleForm>
          </aside>
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
