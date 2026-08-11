import { expect, test } from "@playwright/test";

test.setTimeout(120000);

test.describe("Validação manual P2.7 — Decisão diária", () => {
  test("cenário completo: conta principal → disponibilidade → registro rápido → histórico", async ({ page }) => {
    const errors: string[] = [];
    page.on("console", (m) => {
      if (m.type() === "error") errors.push(m.text());
    });

    // A sessão vem do storageState do projeto autenticado.
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/01-painel.png", fullPage: true });

    await page.goto("/contas");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/02-contas.png", fullPage: true });

    const novaMovBtn = page.getByRole("button", { name: /Nova movimentação/i });
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    await expect(novaMovBtn).toBeVisible({ timeout: 3000 });
    await novaMovBtn.click();
    await page.waitForTimeout(500);
    await page.screenshot({ path: "test-results/manual-validation/03-dialog-registro.png", fullPage: true });
    await page.keyboard.press("Escape");

    await page.goto("/movimentacoes");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/04-movimentacoes.png", fullPage: true });

    await page.goto("/ganhos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/05-ganhos.png", fullPage: true });

    await page.goto("/gastos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/06-gastos.png", fullPage: true });

    await page.goto("/compromissos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    expect(page.url()).toContain("/gastos");
    expect(page.url()).toContain("tab=recurrent");
    await page.screenshot({ path: "test-results/manual-validation/07-compromissos-redirect.png", fullPage: true });

    await page.goto("/configuracoes");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/08-configuracoes.png", fullPage: true });

    await page.goto("/investimentos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/09-investimentos.png", fullPage: true });

    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    expect(page.url()).not.toContain("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/10-painel-final.png", fullPage: true });

    expect(errors).toEqual([]);
  });
});
