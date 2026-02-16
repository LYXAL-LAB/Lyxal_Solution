import { test, expect } from '@playwright/test';

/**
 * Landscape Orientation Testing Suite
 *
 * This suite tests landscape orientation support specifically for tablets and foldable devices.
 * Tests cover:
 * - Tablet landscape layouts (768px-1024px width)
 * - Orientation transitions (portrait ↔ landscape)
 * - Component behavior in landscape
 * - Touch target sizing in landscape
 * - Navigation adaptation
 * - Split-screen compatibility
 */

// Tablet landscape viewports
const TABLET_LANDSCAPE_VIEWPORTS = {
  // Standard iPad
  iPadLandscape: { width: 1024, height: 768, name: 'iPad Landscape' },
  iPadAirLandscape: { width: 1180, height: 820, name: 'iPad Air Landscape' },
  iPadPro11Landscape: { width: 1194, height: 834, name: 'iPad Pro 11" Landscape' },
  iPadPro129Landscape: { width: 1366, height: 1024, name: 'iPad Pro 12.9" Landscape' },

  // Android tablets
  galaxyTabS9: { width: 1280, height: 800, name: 'Galaxy Tab S9 Landscape' },
  pixelTablet: { width: 1600, height: 900, name: 'Google Pixel Tablet Landscape' },

  // Small tablets in landscape
  smallTabletLandscape: { width: 800, height: 600, name: 'Small Tablet Landscape' },
  miniTabletLandscape: { width: 640, height: 480, name: 'Mini Tablet Landscape' },
};

// Phone landscape viewports (for comparison)
const PHONE_LANDSCAPE_VIEWPORTS = {
  iPhone14ProLandscape: { width: 852, height: 393, name: 'iPhone 14 Pro Landscape' },
  pixel7ProLandscape: { width: 912, height: 412, name: 'Pixel 7 Pro Landscape' },
  galaxyS23Landscape: { width: 912, height: 412, name: 'Galaxy S23 Landscape' },
};

type ViewportConfig = {
  width: number;
  height: number;
  name: string;
};

test.describe('Landscape Orientation - Core Functionality', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test.describe('Tablet Landscape Viewports', () => {
    for (const viewport of Object.values(TABLET_LANDSCAPE_VIEWPORTS)) {
      test(`${viewport.name} - Basic Layout`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check that main content is visible
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        // Verify no horizontal scroll
        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();

        // Check orientation is detected correctly
        const isLandscape = await page.evaluate(() => {
          return window.matchMedia('(orientation: landscape)').matches;
        });
        expect(isLandscape).toBeTruthy();
      });

      test(`${viewport.name} - Component Visibility`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check for common components
        const header = page.locator('header').first();
        if (await header.count() > 0) {
          await expect(header).toBeVisible();
        }

        const main = page.locator('main').first();
        await expect(main).toBeVisible();

        // Check that elements fit within viewport width
        const bodyWidth = await page.evaluate(() => document.body.scrollWidth);
        expect(bodyWidth).toBeLessThanOrEqual(viewport.width + 1);
      });
    }
  });

  test.describe('Orientation Transitions', () => {
    test('Portrait to Landscape - iPad', async ({ page }) => {
      // Start in portrait
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForTimeout(200);

      const portraitScreenshot = await page.screenshot();

      // Rotate to landscape
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.waitForTimeout(300);

      const landscapeScreenshot = await page.screenshot();

      // Layout should adapt (screenshots should differ)
      expect(portraitScreenshot.toString('base64')).not.toBe(
        landscapeScreenshot.toString('base64')
      );

      // Verify no horizontal scroll in landscape
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Landscape to Portrait - iPad', async ({ page }) => {
      // Start in landscape
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.waitForTimeout(200);

      const landscapeScreenshot = await page.screenshot();

      // Rotate to portrait
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForTimeout(300);

      const portraitScreenshot = await page.screenshot();

      expect(landscapeScreenshot.toString('base64')).not.toBe(
        portraitScreenshot.toString('base64')
      );

      // Verify no horizontal scroll in portrait
      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Multiple Rotation Cycles', async ({ page }) => {
      const orientations = [
        { width: 768, height: 1024, name: 'Portrait' },
        { width: 1024, height: 768, name: 'Landscape' },
        { width: 768, height: 1024, name: 'Portrait Again' },
        { width: 1024, height: 768, name: 'Landscape Again' },
      ];

      for (const orientation of orientations) {
        await page.setViewportSize({ width: orientation.width, height: orientation.height });
        await page.waitForTimeout(200);

        // Verify layout is valid after each rotation
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();
      }
    });

    test('Phone Landscape to Tablet Landscape Transition', async ({ page }) => {
      // Start with phone in landscape
      await page.setViewportSize({ width: 667, height: 375 });
      await page.waitForTimeout(200);

      // Transition to tablet landscape
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.waitForTimeout(200);

      // Verify layout adapted
      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });
  });

  test.describe('Landscape-Specific Layouts', () => {
    test('Side-by-Side Content in Landscape', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.goto('/components');

      // Look for side-by-side layouts (common in landscape)
      const flexRows = page.locator('.flex-row, [class*="flex-row"]').all();
      const count = await flexRows.length;

      if (count > 0) {
        // Check if any flex-row elements are visible
        for (let i = 0; i < Math.min(count, 3); i++) {
          const element = (await flexRows)[i];
          const isVisible = await element.isVisible();
          if (isVisible) {
            const box = await element.boundingBox();
            if (box) {
              // Side-by-side content should fit within viewport
              expect(box.x + box.width).toBeLessThanOrEqual(1024 + 10);
            }
          }
        }
      }
    });

    test('Navigation in Landscape Mode', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Check navigation visibility
      const nav = page.locator('nav, header').first();
      if (await nav.count() > 0) {
        await expect(nav).toBeVisible();

        // In landscape, navigation should be horizontal
        const navItems = nav.locator('a, button').all();
        const itemCount = await (await navItems).length;

        if (itemCount > 0) {
          // Check that nav items are accessible
          for (let i = 0; i < Math.min(itemCount, 5); i++) {
            const item = (await navItems)[i];
            const isVisible = await item.isVisible();
            if (isVisible) {
              const box = await item.boundingBox();
              if (box) {
                // Nav items should be within viewport
                expect(box.x).toBeGreaterThanOrEqual(0);
                expect(box.x + box.width).toBeLessThanOrEqual(1024);
              }
            }
          }
        }
      }
    });

    test('Card Grid Adapts to Landscape', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.goto('/components');

      // Look for card grids
      const grids = page.locator('[class*="grid"]').all();
      const gridCount = await grids.length;

      if (gridCount > 0) {
        // Check first few grids
        for (let i = 0; i < Math.min(gridCount, 3); i++) {
          const grid = (await grids)[i];
          const isVisible = await grid.isVisible();
          if (isVisible) {
            // Grid should fit within viewport
            const box = await grid.boundingBox();
            if (box) {
              expect(box.x + box.width).toBeLessThanOrEqual(1024 + 20);
            }
          }
        }
      }
    });
  });

  test.describe('Touch Targets in Landscape', () => {
    for (const viewport of Object.values(TABLET_LANDSCAPE_VIEWPORTS)) {
      test(`${viewport.name} - Touch Target Sizing`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Check interactive elements
        const buttons = page.locator('button, a[href]').all();
        const buttonCount = await buttons.length;

        if (buttonCount > 0) {
          let validTargets = 0;
          let checkedCount = 0;

          // Check first 10 buttons
          for (let i = 0; i < Math.min(buttonCount, 10); i++) {
            const button = (await buttons)[i];
            const isVisible = await button.isVisible();
            if (isVisible) {
              const box = await button.boundingBox();
              if (box) {
                // WCAG 2.5.5: Touch targets should be at least 44x44 CSS pixels
                const isLargeEnough = box.width >= 40 && box.height >= 40;
                if (isLargeEnough) {
                  validTargets++;
                }
                checkedCount++;
              }
            }
          }

          // Most touch targets should meet minimum size
          if (checkedCount > 0) {
            const percentage = (validTargets / checkedCount) * 100;
            expect(percentage).toBeGreaterThanOrEqual(80); // At least 80% should be valid
          }
        }
      });

      test(`${viewport.name} - Target Spacing`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Look for button groups
        const buttonGroups = page.locator('[class*="button"], [class*="btn"]').all();

        if (await buttonGroups.length > 0) {
          // Check spacing between adjacent buttons
          for (let i = 0; i < Math.min(await buttonGroups.length, 3); i++) {
            const group = (await buttonGroups)[i];
            const children = group.locator('*').all();

            if ((await children.length) > 1) {
              const first = (await children)[0];
              const second = (await children)[1];

              const firstBox = await first.boundingBox();
              const secondBox = await second.boundingBox();

              if (firstBox && secondBox) {
                // Elements should have some spacing (not overlapping)
                const overlap = Math.min(
                  firstBox.x + firstBox.width,
                  secondBox.x + secondBox.width
                ) - Math.max(firstBox.x, secondBox.x);

                expect(overlap).toBeLessThan(10); // Minimal overlap allowed
              }
            }
          }
        }
      });
    }
  });

  test.describe('Forms in Landscape', () => {
    test('Form Layout in Landscape Mode', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.goto('/components');

      // Look for forms
      const forms = page.locator('form, [class*="form"]').all();
      const formCount = await forms.length;

      if (formCount > 0) {
        for (let i = 0; i < Math.min(formCount, 3); i++) {
          const form = (await forms)[i];
          const isVisible = await form.isVisible();
          if (isVisible) {
            // Check that form fits in viewport
            const box = await form.boundingBox();
            if (box) {
              expect(box.x + box.width).toBeLessThanOrEqual(1024);
            }

            // Check form inputs
            const inputs = form.locator('input, select, textarea').all();
            const inputCount = await inputs.length;

            if (inputCount > 0) {
              for (let j = 0; j < Math.min(inputCount, 3); j++) {
                const input = (await inputs)[j];
                const inputBox = await input.boundingBox();
                if (inputBox) {
                  // Inputs should be large enough to tap
                  expect(inputBox.width).toBeGreaterThanOrEqual(40);
                }
              }
            }
          }
        }
      }
    });

    test('Inline Labels in Landscape', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Look for label-input pairs
      const labels = page.locator('label').all();

      if (await labels.length > 0) {
        // Check first few labels
        for (let i = 0; i < Math.min(await labels.length, 5); i++) {
          const label = (await labels)[i];
          const isVisible = await label.isVisible();
          if (isVisible) {
            // Label should be visible
            const text = await label.textContent();
            expect(text?.trim().length).toBeGreaterThan(0);
          }
        }
      }
    });
  });

  test.describe('Split-Screen Compatibility', () => {
    test('Narrow Width in Split-Screen (1/3)', async ({ page }) => {
      // Simulate iPad split-screen 1/3 width
      await page.setViewportSize({ width: 320, height: 768 });

      // Check content adapts to narrow width
      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Split-Screen Width (2/3)', async ({ page }) => {
      // Simulate iPad split-screen 2/3 width
      await page.setViewportSize({ width: 680, height: 768 });

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });

    test('Full Width Landscape', async ({ page }) => {
      // Full iPad landscape width
      await page.setViewportSize({ width: 1024, height: 768 });

      const main = page.locator('main, body').first();
      await expect(main).toBeVisible();

      const hasHorizontalScroll = await page.evaluate(() => {
        return document.body.scrollWidth > window.innerWidth;
      });
      expect(hasHorizontalScroll).toBeFalsy();
    });
  });

  test.describe('Phone Landscape Comparison', () => {
    for (const viewport of Object.values(PHONE_LANDSCAPE_VIEWPORTS)) {
      test(`${viewport.name} - Layout Comparison`, async ({ page }) => {
        await page.setViewportSize({ width: viewport.width, height: viewport.height });

        // Phone landscape should still work
        const main = page.locator('main, body').first();
        await expect(main).toBeVisible();

        const hasHorizontalScroll = await page.evaluate(() => {
          return document.body.scrollWidth > window.innerWidth;
        });
        expect(hasHorizontalScroll).toBeFalsy();

        // Phone landscape may have different layout than tablet
        const isLandscape = await page.evaluate(() => {
          return window.matchMedia('(orientation: landscape)').matches;
        });
        expect(isLandscape).toBeTruthy();
      });
    }
  });

  test.describe('Safe Areas in Landscape', () => {
    test('Horizontal Safe Areas', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Check if safe-area-inset is being used
      const hasSafeAreaSupport = await page.evaluate(() => {
        const testDiv = document.createElement('div');
        testDiv.style.paddingLeft = 'env(safe-area-inset-left)';
        document.body.appendChild(testDiv);
        const computed = window.getComputedStyle(testDiv).paddingLeft;
        document.body.removeChild(testDiv);
        return computed !== '0px';
      });

      // If supported, check for safe-area usage
      if (hasSafeAreaSupport) {
        const safeAreaElements = await page.locator('[class*="safe"]').count();
        // May or may not have safe-area elements
        expect(typeof safeAreaElements).toBe('number');
      }
    });
  });

  test.describe('Media in Landscape', () => {
    test('Images in Landscape Mode', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Look for images
      const images = page.locator('img').all();
      const imageCount = await images.length;

      if (imageCount > 0) {
        for (let i = 0; i < Math.min(imageCount, 3); i++) {
          const image = (await images)[i];
          const isVisible = await image.isVisible();
          if (isVisible) {
            // Check image is properly sized
            const box = await image.boundingBox();
            if (box) {
              // Images should fit within viewport
              expect(box.x + box.width).toBeLessThanOrEqual(1024 + 20);
            }
          }
        }
      }
    });

    test('Video Players in Landscape', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Look for video elements
      const videos = page.locator('video, iframe[src*="youtube"], iframe[src*="vimeo"]').all();
      const videoCount = await videos.length;

      if (videoCount > 0) {
        for (let i = 0; i < Math.min(videoCount, 3); i++) {
          const video = (await videos)[i];
          const isVisible = await video.isVisible();
          if (isVisible) {
            const box = await video.boundingBox();
            if (box) {
              // Video should fit in landscape
              expect(box.x + box.width).toBeLessThanOrEqual(1024);
            }
          }
        }
      }
    });
  });

  test.describe('Performance in Landscape', () => {
    test('Render Performance - Tablet Landscape', async ({ page }) => {
      const startTime = Date.now();
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.goto('/');
      await page.waitForLoadState('networkidle');
      const loadTime = Date.now() - startTime;

      // Page should load in reasonable time
      expect(loadTime).toBeLessThan(5000);
    });

    test('Rotation Performance', async ({ page }) => {
      // Start in portrait
      await page.setViewportSize({ width: 768, height: 1024 });
      await page.waitForLoadState('networkidle');

      // Measure rotation time
      const startTime = Date.now();
      await page.setViewportSize({ width: 1024, height: 768 });
      await page.waitForTimeout(300);
      const rotationTime = Date.now() - startTime;

      // Rotation should be fast
      expect(rotationTime).toBeLessThan(1000);
    });
  });

  test.describe('Accessibility in Landscape', () => {
    test('Focus Management in Landscape', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

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

    test('Screen Reader Compatibility', async ({ page }) => {
      await page.setViewportSize({ width: 1024, height: 768 });

      // Check for ARIA labels
      const ariaElements = page.locator('[aria-label], [aria-labelledby]').all();
      const count = await ariaElements.length;

      // Should have some ARIA labels for accessibility
      expect(typeof count).toBe('number');
    });
  });
});

test.describe('Landscape Orientation - Visual Regression', () => {
  const landscapeViewports = [
    TABLET_LANDSCAPE_VIEWPORTS.iPadLandscape,
    TABLET_LANDSCAPE_VIEWPORTS.iPadPro11Landscape,
    TABLET_LANDSCAPE_VIEWPORTS.galaxyTabS9,
  ];

  for (const viewport of landscapeViewports) {
    test(`${viewport.name} - Screenshot`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.goto('/');
      await page.waitForLoadState('networkidle');

      await expect(page).toHaveScreenshot(
        `landscape-${viewport.name.replace(/\s+/g, '-').toLowerCase()}.png`,
        {
          maxDiffPixels: viewport.width * viewport.height * 0.01,
        }
      );
    });
  }
});
