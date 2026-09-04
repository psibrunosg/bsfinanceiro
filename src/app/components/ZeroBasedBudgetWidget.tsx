"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  ArrowRightLeft,
  Mail,
  Plus,
  Sparkles,
  Trash2,
} from "lucide-react";
import { money } from "./Money";
import {
  computeZeroBasedBudget,
  transferBetweenEnvelopes,
  BudgetEnvelope,
} from "@/lib/finance/zero-based-budget";

type ZeroBasedBudgetWidgetProps = {
  monthlyIncome?: number;
  initialEnvelopes?: BudgetEnvelope[];
};

export function ZeroBasedBudgetWidget({
  monthlyIncome = 0,
  initialEnvelopes,
}: ZeroBasedBudgetWidgetProps) {
  const [envelopes, setEnvelopes] = useState<BudgetEnvelope[]>(() => {
    if (initialEnvelopes !== undefined) {
      return initialEnvelopes;
    }
    if (typeof window !== "undefined") {
      try {
        const stored = localStorage.getItem("bsf_budget_envelopes");
        if (stored) {
          const parsed = JSON.parse(stored);
          if (Array.isArray(parsed)) return parsed;
        }
      } catch (err) {
        console.error("Erro ao carregar envelopes do localStorage", err);
      }
    }
    return [];
  });

  const [fromEnv, setFromEnv] = useState<string>("");
  const [toEnv, setToEnv] = useState<string>("");
  const [transferAmt, setTransferAmt] = useState<string>("50");

  const [newEnvName, setNewEnvName] = useState("");
  const [newEnvAllocated, setNewEnvAllocated] = useState("");

  const budget = useMemo(
    () => computeZeroBasedBudget({ monthlyIncome, envelopes }),
    [monthlyIncome, envelopes]
  );

  function handleTransfer(e: React.FormEvent) {
    e.preventDefault();
    const sourceEnv = fromEnv || (envelopes[0] ? envelopes[0].id : "");
    const targetEnv = toEnv || (envelopes[1] ? envelopes[1].id : "");
    const amt = Number(transferAmt.replace(",", "."));
    if (isNaN(amt) || amt <= 0 || !sourceEnv || !targetEnv || sourceEnv === targetEnv) return;

    setEnvelopes((prev) => {
      const updated = transferBetweenEnvelopes(prev, sourceEnv, targetEnv, amt);
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem("bsf_budget_envelopes", JSON.stringify(updated));
        } catch {}
      }
      return updated;
    });
  }

  function handleDeleteEnvelope(id: string) {
    setEnvelopes((prev) => {
      const updated = prev.filter((e) => e.id !== id);
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem("bsf_budget_envelopes", JSON.stringify(updated));
        } catch {}
      }
      return updated;
    });
  }

  function handleAddEnvelope(e: React.FormEvent) {
    e.preventDefault();
    const alloc = Number(newEnvAllocated.replace(",", "."));
    if (!newEnvName.trim() || isNaN(alloc) || alloc <= 0) return;

    const newEnv: BudgetEnvelope = {
      id: `env-${Date.now()}`,
      name: newEnvName.trim(),
      allocated: alloc,
      spent: 0,
    };

    setEnvelopes((prev) => {
      const updated = [...prev, newEnv];
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem("bsf_budget_envelopes", JSON.stringify(updated));
        } catch {}
      }
      return updated;
    });

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
      {envelopes.length === 0 ? (
        <div
          style={{
            padding: "2rem 1rem",
            textAlign: "center",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.02))",
            border: "1px dashed var(--border)",
            color: "var(--muted)",
            fontSize: "0.875rem",
            marginBottom: "1.25rem",
          }}
        >
          Nenhum envelope virtual criado. Crie envelopes abaixo (ex: Moradia, Alimentação, Lazer) para distribuir sua receita e planejar seus gastos.
        </div>
      ) : (
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
                    <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                      <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>{env.name}</strong>
                      <button
                        type="button"
                        onClick={() => handleDeleteEnvelope(env.id)}
                        title="Remover envelope"
                        aria-label={`Remover envelope ${env.name}`}
                        style={{
                          background: "transparent",
                          border: "none",
                          color: "var(--muted)",
                          cursor: "pointer",
                          padding: "2px",
                          borderRadius: "4px",
                          display: "inline-flex",
                          alignItems: "center",
                          justifyContent: "center",
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.color = "var(--danger, #ef4444)")}
                        onMouseLeave={(e) => (e.currentTarget.style.color = "var(--muted)")}
                      >
                        <Trash2 size={13} />
                      </button>
                    </div>
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
      )}

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

          {envelopes.length < 2 ? (
            <p style={{ fontSize: "0.75rem", color: "var(--muted)", margin: 0 }}>
              Crie ao menos dois envelopes para remanejar valores entre eles.
            </p>
          ) : (
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 80px auto", gap: "6px" }}>
              <select
                value={fromEnv || (envelopes[0] ? envelopes[0].id : "")}
                onChange={(e) => setFromEnv(e.target.value)}
                style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              >
                {envelopes.map((e) => (
                  <option key={e.id} value={e.id}>De: {e.name}</option>
                ))}
              </select>

              <select
                value={toEnv || (envelopes[1] ? envelopes[1].id : "")}
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
          )}
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
