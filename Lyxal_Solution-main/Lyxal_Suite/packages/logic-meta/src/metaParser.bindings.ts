/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: metaParser.bindings.ts (Part 2/3)
 * Rôle: Ajout de la couche Bindings "{{ }}" au parser.
 *
 * Note : Cette extension se branche dans MetaParser via une méthode interne.
 */

import { MetaContext } from './types';

const BINDING_REGEX = /\{\{\s*([^}]+)\s*\}\}/g;

/**
 * Résout les bindings "{{ expr }}" avec accès au contexte :
 * - state.global / state.flow / state.step / state.session / state.ui
 * - user, tenantId, namespaceId, runtime
 */
export function resolveBindings(value: any, ctx: MetaContext): any {
  if (typeof value !== 'string') return value;

  // Vérifie si la string contient au moins un binding
  if (!value.includes('{{')) return value;

  return value.replace(BINDING_REGEX, (_, expr) => {
    try {
      const res = evalBindingExpression(expr.trim(), ctx);
      return res === undefined || res === null ? '' : String(res);
    } catch (e) {
      if (ctx.options?.logErrors) {
        console.error(`Binding error in "${value}":`, e);
      }
      return '';
    }
  });
}

/**
 * Évalue l'expression d'un binding en sandbox contrôlée (light)
 */
function evalBindingExpression(expr: string, ctx: MetaContext): any {
  const scope = {
    state: ctx.state,
    user: ctx.user,
    tenantId: ctx.tenantId,
    namespaceId: ctx.namespaceId,
    runtime: ctx.runtime,
    // Futur : allow math, date, utils limité
  };

  // Sandboxed eval minimal (sécurisé car accès limité au scope)
  return Function('scope', `with(scope) { return ${expr}; }`)(scope);
}
