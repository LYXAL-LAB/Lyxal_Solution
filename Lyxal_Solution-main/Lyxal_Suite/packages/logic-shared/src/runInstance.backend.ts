import { OperatorMeta } from './meta/types/OperatorMeta.js';
import { validateMeta } from './meta/validators/validateMeta.js';

export class OperatorInstanceError extends Error {
  constructor(op: string, msg: string) {
    super(`OperatorInstanceError [${op}]: ${msg}`);
  }
}

function isType(val: any, type: string): boolean {
  switch (type) {
    case 'string': return typeof val === 'string';
    case 'number': return typeof val === 'number' && Number.isFinite(val);
    case 'boolean':return typeof val === 'boolean';
    case 'object': return val !== null && typeof val === 'object' && !Array.isArray(val);
    case 'array':  return Array.isArray(val);
    case 'date':   return typeof val === 'string' || val instanceof Date;
    case 'record': return val !== null && typeof val === 'object';
    case 'any':    return true;
    case 'null':   return val === null;
    default:       return true;
  }
}

/**
 * Backend engine version (Option 2): accepte
 *  A) liste: [instance, arg1, arg2, ...]
 *  B) objet: { on: instance, arg1: ..., arg2: ... }
 * meta.args décrit UNIQUEMENT les arguments hors instance (dans l’ordre).
 */
export function runInstanceBackend<TOut = any>({
  operator,
  method,
  params,
  meta,
  location,
  impl,        // (instance, ...args) => result | Promise<result>
}: {
  operator: string;
  method: string;
  params: any;              // array OU objet { on, ... }
  meta: OperatorMeta;
  location: string;
  impl: (instance: any, ...args: any[]) => TOut | Promise<TOut>;
}): TOut | Promise<TOut> {
  validateMeta(meta);
  if (!meta.instanceOf) {
    throw new OperatorInstanceError(operator, `meta.instanceOf manquant (ex: "date" | "array" | "object").`);
  }

  let instance: any;
  const argsSpec = meta.args ?? [];
  const args: any[] = [];

  // Extraire instance + args selon le format
  if (Array.isArray(params)) {
    if (params.length === 0) {
      throw new OperatorInstanceError(operator, `Syntaxe liste: instance manquante en premier élément @ ${location}`);
    }
    instance = params[0];
    // le reste = args positionnels, dans l’ordre déclaré par meta.args
    for (let i = 0; i < argsSpec.length; i++) {
      args.push(params[i + 1]);
    }
  } else if (params && typeof params === 'object') {
    instance = (params as any).on;
    if (typeof instance === 'undefined') {
      throw new OperatorInstanceError(operator, `Syntaxe objet: champ "on" (instance) manquant @ ${location}`);
    }
    for (const spec of argsSpec) {
      const v = (params as any)[spec.name];
      if (typeof v === 'undefined') {
        if (spec.required) {
          throw new OperatorInstanceError(operator, `Argument requis manquant: "${spec.name}" @ ${location}`);
        }
        args.push(spec.default ?? undefined);
        continue;
      }
      const accepted = Array.isArray(spec.type) ? spec.type : [spec.type];
      if (!accepted.some((t) => isType(v, t))) {
        throw new OperatorInstanceError(
          operator,
          `Type invalide pour "${spec.name}". Attendu: ${accepted.join('|')}, reçu: ${JSON.stringify(v)} @ ${location}`
        );
      }
      args.push(v);
    }
  } else {
    throw new OperatorInstanceError(operator, `Format params invalide (array ou objet attendu) @ ${location}`);
  }

  try {
    const out = impl(instance, ...args);
    if (meta.returnInstance) return instance as any;
    return out;
  } catch (e: any) {
    throw new OperatorInstanceError(operator, `${method} - ${e?.message ?? e} @ ${location}`);
  }
}
