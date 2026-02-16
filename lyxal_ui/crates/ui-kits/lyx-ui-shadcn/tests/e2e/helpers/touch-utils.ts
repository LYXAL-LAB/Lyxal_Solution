import { Page, Locator } from '@playwright/test';

/**
 * Touch Interaction Utilities for E2E Testing
 *
 * Provides helper functions for simulating and validating touch interactions
 * on mobile devices. Includes gesture simulation, touch event validation,
 * and mobile-specific testing utilities.
 */

// Touch event types that can be tested
export interface TouchEvents {
  touchstart?: boolean;
  touchmove?: boolean;
  touchend?: boolean;
  touchcancel?: boolean;
}

// Point coordinates for touch interactions
export interface TouchPoint {
  x: number;
  y: number;
}

// Swipe direction for gesture testing
export type SwipeDirection = 'up' | 'down' | 'left' | 'right';

// Configuration for touch gestures
export interface TouchGestureConfig {
  duration?: number; // Duration in ms
  steps?: number; // Number of intermediate steps
  pressure?: number; // Touch pressure (0-1)
  radiusX?: number; // Touch radius X
  radiusY?: number; // Touch radius Y
}

// Mobile device configurations for touch testing
export const MOBILE_DEVICES = {
  'iPhone-14-Pro': {
    viewport: { width: 393, height: 852 },
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    hasTouch: true,
    isIOS: true,
  },
  'iPhone-SE': {
    viewport: { width: 375, height: 667 },
    userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    hasTouch: true,
    isIOS: true,
  },
  'iPad-Pro': {
    viewport: { width: 1024, height: 1366 },
    userAgent: 'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
    hasTouch: true,
    isIOS: true,
  },
  'Samsung-Galaxy-S22': {
    viewport: { width: 360, height: 800 },
    userAgent: 'Mozilla/5.0 (Linux; Android 12; SM-S906B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    hasTouch: true,
    isIOS: false,
  },
  'Pixel-7': {
    viewport: { width: 412, height: 915 },
    userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
    hasTouch: true,
    isIOS: false,
  },
} as const;

// Touch action CSS values
export type TouchAction = 'auto' | 'none' | 'pan-x' | 'pan-y' | 'manipulation' | 'pan-left' | 'pan-right' | 'pan-up' | 'pan-down' | 'pinch-zoom';

/**
 * Simulate a tap interaction (touchstart + touchend)
 */
export async function tap(
  page: Page,
  selector: string | Locator,
  options: { duration?: number; force?: boolean } = {}
): Promise<void> {
  const { duration = 100, force = false } = options;

  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  // Get element bounds
  const box = await element.boundingBox();
  if (!box) {
    throw new Error(`Element not found or not visible: ${selector}`);
  }

  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;

  // Simulate touch sequence
  await page.touchstart(x, y);
  await page.waitForTimeout(duration);
  await page.touchend();

  // Wait for any handlers to complete
  await page.waitForTimeout(50);
}

/**
 * Simulate a double tap interaction
 */
export async function doubleTap(
  page: Page,
  selector: string | Locator,
  options: { interval?: number } = {}
): Promise<void> {
  const { interval = 300 } = options;

  await tap(page, selector);
  await page.waitForTimeout(interval);
  await tap(page, selector);
}

/**
 * Simulate a long press interaction
 */
export async function longPress(
  page: Page,
  selector: string | Locator,
  options: { duration?: number } = {}
): Promise<void> {
  const { duration = 500 } = options;

  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const box = await element.boundingBox();
  if (!box) {
    throw new Error(`Element not found or not visible: ${selector}`);
  }

  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;

  // Long press: touchstart, hold, touchend
  await page.touchstart(x, y);
  await page.waitForTimeout(duration);
  await page.touchend();

  await page.waitForTimeout(50);
}

/**
 * Simulate a swipe gesture
 */
export async function swipe(
  page: Page,
  selector: string | Locator | null,
  direction: SwipeDirection,
  options: TouchGestureConfig = {}
): Promise<void> {
  const { duration = 500, steps = 10 } = options;

  let startBounds: { x: number; y: number; width: number; height: number } | null = null;

  if (selector) {
    const element = typeof selector === 'string' ? page.locator(selector) : selector;
    startBounds = await element.boundingBox();
    if (!startBounds) {
      throw new Error(`Element not found or not visible: ${selector}`);
    }
  } else {
    // Use viewport
    const viewport = page.viewportSize();
    if (!viewport) {
      throw new Error('Viewport not set');
    }
    startBounds = { x: 0, y: 0, width: viewport.width, height: viewport.height };
  }

  const startX = startBounds.x + startBounds.width / 2;
  const startY = startBounds.y + startBounds.height / 2;

  const swipeDistance = 100;
  let endX = startX;
  let endY = startY;

  switch (direction) {
    case 'up':
      endY -= swipeDistance;
      break;
    case 'down':
      endY += swipeDistance;
      break;
    case 'left':
      endX -= swipeDistance;
      break;
    case 'right':
      endX += swipeDistance;
      break;
  }

  // Perform swipe with intermediate steps
  const stepDelay = duration / steps;

  await page.touchstart(startX, startY);

  for (let i = 1; i <= steps; i++) {
    const progress = i / steps;
    const currentX = startX + (endX - startX) * progress;
    const currentY = startY + (endY - startY) * progress;
    await page.touchmove(currentX, currentY);
    await page.waitForTimeout(stepDelay);
  }

  await page.touchend();
  await page.waitForTimeout(50);
}

/**
 * Simulate a pinch-to-zoom gesture
 */
export async function pinchZoom(
  page: Page,
  selector: string | Locator,
  options: { scale?: number; duration?: number } = {}
): Promise<void> {
  const { scale = 1.5, duration = 500 } = options;

  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const box = await element.boundingBox();
  if (!box) {
    throw new Error(`Element not found or not visible: ${selector}`);
  }

  const centerX = box.x + box.width / 2;
  const centerY = box.y + box.height / 2;

  // Initial pinch distance
  const initialDistance = 50;
  const finalDistance = initialDistance * scale;

  // Calculate finger positions
  const stepCount = 10;
  const stepDelay = duration / stepCount;

  // Start with both fingers at center
  await page.evaluate(({ x, y }) => {
    const touchStart1 = new TouchEvent('touchstart', {
      bubbles: true,
      cancelable: true,
      touches: [
        new Touch({
          identifier: 1,
          target: document.body,
          clientX: x - 25,
          clientY: y,
        }),
        new Touch({
          identifier: 2,
          target: document.body,
          clientX: x + 25,
          clientY: y,
        }),
      ],
    });
    document.dispatchEvent(touchStart1);
  }, { x: centerX, y: centerY });

  // Animate pinch
  for (let i = 1; i <= stepCount; i++) {
    const progress = i / stepCount;
    const currentDistance = initialDistance + (finalDistance - initialDistance) * progress;
    const offsetX = currentDistance / 2;

    await page.evaluate(({ x, y, offset }) => {
      const touchMove = new TouchEvent('touchmove', {
        bubbles: true,
        cancelable: true,
        touches: [
          new Touch({
            identifier: 1,
            target: document.body,
            clientX: x - offset,
            clientY: y,
          }),
          new Touch({
            identifier: 2,
            target: document.body,
            clientX: x + offset,
            clientY: y,
          }),
        ],
      });
      document.dispatchEvent(touchMove);
    }, { x: centerX, y: centerY, offset: offsetX });

    await page.waitForTimeout(stepDelay);
  }

  // End pinch
  await page.evaluate(({ x, y, offset }) => {
    const touchEnd = new TouchEvent('touchend', {
      bubbles: true,
      cancelable: true,
      changedTouches: [
        new Touch({
          identifier: 1,
          target: document.body,
          clientX: x - offset,
          clientY: y,
        }),
        new Touch({
          identifier: 2,
          target: document.body,
          clientX: x + offset,
          clientY: y,
        }),
      ],
    });
    document.dispatchEvent(touchEnd);
  }, { x: centerX, y: centerY, offset: finalDistance / 2 });

  await page.waitForTimeout(50);
}

/**
 * Simulate dragging an element
 */
export async function drag(
  page: Page,
  selector: string | Locator,
  deltaX: number,
  deltaY: number,
  options: TouchGestureConfig = {}
): Promise<void> {
  const { duration = 500, steps = 10 } = options;

  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const box = await element.boundingBox();
  if (!box) {
    throw new Error(`Element not found or not visible: ${selector}`);
  }

  const startX = box.x + box.width / 2;
  const startY = box.y + box.height / 2;
  const endX = startX + deltaX;
  const endY = startY + deltaY;

  const stepDelay = duration / steps;

  await page.touchstart(startX, startY);

  for (let i = 1; i <= steps; i++) {
    const progress = i / steps;
    const currentX = startX + (endX - startX) * progress;
    const currentY = startY + (endY - startY) * progress;

    await page.touchmove(currentX, currentY);
    await page.waitForTimeout(stepDelay);
  }

  await page.touchend();
  await page.waitForTimeout(50);
}

/**
 * Simulate a scroll with touch
 */
export async function touchScroll(
  page: Page,
  selector: string | Locator | null,
  scrollX: number,
  scrollY: number,
  options: TouchGestureConfig = {}
): Promise<void> {
  const element = selector
    ? typeof selector === 'string'
      ? page.locator(selector)
      : selector
    : null;

  const box = element ? await element.boundingBox() : null;

  const startX = box?.x ? box.x + box.width / 2 : 100;
  const startY = box?.y ? box.y + box.height / 2 : 100;

  await page.touchstart(startX, startY);

  const steps = options.steps ?? 10;
  const duration = options.duration ?? 500;
  const stepDelay = duration / steps;

  const endX = startX - scrollX;
  const endY = startY - scrollY;

  for (let i = 1; i <= steps; i++) {
    const progress = i / steps;
    const currentX = startX + (endX - startX) * progress;
    const currentY = startY + (endY - startY) * progress;

    await page.touchmove(currentX, currentY);
    await page.waitForTimeout(stepDelay);
  }

  await page.touchend();
  await page.waitForTimeout(50);
}

/**
 * Check if an element has proper touch event listeners
 */
export async function hasTouchListeners(
  page: Page,
  selector: string | Locator,
  events: TouchEvents
): Promise<boolean> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const result = await element.evaluate((el, eventNames) => {
    const element = el as HTMLElement;
    const hasListeners: TouchEvents = {};

    if (eventNames.touchstart) {
      hasListeners.touchstart = element.getAttribute('ontouchstart') !== null;
    }
    if (eventNames.touchmove) {
      hasListeners.touchmove = element.getAttribute('ontouchmove') !== null;
    }
    if (eventNames.touchend) {
      hasListeners.touchend = element.getAttribute('ontouchend') !== null;
    }
    if (eventNames.touchcancel) {
      hasListeners.touchcancel = element.getAttribute('ontouchcancel') !== null;
    }

    // Check if any expected listener is present
    return Object.values(hasListeners).some(v => v);
  }, events);

  return result;
}

/**
 * Get the touch-action CSS value of an element
 */
export async function getTouchAction(page: Page, selector: string | Locator): Promise<string> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  return await element.evaluate(el => {
    return window.getComputedStyle(el).touchAction || '';
  });
}

/**
 * Verify touch target size meets WCAG guidelines
 */
export async function verifyTouchTargetSize(
  page: Page,
  selector: string | Locator,
  minSize: number = 44
): Promise<boolean> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const box = await element.boundingBox();
  if (!box) {
    return false;
  }

  return box.width >= minSize && box.height >= minSize;
}

/**
 * Get all touch targets on the page
 */
export async function getTouchTargets(page: Page): Promise<Array<{ selector: string; size: { width: number; height: number } }>> {
  return await page.evaluate(() => {
    const touchTargets = [
      ...Array.from(document.querySelectorAll('button:not([disabled])')),
      ...Array.from(document.querySelectorAll('a[href]')),
      ...Array.from(document.querySelectorAll('input:not([disabled])')),
      ...Array.from(document.querySelectorAll('select:not([disabled])')),
      ...Array.from(document.querySelectorAll('textarea:not([disabled])')),
      ...Array.from(document.querySelectorAll('[role="button"]:not([aria-disabled="true"])')),
      ...Array.from(document.querySelectorAll('[tabindex]:not([tabindex="-1"])')),
    ];

    return touchTargets.map((el, index) => {
      const rect = el.getBoundingClientRect();
      return {
        selector: `${el.tagName.toLowerCase()}${el.className ? '.' + el.className.split(' ').join('.') : ''}:nth-of-type(${index + 1})`,
        size: {
          width: Math.round(rect.width),
          height: Math.round(rect.height),
        },
      };
    });
  });
}

/**
 * Validate all touch targets meet minimum size requirements
 */
export async function validateTouchTargets(
  page: Page,
  options: { minSize?: number; includeHidden?: boolean } = {}
): Promise<{
  valid: number;
  invalid: Array<{ selector: string; size: { width: number; height: number } }>;
}> {
  const { minSize = 44, includeHidden = false } = options;

  const touchTargets = await getTouchTargets(page);
  const invalid: Array<{ selector: string; size: { width: number; height: number } }> = [];
  let valid = 0;

  for (const target of touchTargets) {
    if (!includeHidden) {
      const isVisible = await page.locator(target.selector).isVisible();
      if (!isVisible) continue;
    }

    if (target.size.width >= minSize && target.size.height >= minSize) {
      valid++;
    } else {
      invalid.push(target);
    }
  }

  return { valid, invalid };
}

/**
 * Simulate touch feedback (visual response)
 */
export async function hasTouchFeedback(
  page: Page,
  selector: string | Locator
): Promise<boolean> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  // Check for active state styling
  const hasActiveStyle = await element.evaluate(el => {
    const styles = window.getComputedStyle(el, ':active');
    return styles.backgroundColor !== 'rgba(0, 0, 0, 0)' ||
           styles.transform !== 'none' ||
           styles.opacity !== '1';
  });

  return hasActiveStyle;
}

/**
 * Check if viewport meta tag is properly configured for mobile
 */
export async function hasMobileViewportMeta(page: Page): Promise<boolean> {
  const viewportMeta = await page.locator('meta[name="viewport"]').first();
  if (await viewportMeta.count() === 0) {
    return false;
  }

  const content = await viewportMeta.getAttribute('content') || '';
  return content.includes('width=device-width') && content.includes('initial-scale=1');
}

/**
 * Check for multi-touch support detection
 */
export async function detectMultiTouchSupport(page: Page): Promise<{
  maxTouchPoints: number;
  touchSupport: boolean;
  coalescedEvents: boolean;
}> {
  return await page.evaluate(() => {
    return {
      maxTouchPoints: navigator.maxTouchPoints || 0,
      touchSupport: 'ontouchstart' in window || navigator.maxTouchPoints > 0,
      coalescedEvents: 'onpointermove' in window,
    };
  });
}

/**
 * Set up page for mobile device emulation
 */
export async function setupMobileEmulation(
  page: Page,
  deviceName: keyof typeof MOBILE_DEVICES
): Promise<void> {
  const device = MOBILE_DEVICES[deviceName];

  await page.setViewportSize(device.viewport);
  await page.setExtraHTTPHeaders({
    'User-Agent': device.userAgent,
  });

  // Add touch capability detection script
  await page.addInitScript(() => {
    Object.defineProperty(navigator, 'maxTouchPoints', {
      get: () => 5,
    });

    Object.defineProperty(navigator, 'touchSupport', {
      get: () => true,
    });
  });
}

/**
 * Measure touch response time (time from touch to visual feedback)
 */
export async function measureTouchResponseTime(
  page: Page,
  selector: string | Locator
): Promise<number> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const responseTime = await page.evaluate(async (el) => {
    return new Promise<number>((resolve) => {
      const startTime = performance.now();

      element.addEventListener('touchstart', () => {
        const endTime = performance.now();
        resolve(endTime - startTime);
      }, { once: true });

      // Trigger touch event
      const touchEvent = new TouchEvent('touchstart', {
        bubbles: true,
        cancelable: true,
        touches: [new Touch({
          identifier: 1,
          target: element as EventTarget,
          clientX: 0,
          clientY: 0,
        })],
      });

      element.dispatchEvent(touchEvent);

      // Timeout if no response
      setTimeout(() => resolve(-1), 1000);
    });
  }, await element.elementHandle());

  return responseTime;
}

/**
 * Create a custom touch gesture with multiple touch points
 */
export async function multiTouchGesture(
  page: Page,
  touchPoints: TouchPoint[],
  duration: number = 500
): Promise<void> {
  const steps = 10;
  const stepDelay = duration / steps;

  // Start all touch points
  for (const point of touchPoints) {
    await page.touchstart(point.x, point.y);
  }

  // Hold briefly
  await page.waitForTimeout(stepDelay);

  // End all touch points
  for (const point of touchPoints) {
    await page.touchend();
  }

  await page.waitForTimeout(50);
}

/**
 * Check if element prevents default touch behavior
 */
export async function preventsDefaultTouch(
  page: Page,
  selector: string | Locator,
  eventType: 'touchstart' | 'touchmove' | 'touchend'
): Promise<boolean> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  return await element.evaluate((el, eventType) => {
    let prevented = false;

    const handler = (e: Event) => {
      prevented = e.defaultPrevented;
    };

    el.addEventListener(eventType, handler);
    el.dispatchEvent(new TouchEvent(eventType, {
      bubbles: true,
      cancelable: true,
      touches: [new Touch({
        identifier: 1,
        target: el,
        clientX: 0,
        clientY: 0,
      })],
    }));
    el.removeEventListener(eventType, handler);

    return prevented;
  }, eventType);
}

/**
 * Test element hit area (touch target padding)
 */
export async function getHitAreaPadding(
  page: Page,
  selector: string | Locator
): Promise<{ top: number; right: number; bottom: number; left: number }> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  return await element.evaluate(el => {
    const rect = el.getBoundingClientRect();
    const styles = window.getComputedStyle(el);

    const marginTop = parseFloat(styles.marginTop);
    const marginRight = parseFloat(styles.marginRight);
    const marginBottom = parseFloat(styles.marginBottom);
    const marginLeft = parseFloat(styles.marginLeft);

    return {
      top: marginTop,
      right: marginRight,
      bottom: marginBottom,
      left: marginLeft,
    };
  });
}

/**
 * Get touch event log from page
 */
export async function getTouchEventLog(page: Page): Promise<Array<{
  type: string;
  timestamp: number;
  target: string;
}>> {
  return await page.evaluate(() => {
    return (window as any).__touchEventLog || [];
  });
}

/**
 * Clear touch event log from page
 */
export async function clearTouchEventLog(page: Page): Promise<void> {
  await page.evaluate(() => {
    (window as any).__touchEventLog = [];
  });
}

/**
 * Inject touch event logger into page
 */
export async function injectTouchLogger(page: Page): Promise<void> {
  await page.addInitScript(() => {
    const eventTypes = ['touchstart', 'touchmove', 'touchend', 'touchcancel'];
    (window as any).__touchEventLog = [];

    eventTypes.forEach(eventType => {
      document.addEventListener(eventType, (e: Event) => {
        (window as any).__touchEventLog.push({
          type: eventType,
          timestamp: Date.now(),
          target: (e.target as HTMLElement).tagName,
        });
      }, { passive: true });
    });
  });
}

/**
 * Helper to simulate native device touch events
 */
export async function simulateNativeTouch(
  page: Page,
  selector: string | Locator,
  touchType: 'start' | 'move' | 'end' | 'cancel'
): Promise<void> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  const box = await element.boundingBox();
  if (!box) {
    throw new Error(`Element not found: ${selector}`);
  }

  const x = box.x + box.width / 2;
  const y = box.y + box.height / 2;

  const eventType = `touch${touchType}`;

  await page.evaluate(({ eventType, x, y }) => {
    const touch = new Touch({
      identifier: Date.now(),
      target: document.body,
      clientX: x,
      clientY: y,
    });

    const event = new TouchEvent(eventType, {
      bubbles: true,
      cancelable: true,
      touches: touchType !== 'end' && touchType !== 'cancel' ? [touch] : [],
      changedTouches: [touch],
      targetTouches: touchType !== 'end' && touchType !== 'cancel' ? [touch] : [],
    });

    document.dispatchEvent(event);
  }, { eventType, x, y });
}

/**
 * Test for touch-action CSS property interference
 */
export async function hasTouchActionInterference(
  page: Page,
  selector: string | Locator
): Promise<boolean> {
  const touchAction = await getTouchAction(page, selector);

  // These values might interfere with custom touch handling
  const interferingActions = ['none', 'pan-x', 'pan-y'];

  return interferingActions.some(action => touchAction.includes(action));
}

/**
 * Get element's touch event handlers
 */
export async function getTouchHandlers(
  page: Page,
  selector: string | Locator
): Promise<string[]> {
  const element = typeof selector === 'string' ? page.locator(selector) : selector;

  return await element.evaluate(el => {
    const handlers: string[] = [];
    const element = el as HTMLElement;

    if ((element as any).ontouchstart) handlers.push('touchstart');
    if ((element as any).ontouchmove) handlers.push('touchmove');
    if ((element as any).ontouchend) handlers.push('touchend');
    if ((element as any).ontouchcancel) handlers.push('touchcancel');

    return handlers;
  });
}
