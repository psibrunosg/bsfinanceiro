import { useState } from "react";
import type { Debt } from "./types";
import { Dialog } from "./Dialog";

export function DebtForm({
  isOpen,
  onClose,
  onSubmit,
}: {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (debt: Omit<Debt, "id" | "workspace_id" | "created_at" | "updated_at">) => void;
}) {
  const [name, setName] = useState("");
  const [totalAmount, setTotalAmount] = useState("");
  const [outstandingBalance, setOutstandingBalance] = useState("");
  const [interestRate, setInterestRate] = useState("");
  const [dueDateDay, setDueDateDay] = useState("10");
  const [monthlyInstallment, setMonthlyInstallment] = useState("");
  const [type, setType] = useState<Debt["type"]>("credit_card");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    onSubmit({
      name,
      total_amount: Number(totalAmount),
      outstanding_balance: Number(outstandingBalance),
      interest_rate_percent_monthly: Number(interestRate),
      due_date_day: Number(dueDateDay),
      monthly_installment: Number(monthlyInstallment),
      type,
    });
    onClose();
  }

  return (
    <Dialog open={isOpen} onClose={onClose} title="Nova Dívida">
      <form onSubmit={handleSubmit} style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
        <div>
          <label>Nome</label>
          <input required type="text" value={name} onChange={(e) => setName(e.target.value)} className="input" />
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "1rem" }}>
          <div>
            <label>Valor Total</label>
            <input required type="number" step="0.01" value={totalAmount} onChange={(e) => setTotalAmount(e.target.value)} className="input" />
          </div>
          <div>
            <label>Saldo Devedor Atual</label>
            <input required type="number" step="0.01" value={outstandingBalance} onChange={(e) => setOutstandingBalance(e.target.value)} className="input" />
          </div>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "1rem" }}>
          <div>
            <label>Juros % a.m.</label>
            <input required type="number" step="0.01" value={interestRate} onChange={(e) => setInterestRate(e.target.value)} className="input" />
          </div>
          <div>
            <label>Dia do Vencimento</label>
            <input required type="number" min="1" max="31" value={dueDateDay} onChange={(e) => setDueDateDay(e.target.value)} className="input" />
          </div>
          <div>
            <label>Parcela Mensal</label>
            <input required type="number" step="0.01" value={monthlyInstallment} onChange={(e) => setMonthlyInstallment(e.target.value)} className="input" />
          </div>
        </div>
        <div>
          <label>Tipo</label>
          <select value={type} onChange={(e) => setType(e.target.value as Debt["type"])} className="input">
            <option value="credit_card">Cartão de Crédito</option>
            <option value="loan">Empréstimo</option>
            <option value="financing">Financiamento</option>
            <option value="other">Outro</option>
          </select>
        </div>
        <div style={{ display: "flex", justifyContent: "flex-end", gap: "1rem", marginTop: "1rem" }}>
          <button type="button" onClick={onClose} className="secondary-button">Cancelar</button>
          <button type="submit" className="primary-button">Salvar Dívida</button>
        </div>
      </form>
    </Dialog>
  );
}
