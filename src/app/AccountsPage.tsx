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
import { Landmark, Wallet, Percent, CreditCard, ChevronRight } from "lucide-react";
import { Dialog } from "./components/Dialog";
import { EmergencyFundWidget } from "./components/EmergencyFundWidget";
import Link from "next/link";

export function AccountsPage() {
  const {
    ownerId,
    workspace,
    accounts,
    cards = [],
    invoices = [],
    transactions,
    loading,
    message,
    setMessage,
    reload,
  } = useFinance("accounts");
  const supabase = useMemo(() => createClient(), []);
  const [openDialog, setOpenDialog] = useState(false);

  // Saldo atual conta só o que já foi liquidado — igual ao "disponível" do painel.
  const settledTransactions = useMemo(
    () => transactions.filter((t) => t.status === "paid"),
    [transactions]
  );

  // 1. Contas bancárias e dinheiro líquido (checking, cash, savings, investment)
  const bankAccounts = useMemo(
    () => accounts.filter((a) => a.type !== "credit_card"),
    [accounts]
  );

  // 2. Contas de cartões de crédito
  const cardAccounts = useMemo(
    () => accounts.filter((a) => a.type === "credit_card"),
    [accounts]
  );

  // Saldos reais das contas bancárias
  const bankBalances = useMemo(() => {
    return bankAccounts.map((a) => {
      const initial = Number(a.initial_balance || 0);
      const income = settledTransactions
        .filter((t) => t.account_id === a.id && t.type === "income")
        .reduce((sum, t) => sum + Number(t.amount), 0);
      const expense = settledTransactions
        .filter((t) => t.account_id === a.id && t.type === "expense")
        .reduce((sum, t) => sum + Number(t.amount), 0);
      const transferOut = settledTransactions
        .filter((t) => t.account_id === a.id && t.type === "transfer")
        .reduce((sum, t) => sum + Number(t.amount), 0);
      const transferIn = settledTransactions
        .filter((t) => t.destination_account_id === a.id && t.type === "transfer")
        .reduce((sum, t) => sum + Number(t.amount), 0);

      const balance = initial + income - expense - transferOut + transferIn;
      return {
        account: a,
        balance,
      };
    });
  }, [bankAccounts, settledTransactions]);

  const totalBankBalance = useMemo(
    () => bankBalances.reduce((sum, b) => sum + b.balance, 0),
    [bankBalances]
  );

  // Saldos e débitos atuais dos cartões de crédito.
  // Faturas anteriores já pagas (status 'paid') NÃO constituem dívida aberta.
  const cardBalances = useMemo(() => {
    return cardAccounts.map((a) => {
      const card = cards.find(
        (c) => c.account_id === a.id || c.name.toLowerCase() === a.name.toLowerCase()
      );
      const cardInvoices = invoices.filter(
        (inv) => inv.account_id === a.id || (card && inv.credit_card_id === card.id)
      );
      const openInvoices = cardInvoices.filter((inv) => inv.status !== "paid");
      const openInvoicesDebt = openInvoices.reduce((sum, inv) => {
        const installmentsSum = (inv.credit_card_installments || []).reduce(
          (s, i) => s + Number(i.amount),
          0
        );
        return sum + (installmentsSum > 0 ? installmentsSum : Number(inv.total_amount || 0));
      }, 0);

      // Despesas neste cartão não vinculadas a fatura
      const unbilledDebt = settledTransactions
        .filter((t) => t.account_id === a.id && t.type === "expense" && !t.invoice_id)
        .reduce((sum, t) => sum + Number(t.amount), 0);

      const currentDebt = openInvoicesDebt + unbilledDebt;
      const creditLimit = card ? Number(card.credit_limit || 0) : 0;
      const availableLimit = Math.max(0, creditLimit - currentDebt);

      return {
        account: a,
        card,
        debt: currentDebt,
        balance: currentDebt > 0 ? -currentDebt : 0,
        creditLimit,
        availableLimit,
        openInvoicesCount: openInvoices.length,
      };
    });
  }, [cardAccounts, cards, invoices, settledTransactions]);

  const totalCardDebt = useMemo(
    () => cardBalances.reduce((sum, c) => sum + c.debt, 0),
    [cardBalances]
  );

  // Saldo total consolidado = Saldo bancário líquido - Faturas abertas de cartões
  const totalBalance = totalBankBalance - totalCardDebt;

  // Participação sobre patrimônio bancário positivo
  const positiveBankTotal = bankBalances.reduce((sum, b) => sum + Math.max(0, b.balance), 0);

  async function submitAccount(form: FormData) {
    const name = form.get("name") as string;
    const type = form.get("type") as string;
    const initial_balance = parseMoney(form.get("initial_balance"));
    const is_shared = form.get("is_shared") === "on";

    try {
      // 1. Tenta salvar na API local da VPS
      try {
        const res = await fetch("/api/accounts", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            workspace_id: workspace.id,
            owner_id: ownerId,
            name,
            type,
            initial_balance,
            is_shared,
          }),
        });
        const data = await res.json().catch(() => ({}));
        if (res.ok && data.success) {
          setMessage("Conta adicionada.");
          setOpenDialog(false);
          await reload();
          return;
        }
      } catch {}

      const { data: userData } = await supabase.auth.getUser();
      const owner_id = userData?.user?.id ?? ownerId;
      if (!owner_id) throw new Error("Usuário não autenticado");

      let { error } = await supabase.from("accounts").insert({
        workspace_id: workspace.id,
        owner_id,
        name,
        type,
        initial_balance,
        is_shared,
      });

      if (error && (error.message?.includes("is_shared") || error.code === "PGRST204" || error.code === "42703")) {
        const fallback = await supabase.from("accounts").insert({
          workspace_id: workspace.id,
          owner_id,
          name,
          type,
          initial_balance,
        });
        error = fallback.error;
      }

      if (error) {
        setMessage(`Não foi possível adicionar a conta: ${error.message}`);
      } else {
        setMessage("Conta adicionada.");
        setOpenDialog(false);
        reload();
      }
    } catch (err: unknown) {
      setMessage("Erro ao adicionar conta: " + (err as Error).message);
    }
  }

  if (loading || !workspace)
    return (
      <main className="dashboard-shell">
        <p className="muted">Carregando...</p>
      </main>
    );

  return (
    <main className="dashboard-shell">
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
      
      <div className="bento-row bento-row--3">
        <article className="metric-card metric-card--positive">
          <div className="metric-card__head">
            <span className="muted">Saldo total consolidado</span>
            <span className="metric-icon-badge" style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6" }}>
              <Wallet size={18} aria-hidden="true" />
            </span>
          </div>
          <strong>{money(totalBalance)}</strong>
          <small className="muted" style={{ display: "block", marginTop: 4 }}>
            Patrimônio líquido disponível
          </small>
        </article>

        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Saldo em bancos</span>
            <span className="metric-icon-badge" style={{ background: "rgba(34,197,94,.15)", color: "#22C55E" }}>
              <Landmark size={18} aria-hidden="true" />
            </span>
          </div>
          <strong>{money(totalBankBalance)}</strong>
          <small className="muted" style={{ display: "block", marginTop: 4 }}>
            Total disponível em contas bancárias
          </small>
        </article>

        <article className="metric-card">
          <div className="metric-card__head">
            <span className="muted">Faturas de cartões</span>
            <span
              className="metric-icon-badge"
              style={{
                background: totalCardDebt > 0 ? "rgba(239,68,68,.15)" : "rgba(34,197,94,.15)",
                color: totalCardDebt > 0 ? "#EF4444" : "#22C55E",
              }}
            >
              <CreditCard size={18} aria-hidden="true" />
            </span>
          </div>
          <strong style={{ color: totalCardDebt > 0 ? "var(--danger, #ef4444)" : "inherit" }}>
            {totalCardDebt > 0 ? money(-totalCardDebt) : "R$ 0,00"}
          </strong>
          <small className="muted" style={{ display: "block", marginTop: 4 }}>
            {totalCardDebt > 0
              ? `${cardBalances.filter((c) => c.debt > 0).length} fatura(s) em aberto`
              : "Todas as faturas pagas"}
          </small>
        </article>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        <List title="Contas bancárias e carteiras">
          {bankBalances.map(({ account: a, balance: accountBalance }) => (
            <article className="account-row" key={a.id}>
              <span
                className="metric-icon-badge"
                style={{ background: "rgba(139,92,246,.15)", color: "#8B5CF6", marginLeft: 0 }}
              >
                <Landmark size={18} aria-hidden="true" />
              </span>
              <div className="tx-row__body">
                <strong>{a.name}</strong>
                <small>{ACCOUNT_TYPE_LABEL[a.type] ?? a.type}</small>
              </div>
              <div style={{ textAlign: "right" }}>
                <b>{money(accountBalance)}</b>
                <small className="muted" style={{ display: "block" }}>
                  {accountBalance < 0 ? (
                    <span style={{ color: "var(--danger, #ef4444)" }}>
                      saldo negativo de {money(Math.abs(accountBalance))}
                    </span>
                  ) : (
                    <>
                      <Percent aria-hidden="true" size={14} style={{ verticalAlign: "-2px" }} />{" "}
                      {(positiveBankTotal > 0 ? (accountBalance / positiveBankTotal) * 100 : 0).toFixed(1)}% do total
                    </>
                  )}
                </small>
              </div>
            </article>
          ))}
          {bankBalances.length === 0 && (
            <p className="dashboard-empty">Nenhuma conta bancária encontrada.</p>
          )}
        </List>

        {cardBalances.length > 0 && (
          <List title="Cartões de crédito">
            {cardBalances.map(({ account: a, card, debt, creditLimit, availableLimit }) => {
              const cardSubtitle = card
                ? `${card.brand ? card.brand.toUpperCase() : "Cartão"}${card.last_four ? ` •••• ${card.last_four}` : ""} · Limite: ${money(creditLimit)}`
                : (ACCOUNT_TYPE_LABEL[a.type] ?? a.type);

              const cardContent = (
                <article
                  className="account-row"
                  key={a.id}
                  style={{ cursor: card ? "pointer" : "default" }}
                >
                  <span
                    className="metric-icon-badge"
                    style={{
                      background: debt > 0 ? "rgba(239,68,68,.15)" : "rgba(34,197,94,.15)",
                      color: debt > 0 ? "#EF4444" : "#22C55E",
                      marginLeft: 0,
                    }}
                  >
                    <CreditCard size={18} aria-hidden="true" />
                  </span>
                  <div className="tx-row__body">
                    <strong>{a.name}</strong>
                    <small>{cardSubtitle}</small>
                  </div>
                  <div style={{ textAlign: "right" }}>
                    <b style={{ color: debt > 0 ? "var(--danger, #ef4444)" : "inherit" }}>
                      {debt > 0 ? money(-debt) : "R$ 0,00"}
                    </b>
                    <small
                      style={{
                        display: "block",
                        color: debt > 0 ? "var(--danger, #ef4444)" : "var(--success, #22c55e)",
                      }}
                    >
                      {debt > 0 ? (
                        <>Fatura aberta · Disp: {money(availableLimit)}</>
                      ) : (
                        <>Fatura paga · Limite livre</>
                      )}
                    </small>
                  </div>
                  {card && (
                    <ChevronRight size={16} className="muted" aria-hidden="true" style={{ marginLeft: 8 }} />
                  )}
                </article>
              );

              return card ? (
                <Link
                  key={a.id}
                  href={`/cartoes?cardId=${card.id}`}
                  style={{ textDecoration: "none", color: "inherit", display: "block" }}
                  title="Ver faturas do cartão"
                >
                  {cardContent}
                </Link>
              ) : (
                cardContent
              );
            })}
          </List>
        )}
      </div>

      <div style={{ marginTop: "24px" }}>
        <EmergencyFundWidget monthlyFixedExpenses={5000} initialFundBalance={Math.max(0, totalBalance)} />
      </div>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Adicionar conta">
        <SimpleForm onSubmit={submitAccount}>
          <label htmlFor="account-name">Nome da conta</label>
          <input id="account-name" name="name" placeholder="Nome da conta" autoComplete="off" data-lpignore="true" required autoFocus />
          <label htmlFor="account-type">Tipo</label>
          <select id="account-type" name="type" defaultValue="checking">
            <option value="checking">Conta bancária</option>
            <option value="cash">Dinheiro</option>
            <option value="savings">Poupança</option>
            <option value="investment">Investimento</option>
          </select>
          <label htmlFor="account-initial-balance">Saldo inicial</label>
          <input id="account-initial-balance" name="initial_balance" placeholder="0,00" defaultValue="0,00" autoComplete="off" data-lpignore="true" required />
          
          <label className="account-row" style={{ marginTop: "1rem", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <span>Conta Compartilhada (visível para família)</span>
            <input type="checkbox" name="is_shared" defaultChecked />
          </label>

          <button style={{ marginTop: "1rem" }}>Adicionar conta</button>
        </SimpleForm>
      </Dialog>
    </main>
  );
}
