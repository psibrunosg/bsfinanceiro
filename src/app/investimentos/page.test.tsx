// @vitest-environment jsdom
import React from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import InvestimentosPage from "./page";
import { apiFetch } from "@/lib/api-client";
const workspace = { id: "w-1", name: "Pessoal" };
vi.mock("@/lib/api-client", () => ({ apiFetch: vi.fn() }));
vi.mock("../components/useFinance", () => ({ useFinance: () => ({ workspace, accounts: [{ id: "a-1", name: "Conta" }], defaultCashAccountId: "a-1", loading: false }) }));
vi.mock("../components/Nav", () => ({ Nav: () => null }));
vi.mock("../components/InvestmentGrowthWidget", () => ({ InvestmentGrowthWidget: () => null }));
vi.mock("../components/FireDashboardWidget", () => ({ FireDashboardWidget: () => null }));
vi.mock("../components/Dialog", () => ({ Dialog: ({ open, children }: { open: boolean; children: React.ReactNode }) => open ? <div>{children}</div> : null }));
const response = (body: unknown, ok = true) => ({ ok, json: async () => body }) as Response;
beforeEach(() => {
  vi.mocked(apiFetch).mockReset();
  vi.mocked(apiFetch).mockImplementation(async (url) => String(url).startsWith("/api/bootstrap") ? response({ investments: [], investment_operations: [], investment_quotes: [] }) : response({}));
});
afterEach(cleanup);
async function submitAsset() {
  fireEvent.click(await screen.findByRole("button", { name: "Cadastrar ativo" }));
  fireEvent.change(screen.getByLabelText(/Ticker/), { target: { value: "PETR4" } });
  fireEvent.change(screen.getByLabelText("Nome amigável / Descrição"), { target: { value: "Petrobras" } });
  fireEvent.submit(screen.getByLabelText("Nome amigável / Descrição").closest("form")!);
}
describe("Investimentos VPS-only", () => {
  it("confirms asset creation through the VPS and reloads the hub", async () => {
    vi.mocked(apiFetch).mockImplementation(async (url, options) => options?.method === "POST" ? response({ success: true }) : String(url).startsWith("/api/bootstrap") ? response({ investments: [], investment_operations: [], investment_quotes: [] }) : response({}));
    render(<InvestimentosPage />);
    await submitAsset();
    await waitFor(() => expect(screen.getByRole("status").textContent).toContain("cadastrado com sucesso"));
    expect(screen.queryByLabelText("Nome amigável / Descrição")).toBeNull();
    expect(vi.mocked(apiFetch).mock.calls.filter(([url]) => String(url).startsWith("/api/bootstrap")).length).toBeGreaterThan(1);
  });
  it("renders bootstrap failure without a second backend", async () => {
    vi.mocked(apiFetch).mockRejectedValue(new Error("VPS indisponível"));
    render(<InvestimentosPage />);
    await screen.findByRole("alert");
    expect(screen.getByRole("alert").textContent).toContain("VPS indisponível");
    expect(apiFetch).toHaveBeenCalledTimes(2);
  });
  it.each(["HTTP", "network"])("keeps asset form open after %s failure", async (failure) => {
    vi.mocked(apiFetch).mockImplementation(async (url, options) => {
      if (options?.method === "POST") {
        if (failure === "network") throw new Error("Conexão perdida");
        return response({ error: "Sem permissão" }, false);
      }
      return String(url).startsWith("/api/bootstrap") ? response({ investments: [], investment_operations: [], investment_quotes: [] }) : response({});
    });
    render(<InvestimentosPage />);
    await submitAsset();
    await waitFor(() => expect(screen.getByRole("alert").textContent).toContain(failure === "HTTP" ? "Sem permissão" : "Conexão perdida"));
    expect(screen.getByLabelText("Nome amigável / Descrição")).toBeTruthy();
    const writes = vi.mocked(apiFetch).mock.calls.filter(([, options]) => options?.method === "POST");
    expect(writes).toHaveLength(1);
    expect(JSON.parse(writes[0][1]!.body as string)).toMatchObject({ workspace_id: "w-1", ticker: "PETR4" });
  });
});


