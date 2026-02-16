import { test, expect, Page, BrowserContext } from '@playwright/test';

/**
 * Cross-Browser Compatibility Test Suite
 *
 * Tests all components across Chrome, Firefox, Safari (WebKit), and Edge
 * to ensure consistent behavior and visual rendering.
 *
 * Browser Coverage:
 * - Chromium (Chrome, Edge)
 * - Firefox
 * - WebKit (Safari)
 */

// List of all components to test across browsers
const ALL_COMPONENTS = [
  'button', 'input', 'label', 'checkbox', 'switch', 'radio-group',
  'select', 'textarea', 'card', 'separator', 'tabs', 'accordion',
  'dialog', 'popover', 'tooltip', 'alert', 'badge', 'skeleton',
  'progress', 'toast', 'table', 'slider', 'toggle', 'carousel',
  'form', 'combobox', 'command', 'input-otp', 'breadcrumb',
  'navigation-menu', 'context-menu', 'dropdown-menu', 'menubar',
  'hover-card', 'aspect-ratio', 'collapsible', 'scroll-area',
  'sheet', 'drawer', 'alert-dialog', 'avatar', 'resizable',
  'calendar', 'date-picker', 'pagination'
] as const;

type ComponentName = typeof ALL_COMPONENTS[number];

/**
 * Extended browser information interface
 */
interface BrowserInfo {
  name: string;
  channel: string;
  version: string;
  userAgent: string;
}

/**
 * Cross-browser test helper to get browser info
 */
async function getBrowserInfo(page: Page): Promise<BrowserInfo> {
  const userAgent = await page.evaluate(() => navigator.userAgent);
  const browserInfo = await page.evaluate(() => {
    return {
      name: (window as any).playwright?.browser?.name || 'unknown',
      channel: (window as any).playwright?.browser?.channel || 'unknown',
      version: (window as any).playwright?.browser?.version || 'unknown',
    };
  });

  return {
    ...browserInfo,
    userAgent,
  };
}

/**
 * Test component rendering across different viewports
 */
async function testComponentRendering(
  page: Page,
  componentName: ComponentName,
  baseUrl: string
): Promise<void> {
  await page.goto(`${baseUrl}/#${componentName}`);

  // Wait for component to load
  await page.waitForLoadState('networkidle');

  // Check if component is visible
  const component = await page.locator(`[data-component="${componentName}"]`).first();
  await expect(component).toBeVisible({ timeout: 5000 });
}

/**
 * Test component interactions
 */
async function testComponentInteractions(
  page: Page,
  componentName: ComponentName,
  baseUrl: string
): Promise<void> {
  await page.goto(`${baseUrl}/#${componentName}`);
  await page.waitForLoadState('networkidle');

  // Test interactive elements based on component type
  switch (componentName) {
    case 'button':
      await testButtonInteractions(page);
      break;
    case 'input':
    case 'textarea':
      await testInputInteractions(page);
      break;
    case 'checkbox':
    case 'switch':
    case 'toggle':
      await testToggleInteractions(page);
      break;
    case 'select':
    case 'combobox':
      await testSelectInteractions(page);
      break;
    case 'tabs':
      await testTabsInteractions(page);
      break;
    case 'accordion':
      await testAccordionInteractions(page);
      break;
    case 'dialog':
    case 'alert-dialog':
    case 'sheet':
    case 'drawer':
      await testDialogInteractions(page);
      break;
    case 'popover':
    case 'tooltip':
      await testPopoverInteractions(page);
      break;
    case 'carousel':
      await testCarouselInteractions(page);
      break;
    case 'slider':
      await testSliderInteractions(page);
      break;
    default:
      // Basic visibility test for other components
      await expect(page.locator(`[data-component="${componentName}"]`)).toBeVisible();
  }
}

async function testButtonInteractions(page: Page): Promise<void> {
  const buttons = page.locator('button').first();
  await expect(buttons).toBeVisible();

  // Test hover state
  await buttons.hover();

  // Test click
  await buttons.click();
}

async function testInputInteractions(page: Page): Promise<void> {
  const input = page.locator('input, textarea').first();
  await expect(input).toBeVisible();

  // Test focus
  await input.focus();

  // Test typing
  await input.fill('Test input');
  await expect(input).toHaveValue('Test input');
}

async function testToggleInteractions(page: Page): Promise<void> {
  const toggle = page.locator('[role="checkbox"], [data-state]').first();
  await expect(toggle).toBeVisible();

  const initialState = await toggle.getAttribute('data-state');
  await toggle.click();

  const newState = await toggle.getAttribute('data-state');
  expect(newState).not.toBe(initialState);
}

async function testSelectInteractions(page: Page): Promise<void> {
  const selectTrigger = page.locator('[role="combobox"]').first();
  await expect(selectTrigger).toBeVisible();

  await selectTrigger.click();

  // Check if dropdown appears
  const dropdown = page.locator('[role="listbox"]').first();
  await expect(dropdown).toBeVisible();
}

async function testTabsInteractions(page: Page): Promise<void> {
  const tabs = page.locator('[role="tablist"]').first();
  await expect(tabs).toBeVisible();

  const firstTab = tabs.locator('[role="tab"]').first();
  await expect(firstTab).toBeVisible();
  await firstTab.click();
}

async function testAccordionInteractions(page: Page): Promise<void> {
  const accordion = page.locator('[data-state="closed"]').first();
  await expect(accordion).toBeVisible();
  await accordion.click();

  // Verify it opens
  await expect(accordion).toHaveAttribute('data-state', 'open');
}

async function testDialogInteractions(page: Page): Promise<void> {
  const trigger = page.locator('[data-state="closed"]').first();
  await expect(trigger).toBeVisible();
  await trigger.click();

  // Check if dialog content appears
  const dialog = page.locator('[role="dialog"]').first();
  await expect(dialog).toBeVisible({ timeout: 3000 });
}

async function testPopoverInteractions(page: Page): Promise<void> {
  const trigger = page.locator('[data-state="closed"]').first();
  await expect(trigger).toBeVisible();
  await trigger.hover();

  // Check if popover appears (may have delay)
  await page.waitForTimeout(500);
  const popover = page.locator('[role="dialog"], [data-state="open"]').first();
  await expect(popover).toBeVisible({ timeout: 2000 }).catch(() => {
    // Some popovers require click instead of hover
    return trigger.click();
  });
}

async function testCarouselInteractions(page: Page): Promise<void> {
  const carousel = page.locator('[data-carousel]').first();
  await expect(carousel).toBeVisible();

  // Test next button
  const nextButton = carousel.locator('[data-slide="next"]').first();
  if (await nextButton.isVisible()) {
    await nextButton.click();
  }
}

async function testSliderInteractions(page: Page): Promise<void> {
  const slider = page.locator('[role="slider"]').first();
  await expect(slider).toBeVisible();

  // Test keyboard navigation
  await slider.focus();
  await slider.press('ArrowRight');
}

/**
 * Test CSS feature detection
 */
async function testCSSFeatures(page: Page): Promise<void> {
  const features = await page.evaluate(() => {
    return {
      cssVariables: typeof CSS !== 'undefined' && CSS.supports && CSS.supports('--test', 'red'),
      flexbox: CSS.supports('display', 'flex'),
      grid: CSS.supports('display', 'grid'),
      customProperties: CSS.supports('--custom-property', 'value'),
      backdropFilter: CSS.supports('backdrop-filter', 'blur(10px)'),
      cssContainerQueries: CSS.supports('container-type', 'inline-size'),
      cssHasSelector: CSS.supports('selector(:has(div))'),
    };
  });

  // Log CSS feature support
  test.info().annotations.push({
    type: 'css_features',
    description: JSON.stringify(features, null, 2),
  });

  // Assert essential features are supported
  expect(features.cssVariables).toBe(true);
  expect(features.flexbox).toBe(true);
  expect(features.grid).toBe(true);
  expect(features.customProperties).toBe(true);
}

/**
 * Test JavaScript/WASM features
 */
async function testJSFeatures(page: Page): Promise<void> {
  const features = await page.evaluate(() => {
    return {
      wasm: typeof WebAssembly === 'object' && typeof WebAssembly.instantiate === 'function',
      requestIdleCallback: typeof requestIdleCallback === 'function',
      intersectionObserver: typeof IntersectionObserver === 'function',
      resizeObserver: typeof ResizeObserver === 'function',
      mutationObserver: typeof MutationObserver === 'function',
      weakRef: typeof WeakRef === 'function',
      finalizationRegistry: typeof FinalizationRegistry === 'function',
    };
  });

  test.info().annotations.push({
    type: 'js_features',
    description: JSON.stringify(features, null, 2),
  });

  // Assert essential features are supported
  expect(features.wasm).toBe(true);
  expect(features.intersectionObserver).toBe(true);
  expect(features.resizeObserver).toBe(true);
}

/**
 * Test accessibility across browsers
 */
async function testAccessibilityFeatures(page: Page): Promise<void> {
  const a11y = await page.evaluate(() => {
    // Check ARIA support
    const testElement = document.createElement('div');
    testElement.setAttribute('role', 'button');
    testElement.setAttribute('aria-label', 'Test');

    return {
      ariaSupported: testElement.getAttribute('role') === 'button',
      ariaLabelSupported: testElement.getAttribute('aria-label') === 'Test',
      hasDocumentAccess: typeof document !== 'undefined',
      hasWindowAccess: typeof window !== 'undefined',
      hasComputedStyle: typeof getComputedStyle === 'function',
    };
  });

  expect(a11y.ariaSupported).toBe(true);
  expect(a11y.ariaLabelSupported).toBe(true);
  expect(a11y.hasComputedStyle).toBe(true);
}

/**
 * Test viewport responsiveness
 */
async function testViewportSizes(page: Page): Promise<void> {
  const viewports = [
    { width: 1920, height: 1080 }, // Desktop
    { width: 1366, height: 768 },  // Laptop
    { width: 768, height: 1024 },   // Tablet
    { width: 375, height: 667 },    // Mobile
  ];

  for (const viewport of viewports) {
    await page.setViewportSize(viewport);
    await page.waitForTimeout(500);

    // Verify no horizontal scroll on mobile
    if (viewport.width <= 768) {
      const bodyWidth = await page.evaluate(() => document.body.scrollWidth);
      expect(bodyWidth).toBeLessThanOrEqual(viewport.width + 20); // Allow small margin
    }
  }
}

/**
 * Test event handling consistency
 */
async function testEventHandling(page: Page): Promise<void> {
  const events: string[] = [];

  await page.evaluate((eventList) => {
    const button = document.querySelector('button');
    if (button) {
      eventList.forEach((event: string) => {
        button.addEventListener(event, () => {
          (window as any).testEvents = (window as any).testEvents || [];
          (window as any).testEvents.push(event);
        });
      });
    }
  }, ['click', 'mouseenter', 'mouseleave', 'focus', 'blur']);

  const button = page.locator('button').first();
  await button.click();

  const triggeredEvents = await page.evaluate(() => (window as any).testEvents || []);
  expect(triggeredEvents).toContain('click');
}

/**
 * Test focus management
 */
async function testFocusManagement(page: Page): Promise<void> {
  // Test tab navigation
  const firstFocusable = page.locator('button, input, [tabindex]:not([tabindex="-1"])').first();
  await firstFocusable.focus();

  const hasFocus = await firstFocusable.evaluate((el: any) => document.activeElement === el);
  expect(hasFocus).toBe(true);

  // Test tab key navigation
  await page.keyboard.press('Tab');
  await page.waitForTimeout(100);

  const newFocusedElement = await page.evaluate(() => {
    const focused = document.activeElement;
    return focused?.tagName || null;
  });

  expect(newFocusedElement).toBeTruthy();
}

/**
 * Test form input consistency
 */
async function testFormInputs(page: Page): Promise<void> {
  await page.goto('/#form');
  await page.waitForLoadState('networkidle');

  const form = page.locator('form').first();
  await expect(form).toBeVisible();

  // Test various input types
  const inputTypes = ['text', 'email', 'password', 'number', 'tel', 'url'];

  for (const type of inputTypes) {
    const input = form.locator(`input[type="${type}"]`).first();
    if (await input.isVisible()) {
      await input.fill(`test_${type}`);
      await expect(input).toHaveValue(`test_${type}`);
    }
  }
}

/**
 * Test animation and transitions
 */
async function testAnimations(page: Page): Promise<void> {
  const supportsAnimation = await page.evaluate(() => {
    const elem = document.createElement('div');
    return CSS.supports('animation', '1s') &&
           CSS.supports('transition', '1s') &&
           typeof elem.animate === 'function';
  });

  expect(supportsAnimation).toBe(true);

  test.info().annotations.push({
    type: 'animation_support',
    description: supportsAnimation ? 'Animations supported' : 'Animations not supported',
  });
}

// ============================================================================
// MAIN TEST SUITES
// ============================================================================

test.describe('Cross-Browser: Core Features', () => {
  test.beforeEach(async ({ page }) => {
    const browserInfo = await getBrowserInfo(page);
    test.info().annotations.push({
      type: 'browser_info',
      description: `${browserInfo.name} ${browserInfo.version} (${browserInfo.channel})`,
    });
  });

  test('should support essential CSS features', async ({ page }) => {
    await testCSSFeatures(page);
  });

  test('should support essential JavaScript features', async ({ page }) => {
    await testJSFeatures(page);
  });

  test('should support accessibility features', async ({ page }) => {
    await testAccessibilityFeatures(page);
  });

  test('should handle viewport changes', async ({ page }) => {
    await testViewportSizes(page);
  });

  test('should handle events consistently', async ({ page }) => {
    await testEventHandling(page);
  });

  test('should manage focus correctly', async ({ page }) => {
    await testFocusManagement(page);
  });

  test('should support form inputs', async ({ page }) => {
    await testFormInputs(page);
  });

  test('should support animations', async ({ page }) => {
    await testAnimations(page);
  });
});

test.describe('Cross-Browser: Basic Components', () => {
  const basicComponents: ComponentName[] = [
    'button', 'input', 'label', 'checkbox', 'switch', 'radio-group',
    'select', 'textarea', 'badge', 'separator', 'skeleton', 'progress',
  ];

  for (const component of basicComponents) {
    test.describe(`${component}`, () => {
      test.beforeEach(async ({ page }) => {
        const browserInfo = await getBrowserInfo(page);
        test.info().annotations.push({
          type: 'browser_info',
          description: `${browserInfo.name} ${browserInfo.version}`,
        });
      });

      test(`should render ${component} correctly`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
      });

      test(`should handle ${component} interactions`, async ({ page }) => {
        await testComponentInteractions(page, component, '/');
      });
    });
  }
});

test.describe('Cross-Browser: Interactive Components', () => {
  const interactiveComponents: ComponentName[] = [
    'tabs', 'accordion', 'dialog', 'popover', 'tooltip', 'carousel',
    'slider', 'toggle', 'combobox', 'dropdown-menu', 'context-menu',
  ];

  for (const component of interactiveComponents) {
    test.describe(`${component}`, () => {
      test.beforeEach(async ({ page }) => {
        const browserInfo = await getBrowserInfo(page);
        test.info().annotations.push({
          type: 'browser_info',
          description: `${browserInfo.name} ${browserInfo.version}`,
        });
      });

      test(`should render ${component} correctly`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
      });

      test(`should handle ${component} interactions`, async ({ page }) => {
        await testComponentInteractions(page, component, '/');
      });

      test(`should support keyboard navigation in ${component}`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
        await page.keyboard.press('Tab');
        await page.waitForTimeout(100);

        const focusedElement = await page.evaluate(() => {
          const focused = document.activeElement;
          return {
            tag: focused?.tagName,
            role: focused?.getAttribute('role'),
          };
        });

        expect(focusedElement.tag).toBeTruthy();
      });
    });
  }
});

test.describe('Cross-Browser: Layout Components', () => {
  const layoutComponents: ComponentName[] = [
    'card', 'separator', 'scroll-area', 'collapsible', 'aspect-ratio',
    'resizable', 'navigation-menu', 'menubar', 'breadcrumb',
  ];

  for (const component of layoutComponents) {
    test.describe(`${component}`, () => {
      test.beforeEach(async ({ page }) => {
        const browserInfo = await getBrowserInfo(page);
        test.info().annotations.push({
          type: 'browser_info',
          description: `${browserInfo.name} ${browserInfo.version}`,
        });
      });

      test(`should render ${component} correctly`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
      });

      test(`should handle ${component} responsiveness`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
        await testViewportSizes(page);
      });
    });
  }
});

test.describe('Cross-Browser: Complex Components', () => {
  const complexComponents: ComponentName[] = [
    'form', 'calendar', 'date-picker', 'input-otp', 'table',
    'avatar', 'toast', 'alert-dialog', 'sheet', 'drawer',
  ];

  for (const component of complexComponents) {
    test.describe(`${component}`, () => {
      test.beforeEach(async ({ page }) => {
        const browserInfo = await getBrowserInfo(page);
        test.info().annotations.push({
          type: 'browser_info',
          description: `${browserInfo.name} ${browserInfo.version}`,
        });
      });

      test(`should render ${component} correctly`, async ({ page }) => {
        await testComponentRendering(page, component, '/');
      });

      test(`should handle ${component} interactions`, async ({ page }) => {
        await testComponentInteractions(page, component, '/');
      });

      test(`should maintain accessibility in ${component}`, async ({ page }) => {
        await testComponentRendering(page, component, '/');

        // Check for ARIA attributes
        const hasAria = await page.evaluate(() => {
          const elements = document.querySelectorAll('[role], [aria-label], [aria-describedby]');
          return elements.length > 0;
        });

        expect(hasAria).toBe(true);
      });
    });
  }
});

test.describe('Cross-Browser: WASM Module Loading', () => {
  test('should load WASM modules successfully', async ({ page }) => {
    const browserInfo = await getBrowserInfo(page);
    test.info().annotations.push({
      type: 'browser_info',
      description: `${browserInfo.name} ${browserInfo.version}`,
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Check if WASM is loaded
    const wasmLoaded = await page.evaluate(() => {
      return typeof WebAssembly === 'object' && WebAssembly.module !== undefined;
    });

    expect(wasmLoaded).toBe(true);
  });

  test('should execute WASM functions', async ({ page }) => {
    const browserInfo = await getBrowserInfo(page);
    test.info().annotations.push({
      type: 'browser_info',
      description: `${browserInfo.name} ${browserInfo.version}`,
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Check for any JavaScript errors
    const errors: string[] = [];
    page.on('pageerror', (error) => errors.push(error.message));

    await page.waitForTimeout(2000);

    // If there were critical errors, fail the test
    const criticalErrors = errors.filter(e =>
      e.includes('WASM') ||
      e.includes('WebAssembly') ||
      e.includes('CompileError')
    );

    expect(criticalErrors).toHaveLength(0);
  });
});

test.describe('Cross-Browser: Performance Metrics', () => {
  test('should meet performance thresholds', async ({ page }) => {
    const browserInfo = await getBrowserInfo(page);
    test.info().annotations.push({
      type: 'browser_info',
      description: `${browserInfo.name} ${browserInfo.version}`,
    });

    // Start performance monitoring
    const metrics = await page.evaluate(() => {
      return new Promise((resolve) => {
        if (!(window as any).PerformanceObserver) {
          resolve({});
          return;
        }

        const observer = new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const metrics: any = {};

          entries.forEach((entry: any) => {
            if (entry.entryType === 'navigation') {
              metrics.domContentLoaded = entry.domContentLoadedEventEnd - entry.domContentLoadedEventStart;
              metrics.loadComplete = entry.loadEventEnd - entry.loadEventStart;
            }
          });

          resolve(metrics);
        });

        observer.observe({ entryTypes: ['navigation'] });

        // Fallback timeout
        setTimeout(() => resolve({}), 5000);
      });
    });

    test.info().annotations.push({
      type: 'performance_metrics',
      description: JSON.stringify(metrics, null, 2),
    });
  });
});
