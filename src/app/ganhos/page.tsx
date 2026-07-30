"use client";

import { useState } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { money } from "../components/Money";
import { TrendingUp } from "lucide-react";

type Tab = "overview" | "payslips" | "patients" | "other";

export default function GanhosPage() {
  const { workspace, transactions, loading } = useFinance("dashboard");
  const [tab, setTab] = useState<Tab>("overview");
  const [openDialog, setOpenDialog] = useState(false);

  if (loading || !workspace) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

  const income = transactions.filter((t) => t.type === "income");
  const totalIncome = income.reduce((sum, t) => sum + Number(t.amount), 0);

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
        <button type="button" aria-pressed={tab === "overview"} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visao geral</button>
        <button type="button" aria-pressed={tab === "payslips"} onClick={() => setTab("payslips")} className={tab === "payslips" ? "active" : ""}>Contracheques</button>
        <button type="button" aria-pressed={tab === "patients"} onClick={() => setTab("patients")} className={tab === "patients" ? "active" : ""}>Pacientes</button>
        <button type="button" aria-pressed={tab === "other"} onClick={() => setTab("other")} className={tab === "other" ? "active" : ""}>Outras receitas</button>
     </nav>

      {tab === "overview" && (
        <section className="hub-overview">
          <article className="metric-card metric-card--positive">
            <TrendingUp aria-hidden="true" />
            <strong>{money(totalIncome)}</strong>
            <span className="muted">Total recebido</span>
         </article>
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
          {income.length === 0 ? (
            <p className="muted">Nenhuma receita registrada ainda</p>
          ) : (
            <ul className="list">
              {income.map((t) => (
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
