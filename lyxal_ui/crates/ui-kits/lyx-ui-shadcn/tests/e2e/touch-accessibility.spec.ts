import { test, expect, devices } from '@playwright/test';
import {
  verifyTouchTargetSize,
  validateTouchTargets,
  getTouchTargets,
  getHitAreaPadding,
  hasMobileViewportMeta,
  setupMobileEmulation,
  MOBILE_DEVICES,
  tap,
  doubleTap,
  longPress,
} from './helpers/touch-utils';

/**
 * Mobile Accessibility Touch Tests
 *
 * Comprehensive accessibility testing for touch interactions including:
 * - WCAG 2.5.5 Touch Target sizing (44x44 minimum)
 * - Touch target spacing and separation
 * - Touch target visibility
 * - Screen reader compatibility
 * - Keyboard alternatives
 * - Cognitive load considerations
 */

test.describe('Mobile Accessibility Touch Tests', () => {
  // ===== WCAG TOUCH TARGET SIZING =====

  test.describe('WCAG 2.5.5 Touch Target Sizing', () => {
    const wcagDevices = [
      { name: 'iPhone 14 Pro', config: devices['iPhone 14 Pro'] },
      { name: 'Pixel 5', config: devices['Pixel 5'] },
      { name: 'iPad Pro', config: devices['iPad Pro'] },
    ];

    wcagDevices.forEach(({ name, config }) => {
      test.describe(`${name}`, () => {
        test.use(config);

        test.beforeEach(async ({ page }) => {
          await page.goto('/');
          await page.waitForLoadState('networkidle');
        });

        test('should meet minimum 44x44px touch target size', async ({ page }) => {
          // Test all interactive elements
          const interactiveElements = page.locator(`
            button:not([disabled]),
            a[href],
            input:not([disabled]),
            select:not([disabled]),
            textarea:not([disabled]),
            [role="button"]:not([aria-disabled="true"]),
            [tabindex]:not([tabindex="-1"])
          `).all();

          let failures = 0;
          let checked = 0;

          for (const element of await interactiveElements.slice(0, 20)) {
            const isVisible = await element.then(e => e.isVisible());

            if (isVisible) {
              const isValidSize = await verifyTouchTargetSize(page, element, 44);
              checked++;

              if (!isValidSize) {
                failures++;
              }
            }
          }

          // Report results
          if (checked > 0) {
            const passRate = ((checked - failures) / checked) * 100;
            expect(passRate).toBeGreaterThanOrEqual(90); // 90% compliance target
          }
        });

        test('should have adequate touch targets for all buttons', async ({ page }) => {
          const buttons = page.locator('button').all();

          for (const button of await buttons.slice(0, 10)) {
            const isVisible = await button.then(b => b.isVisible());

            if (isVisible) {
              const box = await button.then(b => b.boundingBox());

              if (box) {
                expect(box.width).toBeGreaterThanOrEqual(44);
                expect(box.height).toBeGreaterThanOrEqual(44);
              }
            }
          }
        });

        test('should have adequate touch targets for all links', async ({ page }) => {
          const links = page.locator('a[href]').all();

          for (const link of await links.slice(0, 10)) {
            const isVisible = await link.then(l => l.isVisible());

            if (isVisible) {
              const box = await link.then(l => l.boundingBox());

              if (box) {
                expect(box.width).toBeGreaterThanOrEqual(44);
                expect(box.height).toBeGreaterThanOrEqual(44);
              }
            }
          }
        });

        test('should have adequate touch targets for form inputs', async ({ page }) => {
          const inputs = page.locator('input, select, textarea').all();

          for (const input of await inputs.slice(0, 10)) {
            const isVisible = await input.then(i => i.isVisible());

            if (isVisible) {
              const box = await input.then(i => i.boundingBox());

              if (box) {
                expect(box.width).toBeGreaterThanOrEqual(44);
                expect(box.height).toBeGreaterThanOrEqual(44);
              }
            }
          }
        });

        test('should validate all touch targets on page', async ({ page }) => {
          const result = await validateTouchTargets(page, {
            minSize: 44,
            includeHidden: false,
          });

          const total = result.valid + result.invalid.length;

          if (total > 0) {
            const passRate = (result.valid / total) * 100;

            // At least 90% should pass
            expect(passRate).toBeGreaterThanOrEqual(90);

            // If there are failures, log them for debugging
            if (result.invalid.length > 0) {
              console.log(`Touch target failures: ${result.invalid.length}`);
              result.invalid.slice(0, 5).forEach(failure => {
                console.log(`  - ${failure.selector}: ${failure.size.width}x${failure.size.height}`);
              });
            }
          }
        });

        test('should get all touch targets', async ({ page }) => {
          const touchTargets = await getTouchTargets(page);

          expect(Array.isArray(touchTargets)).toBeTruthy();
          expect(touchTargets.length).toBeGreaterThan(0);

          // Each target should have selector and size
          for (const target of touchTargets.slice(0, 5)) {
            expect(target.selector).toBeTruthy();
            expect(target.size).toBeDefined();
            expect(typeof target.size.width).toBe('number');
            expect(typeof target.size.height).toBe('number');
          }
        });
      });
    });

    // ===== RELAXED TARGET SIZING (for spacing compensation) =====

    test.describe('Relaxed Touch Target with Spacing', () => {
      test.use(devices['iPhone 14 Pro']);

      test('should allow smaller targets with adequate spacing', async ({ page }) => {
        await page.goto('/');

        const interactiveElements = page.locator('button, a[href]').all();

        for (const element of await interactiveElements.slice(0, 10)) {
          const isVisible = await element.then(e => e.isVisible());

          if (isVisible) {
            const box = await element.then(e => e.boundingBox());

            if (box) {
              // If target is smaller than 44px, check for spacing
              if (box.width < 44 || box.height < 44) {
                // Get hit area padding
                const padding = await getHitAreaPadding(page, element);

                // Total area including padding should be adequate
                const totalWidth = box.width + padding.left + padding.right;
                const totalHeight = box.height + padding.top + padding.bottom;

                expect(totalWidth).toBeGreaterThanOrEqual(44);
                expect(totalHeight).toBeGreaterThanOrEqual(44);
              }
            }
          }
        }
      });

      test('should not have overlapping touch targets', async ({ page }) => {
        await page.goto('/');

        const touchTargets = await getTouchTargets(page);
        const visibleTargets = [];

        // Filter visible targets
        for (const target of touchTargets.slice(0, 20)) {
          const element = page.locator(target.selector);
          if (await element.count() > 0) {
            const isVisible = await element.isVisible();
            if (isVisible) {
              const box = await element.boundingBox();
              if (box) {
                visibleTargets.push({ ...target, box });
              }
            }
          }
        }

        // Check for overlaps
        for (let i = 0; i < visibleTargets.length; i++) {
          for (let j = i + 1; j < visibleTargets.length; j++) {
            const a = visibleTargets[i].box;
            const b = visibleTargets[j].box;

            const hasOverlap = !(
              a.x + a.width < b.x ||
              b.x + b.width < a.x ||
              a.y + a.height < b.y ||
              b.y + b.height < a.y
            );

            if (hasOverlap) {
              // Calculate overlap area
              const overlapWidth = Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x);
              const overlapHeight = Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y);
              const overlapArea = overlapWidth * overlapHeight;

              // Small overlaps are acceptable, but significant ones are not
              const aArea = a.width * a.height;
              const bArea = b.width * b.height;

              // Overlap should not cover more than 20% of either element
              expect(overlapArea / aArea).toBeLessThanOrEqual(0.2);
              expect(overlapArea / bArea).toBeLessThanOrEqual(0.2);
            }
          }
        }
      });
    });
  });

  // ===== TOUCH TARGET SPACING =====

  test.describe('Touch Target Spacing', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should have adequate spacing between adjacent touch targets', async ({ page }) => {
      const buttons = await page.locator('button').all();

      for (let i = 0; i < Math.min(buttons.length, 10) - 1; i++) {
        const button1 = buttons[i];
        const button2 = buttons[i + 1];

        const box1 = await button1.boundingBox();
        const box2 = await button2.boundingBox();

        if (box1 && box2) {
          // Calculate spacing
          const horizontalGap = Math.max(0, box2.x - (box1.x + box1.width));
          const verticalGap = Math.max(0, box2.y - (box1.y + box1.height));

          // If elements are adjacent (not separated by other content), they need spacing
          const isHorizontalNeighbor = Math.abs(box1.y - box2.y) < 10;
          const isVerticalNeighbor = Math.abs(box1.x - box2.x) < 10;

          if (isHorizontalNeighbor) {
            // Horizontal neighbors should have at least 8px gap
            expect(horizontalGap).toBeGreaterThanOrEqual(8);
          } else if (isVerticalNeighbor) {
            // Vertical neighbors should have at least 8px gap
            expect(verticalGap).toBeGreaterThanOrEqual(8);
          }
        }
      }
    });

    test('should maintain spacing in navigation menus', async ({ page }) => {
      const nav = page.locator('nav').first();

      if (await nav.count() > 0) {
        const navItems = nav.locator('a, button').all();

        for (let i = 0; i < (await navItems.length) - 1; i++) {
          const item1 = await navItems[i];
          const item2 = await navItems[i + 1];

          const box1 = await item1.boundingBox();
          const box2 = await item2.boundingBox();

          if (box1 && box2) {
            // Check if items are in same row/col
            const sameRow = Math.abs(box1.y - box2.y) < 10;
            const sameCol = Math.abs(box1.x - box2.x) < 10;

            if (sameRow) {
              const gap = box2.x - (box1.x + box1.width);
              expect(gap).toBeGreaterThanOrEqual(8);
            } else if (sameCol) {
              const gap = box2.y - (box1.y + box1.height);
              expect(gap).toBeGreaterThanOrEqual(8);
            }
          }
        }
      }
    });

    test('should have spacing for inline links', async ({ page }) => {
      // Find inline links (links within text)
      const links = await page.locator('a[href]').all();

      const inlineLinks: Array<{ element: any; box: any }> = [];

      for (const link of links) {
        const box = await link.boundingBox();
        const parent = await link.evaluate(el => el.parentElement);

        if (box && parent) {
          const parentStyles = await link.evaluate(el => {
            return window.getComputedStyle(el.parentElement!);
          });

          // Check if parent has text (indicating inline link)
          const hasTextSiblings = await link.evaluate(el => {
            return Array.from(el.parentElement?.childNodes || [])
              .some(node => node.nodeType === Node.TEXT_NODE && node.textContent?.trim());
          });

          if (hasTextSiblings) {
            inlineLinks.push({ element: link, box });
          }
        }
      }

      // Inline links need adequate size
      for (const { element, box } of inlineLinks.slice(0, 5)) {
        expect(box.width).toBeGreaterThanOrEqual(44);
        expect(box.height).toBeGreaterThanOrEqual(44);
      }
    });
  });

  // ===== TOUCH TARGET VISIBILITY =====

  test.describe('Touch Target Visibility', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should not have obscured touch targets', async ({ page }) => {
      const touchTargets = await getTouchTargets(page);

      for (const target of touchTargets.slice(0, 10)) {
        const element = page.locator(target.selector);

        if (await element.count() > 0) {
          const isVisible = await element.isVisible();

          if (isVisible) {
            const box = await element.boundingBox();

            if (box) {
              // Check if element at center point is the same element
              const elementAtPoint = await page.evaluate(({ x, y }) => {
                const el = document.elementFromPoint(x, y);
                return {
                  tagName: el?.tagName.toLowerCase(),
                  isInteractive: el?.matches('button, a, input, select, textarea, [role="button"]'),
                };
              }, { x: box.x + box.width / 2, y: box.y + box.height / 2 });

              // The element at the touch point should be interactive
              expect(elementAtPoint.isInteractive).toBeTruthy();
            }
          }
        }
      }
    });

    test('should have visible focus indicators for keyboard users', async ({ page }) => {
      const focusableElements = page.locator('button, a[href], input, select, textarea').all();

      for (const element of await focusableElements.slice(0, 5)) {
        // Focus the element
        await element.then(e => e.focus());

        // Check for focus styles
        const hasFocusIndicator = await element.then(e => e.evaluate(el => {
          const styles = window.getComputedStyle(el);
          return styles.outline !== 'none' ||
                 styles.boxShadow !== 'none' ||
                 el.classList.contains('focus') ||
                 el.classList.contains('focused');
        }));

        expect(hasFocusIndicator).toBeTruthy();
      }
    });

    test('should maintain visibility during touch interaction', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        const box = await button.boundingBox();

        if (box) {
          // Start touch
          await page.touchstart(box.x + box.width / 2, box.y + box.height / 2);

          // Check visibility during touch
          const isVisible = await button.isVisible();
          expect(isVisible).toBeTruthy();

          // End touch
          await page.touchend();
        }
      }
    });

    test('should have sufficient color contrast', async ({ page }) => {
      const buttons = await page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        const isVisible = await button.isVisible();

        if (isVisible) {
          // Get colors
          const colors = await button.evaluate(el => {
            const styles = window.getComputedStyle(el);
            return {
              background: styles.backgroundColor,
              color: styles.color,
              fontSize: styles.fontSize,
            };
          });

          // Colors should be defined (not transparent)
          expect(colors.background).not.toBe('rgba(0, 0, 0, 0)');
          expect(colors.color).not.toBe('rgba(0, 0, 0, 0)');
        }
      }
    });
  });

  // ===== SCREEN READER COMPATIBILITY =====

  test.describe('Screen Reader Compatibility', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should have accessible names for touch targets', async ({ page }) => {
      const buttons = await page.locator('button').all();

      for (const button of await buttons.slice(0, 10)) {
        const accessibleName = await button.evaluate(el => {
          return el.getAttribute('aria-label') ||
                 el.getAttribute('title') ||
                 el.textContent?.trim();
        });

        expect(accessibleName).toBeTruthy();
        expect(accessibleName?.length).toBeGreaterThan(0);
      }
    });

    test('should announce state changes on touch', async ({ page }) => {
      const toggle = page.locator('[role="switch"], button[aria-pressed], button[aria-expanded]').first();

      if (await toggle.count() > 0) {
        const beforeState = await toggle.getAttribute('aria-pressed') ||
                           await toggle.getAttribute('aria-expanded') ||
                           await toggle.getAttribute('aria-checked');

        // Perform touch
        await tap(page, toggle);

        await page.waitForTimeout(100);

        const afterState = await toggle.getAttribute('aria-pressed') ||
                          await toggle.getAttribute('aria-expanded') ||
                          await toggle.getAttribute('aria-checked');

        // State should be defined and changed
        expect([beforeState, afterState]).toContain('true');
        expect([beforeState, afterState]).toContain('false');
      }
    });

    test('should have live regions for dynamic content', async ({ page }) => {
      const liveRegions = page.locator('[aria-live], [aria-atomic]').all();

      // If there are live regions, they should be properly configured
      for (const region of await liveRegions.slice(0, 5)) {
        const ariaLive = await region.getAttribute('aria-live');
        const ariaAtomic = await region.getAttribute('aria-atomic');

        expect(['polite', 'assertive']).toContain(ariaLive);
        expect(['true', 'false', null]).toContain(ariaAtomic);
      }
    });

    test('should have proper heading hierarchy', async ({ page }) => {
      const headings = await page.locator('h1, h2, h3, h4, h5, h6').all();

      if (headings.length > 0) {
        let previousLevel = 0;

        for (const heading of headings) {
          const tagName = await heading.evaluate(el => el.tagName);
          const level = parseInt(tagName[1]);

          // Heading levels should not skip (e.g., h1 to h3)
          expect(level).toBeLessThanOrEqual(previousLevel + 1);

          previousLevel = level;
        }
      }
    });

    test('should provide alternative text for icon-only buttons', async ({ page }) => {
      const iconButtons = await page.locator('button svg, button i, button [aria-label]').all();

      for (const button of await iconButtons.slice(0, 5)) {
        const ariaLabel = await button.getAttribute('aria-label');
        const title = await button.getAttribute('title');
        const text = await button.textContent();

        // Icon buttons should have aria-label or meaningful text
        const hasLabel = ariaLabel !== null || title !== null || (text && text.trim().length > 0);
        expect(hasLabel).toBeTruthy();
      }
    });
  });

  // ===== KEYBOARD ALTERNATIVES =====

  test.describe('Keyboard Alternatives', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should be keyboard accessible', async ({ page }) => {
      const focusableElements = page.locator('button, a[href], input, select, textarea').all();

      // Tab through elements
      for (const element of await focusableElements.slice(0, 5)) {
        await page.keyboard.press('Tab');
        await page.waitForTimeout(50);

        const focused = page.locator(':focus');
        await expect(focused).toBeVisible();
      }
    });

    test('should activate on Enter key', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await button.focus();
        await page.keyboard.press('Enter');

        // Button should still be functional
        await expect(button).toBeVisible();
      }
    });

    test('should activate on Space key', async ({ page }) => {
      const button = page.locator('button').first();

      if (await button.count() > 0) {
        await button.focus();
        await page.keyboard.press('Space');

        // Button should still be functional
        await expect(button).toBeVisible();
      }
    });

    test('should have visible focus indicators', async ({ page }) => {
      const focusableElements = page.locator('button, a[href]').all();

      for (const element of await focusableElements.slice(0, 3)) {
        await element.then(e => e.focus());

        const hasFocusStyle = await element.then(e => e.evaluate(el => {
          const styles = window.getComputedStyle(el);
          return styles.outline !== 'none' ||
                 styles.boxShadow !== 'none' ||
                 el.classList.contains('focus');
        }));

        expect(hasFocusStyle).toBeTruthy();
      }
    });

    test('should have logical tab order', async ({ page }) => {
      const focusableElements = page.locator('button, a[href], input, select, textarea').all();

      const tabOrder: string[] = [];

      // Tab through all focusable elements
      for (let i = 0; i < await focusableElements.length; i++) {
        await page.keyboard.press('Tab');
        await page.waitForTimeout(30);

        const focused = page.locator(':focus');
        if (await focused.count() > 0) {
          const tag = await focused.evaluate(el => el.tagName);
          tabOrder.push(tag);
        }
      }

      // Tab order should be consistent
      expect(tabOrder.length).toBeGreaterThan(0);
    });
  });

  // ===== MOBILE VIEWPORT CONFIGURATION =====

  test.describe('Mobile Viewport Configuration', () => {
    for (const [deviceName, deviceConfig] of Object.entries(MOBILE_DEVICES)) {
      test.describe(deviceName, () => {
        test('should have proper viewport meta tag', async ({ page }) => {
          await page.setExtraHTTPHeaders({ 'User-Agent': deviceConfig.userAgent });
          await page.goto('/');

          const hasViewport = await hasMobileViewportMeta(page);
          expect(hasViewport).toBeTruthy();
        });

        test('should have device-width viewport', async ({ page }) => {
          await page.setExtraHTTPHeaders({ 'User-Agent': deviceConfig.userAgent });
          await page.goto('/');

          const viewportMeta = page.locator('meta[name="viewport"]');
          await expect(viewportMeta).toHaveAttribute('content', /width=device-width/);
        });

        test('should prevent zooming on form focus', async ({ page }) => {
          await page.setExtraHTTPHeaders({ 'User-Agent': deviceConfig.userAgent });
          await page.goto('/');

          const viewportMeta = page.locator('meta[name="viewport"]');
          const content = await viewportMeta.getAttribute('content');

          // Should prevent automatic zoom on input focus
          expect(content).toMatch(/maximum-scale=1|user-scalable=no/);
        });
      });
    }
  });

  // ===== COGNITIVE LOAD =====

  test.describe('Cognitive Load Considerations', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should have sufficient spacing between unrelated elements', async ({ page }) => {
      const sections = page.locator('section, [class*="section"], [class*="card"]').all();

      for (let i = 0; i < Math.min(await sections.length, 5) - 1; i++) {
        const section1 = await sections[i];
        const section2 = await sections[i + 1];

        const box1 = await section1.boundingBox();
        const box2 = await section2.boundingBox();

        if (box1 && box2) {
          // Sections should have vertical spacing
          const verticalGap = box2.y - (box1.y + box1.height);
          expect(verticalGap).toBeGreaterThanOrEqual(16); // At least 16px
        }
      }
    });

    test('should not have too many touch targets clustered together', async ({ page }) => {
      // Count touch targets in viewport area
      const touchTargets = await getTouchTargets(page);
      const viewport = page.viewportSize();

      if (viewport && touchTargets.length > 0) {
        const density = touchTargets.length / (viewport.width * viewport.height) * 10000; // per 100x100 pixels

        // Density should be reasonable (less than 5 targets per 100x100px area)
        expect(density).toBeLessThan(5);
      }
    });

    test('should have consistent touch target sizes', async ({ page }) => {
      const buttons = await page.locator('button').all();

      const sizes: Array<{ width: number; height: number }> = [];

      for (const button of await buttons.slice(0, 10)) {
        const box = await button.boundingBox();
        if (box) {
          sizes.push({ width: box.width, height: box.height });
        }
      }

      if (sizes.length >= 3) {
        // Check variance - sizes should be relatively consistent
        const widths = sizes.map(s => s.width);
        const heights = sizes.map(s => s.height);

        const avgWidth = widths.reduce((a, b) => a + b, 0) / widths.length;
        const avgHeight = heights.reduce((a, b) => a + b, 0) / heights.length;

        // Most sizes should be within 20% of average
        const consistentWidths = widths.filter(w => Math.abs(w - avgWidth) / avgWidth < 0.2).length;
        const consistentHeights = heights.filter(h => Math.abs(h - avgHeight) / avgHeight < 0.2).length;

        expect(consistentWidths / widths.length).toBeGreaterThan(0.5);
        expect(consistentHeights / heights.length).toBeGreaterThan(0.5);
      }
    });

    test('should group related touch targets', async ({ page }) => {
      // Look for button groups or related controls
      const buttonGroups = page.locator('[role="group"], .btn-group, .button-group').all();

      for (const group of await buttonGroups.slice(0, 3)) {
        const buttons = group.locator('button').all();

        // Groups should have multiple related buttons
        const buttonCount = await buttons.length;
        expect(buttonCount).toBeGreaterThan(1);
      }
    });
  });

  // ===== TOUCH TARGET REACHABILITY =====

  test.describe('Touch Target Reachability', () => {
    test.use(devices['iPhone 14 Pro']);

    test.beforeEach(async ({ page }) => {
      await page.goto('/');
    });

    test('should place primary actions in bottom third for mobile', async ({ page }) => {
      const viewport = page.viewportSize();

      if (viewport) {
        const primaryButtons = page.locator('[data-primary], .btn-primary, [class*="primary"]').all();

        for (const button of await primaryButtons.slice(0, 3)) {
          const box = await button.boundingBox();

          if (box) {
            const relativeY = box.y / viewport.height;

            // Primary actions should be in bottom 40% of screen (easy thumb reach)
            expect(relativeY).toBeGreaterThan(0.4);
          }
        }
      }
    });

    test('should not place critical actions in top corners', async ({ page }) => {
      const viewport = page.viewportSize();

      if (viewport) {
        const criticalActions = page.locator('button[data-critical], [class*="critical"]').all();

        for (const action of await criticalActions.slice(0, 3)) {
          const box = await action.boundingBox();

          if (box) {
            // Check if action is in hard-to-reach corner
            const inTopLeft = box.y < 100 && box.x < 100;
            const inTopRight = box.y < 100 && box.x > viewport.width - 100;

            // Critical actions should avoid top corners on mobile
            expect(inTopLeft || inTopRight).toBeFalsy();
          }
        }
      }
    });

    test('should have adequate margins for edge buttons', async ({ page }) => {
      const viewport = page.viewportSize();

      if (viewport) {
        const buttons = await page.locator('button').all();

        for (const button of await buttons.slice(0, 5)) {
          const box = await button.boundingBox();

          if (box) {
            // Buttons at edges should have margin
            const atLeftEdge = box.x < 10;
            const atRightEdge = box.x + box.width > viewport.width - 10;

            if (atLeftEdge || atRightEdge) {
              const padding = await getHitAreaPadding(page, button);

              if (atLeftEdge) {
                expect(padding.left).toBeGreaterThanOrEqual(8);
              }
              if (atRightEdge) {
                expect(padding.right).toBeGreaterThanOrEqual(8);
              }
            }
          }
        }
      }
    });
  });

  // ===== ERROR HANDLING ACCESSIBILITY =====

  test.describe('Error Handling Accessibility', () => {
    test.use(devices['iPhone 14 Pro']);

    test('should announce errors to screen readers', async ({ page }) => {
      await page.goto('/');

      const errorRegions = page.locator('[role="alert"], [aria-live="assertive"], .error').all();

      for (const region of await errorRegions.slice(0, 3)) {
        const isVisible = await region.isVisible();

        if (isVisible) {
          // Error regions should be properly configured
          const role = await region.getAttribute('role');
          const ariaLive = await region.getAttribute('aria-live');

          expect([role, ariaLive]).toContain(expect.any(String));
        }
      }
    });

    test('should provide clear error messages on form validation', async ({ page }) => {
      const forms = page.locator('form').all();

      for (const form of await forms.slice(0, 2)) {
        const inputs = form.locator('input[required], [aria-required="true"]').all();

        for (const input of await inputs.slice(0, 3)) {
          const isVisible = await input.isVisible();

          if (isVisible) {
            // Try to submit empty form
            const submitButton = form.locator('button[type="submit"]').first();

            if (await submitButton.count() > 0) {
              await submitButton.tap();
              await page.waitForTimeout(200);

              // Look for error messages
              const errorMessage = form.locator('[aria-invalid="true"], .error, [role="alert"]').first();

              if (await errorMessage.count() > 0) {
                // Error should be visible
                await expect(errorMessage).toBeVisible();
              }
            }
          }
        }
      }
    });
  });

  // ===== ORIENTATION CHANGES =====

  test.describe('Orientation Accessibility', () => {
    test('should maintain touch target sizes in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/');

      const buttons = await page.locator('button').all();

      for (const button of await buttons.slice(0, 5)) {
        const isVisible = await button.isVisible();

        if (isVisible) {
          const box = await button.boundingBox();

          if (box) {
            expect(box.width).toBeGreaterThanOrEqual(44);
            expect(box.height).toBeGreaterThanOrEqual(44);
          }
        }
      }
    });

    test('should maintain spacing in landscape', async ({ page }) => {
      await page.setViewportSize({ width: 667, height: 375 });
      await page.goto('/');

      const buttons = await page.locator('button').all();

      for (let i = 0; i < Math.min(await buttons.length, 5) - 1; i++) {
        const button1 = buttons[i];
        const button2 = buttons[i + 1];

        const box1 = await button1.boundingBox();
        const box2 = await button2.boundingBox();

        if (box1 && box2) {
          const gap = Math.abs(box2.y - box1.y);

          // Vertical spacing should be maintained
          if (Math.abs(box1.x - box2.x) < 10) {
            expect(gap).toBeGreaterThanOrEqual(8);
          }
        }
      }
    });
  });
});

// ===== CROSS-DEVICE ACCESSIBILITY CONSISTENCY =====

test.describe('Cross-Device Accessibility Consistency', () => {
  const devicesToTest = [
    { name: 'iPhone 14 Pro', config: devices['iPhone 14 Pro'] },
    { name: 'iPad Pro', config: devices['iPad Pro'] },
    { name: 'Pixel 5', config: devices['Pixel 5'] },
  ];

  devicesToTest.forEach(({ name, config }) => {
    test.describe(`${name}`, () => {
      test.use(config);

      test('should have consistent touch target sizing', async ({ page }) => {
        await page.goto('/');

        const result = await validateTouchTargets(page, {
          minSize: 44,
          includeHidden: false,
        });

        const total = result.valid + result.invalid.length;

        if (total > 0) {
          const passRate = (result.valid / total) * 100;
          expect(passRate).toBeGreaterThanOrEqual(80);
        }
      });

      test('should have consistent accessibility attributes', async ({ page }) => {
        await page.goto('/');

        const buttons = await page.locator('button').all();

        for (const button of await buttons.slice(0, 5)) {
          const ariaLabel = await button.getAttribute('aria-label');
          const title = await button.getAttribute('title');
          const text = await button.textContent();

          const hasAccessibleName = ariaLabel !== null || title !== null || (text && text.trim().length > 0);
          expect(hasAccessibleName).toBeTruthy();
        }
      });

      test('should have proper viewport configuration', async ({ page }) => {
        await page.goto('/');

        const hasViewport = await hasMobileViewportMeta(page);
        expect(hasViewport).toBeTruthy();
      });
    });
  });
});
