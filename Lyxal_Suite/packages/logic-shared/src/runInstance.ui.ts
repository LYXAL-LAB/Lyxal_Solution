import { OperatorMeta } from './meta/types/OperatorMeta.js';
import { validateMeta } from './meta/validators/validateMeta.js';

export class OperatorInstanceError extends Error {
  constructor(op: string, msg: string) {
    super(`OperatorInstanceError [${op}]: ${msg}`);
  }
}

// Type utilitaire très simple (runtime)
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
 * UI engine version (Option 3): attend un objet nommé.
 * Convention: la clé de l'instance = meta.instanceOf (ex: "date", "array", "object")
 * ex: { "$date.instance.addDays": { date: "...", days: 3 } }
 */
export function runInstanceUI<TOut = any>({
  operator,
  method,
  params,
  meta,
  location,
  impl,        // (instance, ...args) => result
}: {
  operator: string;
  method: string;
  params: any;              // objet nommé (Option 3)
  meta: OperatorMeta;
  location: string;
  impl: (instance: any, ...args: any[]) => TOut;
}): TOut {
  // Sanity meta
  validateMeta(meta);
  if (!meta.instanceOf) {
    throw new OperatorInstanceError(operator, `meta.instanceOf manquant (ex: "date" | "array" | "object").`);
  }
  if (typeof params !== 'object' || Array.isArray(params) || params == null) {
    throw new OperatorInstanceError(operator, `La syntaxe UI requiert un objet nommé. Reçu: ${JSON.stringify(params)} @ ${location}`);
  }

  // Convention: la clé d’instance = meta.instanceOf ("date" => params.date, "array" => params.array, etc.)
  const instanceKey = meta.instanceOf;
  const instance = (params as any)[instanceKey];
  if (typeof instance === 'undefined') {
    throw new OperatorInstanceError(operator, `Champ d'instance "${instanceKey}" requis dans les params UI. @ ${location}`);
  }

  // Préparer les args dans l’ordre défini par meta.args (hors instance)
  const argsSpec = meta.args ?? [];
  const args: any[] = [];
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

  try {
    const res = impl(instance, ...args);
    return meta.returnInstance ? (instance as any) : res;
  } catch (e: any) {
    throw new OperatorInstanceError(operator, `${method} - ${e?.message ?? e} @ ${location}`);
  }
}
