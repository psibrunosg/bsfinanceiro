"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

type Route = "dashboard" | "accounts" | "categories" | "transactions" | "cards" | "card" | "commitments" | "planning" | "settings";
type Workspace = { id: string; name: string };
type Account = { id: string; name: string; type: string; initial_balance: number };
type Category = { id: string; name: string; kind: string; color?: string | null };
type Card = { id: string; name: string; brand?: string | null; last_four?: string | null; credit_limit: number; closing_day: number; due_day: number };
type Invoice = { id: string; credit_card_id?: string; due_date: string; status: string; credit_card_installments?: { amount: number; installment_number: number; credit_card_purchases?: { description: string; installment_count: number } | { description: string; installment_count: number }[] | null }[] };
type Transaction = { id: string; type: string; description: string; amount: number; competence_date: string };

const brl = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });
const date = new Intl.DateTimeFormat("pt-BR");

function money(value: unknown) {
  return brl.format(Number(value || 0));
}

function parseMoney(value: FormDataEntryValue | null) {
  return Number(String(value || "0").replace(/\./g, "").replace(",", "."));
}

export function FinanceClientPage({ route, cardId }: { route: Route; cardId?: string }) {
  const supabase = useMemo(() => createClient(), []);
  const [loading, setLoading] = useState(true);
  const [workspace, setWorkspace] = useState<Workspace | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [cards, setCards] = useState<Card[]>([]);
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [message, setMessage] = useState("");

  async function load() {
    setLoading(true);
    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;
    if (!user) {
      window.location.replace(appPath("/entrar"));
      return;
    }
    const { data: ws } = await supabase.from("workspaces").select("id,name").eq("owner_id", user.id).eq("kind", "personal").order("created_at").limit(1).maybeSingle();
    if (!ws) {
      window.location.replace(appPath("/onboarding"));
      return;
    }
    setWorkspace(ws);
    const [{ data: accountRows }, { data: categoryRows }, { data: cardRows }, { data: txRows }] = await Promise.all([
      supabase.from("accounts").select("id,name,type,initial_balance").eq("workspace_id", ws.id).eq("active", true).order("created_at"),
      supabase.from("categories").select("id,name,kind,color").eq("workspace_id", ws.id).eq("active", true).order("name"),
      supabase.from("credit_cards").select("id,name,brand,last_four,credit_limit,closing_day,due_day").eq("workspace_id", ws.id).eq("active", true).order("created_at"),
      supabase.from("transactions").select("id,type,description,amount,competence_date").eq("workspace_id", ws.id).order("competence_date", { ascending: false }).limit(30),
    ]);
    setAccounts(accountRows || []);
    setCategories(categoryRows || []);
    setCards(cardRows || []);
    setTransactions(txRows || []);
    if (route === "card" && cardId) {
      const { data } = await supabase.from("credit_card_invoices").select("id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))").eq("credit_card_id", cardId).order("due_date", { ascending: false }).limit(12);
      setInvoices(data || []);
    } else if (route === "cards") {
      const { data } = await supabase.from("credit_card_invoices").select("id,credit_card_id,due_date,status,credit_card_installments(amount,installment_number,credit_card_purchases(description,installment_count))").eq("workspace_id", ws.id).order("due_date", { ascending: false }).limit(24);
      setInvoices(data || []);
    }
    setLoading(false);
  }

  // O carregamento depende de estado atualizado pelo próprio load; manter a lista curta evita loop.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => { void load(); }, [route, cardId]);

  async function signOut() {
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  async function submitAccount(form: FormData) {
    if (!workspace) return;
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("accounts").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, name: form.get("name"), type: form.get("type"), initial_balance: parseMoney(form.get("initial_balance")) });
    setMessage(error ? "Não foi possível adicionar a conta." : "Conta adicionada.");
    await load();
  }

  async function submitCategory(form: FormData) {
    if (!workspace) return;
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("categories").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, name: form.get("name"), kind: form.get("kind"), color: form.get("color") || "#087f5b" });
    setMessage(error ? "Não foi possível criar a categoria." : "Categoria criada.");
    await load();
  }

  async function submitTransaction(form: FormData) {
    if (!workspace) return;
    const { data: userData } = await supabase.auth.getUser();
    const type = String(form.get("type"));
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      type,
      amount: parseMoney(form.get("amount")),
      account_id: form.get("account_id"),
      category_id: type === "transfer" ? null : form.get("category_id"),
      destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
      description: form.get("description") || (type === "transfer" ? "Transferência" : "Movimentação"),
      competence_date: form.get("competence_date"),
      paid_at: form.get("competence_date"),
      status: "paid",
      idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível salvar." : "Movimentação adicionada.");
    await load();
  }

  async function submitCard(form: FormData) {
    if (!workspace) return;
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
    setMessage(error ? "Não foi possível adicionar o cartão." : "Cartão adicionado.");
    await load();
  }

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
    setMessage(error ? "Não foi possível registrar a compra." : "Compra registrada.");
    await load();
  }

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;
  const nav = <nav className="quick-actions"><Link className="quick-link" href="/">Painel</Link><Link className="quick-link" href="/contas">Contas</Link><Link className="quick-link" href="/cartoes">Cartões</Link><Link className="quick-link" href="/movimentacoes">Movimentações</Link><Link className="quick-link" href="/categorias">Categorias</Link><Link className="quick-link" href="/planejamento">Planejamento</Link><button className="quick-link" onClick={signOut}>Sair</button></nav>;
  const header = (title: string, subtitle: string) => <header className="management-header"><Link href="/" aria-label="Voltar">←</Link><div><p className="eyebrow">{workspace.name}</p><h1>{title}</h1><p className="muted">{subtitle}</p></div></header>;
  const notice = message ? <p className="form-success">{message}</p> : null;

  if (route === "accounts") return <main className="management-page">{header("Suas contas", "Organize onde seu dinheiro está.")}{nav}{notice}<section className="management-grid"><List title="Contas ativas">{accounts.map(a => <article className="account-row" key={a.id}><span>🏦</span><div><strong>{a.name}</strong><small>{a.type}</small></div><b>{money(a.initial_balance)}</b></article>)}</List><aside className="form-card"><h2>Adicionar conta</h2><SimpleForm onSubmit={submitAccount}><input name="name" placeholder="Nome da conta" required/><select name="type" defaultValue="checking"><option value="checking">Conta bancária</option><option value="cash">Dinheiro</option><option value="savings">Poupança</option><option value="credit_card">Cartão</option><option value="investment">Investimento</option></select><input name="initial_balance" defaultValue="0,00" required/><button>Adicionar</button></SimpleForm></aside></section></main>;
  if (route === "categories") return <main className="management-page">{header("Categorias", "Classifique receitas e despesas.")}{nav}{notice}<section className="management-grid"><List title="Categorias">{categories.map(c => <article className="account-row" key={c.id}><span style={{ color: c.color || undefined }}>●</span><div><strong>{c.name}</strong><small>{c.kind}</small></div></article>)}</List><aside className="form-card"><h2>Nova categoria</h2><SimpleForm onSubmit={submitCategory}><input name="name" placeholder="Nome" required/><select name="kind" defaultValue="expense"><option value="expense">Despesa</option><option value="income">Receita</option></select><input name="color" type="color" defaultValue="#087f5b"/><button>Criar</button></SimpleForm></aside></section></main>;
  if (route === "transactions") return <main className="management-page">{header("Movimentações", "Registre entradas, saídas e transferências.")}{nav}{notice}<section className="management-grid"><List title="Últimos lançamentos">{transactions.map(t => <article className="account-row" key={t.id}><span>{t.type === "income" ? "↑" : "↓"}</span><div><strong>{t.description}</strong><small>{t.competence_date}</small></div><b>{money(t.amount)}</b></article>)}</List><aside className="form-card"><h2>Nova movimentação</h2><SimpleForm onSubmit={submitTransaction}><select name="type" defaultValue="expense"><option value="expense">Despesa</option><option value="income">Receita</option><option value="transfer">Transferência</option></select><input name="amount" placeholder="0,00" required/><select name="account_id" required><option value="">Conta</option>{accounts.map(a => <option key={a.id} value={a.id}>{a.name}</option>)}</select><select name="category_id"><option value="">Categoria</option>{categories.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select><select name="destination_account_id"><option value="">Destino se transferência</option>{accounts.map(a => <option key={a.id} value={a.id}>{a.name}</option>)}</select><input name="description" placeholder="Descrição"/><input name="competence_date" type="date" defaultValue={new Date().toISOString().slice(0,10)} required/><button>Salvar</button></SimpleForm></aside></section></main>;
  if (route === "cards") return <main className="management-page">{header("Cartões", "Limites e vencimentos em um só lugar.")}{nav}{notice}<section className="management-grid"><List title="Cartões ativos">{cards.map(c => <article className="account-row" key={c.id}><span>💳</span><div><strong>{c.name}{c.last_four ? ` • ${c.last_four}` : ""}</strong><small>{c.brand || "Cartão"} · fecha {c.closing_day} · vence {c.due_day}</small></div><b>{money(c.credit_limit)}</b></article>)}</List><aside className="form-card"><h2>Adicionar cartão</h2><SimpleForm onSubmit={submitCard}><select name="account_id" required><option value="">Conta vinculada</option>{accounts.filter(a => a.type === "credit_card").map(a => <option key={a.id} value={a.id}>{a.name}</option>)}</select><input name="name" placeholder="Nome do cartão" required/><input name="brand" placeholder="Bandeira"/><input name="last_four" placeholder="Final"/><input name="credit_limit" placeholder="0,00" required/><input name="closing_day" type="number" min="1" max="31" placeholder="Fecha dia" required/><input name="due_day" type="number" min="1" max="31" placeholder="Vence dia" required/><button>Adicionar</button></SimpleForm></aside></section><section className="account-list"><h2>Faturas</h2>{invoices.map(inv => { const card = cards.find(c => c.id === inv.credit_card_id); const items = inv.credit_card_installments || []; const total = items.reduce((s, i) => s + Number(i.amount), 0); return <article className="invoice-card" key={inv.id}><header><strong>{card?.name || "Cartão"} · vence {date.format(new Date(`${inv.due_date}T12:00:00`))}</strong><b>{money(total)}</b><span data-status={inv.status}>{inv.status === "paid" ? "Paga" : "Em aberto"}</span></header><ul>{items.map((i, n) => { const p = Array.isArray(i.credit_card_purchases) ? i.credit_card_purchases[0] : i.credit_card_purchases; return <li key={n}><span>{p?.description || "Compra"} · {i.installment_number}/{p?.installment_count || 1}</span><b>{money(i.amount)}</b></li>; })}</ul></article>; })}</section></main>;
  if (route === "card") { const card = cards.find(c => c.id === cardId); return <main className="management-page">{header(card?.name || "Cartão", "Faturas e compras.")}{nav}{notice}<section className="management-grid"><List title="Faturas">{invoices.map(inv => { const items = inv.credit_card_installments || []; const total = items.reduce((s, i) => s + Number(i.amount), 0); return <article className="invoice-card" key={inv.id}><header><strong>Vence {date.format(new Date(`${inv.due_date}T12:00:00`))}</strong><b>{money(total)}</b><span data-status={inv.status}>{inv.status === "paid" ? "Paga" : "Em aberto"}</span></header><ul>{items.map((i, n) => { const p = Array.isArray(i.credit_card_purchases) ? i.credit_card_purchases[0] : i.credit_card_purchases; return <li key={n}><span>{p?.description || "Compra"} · {i.installment_number}/{p?.installment_count || 1}</span><b>{money(i.amount)}</b></li>; })}</ul></article>; })}</List><aside className="form-card"><h2>Nova compra</h2><SimpleForm onSubmit={submitPurchase}><input name="description" placeholder="Descrição" required/><input name="total_amount" placeholder="0,00" required/><input name="purchased_on" type="date" defaultValue={new Date().toISOString().slice(0,10)} required/><input name="installment_count" type="number" min="1" max="120" defaultValue="1" required/><select name="category_id"><option value="">Sem categoria</option>{categories.filter(c => c.kind === "expense").map(c => <option key={c.id} value={c.id}>{c.name}</option>)}</select><input name="notes" placeholder="Observação"/><button>Registrar</button></SimpleForm></aside></section></main>; }
  if (route === "commitments" || route === "planning" || route === "settings") return <main className="management-page">{header(route === "commitments" ? "Compromissos" : route === "planning" ? "Planejamento" : "Configurações", "Esta área já está pronta para export estático.")}{nav}<div className="empty-state"><h3>Próximo ajuste</h3><p>Vamos religar os formulários avançados desta tela em modo client-side.</p></div></main>;
  const totalCards = cards.reduce((sum, c) => sum + Number(c.credit_limit), 0);
  const balance = accounts.reduce((sum, a) => sum + Number(a.initial_balance), 0);
  return <main className="dashboard-shell"><section className="hero-card"><p className="eyebrow">BS Financeiro</p><h1>Seu painel financeiro</h1><p className="muted">Dados carregados direto do Supabase, compatível com GitHub Pages.</p>{nav}</section><section className="summary-grid"><article><span>Saldo inicial</span><strong>{money(balance)}</strong></article><article><span>Cartões</span><strong>{cards.length}</strong></article><article><span>Limite total</span><strong>{money(totalCards)}</strong></article></section><section className="management-grid"><List title="Cartões">{cards.map(c => <article className="account-row" key={c.id}><span>💳</span><div><strong>{c.name}</strong><small>Vence dia {c.due_day}</small></div><b>{money(c.credit_limit)}</b></article>)}</List><List title="Movimentações recentes">{transactions.slice(0,8).map(t => <article className="account-row" key={t.id}><span>{t.type === "income" ? "↑" : "↓"}</span><div><strong>{t.description}</strong><small>{t.competence_date}</small></div><b>{money(t.amount)}</b></article>)}</List></section></main>;
}

function List({ title, children }: { title: string; children: React.ReactNode }) {
  return <div className="account-list"><h2>{title}</h2>{children || <p className="muted">Nada por aqui ainda.</p>}</div>;
}

function SimpleForm({ children, onSubmit }: { children: React.ReactNode; onSubmit: (form: FormData) => Promise<void> }) {
  const [pending, setPending] = useState(false);
  return <form className="finance-form" onSubmit={async e => { e.preventDefault(); setPending(true); await onSubmit(new FormData(e.currentTarget)); setPending(false); }}>{children}<fieldset disabled={pending} /></form>;
}
