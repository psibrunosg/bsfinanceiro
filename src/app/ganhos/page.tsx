"use client";

import { useState, useMemo } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { money } from "../components/Money";
import { DashboardChart } from "../components/DashboardChart";
import { aggregateIncomeBySource } from "@/lib/finance/aggregations";
import { TrendingUp } from "lucide-react";

type Tab = "overview" | "payslips" | "patients" | "other";

export default function GanhosPage() {
  const { workspace, transactions, categories, loading } = useFinance("dashboard");
  const [tab, setTab] = useState<Tab>("overview");
  const [openDialog, setOpenDialog] = useState(false);

  const incomeData = useMemo(() => {
    const income = transactions.filter((t) => t.type === "income");
    const totalIncome = income.reduce((sum, t) => sum + Number(t.amount), 0);
    const bySource = aggregateIncomeBySource(transactions, categories);
    return { income, totalIncome, bySource };
  }, [transactions, categories]);

  if (loading || !workspace) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Ganhos"
        subtitle="Contracheques, pacientes e outras receitas"
        workspaceName={workspace.name}
        action={{
          label: "Registrar ganho",
          onClick: () => setOpenDialog(true),
        }}
      />
      <nav className="hub-tabs" aria-label="Abas de ganhos">
        <button type="button" aria-current={tab === "overview" ? "page" : undefined} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visao geral</button>
        <button type="button" aria-current={tab === "payslips" ? "page" : undefined} onClick={() => setTab("payslips")} className={tab === "payslips" ? "active" : ""}>Contracheques</button>
        <button type="button" aria-current={tab === "patients" ? "page" : undefined} onClick={() => setTab("patients")} className={tab === "patients" ? "active" : ""}>Pacientes</button>
        <button type="button" aria-current={tab === "other" ? "page" : undefined} onClick={() => setTab("other")} className={tab === "other" ? "active" : ""}>Outras receitas</button>
     </nav>

      {tab === "overview" && (
        <section className="hub-overview">
          <article className="metric-card metric-card--positive">
            <TrendingUp aria-hidden="true" />
            <strong>{money(incomeData.totalIncome)}</strong>
            <span className="muted">Total recebido</span>
         </article>
          {incomeData.bySource.labels.length > 0 && (
            <article className="dashboard-card">
              <h3>Composição dos ganhos</h3>
              <div className="chart-wrap">
                <DashboardChart
                  type="bar"
                  labels={incomeData.bySource.labels}
                  values={incomeData.bySource.values}
                  label="Receitas"
                  color="var(--positive-color)"
                />
              </div>
            </article>
          )}
       </section>
      )}

      {tab === "payslips" && (
        <section>
          <p className="muted">Cadastre contracheques com empregador, competencia, bruto, descontos, liquido, recebimento e PDF privado</p>
       </section>
      )}

      {tab === "patients" && (
        <section>
          <p className="muted">Use nome completo do paciente e registre apenas os dados financeiros por atendimento, sem informacoes clinicas</p>
       </section>
      )}

      {tab === "other" && (
        <section>
          {incomeData.income.length === 0 ? (
            <p className="muted">Nenhuma receita registrada ainda</p>
          ) : (
            <ul className="list">
              {incomeData.income.map((t) => (
                <li key={t.id}>
                  <span>{t.description}</span>
                  <strong>{money(t.amount)}</strong>
               </li>
              ))}
           </ul>
          )}
       </section>
      )}

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Registrar ganho">
        <p className="muted">Formulario completo de ganho sera exibido aqui</p>
     </Dialog>
   </main>
  );
}
