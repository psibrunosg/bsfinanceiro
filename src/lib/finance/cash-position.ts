export type CashAccount = {
  id: string;
  type: string;
  initial_balance: number;
};

export type PostedTransaction = {
  account_id: string;
  destination_account_id: string | null;
  type: string;
  amount: number;
  status: string;
};

const CASH_ACCOUNT_TYPES = new Set(["checking", "cash", "savings"]);

export function calculateCashPosition(accounts: CashAccount[], transactions: PostedTransaction[]) {
  const accountBalancesCents = Object.fromEntries(
    accounts
      .filter((account) => CASH_ACCOUNT_TYPES.has(account.type))
      .map((account) => [account.id, Math.round(Number(account.initial_balance) * 100)]),
  ) as Record<string, number>;

  for (const transaction of transactions.filter((row) => row.status === "paid")) {
    const amountCents = Math.round(Number(transaction.amount) * 100);

    if (transaction.type === "income" && transaction.account_id in accountBalancesCents) {
      accountBalancesCents[transaction.account_id] += amountCents;
    }

    if (transaction.type === "expense" && transaction.account_id in accountBalancesCents) {
      accountBalancesCents[transaction.account_id] -= amountCents;
    }

    if (transaction.type === "transfer") {
      if (transaction.account_id in accountBalancesCents) {
        accountBalancesCents[transaction.account_id] -= amountCents;
      }

      if (transaction.destination_account_id && transaction.destination_account_id in accountBalancesCents) {
        accountBalancesCents[transaction.destination_account_id] += amountCents;
      }
    }
  }

  return {
    balanceCents: Object.values(accountBalancesCents).reduce((sum, value) => sum + value, 0),
    accountBalancesCents,
  };
}
