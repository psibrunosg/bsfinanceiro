"use client";

import { useEffect, useState, Suspense } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";

function InviteContent() {
  const search = useSearchParams();
  const token = search.get("token");
  const router = useRouter();
  const supabase = createClient();
  
    const [message, setMessage] = useState("Validando convite...");

  useEffect(() => {
    async function checkInvite() {
      if (!token) {
        setMessage("Token de convite não encontrado.");
                return;
      }

      // 1. Check if user is logged in
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        // Redirect to login but save token in sessionStorage so they can come back
        sessionStorage.setItem("pending_invite_token", token);
        setMessage("Redirecionando para login/cadastro...");
        setTimeout(() => {
          router.push("/entrar");
        }, 1500);
        return;
      }

      // 2. Call RPC to accept invite
      const { data: success, error } = await supabase.rpc("accept_workspace_invite", { invite_token: token });
      
      if (error) {
        setMessage("Erro ao aceitar convite: " + error.message);
      } else if (success) {
        setMessage("Convite aceito com sucesso! Redirecionando para seu novo painel...");
        setTimeout(() => {
          router.push("/");
        }, 2000);
      } else {
        setMessage("Convite inválido ou expirado.");
      }
          }

    checkInvite();
  }, [token, router, supabase]);

  return (
    <div style={{ padding: "2rem", maxWidth: "600px", margin: "0 auto", textAlign: "center", marginTop: "10vh" }}>
      <h2>Convite de Família</h2>
      <p style={{ marginTop: "1rem", color: "#666" }}>{message}</p>
    </div>
  );
}

export default function InvitePage() {
  return (
    <Suspense fallback={<p>Carregando...</p>}>
      <InviteContent />
    </Suspense>
  );
}
