"use client";

import { useEffect, useRef, useState } from "react";
import { ArcElement, BarController, BarElement, CategoryScale, Chart, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip } from "chart.js";

Chart.register(ArcElement, BarController, BarElement, CategoryScale, DoughnutController, Filler, Legend, LineController, LineElement, LinearScale, PointElement, Tooltip);

type Props = { type: "bar" | "line" | "doughnut"; labels: string[]; values: number[]; label: string; color: string };

export function DashboardChart({ type, labels, values, label, color }: Props) {
  const ref = useRef<HTMLCanvasElement>(null);
  const [themeVersion, setThemeVersion] = useState(0);
  useEffect(() => {
    const observer = new MutationObserver(() => setThemeVersion((version) => version + 1));
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
    return () => observer.disconnect();
  }, []);
  useEffect(() => {
    if (!ref.current) return;
    const root = getComputedStyle(document.documentElement);
    const muted = root.getPropertyValue("--muted").trim() || "#60716c";
    const border = root.getPropertyValue("--border").trim() || "rgba(96,113,108,.18)";
    const chart = new Chart(ref.current, { type, data: { labels, datasets: [{ label, data: values, backgroundColor: type === "doughnut" ? values.map((_, index) => `hsl(${158 - index * 24} 55% ${42 + index * 6}%)`) : color, borderColor: color, borderWidth: type === "line" ? 2 : 0, fill: type === "line", tension: .35 }] }, options: { maintainAspectRatio: false, plugins: { legend: { display: type === "doughnut", labels: { color: muted } }, tooltip: { callbacks: { label: (item) => `${item.dataset.label}: ${new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(Number(item.raw))}` } } }, scales: type === "doughnut" ? {} : { x: { ticks: { color: muted }, grid: { display: false } }, y: { ticks: { color: muted, callback: (value) => `R$ ${value}` }, grid: { color: border } } } } });
    return () => chart.destroy();
  }, [color, label, labels, type, values, themeVersion]);
  return <canvas ref={ref} role="img" aria-label={`${label}: ${labels.map((item, index) => `${item} ${values[index]}`).join(", ")}`} />;
}
