// packages/logic-shared/src/engine/evaluate.ts
import { createEngineConfig, type EngineConfigOptions } from './createEngineConfig.js';
import { EngineContext, type EngineContextOptions } from './EngineContext.js';
import { interpolate, type ExecuteOperatorFn } from './interpolate.js';

export interface EvaluateOptions {
  // moteur
  config?: Omit<EngineConfigOptions, 'registry'>;

  // données d'exécution
  variables?: EngineContextOptions['variables'];
  scope?: EngineContextOptions['scope'];
}

/**
 * Exécute une structure JSON avec le moteur Lyxal (plugins inclus)
 *
 * @param input - JSON contenant potentiellement des opérateurs
 * @param registry - PluginRegistry à utiliser
 * @param execOp - Fonction qui exécute réellement un opérateur
 * @param options - Variables, scope et config additionnelle
 */
export function evaluate(
  input: any,
  registry: EngineContextOptions['config']['registry'],
  execOp: ExecuteOperatorFn,
  options: EvaluateOptions = {}
): any {
  const config = createEngineConfig({
    registry,
    ...(options.config ?? {})
  });

  const ctx = new EngineContext({
    config,
    variables: options.variables,
    scope: options.scope,
  });

  return interpolate(input, ctx, execOp);
}
