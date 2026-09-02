import type { Debt } from "./types";
import { money } from "./Money";

export function DebtListWidget({ debts, onAdd }: { debts: Debt[]; onAdd: () => void }) {
  if (debts.length === 0) {
    return (
      <div className="dashboard-card" style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "2rem" }}>
        <h3>Sem dívidas cadastradas</h3>
        <p style={{ color: "#666", marginBottom: "1rem" }}>Controle seus financiamentos e empréstimos aqui.</p>
        <button onClick={onAdd} className="primary-button">Adicionar Dívida</button>
      </div>
    );
  }

  return (
    <div className="dashboard-card">
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "1rem" }}>
        <h3>Minhas Dívidas</h3>
        <button onClick={onAdd} className="primary-button">Nova Dívida</button>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
        {debts.map((d) => {
          const progress = Math.min(100, Math.max(0, ((d.total_amount - d.outstanding_balance) / d.total_amount) * 100));
          return (
            <div key={d.id} style={{ border: "1px solid #eee", padding: "1rem", borderRadius: "8px" }}>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "0.5rem" }}>
                <strong>{d.name}</strong>
                <span>Parcela: {money(d.monthly_installment)} (dia {d.due_date_day})</span>
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: "0.875rem", color: "#666", marginBottom: "0.5rem" }}>
                <span>Total: {money(d.total_amount)}</span>
                <span>Faltam: {money(d.outstanding_balance)} ({d.interest_rate_percent_monthly}% a.m.)</span>
              </div>
              <div style={{ width: "100%", height: "8px", backgroundColor: "#eee", borderRadius: "4px", overflow: "hidden" }}>
                <div style={{ width: `${progress}%`, height: "100%", backgroundColor: progress > 80 ? "#10b981" : "#3b82f6" }} />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
