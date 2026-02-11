// packages/logic-shared/src/plugins/pluginRegistry.ts
import path from 'node:path';

export interface PluginOperatorIndexItem {
  name: string;              // ex: "$date.instance.addDays"
  file: string;              // ex: "op-date-instance-adddays.json"
  category?: string;
  deprecated?: boolean;
  version?: string;
  tags?: string[];
}

export interface CompiledPluginIndex {
  pluginId: string;          // ex: "@lyxal/op-date-instance"
  version: string;           // ex: "1.0.0"
  operators: PluginOperatorIndexItem[];
}

export interface CompiledOperatorMeta {
  // miroir du JSON généré par compileMeta (Étape 2)
  name: string;
  description?: string;
  category: string;
  version: string;
  deprecated?: boolean;
  tags?: string[];

  instanceOf?: string;
  args?: any[];
  returns?: string;
  returnInstance?: boolean;

  permissions?: any;
  examples?: any[];
  autoDocs?: boolean;

  uiExample?: any;
  backendExample?: any;
  isPure?: boolean;
  complexity?: number;

  ai?: {
    embedding?: string;
    usageExamples?: string[];
    commonMistakes?: string[];
    naturalLanguage?: string[];
  };
}

export interface LoadedPlugin {
  index: CompiledPluginIndex;
  operators: Record<string, CompiledOperatorMeta>; // key = operator file name
  source: 'fs' | 'url' | 'db';
  basePath?: string;     // fs: dossier plugin, url: base URL, db: namespace logique
  raw?: unknown;         // data brute éventuelle (signature, meta store, etc.)
}

export type OperatorResolver = {
  pluginId: string;
  source: 'fs' | 'url' | 'db';
  meta: CompiledOperatorMeta;
};

export class PluginRegistry {
  private plugins = new Map<string, LoadedPlugin>();
  private operatorByName = new Map<string, OperatorResolver>();

  // —— Register a plugin already loaded (used by loaders)
  registerPlugin(plugin: LoadedPlugin) {
    const { index, operators, source, basePath } = plugin;
    if (!index?.pluginId) {
      throw new Error('PluginRegistryError: index.pluginId is required.');
    }

    // overwrite allowed -> last loaded wins (could add version strategy later)
    this.plugins.set(index.pluginId, { ...plugin });

    // index operators by name
    for (const op of index.operators) {
      const file = op.file;
      const meta = operators[file];
      if (!meta || meta.name !== op.name) {
        // safety: file should match meta.name
        // we still register if meta exists but warn
        // (no console.log here to keep engine quiet)
      }
      this.operatorByName.set(op.name, {
        pluginId: index.pluginId,
        source,
        meta: meta ?? {
          // fallback minimal
          name: op.name,
          category: op.category ?? 'custom',
          version: op.version ?? index.version,
        } as CompiledOperatorMeta,
      });
    }
  }

  // —— Query
  hasPlugin(pluginId: string) {
    return this.plugins.has(pluginId);
  }

  getPlugin(pluginId: string): LoadedPlugin | undefined {
    return this.plugins.get(pluginId);
  }

  listPlugins(): Array<{ pluginId: string; version: string; source: 'fs' | 'url' | 'db' }> {
    return Array.from(this.plugins.values()).map((p) => ({
      pluginId: p.index.pluginId,
      version: p.index.version,
      source: p.source,
    }));
  }

  listOperators(): string[] {
    return Array.from(this.operatorByName.keys()).sort();
  }

  hasOperator(name: string) {
    return this.operatorByName.has(name);
  }

  getOperator(name: string): OperatorResolver | undefined {
    return this.operatorByName.get(name);
  }

  // —— Convenience: compute file path or URL to the operator JSON
  //     (useful for Studio / debugging)
  resolveOperatorLocation(name: string): { kind: 'fs' | 'url' | 'db'; pathOrUrl?: string } | undefined {
    const res = this.operatorByName.get(name);
    if (!res) return undefined;
    const plugin = this.plugins.get(res.pluginId);
    if (!plugin) return undefined;

    const opIndex = plugin.index.operators.find((o) => o.name === name);
    if (!opIndex) return undefined;

    switch (plugin.source) {
      case 'fs':
        return {
          kind: 'fs',
          pathOrUrl: plugin.basePath ? path.join(plugin.basePath, opIndex.file) : undefined,
        };
      case 'url':
        return {
          kind: 'url',
          pathOrUrl: plugin.basePath
            ? plugin.basePath.replace(/\/+$/, '') + '/' + opIndex.file
            : undefined,
        };
      case 'db':
        // For DB, pathOrUrl is a logical reference; read loaders later.
        return { kind: 'db', pathOrUrl: `${res.pluginId}:${opIndex.file}` };
      default:
        return undefined;
    }
  }

  // —— Loaders (delegates) — implemented in next files and re-exported here
  //     We expose friendly methods that call helper functions you will add:
  async loadFromFS(pluginDir: string): Promise<void> {
    const { loadPluginFromFS } = await import('./sources/loadPluginFromFS.js');
    const loaded = await loadPluginFromFS(pluginDir);
    this.registerPlugin(loaded);
  }

  async loadFromURL(indexUrl: string): Promise<void> {
    const { loadPluginFromURL } = await import('./sources/loadPluginFromURL.js');
    const loaded = await loadPluginFromURL(indexUrl);
    this.registerPlugin(loaded);
  }

  async loadFromDB(args: {
    // Surreal connection or adapter will be described in loader file
    db: any;
    pluginRecordId: string; // ex: plugin:date_instance
  }): Promise<void> {
    const { loadPluginFromDB } = await import('./sources/loadPluginFromDB.js');
    const loaded = await loadPluginFromDB(args);
    this.registerPlugin(loaded);
  }
}

// —— Factory
export function createPluginRegistry() {
  return new PluginRegistry();
}
