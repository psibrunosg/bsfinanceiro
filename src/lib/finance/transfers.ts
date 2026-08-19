/**
 * Inter-account transfer identification, pairing, classification (PJ <-> PF / Internal)
 * and filtering utilities.
 */

import { AccountScope, classifyAccountScope } from "./accounts";

export interface TransferTransaction {
  id: string;
  type: string; // 'income' | 'expense' | 'transfer'
  amount: number | string;
  competence_date: string;
  account_id?: string | null;
  destination_account_id?: string | null;
  category_id?: string | null;
  category_name?: string | null;
  description?: string | null;
  is_transfer?: boolean;
  status?: string;
}

export interface AccountInfo {
  id: string;
  name: string;
  scope?: AccountScope;
}

export type TransferType = "pj_to_pf" | "pf_to_pj" | "internal" | "other";

export interface TransferPair {
  id: string;
  outflowTransactionId?: string;
  inflowTransactionId?: string;
  sourceAccountId?: string | null;
  destinationAccountId?: string | null;
  amount: number;
  date: string;
  transferType: TransferType;
  description?: string;
}

export interface CategoryInfo {
  id: string;
  name: string;
  kind?: string;
}

const TRANSFER_KEYWORDS = [
  "transferência",
  "transferencia",
  "transferência interna",
  "transferencia interna",
  "transferência entre contas",
  "transferencia entre contas",
  "transf entre contas",
  "transf. entre contas",
  "transf interna",
  "transf. interna",
  "transf",
  "pix transf",
  "transfer",
  "pró-labore",
  "pro-labore",
  "prolabore",
  "distribuição de lucros",
  "distribuicao de lucros",
  "aporte de capital",
  "aporte",
  "retirada",
  "intercontas",
];

/**
 * Checks if a category ID or name matches transfer keywords.
 */
export function isTransferCategory(categoryNameOrId?: string | null, categories: CategoryInfo[] = []): boolean {
  if (!categoryNameOrId) return false;

  let name = categoryNameOrId;
  if (categories && categories.length > 0) {
    const found = categories.find((c) => c.id === categoryNameOrId || c.name === categoryNameOrId);
    if (found) name = found.name;
  }

  const lower = name.toLowerCase();
  return TRANSFER_KEYWORDS.some((kw) => lower.includes(kw));
}

/**
 * Identifies if a transaction represents an inter-account transfer.
 */
export function isTransferTransaction(tx: TransferTransaction, categories: CategoryInfo[] = []): boolean {
  if (tx.is_transfer === true) return true;
  if (tx.type === "transfer") return true;
  if (tx.destination_account_id != null && tx.destination_account_id !== "") return true;

  if (tx.category_name && isTransferCategory(tx.category_name, categories)) {
    return true;
  }
  if (tx.category_id && isTransferCategory(tx.category_id, categories)) {
    return true;
  }

  if (tx.description) {
    const lowerDesc = tx.description.toLowerCase();
    if (TRANSFER_KEYWORDS.some((kw) => lowerDesc.includes(kw))) {
      return true;
    }
  }

  return false;
}

/**
 * Classifies the type of transfer: PJ -> PF, PF -> PJ, Internal (same scope), or Other.
 */
export function classifyTransferType(
  txOrPair: {
    sourceAccountId?: string | null;
    destinationAccountId?: string | null;
    account_id?: string | null;
    category_name?: string | null;
    description?: string | null;
  },
  accounts: AccountInfo[] = []
): TransferType {
  const accountMap = new Map<string, AccountInfo>();
  for (const acc of accounts) {
    accountMap.set(acc.id, acc);
  }

  const srcId = txOrPair.sourceAccountId || txOrPair.account_id;
  const dstId = txOrPair.destinationAccountId;

  const srcAcc = srcId ? accountMap.get(srcId) : undefined;
  const dstAcc = dstId ? accountMap.get(dstId) : undefined;

  const srcScope = srcAcc ? (srcAcc.scope || classifyAccountScope(srcAcc.name)) : null;
  const dstScope = dstAcc ? (dstAcc.scope || classifyAccountScope(dstAcc.name)) : null;

  if (srcScope === "pj" && dstScope === "pf") return "pj_to_pf";
  if (srcScope === "pf" && dstScope === "pj") return "pf_to_pj";
  if (srcScope && dstScope && srcScope === dstScope) return "internal";

  // Text fallback if account scopes are not directly provided or resolved
  const text = `${txOrPair.category_name || ""} ${txOrPair.description || ""}`.toLowerCase();
  if (
    text.includes("pró-labore") ||
    text.includes("pro-labore") ||
    text.includes("prolabore") ||
    text.includes("distribuição de lucros") ||
    text.includes("distribuicao de lucros") ||
    text.includes("retirada")
  ) {
    return "pj_to_pf";
  }
  if (text.includes("aporte") || text.includes("aporte de capital")) {
    return "pf_to_pj";
  }

  if (srcScope || dstScope) {
    return "internal";
  }

  return "other";
}

/**
 * Pairs individual outflow and inflow transfer transactions, or formats explicit transfer transactions.
 */
export function pairTransfers(
  transactions: TransferTransaction[],
  accounts: AccountInfo[] = [],
  options: { maxDaysDiff?: number; categories?: CategoryInfo[] } = {}
): {
  pairs: TransferPair[];
  unpaired: TransferTransaction[];
} {
  const maxDaysDiff = options.maxDaysDiff ?? 3;
  const categories = options.categories ?? [];
  const pairs: TransferPair[] = [];
  const processedTxIds = new Set<string>();

  // 1. Explicit single-record transfer transactions
  for (const tx of transactions) {
    if (tx.destination_account_id && tx.account_id && tx.destination_account_id !== tx.account_id) {
      processedTxIds.add(tx.id);
      const amount = Math.abs(Number(tx.amount));
      const transferType = classifyTransferType(
        {
          sourceAccountId: tx.account_id,
          destinationAccountId: tx.destination_account_id,
          category_name: tx.category_name,
          description: tx.description,
        },
        accounts
      );

      pairs.push({
        id: `pair-explicit-${tx.id}`,
        outflowTransactionId: tx.id,
        sourceAccountId: tx.account_id,
        destinationAccountId: tx.destination_account_id,
        amount,
        date: tx.competence_date,
        transferType,
        description: tx.description || "Transferência entre contas",
      });
    }
  }

  // 2. Pair matching outflow and inflow transactions across accounts
  const unproc = transactions.filter((t) => !processedTxIds.has(t.id));

  const parseDate = (dStr: string) => new Date(`${dStr.substring(0, 10)}T00:00:00Z`).getTime();
  const dayMs = 24 * 60 * 60 * 1000;

  const outflows = unproc.filter((t) => t.type === "expense" || Number(t.amount) < 0);
  const inflows = unproc.filter((t) => t.type === "income" || Number(t.amount) > 0);

  for (const outflow of outflows) {
    if (processedTxIds.has(outflow.id)) continue;

    const isOutflowTransfer = isTransferTransaction(outflow, categories);
    const outAmount = Math.abs(Number(outflow.amount));
    const outTime = parseDate(outflow.competence_date);

    let bestMatch: TransferTransaction | null = null;
    let minDiff = Infinity;

    for (const inflow of inflows) {
      if (processedTxIds.has(inflow.id)) continue;
      if (inflow.id === outflow.id) continue;
      if (inflow.account_id && outflow.account_id && inflow.account_id === outflow.account_id) continue;

      const isInflowTransfer = isTransferTransaction(inflow, categories);
      if (!isOutflowTransfer && !isInflowTransfer) continue;

      const inAmount = Math.abs(Number(inflow.amount));
      if (Math.abs(outAmount - inAmount) < 0.001) {
        const inTime = parseDate(inflow.competence_date);
        const daysDiff = Math.abs(outTime - inTime) / dayMs;

        if (daysDiff <= maxDaysDiff && daysDiff < minDiff) {
          minDiff = daysDiff;
          bestMatch = inflow;
        }
      }
    }

    if (bestMatch) {
      processedTxIds.add(outflow.id);
      processedTxIds.add(bestMatch.id);

      const transferType = classifyTransferType(
        {
          sourceAccountId: outflow.account_id,
          destinationAccountId: bestMatch.account_id,
          category_name: outflow.category_name || bestMatch.category_name,
          description: outflow.description || bestMatch.description,
        },
        accounts
      );

      pairs.push({
        id: `pair-${outflow.id}-${bestMatch.id}`,
        outflowTransactionId: outflow.id,
        inflowTransactionId: bestMatch.id,
        sourceAccountId: outflow.account_id || null,
        destinationAccountId: bestMatch.account_id || null,
        amount: outAmount,
        date: outflow.competence_date,
        transferType,
        description: outflow.description || bestMatch.description || "Transferência intercontas pareada",
      });
    }
  }

  const unpaired = transactions.filter((t) => !processedTxIds.has(t.id));

  return { pairs, unpaired };
}

/**
 * Filter out inter-account transfers from a transaction list for consolidated revenue/expense reporting.
 */
export function filterOutTransfers(
  transactions: TransferTransaction[],
  categories: CategoryInfo[] = [],
  accounts: AccountInfo[] = []
): TransferTransaction[] {
  const { pairs } = pairTransfers(transactions, accounts, { categories });
  const pairedTxIds = new Set<string>();

  for (const pair of pairs) {
    if (pair.outflowTransactionId) pairedTxIds.add(pair.outflowTransactionId);
    if (pair.inflowTransactionId) pairedTxIds.add(pair.inflowTransactionId);
  }

  return transactions.filter(
    (tx) => !pairedTxIds.has(tx.id) && !isTransferTransaction(tx, categories)
  );
}

export interface TransfersSummary {
  totalVolume: number;
  pjToPfTotal: number;
  pfToPjTotal: number;
  internalTotal: number;
  otherTotal: number;
  count: number;
}

/**
 * Calculates a summary of inter-account transfers.
 */
export function calculateTransfersSummary(
  transactions: TransferTransaction[],
  accounts: AccountInfo[] = [],
  categories: CategoryInfo[] = []
): TransfersSummary {
  const { pairs, unpaired } = pairTransfers(transactions, accounts, { categories });

  let pjToPfTotal = 0;
  let pfToPjTotal = 0;
  let internalTotal = 0;
  let otherTotal = 0;

  for (const pair of pairs) {
    if (pair.transferType === "pj_to_pf") pjToPfTotal += pair.amount;
    else if (pair.transferType === "pf_to_pj") pfToPjTotal += pair.amount;
    else if (pair.transferType === "internal") internalTotal += pair.amount;
    else otherTotal += pair.amount;
  }

  const unpairedTransfers = unpaired.filter((tx) => isTransferTransaction(tx, categories));
  for (const tx of unpairedTransfers) {
    const amount = Math.abs(Number(tx.amount));
    const tType = classifyTransferType(tx, accounts);
    if (tType === "pj_to_pf") pjToPfTotal += amount;
    else if (tType === "pf_to_pj") pfToPjTotal += amount;
    else if (tType === "internal") internalTotal += amount;
    else otherTotal += amount;
  }

  const totalVolume = pjToPfTotal + pfToPjTotal + internalTotal + otherTotal;
  const count = pairs.length + unpairedTransfers.length;

  return {
    totalVolume,
    pjToPfTotal,
    pfToPjTotal,
    internalTotal,
    otherTotal,
    count,
  };
}

/**
 * Calculates net cash flow excluding inter-account transfers.
 */
export function calculateNetCashFlowExcludingTransfers(
  transactions: TransferTransaction[],
  categories: CategoryInfo[] = [],
  accounts: AccountInfo[] = []
): {
  totalIncome: number;
  totalExpense: number;
  netCashFlow: number;
  transferVolume: number;
} {
  const nonTransfers = filterOutTransfers(transactions, categories, accounts);

  const totalIncome = nonTransfers
    .filter((t) => t.type === "income")
    .reduce((sum, t) => sum + Number(t.amount), 0);

  const totalExpense = nonTransfers
    .filter((t) => t.type === "expense")
    .reduce((sum, t) => sum + Number(t.amount), 0);

  const { pairs, unpaired } = pairTransfers(transactions, accounts, { categories });
  const pairedVolume = pairs.reduce((sum, p) => sum + p.amount, 0);
  const unpairedVolume = unpaired
    .filter((t) => isTransferTransaction(t, categories))
    .reduce((sum, t) => sum + Math.abs(Number(t.amount)), 0);

  return {
    totalIncome,
    totalExpense,
    netCashFlow: totalIncome - totalExpense,
    transferVolume: pairedVolume + unpairedVolume,
  };
}
