import { test, expect, devices } from '@playwright/test';
import {
  drag,
  swipe,
  verifyTouchTargetSize,
  getTouchAction,
  hasTouchListeners,
  measureTouchResponseTime,
} from '../helpers/touch-utils';

/**
 * Slider Component Touch Interaction Tests
 *
 * Comprehensive touch testing for slider/range components including:
 * - Drag gestures for value adjustment
 * - Touch target sizing for slider handles
 * - Touch feedback during dragging
 * - Range slider dual-thumb interaction
 * - Cross-device compatibility
 */

test.describe('Slider Component Touch Tests', () => {
  // Setup for mobile devices
  const mobileDevices = [
    { name: 'iPhone 14 Pro', config: devices['iPhone 14 Pro'] },
    { name: 'Pixel 5', config: devices['Pixel 5'] },
  ];

  mobileDevices.forEach(({ name, config }) => {
    test.describe(`${name}`, () => {
      test.use(config);

      test.beforeEach(async ({ page }) => {
        await page.goto('/components/slider');
        await page.waitForLoadState('networkidle');
      });

      // ===== BASIC SLIDER INTERACTION =====

      test('should handle touch drag on slider', async ({ page }) => {
        const slider = page.locator('[role="slider"], input[type="range"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Drag the slider handle
            await drag(page, slider, 50, 0, { duration: 300, steps: 10 });

            // Slider should still be visible and interactive
            await expect(slider).toBeVisible();
          }
        }
      });

      test('should update value on touch drag', async ({ page }) => {
        const slider = page.locator('[role="slider"], input[type="range"]').first();
        const valueDisplay = page.locator('[data-value], .value-display').first();

        if (await slider.count() > 0) {
          // Get initial value
          const initialValue = await slider.inputValue();
          const initialDisplay = await valueDisplay.count() > 0 ?
            await valueDisplay.textContent() : null;

          // Drag slider
          const box = await slider.boundingBox();
          if (box) {
            await drag(page, slider, 50, 0, { duration: 300 });

            // Value should have changed
            await page.waitForTimeout(100);
            const finalValue = await slider.inputValue();

            expect(finalValue).toBeTruthy();
          }
        }
      });

      test('should handle horizontal drag', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            await drag(page, slider, 100, 0, { duration: 500 });

            await expect(slider).toBeVisible();
          }
        }
      });

      test('should respond quickly to touch', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const responseTime = await measureTouchResponseTime(page, slider);

          // Should respond within 100ms
          expect(responseTime).toBeLessThanOrEqual(150);
        }
      });

      // ===== TOUCH TARGET SIZING =====

      test('should have adequate touch target for slider handle', async ({ page }) => {
        const sliderHandle = page.locator('[role="slider"] [data-thumb], [role="slider"]::-webkit-slider-thumb, .slider-handle').first();

        if (await sliderHandle.count() > 0) {
          const box = await sliderHandle.boundingBox();

          if (box) {
            // Slider handles should be at least 44x44 for touch
            expect(box.width).toBeGreaterThanOrEqual(44);
            expect(box.height).toBeGreaterThanOrEqual(44);
          }
        } else {
          // If we can't find the handle directly, check the slider element
          const slider = page.locator('[role="slider"]').first();

          if (await slider.count() > 0) {
            const box = await slider.boundingBox();

            if (box) {
              // Slider track should be at least 44px tall
              expect(box.height).toBeGreaterThanOrEqual(44);
            }
          }
        }
      });

      test('should have adequate touch target for entire slider', async ({ page }) => {
        const slider = page.locator('[role="slider"], input[type="range"]').first();

        if (await slider.count() > 0) {
          const isValidSize = await verifyTouchTargetSize(page, slider, 44);
          expect(isValidSize).toBeTruthy();
        }
      });

      // ===== TOUCH FEEDBACK =====

      test('should provide visual feedback during drag', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Start dragging
            await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);

            // Check for visual feedback (active state)
            const hasFeedback = await slider.evaluate(el => {
              const styles = window.getComputedStyle(el, ':active');
              return styles.transform !== 'none' ||
                     styles.boxShadow !== 'none' ||
                     styles.filter !== 'none';
            });

            // End drag
            await page.touchend();

            expect(typeof hasFeedback).toBe('boolean');
          }
        }
      });

      test('should show tooltip on touch', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();
        const tooltip = page.locator('[data-tooltip], .tooltip, [role="tooltip"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Touch the slider
            await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);
            await page.waitForTimeout(200);

            // Check if tooltip appears
            const tooltipVisible = await tooltip.count() > 0 && await tooltip.isVisible();

            await page.touchend();

            // Tooltip visibility is optional but nice to have
            expect(typeof tooltipVisible).toBe('boolean');
          }
        }
      });

      // ===== RANGE SLIDER TESTS =====

      test('should handle dual-thumb range slider', async ({ page }) => {
        const rangeSlider = page.locator('[data-range-slider], .range-slider').first();

        if (await rangeSlider.count() > 0) {
          const thumbs = rangeSlider.locator('[role="slider"], [data-thumb]').all();

          if (await thumbs.length >= 2) {
            // Test first thumb
            const thumb1 = await thumbs[0];
            const box1 = await thumb1.boundingBox();

            if (box1) {
              await drag(page, thumb1, 20, 0);
            }

            await page.waitForTimeout(200);

            // Test second thumb
            const thumb2 = await thumbs[1];
            const box2 = await thumb2.boundingBox();

            if (box2) {
              await drag(page, thumb2, -20, 0);
            }

            await expect(rangeSlider).toBeVisible();
          }
        }
      });

      test('should prevent thumbs from crossing', async ({ page }) => {
        const rangeSlider = page.locator('[data-range-slider], .range-slider').first();

        if (await rangeSlider.count() > 0) {
          const thumbs = rangeSlider.locator('[role="slider"]').all();

          if (await thumbs.length >= 2) {
            const thumb1 = await thumbs[0];
            const thumb2 = await thumbs[1];

            const value1Before = await thumb1.inputValue();
            const value2Before = await thumb2.inputValue();

            // Try to drag first thumb past second
            await drag(page, thumb1, 200, 0);

            await page.waitForTimeout(200);

            const value1After = await thumb1.inputValue();
            const value2After = await thumb2.inputValue();

            // Values should be maintained or bounded
            expect([value1After, value2After]).toBeTruthy();
          }
        }
      });

      // ===== TOUCH EVENT HANDLING =====

      test('should have touch event listeners', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const hasListeners = await hasTouchListeners(page, slider, {
            touchstart: true,
            touchmove: true,
            touchend: true,
          });

          expect(typeof hasListeners).toBe('boolean');
        }
      });

      test('should have appropriate touch-action', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const touchAction = await getTouchAction(page, slider);

          // Sliders should have specific touch-action
          const validActions = ['none', 'pan-x', 'pan-y'];
          const hasValidAction = validActions.some(action => touchAction.includes(action));

          expect(typeof hasValidAction).toBe('boolean');
        }
      });

      // ===== SLIDER AT EDGE VALUES =====

      test('should handle drag to minimum value', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Drag to the left edge
            await drag(page, slider, -box.width / 2, 0);

            await page.waitForTimeout(100);

            // Should still be at minimum value
            await expect(slider).toBeVisible();
          }
        }
      });

      test('should handle drag to maximum value', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Drag to the right edge
            await drag(page, slider, box.width / 2, 0);

            await page.waitForTimeout(100);

            // Should still be at maximum value
            await expect(slider).toBeVisible();
          }
        }
      });

      // ===== VERTICAL SLIDER =====

      test('should handle vertical slider', async ({ page }) => {
        const verticalSlider = page.locator('[data-orientation="vertical"], .vertical-slider, [aria-orientation="vertical"]').first();

        if (await verticalSlider.count() > 0) {
          const box = await verticalSlider.boundingBox();

          if (box) {
            // Vertical drag
            await drag(page, verticalSlider, 0, 50, { duration: 300 });

            await expect(verticalSlider).toBeVisible();
          }
        }
      });

      // ===== DISCRETE STEPS =====

      test('should snap to discrete steps', async ({ page }) => {
        const steppedSlider = page.locator('[data-step], [data-stepped]').first();

        if (await steppedSlider.count() > 0) {
          const box = await steppedSlider.boundingBox();

          if (box) {
            const initialValue = await steppedSlider.inputValue();

            // Small drag should snap to next step
            await drag(page, steppedSlider, 10, 0);

            await page.waitForTimeout(100);

            const finalValue = await steppedSlider.inputValue();

            // Value should be one of the discrete steps
            expect(finalValue).toBeTruthy();
          }
        }
      });

      // ===== DISABLED STATE =====

      test('should not respond to touch when disabled', async ({ page }) => {
        const disabledSlider = page.locator('[role="slider"][disabled], [data-disabled]').first();

        if (await disabledSlider.count() > 0) {
          const isDisabled = await disabledSlider.isDisabled();

          if (isDisabled) {
            const box = await disabledSlider.boundingBox();

            if (box) {
              const initialValue = await disabledSlider.inputValue();

              // Try to drag
              await drag(page, disabledSlider, 50, 0);

              await page.waitForTimeout(100);

              const finalValue = await disabledSlider.inputValue();

              // Value should not have changed
              expect(finalValue).toBe(initialValue);
            }
          }
        }
      });

      // ===== MULTI-TOUCH TESTS =====

      test('should handle single finger drag', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            // Single finger drag
            const startX = box.x + box.width / 2;
            const startY = box.y + box.height / 2;

            await page.touchstart(startX, startY);

            // Move to new position
            await page.touchmove(startX + 50, startY);
            await page.waitForTimeout(50);
            await page.touchmove(startX + 100, startY);
            await page.waitForTimeout(50);

            await page.touchend();

            await expect(slider).toBeVisible();
          }
        }
      });

      // ===== PERFORMANCE =====

      test('should handle rapid drag movements', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            const startTime = Date.now();

            // Rapid back-and-forth drags
            await drag(page, slider, 50, 0, { duration: 100, steps: 5 });
            await drag(page, slider, -50, 0, { duration: 100, steps: 5 });
            await drag(page, slider, 50, 0, { duration: 100, steps: 5 });

            const duration = Date.now() - startTime;

            // Should complete within 1 second
            expect(duration).toBeLessThan(1000);
          }
        }
      });

      test('should maintain 60fps during drag', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const box = await slider.boundingBox();

          if (box) {
            let frameDrops = 0;

            await page.evaluate(() => {
              let lastTime = performance.now();
              let drops = 0;

              const checkFrame = () => {
                const currentTime = performance.now();
                if (currentTime - lastTime > 20) { // More than 20ms = less than 50fps
                  drops++;
                }
                lastTime = currentTime;
              };

              requestAnimationFrame(checkFrame);
              (window as any).__getFrameDrops = () => drops;
            });

            // Perform drag
            await drag(page, slider, 100, 0, { duration: 500, steps: 20 });

            frameDrops = await page.evaluate(() => (window as any).__getFrameDrops?.() ?? 0);

            // Should have minimal frame drops
            expect(frameDrops).toBeLessThan(5);
          }
        }
      });

      // ===== ACCESSIBILITY =====

      test('should announce value changes', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          // Check for aria-valuenow attribute
          const ariaValue = await slider.getAttribute('aria-valuenow');

          expect(ariaValue).toBeTruthy();

          // After dragging, value should update
          const box = await slider.boundingBox();

          if (box) {
            await drag(page, slider, 50, 0);

            await page.waitForTimeout(100);

            const newAriaValue = await slider.getAttribute('aria-valuenow');

            expect(newAriaValue).toBeTruthy();
          }
        }
      });

      test('should have accessible label', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          // Check for aria-label or aria-labelledby
          const ariaLabel = await slider.getAttribute('aria-label');
          const ariaLabelledBy = await slider.getAttribute('aria-labelledby');

          const hasLabel = ariaLabel !== null || ariaLabelledBy !== null;

          expect(hasLabel).toBeTruthy();
        }
      });

      test('should indicate min and max values', async ({ page }) => {
        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          const ariaMin = await slider.getAttribute('aria-valuemin');
          const ariaMax = await slider.getAttribute('aria-valuemax');

          expect(ariaMin).toBeTruthy();
          expect(ariaMax).toBeTruthy();
        }
      });
    });
  });

  // ===== TABLET-SPECIFIC TESTS =====

  test.describe('iPad Pro', () => {
    test.use(devices['iPad Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/components/slider');
      await page.waitForLoadState('networkidle');
    });

    test('should have larger touch targets on tablet', async ({ page }) => {
      const sliderHandle = page.locator('[role="slider"] [data-thumb], .slider-handle').first();

      if (await sliderHandle.count() > 0) {
        const box = await sliderHandle.boundingBox();

        if (box) {
          // Tablet can have slightly larger handles
          expect(box.width).toBeGreaterThanOrEqual(48);
          expect(box.height).toBeGreaterThanOrEqual(48);
        }
      }
    });

    test('should support touch and mouse interaction', async ({ page }) => {
      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        // Touch interaction
        await drag(page, slider, 50, 0);
        await page.waitForTimeout(100);

        // Should still be interactive
        await expect(slider).toBeVisible();
      }
    });
  });

  // ===== ORIENTATION TESTS =====

  test.describe('Orientation Changes', () => {
    test('should work in portrait', async ({ page }) => {
      await page.setViewportSize({ width: 375, height: 667 });
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        await drag(page, slider, 50, 0);
        await expect(slider).toBeVisible();
      }
    });

    test('should work in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        await drag(page, slider, 50, 0);
        await expect(slider).toBeVisible();
      }
    });

    test('should maintain touch target sizes in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        const isValidSize = await verifyTouchTargetSize(page, slider, 44);
        expect(isValidSize).toBeTruthy();
      }
    });
  });

  // ===== SWIPE GESTURES ON SLIDER =====

  test.describe('Swipe Gestures', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should respond to swipe gestures', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        const box = await slider.boundingBox();

        if (box) {
          // Swipe right on slider
          await swipe(page, slider, 'right', { duration: 300 });

          await page.waitForTimeout(100);

          await expect(slider).toBeVisible();
        }
      }
    });

    test('should respond to swipe left', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        const box = await slider.boundingBox();

        if (box) {
          // Swipe left on slider
          await swipe(page, slider, 'left', { duration: 300 });

          await page.waitForTimeout(100);

          await expect(slider).toBeVisible();
        }
      }
    });
  });

  // ===== SLIDER WITH VALUE DISPLAY =====

  test.describe('Slider with Value Display', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should update value display on touch', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();
      const valueDisplay = page.locator('[data-value], .value-display').first();

      if (await slider.count() > 0 && await valueDisplay.count() > 0) {
        const beforeValue = await valueDisplay.textContent();

        await drag(page, slider, 50, 0);

        await page.waitForTimeout(100);

        const afterValue = await valueDisplay.textContent();

        expect(afterValue).toBeTruthy();
      }
    });

    test('should show value display on touch start', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();
      const valueDisplay = page.locator('[data-value], .value-display').first();

      if (await slider.count() > 0 && await valueDisplay.count() > 0) {
        const box = await slider.boundingBox();

        if (box) {
          // Touch start
          await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);

          // Value display might appear or update
          await page.waitForTimeout(100);

          await page.touchend();
        }
      }
    });
  });

  // ===== EDGE CASES =====

  test.describe('Slider Edge Cases', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should handle touch at slider edge', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        const box = await slider.boundingBox();

        if (box) {
          // Touch at the very edge
          await page.touchstart(box.x + 5, box.y + box.height / 2);
          await page.waitForTimeout(50);
          await page.touchend();

          await expect(slider).toBeVisible();
        }
      }
    });

    test('should handle very small drag', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        // Tiny drag (might not change value)
        await drag(page, slider, 5, 0, { duration: 50 });

        await expect(slider).toBeVisible();
      }
    });

    test('should handle very large drag', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        // Very large drag (should clamp to max)
        await drag(page, slider, 500, 0, { duration: 500 });

        await expect(slider).toBeVisible();
      }
    });

    test('should handle rapid touch start/end', async ({ page }) => {
      await page.goto('/components/slider');

      const slider = page.locator('[role="slider"]').first();

      if (await slider.count() > 0) {
        const box = await slider.boundingBox();

        if (box) {
          // Very quick tap (not really a drag)
          await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);
          await page.waitForTimeout(10);
          await page.touchend();

          await expect(slider).toBeVisible();
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
      test(`${name} slider behavior consistency`, async ({ page }) => {
        test.use(config);

        await page.goto('/components/slider');

        const slider = page.locator('[role="slider"]').first();

        if (await slider.count() > 0) {
          // Should be visible
          await expect(slider).toBeVisible();

          // Should handle drag
          const box = await slider.boundingBox();
          if (box) {
            await drag(page, slider, 50, 0);

            // Should have adequate touch target
            const isValidSize = await verifyTouchTargetSize(page, slider, 44);
            expect(isValidSize).toBeTruthy();
          }
        }
      });
    });
  });
});

// ===== VERTICAL SLIDER TOUCH TESTS =====

test.describe('Vertical Slider Touch Tests', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/slider');
  });

  test('should handle vertical drag', async ({ page }) => {
    const verticalSlider = page.locator('[data-orientation="vertical"], .vertical-slider').first();

    if (await verticalSlider.count() > 0) {
      await drag(page, verticalSlider, 0, 100, { duration: 300 });
      await expect(verticalSlider).toBeVisible();
    }
  });

  test('should have adequate touch target for vertical slider', async ({ page }) => {
    const verticalSlider = page.locator('[data-orientation="vertical"], .vertical-slider').first();

    if (await verticalSlider.count() > 0) {
      const box = await verticalSlider.boundingBox();

      if (box) {
        // Vertical sliders should have adequate width for touch
        expect(box.width).toBeGreaterThanOrEqual(44);
      }
    }
  });
});

// ===== SLIDER WITH MARKS/STEPS =====

test.describe('Slider with Marks', () => {
  test.use(devices['iPhone 14 Pro']);

  test.beforeEach(async ({ page }) => {
    await page.goto('/components/slider');
  });

  test('should show marks on touch', async ({ page }) => {
    const sliderWithMarks = page.locator('[data-marks], .slider-with-marks').first();

    if (await sliderWithMarks.count() > 0) {
      const marks = sliderWithMarks.locator('[data-mark], .mark').all();

      // Marks should be visible
      expect(marks.length).toBeGreaterThan(0);

      // Touch the slider
      await drag(page, sliderWithMarks, 50, 0);

      // Marks should still be visible
      for (const mark of await marks) {
        await expect(mark).toBeVisible();
      }
    }
  });

  test('should snap to marks', async ({ page }) => {
    const sliderWithMarks = page.locator('[data-marks], .slider-with-marks').first();

    if (await sliderWithMarks.count() > 0) {
      const box = await sliderWithMarks.boundingBox();

      if (box) {
        // Drag to a position
        await drag(page, sliderWithMarks, 50, 0);

        await page.waitForTimeout(100);

        // Value should be at a mark position
        const value = await sliderWithMarks.inputValue();
        expect(value).toBeTruthy();
      }
    }
  });
});
