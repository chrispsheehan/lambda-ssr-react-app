import { test, expect } from '@playwright/test';

test('favicon is loading', async ({ page }) => {
    const response = await page.goto(`/public/assets/favicon.ico`);
    expect(response).not.toBeNull();
    expect(response?.status()).toBe(200);
});
