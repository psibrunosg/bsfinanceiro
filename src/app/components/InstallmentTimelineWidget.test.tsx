// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { InstallmentTimelineWidget } from "./InstallmentTimelineWidget";

describe("InstallmentTimelineWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders installment timeline, active purchases, and financial relief badge", () => {
    const invoices = [
      {
        id: "inv-1",
        due_date: "2026-08-20",
        credit_card_installments: [
          {
            amount: 450.0,
            installment_number: 10,
            credit_card_purchases: {
              description: "iPhone 15 Pro",
              installment_count: 12,
            },
          },
        ],
      },
    ];

    render(
      <InstallmentTimelineWidget
        invoices={invoices}
        currentMonth="2026-08"
      />
    );

    expect(screen.getByText("Rastreador de Parcelamentos & Linha do Tempo")).toBeDefined();
    expect(screen.getByText(/Próximo Alívio:/i)).toBeDefined();
    expect(screen.getByText("iPhone 15 Pro")).toBeDefined();
    expect(screen.getByText(/Parcela 10 de 12/i)).toBeDefined();
  });

  it("updates selected month when user clicks a bar on the timeline", () => {
    const invoices = [
      {
        id: "inv-1",
        due_date: "2026-08-20",
        credit_card_installments: [
          {
            amount: 450.0,
            installment_number: 10,
            credit_card_purchases: {
              description: "iPhone 15 Pro",
              installment_count: 12,
            },
          },
        ],
      },
    ];

    render(
      <InstallmentTimelineWidget
        invoices={invoices}
        currentMonth="2026-08"
      />
    );

    const novBar = screen.getByTitle(/nov.*2026/i);
    fireEvent.click(novBar);

    expect(screen.getByText(/Você estará livre de todas as parcelas atuais/i)).toBeDefined();
  });
});
