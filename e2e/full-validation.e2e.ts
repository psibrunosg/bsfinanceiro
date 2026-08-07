import { test, expect } from '@playwright/test';
import * as fs from 'fs';

test('Full validation of login modal and UX', async ({ page }) => {
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

  // Navigate to login page
  await page.goto('/entrar');
  await page.waitForLoadState('networkidle');

  // Verify elements are visible
  await expect(page.getByRole('button', { name: 'Entrar' })).toBeVisible();

  // Try to submit empty form to trigger validation errors (or just get DOM state)
  await page.getByRole('button', { name: 'Entrar' }).click();

  // Extract relevant DOM (the form)
  const form = page.locator('form');
  const domContent = await form.innerHTML();

  // Write outputs to a file for the pilot agent to read
  const output = {
    domContent,
    consoleErrors,
    networkErrors,
  };
  fs.writeFileSync('test-results/qa-audit-log.json', JSON.stringify(output, null, 2));

  expect(consoleErrors.length).toBe(0);
});
