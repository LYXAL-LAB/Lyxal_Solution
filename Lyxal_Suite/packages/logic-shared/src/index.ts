// Types principaux
export type {
  Dict,
  OperatorFn,
  EngineContext,
  OperatorMeta,
  OperatorPlugin
} from './types.js';

// Erreurs
export * from './errors.js';

// Registry et plugins
export * from './registry.js';
export * from './plugin.js';

// Meta (sans conflit avec OperatorMeta)
export {
  compileMeta,
  validateMeta,
  OperatorMetaError
} from './meta/index.js';

// Instances (avec renommage pour éviter conflits)
export {
  runInstanceUI,
  OperatorInstanceError as UIOperatorInstanceError
} from './runInstance.ui.js';

export {
  runInstanceBackend,
  OperatorInstanceError as BackendOperatorInstanceError
} from './runInstance.backend.js';

// Plugin System Exports
export { 
  createPluginRegistry,
  PluginRegistry 
} from './plugins/pluginRegistry.js';

export { validatePlugin } from './plugins/validatePlugin.js';

// Types utiles
export type {
  CompiledPluginIndex,
  CompiledOperatorMeta,
  LoadedPlugin,
  OperatorResolver
} from './plugins/pluginRegistry.js';
