// Import des dépendances
import { promises as fs } from "fs";
import path from "path";

// Fonction pour créer un répertoire basé sur le nom du fichier
export const createDirectoryBasedOnFileNames = async (
  fileName: string,
  fileExtension: string,
  distDir: string,
): Promise<string> => {
  const componentName: string = path.basename(fileName, fileExtension);
  const componentDir: string = path.join(distDir, componentName);
  await fs.mkdir(componentDir, { recursive: true });
  return componentDir;
};
