"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { createClient } from "@/lib/supabase/client";
import { appPath } from "@/lib/app-path";
import { useMemo, useState } from "react";
import { useThemePreference } from "./components/ThemeProvider";

export function SettingsPage() {
  const { workspace, alertPrefs, workspacePrefs, contexts = [], categories, loading, message, setMessage, reload } = useFinance("settings");
  const supabase = useMemo(() => createClient(), []);
  const { preference, updateThemePreference } = useThemePreference();
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState("Aparência");

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  const TABS = ["Aparência", "Painel", "Contextos", "Ganhos", "Gastos", "Alertas", "Privacidade", "Dados"];

  async function savePreferences(form: FormData) {
    setSaving(true);
    const { data: userData } = await supabase.auth.getUser();
    
    if (activeTab === "Alertas") {
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
      setMessage(error ? "Não foi possível salvar alertas." : "Preferências de alerta salvas.");
    } else {
      const p: Record<string, unknown> = {
        workspace_id: workspace.id,
        owner_id: userData.user?.id,
      };
      if (form.has("compact_mode")) p.compact_mode = form.get("compact_mode") === "true";
      if (form.has("personal_color")) p.personal_color = form.get("personal_color");
      if (form.has("default_period")) p.default_period = form.get("default_period");
      if (form.has("hide_values")) p.hide_values = form.get("hide_values") === "true";
      if (form.has("default_context_id")) p.default_context_id = form.get("default_context_id") || null;
      if (form.has("default_appointment_value")) p.default_appointment_value = parseFloat(String(form.get("default_appointment_value")).replace(/\./g, "").replace(",", ".")) || 0;
      if (form.has("default_billing_deadline_days")) p.default_billing_deadline_days = Number(form.get("default_billing_deadline_days")) || 30;
      if (form.has("default_category_id")) p.default_category_id = form.get("default_category_id") || null;
      
      const { error } = await supabase.from("workspace_preferences").upsert(p, { onConflict: "workspace_id,owner_id" });
      setMessage(error ? "Não foi possível salvar preferências." : "Preferências salvas.");
    }
    
    setSaving(false);
    await reload();
  }

  async function signOut() {
    await supabase.auth.signOut();
    window.location.replace(appPath("/entrar"));
  }

  const p = alertPrefs;
  const wp = workspacePrefs ?? ({} as NonNullable<typeof workspacePrefs>);

  return (
    <main className="management-page">
      <PageHeader title="Configurações" subtitle="Preferências e alertas." workspaceName={workspace.name} />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      
      <div className="tabs-nav" style={{ display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '16px', borderBottom: '1px solid var(--border-color)', marginBottom: '24px' }}>
        {TABS.map(tab => (
          <button 
            key={tab} 
            onClick={() => setActiveTab(tab)}
            style={{ 
              background: activeTab === tab ? 'var(--primary-color)' : 'transparent', 
              color: activeTab === tab ? '#fff' : 'var(--text-color)',
              border: 'none',
              padding: '6px 16px',
              borderRadius: '20px',
              cursor: 'pointer',
              whiteSpace: 'nowrap'
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      <section className="settings-page">
        <form className="settings-card" onSubmit={async (e) => { e.preventDefault(); await savePreferences(new FormData(e.currentTarget)); }}>
          <h2>{activeTab}</h2>
          
          {activeTab === "Alertas" && (
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
          )}

          {activeTab === "Aparência" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Tema
                  <select
                    name="theme"
                    value={preference}
                    onChange={(e) => void updateThemePreference(e.target.value as "system" | "light" | "dark")}
                  >
                    <option value="system">Sistema</option>
                    <option value="light">Claro</option>
                    <option value="dark">Escuro</option>
                  </select>
                </label>
                <label>Modo Compacto
                  <select name="compact_mode" defaultValue={wp?.compact_mode ? "true" : "false"}>
                    <option value="false">Desativado</option>
                    <option value="true">Ativado</option>
                  </select>
                </label>
                <label>Cor de Destaque
                  <input type="color" name="personal_color" defaultValue={wp?.personal_color ?? "#087f5b"} />
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Painel" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Período Padrão
                  <select name="default_period" defaultValue={wp?.default_period ?? "current_month"}>
                    <option value="current_month">Mês atual</option>
                    <option value="last_month">Mês anterior</option>
                    <option value="current_year">Ano atual</option>
                    <option value="all_time">Todo o período</option>
                  </select>
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Contextos" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Contexto Padrão
                  <select name="default_context_id" defaultValue={wp?.default_context_id ?? ""}>
                    <option value="">Nenhum (Visão Geral)</option>
                    {contexts.map((c: { id: string; name: string }) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Privacidade" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Ocultar Valores por Padrão
                  <select name="hide_values" defaultValue={wp?.hide_values ? "true" : "false"}>
                    <option value="false">Desativado</option>
                    <option value="true">Ativado</option>
                  </select>
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Ganhos" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Valor padrão por atendimento (R$)
                  <input
                    type="number"
                    name="default_appointment_value"
                    min="0"
                    step="0.01"
                    defaultValue={wp?.default_appointment_value ?? 0}
                  />
                </label>
                <label>Prazo de cobrança (dias)
                  <input
                    type="number"
                    name="default_billing_deadline_days"
                    min="1"
                    max="365"
                    defaultValue={wp?.default_billing_deadline_days ?? 30}
                  />
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Gastos" && (
            <div className="preferences-form">
              <div className="settings-grid">
                <label>Categoria de gasto padrão
                  <select name="default_category_id" defaultValue={wp?.default_category_id ?? ""}>
                    <option value="">Sem padrão</option>
                    {categories.filter((c) => c.kind === "expense").map((c) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </label>
              </div>
              <button disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Dados" && (
            <div className="preferences-form">
              <p className="muted">Exportar ou limpar seus dados. A exportação em CSV estará disponível em breve.</p>
            </div>
          )}
        </form>

        <div className="settings-card" style={{ marginTop: 16 }}>
          <h2>Sessão</h2>
          <div className="preferences-form">
            <button type="button" onClick={signOut} style={{ background: "var(--danger-color, #e03131)", color: "#fff" }}>Sair da conta</button>
          </div>
        </div>
      </section>
    </main>
  );
}
