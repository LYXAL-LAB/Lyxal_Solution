// Types TypeScript
interface ThemeResult {
  defaultTheme: string;
  theme: string;
}

interface CompileOptions {
  polyfills: number;
}

// Import des dépendances
import { promises as fs } from "fs";
import path from "path";

// Fonctions pour charger et compiler les thèmes
export async function loadThemes(): Promise<ThemeResult> {
  const dirname = String(import.meta.dirname);
  const [defaultTheme, theme] = await Promise.all([
    fs.readFile(
      path.join(dirname, "../../../node_modules/tailwindcss/theme.css"),
      "utf-8"
    ),
    fs.readFile(
      path.join(dirname, "./variables.css"),
      "utf-8"
    ),
  ]);
  return { defaultTheme, theme };
}

export async function compileAndExtractStyles(
  styleContent: string,
  defaultTheme: string,
  theme: string,
): Promise<string> {
  const { compile } = await import("tailwindcss");

  const compiledContent = (
    await compile(
      `
    @layer theme{${defaultTheme}${theme}}
    @layer wrapperStart{${styleContent}}
    @layer wrapperEnd
  `,
      {
        // Polyfills:
        // None = 0,
        // AtProperty = 1,
        // ColorMix = 2,
        // All = 3
        polyfills: 1, // AtProperty only, excludes ColorMix
      } as CompileOptions,
    )
  ).build([]);

  const startIndex: number = compiledContent.indexOf("@layer wrapperStart");
  const endIndex: number = compiledContent.indexOf("@layer wrapperEnd");

  if (startIndex === -1 || endIndex === -1) {
    throw new Error("Failed to find wrapper layers in compiled content");
  }

  const openingBraceIndex: number = compiledContent.indexOf("{", startIndex);
  const closingBraceIndex: number = compiledContent.lastIndexOf("}", endIndex);

  if (
    openingBraceIndex === -1 ||
    closingBraceIndex === -1 ||
    openingBraceIndex >= closingBraceIndex
  ) {
    throw new Error("Invalid wrapper structure in compiled content");
  }

  return compiledContent.substring(openingBraceIndex + 1, closingBraceIndex).trim();
}
