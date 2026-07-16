"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";
import { LoaderCircle } from "lucide-react";
import { appPath, appUrl } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";
import { authErrorMessage, authSchema } from "@/lib/validation/auth";

export function AuthForm({ mode }: { mode: "login" | "signup" }) {
  const [state, setState] = useState<{ error?: string; success?: string }>({});
  const [pending, setPending] = useState(false);
  const enter = mode === "login";

  async function submit(data: FormData) {
    setPending(true);
    setState({});
    const parsed = authSchema.safeParse(Object.fromEntries(data));
    if (!parsed.success) {
      setState({ error: parsed.error.issues[0]?.message });
      setPending(false);
      return;
    }

    const supabase = createClient();
    if (enter) {
      const { error } = await supabase.auth.signInWithPassword(parsed.data);
      if (error) setState({ error: "E-mail ou senha incorretos." });
      else window.location.replace(appPath("/"));
    } else {
      const { error } = await supabase.auth.signUp({
        ...parsed.data,
        options: { emailRedirectTo: appUrl("/auth/callback") },
      });
      setState(
        error
          ? { error: authErrorMessage(error) }
          : { success: "Conta criada. Confira seu e-mail para confirmar o acesso." },
      );
    }
    setPending(false);
  }

  return (
    <main className="auth-page">
      <section className="auth-panel">
        <div className="auth-brand">
          <Image src="/logo-bsfinanceiro.png" alt="" aria-hidden="true" width={44} height={44} priority />
          <strong>BS Financeiro</strong>
        </div>
        <div>
          <p className="eyebrow">{enter ? "BEM-VINDO DE VOLTA" : "COMECE AGORA"}</p>
          <h1>{enter ? "Entre na sua conta" : "Crie sua conta"}</h1>
          <p className="muted">Seu dinheiro explicado de forma simples.</p>
        </div>
        <form onSubmit={(e) => { e.preventDefault(); void submit(new FormData(e.currentTarget)); }} className="auth-form">
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
