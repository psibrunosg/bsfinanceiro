"use client";

import { useMemo, useState } from "react";
import {
  Calendar,
  CheckCircle,
  Receipt,
  Sparkles,
} from "lucide-react";
import { money } from "./Money";
import {
  computeMonthlyTaxReport,
  detectLivroCaixaDeductions,
} from "@/lib/finance/tax-radar";

type TaxRadarWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date?: string;
  }[];
  currentMonth: string; // YYYY-MM
  dependentsCount?: number;
};

export function TaxRadarWidget({
  transactions,
  currentMonth,
  dependentsCount = 0,
}: TaxRadarWidgetProps) {
  // Extrai faturamento bruto (income) do mês
  const grossIncome = useMemo(() => {
    const prefix = currentMonth.slice(0, 7);
    return transactions
      .filter((t) => t.type === "income" && (t.competence_date || "").slice(0, 7) === prefix)
      .reduce((sum, t) => sum + Math.abs(Number(t.amount) || 0), 0);
  }, [transactions, currentMonth]);

  // Identifica despesas dedutíveis do livro-caixa
  const livroCaixa = useMemo(
    () => detectLivroCaixaDeductions(transactions, currentMonth),
    [transactions, currentMonth]
  );

  const [inssAmount] = useState<number>(0);
  const [dependents, setDependents] = useState<number>(dependentsCount);

  const report = useMemo(
    () =>
      computeMonthlyTaxReport({
        grossIncome,
        deductibleExpenses: livroCaixa.totalDeductible,
        inssDeduction: inssAmount,
        dependentsCount: dependents,
        month: currentMonth,
      }),
    [grossIncome, livroCaixa.totalDeductible, inssAmount, dependents, currentMonth]
  );

  return (
    <section
      aria-label="Radar de Impostos e Estimador de Carnê-Leão"
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
            <Receipt size={20} aria-hidden="true" />
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
              Radar de Impostos & Carnê-Leão (IRPF)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Estimativa do DARF mensal, livro-caixa de consultório e alíquota efetiva real.
            </p>
          </div>
        </div>

        {report.estimatedDARF > 0 ? (
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
            <Calendar size={12} /> DARF Estimado: {money(report.estimatedDARF)} ({report.darfDueDateLabel})
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
            <CheckCircle size={12} /> Isento de IRPF este mês
          </span>
        )}
      </header>

      {/* Grid: Resumo Tributário + Livro-Caixa */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Métricas do DARF & Alíquota Efetiva */}
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
              DARF Carnê-Leão ({report.monthLabel})
            </span>
            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color: report.estimatedDARF > 0 ? "var(--destructive, #ef4444)" : "var(--positive, #22c55e)",
                marginTop: "0.4rem",
              }}
            >
              {money(report.estimatedDARF)}
              <span style={{ fontSize: "0.85rem", color: "var(--muted)", fontWeight: 500 }}>
                {" "}
                (Alíquota Efetiva: {report.effectiveRatePercent}%)
              </span>
            </div>

            {/* Grid com Receita vs Deduções */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                margin: "1rem 0",
                fontSize: "0.75rem",
              }}
            >
              <div
                style={{
                  padding: "8px",
                  borderRadius: "6px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                }}
              >
                <div style={{ color: "var(--muted)" }}>Receita Bruta</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
                  {money(report.grossIncome)}
                </strong>
              </div>

              <div
                style={{
                  padding: "8px",
                  borderRadius: "6px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                }}
              >
                <div style={{ color: "var(--muted)" }}>Deduções (Livro-Caixa)</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--positive, #22c55e)" }}>
                  -{money(report.totalDeductions)}
                </strong>
              </div>
            </div>

            {/* Economia Fiscal */}
            {report.taxSavingsFromDeductions > 0 && (
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
                <Sparkles size={14} /> ✨ Seu Livro-Caixa economizou{" "}
                <strong>{money(report.taxSavingsFromDeductions)}</strong> em imposto este mês!
              </div>
            )}
          </div>

          {/* Dica de Provisão por Atendimento */}
          {report.recommendedProvisionPercent > 0 && (
            <div style={{ marginTop: "1rem", fontSize: "0.75rem", color: "var(--muted)" }}>
              💡 <strong>Dica Prática:</strong> Reserve <strong>{report.recommendedProvisionPercent}%</strong> de cada consulta/recebimento para a conta do DARF.
            </div>
          )}
        </div>

        {/* Bloco 2: Livro-Caixa (Despesas Dedutíveis Identificadas) */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.8rem" }}>
            <strong style={{ fontSize: "0.85rem", color: "var(--text)" }}>
              Livro-Caixa Dedutível ({livroCaixa.items.length} itens)
            </strong>
            <span style={{ fontSize: "0.8rem", fontWeight: 700, color: "var(--positive, #22c55e)" }}>
              {money(livroCaixa.totalDeductible)}
            </span>
          </div>

          {livroCaixa.items.length === 0 ? (
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Nenhuma despesa dedutível de consultório identificada (Aluguel, CRP, Cursos, Internet).
            </p>
          ) : (
            <div style={{ display: "grid", gap: "6px", maxHeight: "180px", overflowY: "auto" }}>
              {livroCaixa.items.map((item) => (
                <div
                  key={item.id}
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
                  <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", maxWidth: "180px" }}>
                    {item.description}
                  </span>
                  <strong style={{ color: "var(--positive, #22c55e)" }}>
                    -{money(item.amount)}
                  </strong>
                </div>
              ))}
            </div>
          )}

          {/* Ajuste de Dependentes */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: "1rem", paddingTop: "0.8rem", borderTop: "1px solid var(--border)", fontSize: "0.75rem" }}>
            <span style={{ color: "var(--muted)" }}>Dependentes legais:</span>
            <div style={{ display: "flex", gap: "4px" }}>
              {[0, 1, 2, 3].map((num) => (
                <button
                  key={num}
                  type="button"
                  onClick={() => setDependents(num)}
                  style={{
                    padding: "2px 6px",
                    fontSize: "0.7rem",
                    borderRadius: "4px",
                    border: "1px solid var(--border)",
                    background: dependents === num ? "var(--primary, #3b82f6)" : "var(--surface)",
                    color: dependents === num ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  {num}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
