import { expect, test as setup } from "@playwright/test";

export const STORAGE_STATE = "e2e/.auth/user.json";

setup("autenticar", async ({ page }) => {
  const email = process.env.E2E_EMAIL;
  const password = process.env.E2E_PASSWORD;

  // Credencial ausente nunca falha o run: os testes autenticados simplesmente
  // não rodam. Defina E2E_EMAIL e E2E_PASSWORD no ambiente (veja .env.example)
  // apontando para um usuário de teste criado manualmente no Supabase.
  setup.skip(
    !email || !password,
    "Defina E2E_EMAIL e E2E_PASSWORD no ambiente para rodar os testes autenticados.",
  );

  await page.goto("/entrar", { waitUntil: "networkidle" });
  await page.getByLabel("E-mail").fill(email!);
  await page.getByLabel("Senha").fill(password!);
  await page.getByRole("button", { name: "Entrar" }).click();

  // Sai de /entrar ao autenticar com sucesso.
  await expect(page).not.toHaveURL(/\/entrar/, { timeout: 30_000 });

  await page.context().storageState({ path: STORAGE_STATE });
});
