import { OperatorMeta } from '../types/OperatorMeta.js';
import { compileMeta, CompiledOperatorMeta } from './compileMeta.js';

export interface CompiledPluginIndex {
  pluginId: string;
  version: string;
  operators: Array<{
    name: string;
    file: string; // relative path to JSON file for this operator
    category?: string;
    deprecated?: boolean;
    version?: string;
    tags?: string[];
  }>;
}

export function compileAll(
  pluginId: string,
  version: string,
  operators: OperatorMeta[]
): { index: CompiledPluginIndex; files: Record<string, CompiledOperatorMeta> } {
  const files: Record<string, CompiledOperatorMeta> = {};
  const list: CompiledPluginIndex['operators'] = [];

  for (const op of operators) {
    const compiled = compileMeta(op);

    // generate a file-friendly name like "op-date-instance-addDays.json"
    const fileName =
      'op-' +
      compiled.name
        .replace(/\$/g, '')
        .replace(/\./g, '-')
        .replace(/[^a-zA-Z0-9\-]/g, '')
        .toLowerCase() +
      '.json';

    files[fileName] = compiled;

    list.push({
      name: compiled.name,
      file: fileName,
      category: compiled.category,
      deprecated: compiled.deprecated,
      version: compiled.version,
      tags: compiled.tags,
    });
  }

  const index: CompiledPluginIndex = {
    pluginId,
    version,
    operators: list,
  };

  return { index, files };
}
