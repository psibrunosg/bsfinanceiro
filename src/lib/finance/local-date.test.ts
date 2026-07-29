import { describe, expect, it } from "vitest";
import { monthStartsForSaoPauloDate, todayInSaoPaulo } from "./local-date";

describe("todayInSaoPaulo", () => {
  it("keeps the São Paulo calendar day near a UTC midnight boundary", () => {
    expect(todayInSaoPaulo(new Date("2026-07-29T01:30:00.000Z"))).toBe("2026-07-28");
  });

  it("keeps current and next occurrence months distinct at a São Paulo month boundary", () => {
    const today = todayInSaoPaulo(new Date("2026-08-01T02:30:00.000Z"));

    expect(monthStartsForSaoPauloDate(today)).toEqual(["2026-07-01", "2026-08-01"]);
  });
});
