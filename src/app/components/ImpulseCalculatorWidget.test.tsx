// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { ImpulseCalculatorWidget } from "./ImpulseCalculatorWidget";

describe("ImpulseCalculatorWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders impulse hours of life calculator and allows adding a wish", () => {
    render(<ImpulseCalculatorWidget estimatedMonthlyIncome={8000} />);

    expect(screen.getByText("Calculadora de Impulso (Preço em Horas de Vida)")).toBeDefined();
    expect(screen.getByText("Custo Real em Vida")).toBeDefined();

    // Add a wish
    const nameInput = screen.getByPlaceholderText("Nome do desejo (ex: iPhone 16)");
    fireEvent.change(nameInput, { target: { value: "Tênis Esportivo Edição Limitada" } });
    
    // The price input label seems to be "Preço do Item (R$)" based on the log
    // We can just find it by role or placeholder if there is one. 
    // Wait, it is the first input, or we can use getByLabelText.
    const priceInput = screen.getByLabelText("Preço do Item (R$)");
    fireEvent.change(priceInput, { target: { value: "1000" } });

    const submitBtn = screen.getByText(/Ativar Reflexão de 48h/i);
    fireEvent.click(submitBtn);

    expect(screen.getByText("Tênis Esportivo Edição Limitada")).toBeDefined();
  });

  it("allows dismissing an item and marking as saved", () => {
    render(<ImpulseCalculatorWidget estimatedMonthlyIncome={8000} />);

    // Add a wish
    const nameInput = screen.getByPlaceholderText("Nome do desejo (ex: iPhone 16)");
    fireEvent.change(nameInput, { target: { value: "Tênis Esportivo Edição Limitada" } });
    const priceInput = screen.getByLabelText("Preço do Item (R$)");
    fireEvent.change(priceInput, { target: { value: "1000" } });
    const submitBtn = screen.getByText(/Ativar Reflexão de 48h/i);
    fireEvent.click(submitBtn);

    const dismissBtn = screen.getByText("🎉 Desisti (Salvar)");
    fireEvent.click(dismissBtn);

    expect(screen.getAllByText("✅ Economizado").length).toBeGreaterThan(0);
  });
});
