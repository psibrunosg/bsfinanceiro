"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { ArrowDownRight, ArrowUpRight } from "lucide-react";
import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { Dialog } from "./components/Dialog";
import { StatementImportPanel } from "./components/StatementImportPanel";
import { BankNotificationAssistantWidget } from "./components/BankNotificationAssistantWidget";
import { money, parseMoney } from "./components/Money";
import { createClient } from "@/lib/supabase/client";
import { todayInSaoPaulo } from "@/lib/finance/local-date";
import { predictCategory } from "@/lib/finance/category-predictor";

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
    categoryRules,
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

  if (loading || !workspace) return <main className="dashboard-shell"><p className="muted">Carregando...</p></main>;

  async function submitTransaction(form: FormData) {
    const type = String(form.get("type"));
    const amount = parseMoney(form.get("amount"));
    const account_id = form.get("account_id");
    const category_id = type === "transfer" ? null : form.get("category_id");
    const description = form.get("description") || (type === "transfer" ? "Transferência" : "Movimentação");
    const competence_date = form.get("competence_date");

    try {
      const res = await fetch("/api/transactions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspace.id,
          type,
          amount,
          account_id,
          category_id,
          description,
          competence_date,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setMessage("Movimentação adicionada.");
      } else {
        const { data: userData } = await supabase.auth.getUser();
        const { error } = await supabase.from("transactions").insert({
          workspace_id: workspace.id, owner_id: userData?.user?.id, type, amount, account_id,
          category_id, destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
          description, competence_date, paid_at: competence_date, status: "paid", idempotency_key: crypto.randomUUID(),
        });
        setMessage(error ? "Não foi possível salvar." : "Movimentação adicionada.");
      }
    } catch {
      const { data: userData } = await supabase.auth.getUser();
      const { error } = await supabase.from("transactions").insert({
        workspace_id: workspace.id, owner_id: userData?.user?.id, type, amount, account_id,
        category_id, destination_account_id: type === "transfer" ? form.get("destination_account_id") : null,
        description, competence_date, paid_at: competence_date, status: "paid", idempotency_key: crypto.randomUUID(),
      });
      setMessage(error ? "Não foi possível salvar." : "Movimentação adicionada.");
    }
    await reload();
  }

  const messageIsError = message.startsWith("Não");
  const hasActiveFilters = Boolean(query.trim() || type || from || to);
  const pageSize = transactionPageSize || 25;
  const total = transactionTotal ?? transactions.length;
  const totalPages = Math.max(1, Math.ceil(total / pageSize));

  return <main className="dashboard-shell">
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
      categories={categories}
      categoryRules={categoryRules}
      historyTransactions={transactions}
      batches={transactionImportBatches}
      onReload={reload}
      onMessage={setMessage}
    />
    <form className="bento-row" style={{ gridTemplateColumns: '2fr 1fr 1fr 1fr', marginTop: '24px' }} onSubmit={(event) => event.preventDefault()}>
      <div className="filter-card">
        <span><label htmlFor="transaction-query">Buscar movimentações</label></span>
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
      <div className="filter-card">
        <span><label htmlFor="transaction-filter-type">Tipo</label></span>
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
      <div className="filter-card">
        <span><label htmlFor="transaction-from">Data inicial</label></span>
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
      <div className="filter-card">
        <span><label htmlFor="transaction-to">Data final</label></span>
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

    <div style={{ marginTop: '24px', marginBottom: '24px' }}>
      <BankNotificationAssistantWidget
        onAddTransaction={async (tx) => {
          const { data: userData } = await supabase.auth.getUser();
          await supabase.from("transactions").insert({
            workspace_id: workspace.id,
            owner_id: ownerId || userData.user?.id,
            description: tx.description,
            amount: tx.amount,
            type: tx.type,
            competence_date: todayInSaoPaulo(),
            due_date: todayInSaoPaulo(),
            status: "paid",
          });
          await reload();
        }}
      />
    </div>

    <div className="dashboard-bento-grid" style={{ gridTemplateColumns: '1fr' }}>
      <List title="Histórico">
        {transactions.map((transaction) => {
          const isIncome = transaction.type === "income";
          const category = categories.find((c) => c.id === transaction.category_id)?.name;
          return (
            <article className="tx-row" key={transaction.id}>
              <span className="tx-icon-badge" style={isIncome ? { background: "rgba(34,197,94,.15)", color: "#22C55E" } : { background: "rgba(239,68,68,.15)", color: "#EF4444" }}>
                {isIncome ? <ArrowUpRight size={16} aria-hidden="true" /> : <ArrowDownRight size={16} aria-hidden="true" />}
              </span>
              <span className="tx-row__body">
                <strong>{transaction.description}</strong>
                <small>{category ? `${category} · ` : ""}{transaction.competence_date}</small>
              </span>
              <span className="tx-row__amount" style={{ color: isIncome ? 'var(--positive)' : 'var(--danger)' }}>
                {isIncome ? '+' : '-'}{money(transaction.amount)}
              </span>
            </article>
          );
        })}
        {transactions.length === 0 ? (
          <p className="dashboard-empty" role="status">
            {hasActiveFilters
              ? "Nenhuma movimentação corresponde aos filtros."
              : "Nenhuma movimentação registrada."}
          </p>
        ) : null}
      </List>
    </div>

    {total > 0 ? (
      <nav className="transaction-pagination" style={{ display: 'flex', justifyContent: 'center', marginTop: '16px' }} aria-label="Paginação do histórico">
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

    {openDialog && (
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} title="Nova movimentação">
          <SimpleForm onSubmit={async (form) => {
            await submitTransaction(form);
            if (!messageIsError) setOpenDialog(false);
          }}>
            <label htmlFor="transaction-type">Tipo de movimentação</label>
            <select id="transaction-type" name="type" defaultValue={presetType}><option value="expense">Despesa</option><option value="income">Receita</option><option value="transfer">Transferência</option></select>
            <label htmlFor="transaction-amount">Valor</label>
            <input id="transaction-amount" name="amount" placeholder="0,00" autoComplete="off" data-lpignore="true" required />
            <label htmlFor="transaction-account">Conta</label>
            <select id="transaction-account" name="account_id" required><option value="">Conta</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
            <label htmlFor="transaction-category">Categoria</label>
            <select
              id="transaction-category"
              name="category_id"
              onChange={(e) => {
                e.currentTarget.dataset.manual = "true";
              }}
            >
              <option value="">Categoria</option>
              {categories.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
            <label htmlFor="transaction-destination">Conta de destino</label>
            <select id="transaction-destination" name="destination_account_id"><option value="">Destino se transferência</option>{accounts.map((a) => <option key={a.id} value={a.id}>{a.name}</option>)}</select>
            <label htmlFor="transaction-description">Descrição</label>
            <input
              id="transaction-description"
              name="description"
              placeholder="Descrição"
              autoComplete="off"
              data-lpignore="true"
              onChange={(e) => {
                const cat = predictCategory(e.target.value, categories, transactions);
                if (cat) {
                  const select = document.getElementById("transaction-category") as HTMLSelectElement | null;
                  if (select && select.dataset.manual !== "true") {
                    select.value = cat;
                  }
                }
              }}
            />
            <label htmlFor="transaction-date">Data</label>
            <input id="transaction-date" name="competence_date" type="date" defaultValue={todayInSaoPaulo()} autoComplete="off" data-lpignore="true" required />
            <button>Salvar</button>
          </SimpleForm>
      </Dialog>
    )}
  </main>;
}

export function TransactionsPage() {
  return <Suspense fallback={<main className="dashboard-shell"><p className="muted">Carregando...</p></main>}><TransactionsPageInner /></Suspense>;
}
