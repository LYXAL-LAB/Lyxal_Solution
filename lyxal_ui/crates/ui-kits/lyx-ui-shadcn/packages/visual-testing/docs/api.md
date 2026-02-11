# Visual Testing API Reference

Complete API documentation for the visual testing framework.

## Core Classes

### `VisualTestingFramework`

Main entry point for visual testing.

#### Constructor

```typescript
constructor(page: Page, screenshotDir?: string)
```

**Parameters:**
- `page` - Playwright Page instance
- `screenshotDir` - Directory for screenshots (default: "screenshots")

**Example:**
```typescript
const framework = createVisualFramework(page, 'my-screenshots');
```

#### Methods

##### `testStory(component, story, options)`

Test a component story with visual regression.

```typescript
async testStory(
  component: string,
  story: string,
  options: VisualTestOptions
): Promise<void>
```

**Parameters:**
- `component` - Component name in Storybook (e.g., "components-button")
- `story` - Story name (e.g., "default")
- `options` - Test configuration options

**VisualTestOptions:**
```typescript
interface VisualTestOptions {
  themes?: ThemeConfig[];      // Themes to test (default: 2 themes)
  viewports?: ViewportConfig[]; // Viewports to test (default: 2 viewports)
  threshold?: number;           // Max difference (default: 0.0001)
  hideSelectors?: string[];     // CSS selectors to hide
}
```

**Example:**
```typescript
await framework.testStory('components-button', 'default', {
  themes: [THEMES[0]],
  viewports: [VIEWPORTS[0]],
  threshold: 0.0001,
  hideSelectors: ['.timestamp', '.random-id'],
});
```

**Throws:**
- Error if visual regression detected

##### `createBaselines(component, story, options)`

Create baseline screenshots for a component.

```typescript
async createBaselines(
  component: string,
  story: string,
  options?: {
    themes?: ThemeConfig[];
    viewports?: ViewportConfig[];
  }
): Promise<void>
```

**Example:**
```typescript
await framework.createBaselines('components-button', 'default', {
  themes: THEMES,
  viewports: VIEWPORTS,
});
```

##### `getFixture()`

Get the underlying VisualTestFixture for advanced usage.

```typescript
getFixture(): VisualTestFixture
```

---

### `VisualTestFixture`

Lower-level fixture for fine-grained control.

#### Constructor

```typescript
constructor(page: Page, screenshotDir?: string)
```

#### Methods

##### `navigateToStory(component, story, theme?)`

Navigate to a Storybook story.

```typescript
async navigateToStory(
  component: string,
  story: string,
  theme?: ThemeConfig
): Promise<void>
```

##### `takeScreenshot(config)`

Take a screenshot with full configuration.

```typescript
async takeScreenshot(config: ScreenshotConfig): Promise<Buffer>
```

**ScreenshotConfig:**
```typescript
interface ScreenshotConfig {
  component: string;
  story: string;
  theme: ThemeConfig;
  viewport: ViewportConfig;
  variant?: string;
  animations?: 'allow' | 'disable';
  waitForSelector?: string;
  hideSelectors?: string[];
}
```

##### `saveScreenshot(config, subdirectory?)`

Take and save a screenshot to disk.

```typescript
async saveScreenshot(
  config: ScreenshotConfig,
  subdirectory?: 'baseline' | 'actual' | 'diff'
): Promise<string>
```

**Returns:** Path to saved screenshot

##### `compareWithBaseline(config, threshold?)`

Compare current screenshot with baseline.

```typescript
async compareWithBaseline(
  config: ScreenshotConfig,
  threshold?: ThresholdConfig
): Promise<{
  passed: boolean;
  diff?: VisualComparisonResult;
  diffPath?: string;
}>
```

##### `disableAnimations()`

Disable CSS animations for consistent screenshots.

```typescript
async disableAnimations(): Promise<void>
```

##### `hideElements(selectors)`

Hide elements for cleaner screenshots.

```typescript
async hideElements(selectors: string[]): Promise<void>
```

##### `waitForStable(selector?, timeout?)`

Wait for component to be stable.

```typescript
async waitForStable(
  selector?: string,
  timeout?: number
): Promise<void>
```

---

## Utility Functions

### `createVisualFramework(page, screenshotDir?)`

Create a new VisualTestingFramework instance.

```typescript
function createVisualFramework(
  page: Page,
  screenshotDir?: string
): VisualTestingFramework
```

**Example:**
```typescript
import { createVisualFramework } from '@shadcn-ui/visual-testing';

const framework = createVisualFramework(page);
```

### `createVisualFixture(page, screenshotDir?)`

Create a new VisualTestFixture instance.

```typescript
function createVisualFixture(
  page: Page,
  screenshotDir?: string
): VisualTestFixture
```

### `testAcrossThemes(fixture, component, story, themes, testFn)`

Run a test function across multiple themes.

```typescript
async function testAcrossThemes(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  themes: ThemeConfig[],
  testFn: (theme: ThemeConfig) => Promise<void>
): Promise<void>
```

**Example:**
```typescript
await testAcrossThemes(fixture, 'components-button', 'default', THEMES, async (theme) => {
  await fixture.navigateToStory('components-button', 'default', theme);
  // Test with theme
});
```

### `testAcrossViewports(fixture, component, story, viewports, testFn)`

Run a test function across multiple viewports.

```typescript
async function testAcrossViewports(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  viewports: ViewportConfig[],
  testFn: (viewport: ViewportConfig) => Promise<void>
): Promise<void>
```

### `comprehensiveVisualTest(fixture, component, story, themes, viewports, testFn)`

Run tests across all themes and viewports.

```typescript
async function comprehensiveVisualTest(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  themes: ThemeConfig[],
  viewports: ViewportConfig[],
  testFn: (theme: ThemeConfig, viewport: ViewportConfig) => Promise<void>
): Promise<void>
```

---

## Image Comparison

### `compareImages(image1Path, image2Path, diffImagePath, config?)`

Compare two PNG images pixel by pixel.

```typescript
function compareImages(
  image1Path: string,
  image2Path: string,
  diffImagePath: string,
  config?: ThresholdConfig
): Promise<VisualComparisonResult>
```

**Parameters:**
- `image1Path` - Path to first image
- `image2Path` - Path to second image
- `diffImagePath` - Path to save diff image
- `config` - Comparison threshold configuration

**Returns:** `VisualComparisonResult`

```typescript
interface VisualComparisonResult {
  passed: boolean;           // Whether comparison passed
  diffPercentage: number;    // Difference percentage (0-1)
  mismatchedPixels: number;  // Number of different pixels
  totalPixels: number;       // Total pixels compared
  diffImagePath?: string;    // Path to diff image (if any)
}
```

**Example:**
```typescript
const result = await compareImages(
  'baseline/button.png',
  'actual/button.png',
  'diff/button.png',
  { pixelDiffThreshold: 0.0001, maxMismatchedPixels: 100 }
);

if (!result.passed) {
  console.log(`Difference: ${(result.diffPercentage * 100).toFixed(2)}%`);
  console.log(`Mismatched pixels: ${result.mismatchedPixels}`);
}
```

### `generateScreenshotFilename(component, story, theme, viewport, variant?)`

Generate a consistent filename for screenshots.

```typescript
function generateScreenshotFilename(
  component: string,
  story: string,
  theme: string,
  viewport: string,
  variant?: string
): string
```

**Example:**
```typescript
const filename = generateScreenshotFilename(
  'button',
  'default',
  'light',
  'desktop',
  'primary'
);
// Returns: "button_default_light_desktop_primary.png"
```

### `cropToContent(imagePath, outputPath)`

Crop image to content bounds (removes empty space).

```typescript
function cropToContent(
  imagePath: string,
  outputPath: string
): Promise<void>
```

### `normalizeImage(inputPath, outputPath)`

Normalize image for consistent comparison.

```typescript
function normalizeImage(
  inputPath: string,
  outputPath: string
): Promise<void>
```

---

## Constants

### `THEMES`

Predefined theme configurations.

```typescript
const THEMES: ThemeConfig[] = [
  { name: 'Default Light', id: 'default-light', themeId: 'light' },
  { name: 'Default Dark', id: 'default-dark', themeId: 'dark' },
  { name: 'New York Light', id: 'new-york-light', themeId: 'new-york-light' },
  { name: 'New York Dark', id: 'new-york-dark', themeId: 'new-york-dark' },
];
```

### `VIEWPORTS`

Predefined viewport configurations.

```typescript
const VIEWPORTS: ViewportConfig[] = [
  { name: 'desktop', width: 1920, height: 1080, deviceScaleFactor: 1, isMobile: false },
  { name: 'laptop', width: 1366, height: 768, deviceScaleFactor: 1, isMobile: false },
  { name: 'tablet', width: 768, height: 1024, deviceScaleFactor: 2, isMobile: true },
  { name: 'mobile', width: 375, height: 667, deviceScaleFactor: 2, isMobile: true },
];
```

### `DEFAULT_THRESHOLD`

Default threshold configuration.

```typescript
const DEFAULT_THRESHOLD: ThresholdConfig = {
  pixelDiffThreshold: 0.0001,    // 0.01% difference
  maxMismatchedPixels: 100,
  ignoreAntiAliasing: true,
};
```

---

## Type Definitions

### `ThemeConfig`

```typescript
interface ThemeConfig {
  name: string;      // Display name
  id: string;        // Unique identifier
  themeId: string;   // Storybook theme ID
}
```

### `ViewportConfig`

```typescript
interface ViewportConfig {
  name: string;             // Viewport name
  width: number;            // Width in pixels
  height: number;           // Height in pixels
  deviceScaleFactor?: number;  // Device pixel ratio
  isMobile?: boolean;       // Whether this is a mobile viewport
}
```

### `ThresholdConfig`

```typescript
interface ThresholdConfig {
  pixelDiffThreshold: number;      // Max pixel difference (0-1)
  maxMismatchedPixels: number;     // Max number of different pixels
  ignoreAntiAliasing: boolean;     // Ignore anti-aliasing differences
}
```

### `VisualTestCase`

```typescript
interface VisualTestCase {
  name: string;
  component: string;
  story: string;
  themes: ThemeConfig[];
  viewports: ViewportConfig[];
  variants?: Record<string, string>[];
}
```

---

## Playwright Integration

### Test Configuration

Extend your Playwright config for visual testing:

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  // Use consistent screenshots
  use: {
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  // Configure projects for different browsers/viewports
  projects: [
    {
      name: 'chromium-desktop',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'chromium-mobile',
      use: { ...devices['iPhone 13 Pro'] },
    },
  ],
});
```

### Custom Matchers

Extend Playwright's expect with visual matchers:

```typescript
import { expect } from '@playwright/test';
import { compareImages } from '@shadcn-ui/visual-testing';

expect.extend({
  async toMatchVisualScreenshot(received: Buffer, baselinePath: string) {
    const actualPath = 'actual.png';
    const diffPath = 'diff.png';

    await fs.writeFile(actualPath, received);

    const result = await compareImages(baselinePath, actualPath, diffPath);

    return {
      pass: result.passed,
      message: () => `Visual comparison ${result.passed ? 'passed' : 'failed'}`,
    };
  },
});
```

---

## Error Handling

### Common Errors

#### `VisualRegressionError`

Thrown when visual regression is detected.

```typescript
class VisualRegressionError extends Error {
  constructor(
    message: string,
    public diff: VisualComparisonResult,
    public diffPath?: string
  ) {
    super(message);
  }
}
```

#### `BaselineNotFoundError`

Thrown when baseline image doesn't exist.

```typescript
class BaselineNotFoundError extends Error {
  constructor(public component: string, public story: string) {
    super(`Baseline not found for ${component}--${story}`);
  }
}
```

### Error Handling Example

```typescript
try {
  await framework.testStory('components-button', 'default');
} catch (error) {
  if (error instanceof VisualRegressionError) {
    console.error('Visual regression detected!');
    console.error(`Difference: ${error.diff.diffPercentage}`);
    console.error(`Diff image: ${error.diffPath}`);
  } else if (error instanceof BaselineNotFoundError) {
    console.log('Creating new baseline...');
    await framework.createBaselines(error.component, error.story);
  } else {
    throw error;
  }
}
```
