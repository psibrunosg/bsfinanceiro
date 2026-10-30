"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { apiFetch } from "@/lib/api-client";
import { appPath } from "@/lib/app-path";
function InviteContent() {
  const token = useSearchParams().get("token");
  const [message, setMessage] = useState("Validando convite...");
  useEffect(() => {
    let cancelled = false;
    async function accept() {
      if (!token) { setMessage("Token de convite não encontrado."); return; }
      try {
        const response = await apiFetch("/api/invites/accept", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ token }) });
        if (cancelled) return;
        if (response.status === 401) {
          sessionStorage.setItem("pending_invite_token", token);
          window.location.replace(appPath("/entrar")); return;
        }
        const result = await response.json();
        if (!response.ok || !result.success) { setMessage(result.error || "Convite inválido ou expirado."); return; }
        localStorage.setItem("bsfinanceiro_workspace", JSON.stringify(result.workspace));
        sessionStorage.removeItem("pending_invite_token");
        window.location.replace(appPath("/"));
      } catch { if (!cancelled) setMessage("Não foi possível aceitar o convite. Tente novamente."); }
    }
    void accept();
    return () => { cancelled = true; };
  }, [token]);
  return <main style={{ padding: "2rem", maxWidth: 600, margin: "10vh auto", textAlign: "center" }}><h1>Convite de Família</h1><p role="status">{message}</p></main>;
}
export default function InvitePage() { return <Suspense fallback={<p role="status">Carregando...</p>}><InviteContent /></Suspense>; }
