"use client";

import { apiFetch } from "@/lib/api-client";

import { useState } from "react";
import { useFinance } from "@/app/components/useFinance";
import { Nav } from "@/app/components/Nav";
import { DebtListWidget } from "@/app/components/DebtListWidget";
import { DebtSimulatorWidget } from "@/app/components/DebtSimulatorWidget";
import { DebtForm } from "@/app/components/DebtForm";
import { PageHeader } from "@/app/components/PageHeader";

export default function DividasPage() {
  const { debts, workspace, loading, message, setMessage, reload } =
    useFinance("dividas");
  const [formOpen, setFormOpen] = useState(false);

  async function handleAddDebt(
    debt: Omit<
      import("@/app/components/types").Debt,
      "id" | "workspace_id" | "created_at" | "updated_at"
    >,
  ) {
    if (!workspace) return;
    try {
      const res = await apiFetch("/api/debts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...debt,
          workspace_id: workspace.id,
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok || !data.success) {
        throw new Error(data.error || "Não foi possível salvar a dívida.");
      }
      setMessage("Dívida adicionada.");
      setFormOpen(false);
      await reload();
    } catch (error) {
      setMessage(
        error instanceof Error
          ? error.message
          : "Não foi possível salvar a dívida.",
      );
    }
  }

  if (loading || !workspace) {
    return (
      <main className="dashboard-shell">
        <p className="muted">Carregando...</p>
      </main>
    );
  }

  return (
    <main className="dashboard-shell">
      <Nav />
      <PageHeader
        title="Dívidas e Parcelamentos"
        subtitle="Acompanhe parcelas e faça simulações de quitação antecipada"
        workspaceName={workspace.name}
        action={{
          label: "Nova dívida",
          onClick: () => setFormOpen(true),
        }}
      />
      {message && (
        <p
          className={message.startsWith("Não") ? "form-error" : "form-success"}
          role={message.startsWith("Não") ? "alert" : "status"}
        >
          {message}
        </p>
      )}
      
      <div style={{ display: "grid", gap: "2rem", gridTemplateColumns: "1fr" }}>
        <DebtListWidget debts={debts || []} onAdd={() => setFormOpen(true)} />
        <DebtSimulatorWidget debts={debts || []} />
      </div>

      <DebtForm 
        isOpen={formOpen} 
        onClose={() => setFormOpen(false)} 
        onSubmit={handleAddDebt} 
      />
    </main>
  );
}
