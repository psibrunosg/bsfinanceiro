"use client";

import { useState, useMemo } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { money, monthStart } from "../components/Money";
import { DashboardChart } from "../components/DashboardChart";
import { aggregateExpensesByCategory } from "@/lib/finance/aggregations";
import { ReceiptText } from "lucide-react";

type Tab = "overview" | "launches" | "recurrent";

export default function GastosPage() {
  const { workspace, transactions, categories, loading } = useFinance("dashboard");
  const [tab, setTab] = useState<Tab>("overview");
  const [openDialog, setOpenDialog] = useState(false);

  const expenseData = useMemo(() => {
    const expenses = transactions.filter((t) => t.type === "expense");
    const totalExpenses = expenses.reduce((sum, t) => sum + Number(t.amount), 0);
    const byCategory = aggregateExpensesByCategory(transactions, categories, monthStart(), 5);
    return { expenses, totalExpenses, byCategory };
  }, [transactions, categories]);

  if (loading || !workspace) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Gastos"
        subtitle="Visao geral, lancamentos e recorrentes"
        workspaceName={workspace.name}
        action={{
          label: "Registrar gasto",
          onClick: () => setOpenDialog(true),
        }}
      />
      <nav className="hub-tabs" aria-label="Abas de gastos">
        <button type="button" aria-current={tab === "overview" ? "page" : undefined} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visao geral</button>
        <button type="button" aria-current={tab === "launches" ? "page" : undefined} onClick={() => setTab("launches")} className={tab === "launches" ? "active" : ""}>Lancamentos</button>
        <button type="button" aria-current={tab === "recurrent" ? "page" : undefined} onClick={() => setTab("recurrent")} className={tab === "recurrent" ? "active" : ""}>Recorrentes</button>
      </nav>

      {tab === "overview" && (
        <section className="hub-overview">
          <article className="metric-card metric-card--negative">
            <ReceiptText aria-hidden="true" />
            <strong>{money(expenseData.totalExpenses)}</strong>
            <span className="muted">Total gasto</span>
          </article>
          {expenseData.byCategory.length > 0 && (
            <article className="dashboard-card">
              <h3>Gastos por categoria</h3>
              <div className="chart-wrap">
                <DashboardChart
                  type="doughnut"
                  labels={expenseData.byCategory.map((item) => item.label)}
                  values={expenseData.byCategory.map((item) => item.value)}
                  label="Gastos"
                  color="var(--accent)"
                />
              </div>
            </article>
          )}
        </section>
      )}

      {tab === "launches" && (
        <section>
          {expenseData.expenses.length === 0 ? (
            <p className="muted">Nenhum gasto registrado ainda</p>
          ) : (
            <ul className="list">
              {expenseData.expenses.map((t) => (
                <li key={t.id}>
                  <span>{t.description}</span>
                  <strong>{money(t.amount)}</strong>
                </li>
              ))}
            </ul>
          )}
        </section>
      )}

      {tab === "recurrent" && (
        <section>
          <p className="muted">Compromissos fixos e gastos recorrentes aparecerao aqui</p>
        </section>
      )}

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Registrar gasto">
        <p className="muted">Formulario completo de gasto sera exibido aqui</p>
      </Dialog>
    </main>
  );
}
