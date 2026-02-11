/**
 * Visual regression testing utilities
 * Provides comprehensive visual testing for UI components
 */

import { PNG } from 'pngjs';
import * as pixelmatch from 'pixelmatch';
import { promises as fs } from 'fs';
import { resolve } from 'path';

/**
 * Theme configuration for visual testing
 */
export interface ThemeConfig {
  name: string;
  id: string;
  // Storybook theme ID
  themeId: string;
}

/**
 * Viewport configuration for responsive testing
 */
export interface ViewportConfig {
  name: string;
  width: number;
  height: number;
  deviceScaleFactor?: number;
  isMobile?: boolean;
}

/**
 * Visual test case configuration
 */
export interface VisualTestCase {
  name: string;
  component: string;
  story: string;
  themes: ThemeConfig[];
  viewports: ViewportConfig[];
  variants?: Record<string, string>[];
}

/**
 * Visual comparison result
 */
export interface VisualComparisonResult {
  passed: boolean;
  diffPercentage: number;
  mismatchedPixels: number;
  totalPixels: number;
  diffImagePath?: string;
}

/**
 * Predefined themes
 */
export const THEMES: ThemeConfig[] = [
  { name: 'Default Light', id: 'default-light', themeId: 'light' },
  { name: 'Default Dark', id: 'default-dark', themeId: 'dark' },
  { name: 'New York Light', id: 'new-york-light', themeId: 'new-york-light' },
  { name: 'New York Dark', id: 'new-york-dark', themeId: 'new-york-dark' },
];

/**
 * Predefined viewports
 */
export const VIEWPORTS: ViewportConfig[] = [
  { name: 'desktop', width: 1920, height: 1080, deviceScaleFactor: 1, isMobile: false },
  { name: 'laptop', width: 1366, height: 768, deviceScaleFactor: 1, isMobile: false },
  { name: 'tablet', width: 768, height: 1024, deviceScaleFactor: 2, isMobile: true },
  { name: 'mobile', width: 375, height: 667, deviceScaleFactor: 2, isMobile: true },
];

/**
 * Visual testing threshold configuration
 */
export interface ThresholdConfig {
  // Maximum allowed pixel difference percentage (0-1)
  pixelDiffThreshold: number;
  // Maximum allowed mismatched pixels
  maxMismatchedPixels: number;
  // Whether to ignore anti-aliasing differences
  ignoreAntiAliasing: boolean;
}

export const DEFAULT_THRESHOLD: ThresholdConfig = {
  pixelDiffThreshold: 0.0001, // 0.01% difference
  maxMismatchedPixels: 100,
  ignoreAntiAliasing: true,
};

/**
 * Compare two PNG images and return the difference
 */
export async function compareImages(
  image1Path: string,
  image2Path: string,
  diffImagePath: string,
  config: ThresholdConfig = DEFAULT_THRESHOLD
): Promise<VisualComparisonResult> {
  const [img1, img2] = await Promise.all([
    fs.readFile(image1Path),
    fs.readFile(image2Path),
  ]);

  const png1 = PNG.sync.read(img1);
  const png2 = PNG.sync.read(img2);

  const { width, height } = png1;
  const diff = new PNG({ width, height });

  const mismatchedPixels = (pixelmatch as any).default(
    png1.data,
    png2.data,
    diff.data,
    width,
    height,
    {
      threshold: 0.1,
      includeAA: !config.ignoreAntiAliasing,
    }
  );

  const totalPixels = width * height;
  const diffPercentage = mismatchedPixels / totalPixels;

  // Only write diff image if there are differences
  if (mismatchedPixels > 0) {
    await fs.writeFile(diffImagePath, PNG.sync.write(diff));
  }

  const passed = diffPercentage <= config.pixelDiffThreshold &&
                 mismatchedPixels <= config.maxMismatchedPixels;

  return {
    passed,
    diffPercentage,
    mismatchedPixels,
    totalPixels,
    diffImagePath: mismatchedPixels > 0 ? diffImagePath : undefined,
  };
}

/**
 * Generate a consistent filename for screenshots
 */
export function generateScreenshotFilename(
  component: string,
  story: string,
  theme: string,
  viewport: string,
  variant?: string
): string {
  const parts = [
    component,
    story,
    theme,
    viewport,
  ];

  if (variant) {
    parts.push(variant);
  }

  return parts.filter(Boolean).join('_') + '.png';
}

/**
 * Parse component and story from Storybook URL
 */
export function parseStorybookUrl(url: string): { component: string; story: string } {
  const match = url.match(/\/path\/to\/([^/]+)\/([^/?]+)/);
  if (match) {
    return { component: match[1], story: match[2] };
  }
  throw new Error(`Invalid Storybook URL: ${url}`);
}

/**
 * Calculate perceptual hash of an image for fuzzy matching
 */
export async function calculatePerceptualHash(imagePath: string): Promise<string> {
  const img = await fs.readFile(imagePath);
  const png = PNG.sync.read(img);

  // Simple average hash algorithm
  const { width, height } = png;
  const pixels: number[] = [];

  // Calculate average gray value
  let total = 0;
  for (let y = 0; y < height; y += 8) {
    for (let x = 0; x < width; x += 8) {
      const idx = (y * width + x) * 4;
      const gray = (png.data[idx] + png.data[idx + 1] + png.data[idx + 2]) / 3;
      pixels.push(gray);
      total += gray;
    }
  }

  const avg = total / pixels.length;

  // Generate hash based on comparison to average
  let hash = '';
  for (const pixel of pixels) {
    hash += pixel > avg ? '1' : '0';
  }

  return hash;
}

/**
 * Calculate Hamming distance between two hashes
 */
export function hammingDistance(hash1: string, hash2: string): number {
  if (hash1.length !== hash2.length) {
    throw new Error('Hashes must be of equal length');
  }

  let distance = 0;
  for (let i = 0; i < hash1.length; i++) {
    if (hash1[i] !== hash2[i]) {
      distance++;
    }
  }

  return distance;
}

/**
 * Crop image to content bounds (removes empty space)
 */
export async function cropToContent(imagePath: string, outputPath: string): Promise<void> {
  const img = await fs.readFile(imagePath);
  const png = PNG.sync.read(img);

  const { width, height, data } = png;

  let minX = width, minY = height, maxX = 0, maxY = 0;
  let foundContent = false;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const idx = (y * width + x) * 4;
      const alpha = data[idx + 3];

      if (alpha > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        foundContent = true;
      }
    }
  }

  if (!foundContent) {
    // No content found, copy original
    await fs.writeFile(outputPath, img);
    return;
  }

  const cropWidth = maxX - minX + 1;
  const cropHeight = maxY - minY + 1;
  const cropped = new PNG({ width: cropWidth, height: cropHeight });

  for (let y = 0; y < cropHeight; y++) {
    for (let x = 0; x < cropWidth; x++) {
      const srcIdx = ((minY + y) * width + (minX + x)) * 4;
      const dstIdx = (y * cropWidth + x) * 4;
      cropped.data[dstIdx] = data[srcIdx];
      cropped.data[dstIdx + 1] = data[srcIdx + 1];
      cropped.data[dstIdx + 2] = data[srcIdx + 2];
      cropped.data[dstIdx + 3] = data[srcIdx + 3];
    }
  }

  await fs.writeFile(outputPath, PNG.sync.write(cropped));
}

/**
 * Normalize image for consistent comparison
 */
export async function normalizeImage(
  inputPath: string,
  outputPath: string
): Promise<void> {
  await cropToContent(inputPath, outputPath);
}
