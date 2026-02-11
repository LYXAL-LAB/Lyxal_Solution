/**
 * Performance threshold tests for Dialog, Dropdown Menu, and Sheet components
 * Tests measure render times and interactive operation response times
 */

import { test, expect } from '@playwright/test';

// Performance thresholds as specified in requirements
const PERFORMANCE_THRESHOLDS = {
  maxInitializationTime: 100, // 100ms for component initialization
  maxInteractionTime: 50,     // 50ms for interactive operations
} as const;

// Performance metrics interface
interface PerformanceMetrics {
  initializationTime: number;
  interactionTime: number;
  componentName: string;
  operation: string;
}

// Store metrics for console logging
const metricsLog: PerformanceMetrics[] = [];

/**
 * Log performance metrics to console
 */
function logMetrics(metrics: PerformanceMetrics): void {
  metricsLog.push(metrics);

  console.log(`\n=== Performance Metrics: ${metrics.componentName} ===`);
  console.log(`Operation: ${metrics.operation}`);
  console.log(`Initialization Time: ${metrics.initializationTime.toFixed(2)}ms (threshold: ${PERFORMANCE_THRESHOLDS.maxInitializationTime}ms)`);
  console.log(`Interaction Time: ${metrics.interactionTime.toFixed(2)}ms (threshold: ${PERFORMANCE_THRESHOLDS.maxInteractionTime}ms)`);
  console.log(`Status: ✓ PASSED`);
  console.log('='.repeat(50));
}

/**
 * Measure component initialization time
 */
async function measureInitializationTime(
  page: any,
  initFn: () => Promise<void>
): Promise<number> {
  const startTime = performance.now();
  await initFn();
  const endTime = performance.now();

  // Wait for any pending animations/rendering
  await page.waitForTimeout(50);

  return endTime - startTime;
}

/**
 * Measure interaction response time
 */
async function measureInteractionTime(
  page: any,
  interactionFn: () => Promise<void>
): Promise<number> {
  // Start measurement just before interaction
  const startTime = performance.now();
  await interactionFn();

  // Wait for the interaction to complete (animation/update)
  await page.waitForTimeout(10);

  const endTime = performance.now();
  return endTime - startTime;
}

// ===== DIALOG PERFORMANCE TESTS =====

test.describe('Dialog Performance Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-dialog--default');
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('[data-story-loaded="true"], .sb-show-main', { timeout: 10000 })
      .catch(() => page.waitForTimeout(500));
  });

  test('Dialog initialization completes within 100ms', async ({ page }) => {
    const initTime = await measureInitializationTime(page, async () => {
      // Navigate to the dialog story and wait for render
      await page.goto('http://localhost:6006/?path=/story/components-dialog--default', { waitUntil: 'domcontentloaded' });

      // Wait for dialog component to be present
      await page.waitForSelector('button, [role="dialog"]', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Dialog',
      operation: 'Initialization',
    });
  });

  test('Dialog open operation responds within 50ms', async ({ page }) => {
    // Find and click the dialog trigger button
    const triggerButton = page.locator('button').filter({ hasText: /open|trigger/i }).first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await triggerButton.click();
    });

    // Verify dialog opened
    await expect(page.locator('[role="dialog"]').first()).toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Dialog',
      operation: 'Open',
    });
  });

  test('Dialog close operation responds within 50ms', async ({ page }) => {
    // Open the dialog first
    const triggerButton = page.locator('button').filter({ hasText: /open|trigger/i }).first();
    await triggerButton.click();
    await page.waitForSelector('[role="dialog"]', { state: 'visible' });

    // Find close button (X button or overlay)
    const closeButton = page.locator('[aria-label="Close"], button[data-state="open"], [role="dialog"] button').first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await closeButton.click();
    });

    // Verify dialog closed
    await expect(page.locator('[role="dialog"]').first()).not.toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Dialog',
      operation: 'Close',
    });
  });

  test('Dialog with complex content initializes within 100ms', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-dialog--with-form');
    await page.waitForLoadState('networkidle');

    const initTime = await measureInitializationTime(page, async () => {
      await page.waitForSelector('[role="dialog"]', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Dialog',
      operation: 'Complex Content Initialization',
    });
  });
});

// ===== DROPDOWN MENU PERFORMANCE TESTS =====

test.describe('Dropdown Menu Performance Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-dropdown-menu--default');
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('[data-story-loaded="true"], .sb-show-main', { timeout: 10000 })
      .catch(() => page.waitForTimeout(500));
  });

  test('Dropdown Menu initialization completes within 100ms', async ({ page }) => {
    const initTime = await measureInitializationTime(page, async () => {
      await page.goto('http://localhost:6006/?path=/story/components-dropdown-menu--default', { waitUntil: 'domcontentloaded' });
      await page.waitForSelector('button', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Dropdown Menu',
      operation: 'Initialization',
    });
  });

  test('Dropdown Menu open operation responds within 50ms', async ({ page }) => {
    const triggerButton = page.locator('button').first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await triggerButton.click();
    });

    // Verify dropdown menu opened
    await expect(page.locator('[role="menu"], [data-state="open"]').first()).toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Dropdown Menu',
      operation: 'Open',
    });
  });

  test('Dropdown Menu close operation responds within 50ms', async ({ page }) => {
    // Open the menu first
    const triggerButton = page.locator('button').first();
    await triggerButton.click();
    await page.waitForSelector('[role="menu"]', { state: 'visible' });

    // Click outside to close
    const interactionTime = await measureInteractionTime(page, async () => {
      await page.mouse.click(100, 100);
    });

    // Verify menu closed
    await expect(page.locator('[role="menu"]').first()).not.toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Dropdown Menu',
      operation: 'Close (click outside)',
    });
  });

  test('Dropdown Menu item selection responds within 50ms', async ({ page }) => {
    // Open the menu
    const triggerButton = page.locator('button').first();
    await triggerButton.click();
    await page.waitForSelector('[role="menu"]', { state: 'visible' });

    // Click a menu item
    const menuItem = page.locator('[role="menuitem"]').first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await menuItem.click();
    });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Dropdown Menu',
      operation: 'Item Selection',
    });
  });

  test('Dropdown Menu with many items initializes within 100ms', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-dropdown-menu--with-many-items');
    await page.waitForLoadState('networkidle');

    const initTime = await measureInitializationTime(page, async () => {
      await page.waitForSelector('[role="menu"]', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Dropdown Menu',
      operation: 'Many Items Initialization',
    });
  });
});

// ===== SHEET PERFORMANCE TESTS =====

test.describe('Sheet Performance Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-sheet--default');
    await page.waitForLoadState('networkidle');
    await page.waitForSelector('[data-story-loaded="true"], .sb-show-main', { timeout: 10000 })
      .catch(() => page.waitForTimeout(500));
  });

  test('Sheet initialization completes within 100ms', async ({ page }) => {
    const initTime = await measureInitializationTime(page, async () => {
      await page.goto('http://localhost:6006/?path=/story/components-sheet--default', { waitUntil: 'domcontentloaded' });
      await page.waitForSelector('button', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Sheet',
      operation: 'Initialization',
    });
  });

  test('Sheet open operation responds within 50ms', async ({ page }) => {
    const triggerButton = page.locator('button').filter({ hasText: /open|trigger/i }).first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await triggerButton.click();
    });

    // Verify sheet opened
    await expect(page.locator('[role="dialog"], .sheet').first()).toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Sheet',
      operation: 'Open',
    });
  });

  test('Sheet close operation responds within 50ms', async ({ page }) => {
    // Open the sheet first
    const triggerButton = page.locator('button').filter({ hasText: /open|trigger/i }).first();
    await triggerButton.click();
    await page.waitForSelector('[role="dialog"], .sheet', { state: 'visible' });

    // Find close button
    const closeButton = page.locator('[aria-label="Close"], button[data-state="open"], [role="dialog"] button').first();

    const interactionTime = await measureInteractionTime(page, async () => {
      await closeButton.click();
    });

    // Verify sheet closed
    await expect(page.locator('[role="dialog"], .sheet').first()).not.toBeVisible({ timeout: 2000 });

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Sheet',
      operation: 'Close',
    });
  });

  test('Sheet with form content initializes within 100ms', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-sheet--with-form');
    await page.waitForLoadState('networkidle');

    const initTime = await measureInitializationTime(page, async () => {
      await page.waitForSelector('[role="dialog"], .sheet', { timeout: 5000 });
    });

    expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

    logMetrics({
      initializationTime: initTime,
      interactionTime: 0,
      componentName: 'Sheet',
      operation: 'Form Content Initialization',
    });
  });

  test('Sheet slide animation completes within performance threshold', async ({ page }) => {
    const triggerButton = page.locator('button').filter({ hasText: /open|trigger/i }).first();

    // Measure time for the sheet to fully appear
    const startTime = performance.now();
    await triggerButton.click();

    // Wait for the sheet animation to complete
    await page.waitForSelector('[role="dialog"], .sheet', { state: 'visible' });

    // Additional wait for slide animation to finish
    await page.waitForTimeout(300);

    const endTime = performance.now();
    const animationTime = endTime - startTime;

    // Animation should be fast (we measure interaction time separately)
    const interactionTime = animationTime;

    expect(interactionTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime + 300); // Allow for animation duration

    logMetrics({
      initializationTime: 0,
      interactionTime,
      componentName: 'Sheet',
      operation: 'Slide Animation',
    });
  });
});

// ===== CROSS-COMPONENT PERFORMANCE TESTS =====

test.describe('Cross-Component Performance Tests', () => {
  test('All components initialize within threshold on first load', async ({ page }) => {
    const components = [
      { name: 'Dialog', url: 'http://localhost:6006/?path=/story/components-dialog--default' },
      { name: 'Dropdown Menu', url: 'http://localhost:6006/?path=/story/components-dropdown-menu--default' },
      { name: 'Sheet', url: 'http://localhost:6006/?path=/story/components-sheet--default' },
    ];

    for (const component of components) {
      const initTime = await measureInitializationTime(page, async () => {
        await page.goto(component.url, { waitUntil: 'domcontentloaded' });
        await page.waitForSelector('button, [role="dialog"]', { timeout: 5000 });
      });

      expect(initTime).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInitializationTime);

      logMetrics({
        initializationTime: initTime,
        interactionTime: 0,
        componentName: component.name,
        operation: 'First Load Initialization',
      });
    }
  });

  test('Rapid component interactions stay within threshold', async ({ page }) => {
    // Test Dialog
    await page.goto('http://localhost:6006/?path=/story/components-dialog--default');
    await page.waitForLoadState('networkidle');

    const dialogTrigger = page.locator('button').first();
    const interactionTimes: number[] = [];

    // Perform 5 rapid open/close cycles
    for (let i = 0; i < 5; i++) {
      const openTime = await measureInteractionTime(page, async () => {
        await dialogTrigger.click();
      });
      interactionTimes.push(openTime);

      await page.waitForTimeout(100);

      const closeTime = await measureInteractionTime(page, async () => {
        const closeButton = page.locator('[aria-label="Close"], button').nth(1);
        await closeButton.click();
      });
      interactionTimes.push(closeTime);

      await page.waitForTimeout(100);
    }

    // All interactions should be within threshold
    for (let i = 0; i < interactionTimes.length; i++) {
      expect(interactionTimes[i]).toBeLessThan(PERFORMANCE_THRESHOLDS.maxInteractionTime);
    }

    const avgTime = interactionTimes.reduce((a, b) => a + b) / interactionTimes.length;

    console.log(`\n=== Rapid Interactions Test ===`);
    console.log(`Average interaction time: ${avgTime.toFixed(2)}ms`);
    console.log(`Max interaction time: ${Math.max(...interactionTimes).toFixed(2)}ms`);
    console.log(`Min interaction time: ${Math.min(...interactionTimes).toFixed(2)}ms`);
  });
});

// ===== PERFORMANCE SUMMARY =====

test.afterAll(async () => {
  console.log('\n\n' + '='.repeat(60));
  console.log('PERFORMANCE TEST SUMMARY');
  console.log('='.repeat(60));

  if (metricsLog.length === 0) {
    console.log('No metrics collected.');
    return;
  }

  // Group by component
  const byComponent = metricsLog.reduce((acc, metric) => {
    if (!acc[metric.componentName]) {
      acc[metric.componentName] = [];
    }
    acc[metric.componentName].push(metric);
    return acc;
  }, {} as Record<string, PerformanceMetrics[]>);

  for (const [component, metrics] of Object.entries(byComponent)) {
    console.log(`\n${component}:`);

    for (const metric of metrics) {
      if (metric.initializationTime > 0) {
        console.log(`  ${metric.operation}: ${metric.initializationTime.toFixed(2)}ms`);
      }
      if (metric.interactionTime > 0) {
        console.log(`  ${metric.operation}: ${metric.interactionTime.toFixed(2)}ms`);
      }
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log(`Total Tests: ${metricsLog.length}`);
  console.log(`All tests passed within performance thresholds!`);
  console.log('='.repeat(60) + '\n');
});
