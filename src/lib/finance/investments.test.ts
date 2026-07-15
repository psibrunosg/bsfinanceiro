import { describe, expect, it } from "vitest";
import { calculateInvestmentPosition } from "./investments";

describe("calculateInvestmentPosition", () => {
  it("returns a zeroed position when there are no operations", () => {
    expect(calculateInvestmentPosition([], 150_00)).toEqual({
      quantity: 0,
      averageCostCents: 0,
      totalCostCents: 0,
      currentValueCents: 0,
      absoluteGainCents: 0,
      percentageGain: 0,
    });
  });

  it("calculates weighted average cost and a positive current gain", () => {
    expect(
      calculateInvestmentPosition(
        [
          { type: "buy", quantity: 2, unitPriceCents: 10_01 },
          { type: "buy", quantity: 1, unitPriceCents: 20_02 },
        ],
        15_01,
      ),
      ).toEqual({
        quantity: 3,
        averageCostCents: 13_34 + 2 / 3,
        totalCostCents: 40_04,
        currentValueCents: 45_03,
      absoluteGainCents: 4_99,
      percentageGain: (4_99 / 40_04) * 100,
    });
  });

  it("keeps the average cost after a partial sale", () => {
    expect(
      calculateInvestmentPosition(
        [
          { type: "buy", quantity: 10, unitPriceCents: 12_34 },
          { type: "sell", quantity: 4, unitPriceCents: 15_00 },
        ],
        10_00,
      ),
    ).toEqual({
      quantity: 6,
      averageCostCents: 12_34,
      totalCostCents: 74_04,
      currentValueCents: 60_00,
      absoluteGainCents: -14_04,
      percentageGain: (-14_04 / 74_04) * 100,
    });
  });

  it("closes the position without leaving residual cents", () => {
    expect(
      calculateInvestmentPosition(
        [
          { type: "buy", quantity: 3, unitPriceCents: 10_01 },
          { type: "sell", quantity: 3, unitPriceCents: 11_00 },
        ],
        12_00,
      ),
    ).toEqual({
      quantity: 0,
      averageCostCents: 0,
      totalCostCents: 0,
      currentValueCents: 0,
      absoluteGainCents: 0,
      percentageGain: 0,
    });
  });

  it("supports fractional quantities while keeping totals in cents", () => {
    expect(
      calculateInvestmentPosition(
        [{ type: "buy", quantity: 0.5, unitPriceCents: 10_01 }],
        12_01,
      ),
    ).toMatchObject({
      quantity: 0.5,
      totalCostCents: 5_01,
      currentValueCents: 6_01,
      absoluteGainCents: 1_00,
    });
  });

  it("rejects a sale above the available position", () => {
    expect(() =>
      calculateInvestmentPosition(
        [
          { type: "buy", quantity: 1, unitPriceCents: 10_00 },
          { type: "sell", quantity: 2, unitPriceCents: 11_00 },
        ],
        12_00,
      ),
    ).toThrow("Sale quantity cannot exceed the current position.");
  });

  it("rejects invalid quantities and fractional cents", () => {
    expect(() =>
      calculateInvestmentPosition([{ type: "buy", quantity: 0, unitPriceCents: 10_00 }], 12_00),
    ).toThrow(RangeError);
    expect(() =>
      calculateInvestmentPosition([{ type: "buy", quantity: 1, unitPriceCents: 10.5 }], 12_00),
    ).toThrow(RangeError);
    expect(() => calculateInvestmentPosition([], 12.5)).toThrow(RangeError);
  });
});
