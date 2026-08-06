import { expect, test } from "@playwright/test";

test.describe("Resiliência Offline PWA (Service Worker Cache)", () => {
  test("deve carregar a página inicial, registrar service worker e responder em modo offline (sem conexão)", async ({ page, context }) => {
    // 1. Visitar página pública para ativar o cache inicial
    await page.goto("/entrar", { waitUntil: "networkidle" });
    
    // 2. Aguarda e valida que o service worker foi registrado e está ativo no navegador
    const isSwRegistered = await page.evaluate(async () => {
      if (!("serviceWorker" in navigator)) return false;
      try {
        const reg = await navigator.serviceWorker.ready;
        return !!reg;
      } catch {
        return false;
      }
    });
    expect(isSwRegistered).toBe(true);

    // 3. Recarregar online uma vez com o SW ativo para permitir a interceptação e cache dos arquivos de runtime (JS/CSS) no modo Dev
    await page.reload({ waitUntil: "networkidle" });
    await page.waitForTimeout(1000);

    // 4. Simular queda de conexão (Offline)
    await context.setOffline(true);

    // 5. Tentar recarregar ou navegar offline para a mesma rota cacheada
    await page.reload({ waitUntil: "domcontentloaded" });
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();

    // 6. Restaurar conexão (Online)
    await context.setOffline(false);
    await page.reload({ waitUntil: "networkidle" });
    await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  });
});
