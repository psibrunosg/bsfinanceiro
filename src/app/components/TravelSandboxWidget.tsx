"use client";

import { useMemo, useState } from "react";
import {
  MapPin,
  Plane,
  Plus,
  ShieldCheck,
} from "lucide-react";
import { money } from "./Money";
import {
  computeTravelSandbox,
  TravelTrip,
} from "@/lib/finance/travel-sandbox";

type TravelSandboxWidgetProps = {
  initialTrip?: TravelTrip | null;
};

export function TravelSandboxWidget({ initialTrip }: TravelSandboxWidgetProps = {}) {
  const [trip, setTrip] = useState<TravelTrip | null>(() => {
    if (initialTrip !== undefined) {
      return initialTrip;
    }
    if (typeof window !== "undefined") {
      try {
        const stored = localStorage.getItem("bsf_travel_trip");
        if (stored) {
          const parsed = JSON.parse(stored);
          if (parsed?.id === "trip-1" || parsed?.destination === "Santiago, Chile") {
            localStorage.removeItem("bsf_travel_trip");
            return null;
          }
          return parsed;
        }
      } catch (err) {
        console.error("Erro ao carregar viagem do localStorage", err);
      }
    }
    return null;
  });

  const [showCreateForm, setShowCreateForm] = useState(false);
  const [dest, setDest] = useState("");
  const [budgetInput, setBudgetInput] = useState("");
  const [startDateInput, setStartDateInput] = useState(new Date().toISOString().slice(0, 10));
  const [endDateInput, setEndDateInput] = useState(
    new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10)
  );

  const [newDesc, setNewDesc] = useState("");
  const [newAmt, setNewAmt] = useState("");
  const [newCat, setNewCat] = useState("Alimentação");
  const [newCurrency, setNewCurrency] = useState<"BRL" | "USD" | "EUR">("BRL");

  const summary = useMemo(() => (trip ? computeTravelSandbox(trip) : null), [trip]);

  function handleCreateTrip(e: React.FormEvent) {
    e.preventDefault();
    if (!dest.trim()) return;
    const budgetVal = Number(budgetInput.replace(",", ".")) || 1000;
    const newTrip: TravelTrip = {
      id: `trip-${Date.now()}`,
      destination: dest.trim(),
      budgetBrl: budgetVal,
      startDate: startDateInput,
      endDate: endDateInput,
      expenses: [],
    };

    setTrip(newTrip);
    if (typeof window !== "undefined") {
      try {
        localStorage.setItem("bsf_travel_trip", JSON.stringify(newTrip));
      } catch {}
    }
    setDest("");
    setBudgetInput("");
    setShowCreateForm(false);
  }

  function handleEndTrip() {
    if (typeof window !== "undefined") {
      try {
        localStorage.removeItem("bsf_travel_trip");
      } catch {}
    }
    setTrip(null);
  }

  function handleAddExpense(e: React.FormEvent) {
    e.preventDefault();
    if (!trip) return;
    const amt = Number(newAmt.replace(",", "."));
    if (!newDesc.trim() || isNaN(amt) || amt <= 0) return;

    const rate = newCurrency === "USD" ? 5.5 : newCurrency === "EUR" ? 6.0 : 1;

    const updatedTrip: TravelTrip = {
      ...trip,
      expenses: [
        {
          id: `exp-${Date.now()}`,
          description: newDesc.trim(),
          amount: amt,
          currency: newCurrency,
          exchangeRate: rate,
          category: newCat,
          date: new Date().toISOString().slice(0, 10),
        },
        ...trip.expenses,
      ],
    };

    setTrip(updatedTrip);
    if (typeof window !== "undefined") {
      try {
        localStorage.setItem("bsf_travel_trip", JSON.stringify(updatedTrip));
      } catch {}
    }

    setNewDesc("");
    setNewAmt("");
  }

  if (!trip || !summary) {
    return (
      <section
        aria-label="Modo Viagem e Sandbox de Gastos Isolado"
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
                background: "rgba(59, 130, 246, 0.15)",
                color: "var(--primary, #3b82f6)",
              }}
            >
              <Plane size={20} aria-hidden="true" />
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
                Modo Viagem (Sandbox de Gastos)
              </h2>
              <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
                Orçamento isolado para viagens: acompanhe a diária sem distorcer as médias de custo de vida mensal.
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={() => setShowCreateForm((s) => !s)}
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
              background: "rgba(59, 130, 246, 0.12)",
              color: "var(--primary, #3b82f6)",
              border: "1px solid rgba(59, 130, 246, 0.3)",
              borderRadius: "8px",
              padding: "6px 12px",
              fontSize: "0.8rem",
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            <Plus size={14} />
            {showCreateForm ? "Cancelar" : "Iniciar Viagem"}
          </button>
        </header>

        {showCreateForm ? (
          <form
            onSubmit={handleCreateTrip}
            style={{
              padding: "14px",
              borderRadius: "12px",
              background: "var(--surface-2, rgba(255,255,255,0.04))",
              border: "1px solid var(--border)",
              display: "grid",
              gap: "10px",
              gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
            }}
          >
            <div>
              <label style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}>
                Destino / Nome da Viagem
              </label>
              <input
                type="text"
                placeholder="Ex: Férias na Praia"
                value={dest}
                onChange={(e) => setDest(e.target.value)}
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
                Orçamento Total (R$)
              </label>
              <input
                type="number"
                placeholder="Ex: 5000"
                value={budgetInput}
                onChange={(e) => setBudgetInput(e.target.value)}
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
                Data de Início
              </label>
              <input
                type="date"
                value={startDateInput}
                onChange={(e) => setStartDateInput(e.target.value)}
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
                Data de Término
              </label>
              <input
                type="date"
                value={endDateInput}
                onChange={(e) => setEndDateInput(e.target.value)}
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
            <div style={{ display: "flex", alignItems: "flex-end", gap: "8px" }}>
              <button
                type="submit"
                style={{
                  padding: "9px 14px",
                  borderRadius: "8px",
                  background: "var(--primary, #3b82f6)",
                  color: "#fff",
                  border: "none",
                  fontWeight: 600,
                  fontSize: "0.85rem",
                  cursor: "pointer",
                }}
              >
                Criar Sandbox de Viagem
              </button>
            </div>
          </form>
        ) : (
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
            Nenhuma viagem ativa no momento. Clique em &quot;Iniciar Viagem&quot; para registrar gastos de férias ou trabalho isoladamente.
          </div>
        )}
      </section>
    );
  }

  return (
    <section
      aria-label="Modo Viagem e Sandbox de Gastos Isolado"
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
              background: "rgba(59, 130, 246, 0.15)",
              color: "var(--primary, #3b82f6)",
            }}
          >
            <Plane size={20} aria-hidden="true" />
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
              Modo Viagem (Sandbox de Gastos)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Orçamento isolado para viagens: acompanhe a diária sem distorcer as médias de custo de vida mensal.
            </p>
          </div>
        </div>

        {/* Badges */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap", alignItems: "center" }}>
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(59, 130, 246, 0.15)",
              color: "var(--primary, #3b82f6)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <MapPin size={12} /> {summary.destination}
          </span>

          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(34, 197, 94, 0.15)",
              color: "var(--positive, #22c55e)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <ShieldCheck size={12} /> Médias Mensais Blindadas
          </span>

          <button
            type="button"
            onClick={handleEndTrip}
            title="Encerrar esta viagem e limpar o sandbox"
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(239, 68, 68, 0.12)",
              color: "var(--danger, #ef4444)",
              border: "1px solid rgba(239, 68, 68, 0.3)",
              cursor: "pointer",
            }}
          >
            Encerrar Viagem
          </button>
        </div>
      </header>

      {/* Grid: Métricas e Extrato + Formulário */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Métricas de Diária e Progresso */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
          }}
        >
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
              <span style={{ fontSize: "0.85rem", color: "var(--muted)" }}>Total Gasto na Viagem</span>
              <strong style={{ fontSize: "0.75rem", color: summary.status === "over_budget" ? "var(--danger, #ef4444)" : "var(--positive, #22c55e)" }}>
                {summary.statusLabel}
              </strong>
            </div>

            <div style={{ fontSize: "1.8rem", fontWeight: 700, color: "var(--text)", marginTop: "0.3rem" }}>
              {money(summary.totalSpentBrl)}
              <span style={{ fontSize: "0.85rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}de {money(summary.budgetBrl)}
              </span>
            </div>

            {/* Barra de Progresso */}
            <div
              style={{
                width: "100%",
                height: "10px",
                borderRadius: "5px",
                background: "var(--surface)",
                margin: "12px 0",
                overflow: "hidden",
              }}
            >
              <div
                style={{
                  width: `${Math.min(100, summary.spentPercent)}%`,
                  height: "100%",
                  background:
                    summary.spentPercent >= 100
                      ? "var(--danger, #ef4444)"
                      : summary.spentPercent >= 80
                      ? "var(--warning, #f59e0b)"
                      : "var(--primary, #3b82f6)",
                  borderRadius: "5px",
                  transition: "width 0.3s ease",
                }}
              />
            </div>

            {/* Diária Real vs Planejada */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                padding: "8px 10px",
                borderRadius: "8px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                fontSize: "0.75rem",
              }}
            >
              <div>
                <span style={{ color: "var(--muted)" }}>Teto Diário:</span>
                <strong style={{ display: "block", color: "var(--text)" }}>{money(summary.dailyBudgetBrl)}/dia</strong>
              </div>
              <div>
                <span style={{ color: "var(--muted)" }}>Gasto Real Médio:</span>
                <strong style={{ display: "block", color: summary.averageDailySpentBrl <= summary.dailyBudgetBrl ? "var(--positive, #22c55e)" : "var(--danger, #ef4444)" }}>
                  {money(summary.averageDailySpentBrl)}/dia
                </strong>
              </div>
            </div>
          </div>
        </div>

        {/* Bloco 2: Lançamento Rápido na Viagem */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
          }}
        >
          <div>
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "8px" }}>
              Lançar Despesa da Viagem ({trip.expenses.length})
            </strong>

            <form onSubmit={handleAddExpense} style={{ display: "grid", gap: "6px" }}>
              <input
                type="text"
                placeholder="Ex: Almoço / Passeio / Museu"
                value={newDesc}
                onChange={(e) => setNewDesc(e.target.value)}
                style={{ padding: "6px 8px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />

              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "6px" }}>
                <input
                  type="text"
                  placeholder="Valor"
                  value={newAmt}
                  onChange={(e) => setNewAmt(e.target.value)}
                  style={{ padding: "6px 8px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />

                <select
                  value={newCurrency}
                  onChange={(e) => setNewCurrency(e.target.value as "BRL" | "USD" | "EUR")}
                  style={{ padding: "6px 8px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                >
                  <option value="BRL">R$ (BRL)</option>
                  <option value="USD">$ (USD)</option>
                  <option value="EUR">€ (EUR)</option>
                </select>

                <select
                  value={newCat}
                  onChange={(e) => setNewCat(e.target.value)}
                  style={{ padding: "6px 8px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                >
                  <option value="Alimentação">Alimentação</option>
                  <option value="Hospedagem">Hospedagem</option>
                  <option value="Passeios">Passeios</option>
                  <option value="Transporte">Transporte</option>
                  <option value="Compras">Compras</option>
                </select>
              </div>

              <button
                type="submit"
                style={{
                  marginTop: "6px",
                  padding: "8px",
                  borderRadius: "6px",
                  background: "var(--primary, #3b82f6)",
                  color: "#fff",
                  border: "none",
                  fontSize: "0.75rem",
                  fontWeight: 700,
                  cursor: "pointer",
                  display: "inline-flex",
                  alignItems: "center",
                  justifyContent: "center",
                  gap: "4px",
                }}
              >
                <Plus size={14} /> Registrar na Viagem
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}
