import { describe, it, expect } from "vitest";
import {
  computeExpenseReviewMetrics,
  getReviewableTransactions,
} from "./expense-review";

describe("expense-review", () => {
  it("filters variable expenses for monthly review", () => {
    const txs = [
      { id: "1", description: "iFood Hamburgueria", amount: 120, type: "expense", competence_date: "2026-08-04" },
      { id: "2", description: "Aluguel", amount: 2500, type: "expense", competence_date: "2026-08-05" }, // Fixo
      { id: "3", description: "Zara Camisa", amount: 280, type: "expense", competence_date: "2026-08-10" },
    ];

    const reviewable = getReviewableTransactions(txs, "2026-08");
    expect(reviewable).toHaveLength(2);
  });

  it("calculates satisfaction rate, regretted money, and top regret category", () => {
    const items = [
      { id: "1", description: "iFood", amount: 150, category: "Alimentação", rating: "regretted" as const },
      { id: "2", description: "Balada", amount: 200, category: "Lazer", rating: "regretted" as const },
      { id: "3", description: "Livro de Psicologia", amount: 100, category: "Educação", rating: "liked" as const },
      { id: "4", description: "Viagem Praia", amount: 550, category: "Lazer", rating: "liked" as const },
    ];

    const res = computeExpenseReviewMetrics(items);

    expect(res.totalRegrettedAmount).toBe(350); // 150 + 200
    expect(res.totalLikedAmount).toBe(650);     // 100 + 550
    expect(res.satisfactionRatePercent).toBe(65); // 650 / 1000 = 65%
    expect(res.topRegretCategory).toBe("Lazer");
  });
});
