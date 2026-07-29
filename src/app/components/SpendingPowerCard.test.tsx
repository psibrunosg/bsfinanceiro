// @vitest-environment jsdom
import React from "react";
import { cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { SpendingPowerCard } from "./SpendingPowerCard";

afterEach(() => cleanup());

describe("SpendingPowerCard", () => {
  it("states the available amount and the next income date", () => {
    render(
      <SpendingPowerCard
        spendingPower={{
          availableCents: 600_00,
          nextIncomeDate: "2026-08-05",
          reservedCommitmentsCents: 300_00,
          reservedExpenseCents: 100_00,
        }}
      />,
    );

    expect(
      screen.getByRole("heading", { name: "Disponível para gastar" }),
    ).toBeTruthy();
    expect(screen.getByText(/R\$\s?600,00/)).toBeTruthy();
    expect(screen.getByText(/Até 05\/08/)).toBeTruthy();
  });

  it("explains the 30-day window and each reserved amount", () => {
    render(
      <SpendingPowerCard
        spendingPower={{
          availableCents: 600_00,
          nextIncomeDate: null,
          reservedCommitmentsCents: 300_00,
          reservedExpenseCents: 100_00,
        }}
      />,
    );

    expect(screen.getByText("Considerando os próximos 30 dias")).toBeTruthy();
    expect(
      screen.getByRole("group").querySelector("summary")?.textContent,
    ).toBe("Como calculamos");
    expect(
      screen.getByText(/Compromissos reservados:\s*R\$\s?300,00/),
    ).toBeTruthy();
    expect(
      screen.getByText(/Despesas planejadas:\s*R\$\s?100,00/),
    ).toBeTruthy();
  });
});
