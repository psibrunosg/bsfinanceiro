// @vitest-environment jsdom
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { beforeEach, describe, expect, it, vi } from "vitest";

const mocks = vi.hoisted(() => ({
  rpc: vi.fn(), upload: vi.fn(), invoke: vi.fn(), toast: vi.fn(), file: null as File | null,
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
      void onSubmit({ get: (name: string) => name === "document" ? mocks.file : null } as unknown as FormData);
    }}>{children}</form>
  ),
}));
vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    auth: { getUser: async () => ({ data: { user: { id: "owner-a" } } }) },
    from: (table: string) => chain(table === "financial_contexts" ? [{ id: "context-a", kind: "pessoal", name: "Pessoal" }] : []),
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
  beforeEach(() => {
    mocks.rpc.mockReset(); mocks.upload.mockReset(); mocks.invoke.mockReset(); mocks.toast.mockReset();
    mocks.file = { name: "contracheque.pdf", size: 8, type: "application/pdf", arrayBuffer: () => Promise.resolve(new TextEncoder().encode("%PDF-1.4").buffer) } as File;
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
});
