# Visual Regression Testing Implementation Summary

This document summarizes the complete visual regression testing implementation for the leptos-shadcn-ui project.

## Overview

A comprehensive visual testing framework has been implemented using Playwright to detect unintended UI changes across themes, browsers, and viewports.

## What Was Implemented

### 1. Core Testing Framework (`packages/visual-testing/src/`)

#### `visual-tester.ts`
- Image comparison utilities using pixelmatch
- Multi-theme configuration (Default Light/Dark, New York Light/Dark)
- Multi-viewport configuration (Desktop, Laptop, Tablet, Mobile)
- Threshold configuration for diff tolerance
- Perceptual hashing for fuzzy matching
- Image normalization and cropping utilities

#### `playwright-helpers.ts`
- `VisualTestFixture` class for Playwright integration
- Storybook navigation helpers
- Screenshot capture with animation disabling
- Element hiding for cleaner screenshots
- Baseline comparison workflow
- Theme and viewport test helpers

#### `index.ts`
- Main `VisualTestingFramework` class
- Simplified API for common testing scenarios
- Exports of all utilities and constants

### 2. Visual Tests (`packages/visual-testing/tests/`)

#### `button.visual.spec.ts`
- Tests across 6 variants (default, destructive, outline, secondary, ghost, link)
- Tests 4 sizes (sm, default, lg, icon)
- Tests states (normal, disabled, loading, hover, focus, active)
- Responsive testing across viewports
- Dark mode testing
- RTL support testing
- Performance test (100 buttons)

#### `input.visual.spec.ts`
- Tests all input types (text, email, password, number, tel, url)
- Tests states (default, focus, disabled, error)
- Tests with labels, helpers, icons
- Form layout testing
- Accessibility attribute testing
- Performance test (50 inputs)

#### `card.visual.spec.ts`
- Tests with all sections (header, content, footer)
- Tests variations (outlined, filled, with shadows)
- Tests with different content types (images, forms, tables, lists)
- Grid layout testing
- Dark mode testing
- Accessibility testing
- Performance test (20 cards)

### 3. Configuration Files

#### `playwright.config.ts`
- Multi-browser projects (Chromium, Firefox, WebKit)
- Multi-viewport testing
- Storybook server configuration
- Reporter configuration (HTML, JSON, JUnit)
- Screenshot and video settings

#### `package.json`
- Scripts for running tests
- Dependencies (Playwright, pixelmatch, pngjs)
- TypeScript configuration

#### `tsconfig.json`
- TypeScript compilation settings
- Type definitions

### 4. CI/CD Integration (`.github/workflows/visual-tests.yml`)

**Workflow Features:**
- Runs on push, pull request, and schedule
- Matrix strategy for browsers and viewports
- Storybook build and startup
- Parallel test execution
- Artifact upload (results, screenshots, reports)
- PR comments with test results
- Snapshot update workflow

**Jobs:**
1. `visual-tests` - Main testing job with matrix strategy
2. `update-snapshots` - Updates baselines when triggered
3. `summary` - Aggregates test results

### 5. Scripts (`packages/visual-testing/scripts/`)

#### `run-visual-tests.sh`
- Shell script for running visual tests
- Supports updating snapshots
- Supports headed/debug modes
- Component-specific testing
- Report generation

### 6. Documentation (`packages/visual-testing/docs/`)

#### `README.md`
- Framework overview
- Installation instructions
- Quick start guide
- Configuration examples
- Best practices
- Troubleshooting

#### `api.md`
- Complete API reference
- All classes and methods
- Type definitions
- Usage examples
- Error handling

#### `troubleshooting.md`
- Common issues and solutions
- Installation problems
- Test failures
- Performance issues
- CI/CD issues
- Debugging tips

## Key Features

1. **Pixel-Perfect Comparison**
   - Uses pixelmatch for accurate diff detection
   - Configurable threshold (default 0.01%)
   - Anti-aliasing aware comparison
   - Diff image generation

2. **Multi-Theme Support**
   - Default theme (light/dark)
   - New York theme (light/dark)
   - Extensible for custom themes

3. **Responsive Testing**
   - Desktop: 1920x1080
   - Laptop: 1366x768
   - Tablet: 768x1024
   - Mobile: 375x667

4. **Browser Coverage**
   - Chromium (Chrome/Edge)
   - Firefox
   - WebKit (Safari)

5. **CI/CD Ready**
   - GitHub Actions workflow
   - Parallel execution
   - Artifact management
   - PR integration

## File Structure

```
packages/visual-testing/
├── src/
│   ├── index.ts                 # Main exports
│   ├── visual-tester.ts         # Core utilities
│   └── playwright-helpers.ts    # Playwright helpers
├── tests/
│   ├── button.visual.spec.ts    # Button tests
│   ├── input.visual.spec.ts     # Input tests
│   └── card.visual.spec.ts      # Card tests
├── scripts/
│   └── run-visual-tests.sh      # Test runner
├── docs/
│   ├── README.md                # Main docs
│   ├── api.md                   # API reference
│   └── troubleshooting.md       # Troubleshooting
├── .github/
│   └── workflows/
│       └── visual-tests.yml     # CI workflow
├── playwright.config.ts         # Playwright config
├── package.json                 # Dependencies
├── tsconfig.json                # TS config
└── README.md                    # Package readme
```

## Usage

### Running Tests

```bash
# Install dependencies
cd packages/visual-testing
npm install

# Install Playwright browsers
npx playwright install --with-deps

# Run tests
npm test

# Update baselines
npm run test:update

# Run in headed mode
npm run test:headed

# Debug tests
npm run test:debug
```

### Writing Tests

```typescript
import { test } from '@playwright/test';
import { createVisualFramework, THEMES, VIEWPORTS } from '@shadcn-ui/visual-testing';

test('my component visual test', async ({ page }) => {
  const framework = createVisualFramework(page);

  await framework.testStory('components-mycomponent', 'default', {
    themes: THEMES.slice(0, 2),
    viewports: [VIEWPORTS[0], VIEWPORTS[3]],
    threshold: 0.0001,
  });
});
```

## Integration with Existing Code

The visual testing framework integrates with:

1. **Storybook** - Tests run against Storybook stories
2. **test-utils** - Extends existing testing infrastructure
3. **Component packages** - Tests Button, Input, Card components
4. **CI/CD** - GitHub Actions workflow for automation

## Next Steps

To expand visual testing to other components:

1. Create test file: `tests/<component>.visual.spec.ts`
2. Add tests for variants, states, themes
3. Run tests and create baselines: `npm run test:update`
4. Commit baselines to repository
5. CI will automatically run tests on changes

## Benefits

1. **Catch UI Regressions** - Detect unintended visual changes
2. **Multi-Theme Confidence** - Ensure themes work correctly
3. **Responsive Validation** - Test across screen sizes
4. **Cross-Browser Testing** - Validate in different browsers
5. **Automated Workflow** - CI/CD integration prevents bad merges
6. **Detailed Reports** - HTML reports with diff images

## Technical Notes

- Uses Playwright for browser automation
- pixelmatch for image comparison
- PNG image format for lossless compression
- Baseline images stored in `screenshots/baseline/`
- Diff images generated in `screenshots/diff/`
- Threshold of 0.0001 = 0.01% difference allowed
- Anti-aliasing differences ignored by default
