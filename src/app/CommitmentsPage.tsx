"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { money, parseMoney, dateFmt } from "./components/Money";
import { createClient } from "@/lib/supabase/client";
import { useMemo, useState } from "react";
import { CalendarDays, Check, Pin } from "lucide-react";

export function CommitmentsPage() {
  const {
    workspace,
    accounts,
    categories,
    commitments,
    occurrences,
    loading,
    message,
    setMessage,
    reload,
  } = useFinance("commitments");
  const supabase = useMemo(() => createClient(), []);
  const [payingId, setPayingId] = useState<string | null>(null);

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  const expenseCategories = categories.filter((c) => c.kind === "expense");
  const totalFixed = commitments.reduce(
    (s, c) => s + Number(c.amount),
    0
  );

  async function submitCommitment(form: FormData) {
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
    setMessage(
      error
        ? "Não foi possível criar o compromisso."
        : "Compromisso criado."
    );
    await reload();
  }

  async function payCommitment(occurrenceId: string, form: FormData) {
    const accountId = form.get("account_id");
    if (!accountId) {
      setMessage("Escolha uma conta para pagar.");
      return;
    }
    setPayingId(occurrenceId);
    const { error } = await supabase.rpc(
      "pay_fixed_commitment_occurrence",
      {
        p_occurrence_id: occurrenceId,
        p_account_id: accountId,
        p_paid_on: new Date().toISOString().slice(0, 10),
        p_idempotency_key: crypto.randomUUID(),
      }
    );
    setMessage(
      error
        ? "Não foi possível pagar o compromisso."
        : "Compromisso pago."
    );
    setPayingId(null);
    await reload();
  }

  return (
    <main className="management-page">
      <PageHeader
        title="Compromissos"
        subtitle="Contas fixas do mês."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      <section className="management-grid">
        <List title={`Compromissos fixos · ${money(totalFixed)}/mês`}>
          {commitments.map((c) => {
            const cat = categories.find((x) => x.id === c.category_id);
            return (
              <article className="account-row" key={c.id}>
                <span><Pin aria-hidden="true" /></span>
                <div>
                  <strong>{c.description}</strong>
                  <small>
                    vence dia {c.due_day}
                    {cat ? ` · ${cat.name}` : ""}
                  </small>
                </div>
                <b>{money(c.amount)}</b>
              </article>
            );
          })}
        </List>
        <aside className="form-card">
          <h2>Novo compromisso</h2>
          <SimpleForm onSubmit={submitCommitment}>
            <input
              name="description"
              placeholder="Ex.: Aluguel"
              maxLength={100}
              required
            />
            <input name="amount" placeholder="0,00" required />
            <input
              name="due_day"
              type="number"
              min="1"
              max="31"
              defaultValue="10"
              required
            />
            <select name="account_id">
              <option value="">Conta (opcional)</option>
              {accounts.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.name}
                </option>
              ))}
            </select>
            <select name="category_id">
              <option value="">Categoria (opcional)</option>
              {expenseCategories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
            <button>Adicionar</button>
          </SimpleForm>
        </aside>
      </section>
      <section className="account-list">
        <h2>
          Este mês ·{" "}
          {new Intl.DateTimeFormat("pt-BR", {
            month: "long",
            year: "numeric",
          }).format(new Date())}
        </h2>
        {occurrences.length === 0 && (
          <p className="muted">Nenhuma ocorrência neste mês.</p>
        )}
        {occurrences.map((o) => {
          const paid = o.status === "paid";
          const payable = o.status === "planned";
          return (
            <article className="account-row" key={o.id}>
              <span>{paid ? <Check aria-hidden="true" /> : <CalendarDays aria-hidden="true" />}</span>
              <div>
                <strong>{o.description}</strong>
                <small>
                  vence{" "}
                  {dateFmt.format(new Date(`${o.due_date}T12:00:00`))}
                  {paid
                    ? " · paga"
                    : payable
                      ? ""
                      : ` · ${o.status}`}
                </small>
                {payable && (
                  <form
                    className="finance-form"
                    onSubmit={async (e) => {
                      e.preventDefault();
                      const f = new FormData(e.currentTarget);
                      e.currentTarget.reset();
                      await payCommitment(o.id, f);
                    }}
                  >
                    <select name="account_id" required>
                      <option value="">Pagar com...</option>
                      {accounts.map((a) => (
                        <option key={a.id} value={a.id}>
                          {a.name}
                        </option>
                      ))}
                    </select>
                    <button disabled={payingId === o.id}>
                      {payingId === o.id ? "Pagando..." : "Pagar"}
                    </button>
                  </form>
                )}
              </div>
              <b>{money(o.amount)}</b>
            </article>
          );
        })}
      </section>
    </main>
  );
}
