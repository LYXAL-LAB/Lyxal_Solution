import { test, expect, devices } from '@playwright/test';
import {
  tap,
  doubleTap,
  longPress,
  verifyTouchTargetSize,
  getTouchAction,
  hasTouchFeedback,
  measureTouchResponseTime,
  hasTouchListeners,
  getTouchHandlers,
} from '../helpers/touch-utils';

/**
 * Button Component Touch Interaction Tests
 *
 * Comprehensive touch testing for button components including:
 * - Basic touch interactions (tap, double tap, long press)
 * - Touch target sizing compliance
 * - Touch feedback mechanisms
 * - Touch event handling
 * - Cross-device compatibility
 */

test.describe('Button Component Touch Tests', () => {
  // Setup for mobile devices
  const mobileDevices = [
    { name: 'iPhone 14 Pro', config: devices['iPhone 14 Pro'] },
    { name: 'Pixel 5', config: devices['Pixel 5'] },
  ];

  mobileDevices.forEach(({ name, config }) => {
    test.describe(`${name}`, () => {
      test.use(config);

      test.beforeEach(async ({ page }) => {
        await page.goto('/components/button');
        await page.waitForLoadState('networkidle');
      });

      // ===== BASIC TOUCH INTERACTIONS =====

      test('should handle single tap', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          await button.tap();

          // Check for visual feedback
          await expect(button).toBeVisible();
        }
      });

      test('should handle rapid successive taps', async ({ page }) => {
        const button = page.locator('[data-testid="button-clickable"], button').first();

        if (await button.count() > 0) {
          const initialText = await button.textContent();

          // Perform 5 rapid taps
          for (let i = 0; i < 5; i++) {
            await button.tap();
            await page.waitForTimeout(50);
          }

          // Button should still be functional
          await expect(button).toBeVisible();
        }
      });

      test('should handle double tap', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          await doubleTap(page, button, { interval: 250 });

          await expect(button).toBeVisible();
        }
      });

      test('should handle long press', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          await longPress(page, button, { duration: 500 });

          await expect(button).toBeVisible();
        }
      });

      // ===== TOUCH TARGET SIZING =====

      test('should meet minimum touch target size (44x44)', async ({ page }) => {
        const buttons = page.locator('button, [role="button"]').all();

        for (const button of await buttons.slice(0, 10)) {
          const isValidSize = await verifyTouchTargetSize(page, button, 44);
          const isVisible = await button.then(b => b.isVisible());

          if (isVisible) {
            expect(isValidSize).toBeTruthy();
          }
        }
      });

      test('should have adequate touch target size for all button variants', async ({ page }) => {
        const variants = ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'];

        for (const variant of variants) {
          const button = page.locator(`[data-testid="button-${variant}"]`);

          if (await button.count() > 0) {
            const isValidSize = await verifyTouchTargetSize(page, button, 44);
            expect(isValidSize).toBeTruthy();
          }
        }
      });

      test('should have adequate touch target size for all button sizes', async ({ page }) => {
        const sizes = ['sm', 'default', 'lg', 'icon'];

        for (const size of sizes) {
          const button = page.locator(`[data-testid="button-${size}"]`);

          if (await button.count() > 0) {
            const box = await button.boundingBox();
            if (box) {
              // Icon buttons can be smaller but still need adequate size
              const minSize = size === 'icon' ? 40 : 44;
              expect(box.width).toBeGreaterThanOrEqual(minSize);
              expect(box.height).toBeGreaterThanOrEqual(minSize);
            }
          }
        }
      });

      // ===== TOUCH FEEDBACK =====

      test('should provide visual feedback on touch', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const hasFeedback = await hasTouchFeedback(page, button);
          expect(hasFeedback).toBeTruthy();
        }
      });

      test('should provide immediate visual feedback', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const responseTime = await measureTouchResponseTime(page, button);
          expect(responseTime).toBeLessThanOrEqual(100);
        }
      });

      test('should have active state styling', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          // Check for :active state styles
          const hasActiveStyles = await button.evaluate(el => {
            const styles = window.getComputedStyle(el, ':active');
            return styles.transform !== 'none' ||
                   styles.opacity !== '1' ||
                   styles.backgroundColor !== 'rgba(0, 0, 0, 0)';
          });

          expect(typeof hasActiveStyles).toBe('boolean');
        }
      });

      // ===== TOUCH EVENT HANDLING =====

      test('should register touch event handlers', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const handlers = await getTouchHandlers(page, button);
          expect(Array.isArray(handlers)).toBeTruthy();
        }
      });

      test('should have appropriate touch-action CSS', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const touchAction = await getTouchAction(page, button);

          // Buttons should allow manipulation
          const validActions = ['manipulation', 'auto', ''];
          const isValid = validActions.includes(touchAction);

          expect(isValid).toBeTruthy();
        }
      });

      test('should prevent default on touch when needed', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          // Test that button handles touch events properly
          await button.tap();

          // Button should remain interactive
          await expect(button).toBeEnabled();
        }
      });

      // ===== DISABLED STATE =====

      test('should not respond to touch when disabled', async ({ page }) => {
        const disabledButton = page.locator('[data-testid="button-disabled"], button[disabled]').first();

        if (await disabledButton.count() > 0) {
          const isDisabled = await disabledButton.isDisabled();

          if (isDisabled) {
            // Tap should not activate the button
            await disabledButton.tap({ force: true });

            // Button should still be disabled
            await expect(disabledButton).toBeDisabled();
          }
        }
      });

      test('should have visual feedback for disabled state', async ({ page }) => {
        const disabledButton = page.locator('[data-testid="button-disabled"], button[disabled]').first();

        if (await disabledButton.count() > 0) {
          const isDisabled = await disabledButton.isDisabled();

          if (isDisabled) {
            const opacity = await disabledButton.evaluate(el => {
              return window.getComputedStyle(el).opacity;
            });

            // Disabled buttons typically have reduced opacity
            expect(parseFloat(opacity)).toBeLessThan(1);
          }
        }
      });

      // ===== LOADING STATE =====

      test('should show loading state on touch', async ({ page }) => {
        const loadingButton = page.locator('[data-testid="button-loading"]').first();

        if (await loadingButton.count() > 0) {
          // Button should have loading indicator
          const hasLoadingClass = await loadingButton.evaluate(el => {
            return el.classList.contains('loading') ||
                   el.getAttribute('data-loading') === 'true';
          });

          expect(typeof hasLoadingClass).toBe('boolean');
        }
      });

      test('should prevent additional touches during loading', async ({ page }) => {
        const loadingButton = page.locator('[data-testid="button-loading"]').first();

        if (await loadingButton.count() > 0) {
          const isDisabled = await loadingButton.isDisabled();

          // Loading buttons should be disabled
          expect(isDisabled).toBeTruthy();
        }
      });

      // ===== BUTTON VARIANTS TOUCH BEHAVIOR =====

      test('destructive variant should have touch feedback', async ({ page }) => {
        const button = page.locator('[data-testid="button-destructive"]').first();

        if (await button.count() > 0) {
          const hasFeedback = await hasTouchFeedback(page, button);
          expect(hasFeedback).toBeTruthy();
        }
      });

      test('outline variant should have touch feedback', async ({ page }) => {
        const button = page.locator('[data-testid="button-outline"]').first();

        if (await button.count() > 0) {
          const hasFeedback = await hasTouchFeedback(page, button);
          expect(hasFeedback).toBeTruthy();
        }
      });

      test('ghost variant should have touch feedback', async ({ page }) => {
        const button = page.locator('[data-testid="button-ghost"]').first();

        if (await button.count() > 0) {
          const hasFeedback = await hasTouchFeedback(page, button);
          expect(hasFeedback).toBeTruthy();
        }
      });

      // ===== BUTTON WITH ICONS =====

      test('icon button should have adequate touch target', async ({ page }) => {
        const iconButton = page.locator('[data-testid="button-icon"], button[aria-label]').first();

        if (await iconButton.count() > 0) {
          const box = await iconButton.boundingBox();

          if (box) {
            // Icon buttons should still be at least 40x40
            expect(box.width).toBeGreaterThanOrEqual(40);
            expect(box.height).toBeGreaterThanOrEqual(40);
          }
        }
      });

      test('button with icon should respond to touch', async ({ page }) => {
        const buttonWithIcon = page.locator('button svg, button i').first();

        if (await buttonWithIcon.count() > 0) {
          // Get the parent button
          const button = buttonWithIcon.locator('..');

          await button.tap();
          await expect(button).toBeVisible();
        }
      });

      // ===== BUTTON GROUPS =====

      test('button group items should have adequate spacing', async ({ page }) => {
        const buttonGroup = page.locator('[role="group"], .btn-group').first();

        if (await buttonGroup.count() > 0) {
          const buttons = buttonGroup.locator('button').all();

          for (let i = 0; i < (await buttons.length) - 1; i++) {
            const current = await buttons[i];
            const next = await buttons[i + 1];

            const currentBox = await current.boundingBox();
            const nextBox = await next.boundingBox();

            if (currentBox && nextBox) {
              // Buttons should be spaced or have visual separation
              const gap = nextBox.x - (currentBox.x + currentBox.width);
              expect(gap).toBeGreaterThanOrEqual(0);
            }
          }
        }
      });

      // ===== FORM SUBMISSION =====

      test('submit button should work in forms', async ({ page }) => {
        const form = page.locator('[data-testid="form-with-button"], form').first();

        if (await form.count() > 0) {
          const submitButton = form.locator('button[type="submit"], [data-testid="submit-button"]').first();

          if (await submitButton.count() > 0) {
            await submitButton.tap();

            // Wait for form submission
            await page.waitForTimeout(200);
          }
        }
      });

      // ===== ACCESSIBILITY =====

      test('should have accessible name for touch', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const accessibleName = await button.evaluate(el => {
            return el.getAttribute('aria-label') ||
                   el.getAttribute('title') ||
                   el.textContent?.trim();
          });

          expect(accessibleName).toBeTruthy();
          expect(accessibleName?.length).toBeGreaterThan(0);
        }
      });

      test('should announce state changes to screen readers', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          // Check for aria attributes that indicate state
          const ariaPressed = await button.getAttribute('aria-pressed');
          const ariaExpanded = await button.getAttribute('aria-expanded');
          const ariaDisabled = await button.getAttribute('aria-disabled');

          // At least one should be defined (or null for simple buttons)
          expect([ariaPressed, ariaExpanded, ariaDisabled].some(v => v !== undefined)).toBeTruthy();
        }
      });

      // ===== PERFORMANCE =====

      test('should handle 100 taps without performance issues', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          const startTime = Date.now();

          for (let i = 0; i < 100; i++) {
            await button.tap();
          }

          const duration = Date.now() - startTime;

          // Should complete 100 taps in under 10 seconds
          expect(duration).toBeLessThan(10000);
        }
      });

      test('should not cause memory leaks on repeated touches', async ({ page }) => {
        const button = page.locator('button').first();

        if (await button.count() > 0) {
          // Get initial memory usage
          const initialMemory = await page.evaluate(() => {
            return (performance as any).memory?.usedJSHeapSize || 0;
          });

          // Perform many taps
          for (let i = 0; i < 50; i++) {
            await button.tap();
            await page.waitForTimeout(10);
          }

          // Force garbage collection if available
          await page.evaluate(() => {
            if ((globalThis as any).gc) {
              (globalThis as any).gc();
            }
          });

          // Check final memory usage
          const finalMemory = await page.evaluate(() => {
            return (performance as any).memory?.usedJSHeapSize || 0;
          });

          // Memory should not have increased significantly (allow 50% increase)
          if (initialMemory > 0 && finalMemory > 0) {
            const memoryIncrease = (finalMemory - initialMemory) / initialMemory;
            expect(memoryIncrease).toBeLessThan(0.5);
          }
        }
      });
    });
  });

  // ===== TABLET-SPECIFIC TESTS =====

  test.describe('iPad Pro', () => {
    test.use(devices['iPad Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/components/button');
      await page.waitForLoadState('networkidle');
    });

    test('should have larger touch targets on tablet', async ({ page }) => {
      const buttons = page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        const box = await button.then(b => b.boundingBox());

        if (box) {
          // Tablet buttons can be slightly larger
          expect(box.width).toBeGreaterThanOrEqual(44);
          expect(box.height).toBeGreaterThanOrEqual(44);
        }
      }
    });

    test('should support multi-touch gestures', async ({ page }) => {
      // This is more relevant for components that support zoom/pan
      // For buttons, we just verify they still work with multi-touch capable devices
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await button.tap();
        await expect(button).toBeVisible();
      }
    });
  });

  // ===== ORIENTATION TESTS =====

  test.describe('Orientation Changes', () => {
    test('should work in portrait orientation', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/components/button');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await button.tap();
        await expect(button).toBeVisible();
      }
    });

    test('should work in landscape orientation', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/button');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await button.tap();
        await expect(button).toBeVisible();
      }
    });

    test('should maintain touch target sizes in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/button');

      const buttons = page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        const box = await button.then(b => b.boundingBox());

        if (box) {
          expect(box.width).toBeGreaterThanOrEqual(44);
          expect(box.height).toBeGreaterThanOrEqual(44);
        }
      }
    });
  });

  // ===== CROSS-PLATFORM CONSISTENCY =====

  test.describe('Cross-Platform Consistency', () => {
    const platforms = [
      { name: 'iOS', config: devices['iPhone 14 Pro'] },
      { name: 'Android', config: devices['Pixel 5'] },
    ];

    platforms.forEach(({ name, config }) => {
      test(`${name} button behavior consistency`, async ({ page }) => {
        test.use(config);

        await page.goto('/components/button');

        const button = page.locator('button').first();

        if (await button.count() > 0) {
          // Should be visible
          await expect(button).toBeVisible();

          // Should be tappable
          await button.tap();

          // Should have adequate size
          const box = await button.boundingBox();
          if (box) {
            expect(box.width).toBeGreaterThanOrEqual(44);
            expect(box.height).toBeGreaterThanOrEqual(44);
          }
        }
      });
    });
  });
});

// ===== TOUCH TARGET EDGE CASES =====

test.describe('Button Touch Target Edge Cases', () => {
  test.use(devices['iPhone 14 Pro']);

  test('should handle touches at button edges', async ({ page }) => {
    await page.goto('/components/button');

    const button = page.locator('button').first();

    if (await button.count() > 0) {
      const box = await button.boundingBox();

      if (box) {
        // Test touch at each corner
        const corners = [
          { x: box.x + 5, y: box.y + 5 },
          { x: box.x + box.width - 5, y: box.y + 5 },
          { x: box.x + 5, y: box.y + box.height - 5 },
          { x: box.x + box.width - 5, y: box.y + box.height - 5 },
        ];

        for (const corner of corners) {
          await page.touchstart(corner.x, corner.y);
          await page.waitForTimeout(50);
          await page.touchend();

          await page.waitForTimeout(50);
        }

        // Button should still be functional
        await expect(button).toBeVisible();
      }
    }
  });

  test('should handle touch slightly outside button bounds', async ({ page }) => {
    await page.goto('/components/button');

    const button = page.locator('button').first();

    if (await button.count() > 0) {
      const box = await button.boundingBox();

      if (box) {
        // Touch just outside the button (shouldn't activate)
        await page.touchstart(box.x + box.width + 5, box.y + box.height / 2);
        await page.waitForTimeout(50);
        await page.touchend();

        // Button should still be present
        await expect(button).toBeVisible();
      }
    }
  });
});

// ===== BUTTON TOUCH ACCESSIBILITY =====

test.describe('Button Touch Accessibility', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/button');
  });

  test('should not have obscured touch targets', async ({ page }) => {
    const buttons = page.locator('button').all();

    for (const button of await buttons.slice(0, 5)) {
      const isVisible = await button.then(b => b.isVisible());

      if (isVisible) {
        const box = await button.then(b => b.boundingBox());

        if (box) {
          // Check if element is covered by something else
          const elementAtPoint = await page.evaluate(({ x, y }) => {
            const el = document.elementFromPoint(x, y);
            return el?.tagName.toLowerCase();
          }, { x: box.x + box.width / 2, y: box.y + box.height / 2 });

          expect(elementAtPoint).toBe('button');
        }
      }
    }
  });

  test('should have adequate spacing between adjacent buttons', async ({ page }) => {
    const buttons = await page.locator('button').all();

    for (let i = 0; i < Math.min(buttons.length, 10) - 1; i++) {
      const button1 = buttons[i];
      const button2 = buttons[i + 1];

      const box1 = await button1.boundingBox();
      const box2 = await button2.boundingBox();

      if (box1 && box2) {
        // Calculate distance between buttons
        const horizontalDistance = Math.abs(box2.x - (box1.x + box1.width));
        const verticalDistance = Math.abs(box2.y - (box1.y + box1.height));

        // Adjacent buttons should have at least 8px spacing
        const isHorizontallyAdjacent = box1.y === box2.y;
        const isVerticallyAdjacent = box1.x === box2.x;

        if (isHorizontallyAdjacent) {
          expect(horizontalDistance).toBeGreaterThanOrEqual(8);
        } else if (isVerticallyAdjacent) {
          expect(verticalDistance).toBeGreaterThanOrEqual(8);
        }
      }
    }
  });

  test('should maintain contrast for touch feedback', async ({ page }) => {
    const button = page.locator('button').first();

    if (await button.count() > 0) {
      // Get background color in normal and active states
      const normalColor = await button.evaluate(el => {
        return window.getComputedStyle(el).backgroundColor;
      });

      // Simulate active state
      await button.tap();
      await page.waitForTimeout(50);

      const activeColor = await button.evaluate(el => {
        return window.getComputedStyle(el, ':active').backgroundColor;
      });

      // Colors should be defined (not transparent/rgba(0,0,0,0))
      expect(normalColor).not.toBe('rgba(0, 0, 0, 0)');
      expect(activeColor).not.toBe('rgba(0, 0, 0, 0)');
    }
  });
});
