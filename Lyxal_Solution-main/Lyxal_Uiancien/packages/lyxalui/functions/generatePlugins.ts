// Types TypeScript
type PluginType = "base" | "component" | "utility";

interface GeneratePluginsOptions {
  type: PluginType;
  srcDir: string;
  distDir: string;
  exclude?: string[];
}

// Import des dépendances
import fs from "fs/promises";
import { getFileNames } from "./getFileNames.ts";
import { cssToJs } from "./cssToJs.ts";
import { createDirectoryBasedOnFileNames } from "./createDirectoryBasedOnFileNames.ts";
import { createPluginFiles } from "./createPluginFiles.ts";

export const generatePlugins = async ({
  type,
  srcDir,
  distDir,
  exclude = [],
}: GeneratePluginsOptions): Promise<void> => {
  await fs.mkdir(distDir, { recursive: true });
  const cssFiles: string[] = await getFileNames(srcDir, ".css");
  const filteredCssFiles: string[] = cssFiles.filter((file: string) => !exclude.includes(file));

  await Promise.all(
    filteredCssFiles.map(async (cssFile: string): Promise<void> => {
      const [jsContent, componentDir] = await Promise.all([
        cssToJs(`${srcDir}/${cssFile}.css`),
        createDirectoryBasedOnFileNames(cssFile, ".css", distDir),
      ]);

      await createPluginFiles(type, componentDir, jsContent, cssFile);
    }),
  );
};
