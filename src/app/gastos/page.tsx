"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useFinance } from "../components/useFinance";
import { Nav } from "../components/Nav";
import { PageHeader } from "../components/PageHeader";
import { Dialog } from "../components/Dialog";
import { SimpleForm } from "../components/SimpleForm";
import { List } from "../components/List";
import { money, parseMoney, dateFmt, monthStart, nextMonthStart } from "../components/Money";
import { DashboardChart } from "../components/DashboardChart";
import { createClient } from "@/lib/supabase/client";
import { ReceiptText, Check } from "lucide-react";

type Tab = "overview" | "launches" | "recurrent";

type ExpenseTx = {
  id: string;
  description: string;
  amount: number;
  competence_date: string;
  category_id: string | null;
  context_id: string | null;
  status: string;
};

type Commitment = {
  id: string;
  description: string;
  amount: number;
  due_day: number;
  category_id: string | null;
};
type Occurrence = {
  id: string;
  fixed_commitment_id: string;
  due_date: string;
  description: string;
  amount: number;
  status: string;
};

type DialogState = { kind: "expense" } | { kind: "recurrent" } | null;

export default function GastosPage() {
  const { workspace, accounts, categories, defaultCashAccountId, loading } =
    useFinance("dashboard");
  const supabase = useMemo(() => createClient(), []);
  // Lido no cliente apenas para a aba inicial; evita useSearchParams para
  // manter a página estática sem suspense boundary.
  const [tab, setTab] = useState<Tab>(() =>
    typeof window !== "undefined" &&
    new URLSearchParams(window.location.search).get("tab") === "recorrentes"
      ? "recurrent"
      : "overview"
  );
  const [expenses, setExpenses] = useState<ExpenseTx[]>([]);
  const [commitments, setCommitments] = useState<Commitment[]>([]);
  const [occurrences, setOccurrences] = useState<Occurrence[]>([]);
  const [defaultContextId, setDefaultContextId] = useState<string | null>(null);
  const [contextFilter, setContextFilter] = useState<"all" | "pessoal" | "clinica">("all");
  const [dialog, setDialog] = useState<DialogState>(null);
  const [message, setMessage] = useState("");
  const [hubLoading, setHubLoading] = useState(true);

  const loadHub = useCallback(async () => {
    if (!workspace) return;
    try {
      const [{ data: contextRows }, { data: expenseRows }, { data: commitmentRows }, { data: occurrenceData }] =
        await Promise.all([
          supabase
            .from("financial_contexts")
            .select("id,kind")
            .eq("workspace_id", workspace.id)
            .eq("active", true),
          supabase
            .from("transactions")
            .select("id,description,amount,competence_date,category_id,context_id,status")
            .eq("workspace_id", workspace.id)
            .eq("type", "expense")
            // Pagamentos de fatura saem da composição por categoria para evitar
            // dupla contagem com as parcelas do cartão.
            .not("description", "ilike", "Pagamento de fatura%")
            .not("description", "ilike", "Fatura %")
            .order("competence_date", { ascending: false })
            .limit(500),
          supabase
            .from("fixed_commitments")
            .select("id,description,amount,due_day,category_id")
            .eq("workspace_id", workspace.id)
            .eq("active", true)
            .order("due_day"),
          supabase.rpc("materialize_fixed_commitment_occurrences", {
            p_workspace_id: workspace.id,
            p_month: monthStart(),
          }),
        ]);
      setDefaultContextId((contextRows ?? []).find((c: { kind: string }) => c.kind === "pessoal")?.id ?? null);
      setExpenses(expenseRows ?? []);
      setCommitments(commitmentRows ?? []);
      setOccurrences(occurrenceData ?? []);
    } finally {
      setHubLoading(false);
    }
  }, [supabase, workspace]);

  useEffect(() => {
    void loadHub();
  }, [loadHub]);

  if (loading || !workspace || hubLoading) {
    return <main className="management-page"><p className="muted">Carregando...</p></main>;
  }

  const expenseCategories = categories.filter((c) => c.kind === "expense");
  const filteredExpenses =
    contextFilter === "all"
      ? expenses
      : expenses.filter((t) =>
          t.context_id === null
            ? contextFilter === "pessoal"
            : t.context_id === defaultContextId
              ? contextFilter === "pessoal"
              : contextFilter === "clinica"
        );

  const currentMonthExpenses = filteredExpenses.filter(
    (t) => t.competence_date >= monthStart() && t.competence_date < nextMonthStart()
  );
  const totalMonth = currentMonthExpenses.reduce((s, t) => s + Number(t.amount), 0);
  const totalRecurrent = commitments.reduce((s, c) => s + Number(c.amount), 0);

  const byCategory = expenseCategories
    .map((c) => ({
      label: c.name,
      value: currentMonthExpenses
        .filter((t) => t.category_id === c.id)
        .reduce((s, t) => s + Number(t.amount), 0),
    }))
    .filter((x) => x.value > 0)
    .sort((a, b) => b.value - a.value);

  const byMonth: { label: string; value: number }[] = [];
  const now = new Date();
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const start = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-01`;
    const end = new Date(d.getFullYear(), d.getMonth() + 1, 1).toISOString().slice(0, 10);
    const value = filteredExpenses
      .filter((t) => t.competence_date >= start && t.competence_date < end)
      .reduce((s, t) => s + Number(t.amount), 0);
    byMonth.push({
      label: new Intl.DateTimeFormat("pt-BR", { month: "short" }).format(d),
      value,
    });
  }

  const action =
    tab === "recurrent"
      ? { label: "Novo compromisso", onClick: () => setDialog({ kind: "recurrent" }) }
      : { label: "Registrar gasto", onClick: () => setDialog({ kind: "expense" }) };

  async function submitExpense(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("transactions").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      account_id: form.get("account_id"),
      category_id: form.get("category_id") || null,
      context_id: defaultContextId,
      type: "expense",
      amount: parseMoney(form.get("amount")),
      description: form.get("description"),
      competence_date: form.get("competence_date"),
      paid_at: form.get("competence_date"),
      status: "paid",
      idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível registrar o gasto." : "Gasto registrado.");
    if (!error) setDialog(null);
    await loadHub();
  }

  async function submitRecurrent(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("fixed_commitments").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      description: form.get("description"),
      amount: parseMoney(form.get("amount")),
      due_day: Number(form.get("due_day")),
      account_id: form.get("account_id") || null,
      category_id: form.get("category_id") || null,
    });
    setMessage(error ? "Não foi possível criar o compromisso." : "Compromisso criado.");
    if (!error) setDialog(null);
    await loadHub();
  }

  async function payOccurrence(occurrenceId: string, form: FormData) {
    const accountId = form.get("account_id");
    if (!accountId) {
      setMessage("Escolha uma conta para pagar.");
      return;
    }
    const { error } = await supabase.rpc("pay_fixed_commitment_occurrence", {
      p_occurrence_id: occurrenceId,
      p_account_id: accountId,
      p_paid_on: new Date().toISOString().slice(0, 10),
      p_idempotency_key: crypto.randomUUID(),
    });
    setMessage(error ? "Não foi possível pagar o compromisso." : "Compromisso pago.");
    await loadHub();
  }

  const today = new Date().toISOString().slice(0, 10);

  return (
    <main className="management-page">
      <Nav />
      <PageHeader
        title="Gastos"
        subtitle="Visão geral, lançamentos e recorrentes"
        workspaceName={workspace.name}
        action={action}
      />
      {message && <p className={message.startsWith("Não") ? "form-error" : "form-success"} role={message.startsWith("Não") ? "alert" : "status"}>{message}</p>}

      <nav className="hub-tabs" aria-label="Abas de gastos">
        <button type="button" aria-pressed={tab === "overview"} onClick={() => setTab("overview")} className={tab === "overview" ? "active" : ""}>Visão geral</button>
        <button type="button" aria-pressed={tab === "launches"} onClick={() => setTab("launches")} className={tab === "launches" ? "active" : ""}>Lançamentos</button>
        <button type="button" aria-pressed={tab === "recurrent"} onClick={() => setTab("recurrent")} className={tab === "recurrent" ? "active" : ""}>Recorrentes</button>
      </nav>

      <div className="hub-filters" style={{ display: "flex", gap: 8, alignItems: "center", margin: "12px 0" }}>
        <label className="muted" style={{ display: "inline-flex", alignItems: "center", gap: 6 }}>
          Contexto
          <select
            value={contextFilter}
            onChange={(e) => setContextFilter(e.target.value as "all" | "pessoal" | "clinica")}
            aria-label="Filtrar por contexto"
          >
            <option value="all">Todos</option>
            <option value="pessoal">Pessoal</option>
            <option value="clinica">Clínica</option>
          </select>
        </label>
      </div>

      {tab === "overview" && (
        <section>
          <section className="hub-overview">
            <article className="metric-card metric-card--negative">
              <ReceiptText aria-hidden="true" />
              <strong>{money(totalMonth)}</strong>
              <span className="muted">Gasto no mês</span>
            </article>
            <article className="metric-card">
              <strong>{money(totalRecurrent)}</strong>
              <span className="muted">Compromissos fixos/mês</span>
            </article>
          </section>
          <section className="dashboard-columns" style={{ marginTop: 18 }}>
            {byCategory.length > 0 && (
              <article className="dashboard-card">
                <h3>Por categoria (mês)</h3>
                <div className="chart-wrap">
                  <DashboardChart type="doughnut" label="Gastos" labels={byCategory.map((x) => x.label)} values={byCategory.map((x) => x.value)} color="var(--accent)" />
                </div>
              </article>
            )}
            <article className="dashboard-card">
              <h3>Evolução mensal</h3>
              <div className="chart-wrap">
                {filteredExpenses.length > 0 ? (
                  <DashboardChart type="bar" label="Gastos" labels={byMonth.map((x) => x.label)} values={byMonth.map((x) => x.value)} color="var(--accent)" />
                ) : (
                  <p className="dashboard-empty">Nenhum gasto registrado ainda.{" "}
                    <button type="button" onClick={() => setDialog({ kind: "expense" })}>Registrar primeiro gasto</button>
                  </p>
                )}
              </div>
            </article>
          </section>
        </section>
      )}

      {tab === "launches" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title="Lançamentos">
            {filteredExpenses.length === 0 ? (
              <p className="dashboard-empty">Nenhum gasto registrado.{" "}
                <button type="button" onClick={() => setDialog({ kind: "expense" })}>Registrar primeiro gasto</button>
              </p>
            ) : (
              <ul className="list" style={{ display: "grid", gap: 6 }}>
                {filteredExpenses.map((t) => {
                  const cat = expenseCategories.find((c) => c.id === t.category_id);
                  return (
                    <li key={t.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                      <span>
                        {t.description} · {dateFmt.format(new Date(`${t.competence_date}T12:00:00`))}
                        {cat ? ` · ${cat.name}` : ""}
                      </span>
                      <b>{money(t.amount)}</b>
                    </li>
                  );
                })}
              </ul>
            )}
          </List>
        </section>
      )}

      {tab === "recurrent" && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title={`Compromissos fixos · ${money(totalRecurrent)}/mês`}>
            {commitments.length === 0 && (
              <p className="dashboard-empty">Nenhum compromisso fixo.{" "}
                <button type="button" onClick={() => setDialog({ kind: "recurrent" })}>Criar primeiro compromisso</button>
              </p>
            )}
            {commitments.map((c) => {
              const cat = expenseCategories.find((x) => x.id === c.category_id);
              return (
                <article className="account-row" key={c.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                  <div>
                    <strong>{c.description}</strong>
                    <small>vence dia {c.due_day}{cat ? ` · ${cat.name}` : ""}</small>
                  </div>
                  <b>{money(c.amount)}</b>
                </article>
              );
            })}
          </List>

          <List title={`Ocorrências · ${new Intl.DateTimeFormat("pt-BR", { month: "long", year: "numeric" }).format(new Date())}`}>
            {occurrences.length === 0 && <p className="muted">Nenhuma ocorrência neste mês.</p>}
            {occurrences.map((o) => {
              const paid = o.status === "paid";
              const payable = o.status === "planned";
              return (
                <article className="account-row" key={o.id} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 12 }}>
                  <div>
                    <strong>{o.description}</strong>
                    <small>
                      vence {dateFmt.format(new Date(`${o.due_date}T12:00:00`))}
                      {paid ? " · paga" : ""}
                    </small>
                    {payable && (
                      <form
                        className="finance-form"
                        style={{ display: "flex", gap: 8, marginTop: 6 }}
                        onSubmit={async (e) => {
                          e.preventDefault();
                          const f = new FormData(e.currentTarget);
                          e.currentTarget.reset();
                          await payOccurrence(o.id, f);
                        }}
                      >
                        <select name="account_id" required aria-label="Conta para pagamento">
                          <option value="">Pagar com...</option>
                          {accounts.map((a) => (
                            <option key={a.id} value={a.id}>{a.name}</option>
                          ))}
                        </select>
                        <button><Check aria-hidden="true" /> Pagar</button>
                      </form>
                    )}
                  </div>
                  <b>{money(o.amount)}</b>
                </article>
              );
            })}
          </List>
        </section>
      )}

      <Dialog open={dialog !== null} onClose={() => setDialog(null)} title={dialog?.kind === "recurrent" ? "Novo compromisso" : "Registrar gasto"}>
        {dialog?.kind === "expense" && (
          <SimpleForm key="expense" onSubmit={submitExpense}>
            <label htmlFor="expense-description">Descrição</label>
            <input id="expense-description" name="description" maxLength={160} placeholder="Descrição do gasto" required autoFocus />
            <label htmlFor="expense-amount">Valor</label>
            <input id="expense-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="expense-account">Conta</label>
            <select id="expense-account" name="account_id" defaultValue={defaultCashAccountId ?? ""} required>
              <option value="">Escolha uma conta</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="expense-category">Categoria</label>
            <select id="expense-category" name="category_id">
              <option value="">Sem categoria</option>
              {expenseCategories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
            <label htmlFor="expense-date">Data</label>
            <input id="expense-date" name="competence_date" type="date" defaultValue={today} required />
            <button>Registrar gasto</button>
          </SimpleForm>
        )}
        {dialog?.kind === "recurrent" && (
          <SimpleForm key="recurrent" onSubmit={submitRecurrent}>
            <label htmlFor="recurrent-description">Descrição</label>
            <input id="recurrent-description" name="description" maxLength={100} placeholder="Ex.: Aluguel" required autoFocus />
            <label htmlFor="recurrent-amount">Valor</label>
            <input id="recurrent-amount" name="amount" placeholder="0,00" required />
            <label htmlFor="recurrent-day">Dia do vencimento</label>
            <input id="recurrent-day" name="due_day" type="number" min="1" max="31" defaultValue="10" required />
            <label htmlFor="recurrent-account">Conta</label>
            <select id="recurrent-account" name="account_id">
              <option value="">Conta (opcional)</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>{a.name}</option>
              ))}
            </select>
            <label htmlFor="recurrent-category">Categoria</label>
            <select id="recurrent-category" name="category_id">
              <option value="">Categoria (opcional)</option>
              {expenseCategories.map((c) => (
                <option key={c.id} value={c.id}>{c.name}</option>
              ))}
            </select>
            <button>Adicionar</button>
          </SimpleForm>
        )}
      </Dialog>
    </main>
  );
}
