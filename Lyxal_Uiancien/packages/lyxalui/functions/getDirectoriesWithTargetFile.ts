// Import des dépendances
import fs from "fs/promises";
import path from "path";

export const getDirectoriesWithTargetFile = async (directory: string, targetFile: string): Promise<string[]> => {
  const files: string[] = await fs.readdir(directory);
  const filteredDirs: string[] = [];

  for (const file of files) {
    const filePath: string = path.join(directory, file);
    const stats: any = await fs.stat(filePath);

    if (stats.isDirectory()) {
      try {
        await fs.access(path.join(filePath, targetFile));
        filteredDirs.push(file);
      } finally {
        // File doesn't exist, skip this directory
      }
    }
  }

  return filteredDirs;
};
