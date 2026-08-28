"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { CATEGORY_KIND_LABEL } from "./components/types";
import { createClient } from "@/lib/supabase/client";
import { money, dateFmt } from "./components/Money";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Tag, TrendingDown, TrendingUp } from "lucide-react";

type UncategorizedTx = {
  id: string;
  description: string;
  amount: number;
  competence_date: string;
  type: "expense" | "income";
};

export function CategoriesPage() {
  const { workspace, categories, loading, message, setMessage, reload } =
    useFinance("categories");
  const supabase = useMemo(() => createClient(), []);
  const [uncategorized, setUncategorized] = useState<UncategorizedTx[]>([]);
  const [uncategorizedLoading, setUncategorizedLoading] = useState(true);

  const loadUncategorized = useCallback(async () => {
    if (!workspace) return;
    const { data } = await supabase
      .from("transactions")
      .select("id,description,amount,competence_date,type")
      .eq("workspace_id", workspace.id)
      .is("category_id", null)
      .in("type", ["expense", "income"])
      .order("competence_date", { ascending: false })
      .limit(100);
    setUncategorized((data ?? []) as UncategorizedTx[]);
    setUncategorizedLoading(false);
  }, [supabase, workspace]);

  useEffect(() => {
    void loadUncategorized();
  }, [loadUncategorized]);

  async function categorize(transactionId: string, categoryId: string) {
    if (!categoryId) return;
    setUncategorized((rows) => rows.filter((t) => t.id !== transactionId));
    try {
      const res = await fetch("/api/transactions/categorize", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ transaction_id: transactionId, category_id: categoryId }),
      });
      if (!res.ok) throw new Error();
    } catch {
      const { error } = await supabase
        .from("transactions")
        .update({ category_id: categoryId })
        .eq("id", transactionId);
      if (error) {
        setMessage("Não foi possível categorizar o lançamento.");
        await loadUncategorized();
      }
    }
  }

  if (loading || !workspace)
    return (
      <main className="dashboard-shell">
        <p className="muted">Carregando...</p>
      </main>
    );

  async function submitCategory(form: FormData) {
    const name = form.get("name");
    const kind = form.get("kind");
    const color = form.get("color") || "#087f5b";

    try {
      const res = await fetch("/api/categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          workspace_id: workspace.id,
          name,
          kind,
          color,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setMessage("Categoria criada.");
      } else {
        const { data: userData } = await supabase.auth.getUser();
        const { error } = await supabase.from("categories").insert({
          workspace_id: workspace.id,
          owner_id: userData?.user?.id,
          name,
          kind,
          color,
        });
        setMessage(error ? "Não foi possível criar a categoria." : "Categoria criada.");
      }
    } catch {
      const { data: userData } = await supabase.auth.getUser();
      const { error } = await supabase.from("categories").insert({
        workspace_id: workspace.id,
        owner_id: userData?.user?.id,
        name,
        kind,
        color,
      });
      setMessage(error ? "Não foi possível criar a categoria." : "Categoria criada.");
    }
    await reload();
  }

  return (
    <main className="dashboard-shell">
      <PageHeader
        title="Categorias"
        subtitle="Classifique receitas e despesas."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      {!uncategorizedLoading && uncategorized.length > 0 && (
        <List title={`Sem categoria · ${uncategorized.length}`}>
          {uncategorized.map((t) => {
            const options = categories.filter((c) => c.kind === t.type);
            const isExpense = t.type === "expense";
            return (
              <article className="account-row" key={t.id} style={{ flexWrap: "wrap" }}>
                <span
                  className="metric-icon-badge"
                  style={isExpense
                    ? { background: "rgba(239,68,68,.15)", color: "#EF4444", marginLeft: 0 }
                    : { background: "rgba(34,197,94,.15)", color: "#22C55E", marginLeft: 0 }}
                >
                  {isExpense ? <TrendingDown size={18} aria-hidden="true" /> : <TrendingUp size={18} aria-hidden="true" />}
                </span>
                <div className="tx-row__body">
                  <strong>{t.description}</strong>
                  <small>{dateFmt.format(new Date(`${t.competence_date}T12:00:00`))}</small>
                </div>
                <b style={{ color: isExpense ? "var(--danger)" : "var(--positive)", whiteSpace: "nowrap" }}>
                  {money(t.amount)}
                </b>
                <select
                  aria-label={`Categorizar ${t.description}`}
                  defaultValue=""
                  onChange={(e) => categorize(t.id, e.target.value)}
                >
                  <option value="" disabled>Categorizar...</option>
                  {options.map((c) => (
                    <option key={c.id} value={c.id}>{c.name}</option>
                  ))}
                </select>
              </article>
            );
          })}
        </List>
      )}
      <section className="bento-row" style={{ gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))' }}>
        <List title="Categorias">
          {categories.map((c) => (
            <article className="account-row" key={c.id}>
              <span
                className="metric-icon-badge"
                style={{ background: "rgba(139,92,246,.15)", color: c.color || "#8B5CF6", marginLeft: 0 }}
              >
                <Tag size={18} aria-hidden="true" />
              </span>
              <div className="tx-row__body">
                <strong>{c.name}</strong>
                <small>{CATEGORY_KIND_LABEL[c.kind] ?? c.kind}</small>
              </div>
            </article>
          ))}
          {categories.length === 0 && (
            <p className="dashboard-empty">Nenhuma categoria criada.</p>
          )}
        </List>
        <aside className="dashboard-card">
          <h3>Nova categoria</h3>
          <SimpleForm onSubmit={submitCategory}>
            <label htmlFor="category-name">Nome</label>
            <input id="category-name" name="name" placeholder="Nome" autoComplete="off" data-lpignore="true" required />
            <label htmlFor="category-kind">Tipo</label>
            <select id="category-kind" name="kind" defaultValue="expense">
              <option value="expense">Despesa</option>
              <option value="income">Receita</option>
            </select>
            <label htmlFor="category-color">Cor</label>
            <input id="category-color" name="color" type="color" defaultValue="#087f5b" />
            <button>Criar</button>
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
