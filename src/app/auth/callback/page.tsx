"use client";

import { useEffect } from "react";
import { appPath } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

export default function AuthCallbackPage() {
  useEffect(() => {
    const run = async () => {
      const code = new URLSearchParams(window.location.search).get("code");
      if (!code) {
        window.location.replace(appPath("/entrar?erro=confirmacao"));
        return;
      }
      const { error } = await createClient().auth.exchangeCodeForSession(code);
      window.location.replace(appPath(error ? "/entrar?erro=confirmacao" : "/"));
    };
    void run();
  }, []);

  return (
    <main className="auth-shell">
      <section className="auth-card">
        <p className="eyebrow">BS Financeiro</p>
        <h1>Confirmando seu acesso...</h1>
        <p className="muted">Aguarde um instante.</p>
      </section>
    </main>
  );
}
