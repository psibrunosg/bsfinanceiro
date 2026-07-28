import { describe, expect, it } from "vitest";
import { todayInSaoPaulo } from "./local-date";

describe("todayInSaoPaulo", () => {
  it("keeps the São Paulo calendar day near a UTC midnight boundary", () => {
    expect(todayInSaoPaulo(new Date("2026-07-29T01:30:00.000Z"))).toBe("2026-07-28");
  });
});
