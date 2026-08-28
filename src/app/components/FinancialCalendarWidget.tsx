"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  ArrowDownRight,
  ArrowUpRight,
  Calendar as CalendarIcon,
} from "lucide-react";
import { money } from "./Money";
import {
  computeFinancialCalendar,
  CalendarDay,
} from "@/lib/finance/financial-calendar";

type FinancialCalendarWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date?: string;
  }[];
  currentMonth: string; // YYYY-MM
};

const WEEK_DAYS = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];

export function FinancialCalendarWidget({
  transactions,
  currentMonth,
}: FinancialCalendarWidgetProps) {
  const [selectedDay, setSelectedDay] = useState<CalendarDay | null>(null);

  const cal = useMemo(
    () => computeFinancialCalendar(transactions, currentMonth),
    [transactions, currentMonth]
  );

  // Determina o dia da semana do primeiro dia do mês para alinhar o grid
  const firstDayOfWeek = useMemo(() => {
    const d = new Date(`${currentMonth}-01T12:00:00`);
    return d.getDay();
  }, [currentMonth]);

  const selectedDayTransactions = useMemo(() => {
    if (!selectedDay) return [];
    return transactions.filter(
      (t) => t.competence_date && t.competence_date.slice(0, 10) === selectedDay.date
    );
  }, [transactions, selectedDay]);

  return (
    <section
      aria-label="Calendário Financeiro Visual"
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
            <CalendarIcon size={20} aria-hidden="true" />
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
              Calendário Financeiro Visual
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Visão diária do fluxo de caixa: dias verdes (superávit) vs dias vermelhos (gastos).
            </p>
          </div>
        </div>

        {/* Badges de Resumo */}
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
            <ArrowUpRight size={12} /> {cal.positiveDaysCount} dias positivos
          </span>

          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(239, 68, 68, 0.15)",
              color: "var(--danger, #ef4444)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <ArrowDownRight size={12} /> {cal.negativeDaysCount} dias com saídas
          </span>

          {cal.peakExpenseDay && (
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
              <AlertTriangle size={12} /> Pico: Dia {cal.peakExpenseDay.dayNumber} ({money(cal.peakExpenseDay.expense)})
            </span>
          )}
        </div>
      </header>

      {/* Grade do Calendário */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(7, 1fr)",
          gap: "6px",
          marginBottom: "1rem",
        }}
      >
        {/* Cabeçalho dos dias da semana */}
        {WEEK_DAYS.map((wd) => (
          <div
            key={wd}
            style={{
              textAlign: "center",
              fontSize: "0.7rem",
              fontWeight: 600,
              color: "var(--muted)",
              padding: "4px 0",
            }}
          >
            {wd}
          </div>
        ))}

        {/* Espaços vazios antes do dia 1 */}
        {Array.from({ length: firstDayOfWeek }).map((_, i) => (
          <div key={`empty-${i}`} />
        ))}

        {/* Células dos dias do mês */}
        {cal.daysInMonth.map((day) => {
          const isSelected = selectedDay?.date === day.date;
          let cellBg = "var(--surface-2, rgba(255,255,255,0.03))";
          let borderColor = "var(--border)";
          let netColor = "var(--muted)";

          if (day.status === "positive") {
            cellBg = "rgba(34, 197, 94, 0.08)";
            borderColor = "rgba(34, 197, 94, 0.3)";
            netColor = "var(--positive, #22c55e)";
          } else if (day.status === "negative") {
            cellBg = "rgba(239, 68, 68, 0.08)";
            borderColor = "rgba(239, 68, 68, 0.3)";
            netColor = "var(--danger, #ef4444)";
          }

          if (isSelected) {
            borderColor = "var(--primary, #3b82f6)";
          }

          return (
            <button
              type="button"
              key={day.date}
              onClick={() => setSelectedDay(day)}
              style={{
                padding: "8px 4px",
                borderRadius: "8px",
                background: cellBg,
                border: `1px solid ${borderColor}`,
                textAlign: "center",
                cursor: "pointer",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: "2px",
                minHeight: "56px",
                transition: "all 0.2s ease",
              }}
            >
              <span style={{ fontSize: "0.75rem", fontWeight: 700, color: "var(--text)" }}>
                {day.dayNumber}
              </span>

              {day.txCount > 0 ? (
                <small
                  style={{
                    fontSize: "0.65rem",
                    fontWeight: 600,
                    color: netColor,
                    display: "block",
                    lineHeight: "1.1",
                  }}
                >
                  {day.net > 0 ? `+${money(day.net).split(",")[0]}` : money(day.net).split(",")[0]}
                </small>
              ) : (
                <span style={{ fontSize: "0.6rem", color: "var(--muted)", opacity: 0.5 }}>-</span>
              )}
            </button>
          );
        })}
      </div>

      {/* Detalhe do Dia Selecionado */}
      {selectedDay && (
        <div
          style={{
            padding: "1rem",
            borderRadius: "10px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            marginTop: "10px",
          }}
        >
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "8px" }}>
            <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>
              Movimentações do Dia {selectedDay.dayNumber} ({selectedDay.date})
            </strong>
            <span style={{ fontSize: "0.8rem", fontWeight: 700, color: selectedDay.net >= 0 ? "var(--positive, #22c55e)" : "var(--danger, #ef4444)" }}>
              Saldo do dia: {money(selectedDay.net)}
            </span>
          </div>

          {selectedDayTransactions.length === 0 ? (
            <p style={{ fontSize: "0.75rem", color: "var(--muted)", margin: 0 }}>
              Nenhuma transação individual registrada neste dia.
            </p>
          ) : (
            <div style={{ display: "grid", gap: "4px" }}>
              {selectedDayTransactions.map((tx) => (
                <div
                  key={tx.id}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    fontSize: "0.75rem",
                    padding: "4px 6px",
                    background: "var(--surface)",
                    borderRadius: "4px",
                    border: "1px solid var(--border)",
                  }}
                >
                  <span style={{ color: "var(--text)" }}>{tx.description}</span>
                  <strong style={{ color: tx.type === "income" ? "var(--positive, #22c55e)" : "var(--danger, #ef4444)" }}>
                    {tx.type === "income" ? "+" : "-"}{money(tx.amount)}
                  </strong>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </section>
  );
}
