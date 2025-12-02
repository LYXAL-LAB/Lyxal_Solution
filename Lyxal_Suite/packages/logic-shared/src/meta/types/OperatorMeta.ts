import type { OperatorCategory } from './OperatorCategory.js';
import type { OperatorArg } from './OperatorArg.js';
import type { OperatorPermissions } from './OperatorPermissions.js';
import type { OperatorExample } from './OperatorExample.js';

export interface OperatorAIHints {
  embedding?: string;                // optional future use
  usageExamples?: string[];          // short NL prompts
  commonMistakes?: string[];         // help AI & UX
  naturalLanguage?: string[];        // synonyms, phrasing
}

export interface OperatorMeta {
  // Identity
  name: string;                      // e.g. "$date.instance.addDays"
  description?: string;
  category?: OperatorCategory;       // optional for backward compatibility

  // Versioning & maintenance
  version?: string;                  // semver (optional for simple ops)
  deprecated?: boolean;
  tags?: string[];

  // Runtime permissions (simplified for backward compatibility)
  uiSafe?: boolean;                  // allowed on UI engine
  backendOnly?: boolean;             // only allowed on backend engine

  // Instance semantics
  instanceOf?: string;               // e.g. "date", "array", "object"

  // Signature & return
  args?: OperatorArg[];
  returns?: string;                  // textual type info (doc)
  returnInstance?: boolean;          // if true, return the mutated instance

  // Permissions / product controls
  permissions?: OperatorPermissions;

  // Docs & examples
  examples?: OperatorExample[];
  autoDocs?: boolean;                // allow auto-generated docs

  // Runtime hints (for UI, Studio UX and perf)
  uiExample?: any;                   // example input (UI engine)
  backendExample?: any;              // example input (backend engine)
  isPure?: boolean;                  // no side effects
  complexity?: number;               // 1..5 (for UX hints)

  // AI layer
  ai?: OperatorAIHints;
}
