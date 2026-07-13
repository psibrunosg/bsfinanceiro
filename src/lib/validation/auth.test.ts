import { describe, expect, it } from "vitest";
import { authSchema } from "./auth";

describe("authSchema", () => {
  it("aceita e-mail e senha validos", () => {
    const result = authSchema.safeParse({
      email: "bruno@example.com",
      password: "segura123",
    });

    expect(result.success).toBe(true);
  });

  it("rejeita e-mail invalido com mensagem em portugues", () => {
    const result = authSchema.safeParse({
      email: "email-invalido",
      password: "segura123",
    });

    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.message).toBe("Informe um e-mail válido.");
    }
  });

  it("exige senha com pelo menos oito caracteres", () => {
    const result = authSchema.safeParse({
      email: "bruno@example.com",
      password: "curta",
    });

    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.message).toBe("Use pelo menos 8 caracteres.");
    }
  });
});
