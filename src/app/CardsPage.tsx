"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, dateFmt } from "./components/Money";
import { BrandLogo, CARD_BRANDS } from "./brand-logo";
import { createClient } from "@/lib/supabase/client";
import { useMemo } from "react";

export function CardsPage() {
  const {
    workspace,
    accounts,
    cards,
    invoices,
    loading,
    message,
    setMessage,
    reload,
  } = useFinance("cards");
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

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

  return (
    <main className="management-page">
      <PageHeader
        title="Cartões"
        subtitle="Limites e vencimentos em um só lugar."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
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
            <select name="account_id" required>
              <option value="">Conta vinculada</option>
              {accounts
                .filter((a) => a.type === "credit_card")
                .map((a) => (
                  <option key={a.id} value={a.id}>
                    {a.name}
                  </option>
                ))}
            </select>
            <input name="name" placeholder="Nome do cartão" required />
            <select name="brand" defaultValue="">
              <option value="">Bandeira</option>
              {CARD_BRANDS.map((b) => (
                <option key={b} value={b}>
                  {b}
                </option>
              ))}
            </select>
            <input name="last_four" placeholder="Final" />
            <input name="credit_limit" placeholder="0,00" required />
            <input
              name="closing_day"
              type="number"
              min="1"
              max="31"
              placeholder="Fecha dia"
              required
            />
            <input
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
    </main>
  );
}
