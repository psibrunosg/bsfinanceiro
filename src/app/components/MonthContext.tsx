"use client";

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { addMonths, monthLabel, monthStartsForSaoPauloDate, todayInSaoPaulo } from "@/lib/finance/local-date";

const STORAGE_KEY = "bsfinanceiro:selected-month";

export function currentMonthStart(): string {
  return monthStartsForSaoPauloDate(todayInSaoPaulo())[0];
}

type MonthContextValue = {
  /** `YYYY-MM-01` of the selected month. */
  month: string;
  /** `YYYY-MM-01` of the following month — the exclusive end of the range. */
  nextMonth: string;
  /** `ago/2026` */
  label: string;
  setMonth: (month: string) => void;
  shiftMonth: (delta: number) => void;
  isCurrentMonth: boolean;
};

const MonthContext = createContext<MonthContextValue | null>(null);

export function MonthProvider({ children }: { children: React.ReactNode }) {
  const [month, setMonthState] = useState(currentMonthStart);

  // Restore after mount so server and first client render agree.
  useEffect(() => {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (stored && /^\d{4}-\d{2}-01$/.test(stored)) setMonthState(stored);
  }, []);

  const setMonth = useCallback((next: string) => {
    setMonthState(next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // ponytail: private mode / quota — selection just won't persist.
    }
  }, []);

  const value = useMemo<MonthContextValue>(() => ({
    month,
    nextMonth: addMonths(month, 1),
    label: monthLabel(month),
    setMonth,
    shiftMonth: (delta: number) => setMonth(addMonths(month, delta)),
    isCurrentMonth: month === currentMonthStart(),
  }), [month, setMonth]);

  return <MonthContext.Provider value={value}>{children}</MonthContext.Provider>;
}

export function useMonth(): MonthContextValue {
  const value = useContext(MonthContext);
  if (!value) throw new Error("useMonth precisa estar dentro de <MonthProvider>");
  return value;
}
