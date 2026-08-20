import { test, expect } from "@playwright/test";

// Credencial NUNCA no arquivo: este spec ja teve e-mail e senha em texto claro
// commitados (8594c31), o que exigiu rotacao. Le do ambiente, igual ao
// auth.setup.ts, e pula quando ausente — assim nunca falha por falta de segredo.
const EMAIL = process.env.E2E_EMAIL;
const PASSWORD = process.env.E2E_PASSWORD;

test.describe("QA Dashboard", () => {
  test.skip(
    !EMAIL || !PASSWORD,
    "Defina E2E_EMAIL e E2E_PASSWORD no ambiente para rodar este teste.",
  );

  test("Fluxo completo do Dashboard", async ({ page }) => {
    test.setTimeout(60000);

    await page.goto("/entrar");
    await expect(page.getByRole("heading", { name: "Entre na sua conta" })).toBeVisible({ timeout: 10000 });

    await page.getByLabel("E-mail").fill(EMAIL!);
    await page.getByLabel("Senha").fill(PASSWORD!);
    await page.getByRole("button", { name: "Entrar" }).click();

    await expect(page).not.toHaveURL(/\/entrar/, { timeout: 30_000 });

    // O app e dark-only desde a consolidacao do design system: nao ha mais
    // botao "Alternar tema" nem ThemeProvider.
    await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");

    // Sistema visual novo: faixa de metricas em .bento-row + .metric-card.
    await expect(page.locator(".bento-row .metric-card").first()).toBeVisible({ timeout: 30_000 });
    await expect(page.getByText("Patrimônio líquido")).toBeVisible();

    const novaMovimentacao = page.getByRole("button", { name: "Nova movimentação" });
    await expect(novaMovimentacao).toBeVisible();
    await novaMovimentacao.click();

    const dialog = page.getByRole("dialog", { name: "Nova movimentação" });
    await expect(dialog).toBeVisible();

    await page.getByLabel("Descrição").fill("QA Automático");
    await page.getByLabel("Valor").fill("15,00");

    // Escape fecha sem gravar: nenhum dado real e inserido.
    await page.keyboard.press("Escape");
    await expect(dialog).not.toBeVisible();
  });
});
