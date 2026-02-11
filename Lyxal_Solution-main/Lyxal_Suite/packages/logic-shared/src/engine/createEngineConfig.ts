// packages/logic-shared/src/engine/createEngineConfig.ts
import type { PluginRegistry } from '../plugins/pluginRegistry.js';

export interface EngineConfigOptions {
  registry: PluginRegistry;      // Registry injecté
  logLevel?: 'none' | 'error' | 'warn' | 'info' | 'debug';
  strictOperators?: boolean;     // Si true → interdit les opérateurs inconnus
  allowUnsafe?: boolean;         // Si false → interdit certains opérateurs (futur)
}

export interface EngineConfig {
  registry: PluginRegistry;
  logLevel: 'none' | 'error' | 'warn' | 'info' | 'debug';
  strictOperators: boolean;
  allowUnsafe: boolean;
}

export function createEngineConfig(options: EngineConfigOptions): EngineConfig {
  return {
    registry: options.registry,
    logLevel: options.logLevel ?? 'error',
    strictOperators: options.strictOperators ?? false,
    allowUnsafe: options.allowUnsafe ?? false,
  };
}
