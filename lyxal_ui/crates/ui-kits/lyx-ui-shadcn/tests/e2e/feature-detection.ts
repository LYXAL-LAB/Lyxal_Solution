/**
 * Feature Detection Utilities for E2E Testing
 *
 * This module provides utilities for detecting browser capabilities
 * and dynamic loading features in the application.
 */

export interface BrowserCapabilities {
  webAssembly: boolean;
  sharedArrayBuffer: boolean;
  bigInt: boolean;
  userAgent: string;
  language: string;
  platform: string;
  supportsDynamicImport: boolean;
  supportsModuleScripts: boolean;
  supportsWorker: boolean;
  supportsServiceWorker: boolean;
}

export interface WASMFeatures {
  simd: boolean;
  threads: boolean;
  bulkMemory: boolean;
  referenceTypes: boolean;
  exceptions: boolean;
  multiValue: boolean;
  tailCalls: boolean;
  extensions: string[];
}

export interface LoadingFeatureDetection {
  hasLazyLoadingUI: boolean;
  hasDynamicLoaderUI: boolean;
  hasBundleAnalysis: boolean;
  hasSearchAndFilter: boolean;
  hasFavoritesSystem: boolean;
  hasErrorHandling: boolean;
  componentCount: number;
  categoryCount: number;
}

export interface PerformanceMetrics {
  firstPaint: number | null;
  firstContentfulPaint: number | null;
  domContentLoaded: number | null;
  loadComplete: number | null;
  wasmInitTime: number | null;
}

/**
 * Detect browser capabilities
 */
export async function detectBrowserCapabilities(
  page: import('@playwright/test').Page
): Promise<BrowserCapabilities> {
  return await page.evaluate(() => {
    return {
      webAssembly: typeof WebAssembly !== 'undefined',
      sharedArrayBuffer: typeof SharedArrayBuffer !== 'undefined',
      bigInt: typeof BigInt !== 'undefined',
      userAgent: navigator.userAgent,
      language: navigator.language,
      platform: navigator.platform,
      supportsDynamicImport: typeof Symbol !== 'undefined' && Symbol.for('') === Symbol.for(''),
      supportsModuleScripts:
        'noModule' in HTMLScriptElement.prototype ||
        (document.createElement('script') as any).noModule === true,
      supportsWorker: typeof Worker !== 'undefined',
      supportsServiceWorker: 'serviceWorker' in navigator,
    } as BrowserCapabilities;
  });
}

/**
 * Detect WASM-specific features
 */
export async function detectWASMFeatures(
  page: import('@playwright/test').Page
): Promise<WASMFeatures> {
  return await page.evaluate(async () => {
    const features: WASMFeatures = {
      simd: false,
      threads: false,
      bulkMemory: false,
      referenceTypes: false,
      exceptions: false,
      multiValue: false,
      tailCalls: false,
      extensions: [],
    };

    if (typeof WebAssembly === 'undefined') {
      return features;
    }

    try {
      // Test for SIMD support
      const simdModule = new WebAssembly.Module(
        new Uint8Array([
          0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x05, 0x01, 0x60,
          0x00, 0x01, 0x7c, 0x03, 0x02, 0x01, 0x00, 0x0a, 0x09, 0x01, 0x07, 0x00,
          0x20, 0x00, 0xfd, 0x01, 0x0b,
        ])
      );
      features.simd = WebAssembly.validate(simdModule);

      // Test for bulk memory operations
      const bulkMemoryModule = new WebAssembly.Module(
        new Uint8Array([
          0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x05, 0x01, 0x60,
          0x00, 0x01, 0x7f, 0x03, 0x02, 0x01, 0x00, 0x05, 0x03, 0x01, 0x00, 0x02,
          0x0a, 0x0b, 0x01, 0x09, 0x00, 0x41, 0x00, 0xfc, 0x0a, 0x00, 0x00, 0x00,
          0x0b,
        ])
      );
      features.bulkMemory = WebAssembly.validate(bulkMemoryModule);

      // Test for reference types
      const refTypesModule = new WebAssembly.Module(
        new Uint8Array([
          0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x05, 0x01, 0x60,
          0x00, 0x01, 0x6f, 0x03, 0x02, 0x01, 0x00, 0x0a, 0x08, 0x01, 0x06, 0x00,
          0xd0, 0x70, 0x00, 0x0b,
        ])
      );
      features.referenceTypes = WebAssembly.validate(refTypesModule);

      // Test for exceptions
      const exceptionsModule = new WebAssembly.Module(
        new Uint8Array([
          0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x05, 0x01, 0x60,
          0x00, 0x01, 0x7f, 0x03, 0x02, 0x01, 0x00, 0x08, 0x01, 0x01, 0x0a, 0x08,
          0x01, 0x06, 0x00, 0x05, 0x00, 0x11, 0x0b,
        ])
      );
      features.exceptions = WebAssembly.validate(exceptionsModule);

      // Test for multi-value
      const multiValueModule = new WebAssembly.Module(
        new Uint8Array([
          0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00, 0x01, 0x06, 0x01, 0x60,
          0x00, 0x02, 0x7f, 0x7f, 0x03, 0x02, 0x01, 0x00, 0x0a, 0x07, 0x01, 0x05,
          0x00, 0x41, 0x00, 0x41, 0x00, 0x0b,
        ])
      );
      features.multiValue = WebAssembly.validate(multiValueModule);

      // Collect additional extensions
      const wasmMemory = new WebAssembly.Memory({ initial: 1, maximum: 10 });
      features.extensions.push('memory-limit');
    } catch (e) {
      console.warn('Error detecting WASM features:', e);
    }

    return features;
  });
}

/**
 * Detect loading features in the application
 */
export async function detectLoadingFeatures(
  page: import('@playwright/test').Page
): Promise<LoadingFeatureDetection> {
  const detection: LoadingFeatureDetection = {
    hasLazyLoadingUI: false,
    hasDynamicLoaderUI: false,
    hasBundleAnalysis: false,
    hasSearchAndFilter: false,
    hasFavoritesSystem: false,
    hasErrorHandling: false,
    componentCount: 0,
    categoryCount: 0,
  };

  // Check for lazy loading sections
  const lazySection = await page.locator('h3:has-text("Lazy Loaded Components")').count();
  detection.hasLazyLoadingUI = lazySection > 0;

  // Check for dynamic loader sections
  const dynamicSection = await page.locator('h3:has-text("Dynamic WASM Components")').count();
  detection.hasDynamicLoaderUI = dynamicSection > 0;

  // Check for bundle analysis
  const bundlePanel = await page.locator('.panel.bundle-analysis, .bundle-status, .loader-status').count();
  detection.hasBundleAnalysis = bundlePanel > 0;

  // Check for search and filter
  const searchInput = await page.locator('input[placeholder*="search" i], input[type="search"]').count();
  const categoryFilter = await page.locator('select, .category-filter, .filter-controls').count();
  detection.hasSearchAndFilter = searchInput > 0 || categoryFilter > 0;

  // Check for favorites system
  const favoriteBtns = await page.locator('.favorite-btn, .favorite-toggle, button:has-text("☆")').count();
  detection.hasFavoritesSystem = favoriteBtns > 0;

  // Check for error handling
  const errorComponents = await page.locator('.component-error, .error-state, .retry-btn').count();
  detection.hasErrorHandling = errorComponents > 0;

  // Count components
  const lazyComponents = await page.locator('.lazy-component-wrapper').count();
  const dynamicComponents = await page.locator('.dynamic-component-wrapper').count();
  detection.componentCount = lazyComponents + dynamicComponents;

  // Count categories
  const categories = await page.locator('h4:has-text("Form & Input"), h4:has-text("Layout & Navigation"), h4:has-text("Overlay & Feedback"), h4:has-text("Data & Media")').count();
  detection.categoryCount = categories;

  return detection;
}

/**
 * Get performance metrics from the page
 */
export async function getPerformanceMetrics(
  page: import('@playwright/test').Page
): Promise<PerformanceMetrics> {
  return await page.evaluate(() => {
    const metrics: PerformanceMetrics = {
      firstPaint: null,
      firstContentfulPaint: null,
      domContentLoaded: null,
      loadComplete: null,
      wasmInitTime: null,
    };

    // Get paint timings
    const paintEntries = performance.getEntriesByType('paint');
    paintEntries.forEach((entry: any) => {
      if (entry.name === 'first-paint') {
        metrics.firstPaint = entry.startTime;
      } else if (entry.name === 'first-contentful-paint') {
        metrics.firstContentfulPaint = entry.startTime;
      }
    });

    // Get navigation timings
    const navEntries = performance.getEntriesByType('navigation');
    if (navEntries.length > 0) {
      const navEntry = navEntries[0] as any;
      metrics.domContentLoaded = navEntry.domContentLoadedEventEnd;
      metrics.loadComplete = navEntry.loadEventEnd;
    }

    // Get WASM initialization time if available
    if ((window as any).wasmInitTime) {
      metrics.wasmInitTime = (window as any).wasmInitTime;
    }

    return metrics;
  });
}

/**
 * Detect if a specific component type is loaded
 */
export async function isComponentLoaded(
  page: import('@playwright/test').Page,
  componentName: string
): Promise<boolean> {
  const component = page.locator(`.lazy-component-wrapper, .dynamic-component-wrapper`).filter({
    hasText: componentName,
  });

  if ((await component.count()) === 0) {
    return false;
  }

  const hasLoadedClass = await component.locator('.component-success:visible, .lazy-component-loaded:visible').count();
  const hasLoadingClass = await component.locator('.component-loading:visible').count();
  const hasPlaceholderClass = await component.locator('.component-placeholder:visible').count();

  return hasLoadedClass > 0 && hasLoadingClass === 0 && hasPlaceholderClass === 0;
}

/**
 * Get component loading state
 */
export async function getComponentLoadingState(
  page: import('@playwright/test').Page,
  componentName: string
): Promise<'loaded' | 'loading' | 'placeholder' | 'error' | 'not-found'> {
  const component = page.locator(`.lazy-component-wrapper, .dynamic-component-wrapper`).filter({
    hasText: componentName,
  });

  if ((await component.count()) === 0) {
    return 'not-found';
  }

  if ((await component.locator('.component-success:visible, .lazy-component-loaded:visible').count()) > 0) {
    return 'loaded';
  }

  if ((await component.locator('.component-loading:visible').count()) > 0) {
    return 'loading';
  }

  if ((await component.locator('.component-error:visible').count()) > 0) {
    return 'error';
  }

  if ((await component.locator('.component-placeholder:visible').count()) > 0) {
    return 'placeholder';
  }

  return 'not-found';
}

/**
 * Wait for component to load with timeout
 */
export async function waitForComponentLoad(
  page: import('@playwright/test').Page,
  componentName: string,
  timeout = 10000
): Promise<boolean> {
  try {
    await page
      .locator(`.lazy-component-wrapper, .dynamic-component-wrapper`)
      .filter({ hasText: componentName })
      .locator('.component-success:visible, .lazy-component-loaded:visible')
      .waitFor({ timeout });
    return true;
  } catch {
    return false;
  }
}

/**
 * Get loading progress for a component
 */
export async function getComponentLoadingProgress(
  page: import('@playwright/test').Page,
  componentName: string
): Promise<number> {
  const component = page.locator(`.lazy-component-wrapper, .dynamic-component-wrapper`).filter({
    hasText: componentName,
  });

  const progressText = await component.locator('.progress-text').textContent();
  if (progressText) {
    const match = progressText.match(/(\d+)%/);
    if (match) {
      return parseInt(match[1], 10);
    }
  }

  // Try to get progress from progress bar width
  const progressBar = component.locator('.progress-fill');
  if ((await progressBar.count()) > 0) {
    const style = await progressBar.getAttribute('style');
    if (style) {
      const match = style.match(/width:\s*(\d+)%/);
      if (match) {
        return parseInt(match[1], 10);
      }
    }
  }

  return 0;
}

/**
 * Check if WASM is properly initialized
 */
export async function isWASMInitialized(page: import('@playwright/test').Page): Promise<boolean> {
  return await page.evaluate(() => {
    return typeof (window as any).wasmBindings !== 'undefined';
  });
}

/**
 * Get bundle size information
 */
export async function getBundleSizeInfo(page: import('@playwright/test').Page): Promise<{
  initialBundle: string;
  loadedComponents: number;
  totalSize: string;
  optimization: string;
} | null> {
  const bundlePanel = page.locator('.panel.bundle-analysis, .bundle-status, .loader-status');

  if ((await bundlePanel.count()) === 0) {
    return null;
  }

  const text = await bundlePanel.textContent();
  if (!text) {
    return null;
  }

  const info = {
    initialBundle: '',
    loadedComponents: 0,
    totalSize: '',
    optimization: '',
  };

  const bundleMatch = text.match(/Bundle Size:\s*([\d.]+\s*(?:MB|KB|GB))/i);
  if (bundleMatch) {
    info.initialBundle = bundleMatch[1];
  }

  const componentsMatch = text.match(/Components:\s*(\d+)/i);
  if (componentsMatch) {
    info.loadedComponents = parseInt(componentsMatch[1], 10);
  }

  const totalSizeMatch = text.match(/Total Size:\s*([\d.]+\s*(?:MB|KB|GB|KB))/i);
  if (totalSizeMatch) {
    info.totalSize = totalSizeMatch[1];
  }

  const optimizationMatch = text.match(/Optimization:\s*([\d.]+%)/i);
  if (optimizationMatch) {
    info.optimization = optimizationMatch[1];
  }

  return info;
}

/**
 * Get all component categories
 */
export async function getComponentCategories(
  page: import('@playwright/test').Page
): Promise<string[]> {
  const categories: string[] = [];

  const categoryHeaders = await page
    .locator('h4')
    .allTextContents();

  for (const header of categoryHeaders) {
    if (
      header.includes('Form & Input') ||
      header.includes('Layout & Navigation') ||
      header.includes('Overlay & Feedback') ||
      header.includes('Data & Media')
    ) {
      categories.push(header.trim());
    }
  }

  return categories;
}

/**
 * Get list of all component names
 */
export async function getComponentNames(page: import('@playwright/test').Page): Promise<string[]> {
  const names: string[] = [];

  const componentHeaders = await page
    .locator('.lazy-component-wrapper h4, .dynamic-component-wrapper h4, .component-title')
    .allTextContents();

  for (const name of componentHeaders) {
    const trimmed = name.trim();
    if (trimmed && !trimmed.includes('★') && !trimmed.includes('☆')) {
      names.push(trimmed);
    }
  }

  return names;
}
