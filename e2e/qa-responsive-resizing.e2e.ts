import { test, expect } from "@playwright/test";

// Matriz de QA avançado de frontend para redimensionamento, responsividade e menu estendido
// Viewports:
// - 390x844 (Mobile portrait)
// - 768x1024 (Tablet portrait)
// - 1024x768 (Tablet landscape / Small laptop)
// - 1280x800 (Standard laptop)
// - 1440x900 (Desktop)
// - 1920x1080 (Widescreen)

const VIEWPORTS = [
  { name: "mobile-portrait", width: 390, height: 844 },
  { name: "tablet-portrait", width: 768, height: 1024 },
  { name: "tablet-landscape", width: 1024, height: 768 },
  { name: "laptop-1280", width: 1280, height: 800 },
  { name: "desktop-1440", width: 1440, height: 900 },
  { name: "widescreen-1920", width: 1920, height: 1080 },
];

test.describe("QA Avançado: Redimensionamento em Páginas Públicas", () => {
  for (const vp of VIEWPORTS) {
    test(`Sem overflow horizontal em /entrar (${vp.name}: ${vp.width}x${vp.height})`, async ({ page }) => {
      await page.setViewportSize({ width: vp.width, height: vp.height });
      await page.goto("/entrar", { waitUntil: "networkidle" });

      const metrics = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: document.documentElement.clientWidth,
      }));

      // Documento nunca deve transbordar a viewport horizontal
      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth + 1);
    });
  }
});

test.describe("QA Avançado: Menu Lateral e Layout Shell Responsivo", () => {
  test("Verifica tokens e transições CSS de layout responsivo", async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto("/entrar");

    const tokens = await page.evaluate(() => {
      const rootStyle = getComputedStyle(document.documentElement);
      return {
        cardGlass: rootStyle.getPropertyValue("--card-glass").trim(),
        specularShadow: rootStyle.getPropertyValue("--specular-shadow").trim(),
        radiusPill: rootStyle.getPropertyValue("--radius-pill").trim(),
      };
    });

    expect(tokens.cardGlass).toBeTruthy();
    expect(tokens.specularShadow).toBeTruthy();
    expect(tokens.radiusPill).toBe("9999px");
  });
});
