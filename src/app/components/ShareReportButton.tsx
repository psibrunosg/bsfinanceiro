"use client";
import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

export function ShareReportButton({ workspaceId }: { workspaceId: string }) {
  const [link, setLink] = useState("");
  const [loading, setLoading] = useState(false);
  const supabase = createClient();

  async function handleShare() {
    setLoading(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("Unauthorized");

      const token = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
      
      const { data, error } = await supabase.from("shared_reports").insert({
        workspace_id: workspaceId,
        owner_id: user.id,
        token: token,
        name: "Relatório Consolidado",
        config: {},
      }).select("token").single();

      if (error) throw error;
      setLink(window.location.origin + "/s?token=" + data.token);
    } catch (e) {
      console.error(e);
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
