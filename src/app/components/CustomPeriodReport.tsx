import { useState, useMemo } from "react";
import { Category } from "./types";
import { money } from "./Money";
import { DashboardChart } from "./DashboardChart";

export function CustomPeriodReport({ transactions, categories }: { transactions: Array<{ competence_date: string; type: string; amount: number | string; category_id?: string | null; description?: string | null; id: string; }>, categories: Category[] }) {
  const [start, setStart] = useState("");
  const [end, setEnd] = useState("");

  const data = useMemo(() => {
    if (!start || !end) return null;
    
    const filtered = transactions.filter(t => t.competence_date >= start && t.competence_date <= end);
    let income = 0;
    let expense = 0;
    const expenseGroups = new Map<string, number>();

    for (const t of filtered) {
      const amt = Number(t.amount);
      if (t.type === "income") {
        income += amt;
      } else {
        expense += amt;
        const cat = categories.find(c => c.id === t.category_id)?.name || "Sem categoria";
        expenseGroups.set(cat, (expenseGroups.get(cat) || 0) + amt);
      }
    }

    const rows = Array.from(expenseGroups.entries())
      .map(([name, total]) => ({ name, total, share: expense > 0 ? (total / expense) * 100 : 0 }))
      .sort((a, b) => b.total - a.total);

    return { income, expense, balance: income - expense, rows };
  }, [transactions, categories, start, end]);

  return <section className="dashboard-card">
    <header style={{ marginBottom: "1rem" }}>
      <h3>Per�odo Personalizado</h3>
      <div style={{ display: "flex", gap: "1rem", marginTop: "1rem", alignItems: "center" }}>
        <div><label className="muted" style={{ display: "block", fontSize: "0.8rem" }}>De:</label><input type="date" value={start} onChange={e => setStart(e.target.value)} /></div>
        <div><label className="muted" style={{ display: "block", fontSize: "0.8rem" }}>At�:</label><input type="date" value={end} onChange={e => setEnd(e.target.value)} /></div>
      </div>
    </header>

    {!data && <p className="muted">Selecione uma data de in�cio e fim para gerar o relat�rio.</p>}
    
    {data && <>
      <div className="bento-row" style={{ gridTemplateColumns: "repeat(3, 1fr)", marginBottom: "2rem" }}>
        <article className="metric-card metric-card--positive">
          <div className="metric-card__head"><span className="muted">Entradas</span></div>
          <strong>{money(data.income)}</strong>
        </article>
        <article className="metric-card metric-card--negative">
          <div className="metric-card__head"><span className="muted">Sa�das</span></div>
          <strong>{money(data.expense)}</strong>
        </article>
        <article className="metric-card">
          <div className="metric-card__head"><span className="muted">Saldo do Per�odo</span></div>
          <strong>{money(data.balance)}</strong>
        </article>
      </div>
      
      <h4>Despesas por Categoria</h4>
      {data.rows.length === 0 ? <p className="muted">Nenhuma despesa no per�odo.</p> : (
        <div className="chart-wrap" style={{ marginTop: "1rem" }}>
          <DashboardChart type="bar" label="Gastos" labels={data.rows.map(r => r.name)} values={data.rows.map(r => r.total)} color="var(--danger-color, #ef4444)" />
        </div>
      )}
    </>}
  </section>
}
