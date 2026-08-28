"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  LifeBuoy,
  Lock,
  ShieldCheck,
  Sparkles,
  TrendingUp,
} from "lucide-react";
import { money } from "./Money";
import {
  calculateEmergencyFundMetrics,
  simulateWithdrawalImpact,
} from "@/lib/finance/emergency-fund";

type EmergencyFundWidgetProps = {
  monthlyFixedExpenses?: number;
  initialFundBalance?: number;
};

export function EmergencyFundWidget({
  monthlyFixedExpenses = 5000,
  initialFundBalance = 15000,
}: EmergencyFundWidgetProps) {
  const [fundBalance, setFundBalance] = useState<number>(initialFundBalance);
  const [targetMonths, setTargetMonths] = useState<6 | 12>(6);
  const [withdrawInput, setWithdrawInput] = useState("3000");

  const fundMetrics = useMemo(
    () =>
      calculateEmergencyFundMetrics({
        monthlyFixedExpenses,
        currentFundBalance: fundBalance,
        targetMonths,
        annualCdiPercent: 12.0,
      }),
    [monthlyFixedExpenses, fundBalance, targetMonths]
  );

  const numWithdraw = Number(withdrawInput.replace(",", ".")) || 0;
  const guardianSimulation = useMemo(
    () =>
      simulateWithdrawalImpact({
        currentFundBalance: fundBalance,
        monthlyFixedExpenses,
        withdrawAmount: numWithdraw,
      }),
    [fundBalance, monthlyFixedExpenses, numWithdraw]
  );

  function handleQuickDeposit(amount: number) {
    setFundBalance((prev) => prev + amount);
  }

  return (
    <section
      aria-label="Caixinha de Emergência e Guardião de Reserva"
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
              background: "rgba(16, 185, 129, 0.15)",
              color: "var(--positive, #10b981)",
            }}
          >
            <ShieldCheck size={20} aria-hidden="true" />
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
              Caixinha de Emergência Inteligente & Guardião de Reserva
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Proteção do custo de vida essencial, meses de fôlego e alerta contra saques impulsivos.
            </p>
          </div>
        </div>

        {/* Badges de Segurança */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(16, 185, 129, 0.15)",
              color: "var(--positive, #10b981)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <LifeBuoy size={12} /> Fôlego: {fundMetrics.currentRunwayMonths} meses
          </span>

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
            <Sparkles size={12} /> {fundMetrics.progressPercent}% da Meta
          </span>
        </div>
      </header>

      {/* Grid: Termômetro + Guardião de Reserva */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Saldo Guardado & Rendimento */}
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
                Reserva Guardada
              </span>
              <div style={{ display: "flex", gap: "4px" }}>
                <button
                  type="button"
                  onClick={() => setTargetMonths(6)}
                  style={{
                    padding: "3px 6px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: targetMonths === 6 ? "var(--positive, #10b981)" : "var(--surface)",
                    color: targetMonths === 6 ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  6 Meses (CLT)
                </button>
                <button
                  type="button"
                  onClick={() => setTargetMonths(12)}
                  style={{
                    padding: "3px 6px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: targetMonths === 12 ? "var(--positive, #10b981)" : "var(--surface)",
                    color: targetMonths === 12 ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  12 Meses (Autônomo/Clínica)
                </button>
              </div>
            </div>

            <div style={{ fontSize: "1.8rem", fontWeight: 700, color: "var(--text)", marginTop: "0.3rem" }}>
              {money(fundMetrics.currentFundBalance)}
              <span style={{ fontSize: "0.85rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}de {money(fundMetrics.targetAmount)}
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
                  width: `${fundMetrics.progressPercent}%`,
                  height: "100%",
                  background:
                    fundMetrics.progressPercent >= 100
                      ? "var(--positive, #10b981)"
                      : "var(--primary, #3b82f6)",
                  borderRadius: "5px",
                  transition: "width 0.3s ease",
                }}
              />
            </div>

            {/* Rendimento Mensal Seguro */}
            <div
              style={{
                padding: "8px 10px",
                borderRadius: "8px",
                background: "rgba(16, 185, 129, 0.1)",
                border: "1px solid rgba(16, 185, 129, 0.25)",
                fontSize: "0.75rem",
                color: "var(--positive, #10b981)",
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <TrendingUp size={14} /> Rende{" "}
              <strong>+{money(fundMetrics.monthlyYieldCdi)}/mês</strong> com 100% de liquidez diária no CDI.
            </div>
          </div>

          {/* Botões de Aporte Rápido */}
          <div style={{ display: "flex", gap: "6px", marginTop: "1rem" }}>
            <button
              type="button"
              onClick={() => handleQuickDeposit(500)}
              style={{
                flex: 1,
                padding: "6px",
                borderRadius: "6px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                fontSize: "0.75rem",
                fontWeight: 600,
                color: "var(--text)",
                cursor: "pointer",
              }}
            >
              +R$ 500
            </button>
            <button
              type="button"
              onClick={() => handleQuickDeposit(1000)}
              style={{
                flex: 1,
                padding: "6px",
                borderRadius: "6px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                fontSize: "0.75rem",
                fontWeight: 600,
                color: "var(--text)",
                cursor: "pointer",
              }}
            >
              +R$ 1.000
            </button>
          </div>
        </div>

        {/* Bloco 2: Guardião da Reserva (Alerta de Saque) */}
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
            <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
              <Lock size={16} color="var(--warning, #f59e0b)" />
              <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
                Guardião da Reserva (Trava Anti-Impulso)
              </strong>
            </div>

            <p style={{ fontSize: "0.75rem", color: "var(--muted)", margin: "0 0 10px 0" }}>
              Teste uma retirada e veja o impacto exato nos meses de sobrevivência da sua família:
            </p>

            <div style={{ marginBottom: "10px" }}>
              <label htmlFor="wAmt" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                Simular Saque da Reserva (R$)
              </label>
              <input
                id="wAmt"
                type="text"
                value={withdrawInput}
                onChange={(e) => setWithdrawInput(e.target.value)}
                style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />
            </div>

            {/* Mensagem do Guardião */}
            <div
              style={{
                padding: "10px",
                borderRadius: "8px",
                background: "rgba(245, 158, 11, 0.1)",
                border: "1px solid rgba(245, 158, 11, 0.25)",
                fontSize: "0.75rem",
                color: "var(--warning, #f59e0b)",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "6px", fontWeight: 600, marginBottom: "4px" }}>
                <AlertTriangle size={15} /> Impacto do Saque
              </div>
              <p style={{ margin: 0, fontSize: "0.75rem", lineHeight: "1.3" }}>
                {guardianSimulation.warningMessage}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
