import { OperatorMeta } from '../types/OperatorMeta.js';

export class OperatorMetaError extends Error {
  constructor(msg: string) {
    super(`OperatorMetaError: ${msg}`);
  }
}

export function validateMeta(meta: OperatorMeta): void {
  if (!meta) throw new OperatorMetaError('meta is required');
  if (!meta.name || typeof meta.name !== 'string') {
    throw new OperatorMetaError('meta.name (string) is required');
  }
  if (!meta.category) {
    throw new OperatorMetaError(`meta.category is required on ${meta.name}`);
  }
  if (!meta.version || typeof meta.version !== 'string') {
    throw new OperatorMetaError(`meta.version (semver string) is required on ${meta.name}`);
  }

  // args validation (lightweight)
  if (meta.args) {
    for (const a of meta.args) {
      if (!a.name) throw new OperatorMetaError(`${meta.name}: arg.name is required`);
      if (typeof a.name !== 'string') throw new OperatorMetaError(`${meta.name}: arg.name must be string`);
      if (!a.type) throw new OperatorMetaError(`${meta.name}: arg.type is required`);
    }
  }

  // permissions sanity
  if (meta.permissions) {
    const p = meta.permissions;
    if (p.uiSafe === false && p.backend === false) {
      throw new OperatorMetaError(`${meta.name}: permissions prohibit all runtimes`);
    }
  }

  // complexity hints
  if (meta.complexity && (meta.complexity < 1 || meta.complexity > 5)) {
    throw new OperatorMetaError(`${meta.name}: complexity must be between 1 and 5`);
  }
}
