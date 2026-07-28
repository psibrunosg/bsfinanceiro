"use client";

import { Suspense, useMemo } from "react";
import { useSearchParams } from "next/navigation";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney } from "./components/Money";
import { createClient } from "@/lib/supabase/client";
import { todayInSaoPaulo } from "@/lib/finance/local-date";

function TransactionsPageInner() {
  const searchParams = useSearchParams();
  const presetType = searchParams.get("type") === "income" ? "income" : "expense";
  const { workspace, accounts, categories, transactions, loading, message, setMessage, reload } = useFinance("transactions");
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function submitTransaction(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const type = String(form.get("type"));
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace.id, owner_id: userData.user?.id, type, amount: parseMoney(form.get("amount")), account_id: form.get("account_id"),
      category_id: type === "transfer" ? null : form.get("category_id"), destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
      description: form.get("description") || (type === "transfer" ? "Transferência" : "Movimentação"), competence_date: form.get("competence_date"), paid_at: form.get("competence_date"), status: "paid", idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível salvar." : "Movimentação adicionada.");
    await reload();
  }

  const messageIsError = message.startsWith("Não");

  return <main className="management-page">
    <PageHeader title="Movimentações" subtitle="Registre entradas, saídas e transferências." workspaceName={workspace.name} />
    <Nav />
    {message && <p className={messageIsError ? "form-error" : "form-success"} role={messageIsError ? "alert" : "status"}>{message}</p>}
    <section className="management-grid">
      <List title="Últimos lançamentos">{transactions.map((t) => <article className="account-row" key={t.id}><span>{t.type === "income" ? "↑" : "↓"}</span><div><strong>{t.description}</strong><small>{t.competence_date}</small></div><b>{money(t.amount)}</b></article>)}</List>
      <aside className="form-card"><h2>Nova movimentação</h2><SimpleForm onSubmit={submitTransaction}>
        <label htmlFor="transaction-type">Tipo de movimentação</label>
        <select id="transaction-type" name="type" defaultValue={presetType} autoFocus><option value="expense">Despesa</option><option value="income">Receita</option><option value="transfer">Transferência</option></select>
        <label htmlFor="transaction-amount">Valor</label>
        <input id="transaction-amount" name="amount" placeholder="0,00" required />
        <label htmlFor="transaction-account">Conta</label>
        <select id="transaction-account" name="account_id" required><option value="">Conta</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
        <label htmlFor="transaction-category">Categoria</label>
        <select id="transaction-category" name="category_id"><option value="">Categoria</option>{categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}</select>
        <label htmlFor="transaction-destination">Conta de destino</label>
        <select id="transaction-destination" name="destination_account_id"><option value="">Destino se transferência</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
        <label htmlFor="transaction-description">Descrição</label>
        <input id="transaction-description" name="description" placeholder="Descrição" />
        <label htmlFor="transaction-date">Data</label>
        <input id="transaction-date" name="competence_date" type="date" defaultValue={todayInSaoPaulo()} required />
        <button>Salvar</button>
      </SimpleForm></aside>
    </section>
  </main>;
}

export function TransactionsPage() {
  return <Suspense fallback={<main className="management-page"><p className="muted">Carregando...</p></main>}><TransactionsPageInner /></Suspense>;
}
