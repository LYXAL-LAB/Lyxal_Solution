// Import des dépendances
import fs from "fs/promises";
import { getDirectoriesWithTargetFile } from "./getDirectoriesWithTargetFile.ts";

const generateJSContent = async (): Promise<{ content: string }> => {
  // Create separate arrays for each category
  let baseItems: string[] = [];
  let componentItems: string[] = [];
  let utilityItems: string[] = [];
  let imports: string = "";

  try {
    // Function to process each category
    const processCategory = async (category: string): Promise<void> => {
      const items: string[] = await getDirectoriesWithTargetFile(`./${category}`, "index.ts");
      items.forEach((item: string) => {
        const importName: string = `${item}`;
        imports += `import ${importName} from './${category}/${item}/index.ts';\n`;

        // Add items to their respective arrays
        switch (category) {
          case "base":
            baseItems.push(importName);
            break;
          case "components":
            componentItems.push(importName);
            break;
          case "utilities":
            utilityItems.push(importName);
            break;
        }
      });
    };

    // Process all categories
    await processCategory("base");
    await processCategory("components");
    await processCategory("utilities");

    // Generate the content with separate exports
    const content: string = `${imports}
export const base = {${baseItems.join(",")}};
export const components = {${componentItems.join(",")}};
export const utilities = {${utilityItems.join(",")}};
`;

    return { content };
  } catch (error: any) {
    throw new Error(`Failed to generate JS content: ${error.message}`);
  }
};

// Write the generated content to a file
const writeToFile = async (content: string, filename: string): Promise<void> => {
  try {
    await fs.writeFile(filename, content, "utf8");
  } catch (error: any) {
    throw new Error(`Failed to write file ${filename}: ${error.message}`);
  }
};

// Main function to generate JS
export const generateImports = async (filename: string): Promise<void> => {
  try {
    const { content: jsContent } = await generateJSContent();
    await writeToFile(jsContent, filename);
  } catch (error: any) {
    throw new Error(`Failed to generate ${filename}: ${error.message}`);
  }
};
