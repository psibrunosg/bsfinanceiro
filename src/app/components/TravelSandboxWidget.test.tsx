// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { TravelSandboxWidget } from "./TravelSandboxWidget";
import { TravelTrip } from "@/lib/finance/travel-sandbox";

describe("TravelSandboxWidget", () => {
  afterEach(() => {
    cleanup();
  });

  const sampleTrip: TravelTrip = {
    id: "trip-active",
    destination: "Férias em Gramado & Canela",
    budgetBrl: 6000,
    startDate: "2026-07-10",
    endDate: "2026-07-16",
    expenses: [
      { id: "e1", description: "Hotel Ritta Höppner", amount: 2800, category: "Hospedagem", date: "2026-07-10" },
      { id: "e2", description: "Jantar Sequência de Fondue", amount: 450, category: "Alimentação", date: "2026-07-11" },
      { id: "e3", description: "Ingressos Parque Snowland", amount: 650, category: "Passeios", date: "2026-07-12" },
    ],
  };

  it("renders travel sandbox metrics and destination with active trip", () => {
    render(<TravelSandboxWidget initialTrip={sampleTrip} />);

    expect(screen.getByText("Modo Viagem (Sandbox de Gastos)")).toBeDefined();
    expect(screen.getByText("Férias em Gramado & Canela")).toBeDefined();
    expect(screen.getByText("Total Gasto na Viagem")).toBeDefined();
    expect(screen.getByText(/Teto Diário:/i)).toBeDefined();
    expect(screen.getByText(/Lançar Despesa da Viagem/i)).toBeDefined();
    expect(screen.getByRole("button", { name: /Encerrar Viagem/i })).toBeDefined();
  });

  it("renders empty state when no trip is active", () => {
    render(<TravelSandboxWidget initialTrip={null} />);

    expect(screen.getByText("Modo Viagem (Sandbox de Gastos)")).toBeDefined();
    expect(screen.getByText(/Nenhuma viagem ativa no momento/i)).toBeDefined();
    expect(screen.getByRole("button", { name: /Iniciar Viagem/i })).toBeDefined();
    expect(screen.queryByText("Férias em Gramado & Canela")).toBeNull();
  });
});
