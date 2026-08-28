import { addMonths, monthLabel } from "./local-date";

export type ProgressiveBracketResult = {
  marginalRate: number; // 0, 7.5, 15, 22.5, 27.5
  deductionParcel: number;
  taxDue: number;
};

export type LivroCaixaItem = {
  id: string;
  description: string;
  amount: number;
  date: string;
  categoryName?: string;
};

export type LivroCaixaDetectionResult = {
  totalDeductible: number;
  items: LivroCaixaItem[];
};

export type MonthlyTaxReportInput = {
  grossIncome: number;
  deductibleExpenses?: number;
  inssDeduction?: number;
  dependentsCount?: number;
  month: string; // YYYY-MM
};

export type MonthlyTaxReportResult = {
  month: string;
  monthLabel: string;
  grossIncome: number;
  deductibleExpenses: number;
  inssDeduction: number;
  dependentsDeduction: number;
  totalDeductions: number;
  taxableBase: number;
  marginalRatePercent: number;
  estimatedDARF: number;
  effectiveRatePercent: number;
  taxSavingsFromDeductions: number;
  darfDueDateLabel: string;
  recommendedProvisionPercent: number;
};

// Tabela Progressiva Mensal IRPF (Vigência 2026)
const PROGRESSIVE_TABLE_2026 = [
  { limit: 2259.2, rate: 0.0, deduction: 0.0 },
  { limit: 2826.65, rate: 0.075, deduction: 169.44 },
  { limit: 3751.05, rate: 0.15, deduction: 381.44 },
  { limit: 4664.68, rate: 0.225, deduction: 662.77 },
  { limit: Infinity, rate: 0.275, deduction: 896.0 },
];

const DEPENDENT_DEDUCTION_MONTHLY = 189.59;
const SIMPLIFIED_MONTHLY_DISCOUNT = 564.8;

/**
 * Calcula o IRPF devido de acordo com a tabela progressiva oficial.
 */
export function calculateProgressiveTax(taxableBase: number): ProgressiveBracketResult {
  const base = Math.max(0, taxableBase);

  for (const bracket of PROGRESSIVE_TABLE_2026) {
    if (base <= bracket.limit) {
      const rawTax = base * bracket.rate - bracket.deduction;
      return {
        marginalRate: Math.round(bracket.rate * 1000) / 10,
        deductionParcel: bracket.deduction,
        taxDue: Math.max(0, Math.round(rawTax * 100) / 100),
      };
    }
  }

  return { marginalRate: 0, deductionParcel: 0, taxDue: 0 };
}

// Regex de detecção de despesas dedutíveis no Livro-Caixa de profissionais liberais/psicólogos
const LIVRO_CAIXA_PATTERNS = [
  /aluguel/i,
  /consult[oó]rio/i,
  /cl[ií]nica/i,
  /sala/i,
  /condom[ií]nio/i,
  /crp|crm|oab|cro|crefito|coren/i,
  /conselho/i,
  /anuidade/i,
  /supervis[aã]o/i,
  /curso|especializa[cç][aã]o|p[oó]s-gradua[cç][aã]o|congresso|semin[aá]rio/i,
  /livro|publica[cç][aã]o/i,
  /internet|telefonia|telefone/i,
  /inss|gps/i,
  /papelaria|material/i,
  /software|prontu[aá]rio|psicomanager/i,
];

type InputTransaction = {
  id: string;
  description: string;
  amount: number | string;
  type?: string;
  competence_date?: string;
};

/**
 * Identifica despesas que se qualificam para dedução no Livro-Caixa do Carnê-Leão.
 */
export function detectLivroCaixaDeductions(
  transactions: InputTransaction[],
  month: string
): LivroCaixaDetectionResult {
  const monthPrefix = month.slice(0, 7);
  const items: LivroCaixaItem[] = [];
  let totalDeductible = 0;

  for (const tx of transactions) {
    const isExpense = !tx.type || tx.type === "expense";
    const datePrefix = (tx.competence_date || "").slice(0, 7);

    if (isExpense && datePrefix === monthPrefix) {
      const desc = tx.description || "";
      const isMatch = LIVRO_CAIXA_PATTERNS.some((pattern) => pattern.test(desc));

      if (isMatch) {
        const amt = Math.abs(Number(tx.amount) || 0);
        totalDeductible += amt;
        items.push({
          id: tx.id,
          description: desc,
          amount: amt,
          date: tx.competence_date || month,
        });
      }
    }
  }

  return {
    totalDeductible: Math.round(totalDeductible * 100) / 100,
    items,
  };
}

/**
 * Produz o relatório mensal consolidado de tributos (IRPF / Carnê-Leão).
 */
export function computeMonthlyTaxReport(
  input: MonthlyTaxReportInput
): MonthlyTaxReportResult {
  const {
    grossIncome,
    deductibleExpenses = 0,
    inssDeduction = 0,
    dependentsCount = 0,
    month,
  } = input;

  const gross = Math.max(0, grossIncome);
  const dependentsDeduction = dependentsCount * DEPENDENT_DEDUCTION_MONTHLY;

  // Compara deduções legais do Livro-Caixa com desconto simplificado
  const legalDeductions = deductibleExpenses + inssDeduction + dependentsDeduction;
  const bestDeductions = Math.max(legalDeductions, SIMPLIFIED_MONTHLY_DISCOUNT);

  const taxableBase = Math.max(0, Math.round((gross - bestDeductions) * 100) / 100);

  // Imposto devido com deduções
  const taxResult = calculateProgressiveTax(taxableBase);
  const estimatedDARF = taxResult.taxDue;

  // Imposto sem as deduções do livro-caixa (para medir a economia fiscal gerada)
  const baseWithoutLivroCaixa = Math.max(
    0,
    gross - inssDeduction - dependentsDeduction - SIMPLIFIED_MONTHLY_DISCOUNT
  );
  const taxWithoutLivroCaixa = calculateProgressiveTax(baseWithoutLivroCaixa).taxDue;
  const taxSavingsFromDeductions = Math.max(
    0,
    Math.round((taxWithoutLivroCaixa - estimatedDARF) * 100) / 100
  );

  const effectiveRatePercent =
    gross > 0 ? Math.round((estimatedDARF / gross) * 1000) / 10 : 0;

  // DARF vence no último dia útil do mês seguinte
  const monthStart = month.length === 7 ? `${month}-01` : month;
  const nextMonthStart = addMonths(monthStart, 1);
  const darfDueDateLabel = `Fim de ${monthLabel(nextMonthStart)}`;

  // Recomendação de provisão: arredonda alíquota efetiva + 2% de margem
  const recommendedProvisionPercent =
    effectiveRatePercent > 0 ? Math.min(27.5, Math.ceil(effectiveRatePercent + 1)) : 0;

  return {
    month: month.slice(0, 7),
    monthLabel: monthLabel(monthStart),
    grossIncome: Math.round(gross * 100) / 100,
    deductibleExpenses: Math.round(deductibleExpenses * 100) / 100,
    inssDeduction: Math.round(inssDeduction * 100) / 100,
    dependentsDeduction: Math.round(dependentsDeduction * 100) / 100,
    totalDeductions: Math.round(bestDeductions * 100) / 100,
    taxableBase,
    marginalRatePercent: taxResult.marginalRate,
    estimatedDARF,
    effectiveRatePercent,
    taxSavingsFromDeductions,
    darfDueDateLabel,
    recommendedProvisionPercent,
  };
}
