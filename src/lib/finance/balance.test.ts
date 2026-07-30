import { describe, it, expect } from "vitest";
import { sumBalancesCents, numericToCents } from "./balance";

describe("sumBalancesCents", () => {
  it("sums initial balances + income - expense", () => {
    expect(sumBalancesCents([100_00, 50_00], [200_00], [30_00, 20_00])).toBe(300_00);
  });

  it("returns 0 for empty inputs", () => {
    expect(sumBalancesCents([], [], [])).toBe(0);
  });

  it("allows zero balances / amounts", () => {
    expect(sumBalancesCents([0, 0], [0], [0])).toBe(0);
  });

  it("rejects negative initial balance", () => {
    expect(() => sumBalancesCents([-1], [], [])).toThrow(RangeError);
  });

  it("rejects negative income", () => {
    expect(() => sumBalancesCents([], [-1], [])).toThrow(RangeError);
  });

  it("rejects non-integer cents", () => {
    expect(() => sumBalancesCents([1.5], [], [])).toThrow(RangeError);
  });
});

describe("numericToCents", () => {
  it("rounds a numeric string to cents", () => {
    expect(numericToCents("1234.56")).toBe(123456);
    expect(numericToCents("0.10")).toBe(10);
  });

  it("rounds a number to cents", () => {
    expect(numericToCents(99.99)).toBe(9999);
  });

  it("rejects non-finite", () => {
    expect(() => numericToCents("abc")).toThrow(RangeError);
    expect(() => numericToCents(Infinity)).toThrow(RangeError);
  });
});
