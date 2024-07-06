import { test, expect } from '@playwright/test';

const stage = process.env.STAGE;

const urls = [{
  url: `${stage}/`,
  title: "This is the home page"
},
{
  url: `${stage}/about`,
  title: "About Page"
},
{
  url: `${stage}/home`,
  title: "This is the home page"
}];

for (const url of urls) {
  test(`/${url.url} has title ${url.title}`, async ({ page }) => {
    await page.goto(url.url);
    await page.reload();
    await expect(page).toHaveTitle('SSR');
    const element = await page.locator('#root > main > section > h1');
    await expect(element).toBeVisible();
    await expect(element).toHaveText(url.title);
  });
}
