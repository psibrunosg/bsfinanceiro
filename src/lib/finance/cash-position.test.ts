import { describe, expect, it } from "vitest";
import { calculateCashPosition } from "./cash-position";

describe("calculateCashPosition", () => {
  it("subtracts paid expenses and adds paid income only for cash accounts", () => {
    expect(
      calculateCashPosition(
        [{ id: "a", type: "checking", initial_balance: 100 }],
        [
          { account_id: "a", destination_account_id: null, type: "expense", amount: 20, status: "paid" },
          { account_id: "a", destination_account_id: null, type: "income", amount: 35, status: "paid" },
          { account_id: "a", destination_account_id: null, type: "expense", amount: 50, status: "planned" },
        ],
      ).balanceCents,
    ).toBe(115_00);
  });

  it("moves money between eligible cash accounts without changing the total", () => {
    expect(
      calculateCashPosition(
        [
          { id: "a", type: "checking", initial_balance: 100 },
          { id: "b", type: "savings", initial_balance: 0 },
        ],
        [{ account_id: "a", destination_account_id: "b", type: "transfer", amount: 40, status: "paid" }],
      ).accountBalancesCents,
    ).toEqual({ a: 60_00, b: 40_00 });
  });

  it("ignores paid transfers when either account is not eligible for cash position", () => {
    expect(
      calculateCashPosition(
        [
          { id: "checking", type: "checking", initial_balance: 100 },
          { id: "cash", type: "cash", initial_balance: 50 },
          { id: "card", type: "credit_card", initial_balance: 2_000 },
          { id: "investment", type: "investment", initial_balance: 3_000 },
        ],
        [
          { account_id: "checking", destination_account_id: "card", type: "transfer", amount: 40, status: "paid" },
          { account_id: "investment", destination_account_id: "cash", type: "transfer", amount: 30, status: "paid" },
        ],
      ).accountBalancesCents,
    ).toEqual({ checking: 100_00, cash: 50_00 });
  });

  it("ignores planned transfers even when both accounts are eligible", () => {
    expect(
      calculateCashPosition(
        [
          { id: "a", type: "checking", initial_balance: 100 },
          { id: "b", type: "savings", initial_balance: 0 },
        ],
        [{ account_id: "a", destination_account_id: "b", type: "transfer", amount: 40, status: "planned" }],
      ).accountBalancesCents,
    ).toEqual({ a: 100_00, b: 0 });
  });
});
