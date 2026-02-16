import { defineConfig, devices } from '@playwright/test';

/**
 * Cross-Browser Compatibility Configuration
 *
 * This configuration extends the base Playwright config to enable
 * comprehensive testing across all major browsers:
 * - Chromium (Chrome, Edge)
 * - Firefox
 * - WebKit (Safari)
 *
 * Usage:
 *   npx playwright test --config=tests/e2e/cross-browser.config.ts
 *   Or use the npm script: npm run test:cross-browser
 */

const isCI = !!process.env.CI;
const isHeadless = process.env.HEADLESS !== 'false';

// Browser-specific configurations with cross-browser optimizations
const browserConfigs = {
  chromium: {
    timeout: 30000,
    retries: isCI ? 2 : 0,
    headless: isHeadless,
    launchOptions: {
      args: [
        '--disable-blink-features=AutomationControlled',
        '--disable-web-security', // For testing cross-origin scenarios
      ],
    },
  },
  firefox: {
    timeout: 35000,
    retries: isCI ? 2 : 0,
    headless: isHeadless,
    launchOptions: {
      firefoxUserPrefs: {
        'dom.webdriver.enabled': false,
        'useAutomationExtension': false,
        'devtools.jsonview.enabled': false,
      },
    },
  },
  webkit: {
    timeout: 40000,
    retries: isCI ? 3 : 0,
    headless: isHeadless,
  },
  edge: {
    timeout: 30000,
    retries: isCI ? 2 : 0,
    headless: isHeadless,
    channel: 'msedge',
  },
};

export default defineConfig({
  testDir: '.',

  // Run tests sequentially for cross-browser consistency
  fullyParallel: false,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: isCI,

  // Retry on CI only
  retries: isCI ? 2 : 0,

  // Opt out of parallel tests for cross-browser stability
  workers: 1,

  // Reporter configuration
  reporter: [
    ['html', {
      open: 'never',
      outputFolder: 'playwright-report/cross-browser'
    }],
    ['json', {
      outputFile: 'test-results/cross-browser/results.json'
    }],
    ['junit', {
      outputFile: 'test-results/cross-browser/results.xml'
    }],
    ['line'],
  ],

  // Shared settings for all projects
  use: {
    // Base URL for testing
    baseURL: process.env.BASE_URL || 'http://localhost:8082',

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Take screenshot on failure
    screenshot: 'only-on-failure',

    // Record video on failure
    video: 'retain-on-failure',

    // Global test timeout
    actionTimeout: 10000,
    navigationTimeout: 30000,

    // Ignore HTTPS errors
    ignoreHTTPSErrors: true,

    // Extra HTTP headers
    extraHTTPHeaders: {
      'Accept-Language': 'en-US,en;q=0.9',
    },

    // Viewport size
    viewport: { width: 1280, height: 720 },

    // Context options
    contextOptions: {
      // Bypass CSP for testing
      bypassCSP: true,
    },
  },

  // Configure projects for all major browsers
  projects: [
    // Desktop Chrome
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        ...browserConfigs.chromium,
      },
    },

    // Desktop Firefox
    {
      name: 'firefox',
      use: {
        ...devices['Desktop Firefox'],
        ...browserConfigs.firefox,
      },
    },

    // Desktop Safari (WebKit)
    {
      name: 'webkit',
      use: {
        ...devices['Desktop Safari'],
        ...browserConfigs.webkit,
      },
    },

    // Desktop Edge (Chromium-based)
    {
      name: 'edge',
      use: {
        ...devices['Desktop Edge'],
        ...browserConfigs.edge,
      },
    },

    // Mobile Chrome (Android)
    {
      name: 'mobile-chrome',
      use: {
        ...devices['Pixel 5'],
        ...browserConfigs.chromium,
      },
    },

    // Mobile Safari (iOS)
    {
      name: 'mobile-safari',
      use: {
        ...devices['iPhone 13'],
        ...browserConfigs.webkit,
      },
    },

    // Cross-browser compatibility tests
    {
      name: 'cross-browser-tests',
      testMatch: '**/cross-browser-compatibility.spec.ts',
      use: {
        ...devices['Desktop Chrome'],
        ...browserConfigs.chromium,
      },
    },
  ],

  // Web server configuration
  webServer: [
    {
      command: 'cd examples/comprehensive-demo && python3 -m http.server 8001',
      port: 8001,
      reuseExistingServer: true,
      timeout: 30 * 1000,
      stdout: 'pipe',
      stderr: 'pipe',
    },
  ],

  // Global setup and teardown
  globalSetup: require.resolve('./global-setup.ts'),
  globalTeardown: require.resolve('./global-teardown.ts'),

  // Test timeout
  timeout: 30 * 1000,

  expect: {
    timeout: 5 * 1000,
  },

  // Output directory for test artifacts
  outputDir: 'test-results/cross-browser/',

  // Global test timeout
  globalTimeout: isCI ? 120 * 60 * 1000 : 60 * 60 * 1000,

  // Maximum number of test failures
  maxFailures: isCI ? 20 : undefined,

  // Update snapshots
  updateSnapshots: process.env.UPDATE_SNAPSHOTS === 'true' ? 'all' : 'none',

  // Ignore test files
  testIgnore: [
    '**/node_modules/**',
    '**/dist/**',
    '**/build/**',
    '**/.git/**',
    '**/performance*.spec.ts', // Skip performance tests in cross-browser runs
  ],

  // Test match patterns
  testMatch: [
    '**/*.spec.ts',
    '**/*.test.ts',
  ],

  // Metadata for test results
  metadata: {
    testSuite: 'cross-browser-compatibility',
    testEnvironment: isCI ? 'ci' : 'local',
    browserCoverage: ['chromium', 'firefox', 'webkit', 'edge'],
    mobileCoverage: ['mobile-chrome', 'mobile-safari'],
    performanceThresholds: {
      maxInitializationTime: 5000,
      maxFirstPaint: 3000,
      maxFirstContentfulPaint: 4000,
      maxInteractionLatency: 100,
    },
  },
});

// Export configuration for use in other files
export { browserConfigs };
