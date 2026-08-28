"use client";

import { useMemo, useState } from "react";
import {
  AlertTriangle,
  CheckCircle2,
  Compass,
  Scale,
  Wand2,
} from "lucide-react";
import { money } from "./Money";
import {
  compareCashVsInstallment,
  simulateWhatIfScenario,
} from "@/lib/finance/scenario-simulator";

type ScenarioSimulatorWidgetProps = {
  estimatedMonthlyIncome?: number;
  estimatedMonthlyExpenses?: number;
  currentBalance?: number;
};

export function ScenarioSimulatorWidget({
  estimatedMonthlyIncome = 8000,
  estimatedMonthlyExpenses = 6000,
  currentBalance = 5000,
}: ScenarioSimulatorWidgetProps) {
  const [tab, setTab] = useState<"cash_vs_installment" | "what_if">("cash_vs_installment");

  // Estados da Aba 1: À Vista vs Parcelado
  const [productPrice, setProductPrice] = useState("3000");
  const [discountPercent, setDiscountPercent] = useState("10");
  const [installments, setInstallments] = useState("10");

  // Estados da Aba 2: What-If
  const [newExpenseName, setNewExpenseName] = useState("Parcela de Financiamento");
  const [newExpenseAmount, setNewExpenseAmount] = useState("1200");
  const [simulationDuration] = useState<number>(12);

  const numPrice = Number(productPrice.replace(",", ".")) || 0;
  const numDiscount = Number(discountPercent.replace(",", ".")) || 0;
  const numInstallments = Math.max(1, Number(installments) || 1);

  const cashComparison = useMemo(
    () =>
      compareCashVsInstallment({
        fullPrice: numPrice,
        cashDiscountPercent: numDiscount,
        installmentsCount: numInstallments,
        annualCdiPercent: 12.0,
      }),
    [numPrice, numDiscount, numInstallments]
  );

  const numNewExpense = Number(newExpenseAmount.replace(",", ".")) || 0;
  const whatIf = useMemo(
    () =>
      simulateWhatIfScenario({
        currentMonthlyIncome: estimatedMonthlyIncome,
        currentMonthlyExpenses: estimatedMonthlyExpenses,
        newMonthlyCost: numNewExpense,
        durationMonths: simulationDuration,
        initialBalance: currentBalance,
      }),
    [estimatedMonthlyIncome, estimatedMonthlyExpenses, numNewExpense, simulationDuration, currentBalance]
  );

  return (
    <section
      aria-label="Simulador de Cenários e Decisões Financeiras"
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
              background: "rgba(168, 85, 247, 0.15)",
              color: "var(--accent, #a855f7)",
            }}
          >
            <Compass size={20} aria-hidden="true" />
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
              Simulador de Cenários & Máquina do Tempo
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Compare À Vista vs Parcelado no CDI e teste novas despesas antes de assumir dívidas.
            </p>
          </div>
        </div>

        {/* Abas de Navegação */}
        <div style={{ display: "flex", gap: "6px" }}>
          <button
            type="button"
            onClick={() => setTab("cash_vs_installment")}
            style={{
              padding: "4px 10px",
              borderRadius: "6px",
              fontSize: "0.75rem",
              fontWeight: 600,
              border: "1px solid var(--border)",
              background: tab === "cash_vs_installment" ? "var(--accent, #a855f7)" : "var(--surface)",
              color: tab === "cash_vs_installment" ? "#fff" : "var(--muted)",
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Scale size={13} /> À Vista vs 12x
          </button>
          <button
            type="button"
            onClick={() => setTab("what_if")}
            style={{
              padding: "4px 10px",
              borderRadius: "6px",
              fontSize: "0.75rem",
              fontWeight: 600,
              border: "1px solid var(--border)",
              background: tab === "what_if" ? "var(--accent, #a855f7)" : "var(--surface)",
              color: tab === "what_if" ? "#fff" : "var(--muted)",
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Wand2 size={13} /> E Se...? (What-If)
          </button>
        </div>
      </header>

      {/* Conteúdo Aba 1: À Vista vs Parcelado */}
      {tab === "cash_vs_installment" && (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
            gap: "1.25rem",
          }}
        >
          {/* Inputs */}
          <div
            style={{
              padding: "1.2rem",
              borderRadius: "12px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "10px" }}>
              Parâmetros da Compra
            </strong>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px", marginBottom: "10px" }}>
              <div>
                <label htmlFor="pPrice" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Valor da Compra (R$)
                </label>
                <input
                  id="pPrice"
                  type="text"
                  value={productPrice}
                  onChange={(e) => setProductPrice(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
              <div>
                <label htmlFor="pDisc" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Desconto à Vista (%)
                </label>
                <input
                  id="pDisc"
                  type="text"
                  value={discountPercent}
                  onChange={(e) => setDiscountPercent(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
            </div>

            <div>
              <label htmlFor="pInst" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                Parcelas sem juros ({numInstallments}x de {money(cashComparison.installmentValue)})
              </label>
              <input
                id="pInst"
                type="number"
                min={1}
                max={36}
                value={installments}
                onChange={(e) => setInstallments(e.target.value)}
                style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />
            </div>
          </div>

          {/* Veredito Inteligente */}
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
              <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Veredito Financeiro</span>
              <div
                style={{
                  fontSize: "1.2rem",
                  fontWeight: 700,
                  color: cashComparison.bestChoice === "cash" ? "var(--positive, #22c55e)" : "var(--accent, #a855f7)",
                  margin: "6px 0",
                }}
              >
                {cashComparison.bestChoice === "cash"
                  ? "Pagar À Vista com Desconto"
                  : "Parcelar e Rendimento no CDI"}
              </div>
              <p style={{ fontSize: "0.8rem", color: "var(--text)", margin: "4px 0" }}>
                {cashComparison.recommendation}
              </p>
            </div>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                marginTop: "10px",
                fontSize: "0.75rem",
              }}
            >
              <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
                <div style={{ color: "var(--muted)" }}>Valor À Vista</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--positive, #22c55e)" }}>{money(cashComparison.cashPrice)}</strong>
              </div>
              <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
                <div style={{ color: "var(--muted)" }}>Rendimento no CDI</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--accent, #a855f7)" }}>+{money(cashComparison.totalYieldInCdi)}</strong>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Conteúdo Aba 2: E Se...? (What-If) */}
      {tab === "what_if" && (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
            gap: "1.25rem",
          }}
        >
          {/* Parâmetros do Cenário */}
          <div
            style={{
              padding: "1.2rem",
              borderRadius: "12px",
              background: "var(--surface-2, rgba(255,255,255,0.03))",
              border: "1px solid var(--border)",
            }}
          >
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "10px" }}>
              Nova Despesa / Compromisso Futuro
            </strong>

            <div style={{ marginBottom: "8px" }}>
              <label htmlFor="expName" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                Nome do Compromisso
              </label>
              <input
                id="expName"
                type="text"
                value={newExpenseName}
                onChange={(e) => setNewExpenseName(e.target.value)}
                style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />
            </div>

            <div style={{ marginBottom: "8px" }}>
              <label htmlFor="expAmt" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                Parcela Mensal Adicional (R$)
              </label>
              <input
                id="expAmt"
                type="text"
                value={newExpenseAmount}
                onChange={(e) => setNewExpenseAmount(e.target.value)}
                style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />
            </div>
          </div>

          {/* Resultado do Impacto */}
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
              <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "6px" }}>
                {whatIf.isSafe ? (
                  <CheckCircle2 size={18} color="var(--positive, #22c55e)" />
                ) : (
                  <AlertTriangle size={18} color="var(--danger, #ef4444)" />
                )}
                <strong style={{ fontSize: "0.95rem", color: whatIf.isSafe ? "var(--positive, #22c55e)" : "var(--danger, #ef4444)" }}>
                  {whatIf.verdict}
                </strong>
              </div>

              <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: "4px 0" }}>
                Saldo final projetado após 12 meses: <strong>{money(whatIf.finalBalance)}</strong>
              </p>
            </div>

            {/* Linha do tempo resumida dos próximos 6 meses */}
            <div style={{ display: "grid", gridTemplateColumns: "repeat(6, 1fr)", gap: "4px", marginTop: "12px" }}>
              {whatIf.projections.slice(0, 6).map((p) => (
                <div
                  key={p.monthIndex}
                  style={{
                    padding: "4px",
                    borderRadius: "4px",
                    textAlign: "center",
                    fontSize: "0.65rem",
                    background:
                      p.status === "deficit"
                        ? "rgba(239, 68, 68, 0.2)"
                        : p.status === "tight"
                        ? "rgba(245, 158, 11, 0.2)"
                        : "var(--surface)",
                    border: "1px solid var(--border)",
                  }}
                >
                  <div style={{ color: "var(--muted)" }}>Mês {p.monthIndex}</div>
                  <strong style={{ color: p.status === "deficit" ? "var(--danger, #ef4444)" : "var(--text)" }}>
                    {money(p.runningBalance).split(",")[0]}
                  </strong>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
