"use client";

import { useState } from "react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { List } from "./components/List";
import { money } from "./components/Money";
import { BrandLogo } from "./brand-logo";
import { TodayPanel } from "./components/TodayPanel";
import { SpendingPowerCard } from "./components/SpendingPowerCard";
import { QuickTransactionForm } from "./components/QuickTransactionForm";
import { buildTodayDashboard } from "../lib/finance/today-adapter";
import { todayInSaoPaulo } from "../lib/finance/local-date";
import { todayActions } from "../lib/finance/today-actions";
import { appPath } from "../lib/app-path";

export function DashboardPage() {
  const [quickTransactionStatus, setQuickTransactionStatus] = useState("");
  const {
    ownerId,
    workspace,
    accounts,
    categories,
    cards,
    transactions,
    todayTransactions,
    alertPrefs,
    goals,
    cashPosition,
    spendingPower,
    defaultCashAccountId,
    loading,
    reload,
  } = useFinance("dashboard");

  if (loading || !workspace || !ownerId)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const totalCards = cards.reduce(
    (sum, c) => sum + Number(c.credit_limit),
    0
  );
  const today = buildTodayDashboard(
    cashPosition.balanceCents,
    todayTransactions,
    alertPrefs,
    todayInSaoPaulo(),
  );
  const actions = todayActions(goals).map((action) => ({ ...action, href: appPath(action.href) }));

  async function reloadAfterQuickTransaction() {
    setQuickTransactionStatus("Movimentação registrada.");
    await reload();
  }

  return (
    <main className="dashboard-shell">
      <section className="hero-card">
        <div className="hero-brand">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            className="brand-logo"
            src="https://raw.githubusercontent.com/psibrunosg/bsfinanceiro/refs/heads/main/public/logo-bsfinanceiro.png"
            alt="BS Financeiro"
            width={52}
            height={52}
          />
          <div>
            <p className="eyebrow">BS Financeiro</p>
            <h1>Seu painel financeiro</h1>
          </div>
        </div>
        <Nav />
      </section>
      <section className="summary-grid">
        <article>
          <span>Saldo atual</span>
          <strong>{money(cashPosition.balanceCents / 100)}</strong>
        </article>
        <article>
          <span>Cartões</span>
          <strong>{cards.length}</strong>
        </article>
        <article>
          <span>Limite total</span>
          <strong>{money(totalCards)}</strong>
        </article>
      </section>
      <SpendingPowerCard spendingPower={spendingPower} />
      {quickTransactionStatus ? (
        <p className="form-success" role="status">
          {quickTransactionStatus}
        </p>
      ) : null}
      <QuickTransactionForm
        workspaceId={workspace.id}
        ownerId={ownerId}
        defaultCashAccountId={defaultCashAccountId}
        accounts={accounts}
        categories={categories}
        onSubmitStart={() => setQuickTransactionStatus("")}
        onSaved={reloadAfterQuickTransaction}
      />
      <TodayPanel today={today} actions={actions} />
      <section className="management-grid">
        <List title="Cartões">
          {cards.map((c) => (
            <article className="account-row" key={c.id}>
              <span className="brand-badge">
                <BrandLogo brand={c.brand} />
              </span>
              <div>
                <strong>{c.name}</strong>
                <small>Vence dia {c.due_day}</small>
              </div>
              <b>{money(c.credit_limit)}</b>
            </article>
          ))}
        </List>
        <List title="Movimentações recentes">
          {transactions.slice(0, 8).map((t) => (
            <article className="account-row" key={t.id}>
              <span>{t.type === "income" ? "↑" : "↓"}</span>
              <div>
                <strong>{t.description}</strong>
                <small>{t.competence_date}</small>
              </div>
              <b>{money(t.amount)}</b>
            </article>
          ))}
        </List>
      </section>
    </main>
  );
}
