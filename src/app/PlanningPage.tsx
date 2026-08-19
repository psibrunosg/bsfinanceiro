"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, cents, dateFmt, monthStart } from "./components/Money";
import { calculateBudgetConsumption, calculateGoalProgress } from "@/lib/finance/budget";
import { useToast } from "./components/Toast";
import { createClient } from "@/lib/supabase/client";
import { Suspense, useEffect, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";

type Tab = "budgets" | "goals";

function PlanningPageInner() {
  const searchParams = useSearchParams();
  const focus = searchParams.get("focus");
  const goalId = searchParams.get("goalId");
  const [tab, setTab] = useState<Tab>(() => 
    focus === "choose-goal" || focus === "new-goal" || focus === "goal-contribution" || goalId ? "goals" : "budgets"
  );

  const { workspace, categories, budgets, goals, monthSpent, loading, reload } = useFinance("planning");
  const { toast } = useToast();
  const supabase = useMemo(() => createClient(), []);

  useEffect(() => {
    if (!loading && focus === "choose-goal" && goals.length > 1) {
      setTab("goals");
      document.getElementById("goals-list")?.focus();
    }
  }, [focus, goals.length, loading]);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  const expenseCategories = categories.filter((c) => c.kind === "expense");
  const statusLabel: Record<string, string> = { ok: "No limite", attention: "Atenção", exceeded: "Estourou" };

  async function submitBudget(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("monthly_budgets").upsert({ workspace_id: workspace.id, owner_id: userData.user?.id, category_id: form.get("category_id"), category_kind: "expense", month: monthStart(), amount: parseMoney(form.get("amount")) }, { onConflict: "workspace_id,owner_id,category_id,month" });
    if (error) toast("Não foi possível salvar o orçamento.", "error");
    else toast("Orçamento salvo.");
    await reload();
  }

  async function submitGoal(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const initial = parseMoney(form.get("current_amount"));
    const { data: goal, error } = await supabase.from("financial_goals").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, name: form.get("name"), target_amount: parseMoney(form.get("target_amount")), current_amount: 0, deadline: form.get("deadline") || null, status: "active" }).select("id").single();
    if (error || !goal) { toast("Não foi possível criar a meta.", "error"); return; }
    if (initial > 0) {
      const { error: contributionError } = await supabase.from("goal_contributions").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, financial_goal_id: goal.id, amount: initial, note: "Saldo inicial", idempotency_key: crypto.randomUUID() });
      if (contributionError) {
        toast("Não foi possível registrar o saldo inicial da meta.", "error");
        await reload();
        return;
      }
    }
    toast("Meta criada.");
    await reload();
  }

  async function submitContribution(goalId: string, form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("goal_contributions").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, financial_goal_id: goalId, amount: parseMoney(form.get("amount")), idempotency_key: crypto.randomUUID() });
    if (error) toast("Não foi possível registrar o aporte.", "error");
    else toast("Aporte registrado.");
    await reload();
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader title="Planejamento" subtitle="Orçamento do mês e metas financeiras." workspaceName={workspace.name} />

      <nav className="hub-tabs" aria-label="Abas de planejamento" style={{ marginBottom: "1.5rem" }}>
        <button type="button" aria-pressed={tab === "budgets"} onClick={() => setTab("budgets")} className={tab === "budgets" ? "active" : ""}>Orçamentos</button>
        <button type="button" aria-pressed={tab === "goals"} onClick={() => setTab("goals")} className={tab === "goals" ? "active" : ""}>Metas</button>
      </nav>

      {tab === "budgets" && (
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
              <label htmlFor="budget-category">Categoria de despesa</label>
              <select id="budget-category" name="category_id" required>
                <option value="">Categoria de despesa</option>
                {expenseCategories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
              <label htmlFor="budget-amount">Valor</label>
              <input id="budget-amount" name="amount" placeholder="0,00" required />
              <button>Salvar</button>
            </SimpleForm>
          </aside>
        </section>
      )}

      {tab === "goals" && (
        <section className="management-grid">
          <div id="goals-list" tabIndex={-1} style={{ outline: 'none' }}>
            {focus === "choose-goal" && goals.length > 1 && <p className="form-success" role="status" style={{ marginBottom: "1rem" }}>Escolha uma meta abaixo para registrar o aporte.</p>}
            <List title="Metas ativas">
              {goals.length === 0 && <p className="muted">Nenhuma meta financeira criada.</p>}
              {goals.map((g) => {
                const p = calculateGoalProgress(cents(g.target_amount), cents(g.current_amount));
                return (
                  <article className="account-row" key={g.id}>
                    <span>{p.completed ? "🏁" : "🎯"}</span>
                    <div style={{ flex: 1 }}>
                      <strong>{g.name}</strong>
                      <small>{p.progressPercentage.toFixed(0)}% · {money(g.current_amount)} de {money(g.target_amount)}{g.deadline ? ` · até ${dateFmt.format(new Date(`${g.deadline}T12:00:00`))}` : ""}</small>
                      <SimpleForm onSubmit={(form) => submitContribution(g.id, form)}>
                        <label htmlFor={`goal-${g.id}-amount`}>Aporte</label>
                        <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'flex-end', marginTop: '0.5rem' }}>
                          <input id={`goal-${g.id}-amount`} name="amount" placeholder="Aporte" required autoFocus={focus === "goal-contribution" && goals.length === 1 && (!goalId || goalId === g.id)} style={{ margin: 0, flex: 1 }} />
                          <button style={{ margin: 0, padding: '0.5rem 1rem', width: 'auto' }}>Aportar</button>
                        </div>
                      </SimpleForm>
                    </div>
                  </article>
                );
              })}
            </List>
          </div>
          <aside className="form-card">
            <h2>Nova meta</h2>
            <SimpleForm onSubmit={submitGoal}>
              <label htmlFor="goal-name">Nome da meta</label>
              <input id="goal-name" name="name" placeholder="Nome da meta" required autoFocus={focus === "new-goal"} />
              <label htmlFor="goal-target">Valor alvo</label>
              <input id="goal-target" name="target_amount" placeholder="Valor alvo" required />
              <label htmlFor="goal-current">Saldo inicial</label>
              <input id="goal-current" name="current_amount" placeholder="Saldo inicial (opcional)" defaultValue="0,00" />
              <label htmlFor="goal-deadline">Prazo</label>
              <input id="goal-deadline" name="deadline" type="date" />
              <button>Criar meta</button>
            </SimpleForm>
          </aside>
        </section>
      )}
    </main>
  );
}

export function PlanningPage() {
  return <Suspense fallback={<main className="management-page"><p className="muted">Carregando...</p></main>}><PlanningPageInner /></Suspense>;
}
