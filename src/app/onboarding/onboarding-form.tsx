"use client";

import { ArrowRight, LoaderCircle } from "lucide-react";
import React, { useState } from "react";
import { appPath, LOGO_URL } from "../../lib/app-path";
import { createClient } from "../../lib/supabase/client";

type FieldName = "display_name" | "monthly_income" | "current_balance" | "card_name" | "closing_day" | "due_day";
type FieldErrors = Partial<Record<FieldName, string>>;

const fieldIds: Record<FieldName, string> = {
  display_name: "display_name",
  monthly_income: "monthly_income",
  current_balance: "current_balance",
  card_name: "card_name",
  closing_day: "closing_day",
  due_day: "due_day",
};

function numberValue(data: FormData, field: FieldName) {
  const value = data.get(field);
  return typeof value === "string" && value.trim() ? Number(value) : Number.NaN;
}

function validate(data: FormData): FieldErrors {
  const errors: FieldErrors = {};
  const name = String(data.get("display_name") || "").trim();
  const income = numberValue(data, "monthly_income");
  const balance = numberValue(data, "current_balance");
  const cardName = String(data.get("card_name") || "").trim();
  const closingDay = numberValue(data, "closing_day");
  const dueDay = numberValue(data, "due_day");

  if (name.length < 2 || name.length > 60) errors.display_name = "Informe seu nome com 2 a 60 caracteres.";
  if (!Number.isFinite(income) || income <= 0) errors.monthly_income = "Informe uma renda mensal maior que zero.";
  if (!Number.isFinite(balance)) errors.current_balance = "Informe seu saldo atual.";
  if (cardName.length < 2 || cardName.length > 60) errors.card_name = "Informe o nome do cartão com 2 a 60 caracteres.";
  if (!Number.isInteger(closingDay) || closingDay < 1 || closingDay > 31) errors.closing_day = "Informe um dia de fechamento entre 1 e 31.";
  if (!Number.isInteger(dueDay) || dueDay < 1 || dueDay > 31) errors.due_day = "Informe um dia de vencimento entre 1 e 31.";

  return errors;
}

function rpcFieldError(message: string): FieldErrors {
  if (message.includes("display name")) return { display_name: "Revise seu nome." };
  if (message.includes("monthly income")) return { monthly_income: "Informe uma renda mensal maior que zero." };
  if (message.includes("current balance")) return { current_balance: "Revise seu saldo atual." };
  if (message.includes("card name")) return { card_name: "Revise o nome do cartão." };
  if (message.includes("card day")) return { closing_day: "Revise o dia de fechamento do cartão." };
  return {};
}

export function OnboardingForm({ suggestedName }: { suggestedName: string }) {
  const [errors, setErrors] = useState<FieldErrors>({});
  const [formError, setFormError] = useState("");
  const [pending, setPending] = useState(false);

  function focusFirstError(fieldErrors: FieldErrors) {
    const firstField = (Object.keys(fieldErrors) as FieldName[])[0];
    if (firstField) setTimeout(() => document.getElementById(fieldIds[firstField])?.focus(), 0);
  }

  async function submit(data: FormData) {
    if (pending) return;

    const fieldErrors = validate(data);
    if (Object.keys(fieldErrors).length) {
      setErrors(fieldErrors);
      setFormError("");
      focusFirstError(fieldErrors);
      return;
    }

    const monthlyIncome = numberValue(data, "monthly_income");
    const currentBalance = numberValue(data, "current_balance");
    const closingDay = numberValue(data, "closing_day");
    const dueDay = numberValue(data, "due_day");

    setErrors({});
    setFormError("");
    setPending(true);
    const supabase = createClient();
    const { data: userData } = await supabase.auth.getUser();

    if (!userData.user) {
      setFormError("Sua sessão expirou. Entre novamente.");
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
      const rpcErrors = rpcFieldError(rpcError.message);
      setErrors(rpcErrors);
      setFormError(Object.keys(rpcErrors).length ? "" : "Não foi possível concluir agora. Tente novamente.");
      setPending(false);
      focusFirstError(rpcErrors);
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
          noValidate
          onSubmit={(event) => {
            event.preventDefault();
            void submit(new FormData(event.currentTarget));
          }}
        >
          <fieldset disabled={pending}>
            <label htmlFor="display_name">Como podemos chamar você?</label>
            <input id="display_name" name="display_name" defaultValue={suggestedName} minLength={2} maxLength={60} required aria-invalid={Boolean(errors.display_name)} aria-describedby={errors.display_name ? "display_name-error" : undefined} />
            {errors.display_name ? <p id="display_name-error" className="form-error">{errors.display_name}</p> : null}

            <label htmlFor="monthly_income">Renda mensal</label>
            <input id="monthly_income" name="monthly_income" type="number" inputMode="decimal" min="0.01" step="0.01" placeholder="0,00" required aria-invalid={Boolean(errors.monthly_income)} aria-describedby={errors.monthly_income ? "monthly_income-error" : undefined} />
            {errors.monthly_income ? <p id="monthly_income-error" className="form-error">{errors.monthly_income}</p> : null}

            <label htmlFor="current_balance">Saldo atual</label>
            <input id="current_balance" name="current_balance" type="number" inputMode="decimal" step="0.01" placeholder="0,00" required aria-invalid={Boolean(errors.current_balance)} aria-describedby={errors.current_balance ? "current_balance-error" : undefined} />
            {errors.current_balance ? <p id="current_balance-error" className="form-error">{errors.current_balance}</p> : null}

            <fieldset className="onboarding-card-fields">
              <legend>Seu cartão principal</legend>
              <label htmlFor="card_name">Nome do cartão</label>
              <input id="card_name" name="card_name" minLength={2} maxLength={60} placeholder="Ex.: Nubank" required aria-invalid={Boolean(errors.card_name)} aria-describedby={errors.card_name ? "card_name-error" : undefined} />
              {errors.card_name ? <p id="card_name-error" className="form-error">{errors.card_name}</p> : null}
              <div className="onboarding-day-fields">
                <label htmlFor="closing_day">Fecha dia<input id="closing_day" name="closing_day" type="number" min="1" max="31" inputMode="numeric" required aria-invalid={Boolean(errors.closing_day)} aria-describedby={errors.closing_day ? "closing_day-error" : undefined} /></label>
                <label htmlFor="due_day">Vence dia<input id="due_day" name="due_day" type="number" min="1" max="31" inputMode="numeric" required aria-invalid={Boolean(errors.due_day)} aria-describedby={errors.due_day ? "due_day-error" : undefined} /></label>
              </div>
              {errors.closing_day ? <p id="closing_day-error" className="form-error">{errors.closing_day}</p> : null}
              {errors.due_day ? <p id="due_day-error" className="form-error">{errors.due_day}</p> : null}
            </fieldset>
          </fieldset>
          {formError ? <p className="form-error" role="alert">{formError}</p> : null}
          <button className="onboarding-submit" disabled={pending}>
            {pending ? <LoaderCircle className="spin" aria-hidden="true" /> : <ArrowRight aria-hidden="true" />}
            {pending ? "Salvando..." : "Concluir e ver meu painel"}
          </button>
        </form>
      </section>
    </main>
  );
}
