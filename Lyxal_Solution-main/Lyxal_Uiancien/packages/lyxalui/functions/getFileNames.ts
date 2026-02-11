// Import des dépendances
import { promises as fs } from "fs";
import path from "path";

export const getFileNames = async (dir: string, extension: string, recursive: boolean = true): Promise<string[]> => {
  let fileNames: string[] = [];
  const files: any[] = await fs.readdir(dir, { withFileTypes: true });

  for (const file of files) {
    const filePath: string = path.join(dir, file.name);

    if (file.isDirectory() && recursive) {
      const subDirFiles: string[] = await getFileNames(filePath, extension, recursive);
      fileNames = fileNames.concat(subDirFiles);
    } else if (file.isFile() && file.name.endsWith(extension)) {
      // Extract the file name without extension
      const fileName: string = path.basename(file.name, extension);
      fileNames.push(fileName);
    }
  }

  return fileNames;
};
