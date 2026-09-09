"use client";

import { useState } from "react";
import { useFinance } from "@/app/components/useFinance";
import { Nav } from "@/app/components/Nav";
import { DebtListWidget } from "@/app/components/DebtListWidget";
import { DebtSimulatorWidget } from "@/app/components/DebtSimulatorWidget";
import { DebtForm } from "@/app/components/DebtForm";
import { createClient } from "@/lib/supabase/client";
import { PageHeader } from "@/app/components/PageHeader";

export default function DividasPage() {
  const { debts, workspace, loading } = useFinance("dividas");
  const [formOpen, setFormOpen] = useState(false);
  const supabase = createClient();

  async function handleAddDebt(debt: Omit<import('@/app/components/types').Debt, 'id' | 'workspace_id' | 'created_at' | 'updated_at'>) {
    if (!workspace) return;
    try {
      const res = await fetch("/api/debts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...debt,
          workspace_id: workspace.id,
        }),
      });
      if (res.ok) {
        window.location.reload();
        return;
      }
    } catch {}

    const { error } = await supabase.from("debts").insert({
      ...debt,
      workspace_id: workspace.id,
    });
    if (error) {
      alert("Erro ao salvar dívida: " + error.message);
    } else {
      window.location.reload();
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
