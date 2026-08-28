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

export function TravelSandboxWidget() {
  const [trip, setTrip] = useState<TravelTrip>({
    id: "trip-active",
    destination: "Férias em Gramado & Canela",
    budgetBrl: 6000,
    startDate: "2026-07-10",
    endDate: "2026-07-16",
    expenses: [
      { id: "e1", description: "Hotel Ritta Höppner", amount: 2800, category: "Hospedagem", date: "2026-07-10" },
      { id: "e2", description: "Jantar Sequência de Fondue", amount: 450, category: "Alimentação", date: "2026-07-11" },
      { id: "e3", description: "Ingressos Parque Snowland", amount: 650, category: "Passeios", date: "2026-07-12" },
    ],
  });

  const [newDesc, setNewDesc] = useState("");
  const [newAmt, setNewAmt] = useState("");
  const [newCat, setNewCat] = useState("Alimentação");
  const [newCurrency, setNewCurrency] = useState<"BRL" | "USD" | "EUR">("BRL");

  const summary = useMemo(() => computeTravelSandbox(trip), [trip]);

  function handleAddExpense(e: React.FormEvent) {
    e.preventDefault();
    const amt = Number(newAmt.replace(",", "."));
    if (!newDesc.trim() || isNaN(amt) || amt <= 0) return;

    const rate = newCurrency === "USD" ? 5.5 : newCurrency === "EUR" ? 6.0 : 1;

    setTrip((prev) => ({
      ...prev,
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
        ...prev.expenses,
      ],
    }));

    setNewDesc("");
    setNewAmt("");
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
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
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
