/**
 * Visual regression tests for Card component
 * Tests across multiple themes, viewports, and content variations
 */

import { test, expect } from '@playwright/test';
import { THEMES, VIEWPORTS, createVisualFramework } from '../src/index.js';

test.describe('Card Visual Tests', () => {
  test.describe.configure({ mode: 'parallel' });

  // Test default card across themes
  for (const theme of THEMES.slice(0, 2)) {
    test(`default card in ${theme.name} theme`, async ({ page }) => {
      const framework = createVisualFramework(page);

      await framework.testStory('components-card', 'default', {
        themes: [theme],
        viewports: [VIEWPORTS[0]],
        threshold: 0.0001,
      });
    });
  }

  // Test card with all sections
  test('card with header, content, and footer', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-card', 'default', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test card variations
  test('card variations (outlined, filled)', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-card', 'variants', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test responsive card
  test('card responsive design', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-card', 'default', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0], VIEWPORTS[2], VIEWPORTS[3]],
      threshold: 0.0001,
    });
  });

  // Test card with form content
  test('card containing form elements', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-card', 'with-form', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test card with image
  test('card with image content', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-image');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-image.png');
  });

  // Test card grid layout
  test('multiple cards in grid layout', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    await page.evaluate(() => {
      const container = document.createElement('div');
      container.style.display = 'grid';
      container.style.gridTemplateColumns = 'repeat(3, 1fr)';
      container.style.gap = '16px';

      for (let i = 0; i < 6; i++) {
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `
          <div class="card-header">
            <h3 class="card-title">Card ${i + 1}</h3>
          </div>
          <div class="card-content">
            <p>This is card content ${i + 1}</p>
          </div>
        `;
        container.appendChild(card);
      }

      document.body.appendChild(container);
    });

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-grid.png');
  });

  // Test card hover state
  test('card hover state', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    const card = page.locator('.card').first();
    await card.hover();

    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-hover.png');
  });

  // Test card focus state
  test('card with focusable element', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-form');

    const input = page.locator('.card input').first();
    await input.focus();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-with-focus.png');
  });

  // Test card with different header styles
  test('card header variations', async ({ page }) => {
    await page.goto('/?path=/story/components-card--header-variations');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-headers.png');
  });

  // Test card with action buttons
  test('card with action buttons in footer', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-actions');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-actions.png');
  });

  // Test card in dark mode
  test('card in dark mode', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-card', 'default', {
      themes: [THEMES[1]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test RTL support
  test('card in RTL layout', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    await page.evaluate(() => {
      document.documentElement.setAttribute('dir', 'rtl');
    });

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-rtl.png');
  });

  // Test card with long content
  test('card with long scrolling content', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    await page.evaluate(() => {
      const card = document.querySelector('.card');
      if (card) {
        const content = card.querySelector('.card-content');
        if (content) {
          content.innerHTML = '<p>'.repeat(50) + 'Very long content that should cause scrolling within the card' + '</p>'.repeat(50);
        }
      }
    });

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-long-content.png');
  });

  // Test card with tabs
  test('card containing tabs', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-tabs');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-tabs.png');
  });

  // Test card with statistics
  test('card displaying statistics/metrics', async ({ page }) => {
    await page.goto('/?path=/story/components-card--stats');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-stats.png');
  });

  // Test card pricing table
  test('pricing card layout', async ({ page }) => {
    await page.goto('/?path=/story/components-card--pricing');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-pricing.png');
  });

  // Test card with avatar
  test('card with user avatar and info', async ({ page }) => {
    await page.goto('/?path=/story/components-card--user-profile');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-user-profile.png');
  });

  // Test card notification/alert
  test('card as notification container', async ({ page }) => {
    await page.goto('/?path=/story/components-card--notification');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-notification.png');
  });

  // Test nested cards
  test('card containing another card', async ({ page }) => {
    await page.goto('/?path=/story/components-card--nested');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-nested.png');
  });

  // Test card border variations
  test('card with different border styles', async ({ page }) => {
    await page.goto('/?path=/story/components-card--borders');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-borders.png');
  });

  // Test card shadow variations
  test('card with different shadow depths', async ({ page }) => {
    await page.goto('/?path=/story/components-card--shadows');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-shadows.png');
  });

  // Test card with badge
  test('card with badge indicator', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-badge');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-badge.png');
  });

  // Test card with dropdown menu
  test('card with dropdown menu', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-dropdown');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-dropdown.png');
  });

  // Test card with progress indicator
  test('card with progress bar', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-progress');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-progress.png');
  });

  // Test card skeleton loading state
  test('card skeleton loading state', async ({ page }) => {
    await page.goto('/?path=/story/components-card--skeleton');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-skeleton.png');
  });

  // Test card with chart
  test('card containing chart/graphic', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-chart');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-chart.png');
  });

  // Test card with table
  test('card containing table', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-table');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-table.png');
  });

  // Test card with list
  test('card containing list items', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-list');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-list.png');
  });

  // Test card with switch/toggle
  test('card with toggle switch', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-switch');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-switch.png');
  });

  // Test card with checkbox
  test('card with checkbox selection', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-checkbox');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-checkbox.png');
  });

  // Test card with radio group
  test('card with radio options', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-radio');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-radio.png');
  });

  // Test card with slider
  test('card with range slider', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-slider');

    const card = page.locator('.card').first();
    const screenshot = await card.screenshot();
    expect(screenshot).toMatchSnapshot('card-with-slider.png');
  });
});

// Accessibility tests
test.describe('Card Accessibility Tests', () => {
  test('card has proper heading hierarchy', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    const cardTitle = page.locator('.card-title').first();
    await expect(cardTitle).toBeVisible();

    const tagName = await cardTitle.evaluate(el => el.tagName);
    expect(['H1', 'H2', 'H3', 'H4', 'H5', 'H6']).toContain(tagName);
  });

  test('card with interactive elements has focus indicators', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-actions');

    const button = page.locator('.card button').first();
    await button.focus();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('card-focus-indicator.png');
  });

  test('card maintains contrast in both themes', async ({ page }) => {
    for (const theme of THEMES.slice(0, 2)) {
      await page.goto(`/?path=/story/components-card--default&globals=theme:${theme.themeId}`);

      const card = page.locator('.card').first();
      await expect(card).toBeVisible();

      // Visual check for contrast
      const screenshot = await card.screenshot();
      expect(screenshot).toMatchSnapshot(`card-contrast-${theme.id}.png`);
    }
  });

  test('card with form has proper labels', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-form');

    const inputs = page.locator('.card input');
    const count = await inputs.count();

    for (let i = 0; i < count; i++) {
      const input = inputs.nth(i);
      const hasLabel = await input.evaluate(el => {
        const labels = document.querySelectorAll('label');
        return Array.from(labels).some(label =>
          label.getAttribute('for') === el.id ||
          label.contains(el)
        );
      });
      expect(hasLabel).toBeTruthy();
    }
  });
});

// Performance tests
test.describe('Card Performance Tests', () => {
  test('renders 20 cards efficiently', async ({ page }) => {
    await page.goto('/?path=/story/components-card--default');

    await page.evaluate(() => {
      const container = document.createElement('div');
      container.style.display = 'grid';
      container.style.gridTemplateColumns = 'repeat(4, 1fr)';
      container.style.gap = '16px';

      for (let i = 0; i < 20; i++) {
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `
          <div class="card-header">
            <h3 class="card-title">Card ${i + 1}</h3>
            <p class="card-description">Description ${i + 1}</p>
          </div>
          <div class="card-content">
            <p>Content ${i + 1}</p>
          </div>
          <div class="card-footer">
            <button>Action</button>
          </div>
        `;
        container.appendChild(card);
      }

      document.body.appendChild(container);
    });

    const screenshot = await page.screenshot({ fullPage: true });
    expect(screenshot).toMatchSnapshot('card-grid-20.png');
  });

  test('card with complex content renders smoothly', async ({ page }) => {
    await page.goto('/?path=/story/components-card--with-form');

    const startTime = Date.now();
    await page.waitForSelector('.card', { state: 'visible' });
    const loadTime = Date.now() - startTime;

    expect(loadTime).toBeLessThan(3000); // Should load within 3 seconds
  });
});
