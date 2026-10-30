// @vitest-environment jsdom
import React from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import GanhosPage from "./page";
import { apiFetch } from "@/lib/api-client";

const state = vi.hoisted(() => ({ workspace: { id: "space-a", name: "Finanças" }, file: null as File | null }));
vi.mock("@/lib/api-client", () => ({ apiFetch: vi.fn() }));
vi.mock("../components/useFinance", () => ({ useFinance: () => ({ workspace: state.workspace, accounts: [{ id: "account-a", name: "Conta" }], transactions: [], categories: [], defaultCashAccountId: "account-a", loading: false }) }));
vi.mock("../components/MonthContext", () => ({ useMonth: () => ({ month: "2026-10-01", nextMonth: "2026-11-01", label: "Outubro" }) }));
vi.mock("../components/Nav", () => ({ Nav: () => null }));
vi.mock("../components/MonthPicker", () => ({ MonthPicker: () => null }));
vi.mock("../components/DashboardChart", () => ({ DashboardChart: () => null }));
vi.mock("../components/PageHeader", () => ({ PageHeader: ({ action }: { action?: { label: string; onClick: () => void } }) => action ? <button onClick={action.onClick}>{action.label}</button> : null }));
vi.mock("../components/Dialog", () => ({ Dialog: ({ open, children }: { open: boolean; children: React.ReactNode }) => open ? <div role="dialog">{children}</div> : null }));
vi.mock("../components/SimpleForm", () => ({ SimpleForm: ({ children, onSubmit }: { children: React.ReactNode; onSubmit: (form: FormData) => Promise<void> }) => <form onSubmit={event => {
  event.preventDefault(); const form = new FormData(event.currentTarget);
  if (state.file) form.set("pdf", state.file);
  void onSubmit(form);
}}>{children}</form> }));

const emptyHub = { patients: [], patient_earnings: [], payslips: [], transactions: [] };
function response(body: unknown, ok = true, type = "application/json") {
  return { ok, json: async () => body, headers: new Headers({ "Content-Type": type }), blob: async () => new Blob(["%PDF-1.7"], { type }) } as Response;
}
beforeEach(() => {
  state.file = null; vi.mocked(apiFetch).mockReset();
  vi.mocked(apiFetch).mockResolvedValue(response(emptyHub));
});
afterEach(() => { cleanup(); vi.restoreAllMocks(); });
async function openTab(name: string) {
  render(<GanhosPage />); fireEvent.click(await screen.findByRole("button", { name }));
}
async function openPayslipForm() {
  await openTab("Contracheques");
  fireEvent.click(screen.getByRole("button", { name: "Cadastrar contracheque" }));
  fireEvent.change(screen.getByLabelText("Empregador"), { target: { value: "Empresa" } });
  fireEvent.change(screen.getByLabelText("Competência"), { target: { value: "2026-10-01" } });
  fireEvent.change(screen.getByLabelText("Valor bruto"), { target: { value: "1000,00" } });
  fireEvent.change(screen.getByLabelText("Valor líquido"), { target: { value: "900,00" } });
}

describe("GanhosPage VPS-only contracts", () => {
  it("renders bootstrap failure without a second provider or hidden fallback", async () => {
    vi.mocked(apiFetch).mockResolvedValue(response({ error: "offline" }, false));
    render(<GanhosPage />);
    expect(await screen.findByText("Não foi possível carregar os ganhos. Tente novamente.")).toBeDefined();
    expect(vi.mocked(apiFetch).mock.calls.map(([url]) => url)).toEqual(["/api/bootstrap?workspace_id=space-a"]);
  });

  it.each([true, false])("submits patient through VPS and handles success=%s without fallback", async success => {
    vi.mocked(apiFetch).mockImplementation(async (url) => url === "/api/patients" ? response(success ? { success: true } : { error: "Não autorizado" }, success) : response(emptyHub));
    await openTab("Pacientes");
    fireEvent.click(screen.getByRole("button", { name: "Cadastrar paciente" }));
    const name = screen.getByLabelText("Nome completo");
    fireEvent.change(name, { target: { value: "Ana Silva" } }); fireEvent.submit(name.closest("form")!);
    expect(await screen.findByText(success ? "Paciente cadastrado." : "Não autorizado")).toBeDefined();
    const requests = vi.mocked(apiFetch).mock.calls.filter(([url]) => url === "/api/patients");
    expect(requests).toHaveLength(1);
    expect(JSON.parse(requests[0][1]!.body as string)).toEqual({ workspace_id: "space-a", name: "Ana Silva", full_name: "Ana Silva" });
    expect(vi.mocked(apiFetch).mock.calls.every(([url]) => String(url).startsWith("/api/"))).toBe(true);
    expect(screen.queryByRole("dialog") !== null).toBe(!success);
  });

  it("sends payslip PDF and financial fields in multipart without overriding Content-Type", async () => {
    vi.mocked(apiFetch).mockImplementation(async url => url === "/api/payslips" ? response({ success: true }) : response(emptyHub));
    await openPayslipForm(); state.file = new File(["%PDF-1.7"], "folha.pdf", { type: "application/pdf" });
    fireEvent.submit(screen.getByLabelText("Empregador").closest("form")!);
    expect(await screen.findByText("Contracheque cadastrado.")).toBeDefined();
    const request = vi.mocked(apiFetch).mock.calls.find(([url]) => url === "/api/payslips")!;
    expect(request[1]!.body).toBeInstanceOf(FormData);
    const body = request[1]!.body as FormData;
    expect(body.get("workspace_id")).toBe("space-a"); expect(body.get("gross_amount")).toBe("1000");
    expect((body.get("pdf") as File).type).toBe("application/pdf"); expect(request[1]!.headers).toBeUndefined();
  });

  it.each(["mime", "size"])("rejects invalid PDF %s before uploading", async invalid => {
    await openPayslipForm(); state.file = new File(["file"], "folha.pdf", { type: invalid === "mime" ? "text/plain" : "application/pdf" });
    if (invalid === "size") Object.defineProperty(state.file, "size", { value: 10 * 1024 * 1024 + 1 });
    fireEvent.submit(screen.getByLabelText("Empregador").closest("form")!);
    expect(await screen.findByText(invalid === "mime" ? "O arquivo deve ser um PDF." : "O PDF deve ter no máximo 10 MB.")).toBeDefined();
    expect(vi.mocked(apiFetch).mock.calls.some(([url]) => url === "/api/payslips")).toBe(false);
  });

  it.each(["application/pdf", "text/html"])("opens document by payslip id and validates MIME %s", async mime => {
    const payslip = { id: "payslip-id", employer: "Empresa", competence: "2026-10-01", gross_amount: "1000", discounts_amount: "100", net_amount: "900", received_date: null, transaction_id: null, pdf_path: "private/arbitrary-secret-path", notes: null, created_at: "2026-10-01" };
    vi.mocked(apiFetch).mockImplementation(async url => url === "/api/payslips/payslip-id/document" ? response({}, true, mime) : response({ ...emptyHub, payslips: [payslip] }));
    const createUrl = vi.fn().mockReturnValue("blob:document");
    Object.defineProperty(URL, "createObjectURL", { value: createUrl, configurable: true });
    Object.defineProperty(URL, "revokeObjectURL", { value: vi.fn(), configurable: true });
    const anchorClick = vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => {});
    await openTab("Contracheques"); fireEvent.click(screen.getByRole("button", { name: "PDF" }));
    await waitFor(() => expect(apiFetch).toHaveBeenCalledWith("/api/payslips/payslip-id/document"));
    if (mime === "application/pdf") { await waitFor(() => expect(anchorClick).toHaveBeenCalled()); expect(createUrl).toHaveBeenCalled(); }
    else { expect(await screen.findByText("Não foi possível abrir o PDF. Tente novamente.")).toBeDefined(); expect(createUrl).not.toHaveBeenCalled(); expect(anchorClick).not.toHaveBeenCalled(); }
    expect(vi.mocked(apiFetch).mock.calls.some(([url]) => String(url).includes("arbitrary-secret-path"))).toBe(false);
  });
});

