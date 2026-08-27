"use client";

import { useMemo, useState } from "react";
import {
  Bell,
  CheckCircle2,
  Clapperboard,
  CreditCard,
  Dumbbell,
  Laptop,
  Music,
  PiggyBank,
  Sparkles,
} from "lucide-react";
import { money } from "./Money";
import {
  computeSubscriptionMetrics,
  detectSubscriptions,
  simulateSubscriptionCancellationSavings,
  type DetectedSubscription,
} from "@/lib/finance/subscriptions";

type SubscriptionHubWidgetProps = {
  transactions: { id: string; description: string; amount: number | string; competence_date?: string }[];
  commitments?: { id: string; description: string; amount: number | string; due_day: number }[];
};

function getCategoryIcon(category: DetectedSubscription["category"]) {
  switch (category) {
    case "streaming":
      return <Clapperboard size={16} color="#ef4444" />;
    case "music":
      return <Music size={16} color="#22c55e" />;
    case "software":
      return <Laptop size={16} color="#3b82f6" />;
    case "health_fitness":
      return <Dumbbell size={16} color="#f59e0b" />;
    default:
      return <CreditCard size={16} color="#8b5cf6" />;
  }
}

export function SubscriptionHubWidget({
  transactions,
  commitments = [],
}: SubscriptionHubWidgetProps) {
  const subscriptions = useMemo(
    () => detectSubscriptions(transactions, commitments),
    [transactions, commitments]
  );

  const metrics = useMemo(
    () => computeSubscriptionMetrics(subscriptions),
    [subscriptions]
  );

  // Estados da simulação de economia
  const [selectedSubAmount, setSelectedSubAmount] = useState<number>(() => {
    return subscriptions[0]?.monthlyAmount || 49.9;
  });

  const savingsSim = useMemo(
    () =>
      simulateSubscriptionCancellationSavings({
        monthlyCost: selectedSubAmount,
        annualRatePercent: 12.0,
        years: 5,
      }),
    [selectedSubAmount]
  );

  return (
    <section
      aria-label="Hub de Assinaturas e Recorrências"
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
              background: "rgba(239, 68, 68, 0.15)",
              color: "var(--destructive, #ef4444)",
            }}
          >
            <CreditCard size={20} aria-hidden="true" />
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
              Hub de Assinaturas & Recorrências
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Monitore serviços contínuos (streaming, SaaS, academias) e o impacto anualizado.
            </p>
          </div>
        </div>

        <span
          style={{
            fontSize: "0.75rem",
            fontWeight: 600,
            padding: "0.3rem 0.6rem",
            borderRadius: "20px",
            background: "rgba(239, 68, 68, 0.15)",
            color: "var(--destructive, #ef4444)",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
          }}
        >
          <Sparkles size={12} /> Custo Anualizado: {money(metrics.annualizedCost)}/ano
        </span>
      </header>

      {/* Grid: Métricas + Lista de Assinaturas */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Métricas e Alertas de Vencimento */}
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
            <span style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
              Total Mensal em Assinaturas
            </span>
            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color: "var(--text)",
                marginTop: "0.4rem",
              }}
            >
              {money(metrics.totalMonthly)}
              <span style={{ fontSize: "0.9rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}
                / mês ({metrics.activeCount} serviços)
              </span>
            </div>

            {/* Radar de Vencimentos Próximos */}
            <div style={{ marginTop: "1rem" }}>
              <div
                style={{
                  fontSize: "0.75rem",
                  fontWeight: 600,
                  color: "var(--muted)",
                  marginBottom: "6px",
                  display: "flex",
                  alignItems: "center",
                  gap: "4px",
                }}
              >
                <Bell size={12} color="var(--warning, #f59e0b)" /> Próximas Cobranças (7 dias):
              </div>

              {metrics.upcomingRenewals.length === 0 ? (
                <div
                  style={{
                    fontSize: "0.8rem",
                    color: "var(--muted)",
                    padding: "8px",
                    borderRadius: "8px",
                    background: "var(--surface)",
                  }}
                >
                  <CheckCircle2 size={14} color="var(--positive, #22c55e)" style={{ verticalAlign: "middle", marginRight: 4 }} />
                  Nenhuma renovação nos próximos 7 dias.
                </div>
              ) : (
                <div style={{ display: "grid", gap: "6px" }}>
                  {metrics.upcomingRenewals.map((item) => (
                    <div
                      key={item.id}
                      style={{
                        display: "flex",
                        justifyContent: "space-between",
                        alignItems: "center",
                        padding: "8px 10px",
                        borderRadius: "8px",
                        background: "rgba(245, 158, 11, 0.1)",
                        border: "1px solid rgba(245, 158, 11, 0.25)",
                        fontSize: "0.8rem",
                      }}
                    >
                      <span>
                        <strong>{item.name}</strong> · dia {item.dueDay}{" "}
                        <span style={{ color: "var(--warning, #f59e0b)", fontWeight: 600 }}>
                          ({item.daysRemaining === 0 ? "Hoje" : `em ${item.daysRemaining}d`})
                        </span>
                      </span>
                      <strong style={{ color: "var(--text)" }}>{money(item.amount)}</strong>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Otimizador / Simulador de Cancelamento */}
          <div
            style={{
              marginTop: "1.2rem",
              padding: "10px",
              borderRadius: "10px",
              background: "rgba(139, 92, 246, 0.08)",
              border: "1px solid rgba(139, 92, 246, 0.2)",
            }}
          >
            <div style={{ display: "flex", alignItems: "center", gap: "6px", fontSize: "0.75rem", color: "var(--accent, #8b5cf6)", fontWeight: 600 }}>
              <PiggyBank size={14} /> Potencial de Investimento (5 anos a 12% a.a.)
            </div>
            <div style={{ fontSize: "0.8rem", color: "var(--text)", marginTop: "4px" }}>
              Cancelar uma assinatura de <strong>{money(selectedSubAmount)}/mês</strong> acumularia{" "}
              <strong style={{ color: "var(--positive, #22c55e)" }}>
                {money(savingsSim.totalWithCompoundInterest)}
              </strong>{" "}
              no CDI.
            </div>
          </div>
        </div>

        {/* Bloco 2: Lista de Serviços e Assinaturas */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <strong style={{ fontSize: "0.9rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
            Serviços Identificados
          </strong>

          {subscriptions.length === 0 ? (
            <p style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
              Nenhuma assinatura detectada automaticamente. Lance serviços como Netflix, Spotify ou crie compromissos fixos.
            </p>
          ) : (
            <div style={{ display: "grid", gap: "8px", maxHeight: "280px", overflowY: "auto" }}>
              {subscriptions.map((sub) => (
                <div
                  key={sub.id}
                  onClick={() => setSelectedSubAmount(sub.monthlyAmount)}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "10px 12px",
                    borderRadius: "10px",
                    background: "var(--surface)",
                    border: "1px solid var(--border)",
                    cursor: "pointer",
                  }}
                  title="Clique para simular economia no CDI"
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                    <span
                      style={{
                        display: "inline-flex",
                        alignItems: "center",
                        justifyContent: "center",
                        width: "32px",
                        height: "32px",
                        borderRadius: "8px",
                        background: "var(--surface-2, rgba(255,255,255,0.05))",
                      }}
                    >
                      {getCategoryIcon(sub.category)}
                    </span>
                    <div>
                      <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block" }}>
                        {sub.name}
                      </strong>
                      <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>
                        Vence dia {sub.dueDay} · {money(sub.monthlyAmount * 12)}/ano
                      </span>
                    </div>
                  </div>

                  <b style={{ fontSize: "0.9rem", color: "var(--text)" }}>
                    {money(sub.monthlyAmount)}
                  </b>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
