import { describe, it, expect } from "vitest";
import {
  computeZeroBasedBudget,
  transferBetweenEnvelopes,
  BudgetEnvelope,
} from "./zero-based-budget";

describe("zero-based-budget", () => {
  it("allocates income into envelopes, tracks spending, and calculates remaining per envelope", () => {
    const totalIncome = 10000;
    const initialEnvelopes: BudgetEnvelope[] = [
      { id: "env-1", name: "Moradia", allocated: 3500, spent: 3200, category: "Moradia" },
      { id: "env-2", name: "Alimentação", allocated: 2000, spent: 2150, category: "Alimentação" }, // Estourado
      { id: "env-3", name: "Lazer", allocated: 1500, spent: 800, category: "Lazer" },
      { id: "env-4", name: "Investimentos", allocated: 2000, spent: 2000, category: "Investimentos" },
    ];

    const res = computeZeroBasedBudget({
      monthlyIncome: totalIncome,
      envelopes: initialEnvelopes,
    });

    expect(res.totalAllocated).toBe(9000);
    expect(res.unallocatedAmount).toBe(1000); // 10000 - 9000
    expect(res.overspentEnvelopesCount).toBe(1); // Alimentação estourou 150
    expect(res.isFullyAllocated).toBe(false);

    const alimEnv = res.envelopesWithMetrics.find((e) => e.name === "Alimentação");
    expect(alimEnv?.remaining).toBe(-150);
    expect(alimEnv?.isOverspent).toBe(true);
    expect(alimEnv?.spentPercent).toBe(107.5);
  });

  it("allows transferring budget between envelopes to cover overspending", () => {
    const envelopes: BudgetEnvelope[] = [
      { id: "env-1", name: "Lazer", allocated: 1500, spent: 800, category: "Lazer" },
      { id: "env-2", name: "Alimentação", allocated: 2000, spent: 2150, category: "Alimentação" },
    ];

    const updated = transferBetweenEnvelopes(envelopes, "env-1", "env-2", 150);

    const lazer = updated.find((e) => e.id === "env-1")!;
    const alim = updated.find((e) => e.id === "env-2")!;

    expect(lazer.allocated).toBe(1350);
    expect(alim.allocated).toBe(2150);
  });
});
