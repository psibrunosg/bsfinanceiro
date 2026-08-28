"use client";

import { useMemo, useState } from "react";
import {
  Award,
  Check,
  Flame,
  Share2,
  Sparkles,
  Trophy,
} from "lucide-react";
import { money } from "./Money";
import { computeAnnualWrapped } from "@/lib/finance/annual-wrapped";

type AnnualWrappedWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date?: string;
    category_name?: string;
  }[];
  investmentsTotal?: number;
  year?: number;
};

export function AnnualWrappedWidget({
  transactions,
  investmentsTotal = 0,
  year = new Date().getFullYear(),
}: AnnualWrappedWidgetProps) {
  const [copied, setCopied] = useState(false);

  const wrapped = useMemo(
    () => computeAnnualWrapped(transactions, investmentsTotal, year),
    [transactions, investmentsTotal, year]
  );

  function handleCopyShare() {
    if (typeof navigator !== "undefined" && navigator?.clipboard?.writeText) {
      navigator.clipboard.writeText(wrapped.shareableSummaryText).catch(() => {});
    }
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  }

  return (
    <section
      aria-label="Relatório Anual Wrapped"
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
              background: "rgba(234, 179, 8, 0.15)",
              color: "var(--warning, #eab308)",
            }}
          >
            <Trophy size={20} aria-hidden="true" />
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
              Relatório Anual Wrapped {year}
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Sua retrospectiva financeira do ano: conquistas, categoria campeã e perfil financeiro.
            </p>
          </div>
        </div>

        {/* Badges de Conquistas */}
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
            <Sparkles size={12} /> Taxa de Poupança: {wrapped.savingsRatePercent}%
          </span>

          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(234, 179, 8, 0.15)",
              color: "var(--warning, #eab308)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Award size={12} /> {wrapped.financialPersonality.badgeTitle}
          </span>
        </div>
      </header>

      {/* Grid: Card Estilo Stories + Detalhes */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Card Estilo Stories Compartilhável */}
        <div
          style={{
            padding: "1.5rem",
            borderRadius: "16px",
            background: "linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.95))",
            border: "1px solid rgba(234, 179, 8, 0.3)",
            boxShadow: "0 10px 30px rgba(0,0,0,0.3)",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            color: "#fff",
          }}
        >
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1rem" }}>
              <span style={{ fontSize: "0.75rem", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px", color: "var(--warning, #eab308)" }}>
                ✨ Retrospectiva {year}
              </span>
              <Flame size={18} color="var(--warning, #eab308)" />
            </div>

            <span style={{ fontSize: "0.85rem", color: "rgba(255,255,255,0.7)" }}>
              Você economizou este ano:
            </span>
            <div style={{ fontSize: "2rem", fontWeight: 800, color: "#fff", margin: "4px 0 10px" }}>
              {money(wrapped.totalSavedYear)}
            </div>

            <p style={{ fontSize: "0.8rem", color: "rgba(255,255,255,0.8)", margin: "0 0 1rem", lineHeight: "1.4" }}>
              {wrapped.financialPersonality.tagline}
            </p>
          </div>

          <button
            type="button"
            onClick={handleCopyShare}
            style={{
              padding: "8px 12px",
              borderRadius: "8px",
              background: "rgba(234, 179, 8, 0.2)",
              border: "1px solid rgba(234, 179, 8, 0.5)",
              color: "var(--warning, #eab308)",
              fontSize: "0.75rem",
              fontWeight: 700,
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              justifyContent: "center",
              gap: "6px",
            }}
          >
            {copied ? <Check size={14} /> : <Share2 size={14} />}
            {copied ? "Copiado para a área de transferência!" : "Compartilhar Meu Wrapped"}
          </button>
        </div>

        {/* Bloco 2: Conquistas & Top Categorias */}
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
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
              Top 3 Categorias de Gastos no Ano
            </strong>

            {wrapped.topCategories.length === 0 ? (
              <p style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Nenhum gasto registrado neste ano.</p>
            ) : (
              <div style={{ display: "grid", gap: "8px" }}>
                {wrapped.topCategories.map((cat, idx) => (
                  <div
                    key={cat.categoryName}
                    style={{
                      padding: "8px 10px",
                      borderRadius: "8px",
                      background: "var(--surface)",
                      border: "1px solid var(--border)",
                      fontSize: "0.8rem",
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    <span>
                      <strong>#{idx + 1} {cat.categoryName}</strong>
                      <small style={{ color: "var(--muted)", display: "block", fontSize: "0.7rem" }}>
                        {cat.percent}% do total de gastos
                      </small>
                    </span>
                    <strong style={{ color: "var(--text)" }}>{money(cat.amount)}</strong>
                  </div>
                ))}
              </div>
            )}
          </div>

          {wrapped.bestMonth && (
            <div
              style={{
                marginTop: "1rem",
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
              <Trophy size={14} /> Mês de Maior Economia:{" "}
              <strong>{wrapped.bestMonth.monthName} (+{money(wrapped.bestMonth.savedAmount)})</strong>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
