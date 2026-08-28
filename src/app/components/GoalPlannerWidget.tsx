"use client";

import { useMemo, useState } from "react";
import {
  Sparkles,
  Target,
  TrendingUp,
  Zap,
} from "lucide-react";
import { money } from "./Money";
import {
  computeGoalMilestones,
  computeGoalPlan,
} from "@/lib/finance/goal-planner";

type GoalItem = {
  id: string;
  name: string;
  target_amount: number | string;
  current_amount: number | string;
  deadline?: string | null;
  status?: string;
};

type GoalPlannerWidgetProps = {
  goals: GoalItem[];
  currentMonth?: string; // YYYY-MM
};

export function GoalPlannerWidget({
  goals,
  currentMonth = new Date().toISOString().slice(0, 7),
}: GoalPlannerWidgetProps) {
  const [selectedGoalId, setSelectedGoalId] = useState<string>(
    goals[0]?.id || ""
  );

  const activeGoal = useMemo(() => {
    return goals.find((g) => g.id === selectedGoalId) || goals[0] || null;
  }, [goals, selectedGoalId]);

  const [simulatedContribution, setSimulatedContribution] = useState<number>(0);

  const plan = useMemo(() => {
    if (!activeGoal) return null;
    return computeGoalPlan({
      targetAmount: Number(activeGoal.target_amount) || 0,
      currentAmount: Number(activeGoal.current_amount) || 0,
      startMonth: currentMonth,
      deadlineMonth: activeGoal.deadline,
      annualRatePercent: 12.0,
      monthlyContribution: simulatedContribution > 0 ? simulatedContribution : undefined,
    });
  }, [activeGoal, currentMonth, simulatedContribution]);

  const milestones = useMemo(() => {
    if (!activeGoal) return [];
    return computeGoalMilestones(
      Number(activeGoal.target_amount) || 0,
      Number(activeGoal.current_amount) || 0
    );
  }, [activeGoal]);

  if (!activeGoal || !plan) {
    return null;
  }

  return (
    <section
      aria-label="Planejador de Metas e Sonhos com Motor de Aportes"
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
              background: "rgba(139, 92, 246, 0.15)",
              color: "var(--accent, #8b5cf6)",
            }}
          >
            <Target size={20} aria-hidden="true" />
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
              Planejador de Metas & Sonhos (Motor CDI)
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Calcule aportes ideais, ganho com juros compostos e data de conquista.
            </p>
          </div>
        </div>

        {/* Seletor de Meta caso haja mais de uma */}
        {goals.length > 1 && (
          <select
            value={activeGoal.id}
            onChange={(e) => {
              setSelectedGoalId(e.target.value);
              setSimulatedContribution(0);
            }}
            style={{
              padding: "4px 8px",
              borderRadius: "6px",
              border: "1px solid var(--border)",
              background: "var(--surface-2)",
              color: "var(--text)",
              fontSize: "0.75rem",
              fontWeight: 600,
            }}
          >
            {goals.map((g) => (
              <option key={g.id} value={g.id}>
                {g.name}
              </option>
            ))}
          </select>
        )}

        <span
          style={{
            fontSize: "0.75rem",
            fontWeight: 600,
            padding: "0.3rem 0.6rem",
            borderRadius: "20px",
            background:
              plan.status === "completed" || plan.status === "ahead"
                ? "rgba(34, 197, 94, 0.15)"
                : "rgba(139, 92, 246, 0.15)",
            color:
              plan.status === "completed" || plan.status === "ahead"
                ? "var(--positive, #22c55e)"
                : "var(--accent, #8b5cf6)",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
          }}
        >
          <Sparkles size={12} />
          {plan.status === "completed"
            ? "Sonho Conquistado! 🎉"
            : plan.monthsAhead > 0
            ? `Adiantado em ${plan.monthsAhead} meses 🚀`
            : `Conclusão em ${plan.projectedCompletionLabel}`}
        </span>
      </header>

      {/* Grid Principal: Termômetro + Poder do CDI + Simulador */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Termômetro Visual e Marcos */}
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
              <strong style={{ fontSize: "1rem", color: "var(--text)" }}>
                {activeGoal.name}
              </strong>
              <span style={{ fontSize: "0.8rem", color: "var(--muted)" }}>
                {plan.progressPercentage}% concluído
              </span>
            </div>

            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline", marginTop: "4px" }}>
              <span style={{ fontSize: "1.5rem", fontWeight: 700, color: "var(--text)" }}>
                {money(plan.currentAmount)}
              </span>
              <span style={{ fontSize: "0.85rem", color: "var(--muted)" }}>
                de {money(plan.targetAmount)}
              </span>
            </div>

            {/* Barra de Progresso */}
            <div
              style={{
                width: "100%",
                height: "10px",
                borderRadius: "5px",
                background: "var(--surface)",
                margin: "12px 0",
                overflow: "hidden",
              }}
            >
              <div
                style={{
                  width: `${plan.progressPercentage}%`,
                  height: "100%",
                  background:
                    plan.progressPercentage >= 100
                      ? "var(--positive, #22c55e)"
                      : "var(--accent, #8b5cf6)",
                  borderRadius: "5px",
                  transition: "width 0.3s ease",
                }}
              />
            </div>

            {/* 4 Marcos de Conquista (Milestones) */}
            <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: "4px", marginTop: "1rem" }}>
              {milestones.map((m) => (
                <div
                  key={m.percentage}
                  style={{
                    padding: "6px 4px",
                    borderRadius: "6px",
                    background: m.achieved ? "rgba(34, 197, 94, 0.12)" : "var(--surface)",
                    border: m.achieved
                      ? "1px solid rgba(34, 197, 94, 0.3)"
                      : "1px solid var(--border)",
                    textAlign: "center",
                    fontSize: "0.65rem",
                  }}
                >
                  <div style={{ fontWeight: 700, color: m.achieved ? "var(--positive, #22c55e)" : "var(--muted)" }}>
                    {m.percentage}%
                  </div>
                  <div style={{ color: "var(--muted)", marginTop: "2px" }}>
                    {money(m.amount).split(",")[0]}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Bloco 2: O Poder do CDI & Simulador de Aportes */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
            <TrendingUp size={16} color="var(--accent, #8b5cf6)" />
            <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
              O Poder do CDI no seu Sonho
            </strong>
          </div>

          {/* Comparativo: Sem juros vs Com CDI */}
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
              marginBottom: "10px",
            }}
          >
            <div>
              <div style={{ color: "var(--muted)" }}>Sem rendimento</div>
              <strong style={{ fontSize: "0.95rem", color: "var(--text)" }}>
                {money(plan.requiredMonthlyNoInterest)}/mês
              </strong>
            </div>
            <div>
              <div style={{ color: "var(--muted)" }}>Com CDI (12% a.a.)</div>
              <strong style={{ fontSize: "0.95rem", color: "var(--positive, #22c55e)" }}>
                {money(plan.requiredMonthlyWithCDI)}/mês
              </strong>
            </div>
          </div>

          {plan.cdiYieldBenefit > 0 && (
            <div
              style={{
                padding: "8px 10px",
                borderRadius: "8px",
                background: "rgba(139, 92, 246, 0.1)",
                border: "1px solid rgba(139, 92, 246, 0.25)",
                fontSize: "0.75rem",
                color: "var(--accent, #8b5cf6)",
                marginBottom: "10px",
                display: "flex",
                alignItems: "center",
                gap: "6px",
              }}
            >
              <Zap size={14} /> ✨ O rendimento do CDI pagará{" "}
              <strong>{money(plan.cdiYieldBenefit)}</strong> do seu objetivo!
            </div>
          )}

          {/* Slider Interativo de Aporte */}
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.75rem", marginBottom: "4px" }}>
              <span style={{ color: "var(--muted)" }}>Simular outro aporte mensal:</span>
              <strong style={{ color: "var(--text)" }}>
                {money(simulatedContribution > 0 ? simulatedContribution : plan.requiredMonthlyWithCDI)}/mês
              </strong>
            </div>
            <input
              type="range"
              min={Math.max(50, Math.round(plan.requiredMonthlyWithCDI * 0.5))}
              max={Math.round(plan.requiredMonthlyWithCDI * 2.5)}
              step={50}
              value={simulatedContribution > 0 ? simulatedContribution : plan.requiredMonthlyWithCDI}
              onChange={(e) => setSimulatedContribution(Number(e.target.value))}
              style={{ width: "100%", accentColor: "var(--accent, #8b5cf6)", cursor: "pointer" }}
            />
          </div>
        </div>
      </div>
    </section>
  );
}
