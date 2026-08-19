import { test, expect } from '@playwright/test';

test.describe('QA Dashboard', () => {
  test('Fluxo completo do Dashboard', async ({ page }) => {
    test.setTimeout(60000);
    console.log('Iniciando QA...');

    await page.goto('http://127.0.0.1:3000/entrar');
    await expect(page.getByRole('heading', { name: 'Entre na sua conta' })).toBeVisible({ timeout: 10000 });

    await page.fill('input#email', 'brunosg2711@icloud.com');
    await page.fill('input#password', 'SENHA-REMOVIDA-DO-HISTORICO');
    await page.getByRole('button', { name: 'Entrar' }).click();

    console.log('Logando...');
    await page.waitForURL('http://127.0.0.1:3000/', { timeout: 15000 });

    console.log('Logado com sucesso. Alternando tema...');
    const themeButton = page.getByRole('button', { name: 'Alternar tema' });
    if (await themeButton.isVisible()) {
      const isDark = await page.evaluate(() => document.documentElement.getAttribute('data-theme') === 'dark');
      if (!isDark) {
        await themeButton.click();
        await page.waitForTimeout(500);
      }
    }

    console.log('Validando painel...');
    await expect(page.getByRole('heading', { name: 'Painel' })).toBeVisible();
    await expect(page.locator('.hub-overview')).toBeVisible();
    await expect(page.getByText('Saldo disponível')).toBeVisible();

    const novaMovimentacao = page.getByRole('button', { name: 'Nova movimentação' });
    await expect(novaMovimentacao).toBeVisible();
    await novaMovimentacao.click();

    const dialog = page.getByRole('dialog', { name: 'Nova movimentação' });
    await expect(dialog).toBeVisible();

    await page.getByLabel('Descrição').fill('QA Automático');
    await page.getByLabel('Valor').fill('15,00');

    await page.keyboard.press('Escape');
    await expect(dialog).not.toBeVisible();
    console.log('QA do Dashboard concluído com sucesso! (Nenhum dado real foi inserido)');
  });
});
