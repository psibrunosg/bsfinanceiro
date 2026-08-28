"use client";

import Link from "next/link";
import { ArrowDownRight, ArrowUpRight, ChevronDown, CircleAlert, DollarSign, PiggyBank, Receipt, Target, TrendingDown, Utensils, WalletCards } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { currentMonthStart, useMonth } from "./components/MonthContext";
import { MonthPicker } from "./components/MonthPicker";
import { money } from "./components/Money";
import { DashboardChart } from "./components/DashboardChart";
import { UserMenu } from "./components/UserMenu";
import { useCurrentUser } from "./components/useCurrentUser";
import { createClient } from "@/lib/supabase/client";
import { addMonths } from "@/lib/finance/local-date";
import { aggregateExpensesByCategory, computeMonthlyFlow, lastNMonths } from "@/lib/finance/aggregations";
import { generateInsights } from "@/lib/finance/insights";
import { InterestRadarWidget } from "./components/InterestRadarWidget";
import { SubscriptionHubWidget } from "./components/SubscriptionHubWidget";
import { InstallmentTimelineWidget } from "./components/InstallmentTimelineWidget";
import { MicroExpenseRadarWidget } from "./components/MicroExpenseRadarWidget";
import { HealthScoreWidget } from "./components/HealthScoreWidget";
import { DebtPayoffWidget } from "./components/DebtPayoffWidget";
import { GoalPlannerWidget } from "./components/GoalPlannerWidget";
import { TaxRadarWidget } from "./components/TaxRadarWidget";
import { ClinicBusinessWidget } from "./components/ClinicBusinessWidget";

const ASSET_TYPE_LABEL: Record<string, string> = {
  stock: "Ações",
  reit: "FIIs",
  fund: "Fundos",
  fixed_income: "Renda fixa",
  real_estate: "Imóveis",
};

const DONUT_COLORS = ["#8B5CF6", "#3B82F6", "#F97316", "#F5A623", "#22C55E"];

type InvestmentAsset = { id: string; type: string };
type InvestmentOperation = { asset_id: string; operation_type: "buy" | "sell"; quantity: number; unit_price: number; operation_date: string };

function Trend({ pct }: { pct: number | null }) {
  if (pct === null) return null;
  const up = pct >= 0;
  return (
    <span className={`metric-card__trend ${up ? "up" : "down"}`}>
      {up ? <ArrowUpRight size={14} aria-hidden="true" /> : <ArrowDownRight size={14} aria-hidden="true" />}
      {up ? "+" : ""}{pct.toFixed(1)}% esse mês
    </span>
  );
}

export function DashboardPage() {
  const { workspace, accounts, transactions, invoices, categories, goals, loading } = useFinance("dashboard");
  const { month, nextMonth } = useMonth();
  const { displayName } = useCurrentUser();
  const supabase = useMemo(() => createClient(), []);
  const [assets, setAssets] = useState<InvestmentAsset[]>([]);
  const [operations, setOperations] = useState<InvestmentOperation[]>([]);

  const loadInvestments = useCallback(async () => {
    if (!workspace) return;
    const [{ data: assetRows }, { data: operationRows }] = await Promise.all([
      supabase.from("investment_assets").select("id,type").eq("workspace_id", workspace.id).eq("active", true),
      supabase.from("investment_operations").select("asset_id,operation_type,quantity,unit_price,operation_date").eq("workspace_id", workspace.id),
    ]);
    setAssets(assetRows ?? []);
    setOperations(operationRows ?? []);
  }, [supabase, workspace]);

  useEffect(() => {
    void loadInvestments();
  }, [loadInvestments]);

  const investedAsOf = useCallback(
    (cutoff: string | null) => {
      // ponytail: custo investido (compras - vendas), não valor de mercado —
      // evoluir pra cotação atual quando o dashboard também consumir investment_quotes.
      const principalByAsset = new Map<string, number>();
      for (const op of operations) {
        if (cutoff && op.operation_date >= cutoff) continue;
        const amount = op.quantity * op.unit_price * (op.operation_type === "buy" ? 1 : -1);
        principalByAsset.set(op.asset_id, (principalByAsset.get(op.asset_id) ?? 0) + amount);
      }
      const byType = new Map<string, number>();
      for (const asset of assets) {
        const principal = principalByAsset.get(asset.id) ?? 0;
        if (principal <= 0) continue;
        byType.set(asset.type, (byType.get(asset.type) ?? 0) + principal);
      }
      return byType;
    },
    [assets, operations],
  );

  const investments = useMemo(() => {
    const byType = investedAsOf(null);
    const allocation = Array.from(byType, ([type, value]) => ({ label: ASSET_TYPE_LABEL[type] ?? type, value }))
      .sort((a, b) => b.value - a.value);
    const total = allocation.reduce((sum, item) => sum + item.value, 0);
    const prevTotal = Array.from(investedAsOf(month).values()).reduce((sum, v) => sum + v, 0);
    const trend = prevTotal > 0 ? ((total - prevTotal) / prevTotal) * 100 : null;
    return { allocation, total, trend };
  }, [investedAsOf, month]);

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

    const prevMonth = addMonths(month, -1);
    const prevMonthIncome = income.filter((t) => t.competence_date >= prevMonth && t.competence_date < month).reduce((sum, t) => sum + Number(t.amount), 0);
    const prevMonthExpense = expenses.filter((t) => t.competence_date >= prevMonth && t.competence_date < month).reduce((sum, t) => sum + Number(t.amount), 0);
    const incomeTrend = prevMonthIncome > 0 ? ((monthIncome - prevMonthIncome) / prevMonthIncome) * 100 : null;
    const expenseTrend = prevMonthExpense > 0 ? ((monthExpense - prevMonthExpense) / prevMonthExpense) * 100 : null;
    const netFlow = monthIncome - monthExpense;
    const balanceAtMonthStart = balance - netFlow;
    const balanceTrend = balanceAtMonthStart !== 0 ? (netFlow / Math.abs(balanceAtMonthStart)) * 100 : null;

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
    const monthFmt = new Intl.DateTimeFormat("pt-BR", { month: "short" });
    const evolutionTooltipTitles = evolutionMonths.map((d) => {
      const month = monthFmt.format(d).replace(".", "");
      return `${month.charAt(0).toUpperCase()}${month.slice(1)} ${d.getFullYear()}`;
    });

    return {
      balance,
      monthIncome,
      monthExpense,
      incomeTrend,
      expenseTrend,
      balanceTrend,
      expensesByCategory,
      insights,
      uncategorizedCount,
      recentTransactions,
      evolutionLabels,
      evolutionTooltipTitles,
      flowIn,
      flowOut,
    };
  }, [accounts, categories, transactions, month, nextMonth]);

  if (loading || !workspace) return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;

  return <main className="dashboard-shell">
    <Nav />

    <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '20px' }}>
      <UserMenu />
    </div>

    <div className="page-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px', flexWrap: 'wrap', gap: '16px' }}>
      <div>
        <h1 style={{ fontSize: '1.75rem', margin: '0 0 4px' }}>Olá, {displayName}!</h1>
        <p className="muted" style={{ margin: 0 }}>Aqui está o resumo das suas finanças</p>
      </div>
      <MonthPicker />
    </div>

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
        <div className="metric-card__head">
          <span className="muted">Patrimônio líquido</span>
          <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}><WalletCards size={18} aria-hidden="true" /></span>
        </div>
        <strong>{money(metrics.balance + investments.total)}</strong>
        <Trend pct={metrics.balanceTrend} />
      </article>
      <article className="metric-card">
        <div className="metric-card__head">
          <span className="muted">Receitas</span>
          <span className="metric-icon-badge" style={{ background: "rgba(34,197,94,.15)", color: "#22C55E" }}><DollarSign size={18} aria-hidden="true" /></span>
        </div>
        <strong>{money(metrics.monthIncome)}</strong>
        <Trend pct={metrics.incomeTrend} />
      </article>
      <article className="metric-card metric-card--negative">
        <div className="metric-card__head">
          <span className="muted">Despesas</span>
          <span className="metric-icon-badge" style={{ background: "rgba(239,68,68,.15)", color: "#EF4444" }}><TrendingDown size={18} aria-hidden="true" /></span>
        </div>
        <strong>{money(metrics.monthExpense)}</strong>
        <Trend pct={metrics.expenseTrend === null ? null : -metrics.expenseTrend} />
      </article>
      <article className="metric-card">
        <div className="metric-card__head">
          <span className="muted">Investimentos</span>
          <span className="metric-icon-badge" style={{ background: "rgba(245,166,35,.15)", color: "#F5A623" }}><PiggyBank size={18} aria-hidden="true" /></span>
        </div>
        <strong>{money(investments.total)}</strong>
        <Trend pct={investments.trend} />
      </article>
    </div>

    <div className="dashboard-bento-grid">
      <div className="bento-main">
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '2px', fontSize: '1.2rem' }}>Evolução do patrimônio</h3>
          <p className="muted" style={{ marginBottom: '16px', fontSize: '.85rem' }}>Últimos 12 meses</p>
          <div className="chart-wrap" style={{ height: '280px' }}>
            <DashboardChart
              type="line"
              labels={metrics.evolutionLabels}
              tooltipTitles={metrics.evolutionTooltipTitles}
              legend={false}
              compactY
              series={[
                { label: "Ganhos", values: metrics.flowIn, color: "#8B5CF6" },
                { label: "Gastos", values: metrics.flowOut, color: "#F5A623" },
              ]}
            />
          </div>
          <div className="chart-legend">
            <span className="chart-legend__item"><span className="chart-legend__dot" style={{ background: "#8B5CF6" }} />Ganhos</span>
            <span className="chart-legend__item"><span className="chart-legend__dot" style={{ background: "#F5A623" }} />Gastos</span>
          </div>
        </article>
      </div>

      <div className="bento-sidebar">
        <article className="dashboard-card">
          <h3 style={{ marginBottom: '2px', fontSize: '1.2rem' }}>Alocação de investimentos</h3>
          {investments.allocation.length > 0 && <p className="muted" style={{ marginBottom: '16px', fontSize: '.85rem' }}>Total: {money(investments.total)}</p>}
          {investments.allocation.length ? (
            <div className="donut-layout" style={{ height: '200px' }}>
              <div className="chart-wrap">
                <DashboardChart type="doughnut" label="Investimentos" legend={false} labels={investments.allocation.map((item) => item.label)} values={investments.allocation.map((item) => item.value)} color="var(--accent)" />
              </div>
              <div className="donut-legend">
                {investments.allocation.map((item, index) => (
                  <span className="donut-legend__item" key={item.label}>
                    <span className="chart-legend__dot" style={{ background: DONUT_COLORS[index % DONUT_COLORS.length] }} />
                    {item.label}
                    <strong>{investments.total > 0 ? Math.round((item.value / investments.total) * 100) : 0}%</strong>
                  </span>
                ))}
              </div>
            </div>
          ) : (
            <p className="dashboard-empty">Nenhum investimento cadastrado. <Link href="/investimentos">Cadastrar ativo</Link></p>
          )}
        </article>
      </div>
    </div>

    <div style={{ marginTop: '24px' }}>
      <HealthScoreWidget
        monthlyIncome={metrics.monthIncome}
        monthlyExpenses={metrics.monthExpense}
        availableCash={metrics.balance}
        investedTotal={investments.total}
      />
    </div>

    <div style={{ marginTop: '24px' }}>
      <InterestRadarWidget transactions={transactions} currentMonth={month} />
    </div>

    <div style={{ marginTop: '24px' }}>
      <SubscriptionHubWidget transactions={transactions} />
    </div>

    <div style={{ marginTop: '24px' }}>
      <InstallmentTimelineWidget invoices={invoices} transactions={transactions} currentMonth={month} />
    </div>

    <div style={{ marginTop: '24px' }}>
      <MicroExpenseRadarWidget transactions={transactions} currentMonth={month} />
    </div>

    <div style={{ marginTop: '24px' }}>
      <DebtPayoffWidget accounts={accounts} invoices={invoices} transactions={transactions} currentMonth={month} />
    </div>

    {goals.length > 0 && (
      <div style={{ marginTop: '24px' }}>
        <GoalPlannerWidget goals={goals} currentMonth={month} />
      </div>
    )}

    <div style={{ marginTop: '24px' }}>
      <TaxRadarWidget transactions={transactions} currentMonth={month} />
    </div>

    <div style={{ marginTop: '24px' }}>
      <ClinicBusinessWidget transactions={transactions} currentMonth={month} />
    </div>

    <div className="dashboard-bento-grid" style={{ marginTop: '24px', gridTemplateColumns: '1fr 1fr' }}>
      <article className="dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
          <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Metas</h3>
          <Target size={18} aria-hidden="true" className="muted" />
        </div>
        <div>
          {goals.length ? goals.slice(0, 4).map((goal) => {
            const percent = Number(goal.target_amount) > 0 ? Math.min(100, (Number(goal.current_amount) / Number(goal.target_amount)) * 100) : 0;
            return (
              <div className="goal-row" key={goal.id}>
                <div className="goal-row__top">
                  <span>{goal.name}<br /><small>{money(goal.current_amount)} de {money(goal.target_amount)}</small></span>
                  <span className="goal-row__percent">{percent.toFixed(1)}%</span>
                </div>
                <div className="goal-row__bar"><div className="goal-row__bar-fill" style={{ width: `${percent}%` }} /></div>
              </div>
            );
          }) : <p className="dashboard-empty">Crie uma meta para acompanhar seu progresso.</p>}
        </div>
      </article>

      <article className="dashboard-card">
        <h3 style={{ marginBottom: '16px', fontSize: '1.2rem' }}>Transações recentes</h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {metrics.recentTransactions.map(t => {
            const isExpense = t.type === 'expense';
            const category = categories.find((c) => c.id === t.category_id)?.name ?? (t.type === 'income' ? 'Receita' : 'Sem categoria');
            return (
              <div key={t.id} className="tx-row">
                <span className="tx-icon-badge" style={isExpense ? { background: "rgba(239,68,68,.15)", color: "#EF4444" } : { background: "rgba(34,197,94,.15)", color: "#22C55E" }}>
                  {isExpense ? <Utensils size={16} aria-hidden="true" /> : <Receipt size={16} aria-hidden="true" />}
                </span>
                <span className="tx-row__body">
                  <strong>{t.description}</strong>
                  <small>{category}</small>
                </span>
                <span className="tx-row__amount" style={{ color: isExpense ? 'var(--danger)' : 'var(--positive)' }}>
                  {isExpense ? '-' : '+'}{money(Number(t.amount))}
                </span>
              </div>
            );
          })}
          {!metrics.recentTransactions.length && <p className="muted">Nenhuma transação recente.</p>}
        </div>
      </article>
    </div>
  </main>;
}
