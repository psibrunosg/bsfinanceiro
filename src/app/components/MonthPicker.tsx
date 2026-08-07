"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import { useMonth } from "./MonthContext";

/** Month navigator backed by the native <input type="month"> — no date picker lib. */
export function MonthPicker() {
  const { month, shiftMonth, setMonth } = useMonth();

  return (
    <div className="month-picker">
      <button type="button" onClick={() => shiftMonth(-1)} aria-label="Mês anterior">
        <ChevronLeft aria-hidden="true" size={18} />
      </button>
      <input
        type="month"
        value={month.slice(0, 7)}
        aria-label="Mês de referência"
        onChange={(event) => {
          if (event.target.value) setMonth(`${event.target.value}-01`);
        }}
      />
      <button type="button" onClick={() => shiftMonth(1)} aria-label="Próximo mês">
        <ChevronRight aria-hidden="true" size={18} />
      </button>
    </div>
  );
}
