// Import des dépendances
import fs from "fs/promises";
import path from "path";
import { getFileNames } from "./getFileNames.ts";
import themeOrder from "./themeOrder.ts";

const readFileContent = async (filePath: string): Promise<string> => {
  return await fs.readFile(filePath, "utf8");
};

const readAllThemeCSS = async (): Promise<string> => {
  // Get all file names in the ./theme folder with the .css extension
  const themeDirs: string[] = await getFileNames("./theme", ".css", false);

  // Read the content of each theme CSS file and store in an object
  const themeContents: Record<string, string> = {};
  await Promise.all(
    themeDirs.map(async (themeDir: string): Promise<void> => {
      const content: string = await readFileContent(path.join("./theme", `${themeDir}.css`));
      themeContents[themeDir] = content;
    }),
  );

  // Sort themes according to the specified order
  const sortedThemeContents: string[] = themeOrder
    .filter((theme: string) => themeDirs.includes(theme))
    .map((theme: string) => themeContents[theme])
    .filter((content: string | undefined): content is string => content !== undefined);

  return sortedThemeContents.join("\n");
};

export const generateThemes = async (outputFile: string): Promise<void> => {
  try {
    // Read all theme CSS files
    const themeContent: string = await readAllThemeCSS();

    // Write the combined theme content to the output file
    await fs.writeFile(outputFile, themeContent);
  } catch (error: any) {
    throw new Error("Error generating themes:", error);
  }
};
