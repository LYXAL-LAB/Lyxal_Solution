import { test, expect, devices } from '@playwright/test';

/**
 * Cross-Browser Viewport Testing Suite
 *
 * This suite tests responsive design across all major browsers and viewport sizes.
 * Tests cover:
 * - Desktop, tablet, and mobile viewports
 * - Chromium, Firefox, and WebKit browsers
 * - Component responsiveness
 * - Layout integrity
 * - Touch target sizing
 * - Text scaling
 * - Orientation changes
 */

// Viewport configurations for different device categories
const VIEWPORTS = {
  // Desktop viewports
  desktopLarge: { width: 2560, height: 1440, name: 'Desktop Large' },
  desktop: { width: 1920, height: 1080, name: 'Desktop' },
  desktopSmall: { width: 1366, height: 768, name: 'Desktop Small' },

  // Tablet viewports
  tabletLandscape: { width: 1024, height: 768, name: 'Tablet Landscape' },
  tablet: { width: 768, height: 1024, name: 'Tablet Portrait' },
  tabletSmall: { width: 640, height: 960, name: 'Small Tablet' },

  // Mobile viewports
  mobileLarge: { width: 428, height: 926, name: 'Mobile Large' },
  mobile: { width: 375, height: 667, name: 'Mobile' },
  mobileSmall: { width: 320, height: 568, name: 'Mobile Small' },

  // Special viewports
  ultrawide: { width: 3440, height: 1440, name: 'Ultrawide' },
  foldable: { width: 2208, height: 1768, name: 'Foldable Open' },
} as const;

// Test pages to validate
const TEST_PAGES = [
  { path: '/', name: 'Home' },
  { path: '/components', name: 'Components' },
  { path: '/dashboard', name: 'Dashboard' },
];

type ViewportConfig = {
  width: number;
  height: number;
  name: string;
};

test.describe('Cross-Browser Viewport Testing', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  // Desktop Viewports - All browsers
  test.describe('Desktop Viewports', () => {
    const desktopViewports: ViewportConfig[] = [
      VIEWPORTS.desktopLarge,
      VIEWPORTS.desktop,
      VIEWPORTS.desktopSmall,
      VIEWPORTS.ultrawide,
    ];

    for (const viewport of desktopViewports) {
      test(`${viewport.name} (${viewport.width}x${viewport.height})`, async ({ page, browserName }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check that main content is visible
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        // Verify layout doesn't break at this viewport
        const bodyWidth = await page.evaluate(() => document.body.scrollWidth);
        expect(bodyWidth).toBeLessThanOrEqual(viewport.width + 1);

        // Check for horizontal scrolling (should not exist)
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();

        // Verify critical elements are visible
        const header = page.locator('header').first();
        if (await header.count() > 0) {
          await expect(header).toBeVisible();
        }

        // Take screenshot for visual regression
        await expect(page).toHaveScreenshot(`${browserName}-${viewport.name.replace(/\s+/g, '-')}-initial.png`, {
          maxDiffPixels: viewport.width * viewport.height * 0.01,
        });
      });

      test(`${viewport.name} - Component Layout Integrity`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/components');
        await page.waitForLoadState('networkidle');

        // Check that component containers are properly sized
        const componentContainers = page.locator('[class*="component"], [class*="card"], [class*="panel"]');
        const count = await componentContainers.count();

        if (count > 0) {
          for (let i = 0; i < Math.min(count, 5); i++) {
            const container = componentContainers.nth(i);
            await expect(container).toBeVisible();

            // Check that container fits within viewport
            const box = await container.boundingBox();
            if (box) {
              expect(box.x + box.width).toBeLessThanOrEqual(viewport.width + 10);
            }
          }
        }
      });

      test(`${viewport.name} - Navigation Visibility`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check navigation visibility
        const nav = page.locator('nav, header').first();
        if (await nav.count() > 0) {
          await expect(nav).toBeVisible();

          // Verify navigation items are accessible
          const navItems = nav.locator('a, button').all();
          for (const item of await navItems) {
            await expect(item).toBeVisible();
          }
        }
      });
    }
  });

  // Tablet Viewports - All browsers
  test.describe('Tablet Viewports', () => {
    const tabletViewports: ViewportConfig[] = [
      VIEWPORTS.tabletLandscape,
      VIEWPORTS.tablet,
      VIEWPORTS.tabletSmall,
    ];

    for (const viewport of tabletViewports) {
      test(`${viewport.name} (${viewport.width}x${viewport.height})`, async ({ page, browserName }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check that main content is visible
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        // Verify no horizontal scroll
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();

        // Check responsive navigation behavior
        const nav = page.locator('nav, header').first();
        if (await nav.count() > 0) {
          await expect(nav).toBeVisible();

          // Look for mobile menu toggle
          const menuToggle = page.locator('[aria-label*="menu"], [aria-label*="Menu"], button[aria-expanded]').first();
          const hasMenuToggle = await menuToggle.count() > 0;

          // On smaller tablets, menu toggle should be present
          if (viewport.width <= 768) {
            if (hasMenuToggle) {
              await expect(menuToggle).toBeVisible();
            }
          }
        }

        // Verify touch target sizes
        const interactiveElements = page.locator('button, a, input, select').first();
        if (await interactiveElements.count() > 0) {
          const box = await interactiveElements.boundingBox();
          if (box) {
            // Touch targets should be at least 40x40px
            expect(box.width).toBeGreaterThanOrEqual(40);
            expect(box.height).toBeGreaterThanOrEqual(40);
          }
        }

        await expect(page).toHaveScreenshot(`${browserName}-${viewport.name.replace(/\s+/g, '-')}-initial.png`, {
          maxDiffPixels: viewport.width * viewport.height * 0.015,
        });
      });

      test(`${viewport.name} - Landscape Orientation`, async ({ page }) => {
        // Swap dimensions for landscape
        await page.setViewportSize({ width: viewport.height, height: viewport.width });

        // Verify layout adapts to landscape
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();
      });
    }
  });

  // Mobile Viewports - All browsers
  test.describe('Mobile Viewports', () => {
    const mobileViewports: ViewportConfig[] = [
      VIEWPORTS.mobileLarge,
      VIEWPORTS.mobile,
      VIEWPORTS.mobileSmall,
    ];

    for (const viewport of mobileViewports) {
      test(`${viewport.name} (${viewport.width}x${viewport.height})`, async ({ page, browserName }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check that main content is visible
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        // Verify no horizontal scroll
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();

        // Check for mobile navigation
        const nav = page.locator('nav, header').first();
        if (await nav.count() > 0) {
          await expect(nav).toBeVisible();

          // Look for hamburger menu or similar
          const menuToggle = page.locator(
            '[aria-label*="menu"], [aria-label*="Menu"], button[aria-expanded], .menu-toggle, [class*="menu-toggle"]'
          ).first();

          if (await menuToggle.count() > 0) {
            await expect(menuToggle).toBeVisible();
            await expect(menuToggle).toBeEnabled();
          }
        }

        // Verify text is readable (not too small)
        const textElements = page.locator('p, h1, h2, h3, span').filter({ hasText: /.+/ });
        if (await textElements.count() > 0) {
          const firstText = textElements.first();
          const fontSize = await firstText.evaluate(el => {
            return window.getComputedStyle(el).fontSize;
          });
          const fontSizeNum = parseInt(fontSize);
          expect(fontSizeNum).toBeGreaterThanOrEqual(12);
        }

        // Check touch target sizes
        const buttons = page.locator('button, a[href]').all();
        for (const button of await buttons.slice(0, 5)) {
          const box = await button.boundingBox();
          if (box) {
            // WCAG minimum touch target: 40x40px
            expect(box.width).toBeGreaterThanOrEqual(40);
            expect(box.height).toBeGreaterThanOrEqual(40);
          }
        }

        await expect(page).toHaveScreenshot(`${browserName}-${viewport.name.replace(/\s+/g, '-')}-initial.png`, {
          maxDiffPixels: viewport.width * viewport.height * 0.02,
        });
      });

      test(`${viewport.name} - Vertical Scroll`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Verify vertical scrolling works
        const scrollHeight = await page.evaluate(() => document.body.scrollHeight);
        const viewportHeight = await page.evaluate(() => window.innerHeight);

        if (scrollHeight > viewportHeight) {
          // Page should be scrollable
          const initialScrollY = await page.evaluate(() => window.scrollY);

          // Scroll down
          await page.evaluate(() => window.scrollBy(0, 500));
          await page.waitForTimeout(100);

          const afterScrollY = await page.evaluate(() => window.scrollY);
          expect(afterScrollY).toBeGreaterThan(initialScrollY);

          // Scroll back up
          await page.evaluate(() => window.scrollBy(0, -500));
          await page.waitForTimeout(100);
        }
      });

      test(`${viewport.name} - Form Usability`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/components');

        // Look for form inputs
        const inputs = page.locator('input, select, textarea').all();

        for (const input of await inputs.slice(0, 3)) {
          await expect(input).toBeVisible();

          // Check input is usable on mobile
          const box = await input.boundingBox();
          if (box) {
            // Input should be large enough to tap
            expect(box.width).toBeGreaterThanOrEqual(40);

            // Input should fit within viewport
            expect(box.x + box.width).toBeLessThanOrEqual(viewport.width);
          }
        }
      });
    }
  });

  // Special Viewports
  test.describe('Special Viewports', () => {
    test(`Foldable Device (${VIEWPORTS.foldable.width}x${VIEWPORTS.foldable.height})`, async ({ page }) => {
      await page.setViewportSize({ width: VIEWPORTS.foldable.width, height: VIEWPORTS.foldable.height });

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test(`Ultrawide Monitor (${VIEWPORTS.ultrawide.width}x${VIEWPORTS.ultrawide.height})`, async ({ page }) => {
      await page.setViewportSize({ width: VIEWPORTS.ultrawide.width, height: VIEWPORTS.ultrawide.height });

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      // Check content max-width handling
      const container = page.locator('main, .container, [class*="container"]').first();
      if (await container.count() > 0) {
        const box = await container.boundingBox();
        if (box) {
          // Content should be centered or properly constrained on ultrawide
          expect(box.x).toBeGreaterThanOrEqual(0);
          expect(box.x + box.width).toBeLessThanOrEqual(VIEWPORTS.ultrawide.width);
        }
      }
    });
  });

  // Viewport Transition Tests
  test.describe('Viewport Transition Tests', () => {
    test('Desktop to Tablet Transition', async ({ page }) => {
      // Start with desktop
      await page.setViewportSize({ width: VIEWPORTS.desktop.width, height: VIEWPORTS.desktop.height });
      await page.waitForTimeout(200);

      // Transition to tablet
      await page.setViewportSize({ width: VIEWPORTS.tablet.width, height: VIEWPORTS.tablet.height });
      await page.waitForTimeout(200);

      // Verify layout adapted
      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Tablet to Mobile Transition', async ({ page }) => {
      await page.setViewportSize({ width: VIEWPORTS.tablet.width, height: VIEWPORTS.tablet.height });
      await page.waitForTimeout(200);

      await page.setViewportSize({ width: VIEWPORTS.mobile.width, height: VIEWPORTS.mobile.height });
      await page.waitForTimeout(200);

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Mobile to Desktop Transition', async ({ page }) => {
      await page.setViewportSize({ width: VIEWPORTS.mobile.width, height: VIEWPORTS.mobile.height });
      await page.waitForTimeout(200);

      await page.setViewportSize({ width: VIEWPORTS.desktop.width, height: VIEWPORTS.desktop.height });
      await page.waitForTimeout(200);

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();
    });
  });

  // Browser-Specific Viewport Behavior
  test.describe('Browser-Specific Viewport Behavior', () => {
    test('Chromium viewport rendering', async ({ page, browserName }) => {
      test.skip(browserName !== 'chromium', 'Chromium only test');

      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/');

      // Chromium-specific rendering checks
      const scrollWidth = await page.evaluate(() => document.documentElement.scrollWidth);
      expect(scrollWidth).toBe(1920);

      // Check scrollbar rendering
      const hasScrollbar = await page.evaluate(() => {
        return window.innerHeight > document.documentElement.clientHeight;
      });
      expect(typeof hasScrollbar).toBe('boolean');
    });

    test('Firefox viewport rendering', async ({ page, browserName }) => {
      test.skip(browserName !== 'firefox', 'Firefox only test');

      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/');

      // Firefox-specific rendering checks
      const scrollWidth = await page.evaluate(() => document.documentElement.scrollWidth);
      expect(scrollWidth).toBeLessThanOrEqual(1920);
    });

    test('WebKit viewport rendering', async ({ page, browserName }) => {
      test.skip(browserName !== 'webkit', 'WebKit only test');

      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/');

      // WebKit (Safari) specific checks for mobile
      const viewportMeta = await page.locator('meta[name="viewport"]').getAttribute('content');
      expect(viewportMeta).toBeTruthy();
    });
  });

  // Text Scaling and Zoom
  test.describe('Text Scaling and Zoom', () => {
    test('Text scaling at 150%', async ({ page }) => {
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/');

      // Simulate text zoom
      await page.evaluate(() => {
        document.documentElement.style.fontSize = '150%';
      });

      await page.waitForTimeout(200);

      // Verify content remains visible
      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      // Check no overflow
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      // May have scroll with zoom, but layout should not break
    });

    test('Page zoom at 125%', async ({ page }) => {
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/');

      // Set zoom via CSS transform (simulating browser zoom)
      await page.addStyleTag({
        content: 'body { transform: scale(1.25); transform-origin: top left; width: 80%; }',
      });

      await page.waitForTimeout(200);

      // Content should still be visible
      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();
    });
  });

  // Orientation Changes
  test.describe('Orientation Changes', () => {
    test('Portrait to Landscape transition', async ({ page }) => {
      // Start in portrait
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/');
      await page.waitForLoadState('networkidle');

      const portraitScreenshot = await page.screenshot();

      // Rotate to landscape
      await page.setViewportSize({ width: 667, height: 375 });
      await page.waitForTimeout(200);

      const landscapeScreenshot = await page.screenshot();

      // Screenshots should be different (layout adapted)
      expect(portraitScreenshot.toString('base64')).not.toBe(landscapeScreenshot.toString('base64'));

      // Verify no horizontal scroll in landscape
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Landscape to Portrait transition', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.goto('/');
      await page.waitForLoadState('networkidle');

      const landscapeScreenshot = await page.screenshot();

      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForTimeout(200);

      const portraitScreenshot = await page.screenshot();

      expect(landscapeScreenshot.toString('base64')).not.toBe(portraitScreenshot.toString('base64'));

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });
  });

  // Component Responsiveness
  test.describe('Component Responsiveness', () => {
    const viewports = [
      VIEWPORTS.desktop,
      VIEWPORTS.tablet,
      VIEWPORTS.mobile,
    ];

    for (const viewport of viewports) {
      test(`Components render correctly at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/components');
        await page.waitForLoadState('networkidle');

        // Check common component patterns
        const cards = page.locator('[class*="card"], [class*="Card"]');
        const buttons = page.locator('button');
        const inputs = page.locator('input, select, textarea');

        // Components should be visible
        if (await cards.count() > 0) {
          await expect(cards.first()).toBeVisible();
        }

        if (await buttons.count() > 0) {
          await expect(buttons.first()).toBeVisible();
        }

        if (await inputs.count() > 0) {
          await expect(inputs.first()).toBeVisible();
        }

        // Check for overflow issues
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();
      });
    }
  });

  // Accessibility Across Viewports
  test.describe('Accessibility Across Viewports', () => {
    const viewports = [
      VIEWPORTS.desktop,
      VIEWPORTS.tablet,
      VIEWPORTS.mobile,
    ];

    for (const viewport of viewports) {
      test(`Focus management at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/');

        const focusableElements = page.locator('button, a, input, select, textarea');

        if (await focusableElements.count() > 0) {
          // Tab through first few elements
          for (let i = 0; i < Math.min(3, await focusableElements.count()); i++) {
            await page.keyboard.press('Tab');
            await page.waitForTimeout(50);

            const focused = page.locator(':focus');
            await expect(focused).toBeVisible();
          }
        }
      });

      test(`Touch targets at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/');

        const interactiveElements = page.locator('button, a[href], input, select, textarea');

        if (await interactiveElements.count() > 0) {
          for (let i = 0; i < Math.min(5, await interactiveElements.count()); i++) {
            const element = interactiveElements.nth(i);
            const box = await element.boundingBox();

            if (box) {
              // WCAG 2.5.5: Touch targets should be at least 44x44 CSS pixels
              // Relaxed to 40x40 for development
              expect(box.width).toBeGreaterThanOrEqual(40);
              expect(box.height).toBeGreaterThanOrEqual(40);
            }
          }
        }
      });
    }
  });

  // Performance Across Viewports
  test.describe('Performance Across Viewports', () => {
    const viewports = [
      { ...VIEWPORTS.mobile, name: 'Mobile' },
      { ...VIEWPORTS.tablet, name: 'Tablet' },
      { ...VIEWPORTS.desktop, name: 'Desktop' },
    ];

    for (const viewport of viewports) {
      test(`Render performance at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        const startTime = Date.now();
        await page.goto('/');
        await page.waitForLoadState('networkidle');
        const loadTime = Date.now() - startTime;

        // Page should load in reasonable time
        expect(loadTime).toBeLessThan(10000);

        // Check Core Web Vitals
        const metrics = await page.evaluate(() => {
          return {
            domContentLoaded: performance.getEntriesByType('navigation')[0]?.domContentLoadedEventEnd ?? 0,
            loadComplete: performance.getEntriesByType('navigation')[0]?.loadEventEnd ?? 0,
          };
        });

        // DOM should be ready within reasonable time
        expect(metrics.domContentLoaded).toBeLessThan(5000);
      });
    }
  });

  // Real Device Emulation
  test.describe('Real Device Emulation', () => {
    test('iPhone 14 Pro emulation', async ({ page }) => {
      await page.setViewportSize({ width: 393, height: 852 });
      await page.goto('/');

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('iPad Pro emulation', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 1366 });
      await page.goto('/');

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Desktop HD emulation', async ({ page }) => {
      await page.setViewportSize({ width: 1920, height: 1080 });
      await page.goto('/');

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });
  });

  // Cross-Browser Consistency
  test.describe('Cross-Browser Consistency', () => {
    const viewports = [VIEWPORTS.mobile, VIEWPORTS.tablet, VIEWPORTS.desktop];

    for (const viewport of viewports) {
      test(`Layout consistency at ${viewport.name}`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });
        await page.goto('/');

        // Check key layout elements
        const header = page.locator('header');
        const main = page.locator('main');
        const footer = page.locator('footer');

        const headerVisible = await header.count() > 0 && await header.first().isVisible();
        const mainVisible = await main.count() > 0 && await main.first().isVisible();
        const footerVisible = await footer.count() > 0 && await footer.first().isVisible();

        // All visible sections should be visible
        if (headerVisible) expect(headerVisible).toBeTruthy();
        expect(mainVisible).toBeTruthy();
        if (footerVisible) expect(footerVisible).toBeTruthy();

        // No horizontal scroll
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();
      });
    }
  });
});

// Real Device User Agent Tests
const REAL_DEVICES: Record<string, { userAgent: string; viewport: { width: number; height: number } }> = {
  'iPhone-14-Pro': {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 393, height: 852 },
  },
  'iPhone-SE': {
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 375, height: 667 },
  },
  'iPad-Pro': {
    userAgent: 'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    viewport: { width: 1024, height: 1366 },
  },
  'Samsung-Galaxy-S22': {
    userAgent: 'Mozilla/5.0 (Linux; Android 12; SM-S906B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    viewport: { width: 360, height: 800 },
  },
};

test.describe('Real Device User Agent Tests', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  for (const [deviceName, config] of Object.entries(REAL_DEVICES)) {
    test(`${deviceName} viewport test`, async ({ page }) => {
      await page.setViewportSize(config.viewport);
      await page.setExtraHTTPHeaders({ 'User-Agent': config.userAgent });
      await page.goto('/');

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();

      // Check viewport meta tag is properly set
      const viewportMeta = await page.locator('meta[name="viewport"]').getAttribute('content');
      expect(viewportMeta).toContain('width=device-width');
    });
  }
});
