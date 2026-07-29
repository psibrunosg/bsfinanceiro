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
});
