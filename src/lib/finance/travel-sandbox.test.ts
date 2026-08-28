import { describe, it, expect } from "vitest";
import {
  computeTravelSandbox,
  TravelTrip,
} from "./travel-sandbox";

describe("travel-sandbox", () => {
  it("calculates travel budget consumption, daily burn rate, and isolated statistics", () => {
    const trip: TravelTrip = {
      id: "trip-1",
      destination: "Férias em Gramado",
      budgetBrl: 6000,
      startDate: "2026-07-10",
      endDate: "2026-07-16", // 7 dias
      expenses: [
        { id: "e1", description: "Hotel Ritta Höppner", amount: 2800, category: "Hospedagem", date: "2026-07-10" },
        { id: "e2", description: "Jantar Fondue", amount: 450, category: "Alimentação", date: "2026-07-11" },
        { id: "e3", description: "Passeio Snowland", amount: 650, category: "Passeios", date: "2026-07-12" },
      ],
    };

    const res = computeTravelSandbox(trip);

    expect(res.totalDays).toBe(7);
    expect(res.totalSpentBrl).toBe(3900);
    expect(res.remainingBrl).toBe(2100);
    expect(res.spentPercent).toBe(65);
    expect(res.dailyBudgetBrl).toBe(857.14);
    expect(res.averageDailySpentBrl).toBe(557.14);
    expect(res.status).toBe("under_budget");
  });

  it("handles multi-currency travel expenses with exchange rate conversion", () => {
    const trip: TravelTrip = {
      id: "trip-2",
      destination: "Viagem a Paris",
      budgetBrl: 20000,
      startDate: "2026-09-01",
      endDate: "2026-09-10", // 10 dias
      expenses: [
        { id: "e1", description: "Hotel Paris", amount: 1200, currency: "EUR", exchangeRate: 6.0, category: "Hospedagem", date: "2026-09-01" }, // 7200 BRL
        { id: "e2", description: "Jantar Bistrô", amount: 150, currency: "EUR", exchangeRate: 6.0, category: "Alimentação", date: "2026-09-02" },  // 900 BRL
      ],
    };

    const res = computeTravelSandbox(trip);

    expect(res.totalSpentBrl).toBe(8100); // 7200 + 900
    expect(res.remainingBrl).toBe(11900);
  });
});
