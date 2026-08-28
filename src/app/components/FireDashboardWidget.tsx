"use client";

import { useMemo, useState } from "react";
import {
  Flame,
  Sparkles,
  Sunrise,
  TrendingUp,
} from "lucide-react";
import { money } from "./Money";
import {
  calculateFireMetrics,
} from "@/lib/finance/fire-calculator";

type FireDashboardWidgetProps = {
  monthlyExpenses: number;
  currentNetWorth: number;
  estimatedMonthlyContribution?: number;
  currentMonth?: string;
};

export function FireDashboardWidget({
  monthlyExpenses,
  currentNetWorth,
  estimatedMonthlyContribution = 2000,
  currentMonth = new Date().toISOString().slice(0, 7),
}: FireDashboardWidgetProps) {
  const [simulatedContribution, setSimulatedContribution] = useState<number>(
    estimatedMonthlyContribution
  );
  const [fireMode, setFireMode] = useState<"standard" | "lean" | "fat">("standard");

  const fire = useMemo(
    () =>
      calculateFireMetrics({
        monthlyExpenses,
        currentNetWorth,
        monthlyContribution: simulatedContribution,
        realAnnualReturnPercent: 7.0,
        startMonth: currentMonth,
      }),
    [monthlyExpenses, currentNetWorth, simulatedContribution, currentMonth]
  );

  const activeTarget =
    fireMode === "lean"
      ? fire.fireNumberLean
      : fireMode === "fat"
      ? fire.fireNumberFat
      : fire.fireNumberStandard;

  const activeProgress =
    activeTarget > 0 ? Math.min(100, Math.round((currentNetWorth / activeTarget) * 1000) / 10) : 100;

  return (
    <section
      aria-label="Dashboard F.I.R.E. e Independência Financeira"
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
              background: "rgba(249, 115, 22, 0.15)",
              color: "var(--warning, #f97316)",
            }}
          >
            <Flame size={20} aria-hidden="true" />
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
              Dashboard F.I.R.E. (Independência Financeira)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Regra dos 4%, Renda Passiva Perpétua e Previsão da Data da Liberdade.
            </p>
          </div>
        </div>

        {/* Badges de Status */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(249, 115, 22, 0.15)",
              color: "var(--warning, #f97316)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Sunrise size={12} /> Liberdade em: {fire.fireDateLabel} ({fire.yearsToFire} anos)
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
            <Sparkles size={12} /> {activeProgress}% Conquistado
          </span>
        </div>
      </header>

      {/* Grid: Termômetro F.I.R.E. + 3 Níveis + Simulador */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Progresso & Renda Passiva Atual */}
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
              <span style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
                Patrimônio Investido Atual
              </span>
              <div style={{ display: "flex", gap: "4px" }}>
                <button
                  type="button"
                  onClick={() => setFireMode("lean")}
                  style={{
                    padding: "3px 6px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: fireMode === "lean" ? "var(--warning, #f97316)" : "var(--surface)",
                    color: fireMode === "lean" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  Lean
                </button>
                <button
                  type="button"
                  onClick={() => setFireMode("standard")}
                  style={{
                    padding: "3px 6px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: fireMode === "standard" ? "var(--warning, #f97316)" : "var(--surface)",
                    color: fireMode === "standard" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  Standard
                </button>
                <button
                  type="button"
                  onClick={() => setFireMode("fat")}
                  style={{
                    padding: "3px 6px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: fireMode === "fat" ? "var(--warning, #f97316)" : "var(--surface)",
                    color: fireMode === "fat" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  Fat
                </button>
              </div>
            </div>

            <div style={{ fontSize: "1.8rem", fontWeight: 700, color: "var(--text)", marginTop: "0.3rem" }}>
              {money(fire.currentNetWorth)}
              <span style={{ fontSize: "0.85rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}de {money(activeTarget)}
              </span>
            </div>

            {/* Barra de Progresso F.I.R.E. */}
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
                  width: `${activeProgress}%`,
                  height: "100%",
                  background:
                    activeProgress >= 100
                      ? "var(--positive, #22c55e)"
                      : "var(--warning, #f97316)",
                  borderRadius: "5px",
                  transition: "width 0.3s ease",
                }}
              />
            </div>

            {/* Renda Passiva Atual */}
            <div
              style={{
                padding: "8px 10px",
                borderRadius: "8px",
                background: "rgba(34, 197, 94, 0.1)",
                border: "1px solid rgba(34, 197, 94, 0.25)",
                fontSize: "0.75rem",
                color: "var(--positive, #22c55e)",
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <Sparkles size={14} /> Seu patrimônio já gera{" "}
              <strong>{money(fire.currentPassiveIncomeMonthly)}/mês</strong> de renda passiva perpétua!
            </div>
          </div>
        </div>

        {/* Bloco 2: 3 Níveis de Liberdade & Simulador de Aportes */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
            <TrendingUp size={16} color="var(--warning, #f97316)" />
            <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
              Simulador da Data de Aposentadoria
            </strong>
          </div>

          {/* 3 Cartões Rápidos */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(3, 1fr)",
              gap: "6px",
              fontSize: "0.7rem",
              marginBottom: "12px",
            }}
          >
            <div style={{ padding: "6px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)", textAlign: "center" }}>
              <div style={{ color: "var(--muted)" }}>Lean FIRE</div>
              <strong style={{ color: "var(--text)" }}>{money(fire.fireNumberLean).split(",")[0]}</strong>
            </div>
            <div style={{ padding: "6px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)", textAlign: "center" }}>
              <div style={{ color: "var(--muted)" }}>Standard</div>
              <strong style={{ color: "var(--warning, #f97316)" }}>{money(fire.fireNumberStandard).split(",")[0]}</strong>
            </div>
            <div style={{ padding: "6px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)", textAlign: "center" }}>
              <div style={{ color: "var(--muted)" }}>Fat FIRE</div>
              <strong style={{ color: "var(--positive, #22c55e)" }}>{money(fire.fireNumberFat).split(",")[0]}</strong>
            </div>
          </div>

          {/* Slider de Aporte */}
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", marginBottom: "4px" }}>
              <span style={{ color: "var(--muted)" }}>Simular aporte mensal:</span>
              <strong style={{ color: "var(--text)" }}>{money(simulatedContribution)}/mês</strong>
            </div>
            <input
              type="range"
              min={500}
              max={15000}
              step={250}
              value={simulatedContribution}
              onChange={(e) => setSimulatedContribution(Number(e.target.value))}
              style={{ width: "100%", accentColor: "var(--warning, #f97316)", cursor: "pointer" }}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
