"use client";

import { ArrowRight, LoaderCircle } from "lucide-react";
import React, { useState } from "react";
import { appPath, LOGO_URL } from "../../lib/app-path";
import { createClient } from "../../lib/supabase/client";

export function OnboardingForm({ suggestedName }: { suggestedName: string }) {
  const [error, setError] = useState("");
  const [pending, setPending] = useState(false);

  async function submit(data: FormData) {
    if (pending) return;

    const monthlyIncome = Number(data.get("monthly_income"));
    const currentBalance = Number(data.get("current_balance"));
    const closingDay = Number(data.get("closing_day"));
    const dueDay = Number(data.get("due_day"));

    if (!Number.isFinite(monthlyIncome) || monthlyIncome <= 0) {
      setError("Informe uma renda mensal maior que zero.");
      return;
    }
    if (!Number.isFinite(currentBalance) || !Number.isFinite(closingDay) || !Number.isFinite(dueDay)) {
      setError("Revise os valores informados.");
      return;
    }

    setError("");
    setPending(true);
    const supabase = createClient();
    const { data: userData } = await supabase.auth.getUser();

    if (!userData.user) {
      setError("Sua sessão expirou. Entre novamente.");
      setPending(false);
      return;
    }

    const { error: rpcError } = await supabase.rpc("complete_compact_onboarding", {
      p_display_name: data.get("display_name"),
      p_monthly_income: monthlyIncome,
      p_current_balance: currentBalance,
      p_card_name: data.get("card_name"),
      p_card_closing_day: closingDay,
      p_card_due_day: dueDay,
    });

    if (rpcError) {
      setError("Não foi possível concluir agora. Revise os dados e tente novamente.");
      setPending(false);
      return;
    }

    window.location.replace(appPath("/"));
  }

  return (
    <main className="onboarding-page">
      <section className="onboarding-card" aria-labelledby="onboarding-title">
        <div className="auth-brand">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={LOGO_URL} alt="" aria-hidden="true" width={44} height={44} />
          <strong>BS Financeiro</strong>
        </div>
        <div>
          <p className="eyebrow">CONFIGURAÇÃO INICIAL</p>
          <h1 id="onboarding-title">Comece com o essencial</h1>
          <p className="muted">Leva menos de um minuto e você pode ajustar tudo depois.</p>
        </div>
        <form
          className="onboarding-form"
          aria-busy={pending}
          onSubmit={(event) => {
            event.preventDefault();
            void submit(new FormData(event.currentTarget));
          }}
        >
          <fieldset disabled={pending}>
            <label htmlFor="display_name">Como podemos chamar você?</label>
            <input id="display_name" name="display_name" defaultValue={suggestedName} minLength={2} maxLength={60} required />

            <label htmlFor="monthly_income">Renda mensal</label>
            <input id="monthly_income" name="monthly_income" type="number" inputMode="decimal" min="0.01" step="0.01" placeholder="0,00" required />

            <label htmlFor="current_balance">Saldo atual</label>
            <input id="current_balance" name="current_balance" type="number" inputMode="decimal" step="0.01" placeholder="0,00" required />

            <fieldset className="onboarding-card-fields">
              <legend>Seu cartão principal</legend>
              <label htmlFor="card_name">Nome do cartão</label>
              <input id="card_name" name="card_name" minLength={2} maxLength={60} placeholder="Ex.: Nubank" required />
              <div className="onboarding-day-fields">
                <label htmlFor="closing_day">Fecha dia<input id="closing_day" name="closing_day" type="number" min="1" max="31" inputMode="numeric" required /></label>
                <label htmlFor="due_day">Vence dia<input id="due_day" name="due_day" type="number" min="1" max="31" inputMode="numeric" required /></label>
              </div>
            </fieldset>
          </fieldset>
          {error ? <p className="form-error" role="alert">{error}</p> : null}
          <button className="onboarding-submit" disabled={pending}>
            {pending ? <LoaderCircle className="spin" aria-hidden="true" /> : <ArrowRight aria-hidden="true" />}
            {pending ? "Salvando..." : "Concluir e ver meu painel"}
          </button>
        </form>
      </section>
    </main>
  );
}
