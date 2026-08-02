"use client";

import Link from "next/link";
import { ChevronDown, CircleAlert, Target, WalletCards } from "lucide-react";
import { useMemo, useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { money, monthStart } from "./components/Money";
import { DashboardChart } from "./components/DashboardChart";
import { QuickTransactionForm } from "./components/QuickTransactionForm";
import { aggregateExpensesByCategory, computeEvolution, computeMonthlyFlow, lastNMonths } from "@/lib/finance/aggregations";

export function DashboardPage() {
  const { ownerId, workspace, accounts, cards, transactions, categories, budgets = [], goals, monthSpent = {}, commitments = [], occurrences = [], invoices = [], defaultCashAccountId, loading, reload } = useFinance("dashboard");
  const [quickTransactionStatus, setQuickTransactionStatus] = useState("");
  const [openQuickForm, setOpenQuickForm] = useState(false);
  const [Dialog, setDialog] = useState<React.ElementType | null>(null);

  const metrics = useMemo(() => {
    const currentMonth = monthStart();
    const expenses = transactions.filter((t) => t.type === "expense");
    const income = transactions.filter((t) => t.type === "income");
    const monthIncome = income.filter((t) => t.competence_date >= currentMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const monthExpense = expenses.filter((t) => t.competence_date >= currentMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const initialBalance = accounts.reduce((sum, item) => sum + Number(item.initial_balance), 0);
    const balance = initialBalance + income.reduce((sum, t) => sum + Number(t.amount), 0) - expenses.reduce((sum, t) => sum + Number(t.amount), 0);

    const { months, labels } = lastNMonths(6);
    const { flowIn, flowOut } = computeMonthlyFlow(transactions, months);
    const evolution = computeEvolution(transactions, initialBalance, months);
    const expensesByCategory = aggregateExpensesByCategory(transactions, categories, currentMonth, 5);

    return { balance, monthIncome, monthExpense, months: labels, evolution, expensesByCategory, flowIn, flowOut };
  }, [accounts, categories, transactions]);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function reloadAfterQuickTransaction() {
    setQuickTransactionStatus("Movimentação registrada.");
    setOpenQuickForm(false);
    await reload();
  }

  const alerts = [
    ...occurrences.filter((item) => item.status !== "paid").slice(0, 2).map((item) => ({ href: "/compromissos", title: item.description, text: `Vence em ${new Date(`${item.due_date}T12:00:00`).toLocaleDateString("pt-BR")}` })),
    ...invoices.slice(0, 1).map((item) => ({ href: "/cartoes", title: "Fatura de cartão", text: `Vence em ${new Date(`${item.due_date}T12:00:00`).toLocaleDateString("pt-BR")}` })),
    ...budgets.filter((budget) => (monthSpent[budget.category_id] || 0) >= Number(budget.amount) * .8).slice(0, 1).map(() => ({ href: "/planejamento", title: "Orçamento perto do limite", text: "Revise seus gastos deste mês" })),
  ].slice(0, 3);
  const invoicesTotal = invoices.reduce((sum, invoice) => sum + (invoice.credit_card_installments || []).reduce((inner, installment) => inner + Number(installment.amount), 0), 0);

  return <main className="dashboard-shell">
    <Nav />
    <section className="dashboard-hero">
      <div>
        <p className="eyebrow">{workspace.name}</p>
        <h1>Visão financeira completa</h1>
        <p className="muted">Decisões melhores, sem planilhas complicadas.</p>
        <button style={{ marginTop: '1rem', width: 'auto' }} onClick={() => {
            if (!Dialog) import("./components/Dialog").then(m => setDialog(() => m.Dialog));
            setOpenQuickForm(true);
        }}>+ Nova movimentação</button>
      </div>
      <WalletCards aria-hidden="true" size={42} />
    </section>
    
    {quickTransactionStatus ? <p className="form-success" role="status">{quickTransactionStatus}</p> : null}
    {ownerId && openQuickForm && Dialog ? (
      <Dialog open={openQuickForm} onClose={() => setOpenQuickForm(false)} title="Nova movimentação rápida">
        <QuickTransactionForm workspaceId={workspace.id} ownerId={ownerId} defaultCashAccountId={defaultCashAccountId} accounts={accounts} categories={categories} onSubmitStart={() => setQuickTransactionStatus("")} onSaved={reloadAfterQuickTransaction} />
      </Dialog>
    ) : null}

    <details className="dashboard-section" open><summary><div><p className="eyebrow">SAÚDE DO MÊS</p><strong>{money(metrics.balance)} disponível</strong></div><ChevronDown aria-hidden="true" /></summary><div className="dashboard-section__body">
      <div className="metric-grid"><article className="metric positive"><span>Entradas</span><strong>{money(metrics.monthIncome)}</strong></article><article className="metric"><span>Saídas</span><strong>{money(metrics.monthExpense)}</strong></article><article className="metric"><span>Saldo do mês</span><strong>{money(metrics.monthIncome - metrics.monthExpense)}</strong></article></div>
      <div className="dashboard-columns">
        <article className="dashboard-card"><h3>Gastos por categoria</h3><div className="chart-wrap">{metrics.expensesByCategory.length ? <DashboardChart type="doughnut" label="Gastos" labels={metrics.expensesByCategory.map((item) => item.label)} values={metrics.expensesByCategory.map((item) => item.value)} color="var(--accent)" /> : <p className="dashboard-empty">Registre despesas para ver categorias.</p>}</div></article>
        <article className="dashboard-card"><h3>Fluxo de caixa</h3><div className="chart-wrap"><DashboardChart type="bar" label="Entradas" labels={metrics.months} values={metrics.flowIn} color="var(--positive-color)" /></div></article>
        <article className="dashboard-card"><h3><CircleAlert aria-hidden="true" /> Atenção agora</h3><div className="insight-list">{alerts.length ? alerts.map((alert) => <Link className="insight-link" href={alert.href} key={`${alert.href}-${alert.title}`}><span>{alert.title}<small>{alert.text}</small></span><ChevronDown aria-hidden="true" /></Link>) : <p className="dashboard-empty">Nenhuma pendência urgente.</p>}</div></article>
      </div>
    </div></details>
    <details className="dashboard-section"><summary><div><p className="eyebrow">PATRIMÔNIO</p><strong>{accounts.length} contas e {cards.length} cartões</strong></div><ChevronDown aria-hidden="true" /></summary><div className="dashboard-section__body"><div className="metric-grid"><article className="metric"><span>Saldo real</span><strong>{money(metrics.balance)}</strong></article><article className="metric"><span>Limite de cartões</span><strong>{money(cards.reduce((sum, card) => sum + Number(card.credit_limit), 0))}</strong></article><article className="metric"><span>Faturas abertas</span><strong>{money(invoicesTotal)}</strong></article></div><article className="dashboard-card"><h3>Evolução do saldo</h3><div className="chart-wrap"><DashboardChart type="line" label="Saldo" labels={metrics.months} values={metrics.evolution} color="#087f5b" /></div><p className="chart-summary">Evolução calculada com contas e lançamentos registrados.</p></article></div></details>
    <details className="dashboard-section"><summary><div><p className="eyebrow">PLANEJAMENTO</p><strong>{goals.length} metas e {commitments.length} compromissos</strong></div><ChevronDown aria-hidden="true" /></summary><div className="dashboard-section__body"><div className="dashboard-columns"><article className="dashboard-card"><h3>Metas financeiras</h3><div className="insight-list">{goals.length ? goals.slice(0, 4).map((goal) => <Link href="/planejamento" className="insight-link" key={goal.id}><span>{goal.name}<small>{money(goal.current_amount)} de {money(goal.target_amount)}</small></span><Target aria-hidden="true" /></Link>) : <p className="dashboard-empty">Crie uma meta para acompanhar seu progresso.</p>}</div></article><article className="dashboard-card"><h3>Compromissos do mês</h3><div className="insight-list">{commitments.length ? commitments.slice(0, 4).map((item) => <Link href="/compromissos" className="insight-link" key={item.id}><span>{item.description}<small>Dia {item.due_day}</small></span><strong>{money(item.amount)}</strong></Link>) : <p className="dashboard-empty">Cadastre despesas recorrentes para planejar melhor.</p>}</div></article></div></div></details>
  </main>;
}
