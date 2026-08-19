"use client";

import Link from "next/link";
import { ChevronDown, CircleAlert, Plus, Target, WalletCards } from "lucide-react";
import { useMemo, useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { currentMonthStart, useMonth } from "./components/MonthContext";
import { MonthPicker } from "./components/MonthPicker";
import { money } from "./components/Money";
import { DashboardChart } from "./components/DashboardChart";
import { QuickTransactionForm } from "./components/QuickTransactionForm";
import { aggregateExpensesByCategory, computeDailyDecision } from "@/lib/finance/aggregations";
import { generateInsights } from "@/lib/finance/insights";

export function DashboardPage() {
  const { ownerId, workspace, accounts, transactions, categories, defaultCashAccountId, loading, reload } = useFinance("dashboard");
  const { month, nextMonth } = useMonth();
  const [quickTransactionStatus, setQuickTransactionStatus] = useState("");
  const [openQuickForm, setOpenQuickForm] = useState(false);
  const [Dialog, setDialog] = useState<React.ElementType | null>(null);

  const metrics = useMemo(() => {
    // Saldo real depende do mês corrente de verdade ("tudo antes de hoje está liquidado"),
    // não do mês que o usuário está navegando.
    const realMonth = currentMonthStart();
    const expenses = transactions.filter((t) => t.type === "expense");
    const income = transactions.filter((t) => t.type === "income");
    const monthIncome = income.filter((t) => t.competence_date >= month && t.competence_date < nextMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const monthExpense = expenses.filter((t) => t.competence_date >= month && t.competence_date < nextMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const initialBalance = accounts.reduce((sum, item) => sum + Number(item.initial_balance), 0);
    const paidIncome = income.filter((t) => t.status === "paid" || t.competence_date < realMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const paidExpenses = expenses.filter((t) => t.status === "paid" || t.competence_date < realMonth).reduce((sum, t) => sum + Number(t.amount), 0);
    const balance = initialBalance + paidIncome - paidExpenses;

    const monthTransactions = transactions.filter((t) => t.competence_date >= month && t.competence_date < nextMonth);
    const expensesByCategory = aggregateExpensesByCategory(monthTransactions, categories, month, 5, nextMonth);
    const insights = generateInsights(transactions, categories, accounts, month);

    return { balance, monthIncome, monthExpense, expensesByCategory, insights };
  }, [accounts, categories, transactions, month, nextMonth]);

  const dailyDecision = useMemo(() => {
    return computeDailyDecision(metrics.balance, 30);
  }, [metrics.balance]);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function reloadAfterQuickTransaction() {
    setQuickTransactionStatus("Movimentação registrada.");
    setOpenQuickForm(false);
    await reload();
  }

  return <main className="dashboard-shell">
    <Nav />
    
    <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
      <div>
        <p className="eyebrow">{workspace.name}</p>
        <h1 style={{ fontSize: '2rem', margin: '4px 0 16px' }}>Visão Global Financeira</h1>
        <MonthPicker />
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: '24px' }}>
        <button type="button" style={{ padding: '12px 24px', borderRadius: '12px', background: 'var(--primary)', color: 'var(--bg)', border: 'none', fontWeight: 600, display: 'flex', gap: '8px', alignItems: 'center', cursor: 'pointer' }} onClick={() => {
            if (!Dialog) import("./components/Dialog").then(m => setDialog(() => m.Dialog));
            setOpenQuickForm(true);
        }}>
          <Plus size={18} aria-hidden="true" />
          <span>Nova Movimentação</span>
        </button>

        <div className="user-profile-header" style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '8px 16px', background: 'var(--surface)', borderRadius: '100px', border: '1px solid var(--border)', boxShadow: '0 2px 10px rgba(0,0,0,0.02)' }}>
          <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'var(--primary)', color: 'var(--bg)', display: 'grid', placeItems: 'center', fontWeight: 'bold', fontSize: '14px' }}>
            {workspace?.name?.charAt(0).toUpperCase() || 'U'}
          </div>
          <span style={{ fontWeight: 600, fontSize: '0.95rem' }}>{workspace?.name || 'Usuário'}</span>
          <ChevronDown size={16} className="muted" />
        </div>
      </div>
    </div>

    {quickTransactionStatus ? <p className="form-success" role="status">{quickTransactionStatus}</p> : null}
    {ownerId && openQuickForm && Dialog ? (
      <Dialog open={openQuickForm} onClose={() => setOpenQuickForm(false)} title="Nova movimentação rápida">
        <QuickTransactionForm workspaceId={workspace.id} ownerId={ownerId} defaultCashAccountId={defaultCashAccountId} accounts={accounts} categories={categories} onSubmitStart={() => setQuickTransactionStatus("")} onSaved={reloadAfterQuickTransaction} />
      </Dialog>
    ) : null}

    <div className="dashboard-bento-grid">
      <div className="bento-main">
        <div className="bento-row">
          <article className="metric-card metric-card--positive">
            <WalletCards size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Saldo Atual</span>
            <strong>{money(metrics.balance)}</strong>
          </article>
          <article className="metric-card">
            <Target size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Entradas do Mês</span>
            <strong>{money(metrics.monthIncome)}</strong>
          </article>
          <article className="metric-card metric-card--negative">
            <CircleAlert size={32} opacity={0.5} style={{ marginBottom: 16 }} />
            <span className="muted">Saídas do Mês</span>
            <strong>{money(metrics.monthExpense)}</strong>
          </article>
        </div>

        <article className="dashboard-card" style={{ marginTop: '24px' }}>
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Evolução de Saldo Recomendado (30 dias)</h3>
          <p className="muted" style={{ marginBottom: '24px' }}>Baseado no teto diário de {money(dailyDecision.dailyLimit)} para manter o saldo positivo.</p>
          <div className="chart-wrap" style={{ height: '300px' }}>
            <DashboardChart type="line" label="Projeção" labels={dailyDecision.trajectory.map((item) => `Dia ${item.day}`)} values={dailyDecision.trajectory.map((item) => item.remaining)} color={dailyDecision.status === "critical" ? "#ef4444" : dailyDecision.status === "warning" ? "#f59e0b" : "#10b981"} />
          </div>
        </article>
      </div>

      <div className="bento-sidebar">
        <article className="dashboard-card" style={{ marginBottom: '24px' }}>
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Alocação de Gastos</h3>
          <div className="chart-wrap" style={{ height: '220px' }}>
            {metrics.expensesByCategory.length ? <DashboardChart type="doughnut" label="Gastos" labels={metrics.expensesByCategory.map((item) => item.label)} values={metrics.expensesByCategory.map((item) => item.value)} color="var(--accent)" /> : <p className="muted">Sem dados suficientes no mês.</p>}
          </div>
        </article>

        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Transações Recentes</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {transactions.slice(0, 5).map(t => (
              <div key={t.id} className="transaction-row" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', border: '1px solid var(--border)', borderRadius: '12px' }}>
                <div>
                  <div style={{ fontWeight: 600 }}>{t.description}</div>
                  <div className="muted" style={{ fontSize: '0.85rem' }}>{new Date(t.competence_date).toLocaleDateString('pt-BR')}</div>
                </div>
                <div style={{ fontWeight: 600, color: t.type === 'expense' ? 'var(--danger)' : 'var(--positive)' }}>
                  {t.type === 'expense' ? '-' : '+'}{money(Number(t.amount))}
                </div>
              </div>
            ))}
            {!transactions.length && <p className="muted">Nenhuma transação recente.</p>}
          </div>
        </article>
      </div>
    </div>
  </main>;
}
