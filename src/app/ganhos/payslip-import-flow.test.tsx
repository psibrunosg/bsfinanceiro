// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  rpc: vi.fn(), upload: vi.fn(), invoke: vi.fn(), toast: vi.fn(), file: null as File | null,
  imports: [] as Record<string, unknown>[],
  payslips: [] as Record<string, unknown>[],
}));

vi.mock("../components/useWorkspaceBasics", () => ({
  useWorkspaceBasics: () => ({
    workspace: { id: "workspace-a", name: "Pessoal" }, loading: false, defaultCashAccountId: "cash-a",
    accounts: [{ id: "cash-a", name: "Conta", type: "checking", initial_balance: 0 }, { id: "investment-a", name: "Investimento", type: "investment", initial_balance: 0 }],
    categories: [], reload: vi.fn(), ownerId: "owner-a",
  }),
}));
vi.mock("../components/Nav", () => ({ Nav: () => null }));
vi.mock("../components/PageHeader", () => ({ PageHeader: () => null }));
vi.mock("../components/List", () => ({ List: ({ children }: { children: React.ReactNode }) => <section>{children}</section> }));
vi.mock("../components/Dialog", () => ({ Dialog: ({ open, children }: { open: boolean; children: React.ReactNode }) => open ? <div>{children}</div> : null }));
vi.mock("../components/DashboardChart", () => ({ DashboardChart: () => null }));
vi.mock("../components/PeriodFilter", () => ({ PeriodFilter: () => null, periodRange: () => ({}), }));
vi.mock("../components/Toast", () => ({ useToast: () => ({ toast: mocks.toast }) }));
vi.mock("../components/SimpleForm", () => ({
  SimpleForm: ({ children, onSubmit }: { children: React.ReactNode; onSubmit: (data: FormData) => Promise<void> }) => (
    <form noValidate onSubmit={(event) => {
      event.preventDefault();
      const data = new FormData(event.currentTarget);
      const get = data.get.bind(data);
      data.get = (name) => name === "document" && mocks.file ? mocks.file : get(name);
      void onSubmit(data);
    }}>{children}</form>
  ),
}));
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: { getUser: async () => ({ data: { user: { id: "owner-a" } } }) },
    from: (table: string) => chain(table === "financial_contexts" ? [{ id: "context-a", kind: "pessoal", name: "Pessoal" }] : table === "payslip_document_imports" ? mocks.imports : table === "payslips" ? mocks.payslips : []),
    storage: { from: () => ({ upload: mocks.upload, createSignedUrl: vi.fn() }) },
    rpc: mocks.rpc,
    functions: { invoke: mocks.invoke },
  }),
}));

function chain(data: unknown[]) {
  const value = { data };
  const api: Record<string, unknown> = {};
  for (const method of ["select", "eq", "order", "limit", "not"]) api[method] = () => api;
  api.then = (resolve: (result: typeof value) => unknown) => Promise.resolve(value).then(resolve);
  return api;
}

import GanhosPage from "./page";

describe("payslip PDF import UI", () => {
  afterEach(cleanup);

  beforeEach(() => {
    mocks.rpc.mockReset(); mocks.upload.mockReset(); mocks.invoke.mockReset(); mocks.toast.mockReset();
    mocks.file = { name: "contracheque.pdf", size: 8, type: "application/pdf", arrayBuffer: () => Promise.resolve(new TextEncoder().encode("%PDF-1.4").buffer) } as File;
    mocks.imports = [];
    mocks.payslips = [];
    mocks.rpc.mockImplementation((name: string) => name === "create_payslip_document_import"
      ? Promise.resolve({ data: [{ id: "import-a", storage_path: "owner-a/import-a/a.pdf", status: "pending" }], error: null })
      : Promise.resolve({ data: null, error: null }));
    mocks.upload.mockResolvedValue({ error: null });
    mocks.invoke.mockResolvedValue({ error: null });
  });

  it("creates, uploads, queues and invokes a PDF import without changing the manual form", async () => {
    const view = render(<GanhosPage />);
    fireEvent.click(await screen.findByRole("button", { name: "Contracheques" }));
    expect(screen.getByRole("button", { name: "Cadastrar primeiro contracheque" })).toBeTruthy();
    fireEvent.click(await screen.findByText("Importar PDF"));
    fireEvent.click(screen.getAllByRole("button", { name: "Importar PDF" })[1]);
    await waitFor(() => expect(mocks.upload).toHaveBeenCalled());
    expect(mocks.rpc.mock.calls.map(([name]) => name)).toEqual(["create_payslip_document_import", "queue_payslip_document_import"]);
    expect(mocks.invoke).toHaveBeenCalledWith("process-payslip-document-import", { body: { importId: "import-a" } });
    await waitFor(() => expect(screen.queryByLabelText("PDF do contracheque")).toBeNull());
    await new Promise((resolve) => setTimeout(resolve, 25));
    view.unmount();
  });

  async function openReview() {
    mocks.imports = [{ id: "import-a", file_name: "contracheque.pdf", status: "pending_review", error_code: null, employer: "ACME", competence: "2026-07-01", gross_amount_cents: 500000, discounts_amount_cents: 125000, net_amount_cents: 375000, source_fingerprint: "a".repeat(64), result_payslip_id: null }];
    render(<GanhosPage />);
    fireEvent.click(await screen.findByRole("button", { name: "Contracheques" }));
    fireEvent.click(await screen.findByRole("button", { name: "Revisar" }));
    await screen.findByRole("button", { name: "Confirmar contracheque" });
  }

  it("confirms reviewed cents without creating income", async () => {
    await openReview();
    fireEvent.click(screen.getByRole("button", { name: "Confirmar contracheque" }));
    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith("apply_payslip_document_import", expect.objectContaining({
      p_import_id: "import-a", p_received_date: null, p_account_id: null, p_context_id: "context-a",
      p_candidate: expect.objectContaining({ employer: "ACME", competence: "2026-07-01", grossAmountCents: 500000, discountsAmountCents: 125000, netAmountCents: 375000, sourceFingerprint: "a".repeat(64) }),
    })));
  });

  it("confirms reviewed cents with receipt income", async () => {
    await openReview();
    fireEvent.change(screen.getByLabelText("Data de recebimento (opcional)"), { target: { value: "2026-07-31" } });
    fireEvent.change(screen.getByLabelText("Conta de recebimento (opcional)"), { target: { value: "cash-a" } });
    fireEvent.click(screen.getByRole("button", { name: "Confirmar contracheque" }));
    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledWith("apply_payslip_document_import", expect.objectContaining({ p_received_date: "2026-07-31", p_account_id: "cash-a" })));
  });

  it("keeps the review draft open for duplicate errors and permits replay", async () => {
    mocks.rpc.mockImplementation((name: string) => name === "apply_payslip_document_import"
      ? Promise.resolve({ data: null, error: { message: "duplicate_payslip" } })
      : Promise.resolve({ data: null, error: null }));
    await openReview();
    fireEvent.click(screen.getByRole("button", { name: "Confirmar contracheque" }));
    await waitFor(() => expect(mocks.toast).toHaveBeenCalledWith("Já existe um contracheque para este empregador e competência.", "error"));
    expect((screen.getByLabelText("Empregador") as HTMLInputElement).value).toBe("ACME");
    mocks.rpc.mockImplementation(() => Promise.resolve({ data: "payslip-a", error: null }));
    fireEvent.click(screen.getByRole("button", { name: "Confirmar contracheque" }));
    await waitFor(() => expect(mocks.rpc).toHaveBeenCalledTimes(2));
  });

  it.each(["pending", "processing"])("retries already uploaded %s jobs", async (status) => {
    mocks.rpc.mockImplementation((name: string) => name === "create_payslip_document_import"
      ? Promise.resolve({ data: [{ id: "import-a", storage_path: "owner-a/import-a/a.pdf", status }], error: null })
      : Promise.resolve({ data: null, error: null }));
    mocks.upload.mockResolvedValue({ error: { message: "already exists" } });
    render(<GanhosPage />);
    fireEvent.click(await screen.findByRole("button", { name: "Contracheques" }));
    fireEvent.click(await screen.findByText("Importar PDF"));
    fireEvent.click(screen.getAllByRole("button", { name: "Importar PDF" })[1]);
    await waitFor(() => expect(mocks.invoke).toHaveBeenCalledWith("process-payslip-document-import", { body: { importId: "import-a" } }));
    if (status === "pending") expect(mocks.rpc).toHaveBeenCalledWith("queue_payslip_document_import", { p_import_id: "import-a" });
    else expect(mocks.upload).not.toHaveBeenCalled();
  });

  it("explains why a terminal imported payslip stays intact", async () => {
    mocks.payslips = [{ id: "payslip-a", employer: "ACME", competence: "2026-08-01", gross_amount: 5000, discounts_amount: 1250, net_amount: 3750, received_date: "2026-08-01", transaction_id: "income-a", pdf_path: null, notes: null, created_at: "2026-08-01" }];
    mocks.rpc.mockImplementation((name: string) => name === "delete_payslip"
      ? Promise.resolve({ data: null, error: { message: "imported payslip cannot be deleted" } })
      : Promise.resolve({ data: null, error: null }));
    render(<GanhosPage />);
    fireEvent.click(await screen.findByRole("button", { name: "Contracheques" }));
    fireEvent.click(await screen.findByRole("button", { name: "Excluir contracheque" }));
    fireEvent.click(screen.getAllByRole("button", { name: "Excluir contracheque" })[1]);
    await waitFor(() => expect(mocks.toast).toHaveBeenCalledWith("Este contracheque veio de uma importação confirmada e não pode ser excluído.", "error"));
  });
});
