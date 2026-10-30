"use client";
import { useEffect, useState } from "react";
import { apiFetch } from "@/lib/api-client";
import { money } from "./Money";

type Item = { ordinal: number; description: string; purchasedOn: string; installmentAmountCents: number; installmentNumber: number; installmentCount: number; totalAmountCents: number | null; sourceFingerprint: string };
type Import = { id: string; credit_card_id: string; file_name: string; status: string; declared_total_cents: number; items: Item[] };
export function CardStatementReview({ workspaceId, cardId, version, onApplied }: { workspaceId: string; cardId: string | null; version: number; onApplied: () => Promise<void> }) {
  const [jobs, setJobs] = useState<Import[]>([]);
  const [message, setMessage] = useState("");
  const [busy, setBusy] = useState(false);
  const [refresh, setRefresh] = useState(0);
  useEffect(() => {
    let active = true;
    void apiFetch(`/api/card-statement-imports?workspace_id=${encodeURIComponent(workspaceId)}`).then(async response => {
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || "Não foi possível carregar as faturas importadas.");
      if (active) setJobs(Array.isArray(data) ? data : []);
    }).catch(error => { if (active) setMessage(error.message); });
    return () => { active = false; };
  }, [workspaceId, version, refresh]);
  async function act(job: Import, action: "apply" | "discard") {
    setBusy(true); setMessage("");
    try {
      const response = await apiFetch(`/api/card-statement-imports/${job.id}/${action}`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ items: job.items }) });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error || "Não foi possível confirmar a revisão.");
      setMessage(action === "apply" ? "Compras importadas com sucesso." : "Importação descartada.");
      setRefresh(value => value + 1); await onApplied();
    } catch (error) { setMessage(error instanceof Error ? error.message : "Não foi possível confirmar a revisão."); }
    finally { setBusy(false); }
  }
  const visible = jobs.filter(job => (!cardId || job.credit_card_id === cardId) && job.status === "pending_review");
  return <section aria-label="Revisão de faturas importadas" aria-busy={busy}>
    {message && <p role="status">{message}</p>}
    {visible.map(job => <article className="dashboard-card" key={job.id}>
      <h3>Revisar {job.file_name}</h3>
      <p>Total declarado: {money(Number(job.declared_total_cents) / 100)}</p>
      <ul>{job.items.map((item, index) => <li key={item.ordinal}>
        <strong>{item.description}</strong> · {item.purchasedOn} · parcela {item.installmentNumber}/{item.installmentCount}: {money(item.installmentAmountCents / 100)}
        <label>Total da compra {item.ordinal}
          <input type="number" min="0.01" step="0.01" required disabled={busy || item.totalAmountCents !== null && !itemNeedsTotal(jobs, job.id, index)} value={item.totalAmountCents === null ? "" : item.totalAmountCents / 100} onChange={event => {
            const cents = event.target.value === "" ? null : Math.round(Number(event.target.value) * 100);
            setJobs(previous => previous.map(value => value.id === job.id ? { ...value, items: value.items.map((entry, i) => i === index ? { ...entry, totalAmountCents: cents } : entry) } : value));
          }} />
        </label>
      </li>)}</ul>
      <button disabled={busy || job.items.some(item => item.totalAmountCents === null)} onClick={() => void act(job, "apply")}>Confirmar compras revisadas</button>
      <button disabled={busy} onClick={() => void act(job, "discard")}>Descartar importação</button>
    </article>)}
  </section>;
}
function itemNeedsTotal(jobs: Import[], id: string, index: number) {
  // Missing total is a parser review flag preserved through user edits.
  return Boolean((jobs.find(job => job.id === id)?.items[index] as Item & { needsReview?: boolean })?.needsReview);
}
