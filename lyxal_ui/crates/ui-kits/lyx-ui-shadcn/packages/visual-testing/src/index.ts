/**
 * Visual testing framework entry point
 * Exports all utilities for visual regression testing
 */

export * from './visual-tester.js';
export * from './playwright-helpers.js';

/**
 * Main visual testing class
 */
import { Page } from '@playwright/test';
import { createVisualFixture, VisualTestFixture } from './playwright-helpers.js';
import { THEMES, VIEWPORTS, ThemeConfig, ViewportConfig } from './visual-tester.js';

export class VisualTestingFramework {
  private fixture: VisualTestFixture;

  constructor(page: Page, screenshotDir: string = 'screenshots') {
    this.fixture = createVisualFixture(page, screenshotDir);
  }

  /**
   * Get the underlying fixture for advanced usage
   */
  getFixture(): VisualTestFixture {
    return this.fixture;
  }

  /**
   * Test a component story with visual regression
   */
  async testStory(
    component: string,
    story: string,
    options: {
      themes?: ThemeConfig[];
      viewports?: ViewportConfig[];
      threshold?: number;
      hideSelectors?: string[];
    } = {}
  ): Promise<void> {
    const {
      themes = THEMES.slice(0, 2), // Default to light/dark themes
      viewports = VIEWPORTS.slice(0, 2), // Default to desktop and mobile
      threshold = 0.0001,
      hideSelectors = [],
    } = options;

    for (const theme of themes) {
      for (const viewport of viewports) {
        await this.fixture.navigateToStory(component, story, theme);

        const result = await this.fixture.compareWithBaseline(
          {
            component,
            story,
            theme,
            viewport,
            hideSelectors,
          },
          { pixelDiffThreshold: threshold, maxMismatchedPixels: 100, ignoreAntiAliasing: true }
        );

        if (!result.passed && result.diff) {
          throw new Error(
            `Visual regression detected for ${component}--${story} ` +
            `in ${theme.name} theme at ${viewport.name} viewport:\n` +
            `  Diff: ${(result.diff.diffPercentage * 100).toFixed(4)}%\n` +
            `  Mismatched pixels: ${result.diff.mismatchedPixels}\n` +
            `  Diff image: ${result.diffPath}`
          );
        }
      }
    }
  }

  /**
   * Create baselines for a component story
   */
  async createBaselines(
    component: string,
    story: string,
    options: {
      themes?: ThemeConfig[];
      viewports?: ViewportConfig[];
    } = {}
  ): Promise<void> {
    const {
      themes = THEMES,
      viewports = VIEWPORTS,
    } = options;

    for (const theme of themes) {
      for (const viewport of viewports) {
        await this.fixture.navigateToStory(component, story, theme);
        await this.fixture.saveScreenshot(
          {
            component,
            story,
            theme,
            viewport,
          },
          'baseline'
        );
      }
    }
  }
}

/**
 * Create a visual testing framework instance
 */
export function createVisualFramework(
  page: Page,
  screenshotDir?: string
): VisualTestingFramework {
  return new VisualTestingFramework(page, screenshotDir);
}

// Re-export constants
export { THEMES, VIEWPORTS };
export type { ThemeConfig, ViewportConfig, ScreenshotConfig } from './playwright-helpers.js';
export type { VisualTestCase, VisualComparisonResult, ThresholdConfig } from './visual-tester.js';
