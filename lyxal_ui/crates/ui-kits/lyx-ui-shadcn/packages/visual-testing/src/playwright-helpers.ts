/**
 * Playwright helpers for visual testing
 * Extends Playwright's visual testing capabilities
 */

import { Page, BrowserContext, Locator, expect } from '@playwright/test';
import { resolve } from 'path';
import { promises as fs } from 'fs';
import {
  ThemeConfig,
  ViewportConfig,
  generateScreenshotFilename,
  normalizeImage,
  compareImages,
  DEFAULT_THRESHOLD,
} from './visual-tester.js';

/**
 * Screenshot configuration
 */
export interface ScreenshotConfig {
  component: string;
  story: string;
  theme: ThemeConfig;
  viewport: ViewportConfig;
  variant?: string;
  animations?: 'allow' | 'disable';
  waitForSelector?: string;
  hideSelectors?: string[];
}

/**
 * Visual test fixture
 */
export class VisualTestFixture {
  constructor(
    private page: Page,
    private screenshotDir: string = 'screenshots'
  ) {}

  /**
   * Navigate to a Storybook story
   */
  async navigateToStory(
    component: string,
    story: string,
    theme?: ThemeConfig
  ): Promise<void> {
    const url = this.buildStorybookUrl(component, story, theme);
    await this.page.goto(url, { waitUntil: 'networkidle' });

    // Wait for the story to render
    await this.page.waitForSelector('[data-story-loaded="true"], .sb-show-main', {
      timeout: 10000,
    }).catch(() => {
      // Fallback: just wait a bit if the selector isn't found
      return this.page.waitForTimeout(500);
    });

    // Apply theme if specified
    if (theme) {
      await this.applyTheme(theme);
    }
  }

  /**
   * Build Storybook URL
   */
  private buildStorybookUrl(
    component: string,
    story: string,
    theme?: ThemeConfig
  ): string {
    const baseUrl = this.page.context().browser()?.contexts()[0].pages()[0].url()
      || 'http://localhost:6006';

    const storyPath = `?path=/story/${component}--${story}`;

    if (theme) {
      return `${baseUrl}${storyPath}&globals=theme:${theme.themeId}`;
    }

    return `${baseUrl}${storyPath}`;
  }

  /**
   * Apply theme to the page
   */
  private async applyTheme(theme: ThemeConfig): Promise<void> {
    await this.page.evaluate((themeId) => {
      document.documentElement.setAttribute('data-theme', themeId);

      // Trigger theme change event
      window.dispatchEvent(new CustomEvent('themechange', { detail: { theme: themeId } }));
    }, theme.themeId);
  }

  /**
   * Disable animations for consistent screenshots
   */
  async disableAnimations(): Promise<void> {
    await this.page.addStyleTag({
      content: `
        *,
        *::before,
        *::after {
          animation-duration: 0s !important;
          animation-delay: 0s !important;
          transition-duration: 0s !important;
          transition-delay: 0s !important;
        }
      `,
    });
  }

  /**
   * Hide elements for cleaner screenshots
   */
  async hideElements(selectors: string[]): Promise<void> {
    for (const selector of selectors) {
      await this.page.addStyleTag({
        content: `${selector} { visibility: hidden !important; }`,
      });
    }
  }

  /**
   * Wait for component to be stable
   */
  async waitForStable(
    selector?: string,
    timeout: number = 5000
  ): Promise<void> {
    const targetSelector = selector || '[data-story-loaded="true"], .sb-show-main';

    await this.page.waitForSelector(targetSelector, {
      state: 'visible',
      timeout,
    });

    // Wait for potential animations to settle
    await this.page.waitForTimeout(100);
  }

  /**
   * Take a screenshot with full configuration
   */
  async takeScreenshot(config: ScreenshotConfig): Promise<Buffer> {
    const {
      component,
      story,
      theme,
      viewport,
      variant,
      animations = 'disable',
      waitForSelector,
      hideSelectors = [],
    } = config;

    // Disable animations if requested
    if (animations === 'disable') {
      await this.disableAnimations();
    }

    // Hide specified elements
    if (hideSelectors.length > 0) {
      await this.hideElements(hideSelectors);
    }

    // Wait for stability
    await this.waitForStable(waitForSelector);

    // Set viewport
    await this.page.setViewportSize({
      width: viewport.width,
      height: viewport.height,
    });

    // Take screenshot
    const screenshot = await this.page.screenshot({
      animations: animations === 'allow' ? 'allow' : 'disabled',
      type: 'png',
      fullPage: false,
    });

    return screenshot;
  }

  /**
   * Take and save a screenshot
   */
  async saveScreenshot(
    config: ScreenshotConfig,
    subdirectory: 'baseline' | 'actual' | 'diff' = 'actual'
  ): Promise<string> {
    const screenshot = await this.takeScreenshot(config);

    const filename = generateScreenshotFilename(
      config.component,
      config.story,
      config.theme.id,
      config.viewport.name,
      config.variant
    );

    const dir = resolve(this.screenshotDir, subdirectory);
    await fs.mkdir(dir, { recursive: true });

    const filepath = resolve(dir, filename);
    await fs.writeFile(filepath, screenshot);

    return filepath;
  }

  /**
   * Compare current screenshot with baseline
   */
  async compareWithBaseline(
    config: ScreenshotConfig,
    threshold = DEFAULT_THRESHOLD
  ): Promise<{ passed: boolean; diff?: any; diffPath?: string }> {
    const actualPath = await this.saveScreenshot(config, 'actual');
    const baselinePath = resolve(
      this.screenshotDir,
      'baseline',
      generateScreenshotFilename(
        config.component,
        config.story,
        config.theme.id,
        config.viewport.name,
        config.variant
      )
    );

    // Check if baseline exists
    const baselineExists = await fs.access(baselinePath).then(() => true).catch(() => false);

    if (!baselineExists) {
      // Create baseline if it doesn't exist
      await fs.mkdir(resolve(this.screenshotDir, 'baseline'), { recursive: true });
      await fs.copyFile(actualPath, baselinePath);
      return { passed: true };
    }

    // Normalize images
    const normalizedActualPath = actualPath.replace('.png', '.normalized.png');
    const normalizedBaselinePath = baselinePath.replace('.png', '.normalized.png');

    await normalizeImage(actualPath, normalizedActualPath);
    await normalizeImage(baselinePath, normalizedBaselinePath);

    // Compare images
    const diffPath = resolve(
      this.screenshotDir,
      'diff',
      generateScreenshotFilename(
        config.component,
        config.story,
        config.theme.id,
        config.viewport.name,
        config.variant
      )
    );

    await fs.mkdir(resolve(this.screenshotDir, 'diff'), { recursive: true });

    const result = await compareImages(
      normalizedBaselinePath,
      normalizedActualPath,
      diffPath,
      threshold
    );

    return {
      passed: result.passed,
      diff: result,
      diffPath: result.diffImagePath,
    };
  }
}

/**
 * Create a visual test fixture
 */
export function createVisualFixture(
  page: Page,
  screenshotDir?: string
): VisualTestFixture {
  return new VisualTestFixture(page, screenshotDir);
}

/**
 * Test helper for multi-theme visual testing
 */
export async function testAcrossThemes(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  themes: ThemeConfig[],
  testFn: (theme: ThemeConfig) => Promise<void>
): Promise<void> {
  for (const theme of themes) {
    await testFn(theme);
  }
}

/**
 * Test helper for multi-viewport visual testing
 */
export async function testAcrossViewports(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  viewports: ViewportConfig[],
  testFn: (viewport: ViewportConfig) => Promise<void>
): Promise<void> {
  for (const viewport of viewports) {
    await testFn(viewport);
  }
}

/**
 * Comprehensive visual test across themes and viewports
 */
export async function comprehensiveVisualTest(
  fixture: VisualTestFixture,
  component: string,
  story: string,
  themes: ThemeConfig[],
  viewports: ViewportConfig[],
  testFn: (theme: ThemeConfig, viewport: ViewportConfig) => Promise<void>
): Promise<void> {
  for (const theme of themes) {
    for (const viewport of viewports) {
      await testFn(theme, viewport);
    }
  }
}
