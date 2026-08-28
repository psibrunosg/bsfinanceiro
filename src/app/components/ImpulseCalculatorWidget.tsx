"use client";

import { useMemo, useState } from "react";
import {
  Brain,
  Hourglass,
  ShieldCheck,
  TrendingUp,
} from "lucide-react";
import { money } from "./Money";
import {
  calculateHoursOfLife,
  computeWishlistMetrics,
  WishlistItem,
} from "@/lib/finance/impulse-calculator";

type ImpulseCalculatorWidgetProps = {
  estimatedMonthlyIncome?: number;
};

export function ImpulseCalculatorWidget({
  estimatedMonthlyIncome = 8000,
}: ImpulseCalculatorWidgetProps) {
  const [productName, setProductName] = useState("");
  const [priceInput, setPriceInput] = useState("1200");
  const [incomeInput, setIncomeInput] = useState(String(estimatedMonthlyIncome));
  const [coolingOffHours] = useState<number>(48);

  const [wishlist, setWishlist] = useState<WishlistItem[]>([
    {
      id: "w-1",
      name: "Tênis Esportivo Edição Limitada",
      price: 850,
      hoursRequired: 17,
      createdAt: "2026-08-25",
      coolingOffHours: 48,
      status: "cooling_off",
    },
    {
      id: "w-2",
      name: "Drone com Câmera 4K",
      price: 2400,
      hoursRequired: 48,
      createdAt: "2026-08-10",
      coolingOffHours: 48,
      status: "dismissed_saved",
    },
  ]);

  const numPrice = Number(priceInput.replace(",", ".")) || 0;
  const numIncome = Number(incomeInput.replace(",", ".")) || estimatedMonthlyIncome;

  const hoursResult = useMemo(
    () =>
      calculateHoursOfLife({
        price: numPrice,
        monthlyIncome: numIncome,
        workHoursPerMonth: 160,
      }),
    [numPrice, numIncome]
  );

  const metrics = useMemo(() => computeWishlistMetrics(wishlist), [wishlist]);

  function handleAddToWishlist(e: React.FormEvent) {
    e.preventDefault();
    if (numPrice <= 0) return;

    const name = productName.trim() || `Item de ${money(numPrice)}`;
    setWishlist((prev) => [
      {
        id: `wish-${Date.now()}`,
        name,
        price: numPrice,
        hoursRequired: hoursResult.hoursRequired,
        createdAt: new Date().toISOString().slice(0, 10),
        coolingOffHours,
        status: "cooling_off",
      },
      ...prev,
    ]);

    setProductName("");
  }

  function handleUpdateStatus(id: string, status: WishlistItem["status"]) {
    setWishlist((prev) =>
      prev.map((item) => (item.id === id ? { ...item, status } : item))
    );
  }

  return (
    <section
      aria-label="Calculadora de Impulso e Preço em Horas de Vida"
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
            <Brain size={20} aria-hidden="true" />
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
              Calculadora de Impulso (Preço em Horas de Vida)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Converta desejos em dias de trabalho e use a regra de reflexão de 48h antes de comprar.
            </p>
          </div>
        </div>

        {/* Badge de Dinheiro Salvo por Autocontrole */}
        {metrics.totalSavedByDismissal > 0 && (
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
            <ShieldCheck size={12} /> Salvo por Autocontrole: {money(metrics.totalSavedByDismissal)}
          </span>
        )}
      </header>

      {/* Grid: Conversor em Horas + Wishlist com Cooling-Off */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Conversor de Valor Real */}
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
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px", marginBottom: "10px" }}>
              <div>
                <label htmlFor="prodPrice" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Preço do Item (R$)
                </label>
                <input
                  id="prodPrice"
                  type="text"
                  value={priceInput}
                  onChange={(e) => setPriceInput(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
              <div>
                <label htmlFor="userIncome" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Sua Renda Líquida/mês
                </label>
                <input
                  id="userIncome"
                  type="text"
                  value={incomeInput}
                  onChange={(e) => setIncomeInput(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
            </div>

            {/* Resultado em Horas de Vida */}
            <div
              style={{
                padding: "12px",
                borderRadius: "8px",
                background: "var(--surface)",
                border: "1px solid var(--border)",
                textAlign: "center",
                margin: "12px 0",
              }}
            >
              <div style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Custo Real em Vida</div>
              <div style={{ fontSize: "1.6rem", fontWeight: 700, color: "var(--warning, #f59e0b)", marginTop: "2px" }}>
                {hoursResult.hoursRequired} horas
              </div>
              <div style={{ fontSize: "0.8rem", color: "var(--text)", marginTop: "2px" }}>
                {hoursResult.impactSentence}
              </div>
            </div>

            {/* Oportunidade CDI */}
            <div
              style={{
                padding: "8px 10px",
                borderRadius: "8px",
                background: "rgba(139, 92, 246, 0.1)",
                border: "1px solid rgba(139, 92, 246, 0.25)",
                fontSize: "0.75rem",
                color: "var(--accent, #8b5cf6)",
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <TrendingUp size={14} /> Em 5 anos no CDI, esse valor viraria{" "}
              <strong>{money(hoursResult.futureValue5Years)}</strong> (+{money(hoursResult.interestEarned5Years)} de lucro).
            </div>
          </div>

          {/* Botão de Adicionar à Reflexão */}
          <form onSubmit={handleAddToWishlist} style={{ marginTop: "1rem" }}>
            <div style={{ display: "flex", gap: "6px" }}>
              <input
                type="text"
                placeholder="Nome do desejo (ex: iPhone 16)"
                value={productName}
                onChange={(e) => setProductName(e.target.value)}
                style={{ flex: 1, padding: "6px 8px", fontSize: "0.75rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
              />
              <button
                type="submit"
                style={{
                  padding: "6px 12px",
                  borderRadius: "6px",
                  background: "var(--warning, #f59e0b)",
                  color: "#000",
                  fontWeight: 600,
                  border: "none",
                  fontSize: "0.75rem",
                  cursor: "pointer",
                  display: "inline-flex",
                  alignItems: "center",
                  gap: "4px",
                }}
              >
                <Hourglass size={14} /> Ativar Reflexão de 48h
              </button>
            </div>
          </form>
        </div>

        {/* Bloco 2: Wishlist com Período de Reflexão */}
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
              Período de Reflexão (Cooling-Off)
            </strong>
            <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>
              {metrics.activeCoolingOffCount} em espera · {metrics.dismissedCount} desistências 🎉
            </span>
          </div>

          <div style={{ display: "grid", gap: "8px", maxHeight: "220px", overflowY: "auto" }}>
            {wishlist.map((item) => (
              <div
                key={item.id}
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
                <div>
                  <span style={{ fontWeight: 600, color: "var(--text)", display: "block" }}>
                    {item.name}
                  </span>
                  <small style={{ color: "var(--muted)", fontSize: "0.7rem" }}>
                    {money(item.price)} · {item.hoursRequired ? `${item.hoursRequired}h de vida` : ""}
                  </small>
                </div>

                <div style={{ display: "flex", gap: "4px", alignItems: "center" }}>
                  {item.status === "cooling_off" ? (
                    <>
                      <button
                        type="button"
                        onClick={() => handleUpdateStatus(item.id, "dismissed_saved")}
                        style={{
                          padding: "3px 6px",
                          borderRadius: "4px",
                          background: "rgba(34, 197, 94, 0.15)",
                          color: "var(--positive, #22c55e)",
                          border: "1px solid rgba(34, 197, 94, 0.3)",
                          fontSize: "0.65rem",
                          fontWeight: 600,
                          cursor: "pointer",
                        }}
                      >
                        🎉 Desisti (Salvar)
                      </button>
                      <button
                        type="button"
                        onClick={() => handleUpdateStatus(item.id, "purchased")}
                        style={{
                          padding: "3px 6px",
                          borderRadius: "4px",
                          background: "var(--surface-2)",
                          color: "var(--muted)",
                          border: "1px solid var(--border)",
                          fontSize: "0.65rem",
                          cursor: "pointer",
                        }}
                      >
                        Comprei
                      </button>
                    </>
                  ) : item.status === "dismissed_saved" ? (
                    <span style={{ fontSize: "0.7rem", color: "var(--positive, #22c55e)", fontWeight: 600 }}>
                      ✅ Economizado
                    </span>
                  ) : (
                    <span style={{ fontSize: "0.7rem", color: "var(--muted)" }}>
                      🛍️ Comprado
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
