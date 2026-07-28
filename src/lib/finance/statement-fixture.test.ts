import { describe, expect, it } from "vitest";
import { parseStatementFixture } from "../../../supabase/functions/_shared/statement-fixture";

describe("parseStatementFixture", () => {
  it("accepts the documented synthetic fixture only", () => {
    expect(parseStatementFixture(`BSFINANCEIRO_STATEMENT_FIXTURE_V1
{"description":"Compra de teste","totalAmount":42.5,"purchasedOn":"2026-07-28","installmentCount":1,"categoryId":null,"notes":"fixture"}`)).toEqual({
      description: "Compra de teste",
      totalAmount: 42.5,
      purchasedOn: "2026-07-28",
      installmentCount: 1,
      categoryId: null,
      notes: "fixture",
    });
  });

  it("rejects PDF-looking or unknown layouts before persistence", () => {
    expect(() => parseStatementFixture("%PDF-1.7\nunknown issuer layout")).toThrow("unsupported_format");
    expect(() => parseStatementFixture("BSFINANCEIRO_STATEMENT_FIXTURE_V1\n{}\nextra")).toThrow("unsupported_format");
  });
});
