// @vitest-environment jsdom
import React from "react";
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { TodayPanel } from "./TodayPanel";

describe("TodayPanel", () => {
  it("shows the empty state when there is no next income", () => {
    render(<TodayPanel today={{ currentBalanceCents: 50_00, nextIncomeDate: null, projectedBalanceCents: 50_00, lowestBalanceCents: 50_00, lowestBalanceDate: "2026-07-28", alert: null }} />);
    expect(screen.getByText("Nenhuma próxima receita agendada.")).toBeTruthy();
  });
});
