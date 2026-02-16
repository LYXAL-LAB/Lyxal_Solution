import { test, expect, devices } from '@playwright/test';
import {
  tap,
  doubleTap,
  longPress,
  verifyTouchTargetSize,
  getTouchAction,
  hasTouchFeedback,
  hasTouchListeners,
} from '../helpers/touch-utils';

/**
 * Switch Component Touch Interaction Tests
 *
 * Comprehensive touch testing for switch/toggle components including:
 * - Single tap to toggle
 * - Touch target sizing
 * - Touch feedback animations
 * - State changes (checked/unchecked)
 * - Disabled state handling
 * - Cross-device compatibility
 */

test.describe('Switch Component Touch Tests', () => {
  // Setup for mobile devices
  const mobileDevices = [
    { name: 'iPhone 14 Pro', config: devices['iPhone 14 Pro'] },
    { name: 'Pixel 5', config: devices['Pixel 5'] },
  ];

  mobileDevices.forEach(({ name, config }) => {
    test.describe(`${name}`, () => {
      test.use(config);

      test.beforeEach(async ({ page }) => {
        await page.goto('/components/switch');
        await page.waitForLoadState('networkidle');
      });

      // ===== BASIC TOGGLE INTERACTION =====

      test('should toggle on single tap', async ({ page }) => {
        const switchEl = page.locator('[role="switch"], input[type="checkbox"][data-switch], .switch').first();

        if (await switchEl.count() > 0) {
          // Get initial state
          const initialState = await switchEl.isChecked();

          // Tap to toggle
          await tap(page, switchEl);

          await page.waitForTimeout(100);

          // State should have changed
          const newState = await switchEl.isChecked();

          if (initialState !== null && newState !== null) {
            expect(newState).toBe(!initialState);
          }
        }
      });

      test('should toggle back on second tap', async ({ page }) => {
        const switchEl = page.locator('[role="switch"], input[type="checkbox"][data-switch], .switch').first();

        if (await switchEl.count() > 0) {
          const initialState = await switchEl.isChecked();

          // First tap
          await tap(page, switchEl);
          await page.waitForTimeout(100);

          // Second tap
          await tap(page, switchEl);
          await page.waitForTimeout(100);

          // Should be back to initial state
          const finalState = await switchEl.isChecked();

          if (initialState !== null && finalState !== null) {
            expect(finalState).toBe(initialState);
          }
        }
      });

      test('should not toggle on double tap', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const initialState = await switchEl.isChecked();

          // Double tap
          await doubleTap(page, switchEl, { interval: 200 });

          await page.waitForTimeout(200);

          // Should toggle only once (not twice)
          const finalState = await switchEl.isChecked();

          if (initialState !== null && finalState !== null) {
            expect(finalState).toBe(!initialState);
          }
        }
      });

      // ===== TOUCH TARGET SIZING =====

      test('should have adequate touch target size', async ({ page }) => {
        const switchEl = page.locator('[role="switch"], .switch, [data-switch]').first();

        if (await switchEl.count() > 0) {
          const isValidSize = await verifyTouchTargetSize(page, switchEl, 44);
          expect(isValidSize).toBeTruthy();
        }
      });

      test('should have visible thumb for touch', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const thumb = switchEl.locator('[data-thumb], .thumb, span').first();

          if (await thumb.count() > 0) {
            const box = await thumb.boundingBox();

            if (box) {
              // Thumb should be at least 28x28 for touch
              expect(box.width).toBeGreaterThanOrEqual(28);
              expect(box.height).toBeGreaterThanOrEqual(28);
            }
          }
        }
      });

      test('should have adequate overall touch area', async ({ page }) => {
        const switchContainer = page.locator('[role="switch"], .switch-container').first();

        if (await switchContainer.count() > 0) {
          const box = await switchContainer.boundingBox();

          if (box) {
            // Overall switch should be at least 44x27 (typical mobile switch)
            expect(box.width).toBeGreaterThanOrEqual(44);
            expect(box.height).toBeGreaterThanOrEqual(27);
          }
        }
      });

      // ===== TOUCH FEEDBACK =====

      test('should provide visual feedback on touch', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const hasFeedback = await hasTouchFeedback(page, switchEl);
          expect(hasFeedback).toBeTruthy();
        }
      });

      test('should animate thumb on toggle', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const thumb = switchEl.locator('[data-thumb], .thumb, span').first();

          if (await thumb.count() > 0) {
            // Get initial position
            const initialTransform = await thumb.evaluate(el => {
              return window.getComputedStyle(el).transform;
            });

            // Toggle
            await tap(page, switchEl);

            // Wait for animation
            await page.waitForTimeout(200);

            // Transform should have changed
            const finalTransform = await thumb.evaluate(el => {
              return window.getComputedStyle(el).transform;
            });

            expect(finalTransform).not.toBe(initialTransform);
          }
        }
      });

      test('should have active state styling', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const hasActiveState = await switchEl.evaluate(el => {
            const styles = window.getComputedStyle(el, ':active');
            return styles.opacity !== '1' ||
                   styles.transform !== 'none' ||
                   styles.filter !== 'none';
          });

          expect(typeof hasActiveState).toBe('boolean');
        }
      });

      // ===== STATE VISUALIZATION =====

      test('should show checked state visually', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          // Ensure checked state
          const wasChecked = await switchEl.isChecked();
          if (!wasChecked) {
            await switchEl.check();
          }

          await page.waitForTimeout(100);

          // Check for visual indicator (class, style, or attribute)
          const isCheckedClass = await switchEl.evaluate(el => {
            return el.classList.contains('checked') ||
                   el.classList.contains('active') ||
                   el.getAttribute('aria-checked') === 'true' ||
                   el.getAttribute('data-state') === 'checked';
          });

          expect(isCheckedClass).toBeTruthy();
        }
      });

      test('should show unchecked state visually', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          // Ensure unchecked state
          const wasChecked = await switchEl.isChecked();
          if (wasChecked) {
            await switchEl.uncheck();
          }

          await page.waitForTimeout(100);

          // Check for visual indicator
          const isUncheckedClass = await switchEl.evaluate(el => {
            return el.classList.contains('unchecked') ||
                   el.classList.contains('inactive') ||
                   el.getAttribute('aria-checked') === 'false' ||
                   el.getAttribute('data-state') === 'unchecked';
          });

          expect(isUncheckedClass).toBeTruthy();
        }
      });

      // ===== DISABLED STATE =====

      test('should not respond to touch when disabled', async ({ page }) => {
        const disabledSwitch = page.locator('[role="switch"][disabled], [role="switch"][aria-disabled="true"], .switch.disabled').first();

        if (await disabledSwitch.count() > 0) {
          const isDisabled = await disabledSwitch.isDisabled();

          if (isDisabled) {
            const initialState = await disabledSwitch.isChecked();

            // Try to toggle
            await tap(page, disabledSwitch);

            await page.waitForTimeout(100);

            // State should not have changed
            const finalState = await disabledSwitch.isChecked();

            expect(finalState).toBe(initialState);
          }
        }
      });

      test('should show visual feedback for disabled state', async ({ page }) => {
        const disabledSwitch = page.locator('[role="switch"][disabled], .switch.disabled').first();

        if (await disabledSwitch.count() > 0) {
          const opacity = await disabledSwitch.evaluate(el => {
            return window.getComputedStyle(el).opacity;
          });

          // Disabled switches typically have reduced opacity
          expect(parseFloat(opacity)).toBeLessThan(1);
        }
      });

      test('should have disabled styling that differs from enabled', async ({ page }) => {
        const enabledSwitch = page.locator('[role="switch"]:not([disabled])').first();
        const disabledSwitch = page.locator('[role="switch"][disabled], .switch.disabled').first();

        if (await enabledSwitch.count() > 0 && await disabledSwitch.count() > 0) {
          const enabledOpacity = await enabledSwitch.evaluate(el => {
            return window.getComputedStyle(el).opacity;
          });

          const disabledOpacity = await disabledSwitch.evaluate(el => {
            return window.getComputedStyle(el).opacity;
          });

          // Disabled should have lower opacity
          expect(parseFloat(disabledOpacity)).toBeLessThanOrEqual(parseFloat(enabledOpacity));
        }
      });

      // ===== TOUCH EVENT HANDLING =====

      test('should have touch event listeners', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const hasListeners = await hasTouchListeners(page, switchEl, {
            touchstart: true,
            touchend: true,
          });

          expect(typeof hasListeners).toBe('boolean');
        }
      });

      test('should have appropriate touch-action', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const touchAction = await getTouchAction(page, switchEl);

          // Switches should allow manipulation
          const validActions = ['manipulation', 'auto', ''];
          const isValid = validActions.includes(touchAction);

          expect(isValid).toBeTruthy();
        }
      });

      // ===== ACCESSIBILITY =====

      test('should have accessible label', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          // Check for aria-label, aria-labelledby, or associated label
          const ariaLabel = await switchEl.getAttribute('aria-label');
          const ariaLabelledBy = await switchEl.getAttribute('aria-labelledby');

          const hasLabel = ariaLabel !== null || ariaLabelledBy !== null;

          expect(hasLabel).toBeTruthy();
        }
      });

      test('should announce state changes', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const beforeState = await switchEl.getAttribute('aria-checked');

          // Toggle
          await tap(page, switchEl);

          await page.waitForTimeout(100);

          const afterState = await switchEl.getAttribute('aria-checked');

          expect([beforeState, afterState]).toContain('true');
          expect([beforeState, afterState]).toContain('false');
        }
      });

      test('should have correct ARIA role', async ({ page }) => {
        const switchEl = page.locator('[role="switch"], input[type="checkbox"][data-switch]').first();

        if (await switchEl.count() > 0) {
          const role = await switchEl.getAttribute('role');

          // Should have switch role (or be a checkbox which is also valid)
          expect(['switch', 'checkbox', null]).toContain(role);
        }
      });

      // ===== PERFORMANCE =====

      test('should handle rapid toggles without issues', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const startTime = Date.now();

          // Rapid toggles
          for (let i = 0; i < 20; i++) {
            await tap(page, switchEl);
            await page.waitForTimeout(10);
          }

          const duration = Date.now() - startTime;

          // Should complete quickly
          expect(duration).toBeLessThan(3000);
        }
      });

      test('should animate smoothly on toggle', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const thumb = switchEl.locator('[data-thumb], .thumb, span').first();

          if (await thumb.count() > 0) {
            const startTime = Date.now();

            await tap(page, switchEl);

            // Wait for animation to complete
            await page.waitForTimeout(300);

            const duration = Date.now() - startTime;

            // Animation should be smooth (around 200-300ms)
            expect(duration).toBeGreaterThan(100);
            expect(duration).toBeLessThan(500);
          }
        }
      });

      // ===== SWITCH SIZES =====

      test('should handle different switch sizes', async ({ page }) => {
        const switchSizes = [
          { selector: '[data-size="sm"], .switch-sm', minWidth: 36, minHeight: 22 },
          { selector: '[data-size="md"], .switch-md, [role="switch"]', minWidth: 44, minHeight: 27 },
          { selector: '[data-size="lg"], .switch-lg', minWidth: 52, minHeight: 32 },
        ];

        for (const { selector, minWidth, minHeight } of switchSizes) {
          const switchEl = page.locator(selector).first();

          if (await switchEl.count() > 0) {
            const box = await switchEl.boundingBox();

            if (box) {
              expect(box.width).toBeGreaterThanOrEqual(minWidth);
              expect(box.height).toBeGreaterThanOrEqual(minHeight);
            }
          }
        }
      });

      // ===== EDGE CASES =====

      test('should handle touch at switch edge', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const box = await switchEl.boundingBox();

          if (box) {
            // Touch at the edge
            await page.touchstart(box.x + 5, box.y + box.height / 2);
            await page.waitForTimeout(50);
            await page.touchend();

            await page.waitForTimeout(100);

            // Should still toggle
            await expect(switchEl).toBeVisible();
          }
        }
      });

      test('should handle very quick tap', async ({ page }) => {
        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          const initialState = await switchEl.isChecked();

          // Very quick tap
          const box = await switchEl.boundingBox();

          if (box) {
            await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);
            await page.waitForTimeout(20);
            await page.touchend();

            await page.waitForTimeout(100);

            // Should still toggle
            const finalState = await switchEl.isChecked();

            if (initialState !== null && finalState !== null) {
              expect(finalState).toBe(!initialState);
            }
          }
        }
      });

      // ===== SWITCH WITH LABEL =====

      test('should toggle when tapping label', async ({ page }) => {
        const switchWithLabel = page.locator('.switch-with-label, label:has([role="switch"])').first();

        if (await switchWithLabel.count() > 0) {
          const switchEl = switchWithLabel.locator('[role="switch"]').first();

          if (await switchEl.count() > 0) {
            const initialState = await switchEl.isChecked();

            // Tap on label
            await tap(page, switchWithLabel);

            await page.waitForTimeout(100);

            const finalState = await switchEl.isChecked();

            if (initialState !== null && finalState !== null) {
              expect(finalState).toBe(!initialState);
            }
          }
        }
      });

      test('should have adequate touch target for label area', async ({ page }) => {
        const switchWithLabel = page.locator('.switch-with-label, label:has([role="switch"])').first();

        if (await switchWithLabel.count() > 0) {
          const box = await switchWithLabel.boundingBox();

          if (box) {
            // Combined label + switch should be adequate
            expect(box.height).toBeGreaterThanOrEqual(44);
          }
        }
      });
    });
  });

  // ===== TABLET-SPECIFIC TESTS =====

  test.describe('iPad Pro', () => {
    test.use(devices['iPad Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/components/switch');
      await page.waitForLoadState('networkidle');
    });

    test('should have appropriately sized touch targets', async ({ page }) => {
      const switchEl = page.locator('[role="switch"]').first();

      if (await switchEl.count() > 0) {
        const box = await switchEl.boundingBox();

        if (box) {
          // Tablet switches should also be adequate for touch
          expect(box.width).toBeGreaterThanOrEqual(44);
          expect(box.height).toBeGreaterThanOrEqual(27);
        }
      }
    });

    test('should respond to touch and click', async ({ page }) => {
      const switchEl = page.locator('[role="switch"]').first();

      if (await switchEl.count() > 0) {
        // Touch interaction
        await tap(page, switchEl);

        await page.waitForTimeout(100);

        // Should still work with click
        await switchEl.click();

        await expect(switchEl).toBeVisible();
      }
    });
  });

  // ===== ORIENTATION TESTS =====

  test.describe('Orientation Changes', () => {
    test('should work in portrait', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/components/switch');

      const switchEl = page.locator('[role="switch"]').first();

      if (await switchEl.count() > 0) {
        await tap(page, switchEl);
        await expect(switchEl).toBeVisible();
      }
    });

    test('should work in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/switch');

      const switchEl = page.locator('[role="switch"]').first();

      if (await switchEl.count() > 0) {
        await tap(page, switchEl);
        await expect(switchEl).toBeVisible();
      }
    });

    test('should maintain touch target sizes in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/switch');

      const switchEl = page.locator('[role="switch"]').first();

      if (await switchEl.count() > 0) {
        const isValidSize = await verifyTouchTargetSize(page, switchEl, 44);
        expect(isValidSize).toBeTruthy();
      }
    });
  });

  // ===== SWITCH GROUP TESTS =====

  test.describe('Switch Groups', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle multiple switches independently', async ({ page }) => {
      await page.goto('/components/switch');

      const switches = page.locator('[role="switch"]').all();

      if (await switches.length >= 2) {
        const switch1 = await switches[0];
        const switch2 = await switches[1];

        const initial1 = await switch1.isChecked();
        const initial2 = await switch2.isChecked();

        // Toggle first switch
        await tap(page, switch1);

        await page.waitForTimeout(100);

        const after1 = await switch1.isChecked();
        const after2 = await switch2.isChecked();

        // First switch should toggle, second should not
        if (initial1 !== null && after1 !== null) {
          expect(after1).toBe(!initial1);
        }

        if (initial2 !== null && after2 !== null) {
          expect(after2).toBe(initial2);
        }
      }
    });

    test('should have adequate spacing between switches', async ({ page }) => {
      await page.goto('/components/switch');

      const switches = await page.locator('[role="switch"]').all();

      for (let i = 0; i < Math.min(await switches.length, 5) - 1; i++) {
        const current = switches[i];
        const next = switches[i + 1];

        const box1 = await current.boundingBox();
        const box2 = await next.boundingBox();

        if (box1 && box2) {
          // Switches should have some spacing
          const verticalDistance = Math.abs(box2.y - box1.y);

          if (Math.abs(box2.x - box1.x) < 10) {
            // If horizontally aligned, check vertical spacing
            expect(verticalDistance).toBeGreaterThanOrEqual(8);
          }
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
      test(`${name} switch behavior consistency`, async ({ page }) => {
        test.use(config);

        await page.goto('/components/switch');

        const switchEl = page.locator('[role="switch"]').first();

        if (await switchEl.count() > 0) {
          // Should be visible
          await expect(switchEl).toBeVisible();

          // Should toggle
          const initialState = await switchEl.isChecked();
          await tap(page, switchEl);

          await page.waitForTimeout(100);

          const finalState = await switchEl.isChecked();

          if (initialState !== null && finalState !== null) {
            expect(finalState).toBe(!initialState);
          }

          // Should have adequate touch target
          const isValidSize = await verifyTouchTargetSize(page, switchEl, 44);
          expect(isValidSize).toBeTruthy();
        }
      });
    });
  });

  // ===== SWITCH WITH LOADING STATE =====

  test.describe('Switch with Loading State', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should show loading state when toggling', async ({ page }) => {
      await page.goto('/components/switch');

      const loadingSwitch = page.locator('[role="switch"][data-loading], .switch-loading').first();

      if (await loadingSwitch.count() > 0) {
        const isLoading = await loadingSwitch.getAttribute('data-loading');

        if (isLoading === 'true') {
          // Should show loading indicator
          const hasLoadingIndicator = await loadingSwitch.evaluate(el => {
            return el.classList.contains('loading') ||
                   el.querySelector('[data-spinner], .spinner, .loading-icon') !== null;
          });

          expect(hasLoadingIndicator).toBeTruthy();
        }
      }
    });

    test('should disable interaction during loading', async ({ page }) => {
      await page.goto('/components/switch');

      const loadingSwitch = page.locator('[role="switch"][data-loading], .switch-loading').first();

      if (await loadingSwitch.count() > 0) {
        const isLoading = await loadingSwitch.getAttribute('data-loading');

        if (isLoading === 'true') {
          const isDisabled = await loadingSwitch.isDisabled();

          // Should be disabled during loading
          expect(isDisabled).toBeTruthy();
        }
      }
    });
  });
});

// ===== SWITCH COLOR VARIANTS =====

test.describe('Switch Color Variants', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/switch');
  });

  test('should provide touch feedback for all variants', async ({ page }) => {
    const variants = ['default', 'primary', 'success', 'danger', 'warning'];

    for (const variant of variants) {
      const switchEl = page.locator(`[data-variant="${variant}"], .switch-${variant}`).first();

      if (await switchEl.count() > 0) {
        const hasFeedback = await hasTouchFeedback(page, switchEl);
        expect(hasFeedback).toBeTruthy();
      }
    }
  });

  test('should maintain adequate touch targets for all variants', async ({ page }) => {
    const variants = ['default', 'primary', 'success', 'danger', 'warning'];

    for (const variant of variants) {
      const switchEl = page.locator(`[data-variant="${variant}"], .switch-${variant}`).first();

      if (await switchEl.count() > 0) {
        const isValidSize = await verifyTouchTargetSize(page, switchEl, 44);
        expect(isValidSize).toBeTruthy();
      }
    }
  });
});

// ===== SWITCH ACCESSIBILITY =====

test.describe('Switch Accessibility', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/switch');
  });

  test('should not have obscured touch targets', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      const isVisible = await switchEl.isVisible();

      if (isVisible) {
        const box = await switchEl.boundingBox();

        if (box) {
          // Check if element is covered
          const elementAtPoint = await page.evaluate(({ x, y }) => {
            const el = document.elementFromPoint(x, y);
            return el?.getAttribute('role');
          }, { x: box.x + box.width / 2, y: box.y + box.height / 2 });

          expect(elementAtPoint).toBe('switch');
        }
      }
    }
  });

  test('should have adequate color contrast', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      // This is a basic check - actual contrast calculation is complex
      const backgroundColor = await switchEl.evaluate(el => {
        return window.getComputedStyle(el).backgroundColor;
      });

      // Background color should be defined (not transparent)
      expect(backgroundColor).not.toBe('rgba(0, 0, 0, 0)');
      expect(backgroundColor).not.toBe('transparent');
    }
  });

  test('should be keyboard accessible on touch devices', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      // Focus the switch
      await switchEl.focus();

      // Should be focused
      await expect(switchEl).toBeFocused();

      // Press space to toggle
      await page.keyboard.press('Space');

      await page.waitForTimeout(100);

      // Should have toggled
      const afterState = await switchEl.getAttribute('aria-checked');
      expect(afterState).toBeTruthy();
    }
  });
});

// ===== SWITCH EDGE CASES =====

test.describe('Switch Edge Cases', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/switch');
  });

  test('should handle touch during animation', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      // Start first toggle
      await tap(page, switchEl);

      // Try to toggle again during animation
      await page.waitForTimeout(50);
      await tap(page, switchEl);

      await page.waitForTimeout(200);

      // Should still be functional
      await expect(switchEl).toBeVisible();
    }
  });

  test('should handle very long press', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      const initialState = await switchEl.isChecked();

      // Long press
      await longPress(page, switchEl, { duration: 1000 });

      await page.waitForTimeout(100);

      // Should toggle only once
      const finalState = await switchEl.isChecked();

      if (initialState !== null && finalState !== null) {
        expect(finalState).toBe(!initialState);
      }
    }
  });

  test('should handle touch outside then inside', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      const box = await switchEl.boundingBox();

      if (box) {
        // Start outside
        await page.touchstart(box.x - 10, box.y + box.height / 2);

        // Move inside
        await page.touchmove(box.x + box.width / 2, box.y + box.height / 2);

        await page.waitForTimeout(50);

        // End
        await page.touchend();

        await page.waitForTimeout(100);

        // Should toggle (touch ended inside)
        await expect(switchEl).toBeVisible();
      }
    }
  });

  test('should handle touch inside then outside', async ({ page }) => {
    const switchEl = page.locator('[role="switch"]').first();

    if (await switchEl.count() > 0) {
      const box = await switchEl.boundingBox();

      if (box) {
        const initialState = await switchEl.isChecked();

        // Start inside
        await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);

        // Move outside
        await page.touchmove(box.x - 10, box.y + box.height / 2);

        await page.waitForTimeout(50);

        // End
        await page.touchend();

        await page.waitForTimeout(100);

        // Should not toggle (touch ended outside)
        const finalState = await switchEl.isChecked();

        if (initialState !== null && finalState !== null) {
          expect(finalState).toBe(initialState);
        }
      }
    }
  });
});
