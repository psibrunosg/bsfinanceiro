"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney } from "./components/Money";
import { ACCOUNT_TYPE_LABEL, type Account } from "./components/types";
import { createClient } from "@/lib/supabase/client";
import { useMemo, useState } from "react";
import { Landmark, Wallet, Percent, Pencil, Trash2 } from "lucide-react";
import { Dialog } from "./components/Dialog";
import { useToast } from "./components/Toast";

/** O Postgres devolve 23503 quando a exclusão esbarra numa chave estrangeira
 *  (ex.: lançamentos apontando para a conta). */
function isForeignKeyViolation(error: { code?: string; message?: string }) {
  return error.code === "23503" || /foreign key|chave estrangeira/i.test(error.message ?? "");
}

export function AccountsPage() {
  const { workspace, accounts, loading, reload, cashPosition } =
    useFinance("accounts");
  const { toast } = useToast();
  const supabase = useMemo(() => createClient(), []);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingAccount, setEditingAccount] = useState<Account | null>(null);
  const [deletingAccount, setDeletingAccount] = useState<Account | null>(null);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const totalBalance = cashPosition.balanceCents / 100;

  function accountBalanceOf(account: Account) {
    return (
      (cashPosition.accountBalancesCents[account.id] ??
        Number(account.initial_balance) * 100) / 100
    );
  }

  function openNewAccount() {
    setEditingAccount(null);
    setOpenDialog(true);
  }

  function openEditAccount(account: Account) {
    setEditingAccount(account);
    setOpenDialog(true);
  }

  async function submitAccount(form: FormData) {
    const values = {
      name: form.get("name"),
      type: form.get("type"),
      initial_balance: parseMoney(form.get("initial_balance")),
    };

    if (editingAccount) {
      const { error } = await supabase
        .from("accounts")
        .update(values)
        .eq("id", editingAccount.id)
        .eq("workspace_id", workspace.id);
      if (error) {
        toast(`Não foi possível editar a conta: ${error.message}`, "error");
      } else {
        toast("Conta atualizada.");
        setEditingAccount(null);
        setOpenDialog(false);
      }
      await reload();
      return;
    }

    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("accounts").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      ...values,
    });
    if (error) {
      toast(`Não foi possível adicionar a conta: ${error.message}`, "error");
    } else {
      toast("Conta adicionada.");
      setOpenDialog(false);
    }
    await reload();
  }

  async function confirmDeleteAccount() {
    if (!deletingAccount) return;
    const { error } = await supabase
      .from("accounts")
      .delete()
      .eq("id", deletingAccount.id)
      .eq("workspace_id", workspace.id);
    if (error) {
      toast(
        isForeignKeyViolation(error)
          ? "Não foi possível excluir: esta conta tem lançamentos vinculados e não pode ser excluída. Remova ou mova os lançamentos primeiro."
          : `Não foi possível excluir a conta: ${error.message}`,
        "error"
      );
    } else {
      toast("Conta excluída.");
      setDeletingAccount(null);
    }
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
          onClick: openNewAccount,
        }}
      />

      <section className="hub-overview">
        <article className="metric-card metric-card--positive">
          <Wallet aria-hidden="true" />
          <strong>{money(totalBalance)}</strong>
          <span className="muted">Saldo total consolidado</span>
        </article>
      </section>

      <section className="management-grid" style={{ gridTemplateColumns: '1fr' }}>
        <List title="Contas ativas">
          {accounts.map((a) => {
            const accountBalance = accountBalanceOf(a);
            const participation = totalBalance > 0 && accountBalance > 0 ? (accountBalance / totalBalance) * 100 : 0;

            return (
              <article className="account-row" key={a.id}>
                <span><Landmark aria-hidden="true" /></span>
                <div>
                  <strong>{a.name}</strong>
                  <small>{ACCOUNT_TYPE_LABEL[a.type] ?? a.type}</small>
                </div>
                <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '4px' }}>
                  <b>{money(accountBalance)}</b>
                  <small style={{ display: 'flex', alignItems: 'center', gap: '4px' }} className="muted">
                    <Percent aria-hidden="true" size={14} /> {participation.toFixed(1)}% do total
                  </small>
                  <span className="row-actions">
                    <button type="button" aria-label="Editar conta" title="Editar conta" onClick={() => openEditAccount(a)}>
                      <Pencil aria-hidden="true" />
                    </button>
                    <button type="button" className="danger" aria-label="Excluir conta" title="Excluir conta" onClick={() => setDeletingAccount(a)}>
                      <Trash2 aria-hidden="true" />
                    </button>
                  </span>
                </div>
              </article>
            );
          })}
          {accounts.length === 0 && (
            <p className="dashboard-empty" style={{ margin: "2rem 0" }}>Nenhuma conta encontrada.</p>
          )}
        </List>
      </section>

      <Dialog
        open={openDialog}
        onClose={() => {
          setOpenDialog(false);
          setEditingAccount(null);
        }}
        title={editingAccount ? "Editar conta" : "Adicionar conta"}
      >
        <SimpleForm key={editingAccount?.id ?? "new"} onSubmit={submitAccount}>
          <label htmlFor="account-name">Nome da conta</label>
          <input
            id="account-name"
            name="name"
            minLength={2}
            maxLength={60}
            placeholder="Ex.: Nubank"
            defaultValue={editingAccount?.name ?? ""}
            required
            autoFocus
          />
          <label htmlFor="account-type">Tipo</label>
          <select id="account-type" name="type" defaultValue={editingAccount?.type ?? "checking"}>
            <option value="checking">Conta bancária</option>
            <option value="cash">Dinheiro</option>
            <option value="savings">Poupança</option>
            <option value="investment">Investimento</option>
          </select>
          <label htmlFor="account-initial-balance">Saldo inicial</label>
          <input
            id="account-initial-balance"
            name="initial_balance"
            inputMode="decimal"
            placeholder="0,00"
            defaultValue={
              editingAccount
                ? String(editingAccount.initial_balance).replace(".", ",")
                : "0,00"
            }
            required
          />
          <button>{editingAccount ? "Salvar alterações" : "Adicionar conta"}</button>
        </SimpleForm>
      </Dialog>

      <Dialog
        open={deletingAccount !== null}
        onClose={() => setDeletingAccount(null)}
        title="Excluir conta"
      >
        {deletingAccount && (
          <>
            <p>
              Excluir a conta <strong>{deletingAccount.name}</strong>, com saldo de{" "}
              <b>{money(accountBalanceOf(deletingAccount))}</b>? Esta ação não pode ser desfeita.
            </p>
            <SimpleForm onSubmit={confirmDeleteAccount}>
              <button>Excluir conta</button>
              <button type="button" onClick={() => setDeletingAccount(null)}>
                Cancelar
              </button>
            </SimpleForm>
          </>
        )}
      </Dialog>
    </main>
  );
}
