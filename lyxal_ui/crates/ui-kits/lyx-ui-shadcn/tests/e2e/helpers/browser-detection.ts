import { Page } from '@playwright/test';

/**
 * Browser Detection and Compatibility Utilities
 *
 * Helper functions to detect browser-specific issues and
 * provide workarounds for cross-browser compatibility testing.
 */

export interface BrowserInfo {
  name: 'chromium' | 'firefox' | 'webkit' | 'edge';
  userAgent: string;
  version: string;
  isMobile: boolean;
  platform: string;
}

/**
 * Known browser-specific issues and their workarounds
 */
export const BROWSER_ISSUES = {
  firefox: {
    // Firefox has issues with some CSS backdrop-filter implementations
    backdropFilter: 'Firefox may have limited backdrop-filter support',
    // Firefox flexbox gap in older versions
    flexGap: 'Check flex gap rendering in Firefox < 81',
    // Firefox custom scrollbar styling
    customScrollbar: 'Firefox has limited custom scrollbar support',
  },
  webkit: {
    // Safari date input formatting
    dateInput: 'Safari shows native date picker differently',
    // Safari 100vh issue
    viewportHeight: 'Safari includes UI in viewport height',
    // Safari flexbox wrapping
    flexWrap: 'Check flex wrapping behavior on older Safari',
  },
  chromium: {
    // Chrome autofill styling
    autofill: 'Chrome applies yellow background to autofilled inputs',
  },
  edge: {
    // Edge-specific issues (should be minimal with Chromium-based Edge)
    legacy: 'Only testing Chromium-based Edge',
  },
};

/**
 * CSS feature support detection results
 */
export interface CSSFeatureSupport {
  cssVariables: boolean;
  flexbox: boolean;
  grid: boolean;
  customProperties: boolean;
  backdropFilter: boolean;
  containerQueries: boolean;
  hasSelector: boolean;
  gapProperty: boolean;
  aspectRatio: boolean;
}

/**
 * Get detailed browser information
 */
export async function getBrowserInfo(page: Page): Promise<BrowserInfo> {
  const info = await page.evaluate(() => {
    const ua = navigator.userAgent;
    return {
      userAgent: ua,
      version: navigator.appVersion,
      platform: navigator.platform,
      isMobile: /iPhone|iPad|iPod|Android/i.test(ua),
    };
  });

  // Detect browser type from Playwright context
  const browser = (page.context().browser()?.browserType()?.name() ||
    detectBrowserFromUA(info.userAgent)) as BrowserInfo['name'];

  return {
    ...info,
    name: browser,
  };
}

/**
 * Detect browser type from user agent string
 */
function detectBrowserFromUA(userAgent: string): BrowserInfo['name'] {
  if (userAgent.includes('Edg/')) {
    return 'edge';
  }
  if (userAgent.includes('Chrome/') && !userAgent.includes('Edg/')) {
    return 'chromium';
  }
  if (userAgent.includes('Firefox/')) {
    return 'firefox';
  }
  if (userAgent.includes('Safari/') && !userAgent.includes('Chrome/')) {
    return 'webkit';
  }
  return 'chromium'; // Default fallback
}

/**
 * Detect CSS feature support in the current browser
 */
export async function detectCSSFeatures(page: Page): Promise<CSSFeatureSupport> {
  return await page.evaluate(() => {
    return {
      cssVariables: CSS.supports('--test', 'red'),
      flexbox: CSS.supports('display', 'flex'),
      grid: CSS.supports('display', 'grid'),
      customProperties: CSS.supports('--custom-property', 'value'),
      backdropFilter: CSS.supports('backdrop-filter', 'blur(10px)'),
      containerQueries: CSS.supports('container-type', 'inline-size'),
      hasSelector: CSS.supports('selector(:has(div))'),
      gapProperty: CSS.supports('gap', '10px'),
      aspectRatio: CSS.supports('aspect-ratio', '1 / 1'),
    };
  });
}

/**
 * Get browser-specific issues for the current browser
 */
export function getBrowserIssues(browser: BrowserInfo['name']): string[] {
  const issues = BROWSER_ISSUES[browser];
  return issues ? Object.entries(issues).map(([_, description]) => description) : [];
}

/**
 * Check if browser has a specific issue
 */
export function hasBrowserIssue(browser: BrowserInfo['name'], issue: keyof typeof BROWSER_ISSUES.chromium): boolean {
  return BROWSER_ISSUES[browser]?.hasOwnProperty(issue) || false;
}

/**
 * Browser-specific test timeout adjustments
 */
export function getBrowserTimeout(browser: BrowserInfo['name']): number {
  const timeouts: Record<BrowserInfo['name'], number> = {
    firefox: 35000, // Firefox can be slower
    webkit: 40000, // WebKit is often slowest
    chromium: 30000,
    edge: 30000,
  };
  return timeouts[browser] || 30000;
}

/**
 * Browser-specific viewport adjustments
 */
export function getBrowserViewport(browser: BrowserInfo['name'], baseViewport: { width: number; height: number }) {
  // Safari has unique viewport behavior due to URL bar
  if (browser === 'webkit') {
    return {
      ...baseViewport,
      // Adjust for Safari's URL bar
      height: baseViewport.height - 100,
    };
  }
  return baseViewport;
}

/**
 * Check if browser is a mobile variant
 */
export async function isMobileBrowser(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    return /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
  });
}

/**
 * Get all known browser-specific workarounds
 */
export function getBrowserWorkarounds(browser: BrowserInfo['name']): Record<string, any> {
  const workarounds: Record<BrowserInfo['name'], Record<string, any>> = {
    firefox: {
      // Wait longer for animations
      animationWait: 200,
      // Specific selectors for Firefox
      focusSelector: ':focus-visible',
      // Skip backdrop-filter tests in Firefox
      skipBackdropFilter: true,
    },
    webkit: {
      // Use dvh instead of vh
      viewportUnit: 'dvh',
      // Wait for Safari's 300ms click delay
      clickDelay: 350,
      // Skip :has() selector tests on older Safari
      skipHasSelector: true,
    },
    chromium: {
      // Standard timing
      animationWait: 100,
      // No specific workarounds needed
    },
    edge: {
      // Edge follows Chromium behavior
      animationWait: 100,
    },
  };

  return workarounds[browser] || workarounds.chromium;
}

/**
 * Apply browser-specific workarounds to page
 */
export async function applyBrowserWorkarounds(page: Page, browser: BrowserInfo['name']): Promise<void> {
  const workarounds = getBrowserWorkarounds(browser);

  // Apply browser-specific CSS fixes via injected styles
  await page.addInitScript((fixes) => {
    const style = document.createElement('style');
    style.id = 'browser-compatibility-fixes';
    style.textContent = fixes;
    document.head.appendChild(style);
  }, generateBrowserCSSFixes(browser, workarounds));
}

/**
 * Generate browser-specific CSS fixes
 */
function generateBrowserCSSFixes(browser: BrowserInfo['name'], workarounds: Record<string, any>): string {
  const fixes: string[] = [];

  if (browser === 'webkit') {
    fixes.push(`
      /* Safari viewport height fix */
      :root {
        --vh: 1vh;
      }
      @supports (height: 100dvh) {
        :root {
          --vh: 1dvh;
        }
      }
    `);
  }

  if (browser === 'firefox') {
    fixes.push(`
      /* Firefox scrollbar fix */
      * {
        scrollbar-width: auto;
      }
    `);
  }

  return fixes.join('\n');
}

/**
 * Create a cross-browser test annotation
 */
export function createBrowserAnnotation(browser: BrowserInfo['name'], testInfo: any): void {
  testInfo.annotations.push({
    type: 'browser',
    description: browser,
  });

  // Add known issues as annotations
  const issues = getBrowserIssues(browser);
  if (issues.length > 0) {
    testInfo.annotations.push({
      type: 'known-issues',
      description: issues.join('; '),
    });
  }
}

/**
 * Screenshot options for browser-specific differences
 */
export function getScreenshotOptions(browser: BrowserInfo['name']) {
  return {
    fullPage: true,
    animations: 'allowed',
    // WebKit needs more time for animations to complete
    ...(browser === 'webkit' ? { delay: 500 } : {}),
  };
}

/**
 * Compare browser compatibility matrix
 */
export const BROWSER_COMPATIBILITY_MATRIX = {
  // CSS Grid - fully supported in all modern browsers
  grid: { chromium: true, firefox: true, webkit: true, edge: true },
  // CSS Flexbox - fully supported
  flexbox: { chromium: true, firefox: true, webkit: true, edge: true },
  // CSS Variables - fully supported
  cssVariables: { chromium: true, firefox: true, webkit: true, edge: true },
  // Container Queries - newer feature, check support
  containerQueries: { chromium: true, firefox: false, webkit: true, edge: true },
  // :has() selector - newer feature
  hasSelector: { chromium: true, firefox: false, webkit: true, edge: true },
  // backdrop-filter - partial support
  backdropFilter: { chromium: true, firefox: false, webkit: true, edge: true },
  // aspect-ratio - newer feature
  aspectRatio: { chromium: true, firefox: true, webkit: true, edge: true },
};

/**
 * Check if feature is supported in browser
 */
export function isFeatureSupported(feature: keyof typeof BROWSER_COMPATIBILITY_MATRIX, browser: BrowserInfo['name']): boolean {
  return BROWSER_COMPATIBILITY_MATRIX[feature]?.[browser] ?? false;
}

/**
 * Get unsupported features for browser
 */
export function getUnsupportedFeatures(browser: BrowserInfo['name']): string[] {
  const unsupported: string[] = [];

  for (const [feature, support] of Object.entries(BROWSER_COMPATIBILITY_MATRIX)) {
    if (!support[browser as keyof typeof support]) {
      unsupported.push(feature);
    }
  }

  return unsupported;
}
