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
    const { error } = await supabase
      .from("transactions")
      .update({ category_id: categoryId })
      .eq("id", transactionId);
    if (error) {
      setMessage("Não foi possível categorizar o lançamento.");
      await loadUncategorized();
    }
  }

  if (loading || !workspace)
    return (
      <main className="management-page">
        <p className="muted">Carregando...</p>
      </main>
    );

  async function submitCategory(form: FormData) {
    const { data: userData } = await supabase.auth.getUser();
    const { error } = await supabase.from("categories").insert({
      workspace_id: workspace.id,
      owner_id: userData.user?.id,
      name: form.get("name"),
      kind: form.get("kind"),
      color: form.get("color") || "#087f5b",
    });
    setMessage(
      error ? "Não foi possível criar a categoria." : "Categoria criada."
    );
    await reload();
  }

  return (
    <main className="management-page">
      <PageHeader
        title="Categorias"
        subtitle="Classifique receitas e despesas."
        workspaceName={workspace.name}
      />
      <Nav />
      {message && <p className="form-success">{message}</p>}
      {!uncategorizedLoading && uncategorized.length > 0 && (
        <section className="management-grid" style={{ gridTemplateColumns: "1fr" }}>
          <List title={`Sem categoria · ${uncategorized.length}`}>
            {uncategorized.map((t) => {
              const options = categories.filter((c) => c.kind === t.type);
              return (
                <article className="account-row" key={t.id}>
                  <div>
                    <strong>{t.description}</strong>
                    <small>{dateFmt.format(new Date(`${t.competence_date}T12:00:00`))}</small>
                  </div>
                  <b className={t.type === "expense" ? "form-error" : "form-success"} style={{ marginRight: 8 }}>
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
        </section>
      )}
      <section className="management-grid">
        <List title="Categorias">
          {categories.map((c) => (
            <article className="account-row" key={c.id}>
              <span style={{ color: c.color || undefined }}>●</span>
              <div>
                <strong>{c.name}</strong>
                <small>{CATEGORY_KIND_LABEL[c.kind] ?? c.kind}</small>
              </div>
            </article>
          ))}
        </List>
        <aside className="form-card">
          <h2>Nova categoria</h2>
          <SimpleForm onSubmit={submitCategory}>
            <input name="name" placeholder="Nome" required />
            <select name="kind" defaultValue="expense">
              <option value="expense">Despesa</option>
              <option value="income">Receita</option>
            </select>
            <input name="color" type="color" defaultValue="#087f5b" />
            <button>Criar</button>
          </SimpleForm>
        </aside>
      </section>
    </main>
  );
}
