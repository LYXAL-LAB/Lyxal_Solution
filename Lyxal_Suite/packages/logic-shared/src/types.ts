export type Dict<T = any> = Record<string, T>;


export type OperatorFn = (params: any, ctx: EngineContext) => any;


export interface EngineContext {
// stable cross-engine context shape
data: Dict; // { user, props, state, env, local, computed, ... }
call?: (opName: string, params: any) => any; // internal recursive operator calls
secure?: boolean; // UI engine=true, Backend engine=false
engine?: 'ui' | 'backend';
// optional adapters (backend only typically)
adapters?: {
http?: {
get: (url: string, init?: any) => Promise<any>;
post: (url: string, body?: any, init?: any) => Promise<any>;
};
surreal?: {
query: (sql: string, vars?: Dict) => Promise<any>;
};
ai?: {
generate: (input: Dict) => Promise<any>;
embed?: (input: Dict) => Promise<any>;
};
crypto?: {
hash: (input: string, algo?: string) => Promise<string>;
sign?: (payload: Dict) => Promise<string>;
};
scheduler?: {
cron: (spec: string, payload: Dict) => Promise<string>;
};
storage?: {
upload: (path: string, data: Uint8Array | string) => Promise<string>;
};
};
}


// Import the complex OperatorMeta type from the meta system
import type { OperatorMeta, OperatorCategory } from './meta/types/index.js';
export type { OperatorMeta, OperatorCategory };


export interface OperatorPlugin {
id: string; // "@lyxal/op-math"
operators: Record<string, { fn: OperatorFn; meta?: OperatorMeta }>;
}