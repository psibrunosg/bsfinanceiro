"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney } from "./components/Money";
import { ACCOUNT_TYPE_LABEL } from "./components/types";
import { createClient } from "@/lib/supabase/client";
import { useMemo, useState } from "react";

export function AccountsPage() {
  const { workspace, accounts, cards, loading, message, setMessage, reload } =
    useFinance("accounts");
  const supabase = useMemo(() => createClient(), []);
  const [editingAccountId, setEditingAccountId] = useState<string | null>(null);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  async function submitAccount(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("accounts").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      name: form.get("name"),
      type: form.get("type"),
      initial_balance: parseMoney(form.get("initial_balance")),
    });
    setMessage(
      error ? "Não foi possível adicionar a conta." : "Conta adicionada."
    );
    await reload();
  }

  async function updateAccount(form: FormData) {
    if (!editingAccountId) return;
    const { error } = await supabase
      .from("accounts")
      .update({
        name: form.get("name"),
        type: form.get("type"),
        initial_balance: parseMoney(form.get("initial_balance")),
      })
      .eq("id", editingAccountId)
      .eq("workspace_id", workspace.id);
    setMessage(error ? "Não foi possível editar a conta." : "Conta atualizada.");
    if (!error) setEditingAccountId(null);
    await reload();
  }

  const editingAccount = accounts.find((a) => a.id === editingAccountId);
  const accountHasCard = !!editingAccount && cards.some((c) => c.account_id === editingAccount.id);

  return (
    <main className="management-page">
      <PageHeader
        title="Suas contas"
        subtitle="Organize onde seu dinheiro está."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      <section className="management-grid">
        <List title="Contas ativas">
          {accounts.map((a) => (
            <article className="account-row" key={a.id}>
              <span>🏦</span>
              <div>
                <strong>{a.name}</strong>
                <small>{ACCOUNT_TYPE_LABEL[a.type] ?? a.type}</small>
              </div>
              <b>{money(a.initial_balance)}</b>
              <button type="button" onClick={() => setEditingAccountId(a.id)}>
                Editar
              </button>
            </article>
          ))}
        </List>
        <aside className="form-card">
          <h2>{editingAccount ? "Editar conta" : "Adicionar conta"}</h2>
          <SimpleForm key={editingAccount?.id ?? "new"} onSubmit={editingAccount ? updateAccount : submitAccount}>
            <input name="name" placeholder="Nome da conta" defaultValue={editingAccount?.name} required />
            <select name="type" defaultValue={editingAccount?.type ?? "checking"} disabled={accountHasCard}>
              <option value="checking">Conta bancária</option>
              <option value="cash">Dinheiro</option>
              <option value="savings">Poupança</option>
              <option value="credit_card">Cartão</option>
              <option value="investment">Investimento</option>
            </select>
            <input name="initial_balance" defaultValue={editingAccount ? String(editingAccount.initial_balance).replace(".", ",") : "0,00"} required />
            <button>{editingAccount ? "Salvar alterações" : "Adicionar"}</button>
            {editingAccount && <button type="button" onClick={() => setEditingAccountId(null)}>Cancelar</button>}
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
