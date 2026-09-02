"use client";

import { useMemo, useState } from "react";
import { TrendingUp, TrendingDown, Wallet } from "lucide-react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { MonthPicker } from "./components/MonthPicker";
import { useMonth } from "./components/MonthContext";
import { DashboardChart } from "./components/DashboardChart";
import { money, dateFmt } from "./components/Money";
import { computeEvolution, computeMonthlyFlow } from "@/lib/finance/aggregations";
import { filterOutTransfers } from "@/lib/finance/transfers";
import { addMonths, monthLabel } from "@/lib/finance/local-date";
import { CoupleFinanceWidget } from "./components/CoupleFinanceWidget";
import { FinancialCalendarWidget } from "./components/FinancialCalendarWidget";
import { TaxReport } from "./components/TaxReport";
import { CustomPeriodReport } from "./components/CustomPeriodReport";
import { ShareReportButton } from "./components/ShareReportButton";
import { CsvExportButton } from "./components/CsvExportButton";
import { AnnualWrappedWidget } from "./components/AnnualWrappedWidget";
import { TravelSandboxWidget } from "./components/TravelSandboxWidget";

const COMPARISON_MONTHS = 12;

export function ReportsPage() {
  const { workspace, transactions, categories, accounts, loading } = useFinance("dashboard");
  const { month, label, setMonth } = useMonth();
  const [tab, setTab] = useState<"mes" | "comparativo" | "custom" | "ir">("mes");

  const clean = useMemo(() => filterOutTransfers(transactions, categories), [transactions, categories]);

  const monthReport = useMemo(() => {
    const previousMonth = addMonths(month, -1);
    const inRange = (date: string, from: string) => date >= from && date < addMonths(from, 1);
    const names = new Map(categories.map((category) => [category.id, category.name]));
    const nameOf = (categoryId?: string | null) => names.get(String(categoryId ?? "")) || "Sem categoria";

    const current = clean.filter((t) => inRange(t.competence_date, month));
    const income = current.filter((t) => t.type === "income").reduce((sum, t) => sum + Number(t.amount), 0);
    const expenses = current.filter((t) => t.type === "expense");
    const expense = expenses.reduce((sum, t) => sum + Number(t.amount), 0);

    const previousByCategory = new Map<string, number>();
    for (const t of clean) {
      if (t.type !== "expense" || !inRange(t.competence_date, previousMonth)) continue;
      const key = nameOf(t.category_id);
      previousByCategory.set(key, (previousByCategory.get(key) ?? 0) + Number(t.amount));
    }

    const grouped = new Map<string, { total: number; items: typeof expenses }>();
    for (const t of expenses) {
      const key = nameOf(t.category_id);
      const group = grouped.get(key) ?? { total: 0, items: [] };
      group.total += Number(t.amount);
      group.items.push(t);
      grouped.set(key, group);
    }

    const rows = [...grouped.entries()]
      .map(([name, group]) => {
        const before = previousByCategory.get(name) ?? 0;
        return {
          name,
          total: group.total,
          share: expense > 0 ? (group.total / expense) * 100 : 0,
          delta: before > 0 ? ((group.total - before) / before) * 100 : null,
          items: [...group.items].sort((a, b) => a.competence_date.localeCompare(b.competence_date)),
        };
      })
      .sort((a, b) => b.total - a.total);

    return { income, expense, rows };
  }, [clean, categories, month]);

  const comparison = useMemo(() => {
    const starts = Array.from({ length: COMPARISON_MONTHS }, (_, index) =>
      addMonths(month, -(COMPARISON_MONTHS - 1 - index)),
    );
    const dates = starts.map((start) => new Date(`${start}T12:00:00`));
    const initialBalance = accounts.reduce((sum, account) => sum + Number(account.initial_balance), 0);
    const { flowIn, flowOut } = computeMonthlyFlow(clean, dates, { excludeTransfers: false });
    return {
      starts,
      labels: starts.map(monthLabel),
      flowIn,
      flowOut,
      evolution: computeEvolution(clean, initialBalance, dates),
    };
  }, [clean, accounts, month]);

  if (loading || !workspace) return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader title="Relatórios" subtitle="Seus gastos mês a mês, agrupados por categoria" workspaceName={workspace.name} />

      <div className="dashboard-card no-print" style={{ display: "flex", gap: "1rem", marginBottom: "1rem", alignItems: "center" }}>
        <strong>Exportar dados:</strong>
        <CsvExportButton transactions={clean} categories={categories} />
        <button type="button" onClick={() => window.print()} className="secondary-button">Salvar PDF</button>
        <ShareReportButton workspaceId={workspace.id} />
      </div>

      <div className="hub-filters">
        <MonthPicker />
        <span className="muted">Competência: {label}</span>
      </div>

      <nav className="hub-tabs" aria-label="Abas de relatórios">
        <button type="button" aria-pressed={tab === "mes"} onClick={() => setTab("mes")} className={tab === "mes" ? "active" : ""}>Mês</button>
        <button type="button" aria-pressed={tab === "comparativo"} onClick={() => setTab("comparativo")} className={tab === "comparativo" ? "active" : ""}>Comparativo</button>
        <button type="button" aria-pressed={tab === "custom"} onClick={() => setTab("custom")} className={tab === "custom" ? "active" : ""}>Período Personalizado</button>
        <button type="button" aria-pressed={tab === "ir"} onClick={() => setTab("ir")} className={tab === "ir" ? "active" : ""}>Imposto de Renda</button>
      </nav>

      {tab === "mes" && (
        <section>
          <div className="bento-row" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
            <article className="metric-card metric-card--positive">
              <div className="metric-card__head">
                <span className="muted">Entradas</span>
                <span className="metric-icon-badge" style={{ background: "rgba(34,197,94,.15)", color: "#22C55E" }}><TrendingUp size={18} aria-hidden="true" /></span>
              </div>
              <strong>{money(monthReport.income)}</strong>
            </article>
            <article className="metric-card metric-card--negative">
              <div className="metric-card__head">
                <span className="muted">Saídas</span>
                <span className="metric-icon-badge" style={{ background: "rgba(239,68,68,.15)", color: "#EF4444" }}><TrendingDown size={18} aria-hidden="true" /></span>
              </div>
              <strong>{money(monthReport.expense)}</strong>
            </article>
            <article className="metric-card">
              <div className="metric-card__head">
                <span className="muted">Saldo do mês</span>
                <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}><Wallet size={18} aria-hidden="true" /></span>
              </div>
              <strong>{money(monthReport.income - monthReport.expense)}</strong>
            </article>
          </div>

          <article className="dashboard-card" style={{ marginTop: 18 }}>
            <h3>Gastos por categoria em {label}</h3>
            {monthReport.rows.length ? monthReport.rows.map((row) => (
              <details className="report-row" key={row.name}>
                <summary>
                  <span>{row.name}</span>
                  <span className="report-row__figures">
                    <strong>{money(row.total)}</strong>
                    <small className="muted">{row.share.toFixed(1).replace(".", ",")}% do mês</small>
                    <small className={row.delta === null ? "muted" : row.delta > 0 ? "report-delta--up" : "report-delta--down"}>
                      {row.delta === null ? "sem base anterior" : `${row.delta > 0 ? "+" : ""}${row.delta.toFixed(1).replace(".", ",")}% vs. mês anterior`}
                    </small>
                  </span>
                </summary>
                <ul className="report-row__items">
                  {row.items.map((item) => (
                    <li key={item.id}>
                      <span>{dateFmt.format(new Date(`${item.competence_date}T12:00:00`))} · {item.description || "Sem descrição"}</span>
                      <strong>{money(item.amount)}</strong>
                    </li>
                  ))}
                </ul>
              </details>
            )) : <p className="dashboard-empty">Nenhuma despesa registrada em {label}.</p>}
          </article>

          <div style={{ marginTop: '24px' }}>
            <CoupleFinanceWidget transactions={transactions} currentMonth={month} />
          </div>

          <div style={{ marginTop: '24px' }}>
            <FinancialCalendarWidget transactions={transactions} currentMonth={month} />
          </div>

          <div style={{ marginTop: '24px' }}>
            <AnnualWrappedWidget transactions={transactions} year={parseInt(month.slice(0, 4), 10) || 2026} />
          </div>

          <div style={{ marginTop: '24px' }}>
            <TravelSandboxWidget />
          </div>
        </section>
      )}

      {tab === "comparativo" && (
        <section>
          <div className="dashboard-bento-grid" style={{ gridTemplateColumns: 'repeat(3, 1fr)' }}>
            <article className="dashboard-card">
              <h3>Entradas por mês</h3>
              <div className="chart-wrap"><DashboardChart type="bar" label="Entradas" labels={comparison.labels} values={comparison.flowIn} color="var(--positive-color)" /></div>
            </article>
            <article className="dashboard-card">
              <h3>Saídas por mês</h3>
              <div className="chart-wrap"><DashboardChart type="bar" label="Saídas" labels={comparison.labels} values={comparison.flowOut} color="var(--danger-color)" /></div>
            </article>
            <article className="dashboard-card">
              <h3>Evolução do saldo</h3>
              <div className="chart-wrap"><DashboardChart type="line" label="Saldo" labels={comparison.labels} values={comparison.evolution} color="var(--accent)" /></div>
            </article>
          </div>

          <article className="dashboard-card" style={{ marginTop: 18 }}>
            <h3>Abrir o detalhe de um mês</h3>
            <p className="muted">Escolha um mês para ver o relatório por categoria.</p>
            <div className="hub-filters">
              {comparison.starts.map((start, index) => (
                <button
                  type="button"
                  key={start}
                  className={start === month ? "active" : ""}
                  onClick={() => { setMonth(start); setTab("mes"); }}
                >
                  {comparison.labels[index]} · {money(comparison.flowOut[index])}
                </button>
              ))}
            </div>
          </article>
        </section>
      )}
      {tab === "custom" && (
        <section>
          <CustomPeriodReport transactions={clean} categories={categories} />
        </section>
      )}

      {tab === "ir" && (
        <section>
          <TaxReport transactions={clean} categories={categories} />
        </section>
      )}
    </main>

  );
}
