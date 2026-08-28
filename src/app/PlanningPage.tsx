"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, cents, dateFmt, monthStart } from "./components/Money";
import { calculateBudgetConsumption, calculateGoalProgress } from "@/lib/finance/budget";
import { Suspense, useEffect, useMemo } from "react";
import { useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { Flag, PieChart, Target } from "lucide-react";
import { GoalPlannerWidget } from "./components/GoalPlannerWidget";
import { ScenarioSimulatorWidget } from "./components/ScenarioSimulatorWidget";
import { ZeroBasedBudgetWidget } from "./components/ZeroBasedBudgetWidget";

function PlanningPageInner() {
  const searchParams = useSearchParams();
  const focus = searchParams.get("focus");
  const goalId = searchParams.get("goalId");
  const { workspace, categories, budgets, goals, monthSpent, loading, message, setMessage, reload } = useFinance("planning");
  const supabase = useMemo(() => createClient(), []);

  useEffect(() => {
    if (!loading && focus === "choose-goal" && goals.length > 1) document.getElementById("goals-list")?.focus();
  }, [focus, goals.length, loading]);

  if (loading || !workspace) return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;

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
    if (initial > 0) {
      const { error: contributionError } = await supabase.from("goal_contributions").insert({ workspace_id: workspace.id, owner_id: userData.user?.id, financial_goal_id: goal.id, amount: initial, note: "Saldo inicial", idempotency_key: crypto.randomUUID() });
      if (contributionError) {
        setMessage("Não foi possível registrar o saldo inicial da meta.");
        await reload();
        return;
      }
    }
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
    <main className="dashboard-shell">
      <PageHeader title="Planejamento" subtitle="Orçamento do mês e metas financeiras." workspaceName={workspace.name} />
      <Nav />
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}
      {focus === "choose-goal" && goals.length > 1 && <p className="form-success" role="status">Escolha uma meta abaixo para registrar o aporte.</p>}
      <section className="bento-row" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))' }}>
        <List title="Orçamento do mês">
          {budgets.length === 0 && <p className="dashboard-empty">Nenhum orçamento definido para este mês.</p>}
          {budgets.map((b) => {
            const cat = categories.find((c) => c.id === b.category_id);
            const c = calculateBudgetConsumption(cents(b.amount), cents(monthSpent[b.category_id] || 0));
            const barModifier = c.status === "exceeded" ? " progress-bar--danger" : c.status === "attention" ? " progress-bar--warning" : "";
            return (
              <article className="account-row" key={b.id} style={{ flexDirection: 'column', alignItems: 'stretch', gap: '10px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', gap: '12px' }}>
                  <span className="tx-row__body">
                    <strong>
                      <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: cat?.color || "#8B5CF6", width: 26, height: 26, borderRadius: 8, display: 'inline-grid', marginRight: 8, verticalAlign: '-8px' }}>
                        <PieChart size={14} aria-hidden="true" />
                      </span>
                      {cat?.name || "Categoria"}
                    </strong>
                    <small data-status={c.status}>{statusLabel[c.status]} · {c.consumedPercentage.toFixed(0)}% · resta {money(c.remainingCents / 100)}</small>
                  </span>
                  <b style={{ whiteSpace: 'nowrap' }}>{money(monthSpent[b.category_id] || 0)} / {money(b.amount)}</b>
                </div>
                <div className={`progress-bar${barModifier}`}>
                  <span style={{ width: `${Math.min(100, c.consumedPercentage)}%` }} />
                </div>
              </article>
            );
          })}
        </List>
        <aside className="dashboard-card">
          <h3>Definir orçamento</h3>
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

      {goals.length > 0 && (
        <div style={{ marginTop: '24px' }}>
          <GoalPlannerWidget goals={goals} />
        </div>
      )}

      <div style={{ marginTop: '24px' }}>
        <ScenarioSimulatorWidget />
      </div>

      <div style={{ marginTop: '24px' }}>
        <ZeroBasedBudgetWidget />
      </div>

      <section className="bento-row" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))' }}>
        <div id="goals-list" tabIndex={-1}>
        <List title="Metas">
          {goals.length === 0 && <p className="dashboard-empty">Nenhuma meta financeira criada.</p>}
          {goals.map((g) => {
            const p = calculateGoalProgress(cents(g.target_amount), cents(g.current_amount));
            return (
              <div className="goal-row" key={g.id}>
                <div className="goal-row__top">
                  <span>
                    {p.completed ? <Flag size={16} aria-hidden="true" style={{ verticalAlign: '-3px', marginRight: 6 }} /> : <Target size={16} aria-hidden="true" style={{ verticalAlign: '-3px', marginRight: 6 }} />}
                    {g.name}
                    <br />
                    <small>{money(g.current_amount)} de {money(g.target_amount)}{g.deadline ? ` · até ${dateFmt.format(new Date(`${g.deadline}T12:00:00`))}` : ""}</small>
                  </span>
                  <span className="goal-row__percent">{p.progressPercentage.toFixed(0)}%</span>
                </div>
                <div className="goal-row__bar">
                  <div className="goal-row__bar-fill" style={{ width: `${Math.min(100, p.progressPercentage)}%` }} />
                </div>
                <SimpleForm onSubmit={(form) => submitContribution(g.id, form)}>
                  <label htmlFor={`goal-${g.id}-amount`}>Aporte</label>
                  <input id={`goal-${g.id}-amount`} name="amount" placeholder="Aporte" required autoFocus={focus === "goal-contribution" && goals.length === 1 && (!goalId || goalId === g.id)} />
                  <button>Aportar</button>
                </SimpleForm>
              </div>
            );
          })}
        </List>
        </div>
        <aside className="dashboard-card">
          <h3>Nova meta</h3>
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
    </main>
  );
}

export function PlanningPage() {
  return <Suspense fallback={<main className="dashboard-shell"><p className="muted">Carregando...</p></main>}><PlanningPageInner /></Suspense>;
}
