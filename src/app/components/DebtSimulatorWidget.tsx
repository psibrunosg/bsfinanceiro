import { useState, useMemo } from "react";
import type { Debt } from "./types";
import { money } from "./Money";

export function DebtSimulatorWidget({ debts }: { debts: Debt[] }) {
  const [extraPayment, setExtraPayment] = useState(0);
  const [method, setMethod] = useState<"avalanche" | "snowball">("avalanche");

  const simulation = useMemo(() => {
    if (debts.length === 0) return null;

    // Deep copy to simulate
    const simDebts = debts.map(d => ({ ...d }));
    let months = 0;
    let totalInterestPaid = 0;

    while (simDebts.some(d => d.outstanding_balance > 0) && months < 360) {
      months++;
      let extraAvailable = extraPayment;

      // Sort according to method
      if (method === "avalanche") {
        simDebts.sort((a, b) => b.interest_rate_percent_monthly - a.interest_rate_percent_monthly);
      } else {
        simDebts.sort((a, b) => a.outstanding_balance - b.outstanding_balance);
      }

      for (const d of simDebts) {
        if (d.outstanding_balance <= 0) continue;

        const interest = d.outstanding_balance * (d.interest_rate_percent_monthly / 100);
        totalInterestPaid += interest;
        d.outstanding_balance += interest; // accrue interest

        const payment = Math.min(d.outstanding_balance, d.monthly_installment);
        
        // apply minimum payment
        d.outstanding_balance -= payment;

        // if this is the target debt and we have extra, apply extra
        if (d === simDebts.find(x => x.outstanding_balance > 0) && extraAvailable > 0) {
          const applyExtra = Math.min(d.outstanding_balance, extraAvailable);
          d.outstanding_balance -= applyExtra;
          extraAvailable -= applyExtra;
        }
      }
    }

    return { months, totalInterestPaid };
  }, [debts, extraPayment, method]);

  if (debts.length === 0) return null;

  return (
    <div className="dashboard-card">
      <h3 style={{ marginBottom: "1rem" }}>Simulador de Quitação</h3>
      <div style={{ display: "flex", gap: "1rem", marginBottom: "1rem" }}>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", marginBottom: "0.5rem" }}>Pagamento Extra Mensal</label>
          <input
            type="number"
            value={extraPayment || ""}
            onChange={(e) => setExtraPayment(Number(e.target.value))}
            className="input"
            placeholder="Ex: R$ 200,00"
          />
        </div>
        <div style={{ flex: 1 }}>
          <label style={{ display: "block", marginBottom: "0.5rem" }}>Método</label>
          <select value={method} onChange={(e) => setMethod(e.target.value as "avalanche" | "snowball")} className="input">
            <option value="avalanche">Avalanche (Maior Juros)</option>
            <option value="snowball">Bola de Neve (Menor Saldo)</option>
          </select>
        </div>
      </div>
      
      {simulation && (
        <div style={{ padding: "1rem", backgroundColor: "#f0fdf4", border: "1px solid #bbf7d0", borderRadius: "8px" }}>
          <strong>Previsão de Quitação:</strong> {simulation.months} meses<br/>
          <strong>Juros Totais Pagos:</strong> {money(simulation.totalInterestPaid)}
          {extraPayment > 0 && <p style={{ fontSize: "0.875rem", color: "#166534", marginTop: "0.5rem" }}>O pagamento extra acelera a quitação das suas dívidas mais caras/menores conforme o método escolhido.</p>}
        </div>
      )}
    </div>
  );
}
