// @vitest-environment jsdom
import { fireEvent, render, screen, waitFor, cleanup } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { apiFetch } from "@/lib/api-client";
import { CardStatementReview } from "./CardStatementReview";
vi.mock("@/lib/api-client", () => ({ apiFetch: vi.fn() }));
afterEach(cleanup);
const item = { ordinal: 1, description: "LIVRARIA", purchasedOn: "2026-08-12", installmentAmountCents: 10000, installmentNumber: 2, installmentCount: 3, totalAmountCents: null, needsReview: true, sourceFingerprint: "abc" };
describe("CardStatementReview", () => {
  it("requires a missing total and submits the reviewed items to the authenticated VPS route", async () => {
    vi.mocked(apiFetch).mockImplementation(async (_url, init) => ({ ok: true, json: async () => init?.method === "POST" ? { success: true } : [{ id: "job", credit_card_id: "card", file_name: "fatura.pdf", status: "pending_review", declared_total_cents: 10000, items: [item] }] } as Response));
    const reload = vi.fn().mockResolvedValue(undefined);
    render(<CardStatementReview workspaceId="space" cardId="card" version={0} onApplied={reload} />);
    const total = await screen.findByLabelText("Total da compra 1");
    expect((screen.getByText("Confirmar compras revisadas") as HTMLButtonElement).disabled).toBe(true);
    fireEvent.change(total, { target: { value: "300" } });
    fireEvent.click(screen.getByText("Confirmar compras revisadas"));
    await waitFor(() => expect(reload).toHaveBeenCalled());
    const request = vi.mocked(apiFetch).mock.calls.find(([url]) => url === "/api/card-statement-imports/job/apply");
    expect(JSON.parse(request![1]!.body as string).items[0].totalAmountCents).toBe(30000);
  });
  it("keeps errors visible when the server rejects confirmation", async () => {
    vi.mocked(apiFetch).mockImplementation(async (_url, init) => ({ ok: !init?.method, json: async () => init?.method ? { error: "Compra duplicada" } : [{ id: "job", credit_card_id: "card", file_name: "fatura.pdf", status: "pending_review", declared_total_cents: 10000, items: [{ ...item, totalAmountCents: 30000 }] }] } as Response));
    render(<CardStatementReview workspaceId="space" cardId="card" version={0} onApplied={vi.fn()} />);
    fireEvent.click(await screen.findByText("Confirmar compras revisadas"));
    expect(await screen.findByText("Compra duplicada")).toBeDefined();
  });
});
