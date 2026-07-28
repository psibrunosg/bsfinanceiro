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

  return <main className="management-page">
    <PageHeader title="Movimentações" subtitle="Registre entradas, saídas e transferências." workspaceName={workspace.name} />
    <Nav />
    {message && <p className="form-success" role="status">{message}</p>}
    <section className="management-grid">
      <List title="Últimos lançamentos">{transactions.map((t) => <article className="account-row" key={t.id}><span>{t.type === "income" ? "↑" : "↓"}</span><div><strong>{t.description}</strong><small>{t.competence_date}</small></div><b>{money(t.amount)}</b></article>)}</List>
      <aside className="form-card"><h2>Nova movimentação</h2><SimpleForm onSubmit={submitTransaction}>
        <select name="type" defaultValue={presetType} aria-label="Tipo de movimentação" autoFocus><option value="expense">Despesa</option><option value="income">Receita</option><option value="transfer">Transferência</option></select>
        <input name="amount" placeholder="0,00" required aria-label="Valor" />
        <select name="account_id" required aria-label="Conta"><option value="">Conta</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
        <select name="category_id" aria-label="Categoria"><option value="">Categoria</option>{categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}</select>
        <select name="destination_account_id" aria-label="Conta de destino"><option value="">Destino se transferência</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
        <input name="description" placeholder="Descrição" aria-label="Descrição" />
        <input name="competence_date" type="date" defaultValue={new Date().toISOString().slice(0, 10)} required aria-label="Data" />
        <button>Salvar</button>
      </SimpleForm></aside>
    </section>
  </main>;
}

export function TransactionsPage() {
  return <Suspense fallback={<main className="management-page"><p className="muted">Carregando...</p></main>}><TransactionsPageInner /></Suspense>;
}
