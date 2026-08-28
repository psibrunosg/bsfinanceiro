import { describe, it, expect } from "vitest";
import {
  calculateHoursOfLife,
  computeWishlistMetrics,
} from "./impulse-calculator";

describe("impulse-calculator", () => {
  describe("calculateHoursOfLife", () => {
    it("converts product price into working hours and days of life", () => {
      // Renda de R$ 8.000/mês para 160h/mês = R$ 50/hora. Produto de R$ 1.000 = 20h = 2.5 dias
      const res = calculateHoursOfLife({
        price: 1000,
        monthlyIncome: 8000,
        workHoursPerMonth: 160,
      });

      expect(res.hourlyWage).toBe(50);
      expect(res.hoursRequired).toBe(20);
      expect(res.workDaysRequired).toBe(2.5);
      expect(res.futureValue5Years).toBeGreaterThan(1700);
      expect(res.interestEarned5Years).toBeGreaterThan(700);
    });
  });

  describe("computeWishlistMetrics", () => {
    it("computes total money saved from impulse dismissals and active cooling-off items", () => {
      const items = [
        { id: "1", name: "Jaqueta de Couro", price: 600, status: "dismissed_saved" as const, createdAt: "2026-08-01" },
        { id: "2", name: "Fone Bluetooth", price: 400, status: "dismissed_saved" as const, createdAt: "2026-08-10" },
        { id: "3", name: "Monitor Gamer", price: 1800, status: "cooling_off" as const, createdAt: "2026-08-27" },
        { id: "4", name: "Tênis Corrida", price: 500, status: "purchased" as const, createdAt: "2026-08-15" },
      ];

      const metrics = computeWishlistMetrics(items);
      expect(metrics.totalSavedByDismissal).toBe(1000); // 600 + 400
      expect(metrics.activeCoolingOffCount).toBe(1);
    });
  });
});
