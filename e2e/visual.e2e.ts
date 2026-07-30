import { expect, test } from "@playwright/test";

for (const colorScheme of ["light", "dark"] as const) {
  test(`entrada ${colorScheme}`, async ({ page }) => {
    await page.emulateMedia({ colorScheme, reducedMotion: "reduce" });
    await page.goto("/entrar");
    await expect(page).toHaveScreenshot(`entrada-${colorScheme}.png`, { fullPage: true, animations: "disabled" });
  });
}
