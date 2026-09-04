"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { createClient } from "@/lib/supabase/client";
import { appPath } from "@/lib/app-path";
import { useMemo, useState } from "react";
import type { WorkspacePreference } from "./components/types";

export function SettingsPage() {
  const { workspace, workspaceUsers, workspaceInvites, alertPrefs, workspacePrefs, contexts = [], categories, loading, message, setMessage, reload } = useFinance("settings");
  const supabase = useMemo(() => createClient(), []);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState("Aparência");

  if (loading || !workspace) return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;

  const TABS = ["Aparência", "Painel", "Família", "Contextos", "Ganhos", "Gastos", "Alertas", "Privacidade", "Dados"];

  async function savePreferences(form: FormData) {
    setSaving(true);
    const { data: userData } = await supabase.auth.getUser();
    
    if (activeTab === "Família") {
      const action = (form.get("action") as string) || (form.get("invite_role") ? "create_invite" : "");
      if (action === "create_invite") {
        const token = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        const { error } = await supabase.from("workspace_invites").insert({
          workspace_id: workspace.id,
          token,
          role: form.get("invite_role") || "editor"
        });
        setMessage(error ? "Erro ao gerar convite." : "Convite gerado com sucesso!");
        if (!error) reload();
      }
      setSaving(false);
      return;
    }

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
      const p: Partial<WorkspacePreference> & { workspace_id: string; owner_id?: string } = {
        workspace_id: workspace.id,
        owner_id: userData.user?.id,
      };
      if (form.has("compact_mode")) p.compact_mode = form.get("compact_mode") === "true";
      if (form.has("personal_color")) p.personal_color = form.get("personal_color") as string | null;
      if (form.has("default_period")) p.default_period = form.get("default_period") as string;
      if (form.has("hide_values")) p.hide_values = form.get("hide_values") === "true";
      if (form.has("default_context_id")) p.default_context_id = (form.get("default_context_id") as string) || null;
      if (form.has("default_appointment_value")) p.default_appointment_value = parseFloat(String(form.get("default_appointment_value")).replace(/\./g, "").replace(",", ".")) || 0;
      if (form.has("default_billing_deadline_days")) p.default_billing_deadline_days = Number(form.get("default_billing_deadline_days")) || 30;
      if (form.has("default_category_id")) p.default_category_id = (form.get("default_category_id") as string) || null;
      
      const { error } = await supabase.from("workspace_preferences").upsert(p, { onConflict: "workspace_id,owner_id" });
      setMessage(error ? "Não foi possível salvar preferências." : "Preferências salvas.");
    }
    
    setSaving(false);
    await reload();
  }

  async function signOut() {
    try {
      await supabase.auth.signOut();
    } catch {}
    if (typeof window !== "undefined") {
      localStorage.removeItem("bsfinanceiro_user");
      localStorage.removeItem("bsfinanceiro_workspace");
      localStorage.removeItem("bsfinanceiro_token");
    }
    window.location.replace(appPath("/entrar"));
  }

  const p = alertPrefs;
  const wp = workspacePrefs ?? ({} as NonNullable<typeof workspacePrefs>);

  return (
    <main className="dashboard-shell">
      <PageHeader title="Configurações" subtitle="Preferências e alertas." workspaceName={workspace.name} />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      
      <nav className="hub-tabs" aria-label="Abas de configurações">
        {TABS.map(tab => (
          <button
            key={tab}
            type="button"
            aria-pressed={activeTab === tab}
            className={activeTab === tab ? "active" : ""}
            onClick={() => setActiveTab(tab)}
          >
            {tab}
          </button>
        ))}
      </nav>

      <section>
        <form className="dashboard-card" onSubmit={async (e) => { e.preventDefault(); await savePreferences(new FormData(e.currentTarget)); }}>
          <h2>{activeTab}</h2>

          {activeTab === "Alertas" && (
            <>
              <div style={{ display: "grid", gap: "8px" }}>
                <label className="account-row"><span>Alertas de orçamento</span><input type="checkbox" name="budget_alerts" defaultChecked={p?.budget_alerts ?? true} /></label>
                <label className="account-row"><span>Alertas de metas</span><input type="checkbox" name="goal_alerts" defaultChecked={p?.goal_alerts ?? true} /></label>
                <label className="account-row"><span>Alertas de compromissos fixos</span><input type="checkbox" name="fixed_commitment_alerts" defaultChecked={p?.fixed_commitment_alerts ?? true} /></label>
                <label className="account-row"><span>Alertas de cartão de crédito</span><input type="checkbox" name="credit_card_alerts" defaultChecked={p?.credit_card_alerts ?? true} /></label>
                <label className="account-row"><span>Alertas de saldo baixo</span><input type="checkbox" name="low_balance_alerts" defaultChecked={p?.low_balance_alerts ?? true} /></label>
                <label className="account-row"><span>Resumo semanal</span><input type="checkbox" name="weekly_digest" defaultChecked={p?.weekly_digest ?? true} /></label>
              </div>
              <div className="simple-form" style={{ marginTop: 16 }}>
                <details>
                  <summary>Configurações avançadas</summary>
                  <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", marginTop: 12 }}>
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
                <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
              </div>
            </>
          )}

          ﻿          {activeTab === "Família" && (
            <div className="simple-form">
              <h3>Membros da Família</h3>
              <p className="muted" style={{marginBottom: "1rem"}}>Pessoas que têm acesso a contas compartilhadas.</p>
              
              <ul style={{ listStyle: "none", padding: 0, margin: "0 0 2rem 0", display: "grid", gap: "1rem" }}>
                {(workspaceUsers || []).map(u => (
                  <li key={u.id} style={{ display: "flex", justifyContent: "space-between", padding: "1rem", border: "1px solid #eee", borderRadius: "8px" }}>
                    <span>{u.user_id}</span>
                    <span style={{ color: "#666", textTransform: "capitalize" }}>{u.role}</span>
                  </li>
                ))}
              </ul>

              <h3>Convites Pendentes</h3>
              <ul style={{ listStyle: "none", padding: 0, margin: "1rem 0", display: "grid", gap: "1rem" }}>
                {(workspaceInvites || []).map(i => (
                  <li key={i.id} style={{ padding: "1rem", border: "1px solid #eee", borderRadius: "8px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "0.5rem" }}>
                      <strong>Nível: {i.role}</strong>
                      <span>Expira em: {new Date(i.expires_at).toLocaleDateString()}</span>
                    </div>
                    <div style={{ display: "flex", gap: "0.5rem" }}>
                      <input type="text" readOnly value={`${window.location.origin}/convite?token=${i.token}`} className="input" style={{ flex: 1 }} />
                      <button type="button" onClick={() => navigator.clipboard.writeText(`${window.location.origin}/convite?token=${i.token}`)} className="primary-button" style={{ whiteSpace: "nowrap" }}>Copiar Link</button>
                    </div>
                  </li>
                ))}
                {(workspaceInvites || []).length === 0 && <p className="muted">Nenhum convite pendente.</p>}
              </ul>

              <h3 style={{ marginTop: "2rem" }}>Gerar Novo Convite</h3>
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", marginTop: "1rem" }}>
                <label>Permissão do convidado
                  <select name="invite_role" defaultValue="editor">
                    <option value="admin">Administrador (Total)</option>
                    <option value="editor">Editor (Lançamentos)</option>
                    <option value="viewer">Visualizador (Somente Leitura)</option>
                  </select>
                </label>
              </div>
              <button type="submit" name="action" value="create_invite" disabled={saving} style={{ marginTop: "1rem" }}>{saving ? "Gerando..." : "Gerar Link de Convite"}</button>
            </div>
          )}

          {activeTab === "Aparência" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
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
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Painel" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
                <label>Período Padrão
                  <select name="default_period" defaultValue={wp?.default_period ?? "current_month"}>
                    <option value="current_month">Mês atual</option>
                    <option value="last_month">Mês anterior</option>
                    <option value="current_year">Ano atual</option>
                    <option value="all_time">Todo o período</option>
                  </select>
                </label>
              </div>
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Contextos" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
                <label>Contexto Padrão
                  <select name="default_context_id" defaultValue={wp?.default_context_id ?? ""}>
                    <option value="">Nenhum (Visão Geral)</option>
                    {contexts.map((c: { id: string; name: string }) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </label>
              </div>
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Privacidade" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
                <label>Ocultar Valores por Padrão
                  <select name="hide_values" defaultValue={wp?.hide_values ? "true" : "false"}>
                    <option value="false">Desativado</option>
                    <option value="true">Ativado</option>
                  </select>
                </label>
              </div>
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Ganhos" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
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
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Gastos" && (
            <div className="simple-form">
              <div style={{ display: "grid", gap: "16px", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))" }}>
                <label>Categoria de gasto padrão
                  <select name="default_category_id" defaultValue={wp?.default_category_id ?? ""}>
                    <option value="">Sem padrão</option>
                    {categories.filter((c) => c.kind === "expense").map((c) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </label>
              </div>
              <button type="submit" disabled={saving}>{saving ? "Salvando..." : "Salvar preferências"}</button>
            </div>
          )}

          {activeTab === "Dados" && (
            <p className="muted">Exportar ou limpar seus dados. A exportação em CSV estará disponível em breve.</p>
          )}
        </form>

        <div className="dashboard-card" style={{ marginTop: 16 }}>
          <h2>Sessão</h2>
          <button type="button" onClick={signOut} style={{ minHeight: 48, border: 0, padding: "12px 24px", borderRadius: 12, background: "var(--danger)", color: "#fff", fontWeight: 600, cursor: "pointer" }}>Sair da conta</button>
        </div>
      </section>
    </main>
  );
}
