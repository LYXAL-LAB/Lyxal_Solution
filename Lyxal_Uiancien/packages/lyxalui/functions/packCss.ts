// Types TypeScript
interface PackCssOptions {
  outputFile: string;
  exclude?: {
    colors?: string[];
    components?: string[];
    utilities?: string[];
  };
}

interface DirectoryMap {
  [key: string]: string | false;
}

// Import des dépendances
import fs from "fs/promises";
import path from "path";
import { getFileNames } from "./getFileNames.ts";
import { cleanCss } from "./cleanCss.ts";

const readFileContent = async (filePath: string): Promise<string> => {
  return await fs.readFile(filePath, "utf8");
};

const getThemeDirs = (): string[] => ["light", "dark"];

const createThemePath = (theme: string): string => path.join("./theme", `${theme}.css`);

const wrapThemeContent = (contents: string[]): string => `@layer base{\n${contents.join("\n")}\n}`;

const readThemeCSS = async (): Promise<string> => {
  const themeDirs: string[] = getThemeDirs();
  const themeContents: string[] = await Promise.all(
    themeDirs.map((theme: string) => readFileContent(createThemePath(theme))),
  );
  return wrapThemeContent(themeContents);
};

const directoryMap: DirectoryMap = {
  "./base": false,
  "./components": false,
  "./utilities": false,
  "./colors": "utilities",
};

const wrapInLayer = (content: string, layerName: string | false): string => {
  return layerName ? `@layer ${layerName}{\n${content}\n}` : content;
};

const filterExcludedFiles = (files: string[], excludeFiles: string[]): string[] => {
  return files.filter((file: string) => !excludeFiles.includes(`${file}.css`));
};

const readDirectoryContent = async (
  directory: string,
  layerName: string | false,
  excludeFiles: string[] = [],
): Promise<string[]> => {
  const files: string[] = await getFileNames(directory, ".css", false);
  const filteredFiles: string[] = filterExcludedFiles(files, excludeFiles);

  const contents: string[] = await Promise.all(
    filteredFiles.map(async (file: string): Promise<string> => {
      const content: string = await readFileContent(`${directory}/${file}.css`);
      return wrapInLayer(content, layerName);
    }),
  );

  return contents;
};

const readAllCSSDirectories = async (excludeFiles: string[] = []): Promise<string[]> => {
  const directories: string[] = Object.keys(directoryMap);

  const allContents: string[][] = await Promise.all(
    directories.map((dir: string) => readDirectoryContent(dir, directoryMap[dir] ?? false, excludeFiles)),
  );

  return allContents.flat();
};

const combineContent = (themeCSS: string, otherCSS: string[]): string => {
  return [themeCSS, ...otherCSS].join("\n");
};

const writeContentToFile = async (file: string, content: string): Promise<void> => {
  const cleanedContent: string = cleanCss(content);
  await fs.writeFile(file, cleanedContent);
};

export const packCss = async ({
  outputFile,
  exclude = {
    colors: [],
    components: [],
    utilities: [],
  },
}: PackCssOptions): Promise<void> => {
  const allExcludeFiles: string[] = [
    ...(exclude.colors?.map((file: string) => `${file}.css`) || []),
    ...(exclude.components?.map((file: string) => `${file}.css`) || []),
    ...(exclude.utilities?.map((file: string) => `${file}.css`) || []),
  ];
  const [themeCSS, otherCSS] = await Promise.all([
    readThemeCSS(),
    readAllCSSDirectories(allExcludeFiles),
  ]);

  const allContent: string = combineContent(themeCSS, otherCSS);
  await writeContentToFile(outputFile, allContent);
};
