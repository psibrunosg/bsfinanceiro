"use client";

import { useMemo, useState } from "react";
import {
  GraduationCap,
  Plus,
  Rocket,
  Sparkles,
  Zap,
} from "lucide-react";
import { money } from "./Money";
import {
  computeAcademicRoi,
  simulateNextAcademicInvestment,
  AcademicCourse,
} from "@/lib/finance/academic-roi";

type AcademicRoiWidgetProps = {
  currentMonthlyIncome?: number;
  currentMonth?: string;
};

export function AcademicRoiWidget({
  currentMonthlyIncome = 10000,
  currentMonth = new Date().toISOString().slice(0, 7),
}: AcademicRoiWidgetProps) {
  const [courses, setCourses] = useState<AcademicCourse[]>([
    {
      id: "ac-1",
      title: "Especialização em Terapia Cognitivo-Comportamental",
      cost: 4800,
      completionDate: "2025-05-01",
      monthlyIncomeBefore: 6000,
      monthlyIncomeAfter: 8800,
      category: "Especialização",
    },
    {
      id: "ac-2",
      title: "Formação em Avaliação Neuropsicológica",
      cost: 3200,
      completionDate: "2025-11-01",
      monthlyIncomeBefore: 8800,
      monthlyIncomeAfter: 11000,
      category: "Formação",
    },
    {
      id: "ac-3",
      title: "Supervisão Clínica em Casos Graves",
      cost: 1600,
      completionDate: "2026-03-01",
      monthlyIncomeBefore: 11000,
      monthlyIncomeAfter: 12200,
      category: "Supervisão",
    },
  ]);

  // Simulador de Próximo Curso
  const [simCost, setSimCost] = useState("6000");
  const [simPercent, setSimPercent] = useState("15");

  const roiResult = useMemo(
    () => computeAcademicRoi(courses, currentMonth),
    [courses, currentMonth]
  );

  const numSimCost = Number(simCost.replace(",", ".")) || 0;
  const numSimPercent = Number(simPercent.replace(",", ".")) || 0;

  const simResult = useMemo(
    () =>
      simulateNextAcademicInvestment({
        courseCost: numSimCost,
        expectedIncomeIncreasePercent: numSimPercent,
        currentMonthlyIncome,
      }),
    [numSimCost, numSimPercent, currentMonthlyIncome]
  );

  // Form de novo curso
  const [newTitle, setNewTitle] = useState("");
  const [newCost, setNewCost] = useState("");
  const [newIncBefore, setNewIncBefore] = useState("");
  const [newIncAfter, setNewIncAfter] = useState("");

  function handleAddCourse(e: React.FormEvent) {
    e.preventDefault();
    const c = Number(newCost.replace(",", "."));
    const b = Number(newIncBefore.replace(",", "."));
    const a = Number(newIncAfter.replace(",", "."));
    if (!newTitle.trim() || isNaN(c) || isNaN(b) || isNaN(a)) return;

    setCourses((prev) => [
      {
        id: `course-${Date.now()}`,
        title: newTitle.trim(),
        cost: c,
        monthlyIncomeBefore: b,
        monthlyIncomeAfter: a,
        completionDate: currentMonth,
      },
      ...prev,
    ]);

    setNewTitle("");
    setNewCost("");
    setNewIncBefore("");
    setNewIncAfter("");
  }

  return (
    <section
      aria-label="ROI Acadêmico e Retorno sobre Investimento em Educação"
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
              background: "rgba(14, 165, 233, 0.15)",
              color: "var(--primary, #0ea5e9)",
            }}
          >
            <GraduationCap size={20} aria-hidden="true" />
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
              ROI Acadêmico & Evolução Profissional
            </h2>
            <p style={{ fontSize: "0.8rem", color: "var(--muted)", margin: 0 }}>
              Retorno sobre cursos, pós-graduação e supervisão clínica cruzados com a receita de consultas.
            </p>
          </div>
        </div>

        {/* Badges de Destaque */}
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
            <Sparkles size={12} /> ROI Global: +{roiResult.overallRoiPercent}%
          </span>

          <span
            style={{
              fontSize: "0.75rem",
              fontWeight: 600,
              padding: "0.3rem 0.6rem",
              borderRadius: "20px",
              background: "rgba(14, 165, 233, 0.15)",
              color: "var(--primary, #0ea5e9)",
              display: "inline-flex",
              alignItems: "center",
              gap: "4px",
            }}
          >
            <Zap size={12} /> Payback Médio: {roiResult.averagePaybackMonths} meses
          </span>
        </div>
      </header>

      {/* 4 Cards Executivos */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))",
          gap: "10px",
          marginBottom: "1.25rem",
        }}
      >
        <div style={{ padding: "10px", borderRadius: "8px", background: "var(--surface-2)", border: "1px solid var(--border)" }}>
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Total Investido</span>
          <div style={{ fontSize: "1.2rem", fontWeight: 700, color: "var(--text)" }}>{money(roiResult.totalInvested)}</div>
        </div>
        <div style={{ padding: "10px", borderRadius: "8px", background: "var(--surface-2)", border: "1px solid var(--border)" }}>
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Aumento Mensal Gerado</span>
          <div style={{ fontSize: "1.2rem", fontWeight: 700, color: "var(--positive, #22c55e)" }}>+{money(roiResult.totalMonthlyGain)}/mês</div>
        </div>
        <div style={{ padding: "10px", borderRadius: "8px", background: "var(--surface-2)", border: "1px solid var(--border)" }}>
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Lucro Líquido Acumulado</span>
          <div style={{ fontSize: "1.2rem", fontWeight: 700, color: "var(--primary, #0ea5e9)" }}>+{money(roiResult.totalNetProfitToDate)}</div>
        </div>
        <div style={{ padding: "10px", borderRadius: "8px", background: "var(--surface-2)", border: "1px solid var(--border)" }}>
          <span style={{ fontSize: "0.75rem", color: "var(--muted)" }}>Curso Mais Rentável</span>
          <strong style={{ fontSize: "0.8rem", color: "var(--text)", display: "block", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
            {roiResult.topPerformingCourse ? roiResult.topPerformingCourse.title : "Nenhum"}
          </strong>
        </div>
      </div>

      {/* Grid: Extrato de Cursos + Simulador de Próximo Investimento */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Cursos Realizados */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "0.8rem" }}>
            Formações & Retorno Individual ({courses.length})
          </strong>

          <div style={{ display: "grid", gap: "8px", maxHeight: "200px", overflowY: "auto" }}>
            {roiResult.coursesWithRoi.map((c) => (
              <div
                key={c.id}
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
                  <span style={{ fontWeight: 600, color: "var(--text)", display: "block" }}>{c.title}</span>
                  <small style={{ color: "var(--muted)", fontSize: "0.7rem" }}>
                    Custo: {money(c.cost)} · Impacto: +{money(c.monthlyGain)}/mês
                  </small>
                </div>

                <div style={{ textAlign: "right" }}>
                  <span
                    style={{
                      fontSize: "0.7rem",
                      fontWeight: 600,
                      padding: "2px 6px",
                      borderRadius: "4px",
                      background: c.isPaidOff ? "rgba(34, 197, 94, 0.15)" : "rgba(245, 158, 11, 0.15)",
                      color: c.isPaidOff ? "var(--positive, #22c55e)" : "var(--warning, #f59e0b)",
                    }}
                  >
                    {c.isPaidOff ? `Pago em ${c.paybackMonths}m` : `${c.paybackMonths}m payback`}
                  </span>
                  <div style={{ fontSize: "0.7rem", color: "var(--positive, #22c55e)", fontWeight: 600, marginTop: "2px" }}>
                    +{money(c.netProfitToDate)} lucro
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Form Rápido de Novo Curso */}
          <form
            onSubmit={handleAddCourse}
            style={{
              marginTop: "1rem",
              paddingTop: "0.8rem",
              borderTop: "1px solid var(--border)",
              display: "grid",
              gridTemplateColumns: "2fr 1fr 1fr 1fr auto",
              gap: "4px",
            }}
          >
            <input
              type="text"
              placeholder="Nome do Curso / Pós"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.7rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <input
              type="text"
              placeholder="Custo (R$)"
              value={newCost}
              onChange={(e) => setNewCost(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.7rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <input
              type="text"
              placeholder="Renda Antes"
              value={newIncBefore}
              onChange={(e) => setNewIncBefore(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.7rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <input
              type="text"
              placeholder="Renda Depois"
              value={newIncAfter}
              onChange={(e) => setNewIncAfter(e.target.value)}
              style={{ padding: "4px 6px", fontSize: "0.7rem", borderRadius: "4px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
            />
            <button
              type="submit"
              style={{
                padding: "4px 8px",
                borderRadius: "4px",
                background: "var(--primary, #0ea5e9)",
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

        {/* Bloco 2: Simulador do Próximo Investimento Acadêmico */}
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
            <strong style={{ fontSize: "0.85rem", color: "var(--text)", display: "block", marginBottom: "10px" }}>
              Simulador do Próximo Curso ou Pós
            </strong>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "8px", marginBottom: "10px" }}>
              <div>
                <label htmlFor="cCost" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Valor da Formação (R$)
                </label>
                <input
                  id="cCost"
                  type="text"
                  value={simCost}
                  onChange={(e) => setSimCost(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
              <div>
                <label htmlFor="cGain" style={{ fontSize: "0.7rem", color: "var(--muted)", display: "block" }}>
                  Aumento Esperado (%)
                </label>
                <input
                  id="cGain"
                  type="text"
                  value={simPercent}
                  onChange={(e) => setSimPercent(e.target.value)}
                  style={{ width: "100%", padding: "4px 8px", fontSize: "0.85rem", borderRadius: "6px", border: "1px solid var(--border)", background: "var(--surface)", color: "var(--text)" }}
                />
              </div>
            </div>

            {/* Resultado da Projeção */}
            <div
              style={{
                padding: "10px",
                borderRadius: "8px",
                background: "rgba(14, 165, 233, 0.1)",
                border: "1px solid rgba(14, 165, 233, 0.25)",
                fontSize: "0.8rem",
                color: "var(--primary, #0ea5e9)",
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: "6px", fontWeight: 600, marginBottom: "4px" }}>
                <Rocket size={15} /> {simResult.verdict}
              </div>
              <small style={{ color: "var(--muted)", display: "block" }}>
                Ganho incremental projetado: +{money(simResult.monthlyGain)}/mês (+{money(simResult.annualGain)}/ano).
              </small>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
