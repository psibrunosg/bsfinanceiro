// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { MilesTrackerWidget } from "./MilesTrackerWidget";

describe("MilesTrackerWidget (Módulo 19)", () => {
  afterEach(() => {
    cleanup();
  });

  const samplePrograms = [
    {
      id: "p-1",
      name: "Livelo",
      points: 50000,
      pricePerThousand: 32,
      expiringPoints: 5000,
      expiringDate: "2026-09-30",
    },
  ];

  it("renders miles metrics and programs", () => {
    render(<MilesTrackerWidget initialPrograms={samplePrograms} />);
    expect(screen.getByText("Radar de Milhas & Pontos")).toBeDefined();
    expect(screen.getByText("Livelo")).toBeDefined();
    expect(screen.getAllByText(/50\.000\s+pts/).length).toBeGreaterThanOrEqual(1);
  });

  it("allows adding a new loyalty program via form", () => {
    render(<MilesTrackerWidget initialPrograms={samplePrograms} />);
    fireEvent.click(screen.getByRole("button", { name: /Adicionar Programa/i }));

    fireEvent.change(screen.getByPlaceholderText("Nome do programa (ex: Smiles, Latam...)"), {
      target: { value: "Smiles Gol" },
    });
    fireEvent.change(screen.getByPlaceholderText("Saldo total de pontos"), {
      target: { value: "30000" },
    });
    fireEvent.change(screen.getByPlaceholderText("Valor por 1.000 pts (ex: 17.50)"), {
      target: { value: "18" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Salvar" }));

    expect(screen.getByText("Smiles Gol")).toBeDefined();
    expect(screen.getAllByText(/30\.000\s+pts/).length).toBeGreaterThanOrEqual(1);
  });

  it("renders empty state when no programs exist", () => {
    render(<MilesTrackerWidget initialPrograms={[]} />);
    expect(screen.getByText(/Nenhum programa de milhas cadastrado/i)).toBeDefined();
    expect(screen.queryByText("Livelo")).toBeNull();
  });

  it("allows deleting an existing loyalty program", () => {
    render(<MilesTrackerWidget initialPrograms={samplePrograms} />);
    expect(screen.getByText("Livelo")).toBeDefined();

    fireEvent.click(screen.getByRole("button", { name: /Remover programa Livelo/i }));
    expect(screen.queryByText("Livelo")).toBeNull();
    expect(screen.getByText(/Nenhum programa de milhas cadastrado/i)).toBeDefined();
  });
});
