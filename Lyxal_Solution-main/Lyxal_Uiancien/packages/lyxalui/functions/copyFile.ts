// Types TypeScript
interface CopyFileOptions {
  (from: string, to: string, newName?: string | null): Promise<void>;
}

// Import des dépendances
import fs from "fs/promises";
import path from "path";

// Fonction pour copier un fichier
export const copyFile: CopyFileOptions = async (from: string, to: string, newName: string | null = null): Promise<void> => {
  try {
    const destDir: string = path.dirname(to);
    await fs.mkdir(destDir, { recursive: true });

    let destPath: string = to;
    if (newName) {
      destPath = path.join(destDir, newName);
    }

    await fs.copyFile(from, destPath);
  } catch (error: any) {
    throw new Error(`Error copying file from ${from} to ${to}: ${error.message}`);
  }
};
