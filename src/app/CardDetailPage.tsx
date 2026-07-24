"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, dateFmt } from "./components/Money";
import { createClient } from "@/lib/supabase/client";
import { useMemo } from "react";

export function CardDetailPage({ cardId }: { cardId: string }) {
  const {
    workspace,
    categories,
    cards,
    invoices,
    loading,
    message,
    setMessage,
    reload,
  } = useFinance("card", cardId);
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const card = cards.find((c) => c.id === cardId);

  async function submitPurchase(form: FormData) {
    const { error } = await supabase.rpc("create_installment_purchase", {
      p_credit_card_id: cardId,
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
        title={card?.name || "Cartão"}
        subtitle="Faturas e compras."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
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
            <input name="description" placeholder="Descrição" required />
            <input name="total_amount" placeholder="0,00" required />
            <input
              name="purchased_on"
              type="date"
              defaultValue={new Date().toISOString().slice(0, 10)}
              required
            />
            <input
              name="installment_count"
              type="number"
              min="1"
              max="120"
              defaultValue="1"
              required
            />
            <select name="category_id">
              <option value="">Sem categoria</option>
              {categories
                .filter((c) => c.kind === "expense")
                .map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
            </select>
            <input name="notes" placeholder="Observação" />
            <button>Registrar</button>
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
