// Types TypeScript
interface GenerateThemeFilesOptions {
  srcDir: string;
  distDir: string;
}

// Import des dépendances
import fs from "fs/promises";
import path from "path";
import { getFileNames } from "./getFileNames.ts";

export const wrapContent = (themeName: string, content: string): string => {
  if (themeName === "light") {
    return `:root,:root:has(input.theme-controller[value=${themeName}]:checked),[data-theme="${themeName}"] {
${content}}
`;
  }

  return `:root:has(input.theme-controller[value=${themeName}]:checked),[data-theme="${themeName}"] {
${content}}
`;
};

export const generateThemeFiles = async ({ srcDir, distDir }: GenerateThemeFilesOptions): Promise<void> => {
  const themeNames: string[] = await getFileNames(srcDir, ".css");

  const tasks: Promise<void>[] = themeNames.map(async (themeName: string): Promise<void> => {
    const srcPath: string = path.join(srcDir, `${themeName}.css`);
    const distPath: string = path.join(distDir, `${themeName}.css`);

    const content: string = await fs.readFile(srcPath, "utf-8");
    const wrappedContent: string = wrapContent(themeName, content);

    await fs.mkdir(path.dirname(distPath), { recursive: true });
    await fs.writeFile(distPath, wrappedContent);
  });

  await Promise.all(tasks);
};
