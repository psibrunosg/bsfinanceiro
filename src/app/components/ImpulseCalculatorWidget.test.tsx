// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ImpulseCalculatorWidget } from "./ImpulseCalculatorWidget";

describe("ImpulseCalculatorWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders impulse hours of life calculator and cooling-off wishlist", () => {
    render(<ImpulseCalculatorWidget estimatedMonthlyIncome={8000} />);

    expect(screen.getByText("Calculadora de Impulso (Preço em Horas de Vida)")).toBeDefined();
    expect(screen.getByText("Custo Real em Vida")).toBeDefined();
    expect(screen.getByText("Tênis Esportivo Edição Limitada")).toBeDefined();
    expect(screen.getByText(/Salvo por Autocontrole:/i)).toBeDefined();
  });

  it("allows dismissing an item and marking as saved", () => {
    render(<ImpulseCalculatorWidget estimatedMonthlyIncome={8000} />);

    const dismissBtn = screen.getByText("🎉 Desisti (Salvar)");
    fireEvent.click(dismissBtn);

    expect(screen.getAllByText("✅ Economizado").length).toBe(2);
  });
});
