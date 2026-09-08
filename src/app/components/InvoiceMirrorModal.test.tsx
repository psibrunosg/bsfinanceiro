// @vitest-environment jsdom
import { describe, it, expect, afterEach, vi } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { InvoiceMirrorModal } from "./InvoiceMirrorModal";
import { Card, Invoice } from "./types";

const mockCard: Card = {
  id: "card-1",
  name: "Mercado Pago Visa",
  brand: "visa",
  last_four: "3191",
  credit_limit: 500,
  closing_day: 15,
  due_day: 20,
};

const mockInvoiceWithItems: Invoice = {
  id: "inv-1",
  credit_card_id: "card-1",
  due_date: "2026-08-20",
  closing_date: "2026-08-15",
  paid_at: "2026-08-19",
  status: "paid",
  total_amount: 150.5,
  credit_card_installments: [
    {
      amount: 100.5,
      installment_number: 1,
      credit_card_purchases: {
        description: "Supermercado Extra",
        installment_count: 2,
      },
    },
    {
      amount: 50.0,
      installment_number: 1,
      credit_card_purchases: {
        description: "Farmácia",
        installment_count: 1,
      },
    },
  ],
};

const mockConsolidatedInvoice: Invoice = {
  id: "inv-2",
  credit_card_id: "card-1",
  due_date: "2026-07-20",
  closing_date: "2026-07-15",
  paid_at: null,
  status: "open",
  total_amount: 320.0,
  credit_card_installments: [],
};

describe("InvoiceMirrorModal", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders invoice mirror modal with card details and itemized purchases", () => {
    const onClose = vi.fn();
    render(
      <InvoiceMirrorModal
        card={mockCard}
        invoice={mockInvoiceWithItems}
        allInvoices={[mockInvoiceWithItems, mockConsolidatedInvoice]}
        onClose={onClose}
      />
    );

    expect(screen.getByText("Espelho da Fatura")).toBeDefined();
    expect(screen.getByText("Mercado Pago Visa")).toBeDefined();
    expect(screen.getByText("Final •••• 3191")).toBeDefined();
    expect(screen.getByText("Fatura Paga")).toBeDefined();
    expect(screen.getByText("Supermercado Extra")).toBeDefined();
    expect(screen.getByText("Farmácia")).toBeDefined();
    expect(screen.getByText("Parcela 1 de 2")).toBeDefined();

    // Close button
    const closeBtn = screen.getByRole("button", { name: "Fechar" });
    fireEvent.click(closeBtn);
    expect(onClose).toHaveBeenCalled();
  });

  it("renders consolidated invoice balance when installments are empty", () => {
    const onClose = vi.fn();
    render(
      <InvoiceMirrorModal
        card={mockCard}
        invoice={mockConsolidatedInvoice}
        allInvoices={[mockInvoiceWithItems, mockConsolidatedInvoice]}
        onClose={onClose}
      />
    );

    expect(screen.getByText("Total Consolidado da Fatura")).toBeDefined();
    expect(screen.getByText("Fatura em Aberto")).toBeDefined();
  });

  it("allows switching invoices via dropdown", () => {
    const onSelect = vi.fn();
    render(
      <InvoiceMirrorModal
        card={mockCard}
        invoice={mockInvoiceWithItems}
        allInvoices={[mockInvoiceWithItems, mockConsolidatedInvoice]}
        onClose={vi.fn()}
        onSelectInvoice={onSelect}
      />
    );

    const select = screen.getByLabelText("Selecionar mês da fatura:");
    fireEvent.change(select, { target: { value: "inv-2" } });

    expect(screen.getByText("Total Consolidado da Fatura")).toBeDefined();
    expect(onSelect).toHaveBeenCalledWith(mockConsolidatedInvoice);
  });
});
