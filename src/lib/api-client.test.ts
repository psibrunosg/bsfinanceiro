// @vitest-environment jsdom
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { apiFetch } from "./api-client";
const fetchMock = vi.fn();
beforeEach(() => { fetchMock.mockReset(); vi.stubGlobal("fetch", fetchMock); localStorage.setItem("bsfinanceiro_token", "own-token"); });
afterEach(() => { vi.unstubAllGlobals(); localStorage.clear(); });
describe("API client mutation retries", () => {
  it("retains a receipt key across ambiguous failures and renews it after success", async () => {
    fetchMock.mockRejectedValueOnce(new Error("connection lost"))
      .mockResolvedValueOnce(new Response("{}", { status: 500 }))
      .mockImplementation(async () => new Response('{"success":true}', { status: 200 }));
    const options = { method: "POST", body: JSON.stringify({ amount: 123 }) };
    await expect(apiFetch("/api/investments/operations", options)).rejects.toThrow("connection lost");
    await apiFetch("/api/investments/operations", options);
    await apiFetch("/api/investments/operations", options);
    await apiFetch("/api/investments/operations", options);
    const headers = fetchMock.mock.calls.map(([, init]) => init.headers as Headers);
    const key = headers[0].get("X-Idempotency-Key");
    expect(key).toMatch(/^[a-f0-9-]{36}$/);
    expect(headers[1].get("X-Idempotency-Key")).toBe(key);
    expect(headers[2].get("X-Idempotency-Key")).toBe(key);
    expect(headers[3].get("X-Idempotency-Key")).not.toBe(key);
    expect(headers[0].get("Authorization")).toBe("Bearer own-token");
  });
  it("retains the same key for multipart retries despite distinct FormData objects", async () => {
    fetchMock.mockRejectedValueOnce(new Error("offline"))
      .mockImplementation(async () => new Response('{"success":true}', { status: 200 }));
    const form = () => { const value = new FormData(); value.set("employer", "Empresa"); value.set("pdf", new File(["%PDF-test"], "p.pdf", { lastModified: 123 })); return value; };
    await expect(apiFetch("/api/payslips", { method: "POST", body: form() })).rejects.toThrow();
    await apiFetch("/api/payslips", { method: "POST", body: form() });
    expect(fetchMock.mock.calls[0][1].headers.get("X-Idempotency-Key")).toBe(fetchMock.mock.calls[1][1].headers.get("X-Idempotency-Key"));
  });
  it("retains the key when success headers arrive but the JSON body is truncated", async () => {
    fetchMock.mockResolvedValueOnce(new Response('{"success":', { status: 200 }))
      .mockImplementation(async () => new Response('{"success":true}', { status: 200 }));
    const options = { method: "POST", body: JSON.stringify({ employer: "Truncated" }) };
    await apiFetch("/api/payslips", options);
    await apiFetch("/api/payslips", options);
    expect(fetchMock.mock.calls[0][1].headers.get("X-Idempotency-Key")).toBe(fetchMock.mock.calls[1][1].headers.get("X-Idempotency-Key"));
  });
});
