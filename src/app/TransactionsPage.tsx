"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { Dialog } from "./components/Dialog";
import { StatementImportPanel } from "./components/StatementImportPanel";
import { money, parseMoney } from "./components/Money";
import { createClient } from "@/lib/supabase/client";
import { todayInSaoPaulo } from "@/lib/finance/local-date";

function TransactionsPageInner() {
  const searchParams = useSearchParams();
  const presetType = searchParams.get("type") === "income" ? "income" : "expense";
  const supabase = useMemo(() => createClient(), []);
  const [query, setQuery] = useState("");
  const [type, setType] = useState("");
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [page, setPage] = useState(0);
  const [openDialog, setOpenDialog] = useState(false);
  const {
    workspace,
    ownerId,
    accounts,
    categories,
    transactions,
    transactionTotal,
    transactionPageSize,
    loading,
    message,
    setMessage,
    reload,
    transactionImportBatches,
  } = useFinance("transactions", undefined, {
    transactionFilters: { query, type, from, to },
    transactionPage: page,
  });

  if (loading || !workspace) return <main className="management-page"><p className="muted">Carregando...</p></main>;

  async function submitTransaction(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const type = String(form.get("type"));
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace.id, owner_id: userData.user?.id, type, amount: parseMoney(form.get("amount")), account_id: form.get("account_id"),
      category_id: type === "transfer" ? null : form.get("category_id"), destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
      description: form.get("description") || (type === "transfer" ? "Transferência" : "Movimentação"), competence_date: form.get("competence_date"), paid_at: form.get("competence_date"), status: "paid", idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível salvar." : "Movimentação adicionada.");
    await reload();
  }

  const messageIsError = message.startsWith("Não");
  const hasActiveFilters = Boolean(query.trim() || type || from || to);
  const pageSize = transactionPageSize || 25;
  const total = transactionTotal ?? transactions.length;
  const totalPages = Math.max(1, Math.ceil(total / pageSize));

  return <main className="management-page">
    <PageHeader 
      title="Movimentações" 
      subtitle="Registre entradas, saídas e transferências." 
      workspaceName={workspace.name} 
      action={{ label: "Nova movimentação", onClick: () => setOpenDialog(true) }} 
    />
    <Nav />
    {message && <p className={messageIsError ? "form-error" : "form-success"} role={messageIsError ? "alert" : "status"}>{message}</p>}
    <StatementImportPanel
      workspaceId={workspace.id}
      ownerId={ownerId}
      accounts={accounts}
      batches={transactionImportBatches}
      onReload={reload}
      onMessage={setMessage}
    />
    <section className="management-grid" style={{ gridTemplateColumns: '1fr' }}>
      <List title="Histórico">
        <form className="transaction-filters" onSubmit={(event) => event.preventDefault()}>
          <div className="transaction-filter transaction-filter-query">
            <label htmlFor="transaction-query">Buscar movimentações</label>
            <input
              id="transaction-query"
              type="search"
              value={query}
              onChange={(event) => {
                setQuery(event.target.value);
                setPage(0);
              }}
              placeholder="Descrição"
            />
          </div>
          <div className="transaction-filter">
            <label htmlFor="transaction-filter-type">Tipo</label>
            <select
              id="transaction-filter-type"
              value={type}
              onChange={(event) => {
                setType(event.target.value);
                setPage(0);
              }}
            >
              <option value="">Todos</option>
              <option value="expense">Despesa</option>
              <option value="income">Receita</option>
              <option value="transfer">Transferência</option>
            </select>
          </div>
          <div className="transaction-filter">
            <label htmlFor="transaction-from">Data inicial</label>
            <input
              id="transaction-from"
              type="date"
              value={from}
              onChange={(event) => {
                setFrom(event.target.value);
                setPage(0);
              }}
            />
          </div>
          <div className="transaction-filter">
            <label htmlFor="transaction-to">Data final</label>
            <input
              id="transaction-to"
              type="date"
              value={to}
              onChange={(event) => {
                setTo(event.target.value);
                setPage(0);
              }}
            />
          </div>
        </form>
        {transactions.map((transaction) => (
          <article className="account-row" key={transaction.id}>
            <span aria-hidden="true">{transaction.type === "income" ? "↑" : "↓"}</span>
            <div>
              <strong>{transaction.description}</strong>
              <small>{transaction.competence_date}</small>
            </div>
            <b>{money(transaction.amount)}</b>
          </article>
        ))}
        {transactions.length === 0 ? (
          <p className="empty-state" role="status">
            {hasActiveFilters
              ? "Nenhuma movimentação corresponde aos filtros."
              : "Nenhuma movimentação registrada."}
          </p>
        ) : null}
        {total > 0 ? (
          <nav className="transaction-pagination" aria-label="Paginação do histórico">
            <button
              type="button"
              disabled={page === 0}
              onClick={() => setPage((current) => Math.max(0, current - 1))}
            >
              Anterior
            </button>
            <span>
              Página {page + 1} de {totalPages}
            </span>
            <button
              type="button"
              disabled={page + 1 >= totalPages}
              onClick={() => setPage((current) => current + 1)}
            >
              Próxima
            </button>
          </nav>
        ) : null}
      </List>
      
      {openDialog && (
        <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Nova movimentação">
          <SimpleForm onSubmit={async (form) => {
            await submitTransaction(form);
            if (!messageIsError) setOpenDialog(false);
          }}>
            <label htmlFor="transaction-type">Tipo de movimentação</label>
            <select id="transaction-type" name="type" defaultValue={presetType}><option value="expense">Despesa</option><option value="income">Receita</option><option value="transfer">Transferência</option></select>
            <label htmlFor="transaction-amount">Valor</label>
            <input id="transaction-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="transaction-account">Conta</label>
            <select id="transaction-account" name="account_id" required><option value="">Conta</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
            <label htmlFor="transaction-category">Categoria</label>
            <select id="transaction-category" name="category_id"><option value="">Categoria</option>{categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}</select>
            <label htmlFor="transaction-destination">Conta de destino</label>
            <select id="transaction-destination" name="destination_account_id"><option value="">Destino se transferência</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
            <label htmlFor="transaction-description">Descrição</label>
            <input id="transaction-description" name="description" placeholder="Descrição" />
            <label htmlFor="transaction-date">Data</label>
            <input id="transaction-date" name="competence_date" type="date" defaultValue={todayInSaoPaulo()} required />
            <button>Salvar</button>
          </SimpleForm>
        </Dialog>
      )}
    </section>
  </main>;
}

export function TransactionsPage() {
  return <Suspense fallback={<main className="management-page"><p className="muted">Carregando...</p></main>}><TransactionsPageInner /></Suspense>;
}
