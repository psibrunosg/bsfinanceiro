export type BudgetEnvelope = {
  id: string;
  name: string;
  allocated: number;
  spent: number;
  category?: string;
  icon?: string;
};

export type BudgetEnvelopeWithMetrics = BudgetEnvelope & {
  remaining: number;
  spentPercent: number;
  isOverspent: boolean;
  overspentAmount: number;
};

export type ZeroBasedBudgetInput = {
  monthlyIncome: number;
  envelopes: BudgetEnvelope[];
};

export type ZeroBasedBudgetResult = {
  monthlyIncome: number;
  totalAllocated: number;
  totalSpent: number;
  unallocatedAmount: number;
  isFullyAllocated: boolean;
  overspentEnvelopesCount: number;
  envelopesWithMetrics: BudgetEnvelopeWithMetrics[];
  summaryMessage: string;
};

/**
 * Computa a distribuição do Orçamento Base Zero (Zero-Based Budgeting / YNAB Style).
 */
export function computeZeroBasedBudget(
  input: ZeroBasedBudgetInput
): ZeroBasedBudgetResult {
  const { monthlyIncome, envelopes } = input;
  const income = Math.max(0, Number(monthlyIncome) || 0);

  let totalAllocated = 0;
  let totalSpent = 0;
  let overspentEnvelopesCount = 0;
  const envelopesWithMetrics: BudgetEnvelopeWithMetrics[] = [];

  for (const env of envelopes) {
    const allocated = Math.max(0, Number(env.allocated) || 0);
    const spent = Math.max(0, Number(env.spent) || 0);
    const remaining = Math.round((allocated - spent) * 100) / 100;
    const isOverspent = remaining < 0;
    const overspentAmount = isOverspent ? Math.abs(remaining) : 0;
    const spentPercent =
      allocated > 0 ? Math.round((spent / allocated) * 1000) / 10 : spent > 0 ? 100 : 0;

    if (isOverspent) {
      overspentEnvelopesCount++;
    }

    totalAllocated += allocated;
    totalSpent += spent;

    envelopesWithMetrics.push({
      ...env,
      allocated,
      spent,
      remaining,
      spentPercent,
      isOverspent,
      overspentAmount,
    });
  }

  totalAllocated = Math.round(totalAllocated * 100) / 100;
  totalSpent = Math.round(totalSpent * 100) / 100;
  const unallocatedAmount = Math.round((income - totalAllocated) * 100) / 100;
  const isFullyAllocated = unallocatedAmount === 0;

  let summaryMessage = "Parabéns! Cada centavo da sua renda tem um destino planejado.";
  if (unallocatedAmount > 0) {
    summaryMessage = `Você ainda tem R$ ${unallocatedAmount.toLocaleString("pt-BR")} não alocados. Dê um destino a cada centavo!`;
  } else if (unallocatedAmount < 0) {
    summaryMessage = `Atenção: Você alocou R$ ${Math.abs(unallocatedAmount).toLocaleString("pt-BR")} a mais do que sua renda mensal!`;
  }

  return {
    monthlyIncome: income,
    totalAllocated,
    totalSpent,
    unallocatedAmount,
    isFullyAllocated,
    overspentEnvelopesCount,
    envelopesWithMetrics,
    summaryMessage,
  };
}

/**
 * Transfere orçamento entre dois envelopes para cobrir estouros ou readequar metas.
 */
export function transferBetweenEnvelopes(
  envelopes: BudgetEnvelope[],
  fromEnvelopeId: string,
  toEnvelopeId: string,
  amount: number
): BudgetEnvelope[] {
  const transferAmt = Math.max(0, amount);

  return envelopes.map((env) => {
    if (env.id === fromEnvelopeId) {
      return { ...env, allocated: Math.max(0, env.allocated - transferAmt) };
    }
    if (env.id === toEnvelopeId) {
      return { ...env, allocated: env.allocated + transferAmt };
    }
    return env;
  });
}
