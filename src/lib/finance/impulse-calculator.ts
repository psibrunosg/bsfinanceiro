export type ImpulseInput = {
  price: number;
  monthlyIncome: number;
  workHoursPerMonth?: number; // Padrão: 160h (40h/semana)
  annualCdiRatePercent?: number; // Padrão: 12% a.a.
};

export type HoursOfLifeResult = {
  price: number;
  hourlyWage: number;
  hoursRequired: number;
  workDaysRequired: number;
  futureValue5Years: number;
  interestEarned5Years: number;
  futureValue10Years: number;
  interestEarned10Years: number;
  impactSentence: string;
};

export type WishlistItem = {
  id: string;
  name: string;
  price: number;
  hoursRequired?: number;
  createdAt: string;
  coolingOffHours?: number; // 48 ou 168 (7 dias)
  status: "cooling_off" | "purchased" | "dismissed_saved";
};

export type WishlistMetricsResult = {
  totalSavedByDismissal: number;
  activeCoolingOffCount: number;
  purchasedCount: number;
  dismissedCount: number;
};

/**
 * Converte o preço de um item de desejo em horas/dias de trabalho real e calcula o custo de oportunidade no CDI.
 */
export function calculateHoursOfLife(input: ImpulseInput): HoursOfLifeResult {
  const {
    price,
    monthlyIncome,
    workHoursPerMonth = 160,
    annualCdiRatePercent = 12.0,
  } = input;

  const validPrice = Math.max(0, price);
  const income = Math.max(1, monthlyIncome);
  const hours = Math.max(1, workHoursPerMonth);

  const hourlyWage = Math.round((income / hours) * 100) / 100;
  const hoursRequired =
    hourlyWage > 0 ? Math.round((validPrice / hourlyWage) * 10) / 10 : 0;
  const workDaysRequired = Math.round((hoursRequired / 8) * 10) / 10;

  const rate = annualCdiRatePercent / 100;
  const fv5 = validPrice * Math.pow(1 + rate, 5);
  const fv10 = validPrice * Math.pow(1 + rate, 10);

  const futureValue5Years = Math.round(fv5 * 100) / 100;
  const interestEarned5Years = Math.round((fv5 - validPrice) * 100) / 100;

  const futureValue10Years = Math.round(fv10 * 100) / 100;
  const interestEarned10Years = Math.round((fv10 - validPrice) * 100) / 100;

  let impactSentence = `Custa ${hoursRequired}h de trabalho (${workDaysRequired} dias úteis da sua vida)`;
  if (workDaysRequired < 1) {
    impactSentence = `Custa ${hoursRequired}h de trabalho (${(hoursRequired * 60).toFixed(0)} minutos da sua vida)`;
  }

  return {
    price: validPrice,
    hourlyWage,
    hoursRequired,
    workDaysRequired,
    futureValue5Years,
    interestEarned5Years,
    futureValue10Years,
    interestEarned10Years,
    impactSentence,
  };
}

/**
 * Computa as métricas de autocontrole da lista de desejos (dinheiro salvo por compras evitadas).
 */
export function computeWishlistMetrics(items: WishlistItem[]): WishlistMetricsResult {
  let totalSavedByDismissal = 0;
  let activeCoolingOffCount = 0;
  let purchasedCount = 0;
  let dismissedCount = 0;

  for (const item of items) {
    const amt = Math.abs(Number(item.price) || 0);

    if (item.status === "dismissed_saved") {
      totalSavedByDismissal += amt;
      dismissedCount++;
    } else if (item.status === "cooling_off") {
      activeCoolingOffCount++;
    } else if (item.status === "purchased") {
      purchasedCount++;
    }
  }

  return {
    totalSavedByDismissal: Math.round(totalSavedByDismissal * 100) / 100,
    activeCoolingOffCount,
    purchasedCount,
    dismissedCount,
  };
}

export type NetMonthlyIncomeOptions = {
  payslips?: Array<{ competence?: string; received_date?: string | null; net_amount?: number | string }>;
  transactions?: Array<{ type?: string; competence_date?: string; amount?: number | string; category_id?: string | null; description?: string }>;
  salaryCategoryId?: string | null;
  selectedMonth?: string; // YYYY-MM
};

/**
 * Puxa e resolve a renda líquida mensal a partir dos dados do banco:
 * 1. Prioriza holerites (payslips): soma do net_amount no mês selecionado ou no mês mais recente cadastrado.
 * 2. Fallback: transações de receita (excluindo estornos/créditos de faturas).
 */
export function resolveNetMonthlyIncome(options: NetMonthlyIncomeOptions): number {
  const { payslips = [], transactions = [], selectedMonth } = options;

  // 1. Se houver payslips, agrupa por mês (competence ou received_date)
  if (payslips.length > 0) {
    const byMonth: Record<string, number> = {};
    for (const p of payslips) {
      const net = Number(p.net_amount || 0);
      if (net <= 0) continue;
      const monthKey = (p.competence || p.received_date || "").slice(0, 7);
      if (monthKey) {
        byMonth[monthKey] = (byMonth[monthKey] || 0) + net;
      }
    }

    // Se o mês selecionado tem holerite registrado com valor líquido
    if (selectedMonth && byMonth[selectedMonth] && byMonth[selectedMonth] > 0) {
      return Math.round(byMonth[selectedMonth] * 100) / 100;
    }

    // Caso o mês selecionado não tenha (ex: mês futuro ou sem registro), pega o mês mais recente cadastrado
    const sortedMonths = Object.keys(byMonth).sort().reverse();
    if (sortedMonths.length > 0 && byMonth[sortedMonths[0]] > 0) {
      return Math.round(byMonth[sortedMonths[0]] * 100) / 100;
    }
  }

  // 2. Fallback para transações de receita (income)
  if (transactions.length > 0) {
    const isRefund = (desc: string) =>
      /estorno|crédito|credito pula compra|reembolso|devolu[cç][aã]o/i.test(desc);

    const incomeTx = transactions.filter(
      (t) => t.type === "income" && !isRefund(t.description || "")
    );

    if (incomeTx.length > 0) {
      const byMonth: Record<string, number> = {};
      for (const t of incomeTx) {
        const amt = Number(t.amount || 0);
        if (amt <= 0) continue;
        const monthKey = (t.competence_date || "").slice(0, 7);
        if (monthKey) {
          byMonth[monthKey] = (byMonth[monthKey] || 0) + amt;
        }
      }

      if (selectedMonth && byMonth[selectedMonth] && byMonth[selectedMonth] > 0) {
        return Math.round(byMonth[selectedMonth] * 100) / 100;
      }

      const sortedMonths = Object.keys(byMonth).sort().reverse();
      if (sortedMonths.length > 0 && byMonth[sortedMonths[0]] > 0) {
        return Math.round(byMonth[sortedMonths[0]] * 100) / 100;
      }
    }
  }

  return 0;
}

