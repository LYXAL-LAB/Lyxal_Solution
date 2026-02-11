// packages/logic-shared/src/engine/EngineContext.ts
import type { EngineConfig } from './createEngineConfig.js';
import type { PluginRegistry } from '../plugins/pluginRegistry.js';

export interface EngineContextOptions {
  config: EngineConfig;
  variables?: Record<string, any>;
  scope?: Record<string, any>;
}

export class EngineContext {
  config: EngineConfig;
  registry: PluginRegistry;
  variables: Record<string, any>;
  scope: Record<string, any>;

  constructor(options: EngineContextOptions) {
    this.config = options.config;
    this.registry = options.config.registry;
    this.variables = options.variables ?? {};
    this.scope = options.scope ?? {};
  }

  // Permet de définir une variable accessible dans l’exécution
  setVar(key: string, value: any) {
    this.variables[key] = value;
  }

  getVar(key: string): any {
    return this.variables[key];
  }

  // Permet de manipuler le scope (utile pour blocks, loops…)
  setScopeValue(key: string, value: any) {
    this.scope[key] = value;
  }

  getScopeValue(key: string): any {
    return this.scope[key];
  }
}
