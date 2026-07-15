import { describe, expect, it } from "vitest";
import { authErrorMessage, authSchema } from "./auth";

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
      expect(result.error.issues[0]?.message).toBe("Informe um e-mail valido.");
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

  it("traduz erros comuns do Supabase Auth", () => {
    expect(authErrorMessage({ code: "over_email_send_rate_limit", message: "email rate limit exceeded" })).toBe(
      "Muitas tentativas de envio de e-mail. Aguarde alguns minutos e tente novamente.",
    );
    expect(authErrorMessage({ message: "Email address is invalid" })).toBe(
      "Use um e-mail valido para criar a conta.",
    );
    expect(authErrorMessage({ message: "User already registered" })).toBe(
      "Este e-mail ja esta cadastrado. Tente entrar.",
    );
  });
});
