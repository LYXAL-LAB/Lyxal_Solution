// Types TypeScript
interface CssObject {
  [key: string]: any;
}

// Import des dépendances
import { promises as fs } from "fs";
import postcss from "postcss";
import postcssJs from "postcss-js";
import { compileAndExtractStyles, loadThemes } from "./compileAndExtractStyles.ts";
import { replaceApplyTrueWithEmptyObject } from "./replaceApplyTrueWithEmptyObject.ts";
import { cleanCss } from "./cleanCss.ts";

// function to convert camelCase to kebab-case
const camelToKebab = (str: string): string => {
  return str.replace(/([a-z0-9])([A-Z])/g, "$1-$2").toLowerCase();
};

// Function to transform object keys from camelCase to kebab-case
const transformKeys = (obj: any): any => {
  if (typeof obj !== "object" || obj === null) return obj;

  if (Array.isArray(obj)) {
    return obj.map(transformKeys);
  }

  return Object.fromEntries(
    Object.entries(obj).map(([key, value]) => [
      camelToKebab(key),
      typeof value === "object" ? transformKeys(value) : value,
    ]),
  );
};

export const cssToJs = async (cssFile: string): Promise<string> => {
  try {
    // Read the CSS file
    const cssContent: string = await fs.readFile(cssFile, "utf-8");

    // Load themes
    const { defaultTheme, theme } = await loadThemes();

    // First convert Tailwind CSS to raw CSS
    const rawCss: string = await compileAndExtractStyles(cssContent, defaultTheme, theme);

    // Process with PostCSS to convert to JS object
    const result = await (postcss() as any).process(rawCss, {});
    const jsObject: CssObject = (postcssJs as any).objectify(result.root);

    // Transform camelCase keys to kebab-case
    const transformedObject: CssObject = transformKeys(jsObject);

    // Replace @apply true with empty object
    replaceApplyTrueWithEmptyObject(transformedObject);
    const processedObject: CssObject = transformedObject;

    // Clean the CSS
    const cleanedCss: string = cleanCss(JSON.stringify(processedObject, null, 2));

    return cleanedCss;
  } catch (error: any) {
    throw new Error(`Error converting CSS to JS for ${cssFile}: ${error.message}`);
  }
};
