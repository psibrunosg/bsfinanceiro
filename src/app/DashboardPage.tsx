"use client";

import Link from "next/link";
import { CircleAlert, Target, TrendingUp, TrendingDown, Wallet, ArrowRightLeft } from "lucide-react";
import { useMemo, useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { money, monthStart, nextMonthStart, parseMoney } from "./components/Money";
import { DashboardChart } from "./components/DashboardChart";
import { SimpleForm } from "./components/SimpleForm";
import { useToast } from "./components/Toast";
import { todayInSaoPaulo } from "@/lib/finance/local-date";
import { createClient } from "@/lib/supabase/client";
import { aggregateExpensesByCategory, computeEvolution, computeMonthlyFlow, lastNMonths } from "@/lib/finance/aggregations";
import { generateInsights } from "@/lib/finance/insights";

export function DashboardPage() {
  const { ownerId, workspace, accounts, cards, transactions, categories, budgets = [], goals, monthSpent = {}, commitments = [], occurrences = [], invoices = [], defaultCashAccountId, loading, reload } = useFinance("dashboard");
  const [openQuickForm, setOpenQuickForm] = useState(false);
  const [Dialog, setDialog] = useState<React.ElementType | null>(null);
  const { toast } = useToast();
  const supabase = useMemo(() => createClient(), []);

  const metrics = useMemo(() => {
    const currentMonth = monthStart();
    const nextMonth = nextMonthStart();
    const expenses = transactions.filter((t) => t.type === "expense");
    const income = transactions.filter((t) => t.type === "income");
    const monthIncome = income.filter((t) => t.competence_date >= currentMonth && t.competence_date < nextMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const monthExpense = expenses.filter((t) => t.competence_date >= currentMonth && t.competence_date < nextMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const initialBalance = accounts.reduce((sum, item) => sum + Number(item.initial_balance), 0);
    const paidIncome = income.filter((t) => t.status === "paid" || t.competence_date < currentMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const paidExpenses = expenses.filter((t) => t.status === "paid" || t.competence_date < currentMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const balance = initialBalance + paidIncome - paidExpenses;

    const { months, labels } = lastNMonths(6);
    const { flowIn, flowOut } = computeMonthlyFlow(transactions, months);
    const evolution = computeEvolution(transactions, initialBalance, months);
    const monthTransactions = transactions.filter((t) => t.competence_date >= currentMonth && t.competence_date < nextMonth);
    const expensesByCategory = aggregateExpensesByCategory(monthTransactions, categories, currentMonth, 5);
    const insights = generateInsights(transactions, categories, accounts, currentMonth);

    return { balance, monthIncome, monthExpense, months: labels, evolution, expensesByCategory, flowIn, flowOut, insights };
  }, [accounts, categories, transactions]);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function submitTransaction(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const type = String(form.get("type"));
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace?.id, owner_id: userData.user?.id, type, amount: parseMoney(form.get("amount")), account_id: form.get("account_id"),
      category_id: type === "transfer" ? null : form.get("category_id") || null, destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
      description: form.get("description") || (type === "transfer" ? "Transferência" : "Movimentação"), competence_date: form.get("competence_date"), paid_at: form.get("competence_date"), status: "paid", idempotency_key: crypto.randomUUID(),
    });
    if (error) {
      toast("Não foi possível salvar.", "error");
      return false;
    } else {
      toast("Movimentação registrada.");
      await reload();
      return true;
    }
  }

  const alerts = [
    ...occurrences.filter((item) => item.status !== "paid").slice(0, 2).map((item) => ({ href: "/gastos?tab=recorrentes", title: item.description, text: `Vence em ${new Date(`${item.due_date}T12:00:00`).toLocaleDateString("pt-BR")}` })),
    ...invoices.slice(0, 1).map((item) => ({ href: "/cartoes", title: "Fatura de cartão", text: `Vence em ${new Date(`${item.due_date}T12:00:00`).toLocaleDateString("pt-BR")}` })),
    ...budgets.filter((budget) => (monthSpent[budget.category_id] || 0) >= Number(budget.amount) * .8).slice(0, 1).map(() => ({ href: "/planejamento", title: "Orçamento perto do limite", text: "Revise seus gastos deste mês" })),
  ].slice(0, 3);
  const invoicesTotal = invoices.reduce((sum, invoice) => sum + (invoice.credit_card_installments || []).reduce((inner, installment) => inner + Number(installment.amount), 0), 0);

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Painel"
        subtitle="Visão financeira consolidada."
        workspaceName={workspace.name}
        action={{
          label: "Nova movimentação",
          onClick: () => {
            if (!Dialog) import("./components/Dialog").then(m => setDialog(() => m.Dialog));
            setOpenQuickForm(true);
          }
        }}
      />

      <section className="hub-overview">
        <article className="metric-card metric-card--positive">
          <Wallet aria-hidden="true" />
          <strong>{money(metrics.balance)}</strong>
          <span className="muted">Saldo disponível</span>
        </article>
        <article className="metric-card">
          <TrendingUp aria-hidden="true" style={{ color: "var(--positive)" }} />
          <strong>{money(metrics.monthIncome)}</strong>
          <span className="muted">Entradas do mês</span>
        </article>
        <article className="metric-card">
          <TrendingDown aria-hidden="true" style={{ color: "var(--danger)" }} />
          <strong>{money(metrics.monthExpense)}</strong>
          <span className="muted">Saídas do mês</span>
        </article>
        <article className="metric-card">
          <ArrowRightLeft aria-hidden="true" style={{ color: metrics.monthIncome >= metrics.monthExpense ? "var(--positive)" : "var(--warning)" }} />
          <strong>{money(metrics.monthIncome - metrics.monthExpense)}</strong>
          <span className="muted">Resultado do mês</span>
        </article>
      </section>

      <section className="dashboard-columns" style={{ marginTop: "var(--space-5)" }}>
        <article className="dashboard-card">
          <h3>Fluxo de caixa</h3>
          <div className="chart-wrap">
            <DashboardChart type="bar" label="Entradas" labels={metrics.months} values={metrics.flowIn} color="var(--positive)" />
          </div>
        </article>

        <article className="dashboard-card">
          <h3>Gastos por categoria (Mês atual)</h3>
          <div className="chart-wrap">
            {metrics.expensesByCategory.length ? (
              <DashboardChart type="doughnut" label="Gastos" labels={metrics.expensesByCategory.map((item) => item.label)} values={metrics.expensesByCategory.map((item) => item.value)} color="var(--danger)" />
            ) : (
              <p className="dashboard-empty">Registre despesas para ver categorias.</p>
            )}
          </div>
        </article>

        <article className="dashboard-card">
          <h3>Evolução do saldo</h3>
          <div className="chart-wrap">
            <DashboardChart type="line" label="Saldo" labels={metrics.months} values={metrics.evolution} color="var(--accent)" />
          </div>
        </article>

        <article className="dashboard-card">
          <h3><CircleAlert aria-hidden="true" size={18} style={{ display: 'inline', verticalAlign: 'text-bottom' }} /> Alertas e pendências</h3>
          <div className="insight-list" style={{ marginTop: "1rem", display: "grid", gap: "0.5rem" }}>
            {metrics.insights.length ? (
              metrics.insights.map((insight) => (
                <div className="insight-link" key={insight.id} style={{ display: 'flex', gap: '0.5rem', padding: '0.75rem', background: 'var(--surface-2)', borderRadius: 'var(--radius-sm)' }}>
                  <span>{insight.icon} {insight.text}</span>
                </div>
              ))
            ) : alerts.length ? (
              alerts.map((alert) => (
                <Link href={alert.href} key={`${alert.href}-${alert.title}`} style={{ display: 'flex', justifyContent: 'space-between', padding: '0.75rem', background: 'var(--surface-2)', borderRadius: 'var(--radius-sm)', textDecoration: 'none', color: 'inherit' }}>
                  <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <strong style={{ fontSize: '0.9rem' }}>{alert.title}</strong>
                    <small className="muted">{alert.text}</small>
                  </div>
                  <span style={{ color: 'var(--accent)' }}>&rarr;</span>
                </Link>
              ))
            ) : (
              <p className="dashboard-empty" style={{ margin: 0, padding: '1rem' }}>Nenhuma pendência urgente.</p>
            )}
          </div>
        </article>

        <article className="dashboard-card" style={{ gridColumn: '1 / -1' }}>
          <h3>Metas financeiras em andamento</h3>
          <div className="insight-list" style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '1rem', marginTop: '1rem' }}>
            {goals.length ? goals.slice(0, 4).map((goal) => (
              <Link href="/planejamento" key={goal.id} style={{ padding: '1rem', background: 'var(--surface-2)', borderRadius: 'var(--radius-sm)', textDecoration: 'none', color: 'inherit', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', flexDirection: 'column' }}>
                  <strong style={{ fontSize: '0.95rem' }}>{goal.name}</strong>
                  <small className="muted">{money(goal.current_amount)} de {money(goal.target_amount)}</small>
                </div>
                <Target aria-hidden="true" style={{ color: 'var(--accent)', opacity: 0.8 }} />
              </Link>
            )) : <p className="dashboard-empty">Crie uma meta para acompanhar seu progresso.</p>}
          </div>
        </article>
      </section>

      {ownerId && openQuickForm && Dialog && (
        <Dialog open={openQuickForm} onClose={() => setOpenQuickForm(false)} title="Nova movimentação">
          <SimpleForm onSubmit={async (form) => {
            if (await submitTransaction(form)) setOpenQuickForm(false);
          }}>
            <label htmlFor="transaction-type">Tipo de movimentação</label>
            <select id="transaction-type" name="type" defaultValue="expense">
              <option value="expense">Despesa</option>
              <option value="income">Receita</option>
              <option value="transfer">Transferência</option>
            </select>
            <label htmlFor="transaction-description">Descrição</label>
            <input id="transaction-description" name="description" placeholder="Ex: Mercado, Salário" required autoFocus />
            <label htmlFor="transaction-amount">Valor</label>
            <input id="transaction-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="transaction-account">Conta</label>
            <select id="transaction-account" name="account_id" defaultValue={defaultCashAccountId || ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}
            </select>
            <label htmlFor="transaction-category">Categoria</label>
            <select id="transaction-category" name="category_id">
              <option value="">Sem categoria</option>
              {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
            <label htmlFor="transaction-date">Data</label>
            <input id="transaction-date" name="competence_date" type="date" defaultValue={todayInSaoPaulo()} required />
            <button>Registrar</button>
          </SimpleForm>
        </Dialog>
      )}
    </main>
  );
}
