import { defineConfig, devices } from '@playwright/test';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

// ES module equivalent of __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Playwright configuration for visual regression testing
 * Supports multi-browser, multi-viewport, and multi-theme testing
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['list']
  ],

  use: {
    baseURL: 'http://localhost:6006',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  projects: [
    {
      name: 'chromium-desktop',
      use: {
        ...devices['Desktop Chrome'],
        viewport: { width: 1920, height: 1080 },
        screenshot: 'only-on-failure',
      },
    },
    {
      name: 'chromium-tablet',
      use: {
        ...devices['iPad Pro'],
        screenshot: 'only-on-failure',
      },
    },
    {
      name: 'chromium-mobile',
      use: {
        ...devices['iPhone 13 Pro'],
        screenshot: 'only-on-failure',
      },
    },
    {
      name: 'firefox-desktop',
      use: {
        ...devices['Desktop Firefox'],
        viewport: { width: 1920, height: 1080 },
        screenshot: 'only-on-failure',
      },
    },
    {
      name: 'webkit-desktop',
      use: {
        ...devices['Desktop Safari'],
        viewport: { width: 1920, height: 1080 },
        screenshot: 'only-on-failure',
      },
    },
  ],

  // Start local dev server before running tests
  webServer: {
    command: 'cd ../../packages/leptos && npm run storybook',
    url: 'http://localhost:6006',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },

  // Output directories
  outputDir: 'test-results',
  snapshotDir: resolve(__dirname, 'screenshots'),
});
