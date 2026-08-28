export type TravelExpense = {
  id: string;
  description: string;
  amount: number;
  currency?: "BRL" | "USD" | "EUR";
  exchangeRate?: number;
  category?: string;
  date?: string;
};

export type TravelTrip = {
  id: string;
  destination: string;
  budgetBrl: number;
  startDate: string; // YYYY-MM-DD
  endDate: string;   // YYYY-MM-DD
  expenses: TravelExpense[];
};

export type TravelSandboxResult = {
  tripId: string;
  destination: string;
  budgetBrl: number;
  totalDays: number;
  totalSpentBrl: number;
  remainingBrl: number;
  spentPercent: number;
  dailyBudgetBrl: number;
  averageDailySpentBrl: number;
  status: "under_budget" | "on_track" | "over_budget";
  statusLabel: string;
};

function getDaysBetweenDates(startStr: string, endStr: string): number {
  const start = new Date(startStr + "T12:00:00");
  const end = new Date(endStr + "T12:00:00");
  const diffTime = Math.abs(end.getTime() - start.getTime());
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
  return Math.max(1, diffDays);
}

/**
 * Computa as métricas do Sandbox de Gastos de Viagem isolado das despesas mensais.
 */
export function computeTravelSandbox(trip: TravelTrip): TravelSandboxResult {
  const { id, destination, budgetBrl, startDate, endDate, expenses } = trip;
  const budget = Math.max(0, budgetBrl);
  const totalDays = getDaysBetweenDates(startDate, endDate);

  let totalSpentBrl = 0;
  for (const exp of expenses) {
    const rawAmt = Math.max(0, Number(exp.amount) || 0);
    const rate = exp.currency && exp.currency !== "BRL" ? (Number(exp.exchangeRate) || 1) : 1;
    totalSpentBrl += rawAmt * rate;
  }

  totalSpentBrl = Math.round(totalSpentBrl * 100) / 100;
  const remainingBrl = Math.round((budget - totalSpentBrl) * 100) / 100;
  const spentPercent = budget > 0 ? Math.round((totalSpentBrl / budget) * 1000) / 10 : 100;

  const dailyBudgetBrl = Math.round((budget / totalDays) * 100) / 100;
  const averageDailySpentBrl = Math.round((totalSpentBrl / totalDays) * 100) / 100;

  let status: TravelSandboxResult["status"] = "under_budget";
  let statusLabel = "Dentro do Orçamento Planejado";

  if (totalSpentBrl > budget) {
    status = "over_budget";
    statusLabel = `Orçamento Estourado em R$ ${Math.abs(remainingBrl).toLocaleString("pt-BR")}`;
  } else if (spentPercent >= 85) {
    status = "on_track";
    statusLabel = "Atenção: 85%+ do orçamento consumido";
  }

  return {
    tripId: id,
    destination,
    budgetBrl: budget,
    totalDays,
    totalSpentBrl,
    remainingBrl,
    spentPercent,
    dailyBudgetBrl,
    averageDailySpentBrl,
    status,
    statusLabel,
  };
}
