/**
 * Sum account balances + transactions into a single cent value.
 *
 * Pure helper for the dashboard. SQL function `workspace_balance_cents`
 * computes the same number server-side; this keeps client-side recalculation
 * possible (optimistic inserts) without re-querying.
 *
 * ponytail: exists so the dashboard shows a live balance after inserting a
 * transaction before the RPC refetch returns. The DB function stays source of truth.
 */
export function sumBalancesCents(
  initialBalancesCents: readonly number[],
  incomeCents: readonly number[],
  expenseCents: readonly number[],
): number {
  let total = 0;
  for (const v of initialBalancesCents) {
    if (!Number.isSafeInteger(v) || v < 0) {
      throw new RangeError("initialBalancesCents must be non-negative safe integers.");
    }
    total += v;
  }
  for (const v of incomeCents) {
    if (!Number.isSafeInteger(v) || v < 0) {
      throw new RangeError("incomeCents must be non-negative safe integers.");
    }
    total += v;
  }
  for (const v of expenseCents) {
    if (!Number.isSafeInteger(v) || v < 0) {
      throw new RangeError("expenseCents must be non-negative safe integers.");
    }
    total -= v;
  }
  return total;
}

/** Convert a Postgres numeric string (e.g. "1234.56") to integer cents. */
export function numericToCents(value: string | number): number {
  const num = typeof value === "string" ? Number(value) : value;
  if (!Number.isFinite(num)) {
    throw new RangeError("numeric value must be finite.");
  }
  return Math.round(num * 100);
}
