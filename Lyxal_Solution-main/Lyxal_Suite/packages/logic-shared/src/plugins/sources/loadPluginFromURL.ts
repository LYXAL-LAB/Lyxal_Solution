// packages/logic-shared/src/plugins/sources/loadPluginFromURL.ts
import type { LoadedPlugin, CompiledPluginIndex, CompiledOperatorMeta } from '../pluginRegistry.js';

/**
 * Charge un plugin depuis une URL.
 * indexUrl doit pointer vers index.json
 * ex: https://cdn.lyxal.com/plugins/date/1.0.0/index.json
 */
export async function loadPluginFromURL(indexUrl: string): Promise<LoadedPlugin> {
  // 1. Charger index.json
  const indexRes = await fetch(indexUrl);
  if (!indexRes.ok) {
    throw new Error(`Failed to fetch plugin index from URL: ${indexUrl} - ${indexRes.status} ${indexRes.statusText}`);
  }
  const index: CompiledPluginIndex = await indexRes.json();

  // 2. Charger tous les opérateurs listés dans index
  const baseUrl = indexUrl.replace(/\/index\.json$/, '');
  const operators: Record<string, CompiledOperatorMeta> = {};

  for (const op of index.operators) {
    const fileUrl = `${baseUrl}/${op.file}`;
    const opRes = await fetch(fileUrl);
    if (!opRes.ok) {
      throw new Error(`Failed to fetch operator "${op.name}" from ${fileUrl} - ${opRes.status}`);
    }
    const opMeta: CompiledOperatorMeta = await opRes.json();
    operators[op.file] = opMeta;
  }

  // 3. Construire l’objet LoadedPlugin
  const plugin: LoadedPlugin = {
    index,
    operators,
    source: 'url',
    basePath: baseUrl,
  };

  return plugin;
}
