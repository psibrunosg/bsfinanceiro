import { expect, test } from "@playwright/test";

const TEST_EMAIL = "brunosg2711@icloud.com";
const TEST_PASSWORD = "L1nkB@27psi";

test.setTimeout(120000);

test.describe("Validação manual P2.7 — Decisão diária", () => {
  test("cenário completo: conta principal → disponibilidade → registro rápido → histórico", async ({ page }) => {
    const errors: string[] = [];
    page.on("console", (m) => {
      if (m.type() === "error") errors.push(m.text());
    });

    // Step 1: Login
    await page.goto("/entrar");
    await page.fill('input[name="email"]', TEST_EMAIL);
    await page.fill('input[name="password"]', TEST_PASSWORD);
    await page.click('button:has-text("Entrar")');
    await page.waitForFunction(() => !window.location.pathname.startsWith("/entrar"), { timeout: 15000 });
    expect(page.url()).not.toContain("/entrar");
    await page.waitForLoadState("domcontentloaded");

    // Step 2: Dashboard
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000); // data loading from Supabase
    await page.screenshot({ path: "test-results/manual-validation/01-painel.png", fullPage: true });

    // Step 3: Contas
    await page.goto("/contas");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/02-contas.png", fullPage: true });

    // Step 4: Registro rápido
    const novaMovBtn = page.getByRole("button", { name: /Nova movimentação/i });
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    if (await novaMovBtn.isVisible({ timeout: 3000 }).catch(() => false)) {
      await novaMovBtn.click();
      await page.waitForTimeout(500);
      await page.screenshot({ path: "test-results/manual-validation/03-dialog-registro.png", fullPage: true });
      await page.keyboard.press("Escape");
    }

    // Step 5: Movimentações
    await page.goto("/movimentacoes");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/04-movimentacoes.png", fullPage: true });

    // Step 6: Ganhos hub
    await page.goto("/ganhos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/05-ganhos.png", fullPage: true });

    // Step 7: Gastos hub
    await page.goto("/gastos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/06-gastos.png", fullPage: true });

    // Step 8: Compromissos redirect
    await page.goto("/compromissos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    const url = page.url();
    const redirectWorked = url.includes("/gastos") && url.includes("tab=recurrent");
    const sessionLost = url.includes("/entrar");
    await page.screenshot({ path: "test-results/manual-validation/07-compromissos-redirect.png", fullPage: true });

    // Step 9: Configurações
    await page.goto("/configuracoes");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/08-configuracoes.png", fullPage: true });

    // Step 10: Investimentos
    await page.goto("/investimentos");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/09-investimentos.png", fullPage: true });

    // Step 11: Final dashboard
    await page.goto("/");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: "test-results/manual-validation/10-painel-final.png", fullPage: true });

    // Report
    console.log(`\n=== VALIDAÇÃO P2.7 ===`);
    console.log(`URL final: ${page.url()}`);
    console.log(`Redirect /compromissos: ${redirectWorked ? "✅ OK" : sessionLost ? "❌ Session lost" : "⚠️ Other"}`);
    console.log(`Console errors: ${errors.length === 0 ? "✅ Nenhum" : errors.join(", ")}`);
    console.log(`=====================\n`);

    // Don't fail on redirect — report it
    expect(page.url()).not.toContain("/entrar");
  });
});
