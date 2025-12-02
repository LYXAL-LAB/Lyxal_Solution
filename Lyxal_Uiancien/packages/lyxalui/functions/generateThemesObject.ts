// Import des dépendances
import fs from "fs/promises";
import path from "path";

export const generateThemesObject = async (outputPath: string): Promise<void> => {
  const themesDir: string = path.join(import.meta.dirname!, "../theme");
  const themeObjects: Record<string, any> = {};

  const themeNames: string[] = await fs.readdir(themesDir);

  // Use Promise.all to parallelize theme imports
  await Promise.all(
    themeNames.map(async (themeName: string): Promise<void> => {
      const themeObjectPath: string = path.join(themesDir, themeName, "object.ts");
      if (
        await fs
          .stat(themeObjectPath)
          .then((stats: any) => stats.isFile())
          .catch(() => false)
      ) {
        try {
          const themeModule: any = await import(themeObjectPath);
          themeObjects[themeName] = themeModule.default;
        } catch (error: any) {
          throw new Error(`Error importing theme: ${themeName}`, error);
        }
      }
    }),
  );

  // Convert themeObjects to a string in the desired format
  const themeObjectsString: string = `export default ${JSON.stringify(themeObjects)}`;

  // Write the string to the specified output file
  await fs.writeFile(outputPath, themeObjectsString, "utf8");

  // types
  await generateThemesObjectDeclaration(outputPath.replace(".ts", ".d.ts"), themeObjects);
};

const generateThemesObjectDeclaration = async (outputPath: string, themeObjects: Record<string, any>): Promise<void> => {
  const themeNames: string[] = Object.keys(themeObjects);
  const typeDefinition: string = `export declare const themes: Record<string, Record<string, string>>;
export default themes;
`;

  await fs.writeFile(outputPath, typeDefinition, "utf8");
};
