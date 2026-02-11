// Types TypeScript
interface GenerateRawStylesOptions {
  srcDir: string;
  distDir: string;
  responsive?: boolean;
  exclude?: string[];
  layer?: string | null;
}

interface PostcssSelectorParser {
  (callback: (selectors: any) => void): {
    processSync: (selector: string) => string;
  };
}

// Import des dépendances
import fs from "fs/promises";
import path from "path";
import { getFileNames } from "./getFileNames.ts";
import { cleanCss } from "./cleanCss.ts";
import breakpoints from "./breakpoints.ts";
import postcss from "postcss";
import selectorParser from "postcss-selector-parser";
import { compileAndExtractStyles, loadThemes } from "./compileAndExtractStyles.ts";

// transform selectors with breakpoint prefix
export function transformSelector(selector: string, breakpoint: string): string {
  return selectorParser((selectors: any) => {
    selectors.each((selector: any) => {
      if (selector.first.type === "class") {
        selector.first.value = `${breakpoint}:${selector.first.value}`;
      }
    });
  }).processSync(selector);
}

// escape breakpoint colons in CSS
export function escapeBreakpointColon(css: string, breakpoint: string): string {
  return css.replace(new RegExp(`\\.${breakpoint}:`, "g"), `.${breakpoint}\\:`);
}

// wrap styles in layer
export function wrapInLayer(styles: string, layer: string | null): string {
  return layer ? `@layer ${layer} {\n${styles}\n}` : styles;
}

// generate media query
export function generateMediaQuery(breakpoint: string, minWidth: string, styles: string): string {
  return `\n@media (min-width: ${minWidth}) {\n${styles}\n}\n\n`;
}

// extract keyframes
export function extractKeyframes(root: any): string {
  let keyframesStyles: string = "";
  root.walkAtRules("keyframes", (atRule: any) => {
    keyframesStyles += atRule.toString();
    atRule.remove();
  });
  return keyframesStyles;
}

export async function generateResponsiveVariants(css: string): Promise<string> {
  let responsiveStyles: string = "";
  const root: any = postcss.parse(css);

  const keyframesStyles: string = extractKeyframes(root);

  for (const [breakpoint, minWidth] of Object.entries(breakpoints)) {
    const prefixedCss: any = await postcss([
      (root: any) => {
        root.walkRules((rule: any) => {
          if (rule.parent.type === "root") {
            rule.selector = transformSelector(rule.selector, breakpoint);
          }
        });
      },
    ] as any).process(root.toString(), {} as any);

    const escapedCss: string = escapeBreakpointColon(prefixedCss.css, breakpoint);
    responsiveStyles += generateMediaQuery(breakpoint, minWidth as string, escapedCss);
  }

  return css + responsiveStyles + keyframesStyles;
}

async function processFile(
  file: string,
  stylesDir: string,
  distDir: string,
  defaultTheme: string,
  theme: string,
  responsive: boolean,
  exclude: string[],
  layer: string | null,
): Promise<void> {
  const styleContent: string = await fs.readFile(path.join(stylesDir, `${distDir}/${file}.css`), "utf-8");
  let stylesContent: string = await compileAndExtractStyles(styleContent, defaultTheme, theme);

  if (responsive && !exclude.includes(file)) {
    stylesContent = await generateResponsiveVariants(stylesContent);
  }

  stylesContent = cleanCss(stylesContent);

  if (layer) {
    stylesContent = `@layer ${layer} {\n${stylesContent}\n}`;
  }

  await fs.writeFile(
    path.join(import.meta.dirname!, distDir, `${distDir}/${file}.css`),
    stylesContent,
  );
}

export async function generateRawStyles({
  srcDir,
  distDir,
  responsive = false,
  exclude = [],
  layer = null,
}: GenerateRawStylesOptions): Promise<void> {
  try {
    const { defaultTheme, theme } = await loadThemes();

    const stylesDir: string = path.join(import.meta.dirname!, srcDir);
    const files: string[] = await getFileNames(stylesDir, ".css", false);

    // Process all files concurrently
    const processPromises: Promise<void>[] = files.map((file: string) =>
      processFile(file, stylesDir, distDir, defaultTheme, theme, responsive, exclude, layer).catch(
        (fileError: any) => {
          throw new Error(`Error processing file ${file}: ${fileError.message}`);
        },
      ),
    );

    // Wait for all files to be processed
    await Promise.all(processPromises);
  } catch (error: any) {
    console.error("An error occurred while generating raw styles:", error);
    process.exit(1);
  }
}
