"use client";

import { useFinance } from "./components/useFinance";
import { Nav } from "./components/Nav";
import { PageHeader } from "./components/PageHeader";
import { List } from "./components/List";
import { SimpleForm } from "./components/SimpleForm";
import { CATEGORY_KIND_LABEL } from "./components/types";
import { useToast } from "./components/Toast";
import { createClient } from "@/lib/supabase/client";
import { useMemo } from "react";

export function CategoriesPage() {
  const { workspace, categories, loading, reload } = useFinance("categories");
  const { toast } = useToast();
  const supabase = useMemo(() => createClient(), []);

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
    if (error) toast("Não foi possível criar a categoria.", "error");
    else toast("Categoria criada.");
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
