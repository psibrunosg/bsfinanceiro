import { expect, test } from "@playwright/test";

const PROTECTED = [
  "/",
  "/ganhos",
  "/gastos",
  "/contas",
  "/cartoes",
  "/investimentos",
  "/planejamento",
  "/categorias",
  "/configuracoes",
  "/movimentacoes",
];

const AUTH_PAGES = ["/entrar", "/cadastro"];

test.describe("Guarda de autenticação (deslogado)", () => {
  for (const path of PROTECTED) {
    test(`${path} → redireciona para /entrar`, async ({ page }) => {
      await page.goto(path);
      await expect(page).toHaveURL(/\/entrar/);
    });
  }
});

test.describe("Páginas públicas: console limpo + formulário", () => {
  for (const path of AUTH_PAGES) {
    test(`${path} sem erros e com formulário funcional`, async ({ page }) => {
      const problems: string[] = [];
      page.on("console", (m) => {
        if (m.type() === "error") problems.push(`console.error: ${m.text()}`);
      });
      page.on("pageerror", (e) => problems.push(`pageerror: ${e.message}`));

      await page.goto(path, { waitUntil: "networkidle" });
      await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
      await expect(page.getByLabel("E-mail")).toBeVisible();
      await expect(page.getByLabel("Senha")).toBeVisible();
      await expect(page.getByRole("button", { name: /Entrar|Criar conta/ })).toBeVisible();

      const theme = await page.locator("html").getAttribute("data-theme");
      expect(["light", "dark"]).toContain(theme);
      expect(problems).toEqual([]);
    });
  }
});

test.describe("Tema segue prefers-color-scheme", () => {
  for (const scheme of ["light", "dark"] as const) {
    test(`${scheme}`, async ({ page }) => {
      await page.emulateMedia({ colorScheme: scheme, reducedMotion: "reduce" });
      await page.goto("/entrar");
      await expect(page.locator("html")).toHaveAttribute("data-theme", scheme);
    });
  }
});

test.describe("Screenshots para inspeção", () => {
  for (const scheme of ["light", "dark"] as const) {
    for (const path of AUTH_PAGES) {
      test(`${path} ${scheme}`, async ({ page }) => {
        const project = test.info().project.name;
        await page.emulateMedia({ colorScheme: scheme, reducedMotion: "reduce" });
        await page.goto(path, { waitUntil: "networkidle" });
        await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
        await page.screenshot({
          path: `test-results/smoke/${project}-${scheme}-${path.slice(1)}.png`,
          fullPage: true,
        });
      });
    }
  }
});
