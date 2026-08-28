"use client";

import { useMemo, useState } from "react";
import {
  CalendarClock,
  CheckCircle,
  Unlock,
} from "lucide-react";
import { money } from "./Money";
import {
  buildInstallmentTimeline,
  computeFinancialReliefSchedule,
  extractInstallmentPurchases,
} from "@/lib/finance/installment-timeline";
import { monthLabel } from "@/lib/finance/local-date";

type InstallmentTimelineWidgetProps = {
  invoices?: {
    id: string;
    due_date: string;
    credit_card_installments?:
      | {
          amount: number | string;
          installment_number: number;
          credit_card_purchases?:
            | { description: string; installment_count: number }
            | { description: string; installment_count: number }[]
            | null;
        }[]
      | null;
  }[];
  transactions?: {
    id: string;
    description: string;
    amount: number | string;
    competence_date?: string;
  }[];
  currentMonth: string; // YYYY-MM
};

export function InstallmentTimelineWidget({
  invoices = [],
  transactions = [],
  currentMonth,
}: InstallmentTimelineWidgetProps) {
  const purchases = useMemo(
    () => extractInstallmentPurchases(invoices, transactions),
    [invoices, transactions]
  );

  const timeline = useMemo(
    () => buildInstallmentTimeline(purchases, currentMonth, 6),
    [purchases, currentMonth]
  );

  const relief = useMemo(
    () => computeFinancialReliefSchedule(purchases, currentMonth),
    [purchases, currentMonth]
  );

  const [selectedMonthIndex, setSelectedMonthIndex] = useState<number>(0);
  const selectedTimelineMonth = timeline[selectedMonthIndex] || timeline[0];

  const maxMonthAmount = useMemo(
    () => Math.max(...timeline.map((t) => t.totalAmount), 1),
    [timeline]
  );

  return (
    <section
      aria-label="Rastreador de Parcelamentos e Linha do Tempo"
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
            <CalendarClock size={20} aria-hidden="true" />
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
              Rastreador de Parcelamentos & Linha do Tempo
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Visualize o comprometimento futuro do seu cartão e quando cada dívida acaba.
            </p>
          </div>
        </div>

        {relief.nextReliefMonth && relief.nextReliefAmount > 0 ? (
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
            <Unlock size={12} /> Próximo Alívio: +{money(relief.nextReliefAmount)}/mês em{" "}
            {monthLabel(`${relief.nextReliefMonth}-01`)}
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
            <CheckCircle size={12} /> Sem parcelas futuras
          </span>
        )}
      </header>

      {/* Grid: Linha do Tempo dos Próximos Meses + Compras Ativas */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Linha do Tempo Visual dos 6 Meses */}
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
              Comprometimento em {selectedTimelineMonth.monthLabel}
            </span>
            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color: "var(--text)",
                marginTop: "0.4rem",
              }}
            >
              {money(selectedTimelineMonth.totalAmount)}
              <span style={{ fontSize: "0.9rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}
                ({selectedTimelineMonth.activeCount} parcelas ativas)
              </span>
            </div>

            {/* Gráfico de Barras dos Próximos 6 Meses */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(6, 1fr)",
                gap: "8px",
                alignItems: "flex-end",
                height: "120px",
                marginTop: "1.2rem",
                padding: "8px 0",
                borderBottom: "1px solid var(--border)",
              }}
            >
              {timeline.map((t, idx) => {
                const heightPercent = Math.max(8, Math.round((t.totalAmount / maxMonthAmount) * 100));
                const isSelected = idx === selectedMonthIndex;

                return (
                  <div
                    key={t.month}
                    onClick={() => setSelectedMonthIndex(idx)}
                    style={{
                      display: "flex",
                      flexDirection: "column",
                      alignItems: "center",
                      height: "100%",
                      justifyContent: "flex-end",
                      cursor: "pointer",
                    }}
                    title={`${t.monthLabel}: ${money(t.totalAmount)}`}
                  >
                    <span style={{ fontSize: "0.65rem", color: "var(--muted)", marginBottom: "4px" }}>
                      {money(t.totalAmount).split(",")[0]}
                    </span>
                    <div
                      style={{
                        width: "100%",
                        height: `${heightPercent}%`,
                        borderRadius: "6px 6px 0 0",
                        background: isSelected
                          ? "var(--primary, #3b82f6)"
                          : "rgba(59, 130, 246, 0.35)",
                        transition: "all 0.2s ease",
                      }}
                    />
                    <span
                      style={{
                        fontSize: "0.7rem",
                        marginTop: "6px",
                        color: isSelected ? "var(--text)" : "var(--muted)",
                        fontWeight: isSelected ? 700 : 400,
                      }}
                    >
                      {t.monthLabel.split("/")[0]}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Destaque das Parcelas do Mês Selecionado */}
          <div style={{ marginTop: "1rem" }}>
            <strong style={{ fontSize: "0.8rem", color: "var(--muted)", display: "block", marginBottom: "6px" }}>
              Parcelas de {selectedTimelineMonth.monthLabel}:
            </strong>

            {selectedTimelineMonth.items.length === 0 ? (
              <p style={{ fontSize: "0.8rem", color: "var(--positive, #22c55e)", margin: 0 }}>
                🎉 Você estará livre de todas as parcelas atuais neste mês!
              </p>
            ) : (
              <div style={{ display: "grid", gap: "6px", maxHeight: "140px", overflowY: "auto" }}>
                {selectedTimelineMonth.items.map((item, i) => (
                  <div
                    key={`${item.purchaseId}-${i}`}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      fontSize: "0.8rem",
                      padding: "6px 8px",
                      borderRadius: "6px",
                      background: "var(--surface)",
                      border: "1px solid var(--border)",
                    }}
                  >
                    <span>
                      {item.description} ({item.installmentNumber}/{item.totalInstallments})
                    </span>
                    <strong>{money(item.amount)}</strong>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Bloco 2: Lista das Compras Parceladas e Progresso */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <strong style={{ fontSize: "0.9rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
            Compras Parceladas Ativas ({purchases.length})
          </strong>

          {purchases.length === 0 ? (
            <p style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
              Nenhuma compra parcelada identificada nas faturas ou extratos.
            </p>
          ) : (
            <div style={{ display: "grid", gap: "8px", maxHeight: "320px", overflowY: "auto" }}>
              {purchases.map((p) => {
                const progressPct = Math.min(100, Math.round((p.currentInstallment / p.totalInstallments) * 100));

                return (
                  <div
                    key={p.id}
                    style={{
                      padding: "10px 12px",
                      borderRadius: "10px",
                      background: "var(--surface)",
                      border: "1px solid var(--border)",
                    }}
                  >
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginBottom: "4px" }}>
                      <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>
                        {p.description}
                      </strong>
                      <b style={{ fontSize: "0.85rem", color: "var(--text)" }}>
                        {money(p.installmentAmount)}
                        <span style={{ fontSize: "0.75rem", color: "var(--muted)", fontWeight: 400 }}>
                          /mês
                        </span>
                      </b>
                    </div>

                    <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", color: "var(--muted)", marginBottom: "6px" }}>
                      <span>
                        Parcela {p.currentInstallment} de {p.totalInstallments} ({p.remainingInstallments} restantes)
                      </span>
                      <span>{progressPct}% pago</span>
                    </div>

                    <div
                      style={{
                        width: "100%",
                        height: "6px",
                        borderRadius: "3px",
                        background: "var(--surface-2, rgba(255,255,255,0.08))",
                        overflow: "hidden",
                      }}
                    >
                      <div
                        style={{
                          width: `${progressPct}%`,
                          height: "100%",
                          background:
                            progressPct >= 80
                              ? "var(--positive, #22c55e)"
                              : "var(--primary, #3b82f6)",
                          borderRadius: "3px",
                        }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
