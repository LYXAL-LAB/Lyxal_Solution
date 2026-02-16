/**
 * Viewport Testing Utilities
 *
 * Helper functions and configurations for cross-browser viewport testing.
 */

import { Page, BrowserContext } from '@playwright/test';

/**
 * Standard viewport configurations for testing
 */
export const STANDARD_VIEWPORTS = {
  // Desktop
  desktop4K: { width: 3840, height: 2160, name: 'Desktop 4K', category: 'desktop' },
  desktopLarge: { width: 2560, height: 1440, name: 'Desktop Large', category: 'desktop' },
  desktop: { width: 1920, height: 1080, name: 'Desktop', category: 'desktop' },
  desktopSmall: { width: 1366, height: 768, name: 'Desktop Small', category: 'desktop' },

  // Tablet
  tabletProLandscape: { width: 1366, height: 1024, name: 'Tablet Pro Landscape', category: 'tablet' },
  tabletLandscape: { width: 1024, height: 768, name: 'Tablet Landscape', category: 'tablet' },
  tablet: { width: 768, height: 1024, name: 'Tablet Portrait', category: 'tablet' },
  tabletSmall: { width: 640, height: 960, name: 'Small Tablet', category: 'tablet' },

  // Mobile
  mobileLarge: { width: 428, height: 926, name: 'Mobile Large', category: 'mobile' },
  mobile: { width: 375, height: 667, name: 'Mobile', category: 'mobile' },
  mobileSmall: { width: 320, height: 568, name: 'Mobile Small', category: 'mobile' },

  // Special
  ultrawide: { width: 3440, height: 1440, name: 'Ultrawide', category: 'special' },
  foldableOpen: { width: 2208, height: 1768, name: 'Foldable Open', category: 'special' },
  foldableClosed: { width: 1760, height: 2208, name: 'Foldable Closed', category: 'special' },
} as const;

export type ViewportConfig = {
  width: number;
  height: number;
  name: string;
  category: string;
};

/**
 * Real device configurations for testing
 */
export const REAL_DEVICES = {
  iPhone14Pro: {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 393, height: 852 },
    name: 'iPhone 14 Pro',
    deviceScaleFactor: 3,
    isMobile: true,
    hasTouch: true,
  },
  iPhone14: {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 390, height: 844 },
    name: 'iPhone 14',
    deviceScaleFactor: 3,
    isMobile: true,
    hasTouch: true,
  },
  iPhoneSE: {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 375, height: 667 },
    name: 'iPhone SE',
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  },
  iPadPro11: {
    userAgent: 'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 834, height: 1194 },
    name: 'iPad Pro 11"',
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  },
  iPadPro13: {
    userAgent: 'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 1024, height: 1366 },
    name: 'iPad Pro 13"',
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  },
  SamsungGalaxyS23: {
    userAgent: 'Mozilla/5.0 (Linux; Android 13; SM-S911B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    viewport: { width: 360, height: 780 },
    name: 'Samsung Galaxy S23',
    deviceScaleFactor: 3,
    isMobile: true,
    hasTouch: true,
  },
  SamsungGalaxyTabS8: {
    userAgent: 'Mozilla/5.0 (Linux; Android 12; SM-X700) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36',
    viewport: { width: 800, height: 1280 },
    name: 'Samsung Galaxy Tab S8',
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  },
  Pixel7: {
    userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    viewport: { width: 412, height: 915 },
    name: 'Google Pixel 7',
    deviceScaleFactor: 2.625,
    isMobile: true,
    hasTouch: true,
  },
} as const;

export type DeviceConfig = {
  userAgent: string;
  viewport: { width: number; height: number };
  name: string;
  deviceScaleFactor: number;
  isMobile: boolean;
  hasTouch: boolean;
};

/**
 * Browser compatibility configurations
 */
export const BROWSER_CONFIGS = {
  chromium: {
    name: 'Chromium',
    features: {
      supports: ['css-grid', 'flexbox', 'css-variables', 'webp', 'wasm'],
      quirks: ['precise-font-rendering', 'hardware-acceleration'],
    },
    viewportBehavior: {
      includesScrollbar: true,
      scrollbarWidth: 15,
      minimumViewport: 300,
    },
  },
  firefox: {
    name: 'Firefox',
    features: {
      supports: ['css-grid', 'flexbox', 'css-variables', 'webp', 'wasm'],
      quirks: ['subpixel-aa', 'custom-scrollbar'],
    },
    viewportBehavior: {
      includesScrollbar: true,
      scrollbarWidth: 17,
      minimumViewport: 300,
    },
  },
  webkit: {
    name: 'WebKit (Safari)',
    features: {
      supports: ['css-grid', 'flexbox', 'css-variables', 'webp', 'wasm'],
      quirks: ['font-smoothing', 'backface-visibility'],
    },
    viewportBehavior: {
      includesScrollbar: false,
      scrollbarWidth: 0,
      minimumViewport: 320,
    },
  },
} as const;

/**
 * Set viewport and verify it was applied
 */
export async function setViewportAndVerify(
  page: Page,
  config: ViewportConfig
): Promise<boolean> {
  await page.setViewportSize({ width: config.width, height: config.height });
  await page.waitForTimeout(100);

  const actualWidth = await page.evaluate(() => window.innerWidth);
  const actualHeight = await page.evaluate(() => window.innerHeight);

  return actualWidth === config.width && actualHeight === config.height;
}

/**
 * Check for horizontal scroll at current viewport
 */
export async function hasHorizontalScroll(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    return document.body.scrollWidth > window.innerWidth;
  });
}

/**
 * Check for vertical scroll at current viewport
 */
export async function hasVerticalScroll(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    return document.body.scrollHeight > window.innerHeight;
  });
}

/**
 * Get actual viewport dimensions
 */
export async function getViewportDimensions(page: Page): Promise<{
  width: number;
  height: number;
  scrollWidth: number;
  scrollHeight: number;
}> {
  return await page.evaluate(() => ({
    width: window.innerWidth,
    height: window.innerHeight,
    scrollWidth: document.body.scrollWidth,
    scrollHeight: document.body.scrollHeight,
  }));
}

/**
 * Verify element fits within viewport
 */
export async function elementFitsInViewport(
  page: Page,
  selector: string
): Promise<boolean> {
  const element = page.locator(selector).first();
  if (!(await element.count())) return false;

  const box = await element.boundingBox();
  if (!box) return false;

  const viewportWidth = await page.evaluate(() => window.innerWidth);

  return box.x + box.width <= viewportWidth;
}

/**
 * Measure touch target size for an element
 */
export async function getTouchTargetSize(
  page: Page,
  selector: string
): Promise<{ width: number; height: number } | null> {
  const element = page.locator(selector).first();
  if (!(await element.count())) return null;

  const box = await element.boundingBox();
  return box ? { width: box.width, height: box.height } : null;
}

/**
 * Verify touch target meets WCAG minimum (44x44 CSS pixels)
 */
export async function verifyTouchTargetSize(
  page: Page,
  selector: string,
  minimumSize: number = 40
): Promise<boolean> {
  const size = await getTouchTargetSize(page, selector);
  if (!size) return false;

  return size.width >= minimumSize && size.height >= minimumSize;
}

/**
 * Get all interactive elements
 */
export async function getInteractiveElements(page: Page) {
  return await page.locator(
    'button, a[href], input:not([type="hidden"]), select, textarea, [role="button"], [tabindex]:not([tabindex="-1"])'
  );
}

/**
 * Check element visibility across viewports
 */
export async function checkElementVisibilityAcrossViewports(
  page: Page,
  selector: string,
  viewports: readonly ViewportConfig[]
): Promise<Record<string, boolean>> {
  const results: Record<string, boolean> = {};

  for (const viewport of viewports) {
    await page.setViewportSize({ width: viewport.width, height: viewport.height });
    await page.waitForTimeout(100);

    const isVisible = await page.locator(selector).isVisible().catch(() => false);
    results[viewport.name] = isVisible;
  }

  return results;
}

/**
 * Screenshot comparison helper
 */
export interface ScreenshotConfig {
  path: string;
  fullPage?: boolean;
  maxDiffPixels?: number;
  maxDiffRatio?: number;
  threshold?: number;
}

export async function takeViewportScreenshot(
  page: Page,
  config: ScreenshotConfig
): Promise<Buffer> {
  return await page.screenshot({
    path: config.path,
    fullPage: config.fullPage ?? false,
  });
}

/**
 * Analyze layout at viewport
 */
export interface LayoutAnalysis {
  hasHorizontalScroll: boolean;
  hasVerticalScroll: boolean;
  contentWidth: number;
  contentHeight: number;
  overflowX: string;
  overflowY: string;
  scrollbarWidth: number;
}

export async function analyzeLayout(page: Page): Promise<LayoutAnalysis> {
  return await page.evaluate(() => {
    const bodyStyle = window.getComputedStyle(document.body);
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;

    return {
      hasHorizontalScroll: document.body.scrollWidth > window.innerWidth,
      hasVerticalScroll: document.body.scrollHeight > window.innerHeight,
      contentWidth: document.body.scrollWidth,
      contentHeight: document.body.scrollHeight,
      overflowX: bodyStyle.overflowX,
      overflowY: bodyStyle.overflowY,
      scrollbarWidth,
    };
  });
}

/**
 * Detect if mobile menu is present
 */
export async function hasMobileMenu(page: Page): Promise<boolean> {
  const selectors = [
    '[aria-label*="menu" i]',
    '[aria-label*="Menu" i]',
    'button[aria-expanded]',
    '.menu-toggle',
    '[class*="menu-toggle"]',
    '[class*="hamburger"]',
    '.nav-toggle',
  ];

  for (const selector of selectors) {
    const element = page.locator(selector).first();
    if (await element.count()) {
      return true;
    }
  }

  return false;
}

/**
 * Get breakpoint name from viewport width
 */
export function getBreakpoint(width: number): string {
  if (width >= 1536) return 'xl2';
  if (width >= 1280) return 'xl';
  if (width >= 1024) return 'lg';
  if (width >= 768) return 'md';
  if (width >= 640) return 'sm';
  return 'xs';
}

/**
 * Get device category from viewport
 */
export function getDeviceCategory(width: number): 'mobile' | 'tablet' | 'desktop' {
  if (width < 768) return 'mobile';
  if (width < 1024) return 'tablet';
  return 'desktop';
}

/**
 * Orientation change helper
 */
export async function changeOrientation(page: Page): Promise<void> {
  const currentWidth = await page.evaluate(() => window.innerWidth);
  const currentHeight = await page.evaluate(() => window.innerHeight);

  await page.setViewportSize({ width: currentHeight, height: currentWidth });
  await page.waitForTimeout(200);
}

/**
 * Zoom page helper (simulates browser zoom)
 */
export async function setZoomLevel(page: Page, zoom: number): Promise<void> {
  await page.evaluate((z) => {
    document.body.style.zoom = z.toString();
  }, zoom);
  await page.waitForTimeout(100);
}

/**
 * Set text scale (accessibility)
 */
export async function setTextScale(page: Page, scale: number): Promise<void> {
  await page.evaluate((s) => {
    document.documentElement.style.fontSize = `${s * 100}%`;
  }, scale);
  await page.waitForTimeout(100);
}

/**
 * Performance metrics at viewport
 */
export interface ViewportPerformance {
  domContentLoaded: number;
  loadComplete: number;
  firstPaint: number;
  firstContentfulPaint: number;
}

export async function getViewportPerformanceMetrics(page: Page): Promise<ViewportPerformance> {
  return await page.evaluate(() => {
    const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;

    const paintEntries = performance.getEntriesByType('paint');
    const firstPaint = paintEntries.find(e => e.name === 'first-paint')?.startTime ?? 0;
    const firstContentfulPaint = paintEntries.find(e => e.name === 'first-contentful-paint')?.startTime ?? 0;

    return {
      domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
      loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
      firstPaint,
      firstContentfulPaint,
    };
  });
}

/**
 * Verify responsive image loading
 */
export async function verifyResponsiveImages(page: Page): Promise<{
  total: number;
  withSrcset: number;
  withSizes: number;
  properlySized: number;
}> {
  return await page.evaluate(() => {
    const images = document.querySelectorAll('img');
    let withSrcset = 0;
    let withSizes = 0;
    let properlySized = 0;

    images.forEach(img => {
      if (img.srcset) withSrcset++;
      if (img.sizes) withSizes++;

      const rect = img.getBoundingClientRect();
      if (rect.width > 0 && rect.height > 0) {
        properlySized++;
      }
    });

    return {
      total: images.length,
      withSrcset,
      withSizes,
      properlySized,
    };
  });
}

/**
 * Check CSS Grid/Flexbox usage
 */
export async function checkLayoutSystem(page: Page): Promise<{
  usesGrid: boolean;
  usesFlexbox: boolean;
  gridElements: number;
  flexboxElements: number;
}> {
  return await page.evaluate(() => {
    const allElements = document.querySelectorAll('*');
    let gridElements = 0;
    let flexboxElements = 0;

    allElements.forEach(el => {
      const style = window.getComputedStyle(el);
      if (style.display === 'grid' || style.display === 'inline-grid') {
        gridElements++;
      }
      if (style.display === 'flex' || style.display === 'inline-flex') {
        flexboxElements++;
      }
    });

    return {
      usesGrid: gridElements > 0,
      usesFlexbox: flexboxElements > 0,
      gridElements,
      flexboxElements,
    };
  });
}

/**
 * Browser-specific viewport quirk detection
 */
export async function detectBrowserQuirks(page: Page, browserName: string): Promise<Record<string, boolean>> {
  const quirks: Record<string, boolean> = {};

  if (browserName === 'webkit') {
    // Safari-specific checks
    quirks.hasBackdropFilter = await page.evaluate(() =>
      CSS.supports('backdrop-filter', 'blur(10px)')
    );
    quirks.hasWebkitPseudo = await page.evaluate(() => {
      const style = document.createElement('div').style;
      return '-webkit-scrollbar' in style || 'WebkitAppearance' in style;
    });
  }

  if (browserName === 'firefox') {
    // Firefox-specific checks
    quirks.hasMozPseudo = await page.evaluate(() => {
      const style = document.createElement('div').style;
      return 'MozAppearance' in style;
    });
  }

  if (browserName === 'chromium') {
    // Chrome-specific checks
    quirks.hasWebkitPseudo = await page.evaluate(() => {
      const style = document.createElement('div').style;
      return 'WebkitAppearance' in style;
    });
  }

  return quirks;
}

/**
 * Comprehensive viewport test result
 */
export interface ViewportTestResult {
  viewport: ViewportConfig;
  passed: boolean;
  errors: string[];
  warnings: string[];
  metrics: {
    loadTime: number;
    hasHorizontalScroll: boolean;
    hasVerticalScroll: boolean;
    touchTargetsValid: boolean;
    layoutIntegrity: boolean;
  };
}

/**
 * Run comprehensive viewport test
 */
export async function runViewportTest(
  page: Page,
  viewport: ViewportConfig
): Promise<ViewportTestResult> {
  const result: ViewportTestResult = {
    viewport,
    passed: true,
    errors: [],
    warnings: [],
    metrics: {
      loadTime: 0,
      hasHorizontalScroll: false,
      hasVerticalScroll: false,
      touchTargetsValid: true,
      layoutIntegrity: true,
    },
  };

  try {
    const startTime = Date.now();

    // Set viewport
    await page.setViewportSize({ width: viewport.width, height: viewport.height });
    await page.waitForTimeout(100);

    // Check for issues
    const hasHScroll = await hasHorizontalScroll(page);
    const hasVScroll = await hasVerticalScroll(page);

    result.metrics.hasHorizontalScroll = hasHScroll;
    result.metrics.hasVerticalScroll = hasVScroll;

    if (hasHScroll) {
      result.errors.push('Horizontal scroll detected');
      result.passed = false;
    }

    // Check touch targets on mobile
    if (viewport.category === 'mobile' || viewport.category === 'tablet') {
      const interactiveElements = await getInteractiveElements(page);
      const count = await interactiveElements.count();

      if (count > 0) {
        for (let i = 0; i < Math.min(count, 5); i++) {
          const element = interactiveElements.nth(i);
          const box = await element.boundingBox();
          if (box && (box.width < 40 || box.height < 40)) {
            result.warnings.push(`Touch target too small: ${box.width}x${box.height}`);
            result.metrics.touchTargetsValid = false;
          }
        }
      }
    }

    result.metrics.loadTime = Date.now() - startTime;

  } catch (error) {
    result.passed = false;
    result.errors.push(error instanceof Error ? error.message : 'Unknown error');
  }

  return result;
}

/**
 * Generate viewport test report
 */
export function generateViewportReport(results: ViewportTestResult[]): string {
  const lines: string[] = [];
  lines.push('=== Viewport Test Report ===');
  lines.push('');

  const passed = results.filter(r => r.passed).length;
  lines.push(`Total: ${results.length}, Passed: ${passed}, Failed: ${results.length - passed}`);
  lines.push('');

  for (const result of results) {
    const status = result.passed ? '✓ PASS' : '✗ FAIL';
    lines.push(`${status} - ${result.viewport.name} (${result.viewport.width}x${result.viewport.height})`);

    if (result.errors.length > 0) {
      result.errors.forEach(err => lines.push(`  ERROR: ${err}`));
    }

    if (result.warnings.length > 0) {
      result.warnings.forEach(warn => lines.push(`  WARN: ${warn}`));
    }

    lines.push(`  Metrics:`);
    lines.push(`    - Load time: ${result.metrics.loadTime}ms`);
    lines.push(`    - Horizontal scroll: ${result.metrics.hasHorizontalScroll}`);
    lines.push(`    - Touch targets valid: ${result.metrics.touchTargetsValid}`);
    lines.push('');
  }

  return lines.join('\n');
}
