import { test, expect } from '@playwright/test';
import * as fs from 'fs';

test('Full validation of modals and UX', async ({ page }) => {
  const consoleErrors: string[] = [];
  const networkErrors: string[] = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    }
  });

  page.on('response', response => {
    if (response.status() >= 400 && response.status() < 600) {
      networkErrors.push(`${response.status()} ${response.url()}`);
    }
  });

  // Navigate to accounts page
  await page.goto('/contas');

  // Wait for network idle to ensure everything is loaded
  await page.waitForLoadState('networkidle');

  // Click 'Nova movimentação' or 'Adicionar conta' button
  const addButton = page.getByRole('button', { name: /Adicionar conta/i });
  if (await addButton.isVisible()) {
    await addButton.click();
  }

  // Wait for dialog to appear
  const dialog = page.locator('dialog');
  await expect(dialog).toBeVisible({ timeout: 5000 });

  // Extract relevant DOM (the form)
  const domContent = await dialog.innerHTML();

  // Write outputs to a file for the pilot agent to read
  const output = {
    domContent,
    consoleErrors,
    networkErrors,
  };
  fs.writeFileSync('test-results/qa-audit-log.json', JSON.stringify(output, null, 2));

  // Asserting to make test pass locally
  expect(consoleErrors.length).toBe(0);
});
