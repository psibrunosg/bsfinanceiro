import { describe, expect, it } from "vitest";
import { computeHealthReport, type HealthIndicator } from "./health";

const MONTH = "2026-08-01";

let seq = 0;
const tx = (
  type: "income" | "expense",
  amount: number,
  competence_date: string,
  extra: Partial<{ category_id: string; description: string }> = {},
) => ({ id: `tx-${++seq}`, type, amount, competence_date, ...extra });

const byId = (report: HealthIndicator[], id: string) => {
  const found = report.find((item) => item.id === id);
  if (!found) throw new Error(`indicador ${id} ausente`);
  return found;
};

describe("computeHealthReport", () => {
  it("devolve números finitos com carteira vazia", () => {
    const report = computeHealthReport({ month: MONTH, transactions: [] });

    expect(report).toHaveLength(7);
    for (const indicator of report) {
      expect(Number.isFinite(indicator.value)).toBe(true);
      expect(indicator.value).toBe(0);
      expect(indicator.reading).not.toContain("NaN");
    }
  });

  it("não quebra com receita zero", () => {
    const report = computeHealthReport({
      month: MONTH,
      transactions: [tx("expense", 500, "2026-08-10")],
      commitments: [{ amount: 200 }],
    });

    expect(byId(report, "taxa-poupanca").value).toBe(0);
    expect(byId(report, "taxa-poupanca").status).toBe("critical");
    expect(byId(report, "comprometimento-fixo").value).toBe(0);
    expect(Number.isFinite(byId(report, "reserva").value)).toBe(true);
  });

  it("com um mês só de dados não inventa variação nem tendência", () => {
    const report = computeHealthReport({
      month: MONTH,
      transactions: [tx("income", 1000, "2026-08-05"), tx("expense", 400, "2026-08-06")],
      availableBalance: 1000,
    });

    expect(byId(report, "variacao-mensal").value).toBe(0);
    expect(byId(report, "variacao-mensal").reading).toContain("mês anterior");
    expect(byId(report, "burn-rate").value).toBeCloseTo(400 / 3, 6);
    expect(byId(report, "taxa-poupanca").value).toBeCloseTo(60, 6);
  });

  it("classifica a taxa de poupança nas três faixas", () => {
    const rate = (expense: number) =>
      byId(
        computeHealthReport({
          month: MONTH,
          transactions: [tx("income", 1000, "2026-08-05"), tx("expense", expense, "2026-08-06")],
        }),
        "taxa-poupanca",
      ).status;

    expect(rate(700)).toBe("good"); // 30%
    expect(rate(900)).toBe("attention"); // 10%
    expect(rate(990)).toBe("critical"); // 1%
  });

  it("classifica a reserva de emergência nas três faixas", () => {
    const reserve = (availableBalance: number) =>
      byId(
        computeHealthReport({
          month: MONTH,
          transactions: [tx("expense", 300, "2026-08-06")],
          availableBalance,
        }),
        "reserva",
      );

    // burn rate = 300 / 3 meses = 100/mês
    expect(reserve(700).value).toBeCloseTo(7, 6);
    expect(reserve(700).status).toBe("good");
    expect(reserve(400).status).toBe("attention");
    expect(reserve(100).status).toBe("critical");
  });

  it("classifica o comprometimento fixo nas três faixas", () => {
    const commitment = (amount: number) =>
      byId(
        computeHealthReport({
          month: MONTH,
          transactions: [tx("income", 1000, "2026-08-05")],
          commitments: [{ amount }],
        }),
        "comprometimento-fixo",
      ).status;

    expect(commitment(200)).toBe("good"); // 20%
    expect(commitment(450)).toBe("attention"); // 45%
    expect(commitment(800)).toBe("critical"); // 80%
  });

  it("mede concentração pela maior categoria do mês", () => {
    const categories = [
      { id: "c1", name: "Mercado", kind: "expense" },
      { id: "c2", name: "Lazer", kind: "expense" },
    ];
    const indicator = byId(
      computeHealthReport({
        month: MONTH,
        categories,
        transactions: [
          tx("expense", 800, "2026-08-02", { category_id: "c1" }),
          tx("expense", 200, "2026-08-03", { category_id: "c2" }),
        ],
      }),
      "concentracao",
    );

    expect(indicator.value).toBeCloseTo(80, 6);
    expect(indicator.status).toBe("critical");
    expect(indicator.reading).toContain("Mercado");
  });

  it("compara despesa do mês com a do mês anterior", () => {
    const report = computeHealthReport({
      month: MONTH,
      transactions: [tx("expense", 1200, "2026-08-04"), tx("expense", 1000, "2026-07-04")],
    });

    expect(byId(report, "variacao-mensal").value).toBeCloseTo(20, 6);
    expect(byId(report, "variacao-mensal").status).toBe("critical");
  });

  it("detecta tendência de alta nos últimos 6 meses", () => {
    const months = ["2026-03", "2026-04", "2026-05", "2026-06", "2026-07", "2026-08"];
    const report = computeHealthReport({
      month: MONTH,
      transactions: months.map((m, i) => tx("expense", 100 + i * 100, `${m}-10`)),
    });

    expect(byId(report, "tendencia-6-meses").value).toBeGreaterThan(5);
    expect(byId(report, "tendencia-6-meses").status).toBe("critical");
  });
});
