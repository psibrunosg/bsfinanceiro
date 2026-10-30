"use client";
import { useState } from "react";
import { apiFetch } from "@/lib/api-client";
import { appUrl } from "@/lib/app-path";

export function ShareReportButton({ workspaceId }: { workspaceId: string }) {
  const [link, setLink] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleShare() {
    setLoading(true);
    try {
      const response = await apiFetch("/api/reports/share", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspaceId,
          name: "Relatório Consolidado",
        }),
      });
      const data = await response.json().catch(() => ({}));

      if (!response.ok || !data?.token) {
        throw new Error(data?.error || "share_report_failed");
      }

      setLink(appUrl("/s") + "?token=" + encodeURIComponent(data.token));
    } catch (error) {
      console.error(error);
      alert("Erro ao gerar link");
    } finally {
      setLoading(false);
    }
  }

  if (link) {
    return (
      <div style={{ display: "flex", gap: "0.5rem", alignItems: "center" }}>
        <input type="text" readOnly value={link} style={{ padding: "8px", borderRadius: "4px", border: "1px solid #ccc" }} />
        <button onClick={() => navigator.clipboard.writeText(link)} className="secondary-button">Copiar</button>
      </div>
    );
  }

  return <button onClick={handleShare} disabled={loading} className="secondary-button">{loading ? "Gerando..." : "Compartilhar Relatório via Link"}</button>;
}
