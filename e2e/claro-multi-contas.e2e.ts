import { expect, test } from "@playwright/test";

const TEST_EMAIL = "brunosg2711@icloud.com";
const TEST_PASSWORD = "SENHA-REMOVIDA-DO-HISTORICO";

test.setTimeout(180000);

test.describe("Walkthrough QA Visual - Faturas Claro e Multi-Contas", () => {
  for (const scheme of ["light", "dark"] as const) {
    test(`walkthrough autenticado em modo ${scheme}`, async ({ page }) => {
      const project = test.info().project.name;
      await page.emulateMedia({ colorScheme: scheme, reducedMotion: "reduce" });

      // 1. Login
      await page.goto("/entrar", { waitUntil: "networkidle" });
      await page.fill('input[name="email"]', TEST_EMAIL);
      await page.fill('input[name="password"]', TEST_PASSWORD);
      await page.click('button:has-text("Entrar")');
      await page.waitForFunction(() => !window.location.pathname.startsWith("/entrar"), { timeout: 20000 });
      expect(page.url()).not.toContain("/entrar");

      // 2. Dashboard & Pendências
      await page.goto("/", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(3000); // Aguarda carregamento Supabase
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-01-dashboard.png`,
        fullPage: true,
      });

      // 3. Hub Contas (Múltiplas Contas: PJ, PF, Santander)
      await page.goto("/contas", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(3000);
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-02-contas.png`,
        fullPage: true,
      });

      // 4. Hub Gastos (Faturas Claro & Compromissos)
      await page.goto("/gastos", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(3000);
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-03-gastos.png`,
        fullPage: true,
      });

      // 5. Gastos - Aba Recorrentes
      await page.goto("/gastos?tab=recorrentes", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(2000);
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-04-gastos-recorrentes.png`,
        fullPage: true,
      });

      // 6. Hub Ganhos
      await page.goto("/ganhos", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(2000);
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-05-ganhos.png`,
        fullPage: true,
      });

      // 7. Hub Investimentos
      await page.goto("/investimentos", { waitUntil: "domcontentloaded" });
      await page.waitForTimeout(2000);
      await page.screenshot({
        path: `test-results/walkthrough/${project}-${scheme}-06-investimentos.png`,
        fullPage: true,
      });

      // Garantia de ausência de perda de sessão ou quebras severas
      expect(page.url()).not.toContain("/entrar");
    });
  }
});
