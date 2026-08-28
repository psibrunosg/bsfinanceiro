"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  Building2,
  Calendar,
  CheckCircle2,
  CreditCard,
  Receipt,
  Scale,
  TrendingUp,
} from "lucide-react";
import { money } from "./Money";
import {
  computeCashFlowGap,
  computeClinicDRE,
  computePartnerLoanBalance,
  ClinicTransaction,
} from "@/lib/finance/clinic-business";

type ClinicBusinessWidgetProps = {
  transactions: ClinicTransaction[];
  currentMonth: string; // YYYY-MM
  initialCashBalance?: number;
};

type WidgetTab = "dre" | "loans" | "gap";

export function ClinicBusinessWidget({
  transactions,
  currentMonth,
  initialCashBalance = 0,
}: ClinicBusinessWidgetProps) {
  const [tab, setTab] = useState<WidgetTab>("dre");

  const dre = useMemo(
    () => computeClinicDRE(transactions, currentMonth),
    [transactions, currentMonth]
  );

  const loan = useMemo(
    () => computePartnerLoanBalance(transactions),
    [transactions]
  );

  const gap = useMemo(
    () => computeCashFlowGap(transactions, currentMonth, initialCashBalance),
    [transactions, currentMonth, initialCashBalance]
  );

  return (
    <section
      aria-label="Módulo Empresa e Gestão de Consultório"
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
            <Building2 size={20} aria-hidden="true" />
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
              Módulo Empresa (Consultório & PJ)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              DRE gerencial, empréstimos de sócio e descasamento de caixa da clínica.
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
              background: "rgba(34, 197, 94, 0.15)",
              color: "var(--positive, #22c55e)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <TrendingUp size={12} /> Margem: {dre.profitMarginPercent}%
          </span>

          {loan.status === "clinic_owes_partner" && (
            <span
              style={{
                fontSize: "0.75rem",
                fontWeight: 600,
                padding: "0.3rem 0.6rem",
                borderRadius: "20px",
                background: "rgba(245, 158, 11, 0.15)",
                color: "var(--warning, #f59e0b)",
                display: "inline-flex",
                alignItems: "center",
                gap: "4px",
              }}
            >
              <Scale size={12} /> A Reembolsar: {money(loan.pendingBalance)}
            </span>
          )}
        </div>
      </header>

      {/* Navegação de Abas do Widget */}
      <div
        style={{
          display: "flex",
          gap: "8px",
          borderBottom: "1px solid var(--border)",
          paddingBottom: "8px",
          marginBottom: "1rem",
        }}
      >
        <button
          type="button"
          onClick={() => setTab("dre")}
          style={{
            background: tab === "dre" ? "var(--primary, #3b82f6)" : "transparent",
            color: tab === "dre" ? "#fff" : "var(--muted)",
            border: "none",
            borderRadius: "6px",
            padding: "6px 12px",
            fontSize: "0.8rem",
            fontWeight: 600,
            cursor: "pointer",
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
          }}
        >
          <Receipt size={14} /> DRE da Clínica
        </button>

        <button
          type="button"
          onClick={() => setTab("loans")}
          style={{
            background: tab === "loans" ? "var(--primary, #3b82f6)" : "transparent",
            color: tab === "loans" ? "#fff" : "var(--muted)",
            border: "none",
            borderRadius: "6px",
            padding: "6px 12px",
            fontSize: "0.8rem",
            fontWeight: 600,
            cursor: "pointer",
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
          }}
        >
          <CreditCard size={14} /> Empréstimos de Sócio ({loan.unreimbursedItems.length})
        </button>

        <button
          type="button"
          onClick={() => setTab("gap")}
          style={{
            background: tab === "gap" ? "var(--primary, #3b82f6)" : "transparent",
            color: tab === "gap" ? "#fff" : "var(--muted)",
            border: "none",
            borderRadius: "6px",
            padding: "6px 12px",
            fontSize: "0.8rem",
            fontWeight: 600,
            cursor: "pointer",
            display: "inline-flex",
            alignItems: "center",
            gap: "6px",
          }}
        >
          <Calendar size={14} /> Descasamento de Caixa {gap.hasLiquidityGap && "⚠️"}
        </button>
      </div>

      {/* Conteúdo da Aba 1: DRE da Clínica */}
      {tab === "dre" && (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
            gap: "1rem",
          }}
        >
          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <div style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Faturamento Bruto</div>
            <strong style={{ fontSize: "1.3rem", color: "var(--positive, #22c55e)" }}>
              {money(dre.grossRevenue)}
            </strong>
          </div>

          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <div style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Custos Operacionais</div>
            <strong style={{ fontSize: "1.3rem", color: "var(--destructive, #ef4444)" }}>
              -{money(dre.operatingExpenses)}
            </strong>
          </div>

          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <div style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Lucro Líquido da Clínica</div>
            <strong style={{ fontSize: "1.3rem", color: "var(--text)" }}>
              {money(dre.operatingProfit)}
            </strong>
          </div>

          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <div style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Pró-Labore Transferido</div>
            <strong style={{ fontSize: "1.3rem", color: "var(--accent, #8b5cf6)" }}>
              {money(dre.proLaboreWithdrawn)}
            </strong>
          </div>
        </div>
      )}

      {/* Conteúdo da Aba 2: Empréstimos de Sócio */}
      {tab === "loans" && (
        <div>
          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
              marginBottom: "1rem",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              flexWrap: "wrap",
              gap: "8px",
            }}
          >
            <div>
              <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
                {loan.status === "clinic_owes_partner"
                  ? "A clínica deve ao sócio (despesas pagas na conta pessoal):"
                  : loan.status === "partner_owes_clinic"
                  ? "O sócio deve à clínica:"
                  : "Contas e reembolsos conciliados!"}
              </strong>
              <div style={{ fontSize: "0.75rem", color: "var(--muted)", marginTop: "2px" }}>
                Total adiantado pelo sócio: {money(loan.totalLentByPartner)} · Reembolsado: {money(loan.totalReimbursed)}
              </div>
            </div>

            <div style={{ fontSize: "1.4rem", fontWeight: 700, color: "var(--warning, #f59e0b)" }}>
              {money(loan.pendingBalance)}
            </div>
          </div>

          {loan.unreimbursedItems.length === 0 ? (
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Nenhuma despesa da clínica paga com dinheiro/cartão pessoal detectada.
            </p>
          ) : (
            <div style={{ display: "grid", gap: "6px", maxHeight: "180px", overflowY: "auto" }}>
              {loan.unreimbursedItems.map((item) => (
                <div
                  key={item.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 10px",
                    borderRadius: "6px",
                    background: "var(--surface)",
                    border: "1px solid var(--border)",
                    fontSize: "0.8rem",
                  }}
                >
                  <div>
                    <span style={{ fontWeight: 600, color: "var(--text)" }}>{item.description}</span>
                    <small style={{ display: "block", color: "var(--muted)", fontSize: "0.7rem" }}>
                      {item.date} · Pago no cartão pessoal
                    </small>
                  </div>
                  <strong style={{ color: "var(--warning, #f59e0b)" }}>
                    {money(item.amount)}
                  </strong>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Conteúdo da Aba 3: Descasamento de Caixa */}
      {tab === "gap" && (
        <div>
          {gap.hasLiquidityGap ? (
            <div
              style={{
                padding: "1rem",
                borderRadius: "10px",
                background: "rgba(245, 158, 11, 0.1)",
                border: "1px solid rgba(245, 158, 11, 0.3)",
                fontSize: "0.8rem",
                color: "var(--text)",
                marginBottom: "1rem",
                display: "flex",
                alignItems: "center",
                gap: "10px",
              }}
            >
              <AlertTriangle size={24} color="var(--warning, #f59e0b)" />
              <div>
                <strong>Alerta de Descasamento de Liquidez!</strong>
                <p style={{ margin: "2px 0 0", color: "var(--muted)", fontSize: "0.75rem" }}>
                  As contas da clínica (Aluguel, CRP) vencem no dia {gap.maxDeficitDay}, gerando um déficit temporário de{" "}
                  <strong>{money(gap.maxDeficitAmount)}</strong> antes que os pacientes paguem no dia {gap.gapResolutionDay}.
                  Recomendado manter um capital de giro de <strong>{money(gap.workingCapitalNeeded)}</strong>.
                </p>
              </div>
            </div>
          ) : (
            <div
              style={{
                padding: "1rem",
                borderRadius: "10px",
                background: "rgba(34, 197, 94, 0.1)",
                border: "1px solid rgba(34, 197, 94, 0.25)",
                fontSize: "0.8rem",
                color: "var(--positive, #22c55e)",
                display: "flex",
                alignItems: "center",
                gap: "8px",
              }}
            >
              <CheckCircle2 size={18} /> Fluxo de caixa sincronizado! As entradas cobrem os vencimentos sem déficit.
            </div>
          )}
        </div>
      )}
    </section>
  );
}
