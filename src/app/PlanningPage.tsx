"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, cents, dateFmt, monthStart } from "./components/Money";
import { calculateBudgetConsumption, calculateGoalProgress } from "@/lib/finance/budget";
import { createClient } from "@/lib/supabase/client";
import { useMemo } from "react";

export function PlanningPage() {
  const { workspace, categories, budgets, goals, monthSpent, loading, message, setMessage, reload } = useFinance("planning");
  const supabase = useMemo(() => createClient(), []);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  const expenseCategories = categories.filter((c) => c.kind === "expense");
  const statusLabel: Record<string, string> = { ok: "No limite", attention: "Atenção", exceeded: "Estourou" };

  async function submitBudget(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("monthly_budgets").upsert({ workspace_id: workspace.id, owner_id: userData.user?.id, category_id: form.get("category_id"), category_kind: "expense", month: monthStart(), amount: parseMoney(form.get("amount")) }, { onConflict: "workspace_id,owner_id,category_id,month" });
    setMessage(error ? "Não foi possível salvar o orçamento." : "Orçamento salvo.");
    await reload();
  }

  async function submitGoal(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const initial = parseMoney(form.get("current_amount"));
    const { data: goal, error } = await supabase.from("financial_goals").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, name: form.get("name"), target_amount: parseMoney(form.get("target_amount")), current_amount: 0, deadline: form.get("deadline") || null, status: "active" }).select("id").single();
    if (error || !goal) { setMessage("Não foi possível criar a meta."); return; }
    if (initial > 0) await supabase.from("goal_contributions").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, financial_goal_id: goal.id, amount: initial, note: "Saldo inicial", idempotency_key: crypto.randomUUID() });
    setMessage("Meta criada.");
    await reload();
  }

  async function submitContribution(goalId: string, form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("goal_contributions").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, financial_goal_id: goalId, amount: parseMoney(form.get("amount")), idempotency_key: crypto.randomUUID() });
    setMessage(error ? "Não foi possível registrar o aporte." : "Aporte registrado.");
    await reload();
  }

  return (
    <main className="management-page">
      <PageHeader title="Planejamento" subtitle="Orçamento do mês e metas financeiras." workspaceName={workspace.name} />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      <section className="management-grid">
        <List title="Orçamento do mês">
          {budgets.length === 0 && <p className="muted">Nenhum orçamento definido para este mês.</p>}
          {budgets.map((b) => {
            const cat = categories.find((c) => c.id === b.category_id);
            const c = calculateBudgetConsumption(cents(b.amount), cents(monthSpent[b.category_id] || 0));
            return (
              <article className="account-row" key={b.id}>
                <span style={{ color: cat?.color || undefined }}>●</span>
                <div>
                  <strong>{cat?.name || "Categoria"}</strong>
                  <small data-status={c.status}>{statusLabel[c.status]} · {c.consumedPercentage.toFixed(0)}% · resta {money(c.remainingCents / 100)}</small>
                </div>
                <b>{money(monthSpent[b.category_id] || 0)} / {money(b.amount)}</b>
              </article>
            );
          })}
        </List>
        <aside className="form-card">
          <h2>Definir orçamento</h2>
          <SimpleForm onSubmit={submitBudget}>
            <select name="category_id" required>
              <option value="">Categoria de despesa</option>
              {expenseCategories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
            <input name="amount" placeholder="0,00" required />
            <button>Salvar</button>
          </SimpleForm>
        </aside>
      </section>
      <section className="management-grid">
        <List title="Metas">
          {goals.length === 0 && <p className="muted">Nenhuma meta financeira criada.</p>}
          {goals.map((g) => {
            const p = calculateGoalProgress(cents(g.target_amount), cents(g.current_amount));
            return (
              <article className="account-row" key={g.id}>
                <span>{p.completed ? "🏁" : "🎯"}</span>
                <div>
                  <strong>{g.name}</strong>
                  <small>{p.progressPercentage.toFixed(0)}% · {money(g.current_amount)} de {money(g.target_amount)}{g.deadline ? ` · até ${dateFmt.format(new Date(`${g.deadline}T12:00:00`))}` : ""}</small>
                  <form className="finance-form" onSubmit={async (e) => { e.preventDefault(); const f = new FormData(e.currentTarget); e.currentTarget.reset(); await submitContribution(g.id, f); }}>
                    <input name="amount" placeholder="Aporte" required />
                    <button>Aportar</button>
                  </form>
                </div>
                <b>{p.progressPercentage.toFixed(0)}%</b>
              </article>
            );
          })}
        </List>
        <aside className="form-card">
          <h2>Nova meta</h2>
          <SimpleForm onSubmit={submitGoal}>
            <input name="name" placeholder="Nome da meta" required />
            <input name="target_amount" placeholder="Valor alvo" required />
            <input name="current_amount" placeholder="Saldo inicial (opcional)" defaultValue="0,00" />
            <input name="deadline" type="date" />
            <button>Criar meta</button>
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
