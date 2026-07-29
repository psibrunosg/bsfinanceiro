export type PlannedTransaction = {
  type: string;
  amount: number;
  competence_date: string;
  status: string;
};

export type PlannedCommitment = {
  amount: number;
  due_date: string;
  status: string;
};

export type SpendingPowerInput = {
  currentBalanceCents: number;
  today: string;
  plannedTransactions: PlannedTransaction[];
  commitments: PlannedCommitment[];
};

export type SpendingPower = {
  availableCents: number;
  nextIncomeDate: string | null;
  reservedCommitmentsCents: number;
  reservedExpenseCents: number;
};

function addIsoDays(date: string, days: number): string {
  const parsed = new Date(`${date}T00:00:00.000Z`);
  parsed.setUTCDate(parsed.getUTCDate() + days);
  return parsed.toISOString().slice(0, 10);
}

function isWithinDecisionWindow(date: string, today: string, cutoff: string): boolean {
  return date >= today && date <= cutoff;
}

function toCents(amount: number): number {
  return Math.round(amount * 100);
}

export function buildSpendingPower(input: SpendingPowerInput): SpendingPower {
  const nextIncomeDate = input.plannedTransactions
    .filter((row) => row.type === "income" && row.status === "planned" && row.competence_date >= input.today)
    .map((row) => row.competence_date)
    .sort()[0] ?? null;
  const cutoff = nextIncomeDate ?? addIsoDays(input.today, 30);

  const reservedExpenseCents = input.plannedTransactions
    .filter(
      (row) =>
        row.type === "expense" &&
        row.status === "planned" &&
        isWithinDecisionWindow(row.competence_date, input.today, cutoff),
    )
    .reduce((sum, row) => sum + toCents(row.amount), 0);
  const reservedCommitmentsCents = input.commitments
    .filter((row) => row.status === "planned" && isWithinDecisionWindow(row.due_date, input.today, cutoff))
    .reduce((sum, row) => sum + toCents(row.amount), 0);

  return {
    availableCents: input.currentBalanceCents - reservedExpenseCents - reservedCommitmentsCents,
    nextIncomeDate,
    reservedCommitmentsCents,
    reservedExpenseCents,
  };
}
