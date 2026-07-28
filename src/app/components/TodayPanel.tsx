import React from "react";
import { dateFmt, money } from "./Money";
import type { TodayDashboardModel } from "../../lib/finance/today-adapter";

export function TodayPanel({ today }: { today: TodayDashboardModel }) {
  return (
    <section className="today-panel" aria-labelledby="today-title">
      <div>
        <p className="eyebrow">HOJE</p>
        <h2 id="today-title">Seu próximo passo financeiro</h2>
        <p className="muted">Saldo nas contas: <strong>{money(today.currentBalanceCents / 100)}</strong></p>
      </div>
      {today.nextIncomeDate ? (
        <p className="today-projection">Até {dateFmt.format(new Date(`${today.nextIncomeDate}T12:00:00`))}: <strong>{money(today.projectedBalanceCents / 100)}</strong></p>
      ) : (
        <p className="muted">Nenhuma próxima receita agendada.</p>
      )}
      {today.alert ? (
        <p className="today-alert" data-severity={today.alert.severity} role="status">
          {today.alert.severity === "critical" ? "Atenção: " : "Aviso: "}
          o saldo pode ficar abaixo do limite em {dateFmt.format(new Date(`${today.alert.dueDate}T12:00:00`))}.
        </p>
      ) : null}
    </section>
  );
}
