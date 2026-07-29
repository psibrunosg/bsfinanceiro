"use client";

import { useEffect, useMemo, useState, type FormEvent } from "react";
import { createClient } from "@/lib/supabase/client";
import type { Account } from "./types";

const CASH_ACCOUNT_TYPES = new Set(["checking", "cash", "savings"]);

type DefaultCashAccountFormProps = {
  workspaceId: string;
  ownerId: string;
  defaultCashAccountId: string | null;
  accounts: Account[];
  onSaved: () => Promise<void>;
};

export function DefaultCashAccountForm({
  workspaceId,
  ownerId,
  defaultCashAccountId,
  accounts,
  onSaved,
}: DefaultCashAccountFormProps) {
  const supabase = useMemo(() => createClient(), []);
  const cashAccounts = accounts.filter((account) =>
    CASH_ACCOUNT_TYPES.has(account.type),
  );
  const [selectedAccountId, setSelectedAccountId] = useState(
    defaultCashAccountId ?? "",
  );
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const [status, setStatus] = useState("");

  useEffect(() => {
    setSelectedAccountId(defaultCashAccountId ?? "");
  }, [defaultCashAccountId]);

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setStatus("");

    if (!cashAccounts.some((account) => account.id === selectedAccountId)) {
      setError("Escolha uma conta de caixa ativa.");
      return;
    }

    setPending(true);
    try {
      const { error: upsertError } = await supabase
        .from("workspace_preferences")
        .upsert(
          {
            workspace_id: workspaceId,
            owner_id: ownerId,
            default_cash_account_id: selectedAccountId,
          },
          { onConflict: "workspace_id,owner_id" },
        );
      if (upsertError) {
        setError("Não foi possível definir a conta principal.");
        return;
      }

      try {
        await onSaved();
        setStatus("Conta principal atualizada.");
      } catch {
        setStatus(
          "Conta principal atualizada, mas o painel não pôde ser recarregado.",
        );
      }
    } catch {
      setError("Não foi possível definir a conta principal.");
    } finally {
      setPending(false);
    }
  }

  const form = (
    <form className="default-account-form" onSubmit={submit}>
      <label htmlFor="default-cash-account">
        Conta principal
        <select
          id="default-cash-account"
          value={selectedAccountId}
          onChange={(event) => setSelectedAccountId(event.currentTarget.value)}
          aria-invalid={error ? "true" : undefined}
          required
        >
          <option value="">Escolha uma conta</option>
          {cashAccounts.map((account) => (
            <option key={account.id} value={account.id}>
              {account.name}
            </option>
          ))}
        </select>
      </label>
      <button type="submit" disabled={pending || cashAccounts.length === 0}>
        {pending ? "Salvando..." : "Salvar conta principal"}
      </button>
      {cashAccounts.length === 0 ? (
        <p className="muted">Crie uma conta corrente, dinheiro ou poupança ativa.</p>
      ) : null}
    </form>
  );

  return (
    <section
      className="default-account-card"
      id="definir-conta-principal"
      aria-labelledby="default-account-title"
    >
      {defaultCashAccountId ? (
        <details>
          <summary id="default-account-title">Alterar conta principal</summary>
          {form}
        </details>
      ) : (
        <>
          <div>
            <p className="eyebrow">Configuração rápida</p>
            <h2 id="default-account-title">Defina sua conta principal</h2>
            <p>Ela será usada automaticamente nos próximos registros rápidos.</p>
          </div>
          {form}
        </>
      )}
      {error ? <p className="form-error" role="alert">{error}</p> : null}
      {status ? <p className="form-success" role="status">{status}</p> : null}
    </section>
  );
}
