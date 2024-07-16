import { test, expect } from '@playwright/test';

const stage = process.env.STAGE;

test('favicon is loading', async ({ page }) => {
    const response = await page.goto(`${stage}/public/assets/favicon.ico`);
    expect(response).not.toBeNull();
    expect(response?.status()).toBe(200);
});
