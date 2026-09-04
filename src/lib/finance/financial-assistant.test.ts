import { describe, it, expect } from "vitest";
import {
  askFinancialAssistant,
  type FinancialAssistantData,
} from "./financial-assistant";

describe("Financial Assistant (Fase 12)", () => {
  const sampleData: FinancialAssistantData = {
    accounts: [
      { id: "acc-1", name: "Nubank", type: "checking", initial_balance: 1500 },
      { id: "acc-2", name: "Itaú", type: "checking", initial_balance: 3200 },
    ],
    categories: [
      { id: "cat-1", name: "Alimentação" },
      { id: "cat-2", name: "Transporte" },
      { id: "cat-3", name: "Lazer" },
    ],
    transactions: [
      {
        id: "tx-1",
        description: "iFood Delivery",
        amount: 85.5,
        type: "expense",
        competence_date: "2026-08-05",
        category_id: "cat-1",
      },
      {
        id: "tx-2",
        description: "Supermercado Zaffari",
        amount: 320.0,
        type: "expense",
        competence_date: "2026-08-12",
        category_id: "cat-1",
      },
      {
        id: "tx-3",
        description: "Uber Viagem",
        amount: 34.2,
        type: "expense",
        competence_date: "2026-08-14",
        category_id: "cat-2",
      },
      {
        id: "tx-4",
        description: "Salário Empresa",
        amount: 6000.0,
        type: "income",
        competence_date: "2026-08-01",
      },
    ],
    commitments: [
      {
        id: "com-1",
        description: "Aluguel",
        amount: 1800,
        due_day: 10,
      },
      {
        id: "com-2",
        description: "Internet Fibra",
        amount: 120,
        due_day: 20,
      },
    ],
    referenceDate: "2026-08-15",
  };

  it("answers category expense queries like 'quanto gastei com alimentação'", () => {
    const res = askFinancialAssistant("Quanto gastei com alimentação?", sampleData);
    expect(res.text).toContain("Alimentação");
    expect(res.text).toContain("405,50");
    expect(res.matchedTransactions?.length).toBe(2);
  });

  it("answers search term queries like 'quanto gastei com ifood' or 'delivery'", () => {
    const res = askFinancialAssistant("Quanto gastei com iFood?", sampleData);
    expect(res.text).toContain("85,50");
    expect(res.matchedTransactions?.length).toBe(1);
  });

  it("answers queries about biggest expenses 'qual meu maior gasto'", () => {
    const res = askFinancialAssistant("Qual foi meu maior gasto?", sampleData);
    expect(res.text).toContain("Supermercado Zaffari");
    expect(res.text).toContain("320,00");
  });

  it("answers balance and cash questions 'qual meu saldo'", () => {
    const res = askFinancialAssistant("Qual é o meu saldo total?", sampleData);
    expect(res.text).toContain("Nubank");
    expect(res.text).toContain("Itaú");
    expect(res.text).toContain("4.700,00");
  });

  it("answers upcoming bill questions 'quais contas vencem em breve'", () => {
    const res = askFinancialAssistant("O que vence nos próximos dias?", sampleData);
    expect(res.text).toContain("Internet Fibra");
    expect(res.text).toContain("120,00");
  });

  it("provides helpful suggestions with chips when query is not understood", () => {
    const res = askFinancialAssistant("abracadabra xyz", sampleData);
    expect(res.chips?.length).toBeGreaterThan(0);
    expect(res.text).toContain("Não compreendi");
  });
});
