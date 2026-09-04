"use client";

import { useState } from "react";
import { AlertTriangle, Award, Plane, Plus, Trash2 } from "lucide-react";
import { money } from "./Money";
import {
  calculateMilesValue,
  computeMilesSummary,
  type LoyaltyProgram,
} from "@/lib/finance/miles-tracker";

type MilesTrackerWidgetProps = {
  initialPrograms?: LoyaltyProgram[];
};

export function MilesTrackerWidget({
  initialPrograms,
}: MilesTrackerWidgetProps) {
  const [programs, setPrograms] = useState<LoyaltyProgram[]>(() => {
    if (initialPrograms !== undefined) {
      return initialPrograms;
    }
    if (typeof window !== "undefined") {
      try {
        const stored = localStorage.getItem("bsf_miles_programs");
        if (stored) {
          const parsed = JSON.parse(stored);
          if (Array.isArray(parsed)) return parsed;
        }
      } catch (err) {
        console.error("Erro ao carregar milhas do localStorage", err);
      }
    }
    return [];
  });
  const [showAddForm, setShowAddForm] = useState(false);

  const [newName, setNewName] = useState("");
  const [newPoints, setNewPoints] = useState("");
  const [newPrice, setNewPrice] = useState("20");
  const [newExpiringPoints, setNewExpiringPoints] = useState("");
  const [newExpiringDate, setNewExpiringDate] = useState("");

  const summary = computeMilesSummary(programs);

  const handleAddProgram = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName.trim()) return;

    const newProg: LoyaltyProgram = {
      id: `prog-${Date.now()}`,
      name: newName.trim(),
      points: Number(newPoints) || 0,
      pricePerThousand: Number(newPrice) || 20,
      expiringPoints: Number(newExpiringPoints) || undefined,
      expiringDate: newExpiringDate || undefined,
    };

    setPrograms((prev) => {
      const updated = [...prev, newProg];
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem("bsf_miles_programs", JSON.stringify(updated));
        } catch {}
      }
      return updated;
    });
    setNewName("");
    setNewPoints("");
    setNewExpiringPoints("");
    setNewExpiringDate("");
    setShowAddForm(false);
  };

  const handleDeleteProgram = (id: string) => {
    setPrograms((prev) => {
      const updated = prev.filter((p) => p.id !== id);
      if (typeof window !== "undefined") {
        try {
          localStorage.setItem("bsf_miles_programs", JSON.stringify(updated));
        } catch {}
      }
      return updated;
    });
  };

  return (
    <section
      className="dashboard-card"
      aria-label="Radar de Milhas e Pontos"
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
              background: "rgba(234, 179, 8, 0.15)",
              color: "var(--warning, #eab308)",
            }}
          >
            <Plane size={20} />
          </span>
          <div>
            <h2 style={{ fontSize: "1.1rem", fontWeight: 700, margin: 0, color: "var(--text)" }}>
              Radar de Milhas & Pontos
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Consolide seus programas de fidelidade, estime o valor de mercado e evite a expiração.
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={() => setShowAddForm((s) => !s)}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
            background: "rgba(234, 179, 8, 0.12)",
            color: "var(--warning, #eab308)",
            border: "1px solid rgba(234, 179, 8, 0.3)",
            borderRadius: "8px",
            padding: "6px 12px",
            fontSize: "0.8rem",
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          <Plus size={14} />
          Adicionar Programa
        </button>
      </header>

      {/* Summary Cards */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(160px, 1fr))",
          gap: "12px",
          marginBottom: "1.25rem",
        }}
      >
        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Total de Pontos</span>
          <div style={{ fontSize: "1.25rem", fontWeight: 700, color: "var(--text)", marginTop: "2px" }}>
            {summary.totalPoints.toLocaleString("pt-BR")} pts
          </div>
        </div>

        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Valor Estimado em Caixa</span>
          <div style={{ fontSize: "1.25rem", fontWeight: 700, color: "var(--positive, #22c55e)", marginTop: "2px" }}>
            {money(summary.totalEstimatedValue)}
          </div>
        </div>

        <div
          style={{
            padding: "10px 14px",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Pontos Expirando</span>
          <div
            style={{
              fontSize: "1.25rem",
              fontWeight: 700,
              color: summary.totalExpiringPoints > 0 ? "var(--destructive, #ef4444)" : "var(--muted)",
              marginTop: "2px",
            }}
          >
            {summary.totalExpiringPoints.toLocaleString("pt-BR")} pts
          </div>
        </div>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <form
          onSubmit={handleAddProgram}
          style={{
            padding: "14px",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.04))",
            border: "1px solid var(--border)",
            marginBottom: "1.25rem",
            display: "grid",
            gap: "10px",
            gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
          }}
        >
          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Programa
            </label>
            <input
              type="text"
              placeholder="Nome do programa (ex: Smiles, Latam...)"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Saldo de Pontos
            </label>
            <input
              type="number"
              placeholder="Saldo total de pontos"
              value={newPoints}
              onChange={(e) => setNewPoints(e.target.value)}
              required
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Valor p/ 1.000 pts (R$)
            </label>
            <input
              type="number"
              step="0.5"
              placeholder="Valor por 1.000 pts (ex: 17.50)"
              value={newPrice}
              onChange={(e) => setNewPrice(e.target.value)}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div>
            <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
              Pontos a Vencer (Opcional)
            </label>
            <input
              type="number"
              placeholder="Qtd prestes a vencer"
              value={newExpiringPoints}
              onChange={(e) => setNewExpiringPoints(e.target.value)}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
              }}
            />
          </div>

          <div style={{ display: "flex", alignItems: "flex-end", gap: "8px" }}>
            <button
              type="submit"
              style={{
                flex: 1,
                padding: "9px 14px",
                borderRadius: "8px",
                background: "var(--warning, #eab308)",
                color: "#000000",
                border: "none",
                fontWeight: 600,
                fontSize: "0.85rem",
                cursor: "pointer",
              }}
            >
              Salvar
            </button>
            <button
              type="button"
              onClick={() => setShowAddForm(false)}
              style={{
                padding: "9px 14px",
                borderRadius: "8px",
                background: "transparent",
                color: "var(--muted)",
                border: "1px solid var(--border)",
                fontSize: "0.85rem",
                cursor: "pointer",
              }}
            >
              Cancelar
            </button>
          </div>
        </form>
      )}

      {/* Programs List */}
      {programs.length === 0 ? (
        <div
          style={{
            padding: "2rem 1rem",
            textAlign: "center",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.02))",
            border: "1px dashed var(--border)",
            color: "var(--muted)",
            fontSize: "0.875rem",
          }}
        >
          Nenhum programa de milhas cadastrado. Clique em &quot;Adicionar Programa&quot; para cadastrar seus pontos, cotações e vencimentos.
        </div>
      ) : (
        <div style={{ display: "grid", gap: "8px" }}>
          {programs.map((prog) => {
            const estimatedVal = calculateMilesValue(prog);
            const hasExpiring = Boolean(prog.expiringPoints && prog.expiringPoints > 0);

            return (
              <div
                key={prog.id}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  padding: "10px 14px",
                  borderRadius: "10px",
                  background: hasExpiring
                    ? "rgba(239, 68, 68, 0.05)"
                    : "var(--surface-2, rgba(255,255,255,0.02))",
                  border: hasExpiring
                    ? "1px solid rgba(239, 68, 68, 0.25)"
                    : "1px solid var(--border)",
                  flexWrap: "wrap",
                  gap: "10px",
                }}
              >
                <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                  <span
                    style={{
                      color: hasExpiring ? "var(--destructive, #ef4444)" : "var(--warning, #eab308)",
                    }}
                  >
                    {hasExpiring ? <AlertTriangle size={18} /> : <Award size={18} />}
                  </span>
                  <div>
                    <strong style={{ fontSize: "0.9rem", color: "var(--text)", display: "block" }}>
                      {prog.name}
                    </strong>
                    <span style={{ fontSize: "0.75rem", color: "var(--muted)", display: "flex", gap: "8px" }}>
                      <span>{Number(prog.points).toLocaleString("pt-BR")} pts</span>
                      <span>• Cotação: R$ {Number(prog.pricePerThousand).toFixed(2)}/k</span>
                      {hasExpiring && (
                        <span style={{ color: "var(--destructive, #ef4444)", fontWeight: 600 }}>
                          • {Number(prog.expiringPoints).toLocaleString("pt-BR")} vencendo!
                        </span>
                      )}
                    </span>
                  </div>
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                  <div style={{ textAlign: "right" }}>
                    <b style={{ fontSize: "0.92rem", color: "var(--positive, #22c55e)", display: "block" }}>
                      ~ {money(estimatedVal)}
                    </b>
                    <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>
                      Valor de mercado
                    </span>
                  </div>
                  <button
                    type="button"
                    onClick={() => handleDeleteProgram(prog.id)}
                    title="Remover programa"
                    aria-label={`Remover programa ${prog.name}`}
                    style={{
                      background: "transparent",
                      border: "none",
                      color: "var(--muted)",
                      cursor: "pointer",
                      padding: "6px",
                      borderRadius: "6px",
                      display: "inline-flex",
                      alignItems: "center",
                      justifyContent: "center",
                      transition: "color 0.15s ease",
                    }}
                    onMouseEnter={(e) => (e.currentTarget.style.color = "var(--destructive, #ef4444)")}
                    onMouseLeave={(e) => (e.currentTarget.style.color = "var(--muted)")}
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </section>
  );
}
