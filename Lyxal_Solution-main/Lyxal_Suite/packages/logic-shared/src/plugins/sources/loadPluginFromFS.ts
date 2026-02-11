// packages/logic-shared/src/plugins/sources/loadPluginFromFS.ts
import fs from 'node:fs/promises';
import path from 'node:path';
import type { LoadedPlugin, CompiledPluginIndex, CompiledOperatorMeta } from '../pluginRegistry.js';

export async function loadPluginFromFS(pluginDir: string): Promise<LoadedPlugin> {
  // 1. Lire index.json
  const indexPath = path.join(pluginDir, 'index.json');
  const indexRaw = await fs.readFile(indexPath, 'utf8');
  const index: CompiledPluginIndex = JSON.parse(indexRaw);

  // 2. Lire tous les fichiers opérateurs listés dans index
  const operators: Record<string, CompiledOperatorMeta> = {};

  for (const op of index.operators) {
    const opFilePath = path.join(pluginDir, op.file);
    const opRaw = await fs.readFile(opFilePath, 'utf8');
    const opMeta: CompiledOperatorMeta = JSON.parse(opRaw);
    operators[op.file] = opMeta;
  }

  // 3. Construire l’objet LoadedPlugin
  const plugin: LoadedPlugin = {
    index,
    operators,
    source: 'fs',
    basePath: pluginDir,
  };

  return plugin;
}
