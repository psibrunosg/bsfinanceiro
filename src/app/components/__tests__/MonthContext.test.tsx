// @vitest-environment jsdom
import React from "react";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { MonthProvider, currentMonthStart, useMonth } from "../MonthContext";

const STORAGE_KEY = "bsfinanceiro:selected-month";

function Probe() {
  const { month, label, nextMonth, isCurrentMonth, setMonth, shiftMonth } = useMonth();
  return (
    <div>
      <span data-testid="month">{month}</span>
      <span data-testid="next">{nextMonth}</span>
      <span data-testid="label">{label}</span>
      <span data-testid="current">{String(isCurrentMonth)}</span>
      <button onClick={() => setMonth("2026-01-01")}>jan</button>
      <button onClick={() => shiftMonth(-1)}>anterior</button>
      <button onClick={() => shiftMonth(1)}>proximo</button>
    </div>
  );
}

const renderProbe = () => render(<MonthProvider><Probe /></MonthProvider>);
const month = () => screen.getByTestId("month").textContent;

describe("MonthContext", () => {
  beforeEach(() => {
    window.localStorage.clear();
  });

  // Sem setup global do vitest: limpeza explícita do DOM entre os testes.
  afterEach(cleanup);

  it("usa o mês corrente de São Paulo quando não há valor salvo", async () => {
    renderProbe();
    await waitFor(() => {
      expect(month()).toBe(currentMonthStart());
    });
    expect(screen.getByTestId("current").textContent).toBe("true");
  });

  it("restaura um valor válido salvo no localStorage", async () => {
    window.localStorage.setItem(STORAGE_KEY, "2025-03-01");
    renderProbe();
    await waitFor(() => {
      expect(month()).toBe("2025-03-01");
    });
    expect(screen.getByTestId("next").textContent).toBe("2025-04-01");
  });

  it("ignora um valor malformado e mantém o padrão", async () => {
    window.localStorage.setItem(STORAGE_KEY, "2025-3");
    renderProbe();
    await waitFor(() => {
      expect(month()).toBe(currentMonthStart());
    });
  });

  it("persiste a seleção de setMonth", async () => {
    renderProbe();
    fireEvent.click(screen.getByRole("button", { name: "jan" }));
    await waitFor(() => {
      expect(month()).toBe("2026-01-01");
    });
    expect(window.localStorage.getItem(STORAGE_KEY)).toBe("2026-01-01");
  });

  it("shiftMonth atravessa a virada de ano nos dois sentidos", async () => {
    renderProbe();
    fireEvent.click(screen.getByRole("button", { name: "jan" }));
    await waitFor(() => expect(month()).toBe("2026-01-01"));

    fireEvent.click(screen.getByRole("button", { name: "anterior" }));
    await waitFor(() => expect(month()).toBe("2025-12-01"));
    expect(window.localStorage.getItem(STORAGE_KEY)).toBe("2025-12-01");

    fireEvent.click(screen.getByRole("button", { name: "proximo" }));
    await waitFor(() => expect(month()).toBe("2026-01-01"));
  });

  it("useMonth fora do provider lança erro", () => {
    expect(() => render(<Probe />)).toThrow(/MonthProvider/);
  });
});
