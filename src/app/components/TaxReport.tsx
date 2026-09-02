import { useState, useMemo } from "react";
import { Category } from "./types";
import { money } from "./Money";

export function TaxReport({ transactions, categories }: { transactions: Array<{ competence_date: string; type: string; amount: number | string; category_id?: string | null; description?: string | null; id: string; categoryName?: string }>, categories: Category[] }) {
  const [year, setYear] = useState(new Date().getFullYear());
  
  const yearTransactions = useMemo(() => {
    return transactions.filter(t => t.competence_date.startsWith(year.toString()));
  }, [transactions, year]);

  const { totalDeductible, items } = useMemo(() => {
    let total = 0;
    const found: Array<{ competence_date: string; type: string; amount: number | string; category_id?: string | null; description?: string | null; id: string; categoryName?: string }> = [];
    const deductibleRegex = /Sa�de|Educa��o|M�dico|Odonto|Imposto|Livro Caixa|Dentista/i;
    
    for (const tx of yearTransactions) {
      if (tx.type !== "expense") continue;
      const cat = categories.find(c => c.id === tx.category_id);
      
      if (
        (cat && deductibleRegex.test(cat.name)) || 
        deductibleRegex.test(tx.description || "")
      ) {
        total += Number(tx.amount);
        found.push({ ...tx, categoryName: cat?.name || "�" });
      }
    }
    
    return { totalDeductible: total, items: found };
  }, [yearTransactions, categories]);

  return <section className="dashboard-card">
    <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1rem" }}>
      <h3>Resumo de Imposto de Renda ({year})</h3>
      <select value={year} onChange={(e) => setYear(Number(e.target.value))}>
        <option value={new Date().getFullYear()}>{new Date().getFullYear()}</option>
        <option value={new Date().getFullYear() - 1}>{new Date().getFullYear() - 1}</option>
        <option value={new Date().getFullYear() - 2}>{new Date().getFullYear() - 2}</option>
      </select>
    </header>

    <div className="metric-card metric-card--positive" style={{ marginBottom: "1.5rem" }}>
      <div className="metric-card__head">
        <span className="muted">Potencial de Dedu��o Identificado</span>
      </div>
      <strong>{money(totalDeductible)}</strong>
      <p className="muted" style={{ fontSize: "0.8rem", marginTop: "4px" }}>
        Despesas com Sa�de, Educa��o ou Livro-Caixa identificadas automaticamente.
      </p>
    </div>

    <h4>Lan�amentos Encontrados ({items.length})</h4>
    {items.length === 0 ? <p className="muted">Nenhuma despesa dedut�vel encontrada neste ano.</p> : (
      <div style={{ maxHeight: "400px", overflowY: "auto", marginTop: "1rem" }}>
        <table style={{ width: "100%", borderCollapse: "collapse" }}>
          <thead style={{ position: "sticky", top: 0, background: "var(--surface)" }}>
            <tr style={{ borderBottom: "1px solid var(--border)", textAlign: "left" }}>
              <th style={{ padding: "8px" }}>Data</th>
              <th style={{ padding: "8px" }}>Descri��o</th>
              <th style={{ padding: "8px" }}>Categoria</th>
              <th style={{ padding: "8px" }}>Valor</th>
            </tr>
          </thead>
          <tbody>
            {items.map(item => (
              <tr key={item.id} style={{ borderBottom: "1px solid var(--border)" }}>
                <td style={{ padding: "8px" }}>{item.competence_date.split("-").reverse().join("/")}</td>
                <td style={{ padding: "8px" }}>{item.description || "�"}</td>
                <td style={{ padding: "8px" }}>{item.categoryName}</td>
                <td style={{ padding: "8px" }}>{money(item.amount)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    )}
  </section>
}
