import { OperatorMeta } from '../types/OperatorMeta.js';
import { validateMeta } from '../validators/validateMeta.js';

export interface CompiledOperatorMeta {
  // keep same keys for JSON output, so Studio & DB can ingest directly
  name: string;
  description?: string;
  category: string;
  version: string;
  deprecated?: boolean;
  tags?: string[];

  instanceOf?: string;
  args?: any[];
  returns?: string;
  returnInstance?: boolean;

  permissions?: any;
  examples?: any[];
  autoDocs?: boolean;

  uiExample?: any;
  backendExample?: any;
  isPure?: boolean;
  complexity?: number;

  ai?: {
    embedding?: string;
    usageExamples?: string[];
    commonMistakes?: string[];
    naturalLanguage?: string[];
  };
}

export function compileMeta(meta: OperatorMeta): CompiledOperatorMeta {
  validateMeta(meta);

  // Here we could normalize types / coerce where needed (future)
  // For now we pass-through, ensuring JSON-ready values only.

  const out: CompiledOperatorMeta = {
    name: meta.name,
    description: meta.description,
    category: meta.category || 'custom',
    version: meta.version || '1.0.0',
    deprecated: meta.deprecated,
    tags: meta.tags,

    instanceOf: meta.instanceOf,
    args: meta.args,
    returns: meta.returns,
    returnInstance: meta.returnInstance,

    permissions: meta.permissions,
    examples: meta.examples,
    autoDocs: meta.autoDocs,

    uiExample: meta.uiExample,
    backendExample: meta.backendExample,
    isPure: meta.isPure,
    complexity: meta.complexity,

    ai: meta.ai && {
      embedding: meta.ai.embedding,
      usageExamples: meta.ai.usageExamples,
      commonMistakes: meta.ai.commonMistakes,
      naturalLanguage: meta.ai.naturalLanguage,
    },
  };

  return out;
}
