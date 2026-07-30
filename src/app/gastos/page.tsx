"use client";

import { useState } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { money } from "../components/Money";
import { ReceiptText } from "lucide-react";

type Tab = "overview" | "launches" | "recurrent";

export default function GastosPage() {
  const { workspace, transactions, loading } = useFinance("dashboard");
  const [tab, setTab] = useState<Tab>("overview");
  const [openDialog, setOpenDialog] = useState(false);

  if (loading || !workspace) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

  const expenses = transactions.filter((t) => t.type === "expense");
  const totalExpenses = expenses.reduce((sum, t) => sum + Number(t.amount), 0);

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
        <button type="button" aria-pressed={tab === "overview"} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visao geral</button>
        <button type="button" aria-pressed={tab === "launches"} onClick={() => setTab("launches")} className={tab === "launches" ? "active" : ""}>Lancamentos</button>
        <button type="button" aria-pressed={tab === "recurrent"} onClick={() => setTab("recurrent")} className={tab === "recurrent" ? "active" : ""}>Recorrentes</button>
      </nav>

      {tab === "overview" && (
        <section className="hub-overview">
          <article className="metric-card metric-card--negative">
            <ReceiptText aria-hidden="true" />
            <strong>{money(totalExpenses)}</strong>
            <span className="muted">Total gasto</span>
          </article>
        </section>
      )}

      {tab === "launches" && (
        <section>
          {expenses.length === 0 ? (
            <p className="muted">Nenhum gasto registrado ainda</p>
          ) : (
            <ul className="list">
              {expenses.map((t) => (
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
