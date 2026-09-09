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

  it("pulls net monthly income from payslips in database automatically", () => {
    const mockPayslips = [
      { id: "1", employer: "Nova Era", competence: "2026-08-01", gross_amount: 2053.69, discounts_amount: 543.83, net_amount: 1509.86, received_date: "2026-09-04", transaction_id: "tx-1" },
      { id: "2", employer: "ACPO", competence: "2026-08-01", gross_amount: 2389.42, discounts_amount: 214.61, net_amount: 2174.81, received_date: "2026-09-05", transaction_id: "tx-2" },
    ];

    render(
      <ImpulseCalculatorWidget
        payslips={mockPayslips}
        selectedMonth="2026-08"
      />
    );

    const incomeInput = screen.getByLabelText("Sua Renda Líquida/mês") as HTMLInputElement;
    expect(incomeInput.value).toBe("3684.67");
    expect(screen.getByText("✓ Do banco")).toBeDefined();
  });

  it("falls back to most recent payslips when selected month is not yet registered", () => {
    const mockPayslips = [
      { id: "1", employer: "Nova Era", competence: "2026-08-01", gross_amount: 2053.69, discounts_amount: 543.83, net_amount: 1509.86, received_date: "2026-09-04", transaction_id: "tx-1" },
      { id: "2", employer: "ACPO", competence: "2026-08-01", gross_amount: 2389.42, discounts_amount: 214.61, net_amount: 2174.81, received_date: "2026-09-05", transaction_id: "tx-2" },
    ];

    render(
      <ImpulseCalculatorWidget
        payslips={mockPayslips}
        selectedMonth="2026-09"
      />
    );

    const incomeInput = screen.getByLabelText("Sua Renda Líquida/mês") as HTMLInputElement;
    expect(incomeInput.value).toBe("3684.67");
  });
});
