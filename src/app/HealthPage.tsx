"use client";

import { useMemo } from "react";
import { CircleCheck, OctagonAlert, TriangleAlert } from "lucide-react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { MonthPicker } from "./components/MonthPicker";
import { useMonth } from "./components/MonthContext";
import { money } from "./components/Money";
import { computeHealthReport, type HealthIndicator, type HealthStatus } from "@/lib/finance/health";

const STATUS_LABEL: Record<HealthStatus, string> = { good: "Bom", attention: "Atenção", critical: "Crítico" };
const STATUS_COLOR: Record<HealthStatus, string> = { good: "var(--positive)", attention: "var(--warning)", critical: "var(--danger)" };
const STATUS_ICON = { good: CircleCheck, attention: TriangleAlert, critical: OctagonAlert };
const BAR_MODIFIER: Record<HealthStatus, string> = { good: "", attention: " progress-bar--warning", critical: " progress-bar--danger" };

const GROUPS: { id: HealthIndicator["group"]; title: string }[] = [
  { id: "liquidez", title: "Liquidez" },
  { id: "fluxo", title: "Fluxo" },
  { id: "estrutura", title: "Estrutura de gastos" },
];

const decimal = (value: number, digits = 1) => value.toFixed(digits).replace(".", ",");

function formatValue(indicator: HealthIndicator) {
  if (indicator.unit === "BRL") return money(indicator.value);
  if (indicator.unit === "percent") return `${decimal(indicator.value)}%`;
  if (indicator.unit === "months") return `${decimal(indicator.value)} meses`;
  return decimal(indicator.value, 2);
}

/** Régua visual: só faz sentido em unidades com escala conhecida. */
function fillPercent(indicator: HealthIndicator): number | null {
  if (indicator.unit === "percent") return Math.min(100, Math.max(0, Math.abs(indicator.value)));
  if (indicator.unit === "months") return Math.min(100, Math.max(0, (indicator.value / 12) * 100));
  return null;
}

export function HealthPage() {
  const { workspace, transactions, categories, commitments, accounts, cashPosition, loading } = useFinance("dashboard");
  const { month, label } = useMonth();

  const availableBalance = useMemo(
    () =>
      cashPosition?.balanceCents != null
        ? cashPosition.balanceCents / 100
        : accounts.reduce((sum, account) => sum + Number(account.initial_balance), 0),
    [cashPosition, accounts],
  );

  const report = useMemo(
    () => computeHealthReport({ month, transactions, categories, commitments, availableBalance }),
    [month, transactions, categories, commitments, availableBalance],
  );

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  const counts = report.reduce(
    (acc, indicator) => ({ ...acc, [indicator.status]: acc[indicator.status] + 1 }),
    { good: 0, attention: 0, critical: 0 } as Record<HealthStatus, number>,
  );
  const hasData = transactions.length > 0;

  return (
    <main className="management-page">
      <Nav />
      <PageHeader title="Saúde financeira" subtitle="Seu exame de sangue financeiro, com faixas de referência" workspaceName={workspace.name} />

      <div className="hub-filters">
        <MonthPicker />
        <span className="muted">Competência: {label}</span>
      </div>

      {!hasData ? (
        <p className="dashboard-empty">Registre lançamentos para calcular seus indicadores.</p>
      ) : (
        <section>
          <article className="dashboard-card">
            <p className="eyebrow">RESUMO DO EXAME</p>
            <div className="metric-grid">
              <article className="metric"><span>Bons</span><strong style={{ color: STATUS_COLOR.good }}>{counts.good}</strong></article>
              <article className="metric"><span>Em atenção</span><strong style={{ color: STATUS_COLOR.attention }}>{counts.attention}</strong></article>
              <article className="metric"><span>Críticos</span><strong style={{ color: STATUS_COLOR.critical }}>{counts.critical}</strong></article>
            </div>
          </article>

          {GROUPS.map((group) => (
            <article className="dashboard-card" style={{ marginTop: 18 }} key={group.id}>
              <h3>{group.title}</h3>
              {report.filter((indicator) => indicator.group === group.id).map((indicator) => {
                const Icon = STATUS_ICON[indicator.status];
                const fill = fillPercent(indicator);
                return (
                  <div className="health-row" key={indicator.id}>
                    <div className="health-row__head">
                      <strong>{indicator.label}</strong>
                      <span className="health-row__value">{formatValue(indicator)}</span>
                      <span className="health-status" style={{ color: STATUS_COLOR[indicator.status] }}>
                        <Icon aria-hidden="true" size={16} />
                        {STATUS_LABEL[indicator.status]}
                      </span>
                    </div>
                    {fill !== null && (
                      <div className={`progress-bar${BAR_MODIFIER[indicator.status]}`} role="presentation">
                        <span style={{ width: `${fill}%` }} />
                      </div>
                    )}
                    <p className="muted">Referência: {indicator.reference}</p>
                    <p>{indicator.reading}</p>
                  </div>
                );
              })}
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
