"use client";

import { useEffect, useRef } from "react";
import { ArcElement, BarController, BarElement, CategoryScale, Chart, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip } from "chart.js";

Chart.register(ArcElement, BarController, BarElement, CategoryScale, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip);

type Props = { type: "bar" | "line" | "doughnut"; labels: string[]; values: number[]; label: string; color: string };

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

export function DashboardChart({ type, labels, values, label, color }: Props) {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    if (!ref.current) return;
    const token = readTokens();
    // ponytail: --positive por último porque no tema claro ele é igual a --accent.
    const palette = ["--accent", "--gold", "--warning", "--danger", "--positive"].map((name) => token[name]);
    const chart = new Chart(ref.current, { type, data: { labels, datasets: [{ label, data: values, backgroundColor: type === "doughnut" ? values.map((_, index) => palette[index % palette.length]) : color, borderColor: color, borderWidth: type === "line" ? 2 : 0, fill: type === "line", tension: .35 }] }, options: { maintainAspectRatio: false, plugins: { legend: { display: type === "doughnut", labels: { color: token["--muted"] } }, tooltip: { callbacks: { label: (item) => `${item.dataset.label}: ${new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(item.raw))}` } } }, scales: type === "doughnut" ? {} : { x: { ticks: { color: token["--muted"], maxTicksLimit: 7 }, grid: { display: false } }, y: { ticks: { color: token["--muted"], callback: (value) => `R$ ${value}` }, grid: { color: token["--border"] } } } } });
    return () => chart.destroy();
  }, [color, label, labels, type, values]);
  return <canvas ref={ref} role="img" aria-label={`${label}: ${labels.map((item, index) => `${item} ${values[index]}`).join(", ")}`} />;
}
