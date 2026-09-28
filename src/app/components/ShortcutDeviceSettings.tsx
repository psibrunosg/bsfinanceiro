"use client";

import { useCallback, useEffect, useState } from "react";
import { Check, Copy, Smartphone, Trash2 } from "lucide-react";
import type { Account, Category } from "./types";

type Device = {
  id: string;
  name: string;
  token_hint?: string | null;
  default_account_id?: string | null;
  active: boolean;
  last_used_at?: string | null;
  created_at: string;
};

type Props = {
  workspaceId: string;
  accounts: Account[];
  categories: Category[];
  defaultCashAccountId?: string | null;
};

const ENDPOINT = "https://financeiro.bssaude.com.br/api/shortcuts";

function sessionToken() {
  return typeof window === "undefined" ? "" : localStorage.getItem("bsfinanceiro_token") || "";
}
export function ShortcutDeviceSettings({ workspaceId, accounts, categories, defaultCashAccountId }: Props) {
  const [devices, setDevices] = useState<Device[]>([]);
  const [name, setName] = useState("iPhone do Bruno");
  const [accountId, setAccountId] = useState(defaultCashAccountId || accounts.find((a) => a.type !== "credit_card")?.id || "");
  const [categoryId, setCategoryId] = useState("");
  const [newToken, setNewToken] = useState("");
  const [message, setMessage] = useState("");
  const [busy, setBusy] = useState(false);
  const [copied, setCopied] = useState("");

  const api = useCallback(async (path: string, init?: RequestInit) => {
    const token = sessionToken();
    if (!token) throw new Error("Entre novamente para administrar dispositivos.");
    return fetch(path, {
      ...init,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        ...(init?.headers || {}),
      },
    });
  }, []);

  const load = useCallback(async () => {
    try {
      const res = await api("/api/shortcut-devices");
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Não foi possível carregar os dispositivos.");
      setDevices(data.devices || []);
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Não foi possível carregar os dispositivos.");
    }
  }, [api]);

  useEffect(() => { void load(); }, [load]);
  async function createDevice() {
    if (!accountId) {
      setMessage("Selecione uma conta padrão para os registros rápidos.");
      return;
    }
    setBusy(true);
    setMessage("");
    setNewToken("");
    try {
      const res = await api("/api/shortcut-devices", {
        method: "POST",
        body: JSON.stringify({
          name,
          workspace_id: workspaceId,
          default_account_id: accountId,
          default_category_id: categoryId || null,
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Não foi possível criar o dispositivo.");
      setNewToken(data.token);
      setMessage("Dispositivo criado. Copie o token agora: ele não será mostrado novamente.");
      await load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Não foi possível criar o dispositivo.");
    } finally {
      setBusy(false);
    }
  }

  async function revokeDevice(id: string) {
    setBusy(true);
    try {
      const res = await api(`/api/shortcut-devices?id=${encodeURIComponent(id)}`, { method: "DELETE" });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Não foi possível revogar o dispositivo.");
      await load();
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Não foi possível revogar o dispositivo.");
    } finally {
      setBusy(false);
    }
  }

  async function copy(value: string, key: string) {
    await navigator.clipboard.writeText(value);
    setCopied(key);
    setTimeout(() => setCopied(""), 1800);
  }
  return (
    <div style={{ display: "grid", gap: 18 }}>
      <div className="dashboard-card">
        <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
          <Smartphone size={22} />
          <div>
            <strong>Registro rápido no iPhone</strong>
            <p className="muted" style={{ margin: "4px 0 0" }}>
              Cada iPhone recebe um token próprio, ligado ao seu workspace e à conta padrão escolhida.
            </p>
          </div>
        </div>
      </div>

      <div className="simple-form">
        <label>Nome do dispositivo
          <input value={name} onChange={(e) => setName(e.target.value)} />
        </label>
        <label>Conta padrão
          <select value={accountId} onChange={(e) => setAccountId(e.target.value)}>
            <option value="">Selecione</option>
            {accounts.filter((a) => a.type !== "credit_card").map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}
          </select>
        </label>
        <label>Categoria padrão (opcional)
          <select value={categoryId} onChange={(e) => setCategoryId(e.target.value)}>
            <option value="">Sugerir automaticamente</option>
            {categories.filter((c) => c.kind === "expense").map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </label>
        <button type="button" onClick={() => void createDevice()} disabled={busy}>Criar token do iPhone</button>
      </div>
      {newToken ? (
        <div className="dashboard-card">
          <strong>Token do dispositivo — copie agora</strong>
          <code style={{ display: "block", margin: "10px 0", overflowWrap: "anywhere" }}>{newToken}</code>
          <button type="button" onClick={() => void copy(newToken, "token")}>
            {copied === "token" ? <Check size={16} /> : <Copy size={16} />} {copied === "token" ? "Copiado" : "Copiar token"}
          </button>
        </div>
      ) : null}

      <div className="dashboard-card">
        <strong>Configuração do Atalho</strong>
        <p className="muted">Use “Obter Conteúdo de URL” com método POST.</p>
        <code style={{ display: "block", overflowWrap: "anywhere" }}>{ENDPOINT}</code>
        <p>Header: <code>Authorization: Bearer SEU_TOKEN_DO_IPHONE</code></p>
        <p>JSON: <code>{'{"amount":"Valor","description":"Descrição","installments":1,"type":"expense"}'}</code></p>
      </div>

      <div className="dashboard-card">
        <strong>Dispositivos autorizados</strong>
        {devices.length === 0 ? <p className="muted">Nenhum dispositivo criado.</p> : devices.map((device) => (
          <div key={device.id} style={{ display: "flex", justifyContent: "space-between", gap: 12, padding: "10px 0", borderBottom: "1px solid var(--border)" }}>
            <span>{device.name} · final {device.token_hint || "—"}{device.last_used_at ? " · usado recentemente" : ""}</span>
            <button type="button" onClick={() => void revokeDevice(device.id)} disabled={busy} aria-label={`Revogar ${device.name}`}><Trash2 size={16} /></button>
          </div>
        ))}
      </div>
      {message ? <p role="status">{message}</p> : null}
    </div>
  );
}
