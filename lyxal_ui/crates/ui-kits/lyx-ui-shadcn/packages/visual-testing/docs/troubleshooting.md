# Visual Testing Troubleshooting Guide

Common issues and solutions for visual regression testing.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Test Failures](#test-failures)
- [Performance Issues](#performance-issues)
- [CI/CD Issues](#cicd-issues)
- [False Positives](#false-positives)
- [Debugging Tips](#debugging-tips)

---

## Installation Issues

### Playwright browsers not installed

**Error:** `Executables don't exist at /root/.cache/ms-playwright/...`

**Solution:**
```bash
npx playwright install --with-deps chromium firefox webkit
```

### Missing dependencies on Linux

**Error:** `error while loading shared libraries: libX11.so.6`

**Solution:**
```bash
npx playwright install-deps chromium firefox webkit
```

### Node version incompatibility

**Error:** `SyntaxError: Unexpected token`

**Solution:**
```bash
# Use Node.js 18 or higher
node --version  # Should be v18+
nvm use 18
```

---

## Test Failures

### Baseline not found

**Error:** `ENOENT: no such file or directory, open 'screenshots/baseline/...'`

**Cause:** Baseline images don't exist yet.

**Solution:**
```bash
npm run test:update
```

### Too many pixel differences

**Error:** `Visual regression detected: 15.23% difference`

**Cause:** Actual rendering differs significantly from baseline.

**Solutions:**

1. Review the diff image to understand what changed
2. If change is intentional, update baseline:
   ```bash
   npm run test:update
   ```
3. If unintentional, fix the regression and re-run tests

### Tests fail only in CI

**Cause:** Environment differences (fonts, rendering, DPI).

**Solutions:**

1. Use Docker for consistent environment:
   ```yaml
   - uses: docker://ghcr.io/playwright/browser:*:v*
   ```

2. Increase threshold for CI:
   ```typescript
   const ciThreshold = process.env.CI ? 0.001 : 0.0001;
   ```

3. Use consistent fonts:
   ```typescript
   await page.addInitScript(() => {
     document.body.style.fontFamily = 'Arial, sans-serif';
   });
   ```

---

## Performance Issues

### Tests are too slow

**Solutions:**

1. Run tests in parallel:
   ```typescript
   test.describe.configure({ mode: 'parallel' });
   ```

2. Test fewer variants:
   ```typescript
   // Test only 2 themes instead of 4
   themes: THEMES.slice(0, 2)
   ```

3. Use fewer viewports:
   ```typescript
   // Test only desktop and mobile
   viewports: [VIEWPORTS[0], VIEWPORTS[3]]
   ```

4. Skip slow tests in development:
   ```typescript
   test.skip(process.env.CI !== 'true', 'Expensive test');
   ```

### Tests timeout

**Error:** `Test timeout of 30000ms exceeded`

**Solution:**
```typescript
test('slow test', async ({ page }) => {
  test.setTimeout(60000); // Increase timeout to 60s
  // ...
});
```

### Out of memory errors

**Error:** `JavaScript heap out of memory`

**Solution:**
```bash
NODE_OPTIONS="--max-old-space-size=4096" npm test
```

---

## CI/CD Issues

### Workflow fails with "Storybook not running"

**Error:** `Cannot connect to Storybook at http://localhost:6006`

**Solution:**
```yaml
- name: Start Storybook
  run: |
    npm run storybook &
    sleep 30  # Wait for Storybook to start
```

### Playwright can't connect

**Error:** `BrowserType.connect: Target browser, context or page not found`

**Solution:**
```yaml
- name: Install Playwright browsers
  run: npx playwright install --with-deps
```

### Artifacts not uploaded

**Cause:** Incorrect artifact paths.

**Solution:**
```yaml
- name: Upload screenshots
  uses: actions/upload-artifact@v4
  with:
    name: screenshots
    path: packages/visual-testing/screenshots/**
    if-no-files-found: warn
```

---

## False Positives

### Anti-aliasing differences

**Error:** Tests fail due to anti-aliasing variations.

**Solution:**
```typescript
const result = await compareImages(
  baselinePath,
  actualPath,
  diffPath,
  { ignoreAntiAliasing: true }  // Ignore anti-aliasing
);
```

### Font rendering differences

**Cause:** Different OS renders fonts differently.

**Solution:**
```typescript
// Use web-safe fonts
await page.addStyleTag({
  content: `
    * {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
    }
  `
});
```

### Timestamps and dynamic content

**Cause:** Random IDs, timestamps cause false failures.

**Solution:**
```typescript
// Hide dynamic elements
await page.addStyleTag({
  content: `
    .timestamp, .random-id, .counter {
      visibility: hidden !important;
    }
  `
});
```

### Sub-pixel rendering variations

**Cause:** Different pixel densities cause variations.

**Solution:**
```typescript
// Normalize to 1x DPI
await page.setViewportSize({
  width: 1920,
  height: 1080,
});
await page.evaluate(() => {
  window.devicePixelRatio = 1;
});
```

---

## Debugging Tips

### Run tests in headed mode

```bash
npm run test:headed
```

### Run single test file

```bash
npx playwright test tests/button.visual.spec.ts
```

### Run specific test

```bash
npx playwright test --grep "button hover state"
```

### Debug with Playwright Inspector

```bash
npm run test:debug
```

### Keep screenshots for failed tests

```typescript
// playwright.config.ts
use: {
  screenshot: 'always',  // Save all screenshots
}
```

### Pause test execution

```typescript
test('debug test', async ({ page }) => {
  await page.pause();  // Opens Playwright Inspector
});
```

### Log page state

```typescript
test('with logging', async ({ page }) => {
  await page.goto('/?path=/story/components-button--default');

  console.log('Page URL:', page.url());
  console.log('Viewport:', await page.viewportSize());

  const button = page.locator('button').first();
  console.log('Button visible:', await button.isVisible());
  console.log('Button text:', await button.textContent());
});
```

### Take manual screenshots

```typescript
test('manual screenshot', async ({ page }) => {
  await page.goto('/?path=/story/components-button--default');

  await page.screenshot({
    path: 'debug-screenshot.png',
    fullPage: true,
  });
});
```

---

## Advanced Debugging

### Compare images manually

```typescript
import { compareImages } from '@shadcn-ui/visual-testing';

const result = await compareImages(
  'baseline.png',
  'actual.png',
  'diff.png',
  { pixelDiffThreshold: 0.0001 }
);

console.log('Difference:', result.diffPercentage);
console.log('Mismatched pixels:', result.mismatchedPixels);
console.log('Passed:', result.passed);
```

### Export page HTML

```typescript
test('save HTML', async ({ page }) => {
  await page.goto('/?path=/story/components-button--default');

  const html = await page.content();
  await fs.writeFile('page.html', html);
});
```

### Get computed styles

```typescript
test('check styles', async ({ page }) => {
  const button = page.locator('button').first();

  const styles = await button.evaluate(el => {
    const computed = window.getComputedStyle(el);
    return {
      color: computed.color,
      background: computed.background,
      border: computed.border,
    };
  });

  console.log('Button styles:', styles);
});
```

### Trace test execution

```typescript
// playwright.config.ts
use: {
  trace: 'retain-on-failure',  // Keep trace for failed tests
}
```

View trace:
```bash
npx playwright show-trace test-results/trace.zip
```

---

## Common Scenarios

### Component animations not complete

**Solution:**
```typescript
await page.addStyleTag({
  content: `* { animation: none !important; }`
});
await page.waitForTimeout(100);
```

### Images not loaded

**Solution:**
```typescript
await page.goto(url, { waitUntil: 'networkidle' });
await page.waitForSelector('img[src]', { state: 'loaded' });
```

### Popovers and tooltips

**Solution:**
```typescript
// Hover to show tooltip
await button.hover();
await page.waitForTimeout(200);  // Wait for animation

const screenshot = await page.screenshot();
```

### Modal dialogs

**Solution:**
```typescript
// Open dialog
await page.click('button[data-open-dialog]');
await page.waitForSelector('.dialog[open]');

// Screenshot only dialog
const dialog = page.locator('.dialog').first();
const screenshot = await dialog.screenshot();
```

### Infinite scroll content

**Solution:**
```typescript
// Scroll to bottom
await page.evaluate(() => {
  window.scrollTo(0, document.body.scrollHeight);
});
await page.waitForTimeout(500);  // Wait for content to load
```

---

## Getting Help

If you're still stuck:

1. Check the [main documentation](./README.md)
2. Review [API reference](./api.md)
3. Search existing GitHub issues
4. Create a new issue with:
   - Error message
   - Test file
   - Diff image
   - Environment details (OS, browser, Node version)
