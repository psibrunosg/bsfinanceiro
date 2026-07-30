"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney } from "./components/Money";
import { ACCOUNT_TYPE_LABEL } from "./components/types";
import { createClient } from "@/lib/supabase/client";
import { useMemo } from "react";
import { Landmark } from "lucide-react";

export function AccountsPage() {
  const { workspace, accounts, loading, message, setMessage, reload } =
    useFinance("accounts");
  const supabase = useMemo(() => createClient(), []);

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
              <span><Landmark aria-hidden="true" /></span>
              <div>
                <strong>{a.name}</strong>
                <small>{ACCOUNT_TYPE_LABEL[a.type] ?? a.type}</small>
              </div>
              <b>{money(a.initial_balance)}</b>
            </article>
          ))}
        </List>
        <aside className="form-card">
          <h2>Adicionar conta</h2>
          <SimpleForm onSubmit={submitAccount}>
            <input name="name" placeholder="Nome da conta" required />
            <select name="type" defaultValue="checking">
              <option value="checking">Conta bancária</option>
              <option value="cash">Dinheiro</option>
              <option value="savings">Poupança</option>
              <option value="credit_card">Cartão</option>
              <option value="investment">Investimento</option>
            </select>
            <input name="initial_balance" defaultValue="0,00" required />
            <button>Adicionar</button>
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
