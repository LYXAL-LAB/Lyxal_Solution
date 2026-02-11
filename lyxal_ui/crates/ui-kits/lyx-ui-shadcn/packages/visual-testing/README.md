# @shadcn-ui/visual-testing

Visual regression testing framework for shadcn-ui components using Playwright.

## Features

- Pixel-perfect visual comparison
- Multi-theme testing (light/dark, default/New York)
- Multi-browser support (Chromium, Firefox, WebKit)
- Responsive viewport testing (desktop, tablet, mobile)
- CI/CD integration with GitHub Actions
- Detailed HTML reports with diff images

## Quick Start

```bash
# Install dependencies
npm install

# Install Playwright browsers
npx playwright install --with-deps

# Run visual tests
npm test

# Run tests in headed mode (show browser)
npm run test:headed

# Update baseline snapshots
npm run test:update

# View test report
npm run test:report
```

## Documentation

- [Full Documentation](./docs/README.md)
- [API Reference](./docs/api.md)
- [Troubleshooting Guide](./docs/troubleshooting.md)

## Test Structure

```
tests/
├── button.visual.spec.ts   # Button component tests
├── input.visual.spec.ts    # Input component tests
└── card.visual.spec.ts     # Card component tests
```

## Screenshots

```
screenshots/
├── baseline/    # Baseline reference images
├── actual/      # Current test screenshots
└── diff/        # Difference images (when tests fail)
```

## Example Test

```typescript
import { test } from '@playwright/test';
import { createVisualFramework, THEMES, VIEWPORTS } from '@shadcn-ui/visual-testing';

test('button visual test', async ({ page }) => {
  const framework = createVisualFramework(page);

  await framework.testStory('components-button', 'default', {
    themes: THEMES,
    viewports: VIEWPORTS,
    threshold: 0.0001,
  });
});
```

## CI/CD

Visual tests run automatically on:
- Push to main/develop branches
- Pull requests
- Daily schedule (2 AM UTC)
- Manual workflow trigger

See [`.github/workflows/visual-tests.yml`](./.github/workflows/visual-tests.yml)

## License

MIT
