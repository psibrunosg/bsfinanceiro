"use client";

import Link from "next/link";
import { useState } from "react";
import { LoaderCircle } from "lucide-react";
import { appPath, LOGO_URL } from "@/lib/app-path";
import { authSchema } from "@/lib/validation/auth";

export function AuthForm({ mode }: { mode: "login" | "signup" }) {
  const [state, setState] = useState<{ error?: string; success?: string }>(() => {
    if (typeof window !== "undefined" && new URLSearchParams(window.location.search).get("erro") === "confirmacao") {
      return { error: "Nao foi possivel confirmar seu e-mail. Solicite um novo link de confirmacao." };
    }

    return {};
  });
  const [pending, setPending] = useState(false);
  const enter = mode === "login";

  async function submit(data: FormData) {
    if (pending) return;
    setPending(true);
    setState({});
    const parsed = authSchema.safeParse(Object.fromEntries(data));
    if (!parsed.success) {
      setState({ error: parsed.error.issues[0]?.message });
      setPending(false);
      return;
    }

    // 1. Tenta autenticar na API PostgreSQL da VPS
    try {
      const endpoint = enter ? "/api/auth/login" : "/api/auth/register";
      const res = await fetch(endpoint, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(parsed.data),
      });

      if (res.ok) {
        const resData = await res.json();
        if (resData.success) {
          if (!resData.token || !resData.user?.id || !resData.workspace?.id) {
            setState({ error: "A resposta do serviço de acesso está incompleta. Tente novamente." });
            setPending(false);
            return;
          }
          if (typeof window !== "undefined") {
            localStorage.setItem("bsfinanceiro_user", JSON.stringify(resData.user));
            localStorage.setItem("bsfinanceiro_workspace", JSON.stringify(resData.workspace));
            if (resData.token) localStorage.setItem("bsfinanceiro_token", resData.token);
          }
          const invite = sessionStorage.getItem("pending_invite_token");
          window.location.replace(appPath(invite ? `/convite?token=${encodeURIComponent(invite)}` : (!enter || resData.onboarding_required) ? "/onboarding" : "/"));
          return;
        }
      } else {
        const resData = await res.json().catch(() => ({}));
        if (resData.error) {
          setState({ error: resData.error });
          setPending(false);
          return;
        }
      }
    } catch {
      setState({ error: "O serviço de acesso está indisponível. Tente novamente em alguns instantes." });
      setPending(false);
      return;
    }

    setState({ error: "Não foi possível concluir o acesso. Tente novamente." });
    setPending(false);
  }

  return (
    <main className="auth-page">
      <section className="auth-panel">
        <div className="auth-brand">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={LOGO_URL} alt="" aria-hidden="true" width={44} height={44} />
          <strong>BS Financeiro</strong>
        </div>
        <div>
          <p className="eyebrow">{enter ? "BEM-VINDO DE VOLTA" : "COMECE AGORA"}</p>
          <h1>{enter ? "Entre na sua conta" : "Crie sua conta"}</h1>
          <p className="muted">Seu dinheiro explicado de forma simples.</p>
        </div>
        {/* method="post" e defensivo: se o JS falhar (hidratacao quebrada, erro de
          runtime), o submit nativo acontece. Sem isso o default e GET e a senha
          vai parar na query string da URL — e dai para o historico do navegador,
          logs de servidor e Referer. Ja aconteceu num dev server corrompido. */}
        <form method="post" onSubmit={(e) => { e.preventDefault(); void submit(new FormData(e.currentTarget)); }} className="auth-form">
          <label htmlFor="email">E-mail</label>
          <input id="email" name="email" type="email" autoComplete="email" required />
          <label htmlFor="password">Senha</label>
          <input id="password" name="password" type="password" autoComplete={enter ? "current-password" : "new-password"} minLength={8} required />
          <button disabled={pending}>{pending ? <LoaderCircle className="spin" /> : null}{enter ? "Entrar" : "Criar conta"}</button>
          {state.error ? <p className="form-error" role="alert">{state.error}</p> : null}
          {state.success ? <p className="form-success" role="status">{state.success}</p> : null}
        </form>
        <p className="auth-switch">
          {enter ? "Ainda não tem conta?" : "Já tem uma conta?"}{" "}
          <Link href={enter ? "/cadastro" : "/entrar"}>{enter ? "Cadastre-se" : "Entrar"}</Link>
        </p>
      </section>
      <aside className="auth-aside">
        <blockquote>“Finalmente consigo entender para onde meu dinheiro está indo.”</blockquote>
        <p>Controle semanal, visual e sem planilhas complicadas.</p>
      </aside>
    </main>
  );
}
