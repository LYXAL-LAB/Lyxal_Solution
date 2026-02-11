// packages/logic-shared/src/engine/resolveOperator.ts
import type { EngineContext } from './EngineContext.js';
import type { CompiledOperatorMeta } from '../plugins/pluginRegistry.js';

export interface ResolvedOperator {
  name: string;
  meta: CompiledOperatorMeta;
  pluginId: string;
  source: 'fs' | 'url' | 'db';
}

/**
 * Trouve la meta d’un opérateur via le PluginRegistry.
 * Retourne undefined si l’opérateur n’est pas reconnu.
 */
export function resolveOperator(opName: string, ctx: EngineContext): ResolvedOperator | undefined {
  const resolver = ctx.registry.getOperator(opName);
  if (!resolver) return undefined;

  return {
    name: opName,
    meta: resolver.meta,
    pluginId: resolver.pluginId,
    source: resolver.source,
  };
}
