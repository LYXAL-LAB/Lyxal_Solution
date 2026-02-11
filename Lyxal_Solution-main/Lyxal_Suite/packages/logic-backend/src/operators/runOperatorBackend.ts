// packages/logic-backend/src/operators/runOperatorBackend.ts
import type { EngineContext } from '@lyxal/logic-shared/src/engine/EngineContext';
import { operatorMapBackend } from './operatorMapBackend';

export interface RunOperatorBackendOptions {
  strict?: boolean;         // force throw si introuvable
  env?: 'dev' | 'prod';     // override env
  logErrors?: boolean;      // log console.error (prod recommended)
}

export async function runOperatorBackend(
  opName: string,
  params: any,
  ctx: EngineContext,
  options: RunOperatorBackendOptions = {}
): Promise<any> {
  const env = options.env ?? (process.env.NODE_ENV === 'development' ? 'dev' : 'prod');
  const strict = options.strict ?? (env === 'dev');
  const logErrors = options.logErrors ?? (env === 'prod');

  // Exemple: "$http.get" ou "$date.instance.addDays"
  const parts = opName.slice(1).split('.');
  const [namespace, category, method] = parts;

  const nsBlock = (operatorMapBackend as any)[namespace];
  const catBlock = nsBlock?.[category];
  const fn = catBlock?.[method];

  if (!fn) {
    const msg = `Backend Operator not found: ${opName}`;
    if (strict) throw new Error(msg);
    if (env === 'dev') console.warn(msg);
    return params; // fallback safe
  }

  try {
    const result = fn(params, ctx);

    // backend functions can be async or sync
    if (result instanceof Promise) {
      return await result;
    }
    return result;
  } catch (err: any) {
    const msg = `Error executing Backend operator "${opName}": ${err?.message ?? err}`;
    if (strict) throw new Error(msg);
    if (logErrors) console.error(msg);
    return undefined;
  }
}
