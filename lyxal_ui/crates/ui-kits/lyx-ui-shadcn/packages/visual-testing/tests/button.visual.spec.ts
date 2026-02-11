/**
 * Visual regression tests for Button component
 * Tests across multiple themes, viewports, and variants
 */

import { test, expect } from '@playwright/test';
import { THEMES, VIEWPORTS, createVisualFramework } from '../src/index.js';

test.describe('Button Visual Tests', () => {
  test.describe.configure({ mode: 'parallel' });

  // Test default button across themes
  for (const theme of THEMES.slice(0, 2)) {
    test(`default button in ${theme.name} theme`, async ({ page }) => {
      const framework = createVisualFramework(page);

      await framework.testStory('components-button', 'default', {
        themes: [theme],
        viewports: [VIEWPORTS[0]], // desktop
        threshold: 0.0001,
      });
    });
  }

  // Test all button variants
  const buttonVariants = [
    'default',
    'destructive',
    'outline',
    'secondary',
    'ghost',
    'link',
  ];

  for (const variant of buttonVariants) {
    test(`button variant: ${variant}`, async ({ page }) => {
      const framework = createVisualFramework(page);

      await framework.testStory('components-button--variants', variant, {
        themes: [THEMES[0]], // light theme
        viewports: [VIEWPORTS[0]],
        threshold: 0.0001,
      });
    });
  }

  // Test button sizes
  test('button sizes', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'sizes', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test button states
  test('button states (disabled, loading)', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'states', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test responsive behavior
  test('button responsive design', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'default', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0], VIEWPORTS[2], VIEWPORTS[3]], // desktop, tablet, mobile
      threshold: 0.0001,
    });
  });

  // Test with icons
  test('button with icon', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'sizes', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test dark mode variations
  test('button in dark mode', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'variants', {
      themes: [THEMES[1]], // dark theme
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test button with long text
  test('button with long text content', async ({ page }) => {
    const framework = createVisualFramework(page);

    await page.goto('/?path=/story/components-button--default');
    await page.evaluate(() => {
      const button = document.querySelector('button');
      if (button) {
        button.textContent = 'This is a very long button text that should wrap properly';
      }
    });

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('button-long-text.png');
  });

  // Test button hover state
  test('button hover state', async ({ page }) => {
    await page.goto('/?path=/story/components-button--default');

    const button = page.locator('button').first();
    await button.hover();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('button-hover.png');
  });

  // Test button focus state
  test('button focus state', async ({ page }) => {
    await page.goto('/?path=/story/components-button--default');

    const button = page.locator('button').first();
    await button.focus();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('button-focus.png');
  });

  // Test button click animation
  test('button active/click state', async ({ page }) => {
    await page.goto('/?path=/story/components-button--default');

    const button = page.locator('button').first();
    await button.click();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('button-active.png');
  });

  // Test button in different containers
  test('button in card container', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    const screenshot = await page.locator('.card').screenshot();
    expect(screenshot).toMatchSnapshot('button-in-card.png');
  });

  // Test multiple buttons together
  test('button group layout', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'variants', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test button with loading spinner
  test('button loading state with spinner', async ({ page }) => {
    await page.goto('/?path=/story/components-button--states');

    const loadingButton = page.locator('button[aria-busy="true"], button[data-loading="true"]').first();
    const screenshot = await loadingButton.screenshot();
    expect(screenshot).toMatchSnapshot('button-loading.png');
  });

  // Test accessibility attributes
  test('button accessibility attributes visual', async ({ page }) => {
    await page.goto('/?path=/story/components-button--states');

    const disabledButton = page.locator('button[disabled]').first();
    await expect(disabledButton).toHaveAttribute('disabled');
    await expect(disabledButton).toHaveAttribute('aria-disabled', 'true');

    const screenshot = await disabledButton.screenshot();
    expect(screenshot).toMatchSnapshot('button-disabled.png');
  });

  // Test RTL support
  test('button in RTL layout', async ({ page }) => {
    await page.goto('/?path=/story/components-button--default');

    await page.evaluate(() => {
      document.documentElement.setAttribute('dir', 'rtl');
    });

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('button-rtl.png');
  });

  // Test button with nested elements
  test('button with nested icon and text', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-button', 'default', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });
});

// Performance test: render multiple buttons
test.describe('Button Performance Tests', () => {
  test('renders 100 buttons without visual issues', async ({ page }) => {
    await page.goto('/?path=/story/components-button--default');

    await page.evaluate(() => {
      const container = document.createElement('div');
      container.style.display = 'flex';
      container.style.flexWrap = 'wrap';
      container.style.gap = '8px';

      for (let i = 0; i < 100; i++) {
        const button = document.createElement('button');
        button.className = 'btn btn-default';
        button.textContent = `Button ${i + 1}`;
        container.appendChild(button);
      }

      document.body.appendChild(container);
    });

    const screenshot = await page.screenshot({ fullPage: true });
    expect(screenshot).toMatchSnapshot('button-grid-100.png');
  });
});
