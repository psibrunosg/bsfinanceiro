import { describe, expect, it } from "vitest";
import { projectWeekly } from "./projection";

describe("projectWeekly", () => {
  it("groups income and expenses from Monday through Sunday", () => {
    expect(
      projectWeekly([
        { date: "2026-07-06", type: "income", amountCents: 100_00 },
        { date: "2026-07-12", type: "expense", amountCents: 25_00 },
        { date: "2026-07-13", type: "expense", amountCents: 10_00 },
      ]),
    ).toEqual([
      {
        weekStart: "2026-07-06",
        weekEnd: "2026-07-12",
        incomeCents: 100_00,
        expenseCents: 25_00,
        netCents: 75_00,
        balanceCents: 75_00,
      },
      {
        weekStart: "2026-07-13",
        weekEnd: "2026-07-19",
        incomeCents: 0,
        expenseCents: 10_00,
        netCents: -10_00,
        balanceCents: 65_00,
      },
    ]);
  });

  it("sorts weeks and carries the balance from an initial value", () => {
    const projection = projectWeekly(
      [
        { date: "2026-07-20", type: "income", amountCents: 50_00 },
        { date: "2026-07-06", type: "expense", amountCents: 20_00 },
        { date: "2026-07-13", type: "income", amountCents: 10_00 },
      ],
      100_00,
    );

    expect(projection.map((week) => week.balanceCents)).toEqual([80_00, 90_00, 140_00]);
  });

  it("returns an empty projection when there are no events", () => {
    expect(projectWeekly([], 50_00)).toEqual([]);
  });
});
