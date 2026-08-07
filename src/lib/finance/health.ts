/**
 * "Exame de sangue" financeiro: indicadores derivados dos lançamentos,
 * cada um com valor, faixa de referência, status e leitura em português.
 * Puro — sem React, sem Supabase. Transferências entre contas são neutralizadas.
 */

import { addMonths } from "./local-date";
import { filterOutTransfers, type CategoryInfo, type TransferTransaction } from "./transfers";

export type HealthStatus = "good" | "attention" | "critical";

export type HealthIndicator = {
  id: string;
  label: string;
  group: "liquidez" | "fluxo" | "estrutura";
  value: number;
  unit: "BRL" | "percent" | "months" | "ratio";
  reference: string;
  status: HealthStatus;
  reading: string;
};

export type HealthInput = {
  /** `YYYY-MM-01` do mês analisado. */
  month: string;
  transactions: TransferTransaction[];
  categories?: CategoryInfo[];
  /** Compromissos fixos ativos (fixed_commitments). */
  commitments?: { amount: number | string }[];
  /** Saldo disponível em conta (reais). */
  availableBalance?: number;
};

/** Divisão que nunca devolve NaN nem Infinity. */
const safeDiv = (numerator: number, denominator: number) => {
  const result = numerator / denominator;
  return Number.isFinite(result) ? result : 0;
};

const finite = (value: number) => (Number.isFinite(value) ? value : 0);

/** good/attention conforme o valor fica ABAIXO dos limites (quanto menor, melhor). */
const atMost = (value: number, good: number, attention: number): HealthStatus =>
  value <= good ? "good" : value <= attention ? "attention" : "critical";

/** good/attention conforme o valor fica ACIMA dos limites (quanto maior, melhor). */
const atLeast = (value: number, good: number, attention: number): HealthStatus =>
  value >= good ? "good" : value >= attention ? "attention" : "critical";

const pct = (value: number) => `${value.toFixed(1).replace(".", ",")}%`;

type MonthTotals = { income: number; expense: number };

function totalsByMonth(transactions: TransferTransaction[]): Map<string, MonthTotals> {
  const map = new Map<string, MonthTotals>();
  for (const tx of transactions) {
    const key = String(tx.competence_date ?? "").slice(0, 7);
    if (key.length !== 7) continue;
    const totals = map.get(key) ?? { income: 0, expense: 0 };
    const amount = Math.abs(finite(Number(tx.amount)));
    if (tx.type === "income") totals.income += amount;
    else if (tx.type === "expense") totals.expense += amount;
    map.set(key, totals);
  }
  return map;
}

const monthKeysBack = (month: string, count: number, offset = 0) =>
  Array.from({ length: count }, (_, i) => addMonths(month, -(offset + i)).slice(0, 7));

const average = (values: number[]) => safeDiv(values.reduce((sum, v) => sum + v, 0), values.length);

export function computeHealthReport(input: HealthInput): HealthIndicator[] {
  const { month, categories = [], commitments = [], availableBalance = 0 } = input;
  const transactions = filterOutTransfers(input.transactions ?? [], categories);
  const byMonth = totalsByMonth(transactions);
  const totalsOf = (key: string) => byMonth.get(key) ?? { income: 0, expense: 0 };

  const monthKey = month.slice(0, 7);
  const current = totalsOf(monthKey);
  const previous = totalsOf(addMonths(month, -1).slice(0, 7));

  // Taxa de poupança
  const savingsRate = safeDiv(current.income - current.expense, current.income) * 100;

  // Burn rate: média das despesas dos últimos 3 meses (inclui o mês analisado)
  const burnRate = average(monthKeysBack(month, 3).map((key) => totalsOf(key).expense));
  const previousBurnRate = average(monthKeysBack(month, 3, 3).map((key) => totalsOf(key).expense));
  const burnGrowth = safeDiv(burnRate - previousBurnRate, previousBurnRate) * 100;

  // Reserva de emergência
  const reserveMonths = safeDiv(Math.max(0, availableBalance), burnRate);

  // Comprometimento fixo
  const commitmentsTotal = commitments.reduce((sum, item) => sum + Math.abs(finite(Number(item.amount))), 0);
  const commitmentRate = safeDiv(commitmentsTotal, current.income) * 100;

  // Concentração de gastos: maior categoria do mês
  const categoryName = new Map(categories.map((c) => [c.id, c.name]));
  const monthExpenses = transactions.filter(
    (tx) => tx.type === "expense" && String(tx.competence_date ?? "").slice(0, 7) === monthKey,
  );
  const byCategory = new Map<string, number>();
  for (const tx of monthExpenses) {
    const key = tx.category_name || categoryName.get(String(tx.category_id ?? "")) || "Sem categoria";
    byCategory.set(key, (byCategory.get(key) ?? 0) + Math.abs(finite(Number(tx.amount))));
  }
  let topCategory = "";
  let topCategoryValue = 0;
  for (const [name, value] of byCategory) {
    if (value > topCategoryValue) {
      topCategory = name;
      topCategoryValue = value;
    }
  }
  const concentration = safeDiv(topCategoryValue, current.expense) * 100;

  // Variação mensal
  const variation = safeDiv(current.expense - previous.expense, previous.expense) * 100;

  // Tendência 6 meses: inclinação da regressão linear das despesas mensais,
  // expressa como % da média mensal.
  const series = monthKeysBack(month, 6).reverse().map((key) => totalsOf(key).expense);
  const meanX = (series.length - 1) / 2;
  const meanY = average(series);
  const covariance = series.reduce((sum, y, x) => sum + (x - meanX) * (y - meanY), 0);
  const varianceX = series.reduce((sum, _y, x) => sum + (x - meanX) ** 2, 0);
  const slope = safeDiv(covariance, varianceX);
  const trend = safeDiv(slope, meanY) * 100;

  return [
    {
      id: "reserva",
      label: "Reserva de emergência",
      group: "liquidez",
      value: finite(reserveMonths),
      unit: "months",
      reference: "acima de 6 meses",
      status: atLeast(reserveMonths, 6, 3),
      reading: burnRate === 0
        ? "Sem despesas registradas nos últimos 3 meses: não dá para estimar sua reserva."
        : `Seu saldo disponível cobre ${reserveMonths.toFixed(1).replace(".", ",")} meses no ritmo atual de gastos.`,
    },
    {
      id: "burn-rate",
      label: "Burn rate mensal",
      group: "liquidez",
      value: finite(burnRate),
      unit: "BRL",
      reference: "estável ou em queda",
      status: burnGrowth > 20 ? "attention" : "good",
      reading: previousBurnRate === 0
        ? "Média de gastos dos últimos 3 meses. Ainda sem trimestre anterior para comparar."
        : `Média de gastos dos últimos 3 meses, ${burnGrowth >= 0 ? "acima" : "abaixo"} do trimestre anterior em ${pct(Math.abs(burnGrowth))}.`,
    },
    {
      id: "taxa-poupanca",
      label: "Taxa de poupança",
      group: "fluxo",
      value: finite(savingsRate),
      unit: "percent",
      reference: "acima de 20%",
      status: atLeast(savingsRate, 20, 5),
      reading: current.income === 0
        ? "Nenhuma receita registrada neste mês, então não há taxa de poupança para calcular."
        : `De cada R$ 100 que entraram, sobraram R$ ${savingsRate.toFixed(0)} depois das despesas.`,
    },
    {
      id: "variacao-mensal",
      label: "Variação mensal",
      group: "fluxo",
      value: finite(variation),
      unit: "percent",
      reference: "até 0% (gastar igual ou menos)",
      status: atMost(variation, 0, 15),
      reading: previous.expense === 0
        ? "Sem despesas no mês anterior para comparar."
        : `Você gastou ${pct(Math.abs(variation))} ${variation >= 0 ? "a mais" : "a menos"} que no mês anterior.`,
    },
    {
      id: "tendencia-6-meses",
      label: "Tendência 6 meses",
      group: "fluxo",
      value: finite(trend),
      unit: "percent",
      reference: "até 0% ao mês",
      status: atMost(trend, 0, 5),
      reading: meanY === 0
        ? "Sem histórico de despesas suficiente para identificar tendência."
        : `Suas despesas ${trend >= 0 ? "crescem" : "caem"} em média ${pct(Math.abs(trend))} por mês nos últimos 6 meses.`,
    },
    {
      id: "comprometimento-fixo",
      label: "Comprometimento fixo",
      group: "estrutura",
      value: finite(commitmentRate),
      unit: "percent",
      reference: "até 30% da receita",
      status: atMost(commitmentRate, 30, 50),
      reading: current.income === 0
        ? "Sem receita no mês, não é possível medir o peso dos compromissos fixos."
        : `Seus compromissos fixos consomem ${pct(commitmentRate)} da receita do mês.`,
    },
    {
      id: "concentracao",
      label: "Concentração de gastos",
      group: "estrutura",
      value: finite(concentration),
      unit: "percent",
      reference: "até 30% em uma categoria",
      status: atMost(concentration, 30, 45),
      reading: topCategoryValue === 0
        ? "Nenhuma despesa registrada neste mês."
        : `${topCategory} concentra ${pct(concentration)} das despesas do mês.`,
    },
  ];
}
