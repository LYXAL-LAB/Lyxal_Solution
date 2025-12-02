// packages/logic-ui/src/operators/runOperatorUI.ts
import type { EngineContext } from '@lyxal/logic-shared/src/engine/EngineContext';
import { operatorMapUI } from './operatorMapUI';

export interface RunOperatorUIOptions {
  strict?: boolean;       // force throw si introuvable
  env?: 'dev' | 'prod';   // override env
}

export function runOperatorUI(
  opName: string,
  params: any,
  ctx: EngineContext,
  options: RunOperatorUIOptions = {}
): any {
  const env = options.env ?? (process.env.NODE_ENV === 'development' ? 'dev' : 'prod');
  const strict = options.strict ?? (env === 'dev');

  // Exemple: "$date.instance.addDays" → ["date", "instance", "addDays"]
  const parts = opName.slice(1).split('.'); // remove $ then split
  const [namespace, category, method] = parts;

  const nsBlock = (operatorMapUI as any)[namespace];
  const catBlock = nsBlock?.[category];
  const fn = catBlock?.[method];

  if (!fn) {
    const msg = `UI Operator not found: ${opName}`;
    if (strict) throw new Error(msg);
    if (env === 'dev') console.warn(msg);
    return params; // fallback
  }

  try {
    return fn(params, ctx);
  } catch (err: any) {
    const msg = `Error executing UI operator "${opName}": ${err?.message ?? err}`;
    if (strict) throw new Error(msg);
    console.error(msg);
    return undefined;
  }
}
