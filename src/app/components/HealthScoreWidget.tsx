"use client";

import { useMemo } from "react";
import {
  Award,
  HeartPulse,
  Lightbulb,
  PiggyBank,
  ShieldCheck,
  TrendingUp,
  Zap,
} from "lucide-react";
import {
  computeFinancialHealthScore,
  type HealthScorePilar,
} from "@/lib/finance/health-score";

type HealthScoreWidgetProps = {
  monthlyIncome: number;
  monthlyExpenses: number;
  availableCash: number;
  fixedCommitments?: number;
  investedTotal?: number;
};

function getPilarIcon(id: HealthScorePilar["id"]) {
  switch (id) {
    case "reserva":
      return <ShieldCheck size={16} color="var(--primary, #3b82f6)" />;
    case "endividamento":
      return <Zap size={16} color="var(--warning, #f59e0b)" />;
    case "poupanca":
      return <PiggyBank size={16} color="var(--positive, #22c55e)" />;
    case "investimentos":
      return <TrendingUp size={16} color="var(--accent, #8b5cf6)" />;
  }
}

export function HealthScoreWidget({
  monthlyIncome,
  monthlyExpenses,
  availableCash,
  fixedCommitments = 0,
  investedTotal = 0,
}: HealthScoreWidgetProps) {
  const result = useMemo(
    () =>
      computeFinancialHealthScore({
        monthlyIncome,
        monthlyExpenses,
        availableCash,
        fixedCommitments,
        investedTotal,
      }),
    [monthlyIncome, monthlyExpenses, availableCash, fixedCommitments, investedTotal]
  );

  return (
    <section
      aria-label="Saúde Financeira e Score Inteligente"
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
              background: "rgba(34, 197, 94, 0.15)",
              color: "var(--positive, #22c55e)",
            }}
          >
            <HeartPulse size={20} aria-hidden="true" />
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
              Score de Saúde Financeira
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Diagnóstico 360º ponderado em 4 pilares com metas acionáveis de evolução.
            </p>
          </div>
        </div>

        <span
          style={{
            fontSize: "0.75rem",
            fontWeight: 600,
            padding: "0.3rem 0.6rem",
            borderRadius: "20px",
            background: "rgba(255, 255, 255, 0.08)",
            color: result.tierColor,
            border: `1px solid ${result.tierColor}`,
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
          }}
        >
          <Award size={12} /> {result.overallScore} pts · {result.tierLabel}
        </span>
      </header>

      {/* Grid Principal: Velocímetro / Score + 4 Pilares + Recomendações */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Indicador Visual do Score */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            alignItems: "center",
            textAlign: "center",
          }}
        >
          <span style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
            Pontuação Geral (0 a 1000)
          </span>

          <div style={{ margin: "1.2rem 0" }}>
            <div
              style={{
                fontSize: "3rem",
                fontWeight: 800,
                color: result.tierColor,
                letterSpacing: "-0.03em",
                lineHeight: 1,
              }}
            >
              {result.overallScore}
            </div>
            <div
              style={{
                fontSize: "0.9rem",
                fontWeight: 600,
                color: result.tierColor,
                marginTop: "6px",
              }}
            >
              Nível {result.tierLabel}
            </div>
          </div>

          {/* Régua de Faixas */}
          <div style={{ width: "100%" }}>
            <div
              style={{
                width: "100%",
                height: "8px",
                borderRadius: "4px",
                background: "var(--surface)",
                position: "relative",
                overflow: "hidden",
                display: "flex",
              }}
            >
              <div style={{ width: "40%", background: "#ef4444" }} title="Crítico (0-400)" />
              <div style={{ width: "30%", background: "#f59e0b" }} title="Atenção (401-700)" />
              <div style={{ width: "15%", background: "#22c55e" }} title="Saudável (701-850)" />
              <div style={{ width: "15%", background: "#8b5cf6" }} title="Excelente (851-1000)" />
            </div>

            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                fontSize: "0.65rem",
                color: "var(--muted)",
                marginTop: "4px",
              }}
            >
              <span>0</span>
              <span>400</span>
              <span>700</span>
              <span>850</span>
              <span>1000</span>
            </div>
          </div>
        </div>

        {/* Bloco 2: Detalhamento dos 4 Pilares */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <strong style={{ fontSize: "0.9rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
            Os 4 Pilares da Saúde Financeira
          </strong>

          <div style={{ display: "grid", gap: "10px" }}>
            {result.pillars.map((pilar) => {
              const pilarPercent = Math.round((pilar.score / pilar.maxScore) * 100);

              return (
                <div
                  key={pilar.id}
                  style={{
                    padding: "8px 10px",
                    borderRadius: "8px",
                    background: "var(--surface)",
                    border: "1px solid var(--border)",
                  }}
                >
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "4px" }}>
                    <div style={{ display: "flex", alignItems: "center", gap: "6px" }}>
                      {getPilarIcon(pilar.id)}
                      <strong style={{ fontSize: "0.8rem", color: "var(--text)" }}>
                        {pilar.title}
                      </strong>
                    </div>
                    <span style={{ fontSize: "0.75rem", fontWeight: 700, color: "var(--text)" }}>
                      {pilar.score} <span style={{ color: "var(--muted)", fontWeight: 400 }}>/ {pilar.maxScore}</span>
                    </span>
                  </div>

                  <div style={{ fontSize: "0.7rem", color: "var(--muted)", marginBottom: "6px" }}>
                    {pilar.description}
                  </div>

                  <div
                    style={{
                      width: "100%",
                      height: "4px",
                      borderRadius: "2px",
                      background: "var(--surface-2, rgba(255,255,255,0.08))",
                      overflow: "hidden",
                    }}
                  >
                    <div
                      style={{
                        width: `${pilarPercent}%`,
                        height: "100%",
                        background:
                          pilar.status === "excelente"
                            ? "var(--accent, #8b5cf6)"
                            : pilar.status === "bom"
                            ? "var(--positive, #22c55e)"
                            : pilar.status === "atencao"
                            ? "var(--warning, #f59e0b)"
                            : "var(--destructive, #ef4444)",
                        borderRadius: "2px",
                      }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Bloco 3: Recomendações e Missões para Subir de Nível */}
      {result.tips.length > 0 && (
        <div
          style={{
            marginTop: "1.25rem",
            padding: "1rem 1.2rem",
            borderRadius: "12px",
            background: "rgba(139, 92, 246, 0.06)",
            border: "1px solid rgba(139, 92, 246, 0.2)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", fontSize: "0.85rem", color: "var(--accent, #8b5cf6)", fontWeight: 600, marginBottom: "8px" }}>
            <Lightbulb size={16} /> Missões para Elevar seu Score
          </div>

          <div style={{ display: "grid", gap: "8px" }}>
            {result.tips.map((tip) => (
              <div
                key={tip.id}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  fontSize: "0.8rem",
                  color: "var(--text)",
                }}
              >
                <span>
                  <strong>{tip.title}:</strong> {tip.actionText}
                </span>
                <span
                  style={{
                    fontSize: "0.75rem",
                    fontWeight: 700,
                    color: "var(--positive, #22c55e)",
                    whiteSpace: "nowrap",
                    marginLeft: "8px",
                  }}
                >
                  +{tip.pointsPotential} pts
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </section>
  );
}
