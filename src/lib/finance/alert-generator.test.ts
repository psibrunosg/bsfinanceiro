import { describe, expect, it } from "vitest";
import { generateAllAlerts } from "./alert-generator";

describe("generateAllAlerts", () => {
  it("generates budget alerts at 80% and 100%", () => {
    const today = new Date("2026-09-02T10:00:00Z");
    const transactions = [
      { id: "1", amount: 80, type: "expense", category_id: "c1", competence_date: "2026-09-01" },
      { id: "2", amount: 100, type: "expense", category_id: "c2", competence_date: "2026-09-01" },
    ];
    const budgets = [
      { id: "b1", category_id: "c1", amount: 100 },
      { id: "b2", category_id: "c2", amount: 100 },
    ];

    const alerts = generateAllAlerts([], transactions, [], [], [], budgets, today);

    expect(alerts).toHaveLength(2);
    expect(alerts.find(a => a.id === "budget-80-b1")).toBeDefined();
    expect(alerts.find(a => a.id === "budget-100-b2")).toBeDefined();
  });

  it("generates invoice alerts 3 days before due", () => {
    const today = new Date("2026-09-02T10:00:00Z");
    const invoices = [
      { id: "i1", credit_card_installments: [{amount: 500}], due_date: "2026-09-05", status: "open" },
      { id: "i2", credit_card_installments: [{amount: 500}], due_date: "2026-09-10", status: "open" },
    ];

    const alerts = generateAllAlerts([], [], invoices, [], [], [], today);

    expect(alerts).toHaveLength(1);
    expect(alerts[0].id).toBe("invoice-due-i1");
  });

  it("generates goal completion alerts", () => {
    const today = new Date("2026-09-02T10:00:00Z");
    const goals = [
      { id: "g1", name: "Carro", target_amount: 10000, current_amount: 10000 },
      { id: "g2", name: "Casa", target_amount: 100000, current_amount: 50000 },
    ];

    const alerts = generateAllAlerts([], [], [], [], goals, [], today);

    expect(alerts).toHaveLength(1);
    expect(alerts[0].id).toBe("goal-reached-g1");
  });
});
