// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, fireEvent, cleanup } from "@testing-library/react";
import { InvestmentGrowthWidget } from "./InvestmentGrowthWidget";

describe("InvestmentGrowthWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders benchmark CDI and allocation metrics", () => {
    const assets = [
      { id: "a1", name: "Tesouro Selic", type: "fixed_income" },
      { id: "a2", name: "ITUB4", type: "stock" },
    ];
    const positions = {
      a1: { quantity: 10, costCents: 1000000 }, // R$ 10.000
      a2: { quantity: 100, costCents: 300000 }, // R$ 3.000
    };
    const latestQuotes = {
      a1: 1000,
      a2: 30,
    };

    render(
      <InvestmentGrowthWidget
        assets={assets}
        positions={positions}
        latestQuotes={latestQuotes}
        totalInvested={13000}
        totalGainPercent={14.5}
      />
    );

    expect(screen.getByText("Monitor de Investimentos & Benchmark CDI")).toBeDefined();
    expect(screen.getByText(/118.37% do CDI/i)).toBeDefined();
    expect(screen.getByText(/Renda Fixa:/i)).toBeDefined();
    expect(screen.getByText(/76.9%/i)).toBeDefined();
    expect(screen.getByText(/Renda Variável:/i)).toBeDefined();
    expect(screen.getByText(/23.1%/i)).toBeDefined();
  });

  it("updates compound interest simulation when user adjusts inputs", () => {
    render(
      <InvestmentGrowthWidget
        assets={[]}
        positions={{}}
        latestQuotes={{}}
        totalInvested={10000}
        totalGainPercent={12.0}
      />
    );

    const aporteInput = screen.getByLabelText("Aporte Mensal (R$)");
    fireEvent.change(aporteInput, { target: { value: "1000" } });

    expect(screen.getByText(/Seu desembolso:/i)).toBeDefined();
  });
});

