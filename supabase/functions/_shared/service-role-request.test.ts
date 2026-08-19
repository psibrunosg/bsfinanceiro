import { describe, expect, it } from "vitest";
import { isVerifiedServiceRoleRequest } from "./service-role-request";

const token = (payload: unknown) => `x.${Buffer.from(JSON.stringify(payload)).toString("base64url")}.y`;

describe("isVerifiedServiceRoleRequest", () => {
  it("accepts only a service_role JWT already verified by the gateway", () => {
    expect(isVerifiedServiceRoleRequest(new Request("https://example.test", { headers: { Authorization: `Bearer ${token({ role: "service_role" })}` } }))).toBe(true);
    expect(isVerifiedServiceRoleRequest(new Request("https://example.test", { headers: { Authorization: `Bearer ${token({ role: "authenticated" })}` } }))).toBe(false);
    expect(isVerifiedServiceRoleRequest(new Request("https://example.test", { headers: { Authorization: "Bearer malformed" } }))).toBe(false);
  });
});
