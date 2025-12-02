// Types TypeScript
interface ExtractClassesOptions {
  srcDir: string;
}

// Import des dépendances
import fs from "fs/promises";
import path from "path";

// Function to extract class names from CSS content
const extractClassNames = async (cssContent: string): Promise<string[]> => {
  const classRegex: RegExp =
    /\.([a-zA-Z_-][a-zA-Z0-9_-]*)(?=\s*[{,:(])|:where\(\.([a-zA-Z_-][a-zA-Z0-9_-]*)\)/g;
  const matches: RegExpMatchArray | null = cssContent.match(classRegex);
  const classNames: string[] = matches
    ? matches.map((match: string): string => {
        const cleanedMatch: string = match.replace(/:where\(\.|[{,:()]/g, "").trim();
        return cleanedMatch.startsWith(".") ? cleanedMatch.slice(1) : cleanedMatch;
      })
    : [];
  return [...new Set(classNames)]; // Remove duplicates
};

// Function to process a single CSS file
const processCssFile = async (srcDir: string, filePath: string): Promise<number> => {
  try {
    const cssContent: string = await fs.readFile(filePath, "utf8");
    const classNames: string[] = await extractClassNames(cssContent);

    const fileName: string = path.basename(filePath, ".css");
    const outputDir: string = path.join(import.meta.dirname!, "..", srcDir, fileName);
    const outputFilePath: string = path.join(outputDir, "class.json");

    // Create directory if it doesn't exist
    try {
      await fs.mkdir(outputDir, { recursive: true });
    } catch (err: any) {
      if (err.code !== "EEXIST") throw err;
    }

    // Create JSON string
    const jsonString: string = JSON.stringify(classNames, null, 2);

    // Write to a new JSON file
    await fs.writeFile(outputFilePath, jsonString);

    return classNames.length;
  } catch (error: any) {
    throw new Error(`Error processing file ${filePath}: ${error.message}`);
  }
};

// Function to process all CSS files
export const extractClasses = async ({ srcDir }: ExtractClassesOptions): Promise<number> => {
  try {
    // Read all CSS files from the styles directory
    const stylesDir: string = path.join(import.meta.dirname!, "..", "src", srcDir);
    const cssFiles: string[] = await fs.readdir(stylesDir);
    const filteredCssFiles: string[] = cssFiles.filter((file: string) => file.endsWith(".css"));

    if (filteredCssFiles.length === 0) {
      throw new Error("No CSS files found in the specified directory");
    }

    // Process each CSS file and sum up the total number of class names
    const classNameCounts: number[] = await Promise.all(
      filteredCssFiles.map(async (file: string): Promise<number> => {
        const filePath: string = path.join(stylesDir, file);
        return await processCssFile(srcDir, filePath);
      }),
    );

    const totalClassNames: number = classNameCounts.reduce((total: number, count: number) => total + count, 0);

    return totalClassNames;
  } catch (error: any) {
    throw new Error(`Error extracting classes: ${error.message}`);
  }
};
