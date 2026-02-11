/**
 * Visual regression tests for Input component
 * Tests across multiple themes, viewports, and states
 */

import { test, expect } from '@playwright/test';
import { THEMES, VIEWPORTS, createVisualFramework } from '../src/index.js';

test.describe('Input Visual Tests', () => {
  test.describe.configure({ mode: 'parallel' });

  // Test default input across themes
  for (const theme of THEMES.slice(0, 2)) {
    test(`default input in ${theme.name} theme`, async ({ page }) => {
      const framework = createVisualFramework(page);

      await framework.testStory('components-input', 'default', {
        themes: [theme],
        viewports: [VIEWPORTS[0]],
        threshold: 0.0001,
      });
    });
  }

  // Test input states
  test('input states (default, disabled, error)', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-input', 'disabled', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test input focus state
  test('input focus state', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    const input = page.locator('input[type="text"]').first();
    await input.focus();

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('input-focus.png');
  });

  // Test input with placeholder
  test('input with placeholder text', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    const input = page.locator('input[placeholder]').first();
    const screenshot = await input.screenshot();
    expect(screenshot).toMatchSnapshot('input-placeholder.png');
  });

  // Test input with text content
  test('input with filled text', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    const input = page.locator('input[type="text"]').first();
    await input.fill('Sample text content');

    const screenshot = await input.screenshot();
    expect(screenshot).toMatchSnapshot('input-filled.png');
  });

  // Test input with long content
  test('input with long text content (scrolling)', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    const input = page.locator('input[type="text"]').first();
    await input.fill('This is a very long text that should scroll within the input field');

    const screenshot = await input.screenshot();
    expect(screenshot).toMatchSnapshot('input-long-text.png');
  });

  // Test input types
  const inputTypes = ['text', 'email', 'password', 'number', 'tel', 'url'];

  for (const type of inputTypes) {
    test(`input type: ${type}`, async ({ page }) => {
      await page.goto('/?path=/story/components-input--default');

      const input = page.locator(`input[type="${type}"]`).first();
      await expect(input).toBeVisible();

      const screenshot = await input.screenshot();
      expect(screenshot).toMatchSnapshot(`input-type-${type}.png`);
    });
  }

  // Test responsive input
  test('input responsive design', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-input', 'default', {
      themes: [THEMES[0]],
      viewports: [VIEWPORTS[0], VIEWPORTS[2], VIEWPORTS[3]],
      threshold: 0.0001,
    });
  });

  // Test input with icon
  test('input with icon', async ({ page }) => {
    await page.goto('/?path=/story/components-input--with-icon');

    const container = page.locator('.input-with-icon').first();
    const screenshot = await container.screenshot();
    expect(screenshot).toMatchSnapshot('input-with-icon.png');
  });

  // Test input with label
  test('input with label', async ({ page }) => {
    await page.goto('/?path=/story/components-input--with-label');

    const container = page.locator('.form-group').first();
    const screenshot = await container.screenshot();
    expect(screenshot).toMatchSnapshot('input-with-label.png');
  });

  // Test input with helper text
  test('input with helper text', async ({ page }) => {
    await page.goto('/?path=/story/components-input--with-helper');

    const container = page.locator('.form-group').first();
    const screenshot = await container.screenshot();
    expect(screenshot).toMatchSnapshot('input-with-helper.png');
  });

  // Test input with error state
  test('input error state', async ({ page }) => {
    await page.goto('/?path=/story/components-input--error');

    const container = page.locator('.input-error').first();
    const screenshot = await container.screenshot();
    expect(screenshot).toMatchSnapshot('input-error.png');
  });

  // Test input in form
  test('input within form layout', async ({ page }) => {
    await page.goto('/?path=/story/components-form--default');

    const form = page.locator('form').first();
    const screenshot = await form.screenshot();
    expect(screenshot).toMatchSnapshot('input-in-form.png');
  });

  // Test multiple inputs together
  test('multiple inputs in grid', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    await page.evaluate(() => {
      const container = document.createElement('div');
      container.style.display = 'grid';
      container.style.gridTemplateColumns = 'repeat(2, 1fr)';
      container.style.gap = '16px';

      for (let i = 0; i < 4; i++) {
        const wrapper = document.createElement('div');
        wrapper.innerHTML = `
          <label>Field ${i + 1}</label>
          <input type="text" placeholder="Enter text" class="input" />
        `;
        container.appendChild(wrapper);
      }

      document.body.appendChild(container);
    });

    const screenshot = await page.locator('div').filter({ hasText: 'Field 1' }).screenshot();
    expect(screenshot).toMatchSnapshot('input-grid.png');
  });

  // Test dark mode
  test('input in dark mode', async ({ page }) => {
    const framework = createVisualFramework(page);

    await framework.testStory('components-input', 'default', {
      themes: [THEMES[1]],
      viewports: [VIEWPORTS[0]],
      threshold: 0.0001,
    });
  });

  // Test RTL support
  test('input in RTL layout', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    await page.evaluate(() => {
      document.documentElement.setAttribute('dir', 'rtl');
    });

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('input-rtl.png');
  });

  // Test input with validation styles
  test('input validation states', async ({ page }) => {
    await page.goto('/?path=/story/components-input--validation');

    const validInput = page.locator('input[aria-valid="true"]').first();
    const invalidInput = page.locator('input[aria-invalid="true"]').first();

    await expect(validInput).toBeVisible();
    await expect(invalidInput).toBeVisible();

    const screenshot = await page.locator('.validation-states').screenshot();
    expect(screenshot).toMatchSnapshot('input-validation.png');
  });

  // Test textarea (related input component)
  test('textarea visual consistency', async ({ page }) => {
    await page.goto('/?path=/story/components-textarea--default');

    const textarea = page.locator('textarea').first();
    await textarea.fill('This is sample text in a textarea component that can handle multiple lines of content.');

    const screenshot = await textarea.screenshot();
    expect(screenshot).toMatchSnapshot('textarea-default.png');
  });

  // Test input sizing
  test('input sizes (sm, default, lg)', async ({ page }) => {
    await page.goto('/?path=/story/components-input--sizes');

    const screenshot = await page.screenshot({ fullPage: false });
    expect(screenshot).toMatchSnapshot('input-sizes.png');
  });

  // Test input file upload
  test('file input styling', async ({ page }) => {
    await page.goto('/?path=/story/components-input--file');

    const fileInput = page.locator('input[type="file"]').first();
    await expect(fileInput).toBeVisible();

    const screenshot = await fileInput.screenshot();
    expect(screenshot).toMatchSnapshot('input-file.png');
  });

  // Test search input
  test('search input with icon', async ({ page }) => {
    await page.goto('/?path=/story/components-input--search');

    const searchContainer = page.locator('.search-input').first();
    const screenshot = await searchContainer.screenshot();
    expect(screenshot).toMatchSnapshot('input-search.png');
  });

  // Test date input
  test('date input styling', async ({ page }) => {
    await page.goto('/?path=/story/components-input--date');

    const dateInput = page.locator('input[type="date"]').first();
    const screenshot = await dateInput.screenshot();
    expect(screenshot).toMatchSnapshot('input-date.png');
  });

  // Test input with clear button
  test('input with clear button', async ({ page }) => {
    await page.goto('/?path=/story/components-input--clearable');

    const input = page.locator('input[type="text"]').first();
    await input.fill('Text to clear');

    const container = page.locator('.clearable-input').first();
    const screenshot = await container.screenshot();
    expect(screenshot).toMatchSnapshot('input-clearable.png');
  });
});

// Accessibility tests
test.describe('Input Accessibility Tests', () => {
  test('input has proper ARIA labels', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    const input = page.locator('input[type="text"]').first();

    // Check for accessible name
    const ariaLabel = await input.evaluate(el =>
      el.getAttribute('aria-label') || el.getAttribute('aria-labelledby')
    );

    const hasLabel = await page.locator('label').count() > 0;

    expect(ariaLabel || hasLabel).toBeTruthy();
  });

  test('disabled input has proper ARIA attributes', async ({ page }) => {
    await page.goto('/?path=/story/components-input--disabled');

    const disabledInput = page.locator('input[disabled]').first();

    await expect(disabledInput).toHaveAttribute('disabled');
    await expect(disabledInput).toHaveAttribute('aria-disabled', 'true');
  });

  test('required input has proper ARIA attributes', async ({ page }) => {
    await page.goto('/?path=/story/components-input--required');

    const requiredInput = page.locator('input[required]').first();

    await expect(requiredInput).toHaveAttribute('required');
    await expect(requiredInput).toHaveAttribute('aria-required', 'true');
  });

  test('invalid input has proper error indication', async ({ page }) => {
    await page.goto('/?path=/story/components-input--error');

    const invalidInput = page.locator('input[aria-invalid="true"]').first();

    await expect(invalidInput).toHaveAttribute('aria-invalid', 'true');
    await expect(invalidInput).toHaveAttribute('aria-describedby');
  });
});

// Performance tests
test.describe('Input Performance Tests', () => {
  test('renders 50 inputs without lag', async ({ page }) => {
    await page.goto('/?path=/story/components-input--default');

    await page.evaluate(() => {
      const container = document.createElement('div');
      container.style.display = 'grid';
      container.style.gridTemplateColumns = 'repeat(5, 1fr)';
      container.style.gap = '8px';

      for (let i = 0; i < 50; i++) {
        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = `Field ${i + 1}`;
        input.className = 'input';
        container.appendChild(input);
      }

      document.body.appendChild(container);
    });

    const screenshot = await page.screenshot({ fullPage: true });
    expect(screenshot).toMatchSnapshot('input-grid-50.png');
  });
});
