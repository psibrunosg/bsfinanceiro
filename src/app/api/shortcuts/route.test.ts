import { describe, it, expect, vi, beforeEach } from "vitest";
import { POST } from "./route";
import { NextRequest } from "next/server";

const mockInsert = vi.fn();
const mockSelect = vi.fn();
const mockFrom = vi.fn();

vi.mock("@/lib/supabase/client", () => ({
  createClient: () => ({
    from: mockFrom,
    auth: {
      getUser: vi.fn().mockResolvedValue({ data: { user: { id: "user-123" } } }),
      signInWithPassword: vi.fn().mockResolvedValue({ data: { user: { id: "user-123" } } }),
    },
  }),
}));

describe("POST /api/shortcuts", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockInsert.mockResolvedValue({ error: null });
    mockSelect.mockReturnValue({
      eq: vi.fn().mockReturnValue({
        single: vi.fn().mockResolvedValue({ data: { id: "workspace-123" } }),
        data: [{ id: "acc-1", name: "Conta Principal" }],
      }),
      data: [{ id: "cat-alim", name: "Alimentação" }],
    });
    mockFrom.mockImplementation((table: string) => {
      if (table === "transactions") {
        return { insert: mockInsert };
      }
      if (table === "workspaces") {
        return {
          select: vi.fn().mockReturnValue({
            limit: vi.fn().mockReturnValue({
              single: vi.fn().mockResolvedValue({ data: { id: "workspace-123" } }),
            }),
          }),
        };
      }
      if (table === "accounts") {
        return {
          select: vi.fn().mockReturnValue({
            limit: vi.fn().mockReturnValue({
              data: [{ id: "acc-1", name: "Conta Principal" }],
            }),
          }),
        };
      }
      if (table === "categories") {
        return {
          select: vi.fn().mockResolvedValue({
            data: [
              { id: "cat-alim", name: "Alimentação", kind: "expense" },
              { id: "cat-trans", name: "Transporte", kind: "expense" },
            ],
          }),
        };
      }
      return { select: mockSelect, insert: mockInsert };
    });
  });

  it("returns 401 if token is missing or invalid", async () => {
    const req = new NextRequest("https://financeiro.bssaude.com.br/api/shortcuts", {
      method: "POST",
      body: JSON.stringify({ amount: 50, description: "Café" }),
    });

    const res = await POST(req);
    expect(res.status).toBe(401);
    const data = await res.json();
    expect(data.success).toBe(false);
    expect(data.error).toContain("Token");
  });

  it("returns 400 if amount or description is invalid", async () => {
    const req = new NextRequest("https://financeiro.bssaude.com.br/api/shortcuts", {
      method: "POST",
      headers: { Authorization: "Bearer bsf_shortcut_token_2026" },
      body: JSON.stringify({ amount: 0, description: "" }),
    });

    const res = await POST(req);
    expect(res.status).toBe(400);
    const data = await res.json();
    expect(data.success).toBe(false);
  });

  it("creates a single transaction when installments is 1 or omitted", async () => {
    const req = new NextRequest("https://financeiro.bssaude.com.br/api/shortcuts", {
      method: "POST",
      headers: { Authorization: "Bearer bsf_shortcut_token_2026" },
      body: JSON.stringify({
        amount: 85.50,
        description: "Almoço Restaurante",
        type: "expense",
      }),
    });

    const res = await POST(req);
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.success).toBe(true);
    expect(data.count).toBe(1);

    expect(mockInsert).toHaveBeenCalledTimes(1);
    expect(mockInsert).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          amount: 85.50,
          description: "Almoço Restaurante",
          type: "expense",
        }),
      ])
    );
  });

  it("creates multiple installment transactions when installments > 1", async () => {
    const req = new NextRequest("https://financeiro.bssaude.com.br/api/shortcuts", {
      method: "POST",
      headers: { Authorization: "Bearer bsf_shortcut_token_2026" },
      body: JSON.stringify({
        amount: 300.00,
        description: "Tênis Esportivo",
        installments: 3,
        type: "expense",
        date: "2026-09-08",
      }),
    });

    const res = await POST(req);
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.success).toBe(true);
    expect(data.count).toBe(3);

    expect(mockInsert).toHaveBeenCalledTimes(1);
    const insertedRows = mockInsert.mock.calls[0][0];
    expect(insertedRows).toHaveLength(3);

    expect(insertedRows[0].description).toBe("Tênis Esportivo (1/3)");
    expect(insertedRows[0].amount).toBe(100.00);
    expect(insertedRows[0].competence_date).toBe("2026-09-08");

    expect(insertedRows[1].description).toBe("Tênis Esportivo (2/3)");
    expect(insertedRows[1].amount).toBe(100.00);
    expect(insertedRows[1].competence_date).toBe("2026-10-08");

    expect(insertedRows[2].description).toBe("Tênis Esportivo (3/3)");
    expect(insertedRows[2].amount).toBe(100.00);
    expect(insertedRows[2].competence_date).toBe("2026-11-08");
  });

  it("parses raw bank notification if notif is provided", async () => {
    const req = new NextRequest("https://financeiro.bssaude.com.br/api/shortcuts", {
      method: "POST",
      headers: { Authorization: "Bearer bsf_shortcut_token_2026" },
      body: JSON.stringify({
        notif: "Compra de R$ 42,90 aprovada no Nubank em Padaria Estrela.",
      }),
    });

    const res = await POST(req);
    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.success).toBe(true);
    expect(data.count).toBe(1);

    const insertedRows = mockInsert.mock.calls[0][0];
    expect(insertedRows[0].amount).toBe(42.90);
    expect(insertedRows[0].description).toBe("Padaria Estrela");
    expect(insertedRows[0].type).toBe("expense");
  });
});
