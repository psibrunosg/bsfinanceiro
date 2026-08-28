// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { TravelSandboxWidget } from "./TravelSandboxWidget";

describe("TravelSandboxWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders travel sandbox metrics and destination", () => {
    render(<TravelSandboxWidget />);

    expect(screen.getByText("Modo Viagem (Sandbox de Gastos)")).toBeDefined();
    expect(screen.getByText("Férias em Gramado & Canela")).toBeDefined();
    expect(screen.getByText("Total Gasto na Viagem")).toBeDefined();
    expect(screen.getByText(/Teto Diário:/i)).toBeDefined();
    expect(screen.getByText(/Lançar Despesa da Viagem/i)).toBeDefined();
  });
});
