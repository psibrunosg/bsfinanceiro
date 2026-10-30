// @vitest-environment jsdom
import React from "react";
import { cleanup, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import SharedReportPage from "./page";
let token: string | null = "abc&def";
vi.mock("next/navigation", () => ({ useSearchParams: () => new URLSearchParams(token ? { token } : {}) }));
vi.mock("@/app/components/PrintButton", () => ({ PrintButton: () => null }));
const fetchMock = vi.fn();
beforeEach(() => { token = "abc&def"; fetchMock.mockReset(); vi.stubGlobal("fetch", fetchMock); });
afterEach(() => { cleanup(); vi.unstubAllGlobals(); });
describe("public shared report", () => {
  it("reads the VPS snapshot without sending a session", async () => {
    fetchMock.mockResolvedValue({ ok: true, json: async () => ({ success: true, data: {
      report: { name: "Consolidado" }, transactions: [{ id: "t", type: "income", amount: "100.00", competence_date: "2026-10-01", description: "Salário" }],
    } }) });
    render(<SharedReportPage />);
    expect(await screen.findByText("Relatório Compartilhado: Consolidado")).toBeTruthy();
    expect(fetchMock).toHaveBeenCalledWith("/api/reports/shared?token=abc%26def", expect.objectContaining({ credentials: "omit" }));
    expect(fetchMock.mock.calls[0][1].headers).toBeUndefined();
  });
  it.each(["http", "network", "malformed"])("keeps the existing invalid-link message after %s failure", async (failure) => {
    if (failure === "network") fetchMock.mockRejectedValue(new Error("offline"));
    else fetchMock.mockResolvedValue({ ok: failure !== "http", json: async () => ({}) });
    render(<SharedReportPage />);
    expect(await screen.findByText("Relatório não encontrado ou link inválido.")).toBeTruthy();
  });
  it("does not fetch without a token", async () => {
    token = null; render(<SharedReportPage />);
    await waitFor(() => expect(screen.getByText("Relatório não encontrado ou link inválido.")).toBeTruthy());
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
