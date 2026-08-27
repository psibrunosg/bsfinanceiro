import { describe, it, expect } from "vitest";
import {
  detectSubscriptions,
  computeSubscriptionMetrics,
  simulateSubscriptionCancellationSavings,
} from "./subscriptions";

describe("subscriptions", () => {
  describe("detectSubscriptions", () => {
    it("detects known subscriptions from transactions and commitments", () => {
      const txs = [
        {
          id: "tx-1",
          description: "NETFLIX.COM SAO PAULO BRA",
          amount: 55.9,
          competence_date: "2026-08-10",
        },
        {
          id: "tx-2",
          description: "Spotify Premium Individual",
          amount: 21.9,
          competence_date: "2026-08-15",
        },
        {
          id: "tx-3",
          description: "Supermercado Pão de Açúcar",
          amount: 140.0,
          competence_date: "2026-08-18",
        },
        {
          id: "tx-4",
          description: "OPENAI *CHATGPT SUBSCRIPTION",
          amount: 110.0,
          competence_date: "2026-08-20",
        },
      ];

      const commitments = [
        {
          id: "c-1",
          description: "Academia Smart Fit",
          amount: 129.9,
          due_day: 5,
        },
      ];

      const subs = detectSubscriptions(txs, commitments);
      expect(subs).toHaveLength(4); // Netflix, Spotify, ChatGPT, Smart Fit
      expect(subs.find((s) => s.serviceKey === "netflix")).toBeDefined();
      expect(subs.find((s) => s.serviceKey === "spotify")).toBeDefined();
      expect(subs.find((s) => s.serviceKey === "chatgpt")).toBeDefined();
      expect(subs.find((s) => s.serviceKey === "smartfit")).toBeDefined();
    });
  });

  describe("computeSubscriptionMetrics", () => {
    it("calculates monthly total, annualized cost, and upcoming renewals", () => {
      const subs: import("./subscriptions").DetectedSubscription[] = [
        {
          id: "sub-1",
          name: "Netflix",
          serviceKey: "netflix",
          monthlyAmount: 55.9,
          dueDay: 10,
          category: "streaming",
        },
        {
          id: "sub-2",
          name: "Spotify",
          serviceKey: "spotify",
          monthlyAmount: 21.9,
          dueDay: 15,
          category: "music",
        },
        {
          id: "sub-3",
          name: "Smart Fit",
          serviceKey: "smartfit",
          monthlyAmount: 129.9,
          dueDay: 5,
          category: "health_fitness",
        },
      ];

      // Se hoje é dia 08, a do dia 10 (Netflix) vence em 2 dias (próxima)
      const metrics = computeSubscriptionMetrics(subs, 8);
      expect(metrics.totalMonthly).toBeCloseTo(207.7, 2);
      expect(metrics.annualizedCost).toBeCloseTo(2492.4, 2); // 207.7 * 12
      expect(metrics.activeCount).toBe(3);
      expect(metrics.mostExpensive?.name).toBe("Smart Fit");
      expect(metrics.upcomingRenewals.length).toBeGreaterThan(0);
      expect(metrics.upcomingRenewals[0].name).toBe("Netflix");
    });
  });

  describe("simulateSubscriptionCancellationSavings", () => {
    it("calculates future value if monthly subscription cost is invested in CDI", () => {
      // Cancelar Netflix (R$ 55.90/mês) e investir a 12% a.a. por 5 anos
      const res = simulateSubscriptionCancellationSavings({
        monthlyCost: 55.9,
        annualRatePercent: 12,
        years: 5,
      });

      expect(res.totalSavedNominal).toBeCloseTo(3354, 0); // 55.9 * 60
      expect(res.totalWithCompoundInterest).toBeGreaterThan(4400);
      expect(res.extraInterestGained).toBeGreaterThan(1000);
    });
  });
});
