import { describe, it, expect } from "vitest";
import { computeFinancialCalendar } from "./financial-calendar";

describe("financial-calendar", () => {
  it("computes daily flow, positive/negative days and identifies peak expense day", () => {
    const txs = [
      { id: "1", description: "Salário / Consultas", amount: 6000, type: "income", competence_date: "2026-08-05" },
      { id: "2", description: "Aluguel Consultório", amount: 2500, type: "expense", competence_date: "2026-08-08" },
      { id: "3", description: "Supermercado", amount: 450, type: "expense", competence_date: "2026-08-08" },
      { id: "4", description: "Restaurante", amount: 150, type: "expense", competence_date: "2026-08-15" },
    ];

    const res = computeFinancialCalendar(txs, "2026-08");

    expect(res.daysInMonth).toHaveLength(31); // Agosto tem 31 dias
    expect(res.positiveDaysCount).toBe(1);    // Dia 05 (+6000)
    expect(res.negativeDaysCount).toBe(2);    // Dia 08 (-2950) e Dia 15 (-150)
    expect(res.peakExpenseDay?.dayNumber).toBe(8);
    expect(res.peakExpenseDay?.expense).toBe(2950);
  });
});
