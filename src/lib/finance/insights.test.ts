import { describe, expect, test } from "vitest";
import { generateInsights } from "./insights";

const tx = (overrides: Partial<{ type: string; amount: string | number; competence_date: string; category_id: string | null }>) =>
  ({ id: "tx-1", type: "expense", amount: "100", competence_date: "2026-07-15", category_id: "cat-1", ...overrides });

const cat = (overrides: Partial<{ id: string; name: string; kind: string }>) =>
  ({ id: "cat-1", name: "Alimentação", kind: "expense", ...overrides });

const account = (overrides: Partial<{ id: string; name: string; initial_balance: number }>) =>
  ({ id: "acc-1", name: "Corrente", initial_balance: 5000, ...overrides });

describe("generateInsights", () => {
  test("retorna insights quando há dados", () => {
    const transactions = [
      tx({ type: "expense", amount: "200", competence_date: "2026-07-10" }),
      tx({ type: "income", amount: "3000", competence_date: "2026-07-10" }),
    ];
    const categories = [cat({})];
    const accounts = [account({})];

    const insights = generateInsights(transactions, categories, accounts, "2026-07-01");
    expect(insights.length).toBeGreaterThan(0);
  });

  test("insight variação período quando há dados suficientes", () => {
    const transactions = [
      tx({ amount: "500", competence_date: "2026-07-05" }),
      tx({ amount: "300", competence_date: "2026-06-05" }),
    ];
    const insights = generateInsights(transactions, [], [], "2026-07-01");
    const variation = insights.find((i) => i.id === "period-variation");
    // 500 vs 300 = 66% increase
    expect(variation).toBeTruthy();
    expect(variation!.text).toContain("aumentaram");
  });

  test("insight maior categoria", () => {
    const transactions = [
      tx({ category_id: "cat-1", amount: "300", competence_date: "2026-07-10" }),
      tx({ category_id: "cat-2", amount: "100", competence_date: "2026-07-10" }),
    ];
    const categories = [cat({ id: "cat-1", name: "Alimentação" }), cat({ id: "cat-2", name: "Transporte" })];
    const insights = generateInsights(transactions, categories, [], "2026-07-01");
    const topCat = insights.find((i) => i.id === "top-category");
    expect(topCat).toBeTruthy();
    expect(topCat!.text).toContain("Alimentação");
  });

  test("insight despesas altas vs receitas (>100%)", () => {
    const transactions = [
      tx({ amount: "1500", competence_date: "2026-07-10" }),
      tx({ type: "income", amount: "1000", competence_date: "2026-07-10" }),
    ];
    const insights = generateInsights(transactions, [], [], "2026-07-01");
    const high = insights.find((i) => i.id === "expense-ratio-high");
    expect(high).toBeTruthy();
    expect(high!.icon).toBe("⚠️");
  });

  test("insight despesas baixas vs receitas", () => {
    const transactions = [
      tx({ amount: "300", competence_date: "2026-07-10" }),
      tx({ type: "income", amount: "5000", competence_date: "2026-07-10" }),
    ];
    const insights = generateInsights(transactions, [], [], "2026-07-01");
    const low = insights.find((i) => i.id === "expense-ratio-low");
    expect(low).toBeTruthy();
    expect(low!.icon).toBe("✅");
  });

  test("retorna vazio sem dados", () => {
    const insights = generateInsights([], [], [], "2026-07-01");
    expect(insights).toHaveLength(0);
  });

  test("limita a 4 insights", () => {
    const transactions = Array.from({ length: 20 }, (_, i) =>
      tx({ amount: `${(i + 1) * 100}`, category_id: `cat-${i}`, competence_date: `2026-07-${String(i + 1).padStart(2, "0")}` }),
    );
    const categories = Array.from({ length: 20 }, (_, i) => cat({ id: `cat-${i}`, name: `Cat ${i}` }));
    const accounts = [account({})];
    const insights = generateInsights(transactions, categories, accounts, "2026-07-01");
    expect(insights.length).toBeLessThanOrEqual(4);
  });
});
