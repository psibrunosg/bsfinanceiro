import { describe, it, expect } from "vitest";
import { computeAnnualWrapped } from "./annual-wrapped";

describe("annual-wrapped", () => {
  it("computes annual metrics, savings rate, top categories and financial personality", () => {
    const txs = [
      { id: "1", description: "Salário Janeiro", amount: 10000, type: "income", competence_date: "2026-01-05" },
      { id: "2", description: "Aluguel Janeiro", amount: 3000, type: "expense", competence_date: "2026-01-10", category_name: "Moradia" },
      { id: "3", description: "Mercado Janeiro", amount: 2000, type: "expense", competence_date: "2026-01-15", category_name: "Alimentação" },
      { id: "4", description: "Salário Fevereiro", amount: 10000, type: "income", competence_date: "2026-02-05" },
      { id: "5", description: "Aluguel Fevereiro", amount: 3000, type: "expense", competence_date: "2026-02-10", category_name: "Moradia" },
    ];

    const res = computeAnnualWrapped(txs, 50000, 2026);

    expect(res.totalIncomeYear).toBe(20000);
    expect(res.totalExpenseYear).toBe(8000);
    expect(res.totalSavedYear).toBe(12000);
    expect(res.savingsRatePercent).toBe(60);
    expect(res.topCategories[0].categoryName).toBe("Moradia");
    expect(res.bestMonth?.monthName).toBe("Fevereiro");
    expect(res.financialPersonality.badgeTitle).toBeDefined();
  });
});
