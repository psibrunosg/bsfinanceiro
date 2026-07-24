"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { createClient } from "@/lib/supabase/client";
import { appPath } from "@/lib/app-path";
import { useMemo, useState } from "react";

export function SettingsPage() {
  const { workspace, alertPrefs, loading, message, setMessage, reload } = useFinance("settings");
  const supabase = useMemo(() => createClient(), []);
  const [saving, setSaving] = useState(false);

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function savePreferences(form: FormData) {
    setSaving(true);
    const { data: userData } = await supabase.auth.getUser();
    const p = {
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      budget_alerts: form.get("budget_alerts") === "on",
      goal_alerts: form.get("goal_alerts") === "on",
      fixed_commitment_alerts: form.get("fixed_commitment_alerts") === "on",
      credit_card_alerts: form.get("credit_card_alerts") === "on",
      low_balance_alerts: form.get("low_balance_alerts") === "on",
      weekly_digest: form.get("weekly_digest") === "on",
      budget_warning_percent: Number(form.get("budget_warning_percent") || 80),
      low_balance_amount: Number(form.get("low_balance_amount") || 0),
      weekly_digest_day: Number(form.get("weekly_digest_day") || 1),
    };
    const { error } = await supabase.from("alert_preferences").upsert(p, { onConflict: "workspace_id,owner_id" });
    setMessage(error ? "Não foi possível salvar." : "Preferências salvas.");
    setSaving(false);
    await reload();
  }

  async function signOut() {
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  const p = alertPrefs;

  return (
    <main className="management-page">
      <PageHeader title="Configurações" subtitle="Preferências e alertas." workspaceName={workspace.name} />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      <section className="settings-page">
        <form className="settings-card" onSubmit={async (e) => { e.preventDefault(); await savePreferences(new FormData(e.currentTarget)); }}>
          <h2>Alertas</h2>
          <div className="preferences-form">
            <div className="preference-list">
              <label><span>Alertas de orçamento</span><input type="checkbox" name="budget_alerts" defaultChecked={p?.budget_alerts ?? true} /></label>
              <label><span>Alertas de metas</span><input type="checkbox" name="goal_alerts" defaultChecked={p?.goal_alerts ?? true} /></label>
              <label><span>Alertas de compromissos fixos</span><input type="checkbox" name="fixed_commitment_alerts" defaultChecked={p?.fixed_commitment_alerts ?? true} /></label>
              <label><span>Alertas de cartão de crédito</span><input type="checkbox" name="credit_card_alerts" defaultChecked={p?.credit_card_alerts ?? true} /></label>
              <label><span>Alertas de saldo baixo</span><input type="checkbox" name="low_balance_alerts" defaultChecked={p?.low_balance_alerts ?? true} /></label>
              <label><span>Resumo semanal</span><input type="checkbox" name="weekly_digest" defaultChecked={p?.weekly_digest ?? true} /></label>
            </div>
            <details>
              <summary>Configurações avançadas</summary>
              <div className="settings-grid">
                <label>Aviso de orçamento (%)
                  <input type="number" name="budget_warning_percent" min="1" max="100" defaultValue={p?.budget_warning_percent ?? 80} />
                </label>
                <label>Saldo baixo (R$)
                  <input type="number" name="low_balance_amount" min="0" step="0.01" defaultValue={p?.low_balance_amount ?? 0} />
                </label>
                <label>Dia do resumo semanal
                  <select name="weekly_digest_day" defaultValue={p?.weekly_digest_day ?? 1}>
                    <option value="0">Domingo</option>
                    <option value="1">Segunda</option>
                    <option value="2">Terça</option>
                    <option value="3">Quarta</option>
                    <option value="4">Quinta</option>
                    <option value="5">Sexta</option>
                    <option value="6">Sábado</option>
                  </select>
                </label>
              </div>
            </details>
            <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
          </div>
        </form>
        <div className="settings-card" style={{ marginTop: 16 }}>
          <h2>Sessão</h2>
          <div className="preferences-form">
            <button type="button" onClick={signOut} style={{ background: "var(--danger)" }}>Sair da conta</button>
          </div>
        </div>
      </section>
    </main>
  );
}
