"use client";

import Link from "next/link";
import { ChevronDown, CircleAlert, DollarSign, Plus, PiggyBank, Target, TrendingDown, WalletCards } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { currentMonthStart, useMonth } from "./components/MonthContext";
import { MonthPicker } from "./components/MonthPicker";
import { money } from "./components/Money";
import { DashboardChart } from "./components/DashboardChart";
import { QuickTransactionForm } from "./components/QuickTransactionForm";
import { useCurrentUser } from "./components/useCurrentUser";
import { createClient } from "@/lib/supabase/client";
import { appPath } from "@/lib/app-path";
import { aggregateExpensesByCategory, computeMonthlyFlow, lastNMonths } from "@/lib/finance/aggregations";
import { generateInsights } from "@/lib/finance/insights";

const ASSET_TYPE_LABEL: Record<string, string> = {
  stock: "Ações",
  reit: "FIIs",
  fund: "Fundos",
  fixed_income: "Renda fixa",
  real_estate: "Imóveis",
};

type InvestmentAsset = { id: string; type: string };
type InvestmentOperation = { asset_id: string; operation_type: "buy" | "sell"; quantity: number; unit_price: number };

export function DashboardPage() {
  const { ownerId, workspace, accounts, transactions, categories, goals, defaultCashAccountId, loading, reload } = useFinance("dashboard");
  const { month, nextMonth } = useMonth();
  const { displayName, initials } = useCurrentUser();
  const supabase = useMemo(() => createClient(), []);
  const [quickTransactionStatus, setQuickTransactionStatus] = useState("");
  const [openQuickForm, setOpenQuickForm] = useState(false);
  const [Dialog, setDialog] = useState<React.ElementType | null>(null);
  const [assets, setAssets] = useState<InvestmentAsset[]>([]);
  const [operations, setOperations] = useState<InvestmentOperation[]>([]);

  const loadInvestments = useCallback(async () => {
    if (!workspace) return;
    const [{ data: assetRows }, { data: operationRows }] = await Promise.all([
      supabase.from("investment_assets").select("id,type").eq("workspace_id", workspace.id).eq("active", true),
      supabase.from("investment_operations").select("asset_id,operation_type,quantity,unit_price").eq("workspace_id", workspace.id),
    ]);
    setAssets(assetRows ?? []);
    setOperations(operationRows ?? []);
  }, [supabase, workspace]);

  useEffect(() => {
    void loadInvestments();
  }, [loadInvestments]);

  const investments = useMemo(() => {
    // ponytail: custo investido (compras - vendas), não valor de mercado —
    // evoluir pra cotação atual quando o dashboard também consumir investment_quotes.
    const principalByAsset = new Map<string, number>();
    for (const op of operations) {
      const amount = op.quantity * op.unit_price * (op.operation_type === "buy" ? 1 : -1);
      principalByAsset.set(op.asset_id, (principalByAsset.get(op.asset_id) ?? 0) + amount);
    }
    const byType = new Map<string, number>();
    for (const asset of assets) {
      const principal = principalByAsset.get(asset.id) ?? 0;
      if (principal <= 0) continue;
      byType.set(asset.type, (byType.get(asset.type) ?? 0) + principal);
    }
    const allocation = Array.from(byType, ([type, value]) => ({ label: ASSET_TYPE_LABEL[type] ?? type, value }))
      .sort((a, b) => b.value - a.value);
    const total = allocation.reduce((sum, item) => sum + item.value, 0);
    return { allocation, total };
  }, [assets, operations]);

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
    const uncategorizedCount = monthTransactions.filter(
      (t) => !t.category_id && (t.type === "expense" || t.type === "income"),
    ).length;
    // useFinance("dashboard") retorna o histórico completo paginado (não mais
    // truncado às 30 mais recentes), em ordem crescente de competência — para
    // exibir "recentes" é preciso ordenar decrescente antes de recortar.
    const recentTransactions = [...transactions]
      .sort((a, b) => (a.competence_date < b.competence_date ? 1 : a.competence_date > b.competence_date ? -1 : 0))
      .slice(0, 5);

    const { months: evolutionMonths, labels: evolutionLabels } = lastNMonths(12);
    const { flowIn, flowOut } = computeMonthlyFlow(transactions, evolutionMonths, { categories });

    return {
      balance,
      monthIncome,
      monthExpense,
      expensesByCategory,
      insights,
      uncategorizedCount,
      recentTransactions,
      evolutionLabels,
      flowIn,
      flowOut,
    };
  }, [accounts, categories, transactions, month, nextMonth]);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function reloadAfterQuickTransaction() {
    setQuickTransactionStatus("Movimentação registrada.");
    setOpenQuickForm(false);
    await reload();
  }

  async function signOut() {
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  return <main className="dashboard-shell">
    <Nav />

    <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px', flexWrap: 'wrap', gap: '16px' }}>
      <div>
        <h1 style={{ fontSize: '1.75rem', margin: '0 0 4px' }}>Olá, {displayName}! 👋</h1>
        <p className="muted" style={{ margin: '0 0 16px' }}>Aqui está o resumo das suas finanças</p>
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

        <button
          type="button"
          onClick={() => void signOut()}
          title="Sair da conta"
          style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '8px 16px', background: 'var(--surface)', borderRadius: '100px', border: '1px solid var(--border)', boxShadow: '0 2px 10px rgba(0,0,0,0.02)', cursor: 'pointer' }}
        >
          <div style={{ width: '32px', height: '32px', borderRadius: '50%', background: 'var(--primary)', color: 'var(--bg)', display: 'grid', placeItems: 'center', fontWeight: 'bold', fontSize: '14px' }}>
            {initials}
          </div>
          <span style={{ fontWeight: 600, fontSize: '0.95rem' }}>{displayName}</span>
          <ChevronDown size={16} className="muted" />
        </button>
      </div>
    </div>

    {quickTransactionStatus ? <p className="form-success" role="status">{quickTransactionStatus}</p> : null}
    {ownerId && openQuickForm && Dialog ? (
      <Dialog open={openQuickForm} onClose={() => setOpenQuickForm(false)} title="Nova movimentação rápida">
        <QuickTransactionForm workspaceId={workspace.id} ownerId={ownerId} defaultCashAccountId={defaultCashAccountId} accounts={accounts} categories={categories} onSubmitStart={() => setQuickTransactionStatus("")} onSaved={reloadAfterQuickTransaction} />
      </Dialog>
    ) : null}

    {metrics.uncategorizedCount > 0 ? (
      <Link href="/categorias" className="insight-link" style={{ marginBottom: "16px" }}>
        <span>
          <CircleAlert aria-hidden="true" size={16} style={{ marginRight: 6, verticalAlign: "-2px" }} />
          {metrics.uncategorizedCount} lançamento{metrics.uncategorizedCount > 1 ? "s" : ""} sem categoria este mês
          <small>Categorize para relatórios e insights precisos</small>
        </span>
        <ChevronDown aria-hidden="true" />
      </Link>
    ) : null}

    <div className="bento-row" style={{ gridTemplateColumns: 'repeat(4, 1fr)' }}>
      <article className="metric-card metric-card--positive">
        <WalletCards size={32} opacity={0.5} style={{ marginBottom: 16 }} />
        <span className="muted">Patrimônio líquido</span>
        <strong>{money(metrics.balance + investments.total)}</strong>
      </article>
      <article className="metric-card">
        <DollarSign size={32} opacity={0.5} style={{ marginBottom: 16 }} />
        <span className="muted">Receitas do mês</span>
        <strong>{money(metrics.monthIncome)}</strong>
      </article>
      <article className="metric-card metric-card--negative">
        <TrendingDown size={32} opacity={0.5} style={{ marginBottom: 16 }} />
        <span className="muted">Despesas do mês</span>
        <strong>{money(metrics.monthExpense)}</strong>
      </article>
      <article className="metric-card">
        <PiggyBank size={32} opacity={0.5} style={{ marginBottom: 16 }} />
        <span className="muted">Investimentos</span>
        <strong>{money(investments.total)}</strong>
      </article>
    </div>

    <div className="dashboard-bento-grid">
      <div className="bento-main">
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Evolução do patrimônio</h3>
          <p className="muted" style={{ marginBottom: '24px' }}>Ganhos e gastos nos últimos 12 meses.</p>
          <div className="chart-wrap" style={{ height: '300px' }}>
            <DashboardChart
              type="line"
              labels={metrics.evolutionLabels}
              series={[
                { label: "Ganhos", values: metrics.flowIn, color: "var(--accent)" },
                { label: "Gastos", values: metrics.flowOut, color: "var(--gold)" },
              ]}
            />
          </div>
        </article>
      </div>

      <div className="bento-sidebar">
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Alocação de investimentos</h3>
          <div className="chart-wrap" style={{ height: '220px' }}>
            {investments.allocation.length ? (
              <DashboardChart type="doughnut" label="Investimentos" labels={investments.allocation.map((item) => item.label)} values={investments.allocation.map((item) => item.value)} color="var(--accent)" />
            ) : (
              <p className="dashboard-empty">Nenhum investimento cadastrado. <Link href="/investimentos">Cadastrar ativo</Link></p>
            )}
          </div>
        </article>
      </div>
    </div>

    <div className="dashboard-bento-grid" style={{ marginTop: '24px', gridTemplateColumns: '1fr 1fr' }}>
      <article className="dashboard-card">
        <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}><Target size={18} aria-hidden="true" style={{ marginRight: 6, verticalAlign: '-3px' }} />Metas</h3>
        <div className="insight-list">
          {goals.length ? goals.slice(0, 4).map((goal) => {
            const percent = Number(goal.target_amount) > 0 ? Math.min(100, (Number(goal.current_amount) / Number(goal.target_amount)) * 100) : 0;
            return (
              <Link href="/planejamento" className="insight-link" key={goal.id} style={{ flexDirection: 'column', alignItems: 'stretch', gap: 6 }}>
                <span style={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
                  {goal.name}
                  <small>{money(goal.current_amount)} de {money(goal.target_amount)}</small>
                </span>
                <div style={{ height: 6, borderRadius: 999, background: 'var(--border)', overflow: 'hidden' }}>
                  <div style={{ height: '100%', width: `${percent}%`, background: 'var(--accent)', borderRadius: 999 }} />
                </div>
              </Link>
            );
          }) : <p className="dashboard-empty">Crie uma meta para acompanhar seu progresso.</p>}
        </div>
      </article>

      <article className="dashboard-card">
        <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Transações Recentes</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {metrics.recentTransactions.map(t => (
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
          {!metrics.recentTransactions.length && <p className="muted">Nenhuma transação recente.</p>}
        </div>
      </article>
    </div>
  </main>;
}
