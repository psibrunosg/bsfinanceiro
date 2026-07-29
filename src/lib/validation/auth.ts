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

export function authLoginErrorMessage(error: { message?: string; code?: string } | null | undefined) {
  const text = `${error?.code ?? ""} ${error?.message ?? ""}`.toLowerCase();

  if (text.includes("email_not_confirmed") || text.includes("email not confirmed")) {
    return "Confirme seu e-mail antes de entrar. Use o link enviado no cadastro.";
  }

  if (text.includes("fetch") || text.includes("network")) {
    return "Nao foi possivel conectar ao servico de acesso. Tente novamente em alguns instantes.";
  }

  return "E-mail ou senha incorretos.";
}
