"use client";

import { useEffect, useRef } from "react";
import { ArcElement, BarController, BarElement, CategoryScale, Chart, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip } from "chart.js";

Chart.register(ArcElement, BarController, BarElement, CategoryScale, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip);

type Series = { label: string; values: number[]; color: string };
type Props =
  | { type: "bar" | "line" | "doughnut"; labels: string[]; values: number[]; label: string; color: string; series?: undefined; legend?: boolean; compactY?: boolean }
  | { type: "line"; labels: string[]; series: Series[]; values?: undefined; label?: undefined; color?: undefined; legend?: boolean; compactY?: boolean };

function formatCompact(value: number): string {
  const abs = Math.abs(value);
  if (abs >= 1000) return `${(value / 1000).toFixed(abs >= 10000 ? 0 : 1).replace(/\.0$/, "")}k`;
  return String(value);
}

const FALLBACK: Record<string, string> = {
  "--muted": "#60716c",
  "--border": "rgba(96,113,108,.18)",
  "--accent": "#087f5b",
  "--positive": "#2f9e44",
  "--warning": "#d97706",
  "--danger": "#e53e3e",
  "--gold": "#b8860b",
};

/** Lê os tokens vivos do tema (SSR/jsdom caem no fallback). */
function readTokens() {
  if (typeof window === "undefined") return { ...FALLBACK };
  const styles = getComputedStyle(document.documentElement);
  return Object.fromEntries(
    Object.entries(FALLBACK).map(([name, fallback]) => [name, styles.getPropertyValue(name).trim() || fallback]),
  ) as Record<string, string>;
}

export function DashboardChart(props: Props) {
  const { type, labels, compactY } = props;
  const legendOverride = props.legend;
  const ref = useRef<HTMLCanvasElement>(null);
  const series: Series[] = props.series ?? [{ label: props.label, values: props.values, color: props.color }];
  const seriesKey = series.map((s) => `${s.label}:${s.color}:${s.values.join(",")}`).join("|");
  useEffect(() => {
    if (!ref.current) return;
    const token = readTokens();
    // ponytail: --positive por último porque no tema claro ele é igual a --accent.
    const palette = ["--accent", "--gold", "--warning", "--danger", "--positive"].map((name) => token[name]);
    const datasets = series.map((s) => ({
      label: s.label,
      data: s.values,
      backgroundColor: type === "doughnut" ? s.values.map((_, index) => palette[index % palette.length]) : s.color,
      borderColor: s.color,
      borderWidth: type === "line" ? 2 : 0,
      fill: type === "line" && series.length === 1,
      tension: .35,
      pointRadius: type === "line" ? 3 : undefined,
      pointBackgroundColor: s.color,
    }));
    const showLegend = legendOverride ?? (type === "doughnut" || series.length > 1);
    const chart = new Chart(ref.current, { type, data: { labels, datasets }, options: { maintainAspectRatio: false, plugins: { legend: { display: showLegend, labels: { color: token["--muted"] } }, tooltip: { callbacks: { label: (item) => `${item.dataset.label}: ${new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(item.raw))}` } } }, scales: type === "doughnut" ? {} : { x: { ticks: { color: token["--muted"], maxTicksLimit: 7 }, grid: { display: false } }, y: { ticks: { color: token["--muted"], callback: (value) => compactY ? formatCompact(Number(value)) : `R$ ${value}` }, grid: { color: token["--border"] } } } } });
    return () => chart.destroy();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [type, labels, seriesKey, legendOverride, compactY]);
  const ariaLabel = series.map((s) => `${s.label}: ${labels.map((item, index) => `${item} ${s.values[index]}`).join(", ")}`).join(" | ");
  return <canvas ref={ref} role="img" aria-label={ariaLabel} />;
}
