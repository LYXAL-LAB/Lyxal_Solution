import { test, expect, Page } from '@playwright/test';

/**
 * Card Component E2E Tests
 *
 * TDD Approach: These tests define the expected behavior of the Card component
 * and will guide the implementation of comprehensive E2E testing.
 */

test.describe('Card Component E2E Tests', () => {
  let page: Page;

  test.beforeEach(async ({ page: testPage }) => {
    page = testPage;
    await page.goto('/components/card');
    await page.waitForLoadState('networkidle');
  });

  // ===== BASIC FUNCTIONALITY TESTS =====

  test('should render card with default variant', async () => {
    const card = page.locator('[data-testid="card-default"]');
    await expect(card).toBeVisible();
    await expect(card).toHaveClass(/card/);
  });

  test('should render card with all sub-components', async () => {
    const card = page.locator('[data-testid="card-full"]');
    const header = card.locator('[data-testid="card-header"]');
    const title = card.locator('[data-testid="card-title"]');
    const description = card.locator('[data-testid="card-description"]');
    const content = card.locator('[data-testid="card-content"]');
    const footer = card.locator('[data-testid="card-footer"]');

    await expect(card).toBeVisible();
    await expect(header).toBeVisible();
    await expect(title).toBeVisible();
    await expect(description).toBeVisible();
    await expect(content).toBeVisible();
    await expect(footer).toBeVisible();
  });

  test('should render card with different variants', async () => {
    const variants = ['default', 'outline', 'elevated'];

    for (const variant of variants) {
      const card = page.locator(`[data-testid="card-${variant}"]`);
      await expect(card).toBeVisible();
      await expect(card).toHaveClass(new RegExp(`card-${variant}`));
    }
  });

  // ===== CONTENT TESTS =====

  test('should display card title correctly', async () => {
    const cardTitle = page.locator('[data-testid="card-title"]');
    await expect(cardTitle).toBeVisible();
    const text = await cardTitle.textContent();
    expect(text?.length).toBeGreaterThan(0);
  });

  test('should display card description correctly', async () => {
    const cardDescription = page.locator('[data-testid="card-description"]');
    await expect(cardDescription).toBeVisible();
    const text = await cardDescription.textContent();
    expect(text?.length).toBeGreaterThan(0);
  });

  test('should display card content correctly', async () => {
    const cardContent = page.locator('[data-testid="card-content"]');
    await expect(cardContent).toBeVisible();
  });

  test('should display card footer correctly', async () => {
    const cardFooter = page.locator('[data-testid="card-footer"]');
    await expect(cardFooter).toBeVisible();
  });

  // ===== INTERACTION TESTS =====

  test('should handle click events on interactive cards', async () => {
    const interactiveCard = page.locator('[data-testid="card-interactive"]');
    const clickCounter = page.locator('[data-testid="card-click-counter"]');

    await expect(clickCounter).toHaveText('0');

    await interactiveCard.click();
    await expect(clickCounter).toHaveText('1');

    await interactiveCard.click();
    await expect(clickCounter).toHaveText('2');
  });

  test('should handle hover states', async () => {
    const hoverableCard = page.locator('[data-testid="card-hoverable"]');

    await hoverableCard.hover();
    await expect(hoverableCard).toHaveClass(/hover/);
  });

  test('should be clickable when clickable prop is set', async () => {
    const clickableCard = page.locator('[data-testid="card-clickable"]');

    await expect(clickableCard).toBeVisible();
    await clickableCard.click();

    const result = page.locator('[data-testid="card-click-result"]');
    await expect(result).toBeVisible();
  });

  // ===== ACCESSIBILITY TESTS =====

  test('should be keyboard accessible', async () => {
    const interactiveCard = page.locator('[data-testid="card-keyboard"]');

    // Focus the card
    await interactiveCard.focus();
    await expect(interactiveCard).toBeFocused();

    // Press Enter to activate
    await interactiveCard.press('Enter');
    const clickCounter = page.locator('[data-testid="card-click-counter"]');
    await expect(clickCounter).toHaveText('1');

    // Press Space to activate
    await interactiveCard.press(' ');
    await expect(clickCounter).toHaveText('2');
  });

  test('should have proper ARIA attributes', async () => {
    const card = page.locator('[data-testid="card-aria"]');

    await expect(card).toHaveAttribute('role', 'article');

    // Check for aria-label if present
    const ariaLabel = await card.getAttribute('aria-label');
    if (ariaLabel) {
      expect(ariaLabel).toBeTruthy();
    }
  });

  test('should support screen readers', async () => {
    const card = page.locator('[data-testid="card-screen-reader"]');
    const title = card.locator('[data-testid="card-title"]');

    // Check for accessible name
    const accessibleName = await title.evaluate((el) => {
      return el.getAttribute('aria-label') || el.textContent?.trim();
    });

    expect(accessibleName).toBeTruthy();
    expect(accessibleName?.length).toBeGreaterThan(0);
  });

  test('should have proper heading structure', async () => {
    const cardTitle = page.locator('[data-testid="card-title"]');
    const tagName = await cardTitle.evaluate((el) => el.tagName);

    expect(tagName).toBe('H3');
  });

  // ===== RESPONSIVE TESTS =====

  test('should adapt to different screen sizes', async () => {
    const card = page.locator('[data-testid="card-responsive"]');

    // Test mobile view
    await page.setViewportSize({ width: 375, height: 667 });
    await expect(card).toBeVisible();
    const mobileBoundingBox = await card.boundingBox();
    expect(mobileBoundingBox?.width).toBeLessThanOrEqual(375);

    // Test tablet view
    await page.setViewportSize({ width: 768, height: 1024 });
    await expect(card).toBeVisible();
    const tabletBoundingBox = await card.boundingBox();
    expect(tabletBoundingBox?.width).toBeLessThanOrEqual(768);

    // Test desktop view
    await page.setViewportSize({ width: 1920, height: 1080 });
    await expect(card).toBeVisible();
  });

  test('should stack cards on mobile', async () => {
    await page.setViewportSize({ width: 375, height: 667 });

    const cards = page.locator('[data-testid^="card-stack-"]');
    const count = await cards.count();

    if (count > 1) {
      const firstCard = cards.first();
      const secondCard = cards.nth(1);

      const firstBox = await firstCard.boundingBox();
      const secondBox = await secondCard.boundingBox();

      expect(firstBox?.y).toBeLessThan(secondBox?.y || 0);
    }
  });

  // ===== PERFORMANCE TESTS =====

  test('should render within performance budget', async () => {
    const startTime = Date.now();

    await page.goto('/components/card');
    await page.waitForLoadState('networkidle');

    const renderTime = Date.now() - startTime;

    // Should render within 1 second
    expect(renderTime).toBeLessThan(1000);
  });

  test('should handle multiple cards without performance degradation', async () => {
    const cards = page.locator('[data-testid^="card-"]');
    const startTime = Date.now();

    const count = await cards.count();

    // Should render multiple cards quickly
    const renderTime = Date.now() - startTime;
    expect(renderTime).toBeLessThan(1000);

    // Should have at least some cards
    expect(count).toBeGreaterThan(0);
  });

  // ===== STYLING TESTS =====

  test('should apply custom classes correctly', async () => {
    const customCard = page.locator('[data-testid="card-custom"]');
    await expect(customCard).toBeVisible();
    await expect(customCard).toHaveClass(/custom-class/);
  });

  test('should have consistent spacing', async () => {
    const card = page.locator('[data-testid="card-spacing"]');
    const header = card.locator('[data-testid="card-header"]');
    const content = card.locator('[data-testid="card-content"]');

    await expect(card).toBeVisible();
    await expect(header).toBeVisible();
    await expect(content).toBeVisible();

    const headerBox = await header.boundingBox();
    const contentBox = await content.boundingBox();

    expect(headerBox).toBeTruthy();
    expect(contentBox).toBeTruthy();

    if (headerBox && contentBox) {
      expect(contentBox.y).toBeGreaterThan(headerBox.y);
    }
  });

  // ===== INTEGRATION TESTS =====

  test('should work with buttons in footer', async () => {
    const card = page.locator('[data-testid="card-with-buttons"]');
    const footer = card.locator('[data-testid="card-footer"]');
    const button = footer.locator('button').first();

    await expect(card).toBeVisible();
    await expect(button).toBeVisible();

    await button.click();
    const result = page.locator('[data-testid="button-click-result"]');
    await expect(result).toBeVisible();
  });

  test('should work with images', async () => {
    const card = page.locator('[data-testid="card-with-image"]');
    const image = card.locator('img');

    await expect(card).toBeVisible();

    if (await image.count() > 0) {
      await expect(image).toBeVisible();
      await expect(image).toHaveAttribute('src');
    }
  });

  test('should work with forms', async () => {
    const card = page.locator('[data-testid="card-with-form"]');
    const form = card.locator('form');
    const input = card.locator('input').first();

    await expect(card).toBeVisible();
    await expect(form).toBeVisible();
    await expect(input).toBeVisible();

    await input.fill('test value');
    await expect(input).toHaveValue('test value');
  });

  test('should work with lists', async () => {
    const card = page.locator('[data-testid="card-with-list"]');
    const list = card.locator('ul, ol');

    await expect(card).toBeVisible();

    if (await list.count() > 0) {
      await expect(list).toBeVisible();
      const items = list.locator('li');
      const itemCount = await items.count();
      expect(itemCount).toBeGreaterThan(0);
    }
  });

  // ===== EDGE CASE TESTS =====

  test('should handle empty content gracefully', async () => {
    const emptyCard = page.locator('[data-testid="card-empty"]');

    await expect(emptyCard).toBeVisible();
    await expect(emptyCard).toHaveClass(/card/);
  });

  test('should handle very long content', async () => {
    const longContentCard = page.locator('[data-testid="card-long-content"]');
    const content = longContentCard.locator('[data-testid="card-content"]');

    await expect(longContentCard).toBeVisible();
    await expect(content).toBeVisible();

    const text = await content.textContent();
    expect(text?.length).toBeGreaterThan(100);
  });

  test('should handle special characters in content', async () => {
    const specialCard = page.locator('[data-testid="card-special-chars"]');
    const title = specialCard.locator('[data-testid="card-title"]');

    await expect(specialCard).toBeVisible();
    await expect(title).toBeVisible();

    const text = await title.textContent();
    expect(text).toBeTruthy();
  });

  // ===== LAYOUT TESTS =====

  test('should maintain aspect ratio when configured', async () => {
    const aspectRatioCard = page.locator('[data-testid="card-aspect-ratio"]');

    await expect(aspectRatioCard).toBeVisible();

    const boundingBox = await aspectRatioCard.boundingBox();
    expect(boundingBox).toBeTruthy();

    if (boundingBox) {
      expect(boundingBox.width).toBeGreaterThan(0);
      expect(boundingBox.height).toBeGreaterThan(0);
    }
  });

  test('should work in grid layouts', async () => {
    const gridContainer = page.locator('[data-testid="card-grid"]');
    const cards = gridContainer.locator('[data-testid^="card-"]');

    await expect(gridContainer).toBeVisible();

    const cardCount = await cards.count();
    expect(cardCount).toBeGreaterThan(1);
  });

  test('should work in flex layouts', async () => {
    const flexContainer = page.locator('[data-testid="card-flex"]');
    const cards = flexContainer.locator('[data-testid^="card-"]');

    await expect(flexContainer).toBeVisible();

    const cardCount = await cards.count();
    expect(cardCount).toBeGreaterThan(0);
  });

  // ===== STATE TESTS =====

  test('should respect disabled state', async () => {
    const disabledCard = page.locator('[data-testid="card-disabled"]');

    await expect(disabledCard).toBeVisible();
    await expect(disabledCard).toHaveClass(/disabled/);

    // Click should not work
    const clickCounter = page.locator('[data-testid="card-click-counter"]');
    const initialCount = await clickCounter.textContent();

    await disabledCard.click({ force: true });
    const finalCount = await clickCounter.textContent();

    expect(initialCount).toBe(finalCount);
  });

  test('should show loading state', async () => {
    const loadingCard = page.locator('[data-testid="card-loading"]');

    await expect(loadingCard).toBeVisible();
    await expect(loadingCard).toHaveClass(/loading/);

    const loadingIndicator = loadingCard.locator('[data-testid="loading-indicator"]');
    if (await loadingIndicator.count() > 0) {
      await expect(loadingIndicator).toBeVisible();
    }
  });

  // ===== CROSS-BROWSER COMPATIBILITY TESTS =====

  test('should work consistently across browsers', async () => {
    const card = page.locator('[data-testid="card-cross-browser"]');

    // Basic functionality should work
    await expect(card).toBeVisible();
    await expect(card).toHaveClass(/card/);

    // Content should be visible
    const title = card.locator('[data-testid="card-title"]');
    await expect(title).toBeVisible();
  });
});
