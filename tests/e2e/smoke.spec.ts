import { expect, test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('portal shell exposes the sandbox badge and has no critical axe violation', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByText('GLX-DEMO sandbox')).toBeVisible();
  const report = await new AxeBuilder({ page }).analyze();
  expect(report.violations.filter((violation) => violation.impact === 'critical')).toEqual([]);
});
