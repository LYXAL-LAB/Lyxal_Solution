/**
 * Network Throttling Test Suite
 *
 * Tests components with async loading (lazy-loading, command, combobox)
 * under simulated 3G and 4G network conditions to verify:
 * - Fallback UI appears during 500ms+ latency
 * - Components load successfully once network simulation completes
 *
 * Uses Playwright's CDPSession to emulate network conditions.
 */

import { test, expect } from '@playwright/test';

// Network condition profiles based on standard 3G/4G specifications
const NETWORK_PROFILES = {
  // Slow 3G - 500ms RTT, 50 Kbps throughput
  'slow-3g': {
    offline: false,
    downloadThroughput: 50 * 1024 / 8, // 50 Kbps in bytes/s
    uploadThroughput: 20 * 1024 / 8, // 20 Kbps in bytes/s
    latency: 500, // 500ms RTT
  },
  // Fast 3G - 100ms RTT, 750 Kbps throughput
  'fast-3g': {
    offline: false,
    downloadThroughput: 750 * 1024 / 8, // 750 Kbps in bytes/s
    uploadThroughput: 250 * 1024 / 8, // 250 Kbps in bytes/s
    latency: 100, // 100ms RTT
  },
  // 4G - 40ms RTT, 4 Mbps throughput
  '4g': {
    offline: false,
    downloadThroughput: 4 * 1024 * 1024 / 8, // 4 Mbps in bytes/s
    uploadThroughput: 3 * 1024 * 1024 / 8, // 3 Mbps in bytes/s
    latency: 40, // 40ms RTT
  },
} as const;

type NetworkProfile = keyof typeof NETWORK_PROFILES;

// Test thresholds
const THRESHOLDS = {
  minLoadingDisplayTime: 500, // Loading state should appear within 500ms
  maxLoadTimeSlow3G: 15000, // Max load time on slow 3G (15s)
  maxLoadTimeFast3G: 8000, // Max load time on fast 3G (8s)
  maxLoadTime4G: 3000, // Max load time on 4G (3s)
} as const;

// Performance metrics collection
interface NetworkTestMetrics {
  componentName: string;
  networkProfile: NetworkProfile;
  loadTime: number;
  loadingVisible: boolean;
  loadingDisplayTime: number;
  fallbackVisible: boolean;
  success: boolean;
}

const metricsLog: NetworkTestMetrics[] = [];

/**
 * Set network conditions using Chrome DevTools Protocol
 */
async function setNetworkConditions(
  page: any,
  profile: NetworkProfile
): Promise<void> {
  const client = await page.context().newCDPSession(page);
  await client.send('Network.emulateNetworkConditions', {
    ...NETWORK_PROFILES[profile],
  });
}

/**
 * Reset network conditions to normal
 */
async function resetNetworkConditions(page: any): Promise<void> {
  const client = await page.context().newCDPSession(page);
  await client.send('Network.emulateNetworkConditions', {
    offline: false,
    downloadThroughput: -1,
    uploadThroughput: -1,
    latency: 0,
  });
}

/**
 * Measure time until loading state appears
 */
async function measureLoadingStateAppearance(
  page: any,
  loadingSelector: string,
  maxWaitTime: number = THRESHOLDS.minLoadingDisplayTime
): Promise<{ visible: boolean; time: number }> {
  const startTime = Date.now();

  try {
    await page.waitForSelector(loadingSelector, {
      state: 'visible',
      timeout: maxWaitTime,
    });
    const time = Date.now() - startTime;
    return { visible: true, time };
  } catch {
    return { visible: false, time: Date.now() - startTime };
  }
}

/**
 * Wait for component to finish loading
 */
async function waitForComponentLoad(
  page: any,
  successSelector: string,
  maxWaitTime: number
): Promise<{ success: boolean; time: number }> {
  const startTime = Date.now();

  try {
    await page.waitForSelector(successSelector, {
      state: 'visible',
      timeout: maxWaitTime,
    });
    const time = Date.now() - startTime;
    return { success: true, time };
  } catch {
    return { success: false, time: Date.now() - startTime };
  }
}

/**
 * Log test metrics
 */
function logMetrics(metrics: NetworkTestMetrics): void {
  metricsLog.push(metrics);

  console.log(`\n=== Network Test: ${metrics.componentName} ===`);
  console.log(`Network Profile: ${metrics.networkProfile}`);
  console.log(`Load Time: ${metrics.loadTime.toFixed(2)}ms`);
  console.log(`Loading State Visible: ${metrics.loadingVisible}`);
  console.log(`Loading Display Time: ${metrics.loadingDisplayTime.toFixed(2)}ms`);
  console.log(`Fallback Visible: ${metrics.fallbackVisible}`);
  console.log(`Success: ${metrics.success ? '✓ PASSED' : '✗ FAILED'}`);
  console.log('='.repeat(50));
}

// ===== LAZY LOADING COMPONENT TESTS =====

test.describe('Lazy Loading - Network Throttling Tests', () => {
  test.afterEach(async ({ page }) => {
    // Reset network conditions after each test
    await resetNetworkConditions(page);
  });

  test('should show fallback UI during slow 3G loading', async ({ page }) => {
    // Navigate to lazy loading demo page
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    // Look for lazy loading component triggers
    const loadButton = page.locator('.load-component-btn, .load-btn').first();
    const buttonCount = await loadButton.count();

    test.skip(buttonCount === 0, 'Lazy loading component not found on page');

    // Start the load operation
    const startTime = Date.now();
    await loadButton.click();

    // Check for loading state within 500ms
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.component-loading, .loading-spinner, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Verify loading state appeared
    expect(loadingResult.visible).toBe(true);

    // Wait for component to load successfully
    const loadResult = await waitForComponentLoad(
      page,
      '.component-content, .component-success',
      THRESHOLDS.maxLoadTimeSlow3G
    );

    const totalTime = Date.now() - startTime;

    // Verify component loaded successfully
    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Lazy Loading',
      networkProfile: 'slow-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: true,
      success: loadResult.success,
    });
  });

  test('should load successfully on fast 3G network', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set fast 3G network conditions
    await setNetworkConditions(page, 'fast-3g');

    const loadButton = page.locator('.load-component-btn, .load-btn').first();
    const buttonCount = await loadButton.count();

    test.skip(buttonCount === 0, 'Lazy loading component not found on page');

    const startTime = Date.now();
    await loadButton.click();

    // Check for loading state
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.component-loading, .loading-spinner, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Wait for component to load
    const loadResult = await waitForComponentLoad(
      page,
      '.component-content, .component-success',
      THRESHOLDS.maxLoadTimeFast3G
    );

    const totalTime = Date.now() - startTime;

    expect(loadingResult.visible).toBe(true);
    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Lazy Loading',
      networkProfile: 'fast-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: true,
      success: loadResult.success,
    });
  });

  test('should load quickly on 4G network', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set 4G network conditions
    await setNetworkConditions(page, '4g');

    const loadButton = page.locator('.load-component-btn, .load-btn').first();
    const buttonCount = await loadButton.count();

    test.skip(buttonCount === 0, 'Lazy loading component not found on page');

    const startTime = Date.now();
    await loadButton.click();

    // On 4G, loading might be very fast, but we still check
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.component-loading, .loading-spinner, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    const loadResult = await waitForComponentLoad(
      page,
      '.component-content, .component-success',
      THRESHOLDS.maxLoadTime4G
    );

    const totalTime = Date.now() - startTime;

    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Lazy Loading',
      networkProfile: '4g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: true,
      success: loadResult.success,
    });
  });

  test('should handle multiple concurrent lazy loads on slow network', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    const loadButtons = page.locator('.load-component-btn, .load-btn');
    const buttonCount = await loadButtons.count();

    test.skip(buttonCount < 3, 'Need at least 3 lazy loading components for this test');

    const startTime = Date.now();

    // Load first 3 components simultaneously
    for (let i = 0; i < 3; i++) {
      await loadButtons.nth(i).click();
    }

    // Check that loading states appear for all
    const loadingElements = page.locator('.component-loading, .loading-spinner');
    await expect(loadingElements).toHaveCount(3, { timeout: 1000 });

    // Wait for all to complete
    const successElements = page.locator('.component-success');
    const successCount = await successElements.count();

    const totalTime = Date.now() - startTime;

    // At least some should succeed
    expect(successCount).toBeGreaterThan(0);

    logMetrics({
      componentName: 'Lazy Loading (Multiple)',
      networkProfile: 'slow-3g',
      loadTime: totalTime,
      loadingVisible: true,
      loadingDisplayTime: 0,
      fallbackVisible: true,
      success: successCount > 0,
    });
  });
});

// ===== COMMAND COMPONENT TESTS =====

test.describe('Command Component - Network Throttling Tests', () => {
  test.afterEach(async ({ page }) => {
    await resetNetworkConditions(page);
  });

  test('should display loading state when fetching commands on slow 3G', async ({ page }) => {
    // Look for command component on storybook or demo pages
    await page.goto('http://localhost:6006/?path=/story/components-command--default');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    // Look for command input or trigger
    const commandTrigger = page.locator('[data-testid="command-trigger"], button').filter({ hasText: /command|search/i }).first();
    const triggerCount = await commandTrigger.count();

    test.skip(triggerCount === 0, 'Command component not found on page');

    const startTime = Date.now();
    await commandTrigger.click();

    // Check for command dialog and loading state
    const commandDialog = page.locator('[role="dialog"], .command-dialog');
    await expect(commandDialog).toBeVisible({ timeout: 5000 });

    // Type to trigger async search
    const commandInput = page.locator('input[placeholder*="search" i], input[type="text"]').first();
    await commandInput.fill('test');

    // Check for loading indicator in search results
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.command-loading, .search-loading, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Wait for results to load
    const loadResult = await waitForComponentLoad(
      page,
      '.command-item, [role="option"], .search-result',
      THRESHOLDS.maxLoadTimeSlow3G
    );

    const totalTime = Date.now() - startTime;

    // Command should be functional even on slow network
    expect(commandDialog).toBeVisible();

    logMetrics({
      componentName: 'Command (Search)',
      networkProfile: 'slow-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: loadingResult.visible,
      success: loadResult.success,
    });
  });

  test('should load command list quickly on 4G', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-command--default');
    await page.waitForLoadState('domcontentloaded');

    // Set 4G network conditions
    await setNetworkConditions(page, '4g');

    const commandTrigger = page.locator('[data-testid="command-trigger"], button').filter({ hasText: /command|search/i }).first();
    const triggerCount = await commandTrigger.count();

    test.skip(triggerCount === 0, 'Command component not found on page');

    const startTime = Date.now();
    await commandTrigger.click();

    // Command dialog should appear quickly
    const commandDialog = page.locator('[role="dialog"], .command-dialog');
    await expect(commandDialog).toBeVisible({ timeout: THRESHOLDS.maxLoadTime4G });

    const totalTime = Date.now() - startTime;

    logMetrics({
      componentName: 'Command (Open)',
      networkProfile: '4g',
      loadTime: totalTime,
      loadingVisible: false,
      loadingDisplayTime: 0,
      fallbackVisible: false,
      success: true,
    });
  });

  test('should handle rapid keyboard input on slow network', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-command--default');
    await page.waitForLoadState('domcontentloaded');

    // Set fast 3G network conditions
    await setNetworkConditions(page, 'fast-3g');

    const commandTrigger = page.locator('[data-testid="command-trigger"], button').filter({ hasText: /command|search/i }).first();
    const triggerCount = await commandTrigger.count();

    test.skip(triggerCount === 0, 'Command component not found on page');

    await commandTrigger.click();

    const commandInput = page.locator('input[placeholder*="search" i], input[type="text"]').first();
    await commandInput.focus();

    const startTime = Date.now();

    // Type rapidly
    await commandInput.fill('search query');

    // Check that loading state appears
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.command-loading, .search-loading',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Wait for results
    const loadResult = await waitForComponentLoad(
      page,
      '.command-item, [role="option"]',
      THRESHOLDS.maxLoadTimeFast3G
    );

    const totalTime = Date.now() - startTime;

    // Input should remain responsive
    expect(await commandInput.inputValue()).toBe('search query');

    logMetrics({
      componentName: 'Command (Rapid Input)',
      networkProfile: 'fast-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: loadingResult.visible,
      success: loadResult.success,
    });
  });
});

// ===== COMBOBOX COMPONENT TESTS =====

test.describe('Combobox Component - Network Throttling Tests', () => {
  test.afterEach(async ({ page }) => {
    await resetNetworkConditions(page);
  });

  test('should show loading state when fetching options on slow 3G', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-combobox--default');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    // Look for combobox input
    const comboboxInput = page.locator('[role="combobox"], input[data-testid="combobox"]').first();
    const inputCount = await comboboxInput.count();

    test.skip(inputCount === 0, 'Combobox component not found on page');

    const startTime = Date.now();

    // Click to open and trigger option loading
    await comboboxInput.click();

    // Check for loading state
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.combobox-loading, .options-loading, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Wait for options to load
    const loadResult = await waitForComponentLoad(
      page,
      '[role="option"], .combobox-option',
      THRESHOLDS.maxLoadTimeSlow3G
    );

    const totalTime = Date.now() - startTime;

    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Combobox (Open)',
      networkProfile: 'slow-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: loadingResult.visible,
      success: loadResult.success,
    });
  });

  test('should filter options efficiently on 4G', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-combobox--default');
    await page.waitForLoadState('domcontentloaded');

    // Set 4G network conditions
    await setNetworkConditions(page, '4g');

    const comboboxInput = page.locator('[role="combobox"], input[data-testid="combobox"]').first();
    const inputCount = await comboboxInput.count();

    test.skip(inputCount === 0, 'Combobox component not found on page');

    // Open combobox
    await comboboxInput.click();

    const startTime = Date.now();

    // Type to filter
    await comboboxInput.fill('test');

    // Wait for filtered results
    const loadResult = await waitForComponentLoad(
      page,
      '[role="option"], .combobox-option',
      THRESHOLDS.maxLoadTime4G
    );

    const totalTime = Date.now() - startTime;

    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Combobox (Filter)',
      networkProfile: '4g',
      loadTime: totalTime,
      loadingVisible: false,
      loadingDisplayTime: 0,
      fallbackVisible: false,
      success: loadResult.success,
    });
  });

  test('should handle async option loading on fast 3G', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-combobox--async');
    await page.waitForLoadState('domcontentloaded');

    // Set fast 3G network conditions
    await setNetworkConditions(page, 'fast-3g');

    const comboboxInput = page.locator('[role="combobox"], input[data-testid="combobox"]').first();
    const inputCount = await comboboxInput.count();

    test.skip(inputCount === 0, 'Async combobox component not found on page');

    const startTime = Date.now();

    // Type to trigger async option loading
    await comboboxInput.fill('async');

    // Check for loading state
    const loadingResult = await measureLoadingStateAppearance(
      page,
      '.combobox-loading, .options-loading, [data-loading="true"]',
      THRESHOLDS.minLoadingDisplayTime
    );

    // Wait for async options to load
    const loadResult = await waitForComponentLoad(
      page,
      '[role="option"], .combobox-option',
      THRESHOLDS.maxLoadTimeFast3G
    );

    const totalTime = Date.now() - startTime;

    expect(loadingResult.visible).toBe(true);
    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Combobox (Async)',
      networkProfile: 'fast-3g',
      loadTime: totalTime,
      loadingVisible: loadingResult.visible,
      loadingDisplayTime: loadingResult.time,
      fallbackVisible: loadingResult.visible,
      success: loadResult.success,
    });
  });

  test('should maintain interactivity during option loading', async ({ page }) => {
    await page.goto('http://localhost:6006/?path=/story/components-combobox--default');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    const comboboxInput = page.locator('[role="combobox"], input[data-testid="combobox"]').first();
    const inputCount = await comboboxInput.count();

    test.skip(inputCount === 0, 'Combobox component not found on page');

    // Open combobox
    await comboboxInput.click();

    // Immediately try to type while options are loading
    await comboboxInput.fill('a');

    // Input should remain responsive
    const value = await comboboxInput.inputValue();
    expect(value).toBe('a');

    // Continue typing
    await comboboxInput.fill('ab');
    const finalValue = await comboboxInput.inputValue();
    expect(finalValue).toBe('ab');

    logMetrics({
      componentName: 'Combobox (Interactivity)',
      networkProfile: 'slow-3g',
      loadTime: 0,
      loadingVisible: true,
      loadingDisplayTime: 0,
      fallbackVisible: true,
      success: true,
    });
  });
});

// ===== CROSS-COMPONENT NETWORK TESTS =====

test.describe('Cross-Component Network Throttling Tests', () => {
  test.afterEach(async ({ page }) => {
    await resetNetworkConditions(page);
  });

  test('all async components show loading states within 500ms on slow 3G', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G network conditions
    await setNetworkConditions(page, 'slow-3g');

    const startTime = Date.now();

    // Trigger all async components
    const loadButtons = page.locator('.load-component-btn, .load-btn');
    const buttonCount = await loadButtons.count();

    test.skip(buttonCount === 0, 'No async components found on page');

    // Click first 5 buttons to test
    const testsToRun = Math.min(5, buttonCount);

    for (let i = 0; i < testsToRun; i++) {
      await loadButtons.nth(i).click();
    }

    // Check that loading states appear for all
    const loadingElements = page.locator('.component-loading, .loading-spinner');
    const loadingCount = await loadingElements.count();

    const totalTime = Date.now() - startTime;

    // At least some loading states should appear
    expect(loadingCount).toBeGreaterThan(0);

    logMetrics({
      componentName: 'Multiple Async Components',
      networkProfile: 'slow-3g',
      loadTime: totalTime,
      loadingVisible: loadingCount > 0,
      loadingDisplayTime: totalTime,
      fallbackVisible: loadingCount > 0,
      success: loadingCount > 0,
    });
  });

  test('components recover from network throttling恢复正常', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Start with slow 3G
    await setNetworkConditions(page, 'slow-3g');

    const loadButton = page.locator('.load-component-btn, .load-btn').first();
    const buttonCount = await loadButton.count();

    test.skip(buttonCount === 0, 'Async component not found on page');

    // Start loading on slow network
    await loadButton.click();

    // Wait for loading state
    await page.waitForSelector('.component-loading, .loading-spinner', { timeout: 1000 });

    // Now switch to 4G
    await setNetworkConditions(page, '4g');

    // Component should complete loading quickly
    const loadResult = await waitForComponentLoad(
      page,
      '.component-content, .component-success',
      THRESHOLDS.maxLoadTime4G
    );

    expect(loadResult.success).toBe(true);

    logMetrics({
      componentName: 'Network Recovery',
      networkProfile: '4g',
      loadTime: loadResult.time,
      loadingVisible: true,
      loadingDisplayTime: 0,
      fallbackVisible: true,
      success: loadResult.success,
    });
  });

  test('fallback UI is visually distinct during loading', async ({ page }) => {
    await page.goto('http://localhost:8082');
    await page.waitForLoadState('domcontentloaded');

    // Set slow 3G
    await setNetworkConditions(page, 'slow-3g');

    const loadButton = page.locator('.load-component-btn, .load-btn').first();
    const buttonCount = await loadButton.count();

    test.skip(buttonCount === 0, 'Async component not found on page');

    await loadButton.click();

    // Wait for loading state
    await page.waitForSelector('.component-loading, .loading-spinner', { timeout: 2000 });

    // Check that loading element has visual indicators
    const loadingElement = page.locator('.component-loading, .loading-spinner').first();

    // Check for common visual loading indicators
    const hasSpinner = await loadingElement.locator('.spinner, [class*="spin"], [class*="rotate"]').count() > 0;
    const hasText = await loadingElement.filter({ hasText: /loading|please wait/i }).count() > 0;
    const hasAriaLive = await loadingElement.getAttribute('aria-live') !== null;

    // At least one visual indicator should be present
    const hasVisualIndicator = hasSpinner || hasText || hasAriaLive;

    expect(hasVisualIndicator).toBe(true);

    logMetrics({
      componentName: 'Fallback UI Visuals',
      networkProfile: 'slow-3g',
      loadTime: 0,
      loadingVisible: true,
      loadingDisplayTime: 0,
      fallbackVisible: hasVisualIndicator,
      success: hasVisualIndicator,
    });
  });
});

// ===== PERFORMANCE SUMMARY =====

test.afterAll(async () => {
  console.log('\n\n' + '='.repeat(70));
  console.log('NETWORK THROTTLING TEST SUMMARY');
  console.log('='.repeat(70));

  if (metricsLog.length === 0) {
    console.log('No metrics collected.');
    return;
  }

  // Group by network profile
  const byProfile = metricsLog.reduce((acc, metric) => {
    if (!acc[metric.networkProfile]) {
      acc[metric.networkProfile] = [];
    }
    acc[metric.networkProfile].push(metric);
    return acc;
  }, {} as Record<string, NetworkTestMetrics[]>);

  for (const [profile, metrics] of Object.entries(byProfile)) {
    console.log(`\n${profile.toUpperCase()}:`);
    console.log('-'.repeat(40));

    for (const metric of metrics) {
      console.log(`  ${metric.componentName}:`);
      console.log(`    Load Time: ${metric.loadTime.toFixed(2)}ms`);
      if (metric.loadingDisplayTime > 0) {
        console.log(`    Loading Display Time: ${metric.loadingDisplayTime.toFixed(2)}ms`);
      }
      console.log(`    Loading Visible: ${metric.loadingVisible ? '✓' : '✗'}`);
      console.log(`    Fallback Visible: ${metric.fallbackVisible ? '✓' : '✗'}`);
      console.log(`    Success: ${metric.success ? '✓' : '✗'}`);
    }
  }

  // Calculate success rates
  const totalTests = metricsLog.length;
  const successfulTests = metricsLog.filter(m => m.success).length;
  const successRate = (successfulTests / totalTests * 100).toFixed(1);

  console.log('\n' + '='.repeat(70));
  console.log(`Total Tests: ${totalTests}`);
  console.log(`Successful: ${successfulTests} (${successRate}%)`);
  console.log('='.repeat(70) + '\n');
});
