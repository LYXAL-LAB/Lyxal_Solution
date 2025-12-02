/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: metaParser.ts (FULL VERSION)
 * Rôle: Parser générique UI/Backend avec opérateurs, bindings "{{ }}" et sécurité (policies).
 */

import { MetaContext, MetaParserOptions, ParseResult } from './types';
import { resolveBindings } from './metaParser.bindings';
import { checkOperatorSecurity } from './metaParser.security';

export class MetaParser {
  private ctx: MetaContext;
  private opts: Required<MetaParserOptions>;

  constructor(context: MetaContext, options?: MetaParserOptions) {
    this.ctx = context;
    this.opts = {
      operatorPrefix: options?.operatorPrefix ?? '$',
      autoRuntime: options?.autoRuntime ?? true,
    };
  }

  /**
   * API publique — parse un input arbitraire (string, array, object, etc.)
   */
  parse<T = any>(input: T, location: string = 'root'): ParseResult<T> {
    const errors: (Error | string)[] = [];

    if (input === undefined || input === null) {
      return { output: input as T, errors };
    }

    try {
      const output = this.deepCloneWithReviver(input, location, errors) as T;
      return { output, errors };
    } catch (e: any) {
      errors.push(e instanceof Error ? e : new Error(String(e)));
      return { output: input as T, errors };
    }
  }

  /**
   * Deep clone + résolution bindings + résolution opérateurs
   */
  private deepCloneWithReviver(value: any, location: string, errors: (Error | string)[]): any {
    // ✅ Resolves bindings FIRST
    value = resolveBindings(value, this.ctx);

    if (Array.isArray(value)) {
      return value.map((v, i) => this.deepCloneWithReviver(v, `${location}[${i}]`, errors));
    }

    if (value && typeof value === 'object') {
      const keys = Object.keys(value);

      // Cas opérateur: exactement 1 clé, qui commence par prefix
      if (keys.length === 1 && keys[0].startsWith(this.opts.operatorPrefix)) {
        const opName = keys[0];
        const opParams = value[opName];

        try {
          // 🔒 Security check
          const cleanName = opName.replace(this.opts.operatorPrefix, '');
          const sec = checkOperatorSecurity(cleanName, this.ctx);
          if (!sec.allowed) {
            throw new Error(sec.reason);
          }

          return this.executeOperator(opName, opParams, location);
        } catch (err: any) {
          errors.push(this.formatError(err, opName, location));
          return null;
        }
      }

      // Sinon, descente récursive
      const out: any = {};
      for (const k of keys) {
        out[k] = this.deepCloneWithReviver(value[k], `${location}.${k}`, errors);
      }
      return out;
    }

    return value;
  }

  /**
   * Exécute un opérateur déclaratif
   */
  private executeOperator(opName: string, params: any, location: string): any {
    const cleanName = opName.replace(this.opts.operatorPrefix, ''); // "$http.get" -> "http.get"

    const executor = this.ctx.registry?.resolveOperator?.(cleanName);
    if (!executor) {
      if (this.ctx.options?.strict) {
        throw new Error(`Unknown operator "${cleanName}" at ${location}`);
      }
      return null;
    }

    // Détection runtime auto UI/backend
    let runtime = this.ctx.runtime;
    if (typeof params === 'object' && params?.runtime) {
      runtime = params.runtime;
    } else if (this.opts.autoRuntime) {
      runtime = this.inferRuntimeFromOp(cleanName);
    }

    return executor(cleanName, params, this.ctx);
  }

  /**
   * (Simple heuristique — sera amélioré X2 adaptatif)
   */
  private inferRuntimeFromOp(opName: string): 'ui' | 'backend' {
    if (opName.startsWith('ui.')) return 'ui';
    return 'backend';
  }

  private formatError(err: any, opName: string, location: string): string {
    return `Parser Error: operator "${opName}" failed at ${location}: ${err?.message ?? String(err)}`;
  }
}
