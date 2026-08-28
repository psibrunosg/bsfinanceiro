"use client";

import { useMemo, useState } from "react";
import {
  ArrowRightLeft,
  CheckCircle2,
  Heart,
  Plus,
  Sparkles,
} from "lucide-react";
import { money } from "./Money";
import {
  computeCoupleFinances,
  detectCoupleTransactions,
  CoupleExpenseItem,
} from "@/lib/finance/couple-finance";

type CoupleFinanceWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date?: string;
    context_name?: string;
  }[];
  currentMonth: string; // YYYY-MM
  partnerAName?: string;
  partnerBName?: string;
};

export function CoupleFinanceWidget({
  transactions,
  currentMonth,
  partnerAName = "Você",
  partnerBName = "Parceira(o)",
}: CoupleFinanceWidgetProps) {
  const [splitMode, setSplitMode] = useState<"equal_50_50" | "proportional_by_income">("equal_50_50");
  const [partnerAIncome, setPartnerAIncome] = useState<number>(10000);
  const [partnerBIncome, setPartnerBIncome] = useState<number>(6000);
  const [manualExpenses, setManualExpenses] = useState<CoupleExpenseItem[]>([]);

  // Despesas automáticas detectadas no extrato
  const autoExpenses = useMemo(
    () => detectCoupleTransactions(transactions, currentMonth),
    [transactions, currentMonth]
  );

  const allExpenses = useMemo(
    () => [...autoExpenses, ...manualExpenses],
    [autoExpenses, manualExpenses]
  );

  const result = useMemo(
    () =>
      computeCoupleFinances({
        expenses: allExpenses,
        splitMode,
        partnerAIncome,
        partnerBIncome,
        partnerAName,
        partnerBName,
      }),
    [allExpenses, splitMode, partnerAIncome, partnerBIncome, partnerAName, partnerBName]
  );

  const [newDesc, setNewDesc] = useState("");
  const [newAmount, setNewAmount] = useState("");
  const [newPayer, setNewPayer] = useState<"partner_a" | "partner_b">("partner_a");

  function handleAddExpense(e: React.FormEvent) {
    e.preventDefault();
    const val = Number(newAmount.replace(",", "."));
    if (!newDesc || isNaN(val) || val <= 0) return;

    setManualExpenses((prev) => [
      ...prev,
      {
        id: `couple-man-${Date.now()}`,
        description: newDesc,
        amount: val,
        payer: newPayer,
        date: currentMonth,
      },
    ]);

    setNewDesc("");
    setNewAmount("");
  }

  return (
    <section
      aria-label="Módulo Casal e Finanças Compartilhadas"
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
              background: "rgba(236, 72, 153, 0.15)",
              color: "var(--accent, #ec4899)",
            }}
          >
            <Heart size={20} aria-hidden="true" />
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
              Modo Casal & Finanças a Dois
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Divisão justa de gastos compartilhados, quem pagou mais e acerto de contas sem atrito.
            </p>
          </div>
        </div>

        {/* Badges de Status */}
        <div style={{ display: "flex", gap: "6px", flexWrap: "wrap" }}>
          {result.debtor !== "settled" ? (
            <span
              style={{
                fontSize: "0.75rem",
                fontWeight: 600,
                padding: "0.3rem 0.6rem",
                borderRadius: "20px",
                background: "rgba(236, 72, 153, 0.15)",
                color: "var(--accent, #ec4899)",
                display: "inline-flex",
                alignItems: "center",
                gap: "4px",
              }}
            >
              <ArrowRightLeft size={12} /> {result.statusMessage}
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
              <CheckCircle2 size={12} /> Contas equilibradas!
            </span>
          )}
        </div>
      </header>

      {/* Grid: Termômetro do Casal + Lista de Gastos */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Termômetro de Equilíbrio e Seletor de Divisão */}
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
                Total Gasto Juntos no Mês
              </span>
              <div style={{ display: "flex", gap: "4px" }}>
                <button
                  type="button"
                  onClick={() => setSplitMode("equal_50_50")}
                  style={{
                    padding: "3px 8px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: splitMode === "equal_50_50" ? "var(--accent, #ec4899)" : "var(--surface)",
                    color: splitMode === "equal_50_50" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  50% / 50%
                </button>
                <button
                  type="button"
                  onClick={() => setSplitMode("proportional_by_income")}
                  style={{
                    padding: "3px 8px",
                    borderRadius: "4px",
                    fontSize: "0.7rem",
                    fontWeight: 600,
                    border: "1px solid var(--border)",
                    background: splitMode === "proportional_by_income" ? "var(--accent, #ec4899)" : "var(--surface)",
                    color: splitMode === "proportional_by_income" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                  }}
                >
                  Por Renda
                </button>
              </div>
            </div>

            <div style={{ fontSize: "1.8rem", fontWeight: 700, color: "var(--text)", marginTop: "0.3rem" }}>
              {money(result.totalSharedExpenses)}
            </div>

            {splitMode === "proportional_by_income" && (
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px", margin: "8px 0", fontSize: "0.75rem" }}>
                <div>
                  <label htmlFor="pAIncome" style={{ color: "var(--muted)", display: "block", fontSize: "0.7rem" }}>Renda {partnerAName}</label>
                  <input
                    id="pAIncome"
                    type="number"
                    value={partnerAIncome}
                    onChange={(e) => setPartnerAIncome(Number(e.target.value) || 0)}
                    style={{ width: "100%", padding: "2px 6px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                  />
                </div>
                <div>
                  <label htmlFor="pBIncome" style={{ color: "var(--muted)", display: "block", fontSize: "0.7rem" }}>Renda {partnerBName}</label>
                  <input
                    id="pBIncome"
                    type="number"
                    value={partnerBIncome}
                    onChange={(e) => setPartnerBIncome(Number(e.target.value) || 0)}
                    style={{ width: "100%", padding: "2px 6px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                  />
                </div>
              </div>
            )}

            {/* Barra Bicolor de Divisão */}
            <div style={{ marginTop: "1rem" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", marginBottom: "4px" }}>
                <span style={{ color: "var(--primary, #3b82f6)" }}>
                  {partnerAName} pagou {money(result.totalPaidByPartnerA)}
                </span>
                <span style={{ color: "var(--accent, #ec4899)" }}>
                  {partnerBName} pagou {money(result.totalPaidByPartnerB)}
                </span>
              </div>
              <div
                style={{
                  width: "100%",
                  height: "10px",
                  borderRadius: "5px",
                  background: "var(--surface)",
                  overflow: "hidden",
                  display: "flex",
                }}
              >
                <div
                  style={{
                    width: `${result.totalSharedExpenses > 0 ? (result.totalPaidByPartnerA / result.totalSharedExpenses) * 100 : 50}%`,
                    background: "var(--primary, #3b82f6)",
                    transition: "width 0.3s ease",
                  }}
                />
                <div
                  style={{
                    width: `${result.totalSharedExpenses > 0 ? (result.totalPaidByPartnerB / result.totalSharedExpenses) * 100 : 50}%`,
                    background: "var(--accent, #ec4899)",
                    transition: "width 0.3s ease",
                  }}
                />
              </div>
            </div>

            {/* Cota Justa de Cada Um */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                marginTop: "1rem",
                fontSize: "0.75rem",
              }}
            >
              <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
                <div style={{ color: "var(--muted)" }}>Cota justa {partnerAName} ({result.partnerASharePercent}%)</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>{money(result.fairSharePartnerA)}</strong>
              </div>
              <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
                <div style={{ color: "var(--muted)" }}>Cota justa {partnerBName} ({result.partnerBSharePercent}%)</div>
                <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>{money(result.fairSharePartnerB)}</strong>
              </div>
            </div>
          </div>

          {/* Acerto Final */}
          {result.debtor !== "settled" && (
            <div
              style={{
                padding: "8px 10px",
                borderRadius: "8px",
                background: "rgba(236, 72, 153, 0.1)",
                border: "1px solid rgba(236, 72, 153, 0.25)",
                fontSize: "0.75rem",
                color: "var(--accent, #ec4899)",
                marginTop: "1rem",
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <Sparkles size={14} /> Pix de acerto recomendado: <strong>{money(result.settlementAmount)}</strong>
            </div>
          )}
        </div>

        {/* Bloco 2: Lista de Despesas Compartilhadas e Lançamento */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
            Gastos Compartilhados ({allExpenses.length})
          </strong>

          {allExpenses.length === 0 ? (
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Nenhum gasto do casal identificado este mês. Adicione abaixo!
            </p>
          ) : (
            <div style={{ display: "grid", gap: "6px", maxHeight: "160px", overflowY: "auto" }}>
              {allExpenses.map((exp) => (
                <div
                  key={exp.id}
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
                  <div>
                    <span style={{ fontWeight: 600, color: "var(--text)" }}>{exp.description}</span>
                    <small style={{ display: "block", color: "var(--muted)", fontSize: "0.7rem" }}>
                      Pago por: {exp.payer === "partner_a" ? partnerAName : partnerBName}
                    </small>
                  </div>
                  <strong style={{ color: "var(--text)" }}>
                    {money(exp.amount)}
                  </strong>
                </div>
              ))}
            </div>
          )}

          {/* Form Rápido de Novo Gasto do Casal */}
          <form
            onSubmit={handleAddExpense}
            style={{
              marginTop: "1rem",
              paddingTop: "0.8rem",
              borderTop: "1px solid var(--border)",
              display: "grid",
              gridTemplateColumns: "2fr 1fr 1fr auto",
              gap: "6px",
            }}
          >
            <input
              type="text"
              placeholder="Ex: Restaurante Outback"
              value={newDesc}
              onChange={(e) => setNewDesc(e.target.value)}
              style={{ padding: "4px 8px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <input
              type="text"
              placeholder="R$ 0,00"
              value={newAmount}
              onChange={(e) => setNewAmount(e.target.value)}
              style={{ padding: "4px 8px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <select
              value={newPayer}
              onChange={(e) => setNewPayer(e.target.value as "partner_a" | "partner_b")}
              style={{ padding: "4px 6px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            >
              <option value="partner_a">{partnerAName}</option>
              <option value="partner_b">{partnerBName}</option>
            </select>
            <button
              type="submit"
              style={{
                padding: "4px 8px",
                borderRadius: "4px",
                background: "var(--accent, #ec4899)",
                color: "#fff",
                border: "none",
                fontSize: "0.75rem",
                cursor: "pointer",
                display: "inline-flex",
                alignItems: "center",
              }}
            >
              <Plus size={14} />
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}
