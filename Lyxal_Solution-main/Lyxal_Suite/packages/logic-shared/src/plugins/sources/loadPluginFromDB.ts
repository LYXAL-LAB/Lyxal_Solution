// packages/logic-shared/src/plugins/sources/loadPluginFromDB.ts
import type { LoadedPlugin, CompiledPluginIndex, CompiledOperatorMeta } from '../pluginRegistry.js';

/**
 * Charge un plugin stocké dans SurrealDB.
 *
 * Structure DB attendue :
 *
 * Record principal :
 * plugin:<id> {
 *   pluginId: "@lyxal/op-date-instance",
 *   version: "1.0.0",
 *   operators: ["plugin_operator:abc", "plugin_operator:def"]
 * }
 *
 * Chaque operator record :
 * plugin_operator:<id> {
 *   file: "op-date-instance-adddays.json",
 *   meta: { ...CompiledOperatorMeta }
 * }
 */
export async function loadPluginFromDB(args: {
  db: any; // Surreal adapter - doit avoir .select() ou .query()
  pluginRecordId: string; // ex: "plugin:date_instance"
}): Promise<LoadedPlugin> {
  const { db, pluginRecordId } = args;

  // 1. Lire le record plugin
  const pluginRecord = await db.select(pluginRecordId);
  if (!pluginRecord) {
    throw new Error(`Plugin not found in DB: ${pluginRecordId}`);
  }

  // Construire l’index local (même forme que FS/URL)
  const index: CompiledPluginIndex = {
    pluginId: pluginRecord.pluginId,
    version: pluginRecord.version,
    operators: [],
  };

  const operators: Record<string, CompiledOperatorMeta> = {};

  // 2. Lire chaque opérateur lié
  for (const opRef of pluginRecord.operators ?? []) {
    const opRecord = await db.select(opRef);
    if (!opRecord) {
      throw new Error(`Missing operator record: ${opRef}`);
    }

    const file = opRecord.file;
    const meta = opRecord.meta as CompiledOperatorMeta;

    index.operators.push({
      name: meta.name,
      file,
      category: meta.category,
      version: meta.version,
      deprecated: meta.deprecated,
      tags: meta.tags
    });

    operators[file] = meta;
  }

  // 3. Construire l’objet LoadedPlugin
  const plugin: LoadedPlugin = {
    index,
    operators,
    source: 'db',
    basePath: pluginRecordId, // référence logique
    raw: pluginRecord
  };

  return plugin;
}
