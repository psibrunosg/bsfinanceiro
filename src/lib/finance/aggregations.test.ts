import { describe, expect, test } from "vitest";
import {
  aggregateExpensesByCategory,
  aggregateIncomeBySource,
  computeEvolution,
  computeMonthlyFlow,
  lastNMonths,
  calculateNetCashFlowExcludingTransfers,
} from "./aggregations";

let txIdCounter = 1;
const tx = (overrides: Partial<Parameters<typeof aggregateExpensesByCategory>[0][number]>) =>
  ({
    id: `tx-${txIdCounter++}`,
    type: "expense" as const,
    amount: "100",
    competence_date: "2026-07-15",
    category_id: "cat-1",
    ...overrides,
  });

const cat = (overrides: Partial<{ id: string; name: string; kind: "income" | "expense" }>) =>
  ({ id: "cat-1", name: "Alimentação", kind: "expense" as const, ...overrides });

describe("aggregateExpensesByCategory", () => {
  test("agrupa por categoria e ordena por valor", () => {
    const transactions = [
      tx({ category_id: "cat-1", amount: "500", competence_date: "2026-07-10" }),
      tx({ category_id: "cat-1", amount: "300", competence_date: "2026-07-20" }),
      tx({ category_id: "cat-2", amount: "200", competence_date: "2026-07-15" }),
    ];
    const categories = [cat({ id: "cat-1", name: "Alimentação" }), cat({ id: "cat-2", name: "Transporte" })];

    const result = aggregateExpensesByCategory(transactions, categories, "2026-07-01");

    expect(result).toEqual([
      { label: "Alimentação", value: 800 },
      { label: "Transporte", value: 200 },
    ]);
  });

  test("filtra por mês", () => {
    const transactions = [
      tx({ competence_date: "2026-06-15", amount: "100" }),
      tx({ competence_date: "2026-07-15", amount: "200" }),
    ];
    const categories = [cat({})];

    const result = aggregateExpensesByCategory(transactions, categories, "2026-07-01");

    expect(result).toEqual([{ label: "Alimentação", value: 200 }]);
  });

  test("ignora receitas e transfere", () => {
    const transactions = [
      tx({ type: "expense", amount: "100" }),
      tx({ type: "income", amount: "500", category_id: null }),
      tx({ type: "transfer", amount: "300", category_id: null }),
      tx({ type: "expense", amount: "400", is_transfer: true }),
    ];
    const categories = [cat({})];

    const result = aggregateExpensesByCategory(transactions, categories, "2026-01-01");

    expect(result).toEqual([{ label: "Alimentação", value: 100 }]);
  });

  test("limita a topN resultados", () => {
    const transactions = Array.from({ length: 10 }, (_, i) =>
      tx({ category_id: `cat-${i}`, amount: `${(10 - i) * 100}` }),
    );
    const categories = Array.from({ length: 10 }, (_, i) =>
      cat({ id: `cat-${i}`, name: `Cat ${i}` }),
    );

    const result = aggregateExpensesByCategory(transactions, categories, "2026-01-01", 3);

    expect(result).toHaveLength(3);
    expect(result[0].label).toBe("Cat 0");
  });

  test("retorna vazio quando não há despesas", () => {
    const result = aggregateExpensesByCategory([], [], "2026-07-01");
    expect(result).toEqual([]);
  });
});

describe("computeMonthlyFlow", () => {
  test("calcula entradas e saídas por mês ignorando transferências por padrão", () => {
    const transactions = [
      tx({ id: "m1", type: "income", amount: "3000", competence_date: "2026-07-10" }),
      tx({ id: "m2", type: "expense", amount: "1500", competence_date: "2026-07-15" }),
      tx({ id: "m3", type: "expense", amount: "5000", competence_date: "2026-07-20", is_transfer: true }),
      tx({ id: "m4", type: "income", amount: "5000", competence_date: "2026-07-20", is_transfer: true }),
    ];
    const months = [new Date(2026, 6, 1)]; // July 2026

    const result = computeMonthlyFlow(transactions, months);

    expect(result.flowIn).toEqual([3000]);
    expect(result.flowOut).toEqual([1500]);
  });

  test("ignora meses sem movimentação", () => {
    const transactions = [tx({ type: "income", amount: "1000", competence_date: "2026-07-10" })];
    const months = [new Date(2026, 5, 1), new Date(2026, 6, 1)]; // Jun, Jul

    const result = computeMonthlyFlow(transactions, months);

    expect(result.flowIn).toEqual([0, 1000]);
    expect(result.flowOut).toEqual([0, 0]);
  });
});

describe("computeEvolution", () => {
  test("começa do saldo inicial e acumula", () => {
    const transactions = [
      tx({ type: "income", amount: "1000", competence_date: "2026-06-15" }),
      tx({ type: "expense", amount: "400", competence_date: "2026-07-10" }),
    ];
    const months = [new Date(2026, 5, 1), new Date(2026, 6, 1)];

    const result = computeEvolution(transactions, 500, months);

    expect(result).toEqual([1500, 1100]);
  });
});

describe("lastNMonths", () => {
  test("retorna n meses com labels", () => {
    const { months, labels } = lastNMonths(3);

    expect(months).toHaveLength(3);
    expect(labels).toHaveLength(3);
    expect(typeof labels[0]).toBe("string");
  });
});

describe("aggregateIncomeBySource", () => {
  test("agrupa receitas por categoria e ignora transferências", () => {
    const transactions = [
      tx({ type: "income", amount: "5000", category_id: "inc-1" }),
      tx({ type: "income", amount: "2000", category_id: "inc-2" }),
      tx({ type: "income", amount: "4000", category_id: "inc-1", is_transfer: true }),
    ];
    const categories = [
      cat({ id: "inc-1", name: "Contracheques", kind: "income" }),
      cat({ id: "inc-2", name: "Pacientes", kind: "income" }),
    ];

    const result = aggregateIncomeBySource(transactions, categories);

    expect(result.labels).toEqual(["Contracheques", "Pacientes"]);
    expect(result.values).toEqual([5000, 2000]);
  });

  test("agrupa como 'Outras receitas' quando não há categorias de receita", () => {
    const transactions = [tx({ type: "income", amount: "3000", category_id: null })];
    const categories = [cat({ kind: "expense" })];

    const result = aggregateIncomeBySource(transactions, categories);

    expect(result.labels).toEqual(["Outras receitas"]);
    expect(result.values).toEqual([3000]);
  });

  test("retorna vazio quando não há receitas", () => {
    const result = aggregateIncomeBySource([], []);
    expect(result.labels).toEqual([]);
    expect(result.values).toEqual([]);
  });
});

describe("calculateNetCashFlowExcludingTransfers", () => {
  test("calcula fluxo de caixa líquido neutralizando transferências intercontas", () => {
    const transactions = [
      tx({ id: "flow-1", type: "income", amount: "12000", competence_date: "2026-07-01", description: "Faturamento clinica" }),
      tx({ id: "flow-2", type: "expense", amount: "4000", competence_date: "2026-07-05", description: "Fornecedores" }),
      tx({ id: "flow-3", type: "expense", amount: "5000", competence_date: "2026-07-10", description: "Transferencia para PF", is_transfer: true }),
    ];

    const summary = calculateNetCashFlowExcludingTransfers(transactions);

    expect(summary.totalIncome).toBe(12000);
    expect(summary.totalExpense).toBe(4000);
    expect(summary.netCashFlow).toBe(8000);
    expect(summary.transferVolume).toBe(5000);
  });
});
