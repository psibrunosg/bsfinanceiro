import React from "react";
import Link from "next/link";
import { dateFmt, money } from "./Money";
import type { TodayDashboardModel } from "../../lib/finance/today-adapter";
import type { TodayAction } from "../../lib/finance/today-actions";

export function TodayPanel({ today, actions }: { today: TodayDashboardModel; actions: readonly TodayAction[] }) {
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
      <nav className="today-actions" aria-label="Ações financeiras">
        {actions.map((action) => <Link key={action.id} href={action.href}>{action.label}</Link>)}
      </nav>
    </section>
  );
}
