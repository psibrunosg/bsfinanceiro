export type InvestmentOperation = {
  type: "buy" | "sell";
  quantity: number;
  unitPriceCents: number;
};

export type InvestmentPosition = {
  quantity: number;
  averageCostCents: number;
  totalCostCents: number;
  currentValueCents: number;
  absoluteGainCents: number;
  percentageGain: number;
};

function assertQuantity(value: number): void {
  if (!Number.isFinite(value) || value <= 0) {
    throw new RangeError("Operation quantity must be a positive finite number.");
  }
}

function assertNonNegativeCents(value: number, field: string): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(`${field} must be a non-negative safe integer.`);
  }
}

function centsFor(quantity: number, unitPriceCents: number): number {
  const amount = Math.round(quantity * unitPriceCents);

  if (!Number.isSafeInteger(amount)) {
    throw new RangeError("Operation total exceeds the safe cent range.");
  }

  return amount;
}

/**
 * Calculates a position using weighted average cost. All monetary totals are
 * rounded to integer cents after each operation, avoiding floating cent values.
 */
export function calculateInvestmentPosition(
  operations: readonly InvestmentOperation[],
  currentUnitPriceCents: number,
): InvestmentPosition {
  assertNonNegativeCents(currentUnitPriceCents, "Current unit price");

  let quantity = 0;
  let totalCostCents = 0;

  for (const operation of operations) {
    assertQuantity(operation.quantity);
    assertNonNegativeCents(operation.unitPriceCents, "Operation unit price");

    if (operation.type === "buy") {
      const nextQuantity = quantity + operation.quantity;
      const nextCost = totalCostCents + centsFor(operation.quantity, operation.unitPriceCents);

      if (!Number.isFinite(nextQuantity) || !Number.isSafeInteger(nextCost)) {
        throw new RangeError("Position exceeds the supported numeric range.");
      }

      quantity = nextQuantity;
      totalCostCents = nextCost;
      continue;
    }

    if (operation.type !== "sell") {
      throw new RangeError("Operation type must be buy or sell.");
    }

    if (operation.quantity > quantity) {
      throw new RangeError("Sale quantity cannot exceed the current position.");
    }

    const averageCostCents = quantity === 0 ? 0 : totalCostCents / quantity;
    quantity -= operation.quantity;

    if (quantity === 0) {
      totalCostCents = 0;
    } else {
      totalCostCents = Math.round(averageCostCents * quantity);
    }
  }

  const currentValueCents = centsFor(quantity, currentUnitPriceCents);
  const absoluteGainCents = currentValueCents - totalCostCents;

  return {
    quantity,
    averageCostCents: quantity === 0 ? 0 : totalCostCents / quantity,
    totalCostCents,
    currentValueCents,
    absoluteGainCents,
    percentageGain: totalCostCents === 0 ? 0 : (absoluteGainCents / totalCostCents) * 100,
  };
}
