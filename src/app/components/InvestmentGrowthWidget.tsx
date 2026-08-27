"use client";

import { useMemo, useState } from "react";
import {
  Award,
  BarChart3,
  Calculator,
  Compass,
  PiggyBank,
  ShieldCheck,
  TrendingUp,
} from "lucide-react";
import { money } from "./Money";
import {
  comparePortfolioYield,
  computeAssetClassAllocation,
  projectCompoundGrowth,
  type AssetSummaryItem,
  type PositionItem,
} from "@/lib/finance/investment-growth";

type InvestmentGrowthWidgetProps = {
  assets: AssetSummaryItem[];
  positions: Record<string, PositionItem | undefined>;
  latestQuotes: Record<string, number | undefined>;
  totalInvested: number;
  totalGainPercent: number;
};

export function InvestmentGrowthWidget({
  assets,
  positions,
  latestQuotes,
  totalInvested,
  totalGainPercent,
}: InvestmentGrowthWidgetProps) {
  // Benchmark CDI
  const benchmark = useMemo(
    () =>
      comparePortfolioYield({
        portfolioYieldPercent: totalGainPercent,
        annualCdiPercent: 12.25,
        annualSavingsPercent: 7.2,
      }),
    [totalGainPercent]
  );

  // Alocação por Classe de Ativos
  const allocation = useMemo(
    () => computeAssetClassAllocation(assets, positions, latestQuotes),
    [assets, positions, latestQuotes]
  );

  // Estados do Simulador de Liberdade Financeira
  const [monthlyContribution, setMonthlyContribution] = useState<number>(500);
  const [years, setYears] = useState<number>(5);
  const [expectedRate, setExpectedRate] = useState<number>(12.25);

  const projection = useMemo(
    () =>
      projectCompoundGrowth({
        initialPrincipal: totalInvested,
        monthlyContribution,
        annualRatePercent: expectedRate,
        months: years * 12,
      }),
    [totalInvested, monthlyContribution, expectedRate, years]
  );

  return (
    <section
      aria-label="Monitor de Investimentos e Crescimento Patrimonial"
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
            <TrendingUp size={20} aria-hidden="true" />
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
              Monitor de Investimentos & Benchmark CDI
            </h2>
            <p
              style={{
                fontSize: "0.8rem",
                color: "var(--muted)",
                margin: 0,
              }}
            >
              Acompanhe a rentabilidade comparativa com o CDI e projete a evolução patrimonial.
            </p>
          </div>
        </div>

        <span
          style={{
            fontSize: "0.75rem",
            fontWeight: 600,
            padding: "0.3rem 0.6rem",
            borderRadius: "20px",
            background:
              benchmark.percentOfCdi >= 100
                ? "rgba(34, 197, 94, 0.15)"
                : "rgba(245, 158, 11, 0.15)",
            color:
              benchmark.percentOfCdi >= 100
                ? "var(--positive, #22c55e)"
                : "var(--warning, #f59e0b)",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
          }}
        >
          {benchmark.percentOfCdi >= 100 ? (
            <>
              <Award size={12} /> {benchmark.percentOfCdi}% do CDI
            </>
          ) : (
            <>
              <Compass size={12} /> {benchmark.percentOfCdi}% do CDI
            </>
          )}
        </span>
      </header>

      {/* Grid Principal: Benchmark + Simulador */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))",
          gap: "1.25rem",
        }}
      >
        {/* Bloco 1: Comparativo com o CDI e Alocação de Classes */}
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
              Rentabilidade Acumulada
            </span>
            <div
              style={{
                fontSize: "1.8rem",
                fontWeight: 700,
                color:
                  totalGainPercent >= 0
                    ? "var(--positive, #22c55e)"
                    : "var(--destructive, #ef4444)",
                marginTop: "0.4rem",
              }}
            >
              {totalGainPercent >= 0 ? "+" : ""}
              {totalGainPercent.toFixed(2)}%
            </div>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "1fr 1fr",
                gap: "8px",
                marginTop: "10px",
              }}
            >
              <div
                style={{
                  padding: "8px",
                  borderRadius: "8px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                  fontSize: "0.75rem",
                }}
              >
                <div style={{ color: "var(--muted)" }}>CDI Benchmark</div>
                <strong style={{ color: "var(--text)" }}>12,25% a.a.</strong>
                <div
                  style={{
                    color:
                      benchmark.beatsCdi
                        ? "var(--positive, #22c55e)"
                        : "var(--warning, #f59e0b)",
                    marginTop: "2px",
                    fontWeight: 600,
                  }}
                >
                  {benchmark.beatsCdi
                    ? `+${benchmark.cdiSpread}% vs CDI`
                    : `${benchmark.cdiSpread}% vs CDI`}
                </div>
              </div>

              <div
                style={{
                  padding: "8px",
                  borderRadius: "8px",
                  background: "var(--surface)",
                  border: "1px solid var(--border)",
                  fontSize: "0.75rem",
                }}
              >
                <div style={{ color: "var(--muted)" }}>Poupança</div>
                <strong style={{ color: "var(--text)" }}>7,20% a.a.</strong>
                <div
                  style={{
                    color:
                      benchmark.beatsSavings
                        ? "var(--positive, #22c55e)"
                        : "var(--warning, #f59e0b)",
                    marginTop: "2px",
                    fontWeight: 600,
                  }}
                >
                  {benchmark.beatsSavings
                    ? `+${benchmark.savingsSpread}% vs Poupança`
                    : `${benchmark.savingsSpread}% vs Poupança`}
                </div>
              </div>
            </div>
          </div>

          {/* Alocação Renda Fixa vs Variável */}
          <div style={{ marginTop: "1.2rem" }}>
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                fontSize: "0.75rem",
                color: "var(--muted)",
                marginBottom: "6px",
              }}
            >
              <span>
                <ShieldCheck size={12} style={{ verticalAlign: "middle", marginRight: 4 }} />
                Renda Fixa: <strong>{allocation.fixedIncomePercent}%</strong>
              </span>
              <span>
                <BarChart3 size={12} style={{ verticalAlign: "middle", marginRight: 4 }} />
                Renda Variável: <strong>{allocation.variableIncomePercent}%</strong>
              </span>
            </div>

            <div
              style={{
                width: "100%",
                height: "8px",
                borderRadius: "4px",
                background: "var(--surface)",
                display: "flex",
                overflow: "hidden",
              }}
            >
              <div
                style={{
                  width: `${allocation.fixedIncomePercent}%`,
                  background: "var(--positive, #22c55e)",
                  height: "100%",
                }}
                title={`Renda Fixa: ${money(allocation.fixedIncomeTotal)}`}
              />
              <div
                style={{
                  width: `${allocation.variableIncomePercent}%`,
                  background: "var(--accent, #8b5cf6)",
                  height: "100%",
                }}
                title={`Renda Variável: ${money(allocation.variableIncomeTotal)}`}
              />
            </div>
          </div>
        </div>

        {/* Bloco 2: Simulador de Liberdade Financeira e Juros Compostos */}
        <div
          style={{
            padding: "1.2rem",
            borderRadius: "12px",
            background: "var(--surface-2, rgba(255,255,255,0.03))",
            border: "1px solid var(--border)",
          }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: "6px", marginBottom: "0.8rem" }}>
            <Calculator size={16} color="var(--primary, #3b82f6)" />
            <strong style={{ fontSize: "0.9rem", color: "var(--text)" }}>
              Simulador de Liberdade Financeira
            </strong>
          </div>

          <div
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr 1fr",
              gap: "8px",
              marginBottom: "1rem",
            }}
          >
            <div>
              <label
                htmlFor="sim-aport"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Aporte Mensal (R$)
              </label>
              <input
                id="sim-aport"
                type="number"
                min={0}
                step={50}
                value={monthlyContribution}
                onChange={(e) => setMonthlyContribution(Math.max(0, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.85rem",
                  fontWeight: 600,
                }}
              />
            </div>

            <div>
              <label
                htmlFor="sim-years"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Prazo (Anos)
              </label>
              <input
                id="sim-years"
                type="number"
                min={1}
                max={40}
                value={years}
                onChange={(e) => setYears(Math.max(1, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.85rem",
                  fontWeight: 600,
                }}
              />
            </div>

            <div>
              <label
                htmlFor="sim-expect-rate"
                style={{ fontSize: "0.75rem", color: "var(--muted)", display: "block", marginBottom: "4px" }}
              >
                Taxa (% a.a.)
              </label>
              <input
                id="sim-expect-rate"
                type="number"
                min={1}
                max={50}
                step={0.25}
                value={expectedRate}
                onChange={(e) => setExpectedRate(Math.max(0.1, Number(e.target.value)))}
                style={{
                  width: "100%",
                  padding: "8px",
                  borderRadius: "8px",
                  border: "1px solid var(--border)",
                  background: "var(--surface)",
                  color: "var(--text)",
                  fontSize: "0.85rem",
                  fontWeight: 600,
                }}
              />
            </div>
          </div>

          {/* Resultado da Projeção */}
          <div
            style={{
              padding: "1rem",
              borderRadius: "10px",
              background: "rgba(139, 92, 246, 0.1)",
              border: "1px solid rgba(139, 92, 246, 0.25)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "baseline" }}>
              <span style={{ fontSize: "0.8rem", color: "var(--muted)" }}>
                Patrimônio em {years} anos:
              </span>
              <strong style={{ fontSize: "1.25rem", color: "var(--accent, #8b5cf6)" }}>
                {money(projection.totalAccumulated)}
              </strong>
            </div>

            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                fontSize: "0.75rem",
                color: "var(--muted)",
                marginTop: "6px",
              }}
            >
              <span>Seu desembolso: {money(projection.totalContributed)}</span>
              <span style={{ color: "var(--positive, #22c55e)", fontWeight: 600 }}>
                + {money(projection.totalInterestGained)} de juros
              </span>
            </div>

            <div
              style={{
                marginTop: "8px",
                display: "flex",
                alignItems: "center",
                gap: "4px",
                fontSize: "0.75rem",
                color: "var(--muted)",
              }}
            >
              <PiggyBank size={12} color="var(--positive, #22c55e)" /> Rendimento médio de{" "}
              <strong>
                {money(Math.round(projection.totalAccumulated * (expectedRate / 100 / 12)))}
                /mês
              </strong>{" "}
              em dividendos/rendimentos futuros
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
