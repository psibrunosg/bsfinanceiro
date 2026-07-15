import { z } from "zod";

export const authSchema = z.object({
  email: z.string().email("Informe um e-mail valido."),
  password: z.string().min(8, "Use pelo menos 8 caracteres."),
});

export function authErrorMessage(error: { message?: string; code?: string } | null | undefined) {
  const text = `${error?.code ?? ""} ${error?.message ?? ""}`.toLowerCase();

  if (text.includes("rate limit")) {
    return "Muitas tentativas de envio de e-mail. Aguarde alguns minutos e tente novamente.";
  }

  if (text.includes("invalid") && text.includes("email")) {
    return "Use um e-mail valido para criar a conta.";
  }

  if (text.includes("already") || text.includes("registered")) {
    return "Este e-mail ja esta cadastrado. Tente entrar.";
  }

  return "Nao foi possivel criar a conta. Tente novamente.";
}
