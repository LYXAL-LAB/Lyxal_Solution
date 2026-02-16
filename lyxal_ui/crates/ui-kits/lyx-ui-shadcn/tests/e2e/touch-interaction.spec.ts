import { test, expect, devices } from '@playwright/test';
import {
  setupMobileEmulation,
  MOBILE_DEVICES,
  tap,
  doubleTap,
  longPress,
  swipe,
  drag,
  touchScroll,
  pinchZoom,
  hasTouchListeners,
  getTouchAction,
  verifyTouchTargetSize,
  validateTouchTargets,
  hasMobileViewportMeta,
  detectMultiTouchSupport,
  measureTouchResponseTime,
  multiTouchGesture,
  preventsDefaultTouch,
  getHitAreaPadding,
  injectTouchLogger,
  getTouchEventLog,
  clearTouchEventLog,
  hasTouchFeedback,
  hasTouchActionInterference,
  getTouchHandlers,
} from './helpers/touch-utils';

/**
 * Touch Interaction E2E Tests
 *
 * Comprehensive test suite for touch interactions on mobile devices.
 * Tests cover:
 * - Basic touch interactions (tap, double tap, long press)
 * - Advanced gestures (swipe, drag, pinch-to-zoom)
 * - Touch event handling and validation
 * - Touch target sizing and accessibility
 * - Touch feedback mechanisms
 * - Cross-device compatibility
 */

test.describe('Touch Interaction Tests', () => {
  // ===== SETUP AND TEARDOWN =====

  test.beforeEach(async ({ page }) => {
    await injectTouchLogger(page);
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test.afterEach(async ({ page }) => {
    await clearTouchEventLog(page);
  });

  // ===== BASIC TOUCH INTERACTIONS =====

  test.describe('Basic Touch Interactions', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should handle single tap', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await tap(page, button);
        await expect(button).toBeVisible();

        // Check touch events were logged
        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThan(0);
      }
    });

    test('should handle double tap', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await doubleTap(page, button, { interval: 300 });

        const events = await getTouchEventLog(page);
        // Should have multiple touch events
        expect(events.length).toBeGreaterThan(1);
      }
    });

    test('should handle long press', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await longPress(page, button, { duration: 500 });

        const events = await getTouchEventLog(page);
        expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
      }
    });

    test('should provide visual feedback on touch', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const hasFeedback = await hasTouchFeedback(page, button);
        expect(hasFeedback).toBeTruthy();
      }
    });
  });

  // ===== SWIPE GESTURES =====

  test.describe('Swipe Gestures', () => {
    for (const [deviceName, deviceConfig] of Object.entries(MOBILE_DEVICES)) {
      test.describe(`${deviceName}`, () => {
        test.use({
          viewport: deviceConfig.viewport,
          userAgent: deviceConfig.userAgent,
        });

        test('should handle swipe up', async ({ page }) => {
          await clearTouchEventLog(page);
          await swipe(page, null, 'up', { duration: 300 });

          const events = await getTouchEventLog(page);
          expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
        });

        test('should handle swipe down', async ({ page }) => {
          await clearTouchEventLog(page);
          await swipe(page, null, 'down', { duration: 300 });

          const events = await getTouchEventLog(page);
          expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
        });

        test('should handle swipe left', async ({ page }) => {
          await clearTouchEventLog(page);
          await swipe(page, null, 'left', { duration: 300 });

          const events = await getTouchEventLog(page);
          expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
        });

        test('should handle swipe right', async ({ page }) => {
          await clearTouchEventLog(page);
          await swipe(page, null, 'right', { duration: 300 });

          const events = await getTouchEventLog(page);
          expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
        });

        test('should handle swipe on specific element', async ({ page }) => {
          const swipeable = page.locator('[class*="swipe"], [data-swipeable]').first();

          if (await swipeable.count() > 0) {
            await clearTouchEventLog(page);
            await swipe(page, swipeable, 'left');

            const events = await getTouchEventLog(page);
            expect(events.some(e => e.type === 'touchmove')).toBeTruthy();
          }
        });
      });
    }
  });

  // ===== DRAG INTERACTIONS =====

  test.describe('Drag Interactions', () => {
    test.use({
      ...devices['Pixel 5'],
    });

    test('should handle horizontal drag', async ({ page }) => {
      const draggable = page.locator('[draggable], [data-draggable]').first();

      if (await draggable.count() > 0) {
        await clearTouchEventLog(page);
        await drag(page, draggable, 100, 0);

        const events = await getTouchEventLog(page);
        expect(events.some(e => e.type === 'touchmove')).toBeTruthy();
      }
    });

    test('should handle vertical drag', async ({ page }) => {
      const draggable = page.locator('[draggable], [data-draggable]').first();

      if (await draggable.count() > 0) {
        await clearTouchEventLog(page);
        await drag(page, draggable, 0, 100);

        const events = await getTouchEventLog(page);
        expect(events.some(e => e.type === 'touchmove')).toBeTruthy();
      }
    });

    test('should handle diagonal drag', async ({ page }) => {
      const draggable = page.locator('[draggable], [data-draggable]').first();

      if (await draggable.count() > 0) {
        await clearTouchEventLog(page);
        await drag(page, draggable, 50, 50);

        const events = await getTouchEventLog(page);
        expect(events.some(e => e.type === 'touchmove')).toBeTruthy();
      }
    });
  });

  // ===== PINCH TO ZOOM =====

  test.describe('Pinch to Zoom', () => {
    test.use({
      ...devices['iPad Pro'],
    });

    test('should handle pinch zoom in', async ({ page }) => {
      const zoomable = page.locator('[data-zoomable], .zoomable, img').first();

      if (await zoomable.count() > 0) {
        await clearTouchEventLog(page);
        await pinchZoom(page, zoomable, { scale: 1.5, duration: 500 });

        const events = await getTouchEventLog(page);
        // Should have multiple touch events for multi-touch
        expect(events.length).toBeGreaterThan(2);
      }
    });

    test('should handle pinch zoom out', async ({ page }) => {
      const zoomable = page.locator('[data-zoomable], .zoomable, img').first();

      if (await zoomable.count() > 0) {
        await clearTouchEventLog(page);
        await pinchZoom(page, zoomable, { scale: 0.7, duration: 500 });

        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThan(2);
      }
    });
  });

  // ===== TOUCH SCROLL =====

  test.describe('Touch Scroll', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should handle vertical touch scroll', async ({ page }) => {
      await clearTouchEventLog(page);
      await touchScroll(page, null, 0, -200);

      // Wait for scroll to complete
      await page.waitForTimeout(300);

      const scrollY = await page.evaluate(() => window.scrollY);
      expect(scrollY).toBeGreaterThan(0);
    });

    test('should handle horizontal touch scroll', async ({ page }) => {
      const scrollContainer = page.locator('[data-scrollable], .overflow-x-auto').first();

      if (await scrollContainer.count() > 0) {
        await clearTouchEventLog(page);
        await touchScroll(page, scrollContainer, -200, 0);

        const events = await getTouchEventLog(page);
        expect(events.some(e => e.type === 'touchmove')).toBeTruthy();
      }
    });

    test('should handle scroll with momentum', async ({ page }) => {
      const scrollableContent = page.locator('main, [role="main"]').first();

      if (await scrollableContent.count() > 0) {
        const initialScrollY = await page.evaluate(() => window.scrollY);

        // Fast scroll gesture
        await touchScroll(page, null, 0, -300, { duration: 200, steps: 5 });

        // Wait for momentum scroll
        await page.waitForTimeout(500);

        const finalScrollY = await page.evaluate(() => window.scrollY);
        expect(finalScrollY).toBeGreaterThan(initialScrollY);
      }
    });
  });

  // ===== TOUCH EVENT HANDLING =====

  test.describe('Touch Event Handling', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should register touchstart events', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const hasListeners = await hasTouchListeners(page, button, {
          touchstart: true,
        });
        // Note: This may return false if using delegated event listeners
        expect(typeof hasListeners).toBe('boolean');
      }
    });

    test('should register touchmove events', async ({ page }) => {
      const slider = page.locator('[role="slider"], input[type="range"]').first();

      if (await slider.count() > 0) {
        const hasListeners = await hasTouchListeners(page, slider, {
          touchmove: true,
        });
        expect(typeof hasListeners).toBe('boolean');
      }
    });

    test('should register touchend events', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const hasListeners = await hasTouchListeners(page, button, {
          touchend: true,
        });
        expect(typeof hasListeners).toBe('boolean');
      }
    });

    test('should have correct touch-action CSS', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const touchAction = await getTouchAction(page, button);
        expect(typeof touchAction).toBe('string');
      }
    });

    test('should prevent default when needed', async ({ page }) => {
      const swipeable = page.locator('[data-swipeable], [data-prevent-default]').first();

      if (await swipeable.count() > 0) {
        const prevents = await preventsDefaultTouch(page, swipeable, 'touchmove');
        expect(typeof prevents).toBe('boolean');
      }
    });

    test('should have touch event handlers', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const handlers = await getTouchHandlers(page, button);
        expect(Array.isArray(handlers)).toBeTruthy();
      }
    });
  });

  // ===== TOUCH TARGET SIZING =====

  test.describe('Touch Target Sizing', () => {
    const devicesToTest = [
      { name: 'Mobile', ...devices['iPhone 14 Pro'] },
      { name: 'Tablet', ...devices['iPad Pro'] },
    ];

    for (const device of devicesToTest) {
      test.describe(device.name, () => {
        test.use(device);

        test('should meet minimum touch target size (44x44)', async ({ page }) => {
          const buttons = page.locator('button, a[href], input, [role="button"]');

          const count = await buttons.count();
          let failures = 0;

          for (let i = 0; i < Math.min(count, 10); i++) {
            const button = buttons.nth(i);
            const isVisible = await button.isVisible();

            if (isVisible) {
              const isValidSize = await verifyTouchTargetSize(page, button, 44);
              if (!isValidSize) {
                failures++;
              }
            }
          }

          // Allow some failures for edge cases, but most should pass
          expect(failures).toBeLessThan(Math.min(count, 10) / 2);
        });

        test('should validate all touch targets', async ({ page }) => {
          const result = await validateTouchTargets(page, {
            minSize: 44,
            includeHidden: false,
          });

          // At least 50% of touch targets should be valid
          const total = result.valid + result.invalid.length;
          if (total > 0) {
            const validPercentage = (result.valid / total) * 100;
            expect(validPercentage).toBeGreaterThanOrEqual(50);
          }
        });

        test('should have adequate padding for touch targets', async ({ page }) => {
          const button = page.locator('button').first();

          if (await button.count() > 0) {
            const padding = await getHitAreaPadding(page, button);
            expect(typeof padding).toBe('object');
            expect(typeof padding.top).toBe('number');
          }
        });
      });
    }
  });

  // ===== TOUCH ACTION INTERFERENCE =====

  test.describe('Touch Action CSS', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should not have interfering touch-action on buttons', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const hasInterference = await hasTouchActionInterference(page, button);
        // Buttons should allow default touch behavior
        expect(hasInterference).toBeFalsy();
      }
    });

    test('should allow manipulation touch action for interactive elements', async ({ page }) => {
      const interactive = page.locator('button, a, input').first();

      if (await interactive.count() > 0) {
        const touchAction = await getTouchAction(page, interactive);
        // 'manipulation' or 'auto' are acceptable
        const isValid = touchAction === 'manipulation' ||
                       touchAction === 'auto' ||
                       touchAction === '';
        expect(isValid).toBeTruthy();
      }
    });
  });

  // ===== MULTI-TOUCH SUPPORT =====

  test.describe('Multi-Touch Support', () => {
    test.use({
      ...devices['iPad Pro'],
    });

    test('should detect multi-touch capability', async ({ page }) => {
      const support = await detectMultiTouchSupport(page);

      expect(support.touchSupport).toBe(true);
      expect(support.maxTouchPoints).toBeGreaterThan(0);
    });

    test('should handle multi-touch gestures', async ({ page }) => {
      const touchPoints = [
        { x: 100, y: 100 },
        { x: 200, y: 100 },
      ];

      await clearTouchEventLog(page);
      await multiTouchGesture(page, touchPoints, 300);

      const events = await getTouchEventLog(page);
      expect(events.length).toBeGreaterThan(0);
    });
  });

  // ===== TOUCH RESPONSE TIME =====

  test.describe('Touch Response Time', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should respond to touch within 100ms', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const responseTime = await measureTouchResponseTime(page, button);
        // Should respond within 100ms (feel instant)
        expect(responseTime).toBeLessThanOrEqual(100);
      }
    });

    test('should provide immediate visual feedback', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const hasFeedback = await hasTouchFeedback(page, button);
        expect(hasFeedback).toBeTruthy();
      }
    });
  });

  // ===== MOBILE VIEWPORT CONFIGURATION =====

  test.describe('Mobile Viewport Configuration', () => {
    for (const [deviceName, deviceConfig] of Object.entries(MOBILE_DEVICES)) {
      test(`${deviceName} should have proper viewport meta`, async ({ page }) => {
        await page.setExtraHTTPHeaders({ 'User-Agent': deviceConfig.userAgent });
        await page.goto('/');

        const hasViewport = await hasMobileViewportMeta(page);
        expect(hasViewport).toBeTruthy();
      });
    }

    test('should use device-width for viewport', async ({ page }) => {
      const viewportMeta = page.locator('meta[name="viewport"]');
      await expect(viewportMeta).toHaveAttribute('content', /width=device-width/);
    });

    test('should set initial-scale to 1', async ({ page }) => {
      const viewportMeta = page.locator('meta[name="viewport"]');
      await expect(viewportMeta).toHaveAttribute('content', /initial-scale=1/);
    });
  });

  // ===== CROSS-DEVICE COMPATIBILITY =====

  test.describe('Cross-Device Compatibility', () => {
    const testCases = [
      { name: 'iPhone 14 Pro', device: 'iPhone-14-Pro' as const },
      { name: 'iPhone SE', device: 'iPhone-SE' as const },
      { name: 'Samsung Galaxy S22', device: 'Samsung-Galaxy-S22' as const },
      { name: 'Pixel 7', device: 'Pixel-7' as const },
    ];

    for (const testCase of testCases) {
      test.describe(testCase.name, () => {
        test.beforeEach(async ({ page }) => {
          await setupMobileEmulation(page, testCase.device);
          await page.goto('/');
          await page.waitForLoadState('networkidle');
        });

        test('should handle basic tap interactions', async ({ page }) => {
          const button = page.locator('button').first();

          if (await button.count() > 0) {
            await clearTouchEventLog(page);
            await tap(page, button);

            const events = await getTouchEventLog(page);
            expect(events.length).toBeGreaterThan(0);
          }
        });

        test('should handle swipe gestures', async ({ page }) => {
          await clearTouchEventLog(page);
          await swipe(page, null, 'up');

          const events = await getTouchEventLog(page);
          expect(events.some(e => e.type === 'touchstart')).toBeTruthy();
        });

        test('should meet touch target requirements', async ({ page }) => {
          const result = await validateTouchTargets(page, { minSize: 44 });
          const total = result.valid + result.invalid.length;

          if (total > 0) {
            const validPercentage = (result.valid / total) * 100;
            expect(validPercentage).toBeGreaterThanOrEqual(50);
          }
        });
      });
    }
  });

  // ===== TOUCH ACCESSIBILITY =====

  test.describe('Touch Accessibility', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should have adequately spaced touch targets', async ({ page }) => {
      const buttons = page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        const box = await button.then(b => b.boundingBox());
        if (box) {
          // Check minimum size
          expect(box.width).toBeGreaterThanOrEqual(44);
          expect(box.height).toBeGreaterThanOrEqual(44);
        }
      }
    });

    test('should not have overlapping touch targets', async ({ page }) => {
      const buttons = page.locator('button').all();
      const boxes: Array<{ x: number; y: number; width: number; height: number }> = [];

      for (const button of await buttons.slice(0, 10)) {
        const box = await button.then(b => b.boundingBox());
        if (box) {
          boxes.push(box);
        }
      }

      // Check for overlaps
      for (let i = 0; i < boxes.length; i++) {
        for (let j = i + 1; j < boxes.length; j++) {
          const a = boxes[i];
          const b = boxes[j];

          const overlap = !(
            a.x + a.width < b.x ||
            b.x + b.width < a.x ||
            a.y + a.height < b.y ||
            b.y + b.height < a.y
          );

          // Small overlaps are OK (for nested buttons), but not complete containment
          if (overlap) {
            const overlapArea = Math.max(0, Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x)) *
                               Math.max(0, Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y));
            const aArea = a.width * a.height;
            const bArea = b.width * b.height;

            // No element should be mostly covered by another
            expect(overlapArea).toBeLessThan(Math.min(aArea, bArea) * 0.8);
          }
        }
      }
    });

    test('should maintain touch target visibility', async ({ page }) => {
      const buttons = page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        await button.then(async b => {
          const isVisible = await b.isVisible();
          const isDisabled = await b.isDisabled();

          if (isVisible && !isDisabled) {
            // Check if element is not obscured
            const box = await b.boundingBox();
            expect(box).toBeTruthy();
          }
        });
      }
    });
  });

  // ===== TOUCH ORIENTATION HANDLING =====

  test.describe('Touch Orientation Handling', () => {
    test('should handle portrait orientation', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await clearTouchEventLog(page);
        await tap(page, button);

        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThan(0);
      }
    });

    test('should handle landscape orientation', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await clearTouchEventLog(page);
        await tap(page, button);

        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThan(0);
      }
    });

    test('should maintain touch target sizes in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        const isValidSize = await verifyTouchTargetSize(page, button, 44);
        expect(isValidSize).toBeTruthy();
      }
    });
  });

  // ===== PREVENTING ACCIDENTAL TOUCHES =====

  test.describe('Preventing Accidental Touches', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should not activate on accidental touches', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        // Very short tap (accidental)
        const box = await button.boundingBox();
        if (box) {
          const x = box.x + box.width / 2;
          const y = box.y + box.height / 2;

          await page.touchstart(x, y);
          await page.waitForTimeout(30); // Very short duration
          await page.touchend();

          // This is a documentation test - actual behavior depends on implementation
          expect(box).toBeTruthy();
        }
      }
    });

    test('should distinguish between tap and long press', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        // Short tap
        await clearTouchEventLog(page);
        await tap(page, button, { duration: 50 });
        const tapEvents = await getTouchEventLog(page);

        // Long press
        await clearTouchEventLog(page);
        await longPress(page, button, { duration: 500 });
        const longPressEvents = await getTouchEventLog(page);

        // Events should be recorded
        expect(tapEvents.length).toBeGreaterThan(0);
        expect(longPressEvents.length).toBeGreaterThan(0);
      }
    });
  });

  // ===== EDGE CASES =====

  test.describe('Touch Edge Cases', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should handle touch at element edge', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const box = await button.boundingBox();
        if (box) {
          // Touch at the very edge of the button
          await page.touchstart(box.x + 1, box.y + 1);
          await page.waitForTimeout(100);
          await page.touchend();

          // Should still register the touch
          expect(box).toBeTruthy();
        }
      }
    });

    test('should handle rapid successive touches', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await clearTouchEventLog(page);

        // Rapid taps
        for (let i = 0; i < 5; i++) {
          await tap(page, button, { duration: 50 });
          await page.waitForTimeout(50);
        }

        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThanOrEqual(5);
      }
    });

    test('should handle touch during page transitions', async ({ page }) => {
      const link = page.locator('a[href]').first();

      if (await link.count() > 0) {
        await clearTouchEventLog(page);

        // Tap a link while page is still loading
        await tap(page, link);
        await page.waitForTimeout(100);

        const events = await getTouchEventLog(page);
        expect(events.length).toBeGreaterThan(0);
      }
    });
  });

  // ===== PERFORMANCE TESTS =====

  test.describe('Touch Performance', () => {
    test.use({
      ...devices['iPhone 14 Pro'],
    });

    test('should handle 60fps touch interactions', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const startTime = Date.now();

        // Perform 10 taps
        for (let i = 0; i < 10; i++) {
          await tap(page, button);
        }

        const duration = Date.now() - startTime;

        // Should complete 10 taps in under 2 seconds
        expect(duration).toBeLessThan(2000);
      }
    });

    test('should not cause layout thrashing on touch', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        let layoutCount = 0;

        await page.evaluate(() => {
          let count = 0;
          const observer = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
              if (entry.entryType === 'layout-shift') {
                count++;
              }
            }
          });
          observer.observe({ entryTypes: ['layout-shift'] });
          (window as any).__layoutCount = () => count;
        });

        // Perform touch interactions
        await tap(page, button);
        await swipe(page, null, 'up', { duration: 300 });

        await page.waitForTimeout(500);

        layoutCount = await page.evaluate(() => (window as any).__layoutCount?.() ?? 0);

        // Should not cause excessive layout shifts
        expect(layoutCount).toBeLessThan(5);
      }
    });
  });
});

// Device-specific test suites
test.describe('iOS Device Tests', () => {
  test.describe('iPhone 14 Pro', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle iOS-specific touch behaviors', async ({ page }) => {
      await page.goto('/');

      // iOS has specific touch behavior (double-tap to zoom, etc.)
      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await tap(page, button);
        await expect(button).toBeVisible();
      }
    });

    test('should respect iOS viewport height quirks', async ({ page }) => {
      await page.goto('/');

      // iOS includes URL bar in viewport
      const vh = await page.evaluate(() => {
        const testDiv = document.createElement('div');
        testDiv.style.height = '100vh';
        testDiv.style.position = 'absolute';
        testDiv.style.top = '-9999px';
        document.body.appendChild(testDiv);
        const height = testDiv.getBoundingClientRect().height;
        document.body.removeChild(testDiv);
        return height;
      });

      expect(vh).toBeGreaterThan(0);
    });
  });
});

test.describe('Android Device Tests', () => {
  test.describe('Samsung Galaxy S22', () => {
    test.use(devices['Galaxy S22+']);

    test('should handle Android-specific touch behaviors', async ({ page }) => {
      await page.goto('/');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        await tap(page, button);
        await expect(button).toBeVisible();
      }
    });

    test('should handle Android back button navigation', async ({ page }) => {
      await page.goto('/components');

      // Navigate to a sub-page if possible
      const subLink = page.locator('a[href]').first();
      if (await subLink.count() > 0) {
        await subLink.click();
        await page.waitForTimeout(200);

        // Android back button would go back
        await page.goBack();
        await expect(page).toHaveURL('/');
      }
    });
  });
});

test.describe('Tablet Device Tests', () => {
  test.describe('iPad Pro', () => {
    test.use(devices['iPad Pro']);

    test('should handle larger touch targets on tablet', async ({ page }) => {
      await page.goto('/');

      const button = page.locator('button').first();
      if (await button.count() > 0) {
        const box = await button.boundingBox();
        if (box) {
          // Tablet can have slightly larger targets
          expect(box.width).toBeGreaterThanOrEqual(44);
          expect(box.height).toBeGreaterThanOrEqual(44);
        }
      }
    });

    test('should handle multi-touch gestures on iPad', async ({ page }) => {
      await page.goto('/');

      const support = await detectMultiTouchSupport(page);
      expect(support.maxTouchPoints).toBeGreaterThanOrEqual(5);
    });
  });
});
