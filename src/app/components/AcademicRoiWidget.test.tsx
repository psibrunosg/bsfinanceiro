// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { AcademicRoiWidget } from "./AcademicRoiWidget";

describe("AcademicRoiWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders academic ROI metrics and allows adding a course", () => {
    render(<AcademicRoiWidget currentMonthlyIncome={10000} currentMonth="2026-08" />);

    expect(screen.getByText("ROI Acadêmico & Evolução Profissional")).toBeDefined();
    expect(screen.getByText("Total Investido")).toBeDefined();
    expect(screen.getByText("Aumento Mensal Gerado")).toBeDefined();
    expect(screen.getByText(/Simulador do Próximo Curso/i)).toBeDefined();

    // Add a course
    const titleInput = screen.getByPlaceholderText("Nome do Curso / Pós");
    fireEvent.change(titleInput, { target: { value: "Especialização em Terapia" } });
    
    const costInput = screen.getByPlaceholderText("Custo (R$)");
    fireEvent.change(costInput, { target: { value: "5000" } });

    const beforeInput = screen.getByPlaceholderText("Renda Antes");
    fireEvent.change(beforeInput, { target: { value: "4000" } });

    const afterInput = screen.getByPlaceholderText("Renda Depois");
    fireEvent.change(afterInput, { target: { value: "5000" } });

    fireEvent.submit(titleInput); // Submits the form

    expect(screen.getAllByText(/Especialização em Terapia/i).length).toBeGreaterThan(0);
  });
});
