"use client";

import { useMemo, useState } from "react";
import {
  CalendarCheck,
  CheckCircle,
  Plus,
  ShieldAlert,
  Zap,
} from "lucide-react";
import { money } from "./Money";
import {
  extractDebtsFromFinancialData,
  simulateDebtPayoff,
  type DebtItem,
} from "@/lib/finance/debt-payoff";

type DebtPayoffWidgetProps = {
  accounts?: { id: string; name: string; type: string; initial_balance: number }[];
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
    type?: string;
  }[];
  currentMonth: string; // YYYY-MM
};

export function DebtPayoffWidget({
  accounts = [],
  invoices = [],
  transactions = [],
  currentMonth,
}: DebtPayoffWidgetProps) {
  const extractedDebts = useMemo(
    () => extractDebtsFromFinancialData({ accounts, invoices, transactions }),
    [accounts, invoices, transactions]
  );

  const [customDebts, setCustomDebts] = useState<DebtItem[]>([]);
  const [strategy, setStrategy] = useState<"avalanche" | "snowball">("avalanche");
  const [extraPayment, setExtraPayment] = useState<number>(200);

  const allDebts = useMemo(() => {
    return [...extractedDebts, ...customDebts];
  }, [extractedDebts, customDebts]);

  const simulation = useMemo(
    () =>
      simulateDebtPayoff({
        debts: allDebts,
        strategy,
        extraMonthlyPayment: extraPayment,
        startMonth: currentMonth,
      }),
    [allDebts, strategy, extraPayment, currentMonth]
  );

  // Formulário rápido para adicionar dívida manual (ex: empréstimo consignado ou financiamento)
  const [showAddForm, setShowAddForm] = useState(false);
  const [newDebtName, setNewDebtName] = useState("");
  const [newDebtBalance, setNewDebtBalance] = useState("");
  const [newDebtRate, setNewDebtRate] = useState("35");
  const [newDebtMinPay, setNewDebtMinPay] = useState("");

  function handleAddCustomDebt(e: React.FormEvent) {
    e.preventDefault();
    if (!newDebtName || !newDebtBalance) return;

    const balance = Math.abs(Number(newDebtBalance.replace(",", "."))) || 0;
    const rate = Math.abs(Number(newDebtRate.replace(",", "."))) || 35;
    const minPay =
      Math.abs(Number(newDebtMinPay.replace(",", "."))) || Math.max(50, Math.round(balance * 0.05));

    setCustomDebts((prev) => [
      ...prev,
      {
        id: `custom-debt-${Date.now()}`,
        name: newDebtName,
        balance,
        interestRateAnnual: rate,
        minimumMonthlyPayment: minPay,
        category: "emprestimo",
      },
    ]);

    setNewDebtName("");
    setNewDebtBalance("");
    setNewDebtMinPay("");
    setShowAddForm(false);
  }

  return (
    <section
      aria-label="Rastreador de Dívidas e Simulador de Quitação"
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
            <ShieldAlert size={20} aria-hidden="true" />
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
              Rastreador de Dívidas & Simulador de Quitação
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Estratégias matemáticas para zerar dívidas e juros bancários mais rápido.
            </p>
          </div>
        </div>

        {allDebts.length > 0 ? (
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
            <CalendarCheck size={12} /> Livre de dívidas em {simulation.debtFreeDateLabel}
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
            <CheckCircle size={12} /> Sem dívidas ativas
          </span>
        )}
      </header>

      {/* Grid Principal: Estratégias & Aporte Extra + Ordem de Quitação */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Simulador Interativo */}
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
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "0.8rem" }}>
              <span style={{ fontSize: "0.8rem", color: "var(--muted)" }}>Estratégia de Quitação:</span>
              <div style={{ display: "flex", gap: "4px" }}>
                <button
                  type="button"
                  onClick={() => setStrategy("avalanche")}
                  style={{
                    padding: "4px 8px",
                    fontSize: "0.75rem",
                    borderRadius: "6px",
                    border: "1px solid var(--border)",
                    background: strategy === "avalanche" ? "var(--primary, #3b82f6)" : "var(--surface)",
                    color: strategy === "avalanche" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                    fontWeight: 600,
                  }}
                >
                  🏔️ Avalanche (Menos Juros)
                </button>
                <button
                  type="button"
                  onClick={() => setStrategy("snowball")}
                  style={{
                    padding: "4px 8px",
                    fontSize: "0.75rem",
                    borderRadius: "6px",
                    border: "1px solid var(--border)",
                    background: strategy === "snowball" ? "var(--primary, #3b82f6)" : "var(--surface)",
                    color: strategy === "snowball" ? "#fff" : "var(--muted)",
                    cursor: "pointer",
                    fontWeight: 600,
                  }}
                >
                  ❄️ Bola de Neve (Rápido)
                </button>
              </div>
            </div>

            {/* Slider de Aporte Extra */}
            <div style={{ margin: "1rem 0" }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.8rem", marginBottom: "4px" }}>
                <span style={{ color: "var(--muted)" }}>Aporte Extra Mensal:</span>
                <strong style={{ color: "var(--positive, #22c55e)" }}>+{money(extraPayment)}/mês</strong>
              </div>
              <input
                type="range"
                min={0}
                max={1500}
                step={50}
                value={extraPayment}
                onChange={(e) => setExtraPayment(Number(e.target.value))}
                style={{ width: "100%", accentColor: "var(--primary, #3b82f6)", cursor: "pointer" }}
              />
            </div>

            {/* Resumo do Impacto da Simulação */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                padding: "10px",
                borderRadius: "8px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                fontSize: "0.75rem",
              }}
            >
              <div>
                <div style={{ color: "var(--muted)" }}>Saldo Total Devedor</div>
                <strong style={{ fontSize: "0.95rem", color: "var(--text)" }}>
                  {money(simulation.totalInitialDebt)}
                </strong>
              </div>
              <div>
                <div style={{ color: "var(--muted)" }}>Juros Totais Estimados</div>
                <strong style={{ fontSize: "0.95rem", color: "var(--destructive, #ef4444)" }}>
                  {money(simulation.totalInterestPaid)}
                </strong>
              </div>
            </div>

            {simulation.interestSaved > 0 && (
              <div
                style={{
                  marginTop: "8px",
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
                <Zap size={14} /> Economia de <strong>{money(simulation.interestSaved)}</strong> em juros
                e término <strong>{simulation.monthsSaved} meses antes</strong>!
              </div>
            )}
          </div>
        </div>

        {/* Bloco 2: Ordem de Quitação e Lista de Dívidas */}
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
              Ordem de Eliminação ({allDebts.length} dívidas)
            </strong>
            <button
              type="button"
              onClick={() => setShowAddForm(!showAddForm)}
              style={{
                fontSize: "0.7rem",
                padding: "2px 6px",
                borderRadius: "4px",
                border: "1px solid var(--border)",
                background: "var(--surface)",
                color: "var(--text)",
                cursor: "pointer",
                display: "inline-flex",
                alignItems: "center",
                gap: "2px",
              }}
            >
              <Plus size={12} /> Adicionar Dívida
            </button>
          </div>

          {showAddForm && (
            <form onSubmit={handleAddCustomDebt} style={{ display: "grid", gap: "6px", marginBottom: "10px", padding: "8px", background: "var(--surface)", borderRadius: "8px", border: "1px solid var(--border)" }}>
              <input
                type="text"
                placeholder="Nome (ex: Empréstimo Caixa)"
                value={newDebtName}
                onChange={(e) => setNewDebtName(e.target.value)}
                required
                style={{ padding: "4px 8px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface-2)", color: "var(--text)" }}
              />
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "6px" }}>
                <input
                  type="text"
                  placeholder="Saldo (ex: 5000)"
                  value={newDebtBalance}
                  onChange={(e) => setNewDebtBalance(e.target.value)}
                  required
                  style={{ padding: "4px 8px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface-2)", color: "var(--text)" }}
                />
                <input
                  type="text"
                  placeholder="Taxa % a.a. (ex: 45)"
                  value={newDebtRate}
                  onChange={(e) => setNewDebtRate(e.target.value)}
                  style={{ padding: "4px 8px", fontSize: "0.75rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface-2)", color: "var(--text)" }}
                />
              </div>
              <button
                type="submit"
                style={{ padding: "4px", fontSize: "0.75rem", background: "var(--primary, #3b82f6)", color: "#fff", border: "none", borderRadius: "4px", cursor: "pointer", fontWeight: 600 }}
              >
                Salvar Dívida no Simulador
              </button>
            </form>
          )}

          {allDebts.length === 0 ? (
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Nenhuma dívida pendente detectada nas contas ou cartões.
            </p>
          ) : (
            <div style={{ display: "grid", gap: "6px", maxHeight: "240px", overflowY: "auto" }}>
              {simulation.payoffOrder.map((item, index) => (
                <div
                  key={item.debtId}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 10px",
                    borderRadius: "8px",
                    background: "var(--surface)",
                    border: "1px solid var(--border)",
                    fontSize: "0.8rem",
                  }}
                >
                  <div>
                    <span style={{ fontWeight: 700, marginRight: "6px", color: "var(--primary, #3b82f6)" }}>
                      #{index + 1}
                    </span>
                    <strong>{item.debtName}</strong>
                    <div style={{ fontSize: "0.7rem", color: "var(--muted)" }}>
                      Quitação estimada: {item.payoffMonthLabel} ({item.monthsToPayoff} meses)
                    </div>
                  </div>
                  <div style={{ textAlign: "right", fontSize: "0.75rem", color: "var(--muted)" }}>
                    Juros: {money(item.totalInterestPaid)}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
