# Visual Regression Testing Framework

Comprehensive visual regression testing framework for shadcn-ui components using Playwright.

## Overview

This framework provides automated visual testing to detect unintended UI changes across:
- **Multiple themes**: Default (light/dark) and New York (light/dark)
- **Multiple browsers**: Chromium, Firefox, WebKit
- **Multiple viewports**: Desktop, Tablet, Mobile
- **Component variants**: Different sizes, states, and configurations

## Features

- 🎨 **Pixel-perfect comparison**: Detects even minor visual differences
- 🌓 **Multi-theme testing**: Tests components across all theme variants
- 📱 **Responsive testing**: Validates components across different screen sizes
- 🔄 **CI/CD integration**: Automated testing in GitHub Actions
- 📊 **Detailed reports**: HTML reports with diff images and metrics
- ⚡ **Fast execution**: Parallel test execution for quick feedback

## Installation

```bash
cd packages/visual-testing
npm install
npx playwright install --with-deps
```

## Quick Start

### Run all visual tests

```bash
npm test
```

### Run tests in headed mode (show browser)

```bash
npm run test:headed
```

### Update snapshots

```bash
npm run test:update
```

### Debug tests

```bash
npm run test:debug
```

## Project Structure

```
packages/visual-testing/
├── src/
│   ├── visual-tester.ts       # Core image comparison utilities
│   ├── playwright-helpers.ts  # Playwright test helpers
│   └── index.ts               # Main exports
├── tests/
│   ├── button.visual.spec.ts  # Button visual tests
│   ├── input.visual.spec.ts   # Input visual tests
│   └── card.visual.spec.ts    # Card visual tests
├── scripts/
│   └── run-visual-tests.sh    # Test runner script
├── screenshots/
│   ├── baseline/              # Baseline screenshots
│   ├── actual/                # Current test screenshots
│   └── diff/                  # Difference images
├── playwright.config.ts       # Playwright configuration
└── package.json
```

## Configuration

### Themes

```typescript
import { THEMES } from '@shadcn-ui/visual-testing';

const themes = [
  { name: 'Default Light', id: 'default-light', themeId: 'light' },
  { name: 'Default Dark', id: 'default-dark', themeId: 'dark' },
  { name: 'New York Light', id: 'new-york-light', themeId: 'new-york-light' },
  { name: 'New York Dark', id: 'new-york-dark', themeId: 'new-york-dark' },
];
```

### Viewports

```typescript
import { VIEWPORTS } from '@shadcn-ui/visual-testing';

const viewports = [
  { name: 'desktop', width: 1920, height: 1080, deviceScaleFactor: 1 },
  { name: 'laptop', width: 1366, height: 768, deviceScaleFactor: 1 },
  { name: 'tablet', width: 768, height: 1024, deviceScaleFactor: 2 },
  { name: 'mobile', width: 375, height: 667, deviceScaleFactor: 2 },
];
```

### Thresholds

```typescript
const threshold = {
  pixelDiffThreshold: 0.0001,  // 0.01% max difference
  maxMismatchedPixels: 100,     // Max 100 different pixels
  ignoreAntiAliasing: true,     // Ignore anti-aliasing differences
};
```

## Writing Visual Tests

### Basic test

```typescript
import { test, expect } from '@playwright/test';
import { createVisualFramework } from '@shadcn-ui/visual-testing';

test('button default appearance', async ({ page }) => {
  const framework = createVisualFramework(page);

  await framework.testStory('components-button', 'default', {
    themes: [THEMES[0]],  // Light theme
    viewports: [VIEWPORTS[0]],  // Desktop
    threshold: 0.0001,
  });
});
```

### Multi-theme test

```typescript
test('button across all themes', async ({ page }) => {
  const framework = createVisualFramework(page);

  await framework.testStory('components-button', 'default', {
    themes: THEMES,  // All themes
    viewports: [VIEWPORTS[0]],
  });
});
```

### Multi-viewport test

```typescript
test('button responsive design', async ({ page }) => {
  const framework = createVisualFramework(page);

  await framework.testStory('components-button', 'default', {
    themes: [THEMES[0]],
    viewports: VIEWPORTS,  // All viewports
  });
});
```

### Custom screenshot

```typescript
test('custom component screenshot', async ({ page }) => {
  await page.goto('/?path=/story/my-component--default');

  // Hide dynamic elements
  await page.evaluate(() => {
    document.querySelector('.timestamp')?.remove();
  });

  const screenshot = await page.screenshot({
    fullPage: false,
    animations: 'disabled',
  });

  expect(screenshot).toMatchSnapshot('my-component.png');
});
```

### Interactive state tests

```typescript
test('button hover state', async ({ page }) => {
  await page.goto('/?path=/story/components-button--default');

  const button = page.locator('button').first();
  await button.hover();

  const screenshot = await button.screenshot();
  expect(screenshot).toMatchSnapshot('button-hover.png');
});

test('button focus state', async ({ page }) => {
  await page.goto('/?path=/story/components-button--default');

  const button = page.locator('button').first();
  await button.focus();

  const screenshot = await button.screenshot();
  expect(screenshot).toMatchSnapshot('button-focus.png');
});
```

## Test Workflow

### Initial run (create baselines)

1. Run tests with `--update-snapshots` flag
2. Baseline images are created in `screenshots/baseline/`
3. Commit baselines to repository

```bash
npm run test:update
git add screenshots/baseline/
git commit -m "chore: add visual test baselines"
```

### Subsequent runs (compare with baselines)

1. Tests take new screenshots in `screenshots/actual/`
2. Compare with baselines using pixelmatch
3. Generate diff images in `screenshots/diff/` if differences found
4. Tests pass if differences are within threshold

### Handling failures

When visual tests fail:

1. Review the HTML report: `npm run test:report`
2. Check diff images in `screenshots/diff/`
3. Determine if changes are intentional:
   - **Intentional**: Update baselines with `npm run test:update`
   - **Unintentional**: Fix the regression and re-run tests

## CI/CD Integration

### GitHub Actions

The workflow runs on:
- Push to main/develop branches
- Pull requests
- Daily schedule (2 AM UTC)
- Manual trigger

```yaml
# .github/workflows/visual-tests.yml
name: Visual Regression Tests
on: [push, pull_request, schedule]
```

### Manual workflow trigger

```bash
# Via GitHub UI: Actions → Visual Regression Tests → Run workflow
# Or via gh CLI:
gh workflow run visual-tests.yml
```

### Update snapshots in CI

When you need to update baselines after intentional changes:

```bash
# Trigger workflow with update_snapshots: true
gh workflow run visual-tests.yml -f update_snapshots=true
```

## Best Practices

### 1. Test meaningful variations

```typescript
// Good: Test distinct visual states
test('button states', async ({ page }) => {
  // Test default, hover, active, disabled, loading
});

// Avoid: Testing too many similar variations
test('button 100 different texts', async ({ page }) => {
  // This creates unnecessary maintenance burden
});
```

### 2. Use appropriate selectors

```typescript
// Good: Stable selectors
const button = page.locator('button').first();
const card = page.locator('.card').first();

// Avoid: Fragile selectors
const element = page.locator('div > div > span:nth-child(3)');
```

### 3. Wait for stability

```typescript
// Wait for animations to complete
await page.waitForTimeout(100);

// Wait for specific elements
await page.waitForSelector('.component-loaded');

// Wait for network idle
await page.goto(url, { waitUntil: 'networkidle' });
```

### 4. Hide dynamic content

```typescript
// Hide timestamps, random IDs, etc.
await page.addStyleTag({
  content: `.timestamp, .random-id { visibility: hidden; }`
});
```

### 5. Set appropriate thresholds

```typescript
// Strict: For critical components
const strictThreshold = { pixelDiffThreshold: 0.0001 };

// Lenient: For complex layouts with more variability
const lenientThreshold = { pixelDiffThreshold: 0.001 };
```

## Troubleshooting

### Tests fail with "baseline not found"

**Cause**: Baseline images don't exist yet.

**Solution**: Run with `--update-snapshots` to create baselines.

```bash
npm run test:update
```

### Tests fail with "too many differences"

**Cause**: Actual rendering differs significantly from baseline.

**Solution**:
1. Review diff images to understand changes
2. If intentional: Update baselines
3. If unintentional: Fix the regression

### Tests are flaky (sometimes pass, sometimes fail)

**Cause**: Timing issues or animations not disabled.

**Solution**:
```typescript
// Disable animations
await page.addStyleTag({
  content: `* { transition: none !important; animation: none !important; }`
});

// Wait for stability
await page.waitForTimeout(200);
```

### CI tests fail but local tests pass

**Cause**: Environment differences (fonts, rendering, etc.)

**Solution**:
1. Use Docker container with consistent environment
2. Increase threshold slightly for CI
3. Check CI logs for specific differences

## API Reference

### `VisualTestingFramework`

Main class for running visual tests.

#### Methods

##### `testStory(component, story, options)`

Test a component story across themes and viewports.

```typescript
await framework.testStory('components-button', 'default', {
  themes: THEMES,
  viewports: VIEWPORTS,
  threshold: 0.0001,
  hideSelectors: ['.timestamp'],
});
```

##### `createBaselines(component, story, options)`

Create baseline screenshots for a component story.

```typescript
await framework.createBaselines('components-button', 'default', {
  themes: THEMES,
  viewports: VIEWPORTS,
});
```

### `createVisualFramework(page, screenshotDir?)`

Create a new visual testing framework instance.

```typescript
const framework = createVisualFramework(page, 'custom-screenshot-dir');
```

## Contributing

### Adding tests for a new component

1. Create test file: `tests/<component>.visual.spec.ts`
2. Add tests for:
   - Default appearance
   - All variants
   - All states (hover, focus, active, disabled)
   - Responsive behavior
   - Theme variations

3. Run tests and create baselines:
   ```bash
   npm run test:update
   ```

4. Commit baselines and tests

### Test template

```typescript
import { test, expect } from '@playwright/test';
import { THEMES, VIEWPORTS, createVisualFramework } from '../src/index.js';

test.describe('ComponentName Visual Tests', () => {
  test.describe.configure({ mode: 'parallel' });

  for (const theme of THEMES.slice(0, 2)) {
    test(`default in ${theme.name}`, async ({ page }) => {
      const framework = createVisualFramework(page);
      await framework.testStory('components-componentname', 'default', {
        themes: [theme],
        viewports: [VIEWPORTS[0]],
      });
    });
  }

  // Add more tests...
});
```

## License

MIT
