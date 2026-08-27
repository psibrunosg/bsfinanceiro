"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  Calculator,
  Flame,
  Percent,
  Sparkles,
  Zap,
} from "lucide-react";
import type { Transaction } from "./types";
import {
  computeInterestSummary,
  detectHiddenCosts,
  simulatePrepaymentDiscount,
} from "@/lib/finance/interest-radar";
import { money } from "./Money";

type InterestRadarWidgetProps = {
  transactions: Transaction[];
  currentMonth: string;
};

export function InterestRadarWidget({
  transactions,
  currentMonth,
}: InterestRadarWidgetProps) {
  const summary = useMemo(
    () => computeInterestSummary(transactions, currentMonth),
    [transactions, currentMonth]
  );

  const hiddenCostAlerts = useMemo(
    () => detectHiddenCosts(transactions),
    [transactions]
  );

  // Estados do Simulador de Adiantamento
  const [installmentVal, setInstallmentVal] = useState<number>(150);
  const [remainingInstallments, setRemainingInstallments] = useState<number>(6);
  const [discountRate, setDiscountRate] = useState<number>(12); // 12% a.a. padrão Nubank

  const simulation = useMemo(
    () =>
      simulatePrepaymentDiscount({
        installmentValue: installmentVal,
        remainingCount: remainingInstallments,
        annualDiscountRate: discountRate,
      }),
    [installmentVal, remainingInstallments, discountRate]
  );

  return (
    <section
      aria-label="Radar de Juros e Custos Ocultos"
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
              Radar de Juros & Custos Ocultos
            </h2>
            <p
              style={{
                fontSize: "0.8rem",
                color: "var(--muted)",
                margin: 0,
              }}
            >
              Rastreie o ralo financeiro de tarifas, juros bancários e simule economias.
            </p>
          </div>
        </div>

        {summary.hasAlert ? (
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(239, 68, 68, 0.2)",
              color: "var(--destructive, #ef4444)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <AlertTriangle size={12} /> Juros detectados
          </span>
        ) : (
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
            <Sparkles size={12} /> 0 juros pagos
          </span>
        )}
      </header>

      {/* Grid Principal: Métricas do Mês + Simulador */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Total Pago em Juros/Taxas no Mês */}
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
              Total pago em Juros & Tarifas no Mês
            </span>
            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color:
                  summary.totalInterestAndFees > 0
                    ? "var(--destructive, #ef4444)"
                    : "var(--text)",
                marginTop: "0.4rem",
              }}
            >
              {money(summary.totalInterestAndFees)}
            </div>
          </div>

          {summary.items.length > 0 ? (
            <div style={{ marginTop: "1rem" }}>
              <div
                style={{
                  fontSize: "0.75rem",
                  fontWeight: 600,
                  color: "var(--muted)",
                  textTransform: "uppercase",
                  letterSpacing: "0.05em",
                  marginBottom: "0.5rem",
                }}
              >
                Detalhamento dos Custos
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                {summary.items.slice(0, 4).map((item) => (
                  <div
                    key={item.id}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      fontSize: "0.85rem",
                      padding: "4px 0",
                      borderBottom: "1px dashed var(--border)",
                    }}
                  >
                    <span
                      style={{
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        whiteSpace: "nowrap",
                        maxWidth: "180px",
                        color: "var(--text)",
                      }}
                      title={item.description}
                    >
                      {item.description}
                    </span>
                    <strong style={{ color: "var(--destructive, #ef4444)" }}>
                      {money(item.amount)}
                    </strong>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <p style={{ fontSize: "0.85rem", color: "var(--muted)", marginTop: "1rem" }}>
              Nenhum encargo financeiro ou juros identificado no período selecionado.
            </p>
          )}

          {hiddenCostAlerts.length > 0 && (
            <div
              style={{
                marginTop: "1rem",
                padding: "0.75rem",
                borderRadius: "8px",
                background: "rgba(245, 158, 11, 0.1)",
                border: "1px solid rgba(245, 158, 11, 0.3)",
                fontSize: "0.8rem",
                color: "var(--text)",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "6px", fontWeight: 600, color: "var(--warning, #f59e0b)" }}>
                <Zap size={14} /> Custo Oculto Detectado:
              </div>
              {hiddenCostAlerts[0].description} ({money(hiddenCostAlerts[0].amount)})
              <div style={{ fontSize: "0.75rem", color: "var(--muted)", marginTop: "2px" }}>
                {hiddenCostAlerts[0].reason}
              </div>
            </div>
          )}
        </div>

        {/* Bloco 2: Simulador de Adiantamento de Parcelas */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
            <Calculator size={16} color="var(--primary, #3b82f6)" />
            <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
              Simulador de Adiantamento de Parcelas
            </strong>
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr 1fr",
              gap: "10px",
              marginBottom: "1rem",
            }}
          >
            <div>
              <label
                htmlFor="sim-val"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Valor da Parcela (R$)
              </label>
              <input
                id="sim-val"
                type="number"
                min={1}
                step={1}
                value={installmentVal}
                onChange={(e) => setInstallmentVal(Math.max(0, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px 10px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.9rem",
                  fontWeight: 600,
                }}
              />
            </div>

            <div>
              <label
                htmlFor="sim-count"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Parcelas Restantes
              </label>
              <input
                id="sim-count"
                type="number"
                min={1}
                max={60}
                value={remainingInstallments}
                onChange={(e) => setRemainingInstallments(Math.max(0, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px 10px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.9rem",
                  fontWeight: 600,
                }}
              />
            </div>

            <div>
              <label
                htmlFor="sim-rate"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Taxa Desconto (% a.a.)
              </label>
              <input
                id="sim-rate"
                type="number"
                min={1}
                max={100}
                value={discountRate}
                onChange={(e) => setDiscountRate(Math.max(1, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px 10px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.9rem",
                  fontWeight: 600,
                }}
              />
            </div>
          </div>

          {/* Resultado do Desconto */}
          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "rgba(34, 197, 94, 0.1)",
              border: "1px solid rgba(34, 197, 94, 0.25)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
              <span style={{ fontSize: "0.8rem", color: "var(--muted)" }}>
                Economia com desconto:
              </span>
              <strong style={{ fontSize: "1.25rem", color: "var(--positive, #22c55e)" }}>
                + {money(simulation.totalSaved)}
              </strong>
            </div>

            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                fontSize: "0.75rem",
                color: "var(--muted)",
                marginTop: "6px",
              }}
            >
              <span>Total original: {money(simulation.totalOriginal)}</span>
              <span>Você paga: {money(simulation.totalWithDiscount)}</span>
            </div>

            <div
              style={{
                marginTop: "8px",
                display: "flex",
                alignItems: "center",
                gap: "4px",
                fontSize: "0.75rem",
                color: "var(--positive, #22c55e)",
                fontWeight: 600,
              }}
            >
              <Percent size={12} /> Desconto médio de {simulation.discountPercent}% no saldo antecipado
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
