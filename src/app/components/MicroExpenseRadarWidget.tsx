"use client";

import { useMemo, useState } from "react";
import {
  Coffee,
  Flame,
  PiggyBank,
  Target,
} from "lucide-react";
import { money } from "./Money";
import {
  calculateMicroSavingsChallenge,
  computeMicroExpenseSummary,
} from "@/lib/finance/micro-expenses";

type MicroExpenseRadarWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date: string;
    category_id?: string | null;
  }[];
  currentMonth: string; // YYYY-MM
};

export function MicroExpenseRadarWidget({
  transactions,
  currentMonth,
}: MicroExpenseRadarWidgetProps) {
  const [threshold, setThreshold] = useState<number>(30);

  const summary = useMemo(
    () => computeMicroExpenseSummary(transactions, currentMonth, threshold),
    [transactions, currentMonth, threshold]
  );

  const [weeklyGoal, setWeeklyGoal] = useState<number>(50);

  const challenge = useMemo(
    () =>
      calculateMicroSavingsChallenge({
        weeklyTarget: weeklyGoal,
        annualRatePercent: 12.0,
      }),
    [weeklyGoal]
  );

  return (
    <section
      aria-label="Detector de Gastos Invisíveis e Micro-gastos"
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
              background: "rgba(245, 158, 11, 0.15)",
              color: "var(--warning, #f59e0b)",
            }}
          >
            <Coffee size={20} aria-hidden="true" />
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
              Detector de Gastos Invisíveis (&quot;Formiguinha&quot;)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Pequenos valores diários que passam despercebidos e somam no fim do mês.
            </p>
          </div>
        </div>

        <span
          style={{
            fontSize: "0.75rem",
            fontWeight: 600,
            padding: "0.3rem 0.6rem",
            borderRadius: "20px",
            background:
              summary.totalMonthly > 200
                ? "rgba(239, 68, 68, 0.15)"
                : "rgba(245, 158, 11, 0.15)",
            color:
              summary.totalMonthly > 200
                ? "var(--destructive, #ef4444)"
                : "var(--warning, #f59e0b)",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
          }}
        >
          <Flame size={12} /> Impacto Anualizado: {money(summary.annualizedImpact)}/ano
        </span>
      </header>

      {/* Grid Principal: Métricas do Raio-X + Desafio Semanal */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Raio-X dos Micro-gastos */}
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
                Total em compras ≤ R$ {threshold}
              </span>
              <div style={{ display: "flex", gap: "4px" }}>
                {[15, 30, 50].map((val) => (
                  <button
                    key={val}
                    type="button"
                    onClick={() => setThreshold(val)}
                    style={{
                      padding: "3px 8px",
                      fontSize: "0.7rem",
                      borderRadius: "6px",
                      border: "1px solid var(--border)",
                      background: threshold === val ? "var(--primary, #3b82f6)" : "var(--surface)",
                      color: threshold === val ? "#fff" : "var(--muted)",
                      cursor: "pointer",
                      fontWeight: 600,
                    }}
                  >
                    ≤ R$ {val}
                  </button>
                ))}
              </div>
            </div>

            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color: "var(--text)",
                marginTop: "0.4rem",
              }}
            >
              {money(summary.totalMonthly)}
              <span style={{ fontSize: "0.85rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}
                ({summary.count} compras · {summary.percentageOfExpenses}% dos gastos)
              </span>
            </div>

            {/* Top Estabelecimentos */}
            <div style={{ marginTop: "1rem" }}>
              <strong style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "6px" }}>
                Principais ralos identificados:
              </strong>

              {summary.topVendors.length === 0 ? (
                <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
                  Nenhum micro-gasto registrado neste mês.
                </p>
              ) : (
                <div style={{ display: "grid", gap: "6px" }}>
                  {summary.topVendors.map((vendor, i) => (
                    <div
                      key={`${vendor.name}-${i}`}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        padding: "6px 8px",
                        borderRadius: "6px",
                        background: "var(--surface)",
                        border: "1px solid var(--border)",
                        fontSize: "0.8rem",
                      }}
                    >
                      <span>
                        {vendor.name}{" "}
                        <span style={{ color: "var(--muted)", fontSize: "0.75rem" }}>
                          ({vendor.count}x)
                        </span>
                      </span>
                      <strong>{money(vendor.total)}</strong>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Bloco 2: Desafio Semanal de Economia (Gamificação) */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
            <Target size={16} color="var(--positive, #22c55e)" />
            <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
              Desafio Semanal: Economia no CDI
            </strong>
          </div>

          <div style={{ marginBottom: "0.8rem" }}>
            <label
              htmlFor="weekly-target"
              style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
            >
              Meta de Economia por Semana (R$)
            </label>
            <input
              id="weekly-target"
              type="number"
              min={10}
              step={10}
              value={weeklyGoal}
              onChange={(e) => setWeeklyGoal(Math.max(10, Number(e.target.value)))}
              style={{
                width: "100%",
                padding: "8px 10px",
                borderRadius: "8px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                fontSize: "0.85rem",
                fontWeight: 600,
              }}
            />
          </div>

          {/* Projeção de Investimento da Economia */}
          <div
            style={{
              padding: "10px 12px",
              borderRadius: "10px",
              background: "rgba(34, 197, 94, 0.08)",
              border: "1px solid rgba(34, 197, 94, 0.25)",
            }}
          >
            <div style={{ fontSize: "0.8rem", color: "var(--text)" }}>
              Economizar <strong>{money(weeklyGoal)}/semana</strong> gera{" "}
              <strong>~{money(challenge.monthlyEstimatedSavings)}/mês</strong>.
            </div>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                marginTop: "8px",
                fontSize: "0.75rem",
              }}
            >
              <div
                style={{
                  padding: "6px 8px",
                  borderRadius: "6px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                }}
              >
                <div style={{ color: "var(--muted)" }}>Em 1 Ano (CDI)</div>
                <strong style={{ color: "var(--positive, #22c55e)", fontSize: "0.9rem" }}>
                  {money(challenge.accumulated1Year)}
                </strong>
              </div>

              <div
                style={{
                  padding: "6px 8px",
                  borderRadius: "6px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                }}
              >
                <div style={{ color: "var(--muted)" }}>Em 3 Anos (CDI)</div>
                <strong style={{ color: "var(--positive, #22c55e)", fontSize: "0.9rem" }}>
                  {money(challenge.accumulated3Years)}
                </strong>
              </div>
            </div>

            <div
              style={{
                marginTop: "8px",
                display: "flex",
                alignItems: "center",
                gap: "4px",
                fontSize: "0.75rem",
                color: "var(--muted)",
              }}
            >
              <PiggyBank size={12} color="var(--positive, #22c55e)" /> Em 5 anos:{" "}
              <strong style={{ color: "var(--positive, #22c55e)" }}>
                {money(challenge.accumulated5Years)}
              </strong>{" "}
              acumulados!
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
