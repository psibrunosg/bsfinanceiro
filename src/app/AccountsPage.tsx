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
import { Landmark, Wallet, Percent } from "lucide-react";
import { Dialog } from "./components/Dialog";

export function AccountsPage() {
  const { workspace, accounts, transactions, loading, message, setMessage, reload } =
    useFinance("accounts");
  const supabase = useMemo(() => createClient(), []);
  const [openDialog, setOpenDialog] = useState(false);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  // Saldo atual conta só o que já foi liquidado — igual ao "disponível" do
  // painel. Transações "planned" (futuras) não afetam o saldo de hoje.
  const settledTransactions = transactions.filter((t) => t.status === "paid");

  const totalBalance = accounts.reduce((sum, a) => sum + Number(a.initial_balance), 0) +
    settledTransactions.reduce((sum, t) => sum + (t.type === 'income' ? Number(t.amount) : -Number(t.amount)), 0);

  const balances = accounts.map((a) => ({
    account: a,
    balance: Number(a.initial_balance) + settledTransactions
      .filter((t) => t.account_id === a.id)
      .reduce((sum, t) => sum + (t.type === 'income' ? Number(t.amount) : -Number(t.amount)), 0),
  }));
  // Participação é sobre o patrimônio positivo: usar o consolidado zerava tudo
  // quando o saldo total ficava negativo.
  const positiveTotal = balances.reduce((sum, b) => sum + Math.max(0, b.balance), 0);

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
    if (!error) setOpenDialog(false);
    await reload();
  }

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Contas"
        subtitle="Saldos, evolução e distribuição do patrimônio."
        workspaceName={workspace.name}
        action={{
          label: "Adicionar conta",
          onClick: () => setOpenDialog(true),
        }}
      />
      {message && <p className="form-success">{message}</p>}
      
      <section className="hub-overview">
        <article className="metric-card metric-card--positive">
          <Wallet aria-hidden="true" />
          <strong>{money(totalBalance)}</strong>
          <span className="muted">Saldo total consolidado</span>
        </article>
      </section>

      <section className="management-grid" style={{ gridTemplateColumns: '1fr' }}>
        <List title="Contas ativas">
          {balances.map(({ account: a, balance: accountBalance }) => (
            <article className="account-row" key={a.id}>
              <span><Landmark aria-hidden="true" /></span>
              <div>
                <strong>{a.name}</strong>
                <small>{ACCOUNT_TYPE_LABEL[a.type] ?? a.type}</small>
              </div>
              <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '4px' }}>
                <b>{money(accountBalance)}</b>
                <small style={{ display: 'flex', alignItems: 'center', gap: '4px' }} className="muted">
                  {accountBalance < 0 ? (
                    <>saldo negativo de {money(Math.abs(accountBalance))}</>
                  ) : (
                    <>
                      <Percent aria-hidden="true" size={14} />{" "}
                      {(positiveTotal > 0 ? (accountBalance / positiveTotal) * 100 : 0).toFixed(1)}% do total
                    </>
                  )}
                </small>
              </div>
            </article>
          ))}
          {accounts.length === 0 && (
            <p className="dashboard-empty" style={{ margin: "2rem 0" }}>Nenhuma conta encontrada.</p>
          )}
        </List>
      </section>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Adicionar conta">
        <SimpleForm onSubmit={submitAccount}>
          <label htmlFor="account-name">Nome da conta</label>
          <input id="account-name" name="name" placeholder="Nome da conta" required autoFocus />
          <label htmlFor="account-type">Tipo</label>
          <select id="account-type" name="type" defaultValue="checking">
            <option value="checking">Conta bancária</option>
            <option value="cash">Dinheiro</option>
            <option value="savings">Poupança</option>
            <option value="investment">Investimento</option>
          </select>
          <label htmlFor="account-initial-balance">Saldo inicial</label>
          <input id="account-initial-balance" name="initial_balance" placeholder="0,00" defaultValue="0,00" required />
          <button>Adicionar conta</button>
        </SimpleForm>
      </Dialog>
    </main>
  );
}
