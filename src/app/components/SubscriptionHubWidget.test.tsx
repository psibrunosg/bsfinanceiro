// @vitest-environment jsdom
import { describe, it, expect, afterEach } from "vitest";
import { render, screen, cleanup, fireEvent } from "@testing-library/react";
import { SubscriptionHubWidget } from "./SubscriptionHubWidget";

describe("SubscriptionHubWidget", () => {
  afterEach(() => {
    cleanup();
  });

  it("renders subscription metrics, annualized cost, and detected list", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Netflix Mensalidade",
        amount: 55.9,
        competence_date: "2026-08-10",
      },
      {
        id: "tx-2",
        description: "Spotify Premium",
        amount: 21.9,
        competence_date: "2026-08-15",
      },
    ];

    render(<SubscriptionHubWidget transactions={txs} />);

    expect(screen.getByText("Hub de Assinaturas & Recorrências")).toBeDefined();
    expect(screen.getByText(/Custo Anualizado:/i)).toBeDefined();
    expect(screen.getByText("Netflix")).toBeDefined();
    expect(screen.getByText("Spotify")).toBeDefined();
  });

  it("allows selecting a service to simulate cancellation savings in CDI", () => {
    const txs = [
      {
        id: "tx-1",
        description: "Netflix Mensalidade",
        amount: 55.9,
        competence_date: "2026-08-10",
      },
    ];

    render(<SubscriptionHubWidget transactions={txs} />);

    const netflixCard = screen.getByText("Netflix");
    fireEvent.click(netflixCard);

    expect(screen.getByText(/Potencial de Investimento/i)).toBeDefined();
  });
});
