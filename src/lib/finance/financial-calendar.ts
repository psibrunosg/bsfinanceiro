export type CalendarDay = {
  date: string; // YYYY-MM-DD
  dayNumber: number;
  income: number;
  expense: number;
  net: number;
  status: "positive" | "negative" | "neutral";
  txCount: number;
};

export type FinancialCalendarResult = {
  month: string; // YYYY-MM
  daysInMonth: CalendarDay[];
  positiveDaysCount: number;
  negativeDaysCount: number;
  neutralDaysCount: number;
  peakExpenseDay: CalendarDay | null;
  totalMonthIncome: number;
  totalMonthExpense: number;
};

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
};

function getDaysInMonthCount(year: number, monthIndex: number): number {
  return new Date(year, monthIndex + 1, 0).getDate();
}

/**
 * Computa o fluxo diário e o calendário financeiro visual de um mês específico.
 */
export function computeFinancialCalendar(
  transactions: InputTransaction[],
  month: string = new Date().toISOString().slice(0, 7)
): FinancialCalendarResult {
  const [yearStr, monthStr] = month.split("-");
  const year = parseInt(yearStr, 10) || new Date().getFullYear();
  const monthIndex = (parseInt(monthStr, 10) || 1) - 1;

  const totalDays = getDaysInMonthCount(year, monthIndex);
  const dailyMap = new Map<string, { income: number; expense: number; count: number }>();

  for (let d = 1; d <= totalDays; d++) {
    const dayStr = String(d).padStart(2, "0");
    const dateKey = `${month}-${dayStr}`;
    dailyMap.set(dateKey, { income: 0, expense: 0, count: 0 });
  }

  for (const tx of transactions) {
    const txDate = tx.competence_date ? tx.competence_date.slice(0, 10) : "";
    if (dailyMap.has(txDate)) {
      const entry = dailyMap.get(txDate)!;
      const amt = Math.abs(Number(tx.amount) || 0);
      const isIncome = tx.type === "income";

      if (isIncome) {
        entry.income += amt;
      } else {
        entry.expense += amt;
      }
      entry.count++;
    }
  }

  const daysInMonth: CalendarDay[] = [];
  let positiveDaysCount = 0;
  let negativeDaysCount = 0;
  let neutralDaysCount = 0;
  let peakExpenseDay: CalendarDay | null = null;
  let maxExpense = 0;
  let totalMonthIncome = 0;
  let totalMonthExpense = 0;

  for (let d = 1; d <= totalDays; d++) {
    const dayStr = String(d).padStart(2, "0");
    const dateKey = `${month}-${dayStr}`;
    const data = dailyMap.get(dateKey)!;

    const income = Math.round(data.income * 100) / 100;
    const expense = Math.round(data.expense * 100) / 100;
    const net = Math.round((income - expense) * 100) / 100;

    totalMonthIncome += income;
    totalMonthExpense += expense;

    let status: CalendarDay["status"] = "neutral";
    if (net > 0) {
      status = "positive";
      positiveDaysCount++;
    } else if (net < 0) {
      status = "negative";
      negativeDaysCount++;
    } else {
      neutralDaysCount++;
    }

    const dayObj: CalendarDay = {
      date: dateKey,
      dayNumber: d,
      income,
      expense,
      net,
      status,
      txCount: data.count,
    };

    if (expense > maxExpense) {
      maxExpense = expense;
      peakExpenseDay = dayObj;
    }

    daysInMonth.push(dayObj);
  }

  return {
    month,
    daysInMonth,
    positiveDaysCount,
    negativeDaysCount,
    neutralDaysCount,
    peakExpenseDay,
    totalMonthIncome: Math.round(totalMonthIncome * 100) / 100,
    totalMonthExpense: Math.round(totalMonthExpense * 100) / 100,
  };
}
