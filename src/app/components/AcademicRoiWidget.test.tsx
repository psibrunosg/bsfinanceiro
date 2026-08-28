// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup } from "@testing-library/react";
import { AcademicRoiWidget } from "./AcademicRoiWidget";

describe("AcademicRoiWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders academic ROI metrics and course list", () => {
    render(<AcademicRoiWidget currentMonthlyIncome={10000} currentMonth="2026-08" />);

    expect(screen.getByText("ROI Acadêmico & Evolução Profissional")).toBeDefined();
    expect(screen.getAllByText(/Especialização em Terapia/i).length).toBeGreaterThan(0);
    expect(screen.getByText("Total Investido")).toBeDefined();
    expect(screen.getByText("Aumento Mensal Gerado")).toBeDefined();
    expect(screen.getByText(/Simulador do Próximo Curso/i)).toBeDefined();
  });
});
