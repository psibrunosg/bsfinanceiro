"use client";

import { useState } from "react";
import { ArrowRight, BarChart3, Landmark, LoaderCircle, PiggyBank, ReceiptText } from "lucide-react";
import { appPath, LOGO_URL } from "@/lib/app-path";
import { createClient } from "@/lib/supabase/client";

const goals = [
  { id: "understand", label: "Entender meus gastos", icon: BarChart3 },
  { id: "save", label: "Começar a economizar", icon: PiggyBank },
  { id: "debt", label: "Sair das dívidas", icon: Landmark },
  { id: "bills", label: "Organizar minhas contas", icon: ReceiptText },
] as const;

export function OnboardingForm({ suggestedName }: { suggestedName: string }) {
  const [state, setState] = useState<{ error?: string }>({});
  const [pending, setPending] = useState(false);

  async function submit(data: FormData) {
    setPending(true);
    const supabase = createClient();
    const { data: userData } = await supabase.auth.getUser();
    if (!userData.user) {
      setState({ error: "Sua sessão expirou. Entre novamente." });
      setPending(false);
      return;
    }
    const { error } = await supabase.rpc("bootstrap_personal_workspace", {
      p_display_name: data.get("display_name"),
      p_workspace_name: data.get("workspace_name"),
      p_weekly_goal: data.get("weekly_goal"),
    });
    if (error) {
      setState({ error: "Não foi possível concluir agora. Tente novamente." });
      setPending(false);
      return;
    }
    window.location.replace(appPath("/"));
  }

  return (
    <main className="onboarding-page">
      <section className="onboarding-card">
        <div className="auth-brand">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={LOGO_URL} alt="" aria-hidden="true" width={44} height={44} />
          <strong>BS Financeiro</strong>
        </div>
        <div>
          <p className="eyebrow">CONFIGURAÇÃO INICIAL</p>
          <h1>Vamos deixar tudo pronto</h1>
          <p className="muted">Leva menos de dois minutos. Você pode alterar depois.</p>
        </div>
        <form onSubmit={(e) => { e.preventDefault(); void submit(new FormData(e.currentTarget)); }} className="onboarding-form">
          <label htmlFor="display_name">Como podemos chamar você?</label>
          <input id="display_name" name="display_name" defaultValue={suggestedName} required />
          <label htmlFor="workspace_name">Nome do seu espaço financeiro</label>
          <input id="workspace_name" name="workspace_name" defaultValue="Minhas finanças" required />
          <fieldset>
            <legend>Qual é seu foco agora?</legend>
            <div className="goal-grid">
              {goals.map(({ id, label, icon: Icon }) => (
                <label key={id}>
                  <input type="radio" name="weekly_goal" value={id} defaultChecked={id === "understand"} />
                  <span><Icon /><b>{label}</b></span>
                </label>
              ))}
            </div>
          </fieldset>
          {state.error ? <p className="form-error" role="alert">{state.error}</p> : null}
          <button className="onboarding-submit" disabled={pending}>{pending ? <LoaderCircle className="spin" /> : <ArrowRight />}{pending ? "Preparando..." : "Concluir e ver meu painel"}</button>
        </form>
      </section>
    </main>
  );
}
