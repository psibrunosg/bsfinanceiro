import Link from "next/link";
import { Archive, ArrowLeft, CalendarDays, RotateCcw } from "lucide-react";
import { requireFinanceContext } from "@/lib/finance/context";
import { archiveCommitment, restoreCommitment } from "./actions";
import { CommitmentForm } from "./commitment-form";
import "./commitments.css";

const money = new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" });

export default async function CommitmentsPage() {
  const { supabase, workspace } = await requireFinanceContext();
  const [{ data: commitments }, { data: accounts }, { data: categories }] = await Promise.all([
    supabase
      .from("fixed_commitments")
      .select("id,description,amount,due_day,account_id,category_id,active")
      .eq("workspace_id", workspace.id)
      .order("active", { ascending: false })
      .order("due_day"),
    supabase.from("accounts").select("id,name").eq("workspace_id", workspace.id).eq("active", true).order("name"),
    supabase.from("categories").select("id,name").eq("workspace_id", workspace.id).eq("active", true).eq("kind", "expense").order("name"),
  ]);
  const accountOptions = accounts ?? [];
  const categoryOptions = categories ?? [];
  const active = commitments?.filter((item) => item.active) ?? [];
  const archived = commitments?.filter((item) => !item.active) ?? [];

  return <main className="management-page commitments-page">
    <header className="management-header">
      <Link href="/" aria-label="Voltar"><ArrowLeft /></Link>
      <div><p className="eyebrow">{workspace.name}</p><h1>Compromissos fixos</h1><p className="muted">Veja e organize o que se repete todo mês.</p></div>
    </header>
    <section className="management-grid">
      <div className="commitment-list">
        <h2>Contas mensais</h2>
        {active.length ? active.map((item) => <article className="commitment-row" key={item.id}>
          <div className="commitment-summary"><span><b>{item.due_day}</b><small>DIA</small></span><div><strong>{item.description}</strong><small>{money.format(Number(item.amount))} por mês</small></div></div>
          <details><summary>Editar</summary><CommitmentForm accounts={accountOptions} categories={categoryOptions} initial={{ ...item, amount: Number(item.amount) }} compact /></details>
          <form action={archiveCommitment}><input type="hidden" name="id" value={item.id} /><button className="icon-action" aria-label={`Arquivar ${item.description}`}><Archive /></button></form>
        </article>) : <div className="empty-state"><CalendarDays /><h3>Nenhum compromisso ainda</h3><p>Adicione aluguel, internet ou qualquer pagamento recorrente.</p></div>}
        {archived.length ? <details className="archived-list"><summary>Arquivados ({archived.length})</summary>{archived.map((item) => <div key={item.id}><span><strong>{item.description}</strong><small>Dia {item.due_day} · {money.format(Number(item.amount))}</small></span><form action={restoreCommitment}><input type="hidden" name="id" value={item.id} /><button className="icon-action" aria-label={`Restaurar ${item.description}`}><RotateCcw /></button></form></div>)}</details> : null}
      </div>
      <aside className="form-card"><h2>Novo compromisso</h2><p className="muted">Cadastre uma vez para acompanhar todos os meses.</p><CommitmentForm accounts={accountOptions} categories={categoryOptions} /></aside>
    </section>
  </main>;
}
