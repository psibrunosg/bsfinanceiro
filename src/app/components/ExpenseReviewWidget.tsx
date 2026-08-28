"use client";

import { useMemo, useState } from "react";
import {
  Frown,
  HeartCrack,
  RotateCcw,
  Smile,
  Sparkles,
  ThumbsDown,
  ThumbsUp,
} from "lucide-react";
import { money } from "./Money";
import {
  computeExpenseReviewMetrics,
  getReviewableTransactions,
  ExpenseReviewItem,
} from "@/lib/finance/expense-review";

type ExpenseReviewWidgetProps = {
  transactions: {
    id: string;
    description: string;
    amount: number | string;
    type?: string;
    competence_date?: string;
    category_id?: string | null;
    category_name?: string;
  }[];
  currentMonth: string; // YYYY-MM
};

export function ExpenseReviewWidget({
  transactions,
  currentMonth,
}: ExpenseReviewWidgetProps) {
  const initialItems = useMemo(
    () => getReviewableTransactions(transactions, currentMonth),
    [transactions, currentMonth]
  );

  const [reviewedItems, setReviewedItems] = useState<ExpenseReviewItem[]>([]);

  const [currentIndex, setCurrentIndex] = useState<number>(0);

  // Unifica itens detectados do extrato
  const itemsToReview = useMemo(() => {
    if (initialItems.length > 0) return initialItems;
    return reviewedItems;
  }, [initialItems, reviewedItems]);

  const metrics = useMemo(
    () => computeExpenseReviewMetrics(itemsToReview),
    [itemsToReview]
  );

  const currentCard = itemsToReview[currentIndex];
  const isFinished = currentIndex >= itemsToReview.length;

  function handleSwipe(rating: "liked" | "regretted") {
    if (!currentCard) return;

    setReviewedItems((prev) =>
      prev.map((item, idx) =>
        idx === currentIndex ? { ...item, rating } : item
      )
    );

    setCurrentIndex((prev) => prev + 1);
  }

  function handleReset() {
    setCurrentIndex(0);
    setReviewedItems((prev) =>
      prev.map((item) => ({ ...item, rating: "unreviewed" }))
    );
  }

  return (
    <section
      aria-label="Tinder dos Gastos e Revisão de Arrependimentos"
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
              color: "var(--danger, #ef4444)",
            }}
          >
            <HeartCrack size={20} aria-hidden="true" />
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
              Tinder dos Gastos (Revisão de Arrependimentos)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Descubra quais compras realmente valeram a pena e corte o dinheiro desperdiçado em impulsos.
            </p>
          </div>
        </div>

        {/* Badges de Satisfação */}
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
            <Smile size={12} /> Satisfação: {metrics.satisfactionRatePercent}%
          </span>

          {metrics.totalRegrettedAmount > 0 && (
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
              <Frown size={12} /> Arrependimento: {money(metrics.totalRegrettedAmount)}
            </span>
          )}
        </div>
      </header>

      {/* Card Swipe Interativo */}
      {!isFinished && currentCard ? (
        <div
          style={{
            maxWidth: "420px",
            margin: "0 auto",
            padding: "1.5rem",
            borderRadius: "16px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            textAlign: "center",
            boxShadow: "0 8px 30px rgba(0,0,0,0.2)",
          }}
        >
          <div style={{ fontSize: "0.75rem", color: "var(--muted)", marginBottom: "8px" }}>
            Revisão {currentIndex + 1} de {itemsToReview.length}
          </div>

          <strong style={{ fontSize: "1.2rem", color: "var(--text)", display: "block", marginBottom: "4px" }}>
            {currentCard.description}
          </strong>

          <span
            style={{
              fontSize: "0.7rem",
              padding: "2px 8px",
              borderRadius: "12px",
              background: "var(--surface)",
              color: "var(--muted)",
              border: "1px solid var(--border)",
              display: "inline-block",
              marginBottom: "12px",
            }}
          >
            {currentCard.category || "Geral"}
          </span>

          <div style={{ fontSize: "2rem", fontWeight: 800, color: "var(--text)", marginBottom: "1.5rem" }}>
            {money(currentCard.amount)}
          </div>

          {/* Botões de Decisão */}
          <div style={{ display: "flex", gap: "12px", justifyContent: "center" }}>
            <button
              type="button"
              onClick={() => handleSwipe("regretted")}
              style={{
                flex: 1,
                padding: "10px",
                borderRadius: "10px",
                background: "rgba(239, 68, 68, 0.15)",
                color: "var(--danger, #ef4444)",
                border: "1px solid rgba(239, 68, 68, 0.3)",
                fontSize: "0.85rem",
                fontWeight: 700,
                cursor: "pointer",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "6px",
              }}
            >
              <ThumbsDown size={16} /> Me Arrependi
            </button>

            <button
              type="button"
              onClick={() => handleSwipe("liked")}
              style={{
                flex: 1,
                padding: "10px",
                borderRadius: "10px",
                background: "rgba(34, 197, 94, 0.15)",
                color: "var(--positive, #22c55e)",
                border: "1px solid rgba(34, 197, 94, 0.3)",
                fontSize: "0.85rem",
                fontWeight: 700,
                cursor: "pointer",
                display: "inline-flex",
                alignItems: "center",
                justifyContent: "center",
                gap: "6px",
              }}
            >
              <ThumbsUp size={16} /> Valeu a Pena!
            </button>
          </div>
        </div>
      ) : (
        /* Tela de Conclusão & Insights */
        <div
          style={{
            padding: "1.5rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
            textAlign: "center",
          }}
        >
          <Sparkles size={28} color="var(--positive, #22c55e)" style={{ margin: "0 auto 8px" }} />
          <h3 style={{ fontSize: "1.1rem", margin: "0 0 4px", color: "var(--text)" }}>
            Revisão Mensal Concluída!
          </h3>
          <p style={{ fontSize: "0.85rem", color: "var(--muted)", maxWidth: "500px", margin: "0 auto 1rem" }}>
            {metrics.behavioralInsight}
          </p>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(140px, 1fr))",
              gap: "10px",
              maxWidth: "500px",
              margin: "0 auto 1.25rem",
              fontSize: "0.75rem",
            }}
          >
            <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
              <div style={{ color: "var(--muted)" }}>Compras Valiosas</div>
              <strong style={{ fontSize: "0.95rem", color: "var(--positive, #22c55e)" }}>{money(metrics.totalLikedAmount)}</strong>
            </div>
            <div style={{ padding: "8px", borderRadius: "6px", background: "var(--surface)", border: "1px solid var(--border)" }}>
              <div style={{ color: "var(--muted)" }}>Compras Arrependidas</div>
              <strong style={{ fontSize: "0.95rem", color: "var(--danger, #ef4444)" }}>{money(metrics.totalRegrettedAmount)}</strong>
            </div>
          </div>

          <button
            type="button"
            onClick={handleReset}
            style={{
              padding: "6px 14px",
              borderRadius: "6px",
              background: "var(--surface)",
              border: "1px solid var(--border)",
              color: "var(--text)",
              fontSize: "0.8rem",
              cursor: "pointer",
              display: "inline-flex",
              alignItems: "center",
              gap: "6px",
            }}
          >
            <RotateCcw size={14} /> Revisar Novamente
          </button>
        </div>
      )}
    </section>
  );
}
