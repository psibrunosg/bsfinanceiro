import { expect, test } from "@playwright/test";

for (const colorScheme of ["light", "dark"] as const) {
  test(`entrada ${colorScheme}`, async ({ page }) => {
    await page.emulateMedia({ colorScheme, reducedMotion: "reduce" });
    await page.goto("/entrar", { waitUntil: "networkidle" });
    // Espera as fontes do app carregarem explicitamente. O @import do Google
    // Fonts pode não estar em document.fonts.ready, causando FOUT flaky.
    await page.evaluate(async () => {
      await document.fonts.load('16px "Source Sans 3"');
      await document.fonts.load('700 32px "Lexend"');
    });
    await expect(page).toHaveScreenshot(`entrada-${colorScheme}.png`, {
      fullPage: true,
      animations: "disabled",
      // Tolerância para ruído de anti-alias de fonte no dev server; regressões
      // visuais reais (1%+) continuam falhando.
      maxDiffPixelRatio: 0.005,
    });
  });
}
