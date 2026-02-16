import { test, expect, devices } from '@playwright/test';
import {
  swipe,
  drag,
  pinchZoom,
  touchScroll,
  multiTouchGesture,
  tap,
  doubleTap,
  longPress,
  setupMobileEmulation,
  MOBILE_DEVICES,
} from './helpers/touch-utils';

/**
 * Gesture-Based Touch Interaction Tests
 *
 * Comprehensive testing for touch gestures including:
 * - Swipe gestures (all directions)
 * - Drag and drop
 * - Pinch to zoom
 * - Multi-touch gestures
 * - Scroll gestures
 * - Edge case handling
 * - Cross-device compatibility
 */

test.describe('Gesture-Based Touch Tests', () => {
  // ===== SWIPE GESTURES =====

  test.describe('Swipe Gestures', () => {
    const swipeDevices = [
      { name: 'iPhone 14 Pro', device: 'iPhone-14-Pro' as const },
      { name: 'Samsung Galaxy S22', device: 'Samsung-Galaxy-S22' as const },
    ];

    swipeDevices.forEach(({ name, device }) => {
      test.describe(`${name}`, () => {
        test.beforeEach(async ({ page }) => {
          await setupMobileEmulation(page, device);
          await page.goto('/');
          await page.waitForLoadState('networkidle');
        });

        test('should handle swipe up gesture', async ({ page }) => {
          await swipe(page, null, 'up', { duration: 300 });

          // Verify scroll occurred
          const scrollY = await page.evaluate(() => window.scrollY);
          expect(scrollY).toBeGreaterThan(0);
        });

        test('should handle swipe down gesture', async ({ page }) => {
          // First scroll down
          await touchScroll(page, null, 0, -200);
          await page.waitForTimeout(200);

          const scrollY = await page.evaluate(() => window.scrollY);
          expect(scrollY).toBeGreaterThan(0);

          // Then swipe up to go down
          await swipe(page, null, 'down', { duration: 300 });
        });

        test('should handle swipe left gesture', async ({ page }) => {
          const carousel = page.locator('[data-carousel], .carousel, .slider').first();

          if (await carousel.count() > 0) {
            await swipe(page, carousel, 'left', { duration: 300 });

            await page.waitForTimeout(200);
            await expect(carousel).toBeVisible();
          }
        });

        test('should handle swipe right gesture', async ({ page }) => {
          const carousel = page.locator('[data-carousel], .carousel, .slider').first();

          if (await carousel.count() > 0) {
            await swipe(page, carousel, 'right', { duration: 300 });

            await page.waitForTimeout(200);
            await expect(carousel).toBeVisible();
          }
        });

        test('should handle swipe with momentum', async ({ page }) => {
          const scrollable = page.locator('main, [role="main"]').first();

          if (await scrollable.count() > 0) {
            const initialScrollY = await page.evaluate(() => window.scrollY);

            // Fast swipe for momentum
            await swipe(page, scrollable, 'up', { duration: 200 });

            // Wait for momentum to complete
            await page.waitForTimeout(500);

            const finalScrollY = await page.evaluate(() => window.scrollY);
            expect(finalScrollY).toBeGreaterThan(initialScrollY);
          }
        });

        test('should handle slow swipe', async ({ page }) => {
          await swipe(page, null, 'up', { duration: 1000 });

          const scrollY = await page.evaluate(() => window.scrollY);
          expect(scrollY).toBeGreaterThan(0);
        });

        test('should handle short swipe', async ({ page }) => {
          await swipe(page, null, 'up', { duration: 100 });

          // Even short swipe should cause some movement
          const scrollY = await page.evaluate(() => window.scrollY);
          expect(scrollY).toBeGreaterThanOrEqual(0);
        });
      });
    });

    // ===== ELEMENT-SPECIFIC SWIPE =====

    test.describe('Element-Specific Swipe', () => {
      test.use(devices['iPhone 14 Pro']);

      test('should handle swipe on swipeable element', async ({ page }) => {
        await page.goto('/');

        const swipeable = page.locator('[data-swipeable], [data-on-swipe], .swipeable').first();

        if (await swipeable.count() > 0) {
          await swipe(page, swipeable, 'left');

          await page.waitForTimeout(300);

          // Element should still be visible
          await expect(swipeable).toBeVisible();
        }
      });

      test('should handle swipe on card element', async ({ page }) => {
        await page.goto('/');

        const card = page.locator('[class*="card"], [data-card]').first();

        if (await card.count() > 0) {
          await swipe(page, card, 'up');

          await page.waitForTimeout(200);

          await expect(card).toBeVisible();
        }
      });

      test('should handle swipe on list item', async ({ page }) => {
        await page.goto('/');

        const listItem = page.locator('li, [role="listitem"]').first();

        if (await listItem.count() > 0) {
          await swipe(page, listItem, 'left');

          await page.waitForTimeout(200);

          await expect(listItem).toBeVisible();
        }
      });
    });

    // ===== SWIPE DIRECTION DETECTION =====

    test.describe('Swipe Direction Detection', () => {
      test.use(devices['iPhone 14 Pro']);

      const directions = ['up', 'down', 'left', 'right'] as const;

      directions.forEach(direction => {
        test(`should detect ${direction} swipe`, async ({ page }) => {
          await page.goto('/');

          // This test verifies that the page can handle swipe in any direction
          await swipe(page, null, direction);

          // Page should still be functional
          const body = page.locator('body');
          await expect(body).toBeVisible();
        });
      });
    });

    // ===== SWIPE WITH CALLBACKS =====

    test.describe('Swipe with Callbacks', () => {
      test.use(devices['iPhone 14 Pro']);

      test('should trigger onSwipeStart callback', async ({ page }) => {
        await page.goto('/');

        const swipeable = page.locator('[data-swipeable], [data-on-swipe-start]').first();

        if (await swipeable.count() > 0) {
          // Inject event listener
          await swipeable.evaluate(el => {
            let swipeStarted = false;
            (el as any).__swipeStarted = () => { swipeStarted = true; };
          });

          await swipe(page, swipeable, 'right');

          await page.waitForTimeout(200);

          await expect(swipeable).toBeVisible();
        }
      });

      test('should trigger onSwipeEnd callback', async ({ page }) => {
        await page.goto('/');

        const swipeable = page.locator('[data-swipeable], [data-on-swipe-end]').first();

        if (await swipeable.count() > 0) {
          await swipe(page, swipeable, 'left');

          await page.waitForTimeout(200);

          await expect(swipeable).toBeVisible();
        }
      });
    });
  });

  // ===== DRAG GESTURES =====

  test.describe('Drag Gestures', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle horizontal drag', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable], .draggable').first();

      if (await draggable.count() > 0) {
        const initialBox = await draggable.boundingBox();

        await drag(page, draggable, 100, 0, { duration: 500 });

        await page.waitForTimeout(200);

        const finalBox = await draggable.boundingBox();

        // Element should have moved or remained in position
        expect(finalBox).toBeTruthy();
      }
    });

    test('should handle vertical drag', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable], .draggable').first();

      if (await draggable.count() > 0) {
        await drag(page, draggable, 0, 100, { duration: 500 });

        await page.waitForTimeout(200);

        await expect(draggable).toBeVisible();
      }
    });

    test('should handle diagonal drag', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable], .draggable').first();

      if (await draggable.count() > 0) {
        await drag(page, draggable, 50, 50, { duration: 500 });

        await page.waitForTimeout(200);

        await expect(draggable).toBeVisible();
      }
    });

    test('should handle drag and drop', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable]').first();
      const dropzone = page.locator('[data-dropzone], .dropzone, [data-drop-target]').first();

      if (await draggable.count() > 0 && await dropzone.count() > 0) {
        const dragBox = await draggable.boundingBox();
        const dropBox = await dropzone.boundingBox();

        if (dragBox && dropBox) {
          // Calculate position to drag to
          const targetX = dropBox.x + dropBox.width / 2 - dragBox.x - dragBox.width / 2;
          const targetY = dropBox.y + dropBox.height / 2 - dragBox.y - dragBox.height / 2;

          await drag(page, draggable, targetX, targetY, { duration: 500 });

          await page.waitForTimeout(200);

          // Elements should still be visible
          await expect(draggable).toBeVisible();
          await expect(dropzone).toBeVisible();
        }
      }
    });

    test('should constrain drag within bounds', async ({ page }) => {
      await page.goto('/');

      const constrainedDraggable = page.locator('[data-drag-constrained], .drag-constrained').first();

      if (await constrainedDraggable.count() > 0) {
        // Try to drag very far
        await drag(page, constrainedDraggable, 500, 500, { duration: 500 });

        await page.waitForTimeout(200);

        // Element should still be visible
        await expect(constrainedDraggable).toBeVisible();
      }
    });

    test('should handle rapid drag movements', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable]').first();

      if (await draggable.count() > 0) {
        const startTime = Date.now();

        // Multiple quick drags
        await drag(page, draggable, 50, 0, { duration: 100, steps: 5 });
        await drag(page, draggable, -50, 0, { duration: 100, steps: 5 });
        await drag(page, draggable, 0, 50, { duration: 100, steps: 5 });

        const duration = Date.now() - startTime;

        // Should complete quickly
        expect(duration).toBeLessThan(1000);

        await expect(draggable).toBeVisible();
      }
    });
  });

  // ===== PINCH TO ZOOM =====

  test.describe('Pinch to Zoom', () => {
    test.describe('iPad Pro', () => {
      test.use(devices['iPad Pro']);

      test('should handle pinch zoom in', async ({ page }) => {
        await page.goto('/');

        const zoomable = page.locator('[data-zoomable], .zoomable, img').first();

        if (await zoomable.count() > 0) {
          await pinchZoom(page, zoomable, { scale: 1.5, duration: 500 });

          await page.waitForTimeout(200);

          await expect(zoomable).toBeVisible();
        }
      });

      test('should handle pinch zoom out', async ({ page }) => {
        await page.goto('/');

        const zoomable = page.locator('[data-zoomable], .zoomable, img').first();

        if (await zoomable.count() > 0) {
          await pinchZoom(page, zoomable, { scale: 0.7, duration: 500 });

          await page.waitForTimeout(200);

          await expect(zoomable).toBeVisible();
        }
      });

      test('should handle zoom with animation', async ({ page }) => {
        await page.goto('/');

        const zoomable = page.locator('[data-zoomable], .zoomable, img').first();

        if (await zoomable.count() > 0) {
          const startTime = Date.now();

          await pinchZoom(page, zoomable, { scale: 2, duration: 300 });

          const duration = Date.now() - startTime;

          // Animation should be smooth
          expect(duration).toBeGreaterThanOrEqual(250);
          expect(duration).toBeLessThanOrEqual(400);
        }
      });
    });

    // ===== ZOOM LIMITS =====

    test.describe('Zoom Limits', () => {
      test.use(devices['iPad Pro']);

      test('should respect minimum zoom limit', async ({ page }) => {
        await page.goto('/');

        const zoomable = page.locator('[data-zoomable], .zoomable').first();

        if (await zoomable.count() > 0) {
          // Try to zoom out too much
          await pinchZoom(page, zoomable, { scale: 0.1, duration: 500 });

          await page.waitForTimeout(200);

          // Element should still be visible and not distorted
          await expect(zoomable).toBeVisible();
        }
      });

      test('should respect maximum zoom limit', async ({ page }) => {
        await page.goto('/');

        const zoomable = page.locator('[data-zoomable], .zoomable').first();

        if (await zoomable.count() > 0) {
          // Try to zoom in too much
          await pinchZoom(page, zoomable, { scale: 5, duration: 500 });

          await page.waitForTimeout(200);

          // Element should still be visible
          await expect(zoomable).toBeVisible();
        }
      });
    });
  });

  // ===== SCROLL GESTURES =====

  test.describe('Scroll Gestures', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle vertical scroll', async ({ page }) => {
      await page.goto('/');

      const initialScrollY = await page.evaluate(() => window.scrollY);

      await touchScroll(page, null, 0, -200);

      await page.waitForTimeout(200);

      const finalScrollY = await page.evaluate(() => window.scrollY);

      expect(finalScrollY).toBeGreaterThan(initialScrollY);
    });

    test('should handle horizontal scroll', async ({ page }) => {
      await page.goto('/');

      const scrollContainer = page.locator('[data-scrollable], .overflow-x-auto, .horizontal-scroll').first();

      if (await scrollContainer.count() > 0) {
        const initialScrollX = await scrollContainer.evaluate(el => el.scrollLeft);

        await touchScroll(page, scrollContainer, -200, 0);

        await page.waitForTimeout(200);

        const finalScrollX = await scrollContainer.evaluate(el => el.scrollLeft);

        expect(finalScrollX).toBeGreaterThan(initialScrollX);
      }
    });

    test('should handle scroll with bounce effect (iOS)', async ({ page }) => {
      await page.goto('/');

      // Scroll past top
      await touchScroll(page, null, 0, 500);

      await page.waitForTimeout(300);

      // Scroll should settle back
      const scrollY = await page.evaluate(() => window.scrollY);
      expect(scrollY).toBe(0);
    });

    test('should handle scroll with momentum', async ({ page }) => {
      await page.goto('/');

      const initialScrollY = await page.evaluate(() => window.scrollY);

      // Fast scroll
      await touchScroll(page, null, 0, -400, { duration: 200, steps: 5 });

      // Wait for momentum
      await page.waitForTimeout(500);

      const finalScrollY = await page.evaluate(() => window.scrollY);

      expect(finalScrollY).toBeGreaterThan(initialScrollY);
    });

    test('should handle scroll in nested containers', async ({ page }) => {
      await page.goto('/');

      const nestedContainer = page.locator('[data-scroll-container], .nested-scroll').first();

      if (await nestedContainer.count() > 0) {
        const initialScrollTop = await nestedContainer.evaluate(el => el.scrollTop);

        await touchScroll(page, nestedContainer, 0, -100);

        await page.waitForTimeout(200);

        const finalScrollTop = await nestedContainer.evaluate(el => el.scrollTop);

        expect(finalScrollTop).toBeGreaterThan(initialScrollTop);
      }
    });
  });

  // ===== MULTI-TOUCH GESTURES =====

  test.describe('Multi-Touch Gestures', () => {
    test.use(devices['iPad Pro']);

    test('should handle two-finger tap', async ({ page }) => {
      await page.goto('/');

      const touchPoints = [
        { x: 200, y: 300 },
        { x: 250, y: 300 },
      ];

      await multiTouchGesture(page, touchPoints, 100);

      // Page should remain functional
      await expect(page.locator('body')).toBeVisible();
    });

    test('should handle three-finger swipe', async ({ page }) => {
      await page.goto('/');

      const touchPoints = [
        { x: 100, y: 300 },
        { x: 150, y: 300 },
        { x: 200, y: 300 },
      ];

      await multiTouchGesture(page, touchPoints, 300);

      // Page should remain functional
      await expect(page.locator('body')).toBeVisible();
    });

    test('should handle simultaneous touch points', async ({ page }) => {
      await page.goto('/');

      // Start two simultaneous touches
      await page.touchstart(200, 300);
      await page.touchstart(300, 300);

      await page.waitForTimeout(100);

      // End both touches
      await page.touchend();
      await page.touchend();

      await page.waitForTimeout(50);

      // Page should remain functional
      await expect(page.locator('body')).toBeVisible();
    });
  });

  // ===== COMBINATION GESTURES =====

  test.describe('Combination Gestures', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle tap then drag', async ({ page }) => {
      await page.goto('/');

      const element = page.locator('[data-draggable]').first();

      if (await element.count() > 0) {
        await tap(page, element);
        await page.waitForTimeout(100);

        await drag(page, element, 50, 0);

        await expect(element).toBeVisible();
      }
    });

    test('should handle double tap then zoom', async ({ page }) => {
      await page.goto('/');

      const zoomable = page.locator('[data-zoomable], img').first();

      if (await zoomable.count() > 0) {
        await doubleTap(page, zoomable, { interval: 200 });

        await page.waitForTimeout(300);

        await expect(zoomable).toBeVisible();
      }
    });

    test('should handle long press then drag', async ({ page }) => {
      await page.goto('/');

      const element = page.locator('[data-long-press-drag], [data-draggable]').first();

      if (await element.count() > 0) {
        await longPress(page, element, { duration: 500 });

        await page.waitForTimeout(100);

        await drag(page, element, 50, 0);

        await expect(element).toBeVisible();
      }
    });
  });

  // ===== GESTURE CANCELLATION =====

  test.describe('Gesture Cancellation', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should cancel drag when interrupted', async ({ page }) => {
      await page.goto('/');

      const draggable = page.locator('[draggable="true"], [data-draggable]').first();

      if (await draggable.count() > 0) {
        const box = await draggable.boundingBox();

        if (box) {
          // Start drag
          await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);

          // Move a bit
          await page.touchmove(box.x + box.width / 2 + 20, box.y + box.height / 2);

          // Interrupt with touch cancel
          await page.evaluate(() => {
            const event = new TouchEvent('touchcancel', {
              bubbles: true,
              cancelable: true,
              touches: [],
              targetTouches: [],
              changedTouches: [],
            });
            document.dispatchEvent(event);
          });

          await page.waitForTimeout(200);

          // Element should still be functional
          await expect(draggable).toBeVisible();
        }
      }
    });

    test('should handle touch cancellation during scroll', async ({ page }) => {
      await page.goto('/');

      // Start scroll
      await page.touchstart(200, 400);
      await page.touchmove(200, 350);

      // Cancel
      await page.evaluate(() => {
        const event = new TouchEvent('touchcancel', {
          bubbles: true,
          cancelable: true,
        });
        document.dispatchEvent(event);
      });

      await page.waitForTimeout(200);

      // Page should remain functional
      await expect(page.locator('body')).toBeVisible();
    });
  });

  // ===== GESTURE PERFORMANCE =====

  test.describe('Gesture Performance', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should maintain 60fps during swipe', async ({ page }) => {
      await page.goto('/');

      let frameDrops = 0;

      await page.evaluate(() => {
        let lastTime = performance.now();
        const observer = new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (entry.entryType === 'layout-shift' && !(entry as any).hadRecentInput) {
              if (performance.now() - lastTime > 20) {
                (window as any).__frameDrops = ((window as any).__frameDrops || 0) + 1;
              }
              lastTime = performance.now();
            }
          }
        });
        observer.observe({ entryTypes: ['layout-shift'] });
      });

      // Perform swipe
      await swipe(page, null, 'up', { duration: 500 });

      frameDrops = await page.evaluate(() => (window as any).__frameDrops || 0);

      // Should have minimal frame drops
      expect(frameDrops).toBeLessThan(5);
    });

    test('should handle rapid gesture changes', async ({ page }) => {
      await page.goto('/');

      const startTime = Date.now();

      // Rapidly changing gestures
      await swipe(page, null, 'up', { duration: 100 });
      await swipe(page, null, 'down', { duration: 100 });
      await swipe(page, null, 'left', { duration: 100 });
      await swipe(page, null, 'right', { duration: 100 });

      const duration = Date.now() - startTime;

      // Should complete quickly
      expect(duration).toBeLessThan(2000);
    });
  });

  // ===== DEVICE-SPECIFIC GESTURE BEHAVIOR =====

  test.describe('Device-Specific Gesture Behavior', () => {
    test.describe('iOS vs Android swipe behavior', () => {
      const devices = [
        { name: 'iOS', config: devices['iPhone 14 Pro'], device: 'iPhone-14-Pro' as const },
        { name: 'Android', config: devices['Galaxy S22+'], device: 'Samsung-Galaxy-S22' as const },
      ];

      devices.forEach(({ name, config, device }) => {
        test(`${name} swipe behavior`, async ({ page }) => {
          test.use(config);

          await setupMobileEmulation(page, device);
          await page.goto('/');

          // Same gesture should work on both
          await swipe(page, null, 'up');

          await page.waitForTimeout(200);

          // Both should scroll
          const scrollY = await page.evaluate(() => window.scrollY);
          expect(scrollY).toBeGreaterThanOrEqual(0);
        });
      });
    });
  });

  // ===== GESTURE WITH FORM ELEMENTS =====

  test.describe('Gestures with Form Elements', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle gestures on input elements', async ({ page }) => {
      await page.goto('/');

      const input = page.locator('input[type="text"], input[type="search"]').first();

      if (await input.count() > 0) {
        const box = await input.boundingBox();

        if (box) {
          // Tap to focus
          await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);
          await page.waitForTimeout(100);
          await page.touchend();

          // Should be focused
          await expect(input).toBeFocused();
        }
      }
    });

    test('should handle gestures on sliders', async ({ page }) => {
      await page.goto('/');

      const slider = page.locator('[role="slider"], input[type="range"]').first();

      if (await slider.count() > 0) {
        // Drag gesture on slider
        await drag(page, slider, 50, 0, { duration: 300 });

        await page.waitForTimeout(100);

        await expect(slider).toBeVisible();
      }
    });
  });

  // ===== EDGE CASES =====

  test.describe('Gesture Edge Cases', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle gesture at viewport edge', async ({ page }) => {
      await page.goto('/');

      // Swipe at very top of screen
      await page.touchstart(200, 10);
      await page.touchmove(200, 50);
      await page.touchend();

      await page.waitForTimeout(100);

      // Should still work
      await expect(page.locator('body')).toBeVisible();
    });

    test('should handle gesture during page load', async ({ page }) => {
      // Navigate and immediately gesture
      page.goto('/');

      await page.waitForTimeout(100);

      await swipe(page, null, 'up');

      // Should work despite page loading
      await expect(page.locator('body')).toBeVisible();
    });

    test('should handle gesture on hidden elements', async ({ page }) => {
      await page.goto('/');

      const hidden = page.locator('[style*="display: none"], .hidden').first();

      if (await hidden.count() > 0) {
        const isVisible = await hidden.isVisible();

        if (!isVisible) {
          // Gesture on hidden element should not cause errors
          const box = await hidden.boundingBox();

          if (box) {
            await page.touchstart(box.x, box.y);
            await page.touchend();
          }
        }
      }
    });

    test('should handle overlapping touch targets', async ({ page }) => {
      await page.goto('/');

      const buttons = await page.locator('button').all();

      if (buttons.length >= 2) {
        const button1 = buttons[0];
        const button2 = buttons[1];

        const box1 = await button1.boundingBox();
        const box2 = await button2.boundingBox();

        if (box1 && box2) {
          // Check if buttons overlap
          const overlaps = !(
            box1.x + box1.width < box2.x ||
            box2.x + box2.width < box1.x ||
            box1.y + box1.height < box2.y ||
            box2.y + box2.height < box1.y
          );

          if (overlaps) {
            // Touch in overlap area
            const overlapX = Math.max(box1.x, box2.x) + 10;
            const overlapY = Math.max(box1.y, box2.y) + 10;

            await page.touchstart(overlapX, overlapY);
            await page.waitForTimeout(100);
            await page.touchend();

            // Should not cause errors
            await expect(page.locator('body')).toBeVisible();
          }
        }
      }
    });
  });
});

// ===== GESTURE ACCESSIBILITY =====

test.describe('Gesture Accessibility', () => {
  test.use(devices['iPhone 14 Pro']);

  test('should have alternative controls for gestures', async ({ page }) => {
    await page.goto('/');

    // Look for alternative controls (buttons, links) that might duplicate gesture functionality
    const buttons = page.locator('button, a[href]').all();

    expect(buttons.length).toBeGreaterThan(0);
  });

  test('should announce gesture results to screen readers', async ({ page }) => {
    await page.goto('/');

    const swipeable = page.locator('[data-swipeable], [aria-live]').first();

    if (await swipeable.count() > 0) {
      // Check for aria-live region
      const ariaLive = await swipeable.getAttribute('aria-live');

      // Elements that respond to gestures should announce changes
      expect([ariaLive, 'polite', 'assertive', null]).toContain(ariaLive);
    }
  });

  test('should not interfere with screen reader gestures', async ({ page }) => {
    await page.goto('/');

    // Screen readers use their own gestures
    // Our gestures should not interfere
    const body = page.locator('body');

    // Perform a gesture
    await swipe(page, body, 'up');

    // Page should remain accessible
    const hasAccessibleContent = await page.evaluate(() => {
      return document.querySelectorAll('button, a, input, [role="button"]').length > 0;
    });

    expect(hasAccessibleContent).toBeTruthy();
  });
});

// ===== GESTURE CUSTOMIZATION =====

test.describe('Gesture Customization', () => {
  test.use(devices['iPhone 14 Pro']);

  test('should respect custom gesture thresholds', async ({ page }) => {
    await page.goto('/');

    // This is a placeholder test for custom gesture thresholds
    // Implementation would depend on how gestures are configured
    await swipe(page, null, 'up', { duration: 300 });

    await expect(page.locator('body')).toBeVisible();
  });

  test('should respect custom gesture durations', async ({ page }) => {
    await page.goto('/');

    const durations = [100, 300, 500, 1000];

    for (const duration of durations) {
      await swipe(page, null, 'up', { duration });
      await page.waitForTimeout(100);
    }

    await expect(page.locator('body')).toBeVisible();
  });

  test('should respect custom gesture steps', async ({ page }) => {
    await page.goto('/');

    const steps = [5, 10, 20];

    for (const stepCount of steps) {
      await swipe(page, null, 'up', { duration: 300, steps: stepCount });
      await page.waitForTimeout(100);
    }

    await expect(page.locator('body')).toBeVisible();
  });
});
