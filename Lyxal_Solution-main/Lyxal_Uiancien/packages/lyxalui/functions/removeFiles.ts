// Import des dépendances
import { promises as fs } from "fs";
import { resolve } from "path";

export const removeFiles = async (items: string[] = []): Promise<void> => {
  const removePromises: Promise<void>[] = items.map(async (item: string): Promise<void> => {
    const itemPath: string = resolve(item);

    try {
      const stats: any = await fs.lstat(itemPath);
      if (stats.isDirectory()) {
        await fs.rmdir(itemPath, { recursive: true });
      } else {
        await fs.unlink(itemPath);
      }
    } catch (error: any) {
      if (error.code !== "ENOENT") {
        throw error;
      }
    }
  });

  await Promise.all(removePromises);
};
