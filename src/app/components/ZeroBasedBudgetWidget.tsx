"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  ArrowRightLeft,
  Mail,
  Plus,
  Sparkles,
} from "lucide-react";
import { money } from "./Money";
import {
  computeZeroBasedBudget,
  transferBetweenEnvelopes,
  BudgetEnvelope,
} from "@/lib/finance/zero-based-budget";

type ZeroBasedBudgetWidgetProps = {
  monthlyIncome?: number;
};

export function ZeroBasedBudgetWidget({
  monthlyIncome = 10000,
}: ZeroBasedBudgetWidgetProps) {
  const [envelopes, setEnvelopes] = useState<BudgetEnvelope[]>([
    { id: "env-1", name: "Moradia & Contas", allocated: 3500, spent: 3200, category: "Moradia" },
    { id: "env-2", name: "Alimentação & Mercado", allocated: 2000, spent: 2150, category: "Alimentação" },
    { id: "env-3", name: "Lazer & Restaurantes", allocated: 1500, spent: 800, category: "Lazer" },
    { id: "env-4", name: "Saúde & Farmácia", allocated: 1000, spent: 650, category: "Saúde" },
    { id: "env-5", name: "Aportes & F.I.R.E.", allocated: 2000, spent: 2000, category: "Investimentos" },
  ]);

  const [fromEnv, setFromEnv] = useState<string>("env-3");
  const [toEnv, setToEnv] = useState<string>("env-2");
  const [transferAmt, setTransferAmt] = useState<string>("150");

  const [newEnvName, setNewEnvName] = useState("");
  const [newEnvAllocated, setNewEnvAllocated] = useState("");

  const budget = useMemo(
    () => computeZeroBasedBudget({ monthlyIncome, envelopes }),
    [monthlyIncome, envelopes]
  );

  function handleTransfer(e: React.FormEvent) {
    e.preventDefault();
    const amt = Number(transferAmt.replace(",", "."));
    if (isNaN(amt) || amt <= 0 || fromEnv === toEnv) return;

    setEnvelopes((prev) => transferBetweenEnvelopes(prev, fromEnv, toEnv, amt));
  }

  function handleAddEnvelope(e: React.FormEvent) {
    e.preventDefault();
    const alloc = Number(newEnvAllocated.replace(",", "."));
    if (!newEnvName.trim() || isNaN(alloc) || alloc <= 0) return;

    setEnvelopes((prev) => [
      ...prev,
      {
        id: `env-${Date.now()}`,
        name: newEnvName.trim(),
        allocated: alloc,
        spent: 0,
      },
    ]);

    setNewEnvName("");
    setNewEnvAllocated("");
  }

  return (
    <section
      aria-label="Orçamento Base Zero e Envelopes Virtuais"
      className="dashboard-card"
      style={{
        padding: "1.5rem",
        borderRadius: "16px",
        background: "var(--surface)",
        border: "1px solid var(--border)",
        boxShadow: "0 4px 20px rgba(0, 0, 0, 0.15)",
        marginBottom: "1.5rem",
      }}
    >
      <header
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "1.25rem",
          flexWrap: "wrap",
          gap: "10px",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: "0.6rem" }}>
          <span
            style={{
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              width: "36px",
              height: "36px",
              borderRadius: "10px",
              background: "rgba(14, 165, 233, 0.15)",
              color: "var(--primary, #0ea5e9)",
            }}
          >
            <Mail size={20} aria-hidden="true" />
          </span>
          <div>
            <h2
              style={{
                fontSize: "1.1rem",
                fontWeight: 700,
                letterSpacing: "-0.02em",
                margin: 0,
                color: "var(--text)",
              }}
            >
              Orçamento Base Zero (Envelopes Virtuais)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Regra de ouro YNAB: dê um destino a cada centavo e remaneje entre envelopes para não estourar.
            </p>
          </div>
        </div>

        {/* Badges */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: budget.unallocatedAmount === 0 ? "rgba(34, 197, 94, 0.15)" : "rgba(245, 158, 11, 0.15)",
              color: budget.unallocatedAmount === 0 ? "var(--positive, #22c55e)" : "var(--warning, #f59e0b)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Sparkles size={12} /> Não Alocado: {money(budget.unallocatedAmount)}
          </span>

          {budget.overspentEnvelopesCount > 0 && (
            <span
              style={{
                fontSize: "0.75rem",
                fontWeight: 600,
                padding: "0.3rem 0.6rem",
                borderRadius: "20px",
                background: "rgba(239, 68, 68, 0.15)",
                color: "var(--danger, #ef4444)",
                display: "inline-flex",
                alignItems: "center",
                gap: "4px",
              }}
            >
              <AlertTriangle size={12} /> {budget.overspentEnvelopesCount} Estourado(s)
            </span>
          )}
        </div>
      </header>

      {/* Grid de Envelopes Virtuais */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
          gap: "12px",
          marginBottom: "1.25rem",
        }}
      >
        {budget.envelopesWithMetrics.map((env) => {
          let barBg = "var(--primary, #0ea5e9)";
          if (env.spentPercent >= 100) {
            barBg = "var(--danger, #ef4444)";
          } else if (env.spentPercent >= 80) {
            barBg = "var(--warning, #f59e0b)";
          }

          return (
            <div
              key={env.id}
              style={{
                padding: "12px",
                borderRadius: "12px",
                background: "var(--surface-2, rgba(255,255,255,0.03))",
                border: `1px solid ${env.isOverspent ? "rgba(239, 68, 68, 0.4)" : "var(--border)"}`,
                display: "flex",
                flexDirection: "column",
                justifyContent: "space-between",
              }}
            >
              <div>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: "4px" }}>
                  <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>{env.name}</strong>
                  <span
                    style={{
                      fontSize: "0.7rem",
                      fontWeight: 700,
                      color: env.isOverspent ? "var(--danger, #ef4444)" : "var(--positive, #22c55e)",
                    }}
                  >
                    {env.isOverspent ? `Estourado em ${money(env.overspentAmount)}` : `${money(env.remaining)} restante`}
                  </span>
                </div>

                <small style={{ color: "var(--muted)", fontSize: "0.75rem", display: "block" }}>
                  Gasto {money(env.spent)} de {money(env.allocated)} ({env.spentPercent}%)
                </small>

                {/* Barra de Progresso */}
                <div
                  style={{
                    width: "100%",
                    height: "8px",
                    borderRadius: "4px",
                    background: "var(--surface)",
                    marginTop: "8px",
                    overflow: "hidden",
                  }}
                >
                  <div
                    style={{
                      width: `${Math.min(100, env.spentPercent)}%`,
                      height: "100%",
                      background: barBg,
                      borderRadius: "4px",
                      transition: "width 0.3s ease",
                    }}
                  />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Ações Rápidas: Remanejar Orçamento + Novo Envelope */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1rem",
          padding: "1rem",
          borderRadius: "12px",
          background: "var(--surface-2, rgba(255,255,255,0.02))",
          border: "1px solid var(--border)",
        }}
      >
        {/* Remanejar Orçamento entre Envelopes */}
        <form onSubmit={handleTransfer} style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
          <strong style={{ fontSize: "0.8rem", color: "var(--text)", display: "flex", alignItems: "center", gap: "4px" }}>
            <ArrowRightLeft size={14} /> Cobrir Estouro / Remanejar
          </strong>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 80px auto", gap: "6px" }}>
            <select
              value={fromEnv}
              onChange={(e) => setFromEnv(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            >
              {envelopes.map((e) => (
                <option key={e.id} value={e.id}>De: {e.name}</option>
              ))}
            </select>

            <select
              value={toEnv}
              onChange={(e) => setToEnv(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            >
              {envelopes.map((e) => (
                <option key={e.id} value={e.id}>Para: {e.name}</option>
              ))}
            </select>

            <input
              type="text"
              value={transferAmt}
              onChange={(e) => setTransferAmt(e.target.value)}
              placeholder="R$"
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />

            <button
              type="submit"
              style={{
                padding: "4px 10px",
                borderRadius: "6px",
                background: "var(--primary, #0ea5e9)",
                color: "#fff",
                border: "none",
                fontSize: "0.75rem",
                fontWeight: 600,
                cursor: "pointer",
              }}
            >
              Mover
            </button>
          </div>
        </form>

        {/* Adicionar Novo Envelope */}
        <form onSubmit={handleAddEnvelope} style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
          <strong style={{ fontSize: "0.8rem", color: "var(--text)", display: "flex", alignItems: "center", gap: "4px" }}>
            <Plus size={14} /> Novo Envelope
          </strong>

          <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr auto", gap: "6px" }}>
            <input
              type="text"
              placeholder="Nome do Envelope"
              value={newEnvName}
              onChange={(e) => setNewEnvName(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <input
              type="text"
              placeholder="Meta (R$)"
              value={newEnvAllocated}
              onChange={(e) => setNewEnvAllocated(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <button
              type="submit"
              style={{
                padding: "4px 10px",
                borderRadius: "6px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                color: "var(--text)",
                fontSize: "0.75rem",
                fontWeight: 600,
                cursor: "pointer",
              }}
            >
              Criar
            </button>
          </div>
        </form>
      </div>
    </section>
  );
}
