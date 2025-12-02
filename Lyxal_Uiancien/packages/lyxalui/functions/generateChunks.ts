// Import des dépendances
import fs from "fs/promises";
import { getFileNames } from "./getFileNames.ts";
import themeOrder from "./themeOrder.ts";

// Fonction pour générer des chunks CSS
export const generateChunks = async (filename: string): Promise<void> => {
  try {
    let content: string = "";
    // let content = '@layer base, themes, components, utilities;\n';
    // content += `@import url(https://cdn.jsdelivr.net/npm/tailwindcss@next/preflight.min.css) layer(base);\n`;

    const themes: string[] = await getFileNames("./theme", ".css", false);
    const allowedThemes: string[] = ["light", "dark"];
    themeOrder.forEach((theme: string) => {
      if (themes.includes(theme) && allowedThemes.includes(theme)) {
        content += `@import url(theme/${theme}.css);\n`;
      }
    });

    const baseFiles: string[] = await getFileNames("./base", ".css", false);
    baseFiles.forEach((filePath: string) => {
      content += `@import url(base/${filePath}.css);\n`;
    });

    const componentFiles: string[] = await getFileNames("./components", ".css", false);
    componentFiles.forEach((filePath: string) => {
      content += `@import url(components/${filePath}.css);\n`;
    });

    const utilityFiles: string[] = await getFileNames("./utilities", ".css", false);
    utilityFiles.forEach((filePath: string) => {
      content += `@import url(utilities/${filePath}.css);\n`;
    });

    // Load color files with specific ordering
    const colorFiles: string[] = await getFileNames("./colors", ".css", false);
    colorFiles.forEach((filePath: string) => {
      content += `@import url(colors/${filePath}.css);\n`;
    });

    // Write to file
    await fs.writeFile(`./${filename}`, content, "utf8");
  } catch (error: any) {
    throw new Error(`Failed to generate full CSS: ${error.message}`);
  }
};
