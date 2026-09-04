// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { WarrantyVaultWidget } from "./WarrantyVaultWidget";

describe("WarrantyVaultWidget (Módulo 12)", () => {
  afterEach(() => {
    cleanup();
  });

  const sampleItems = [
    {
      id: "w-1",
      name: "Notebook Dell",
      purchaseDate: "2025-10-01",
      warrantyMonths: 12,
      invoiceNumber: "NF-5544",
      value: 5000,
      category: "Informática",
    },
  ];

  it("renders warranty vault metrics and items", () => {
    render(<WarrantyVaultWidget initialItems={sampleItems} referenceDate="2026-08-15" />);
    expect(screen.getByText("Cofre de Garantias & Notas Fiscais")).toBeDefined();
    expect(screen.getByText("Notebook Dell")).toBeDefined();
    expect(screen.getByText("NF-5544")).toBeDefined();
  });

  it("allows adding a new warranty item via form", () => {
    render(<WarrantyVaultWidget initialItems={sampleItems} referenceDate="2026-08-15" />);
    fireEvent.click(screen.getByRole("button", { name: /Cadastrar Garantia/i }));
    fireEvent.change(screen.getByPlaceholderText("Nome do item (ex: iPhone 15, TV...)"), {
      target: { value: "Smart TV Samsung" },
    });
    fireEvent.change(screen.getByPlaceholderText("Valor em R$"), {
      target: { value: "3200" },
    });
    fireEvent.change(screen.getByPlaceholderText("Meses de garantia"), {
      target: { value: "12" },
    });
    fireEvent.change(screen.getByLabelText("Data da compra"), {
      target: { value: "2026-08-01" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Salvar" }));

    expect(screen.getByText("Smart TV Samsung")).toBeDefined();
  });
});
