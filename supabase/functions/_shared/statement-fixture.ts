export type StatementFixturePurchase = {
  description: string;
  totalAmount: number;
  purchasedOn: string;
  installmentCount: number;
  categoryId: string | null;
  notes: string | null;
};

const HEADER = "BSFINANCEIRO_STATEMENT_FIXTURE_V1";

/**
 * This is deliberately not a PDF parser. It exists only to exercise the
 * private upload/job pipeline until a real issuer layout is specified.
 */
export function parseStatementFixture(content: string): StatementFixturePurchase {
  const [header, payload, ...extra] = content.trim().split("\n");
  if (header !== HEADER || !payload || extra.length > 0) {
    throw new Error("unsupported_format");
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(payload);
  } catch {
    throw new Error("unsupported_format");
  }
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("unsupported_format");
  }
  const value = parsed as Record<string, unknown>;
  const allowed = ["description", "totalAmount", "purchasedOn", "installmentCount", "categoryId", "notes"];
  if (Object.keys(value).some((key) => !allowed.includes(key))) throw new Error("unsupported_format");
  if (typeof value.description !== "string" || value.description.trim().length < 1 || value.description.trim().length > 160) throw new Error("unsupported_format");
  if (typeof value.totalAmount !== "number" || !Number.isFinite(value.totalAmount) || value.totalAmount <= 0 || Math.round(value.totalAmount * 100) !== value.totalAmount * 100) throw new Error("unsupported_format");
  if (typeof value.purchasedOn !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value.purchasedOn)) throw new Error("unsupported_format");
  if (typeof value.installmentCount !== "number" || !Number.isInteger(value.installmentCount) || value.installmentCount < 1 || value.installmentCount > 120) throw new Error("unsupported_format");
  if (value.categoryId !== undefined && value.categoryId !== null && typeof value.categoryId !== "string") throw new Error("unsupported_format");
  if (value.notes !== undefined && value.notes !== null && typeof value.notes !== "string") throw new Error("unsupported_format");

  return {
    description: value.description.trim(),
    totalAmount: value.totalAmount,
    purchasedOn: value.purchasedOn,
    installmentCount: value.installmentCount,
    categoryId: (value.categoryId as string | null | undefined) ?? null,
    notes: (value.notes as string | null | undefined)?.trim() || null,
  };
}
