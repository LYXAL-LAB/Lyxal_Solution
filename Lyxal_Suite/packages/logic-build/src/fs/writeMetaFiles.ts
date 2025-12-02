import fs from 'node:fs/promises';
import path from 'node:path';

export interface WriteMetaOptions {
  outputDir: string;
  pluginId: string;
  index: any;
  files: Record<string, any>;
}

/**
 * Écrit les meta JSON d'un plugin vers le disque
 */
export async function writeMetaFiles({ outputDir, pluginId, index, files }: WriteMetaOptions) {
  const pluginDir = path.join(outputDir, pluginId);

  await fs.mkdir(pluginDir, { recursive: true });

  // Écriture fichiers opérateurs
  for (const [fileName, fileContent] of Object.entries(files)) {
    const filePath = path.join(pluginDir, fileName);
    await fs.writeFile(filePath, JSON.stringify(fileContent, null, 2), 'utf8');
  }

  // Écriture index.json
  const indexFile = path.join(pluginDir, 'index.json');
  await fs.writeFile(indexFile, JSON.stringify(index, null, 2), 'utf8');

  return pluginDir;
}
