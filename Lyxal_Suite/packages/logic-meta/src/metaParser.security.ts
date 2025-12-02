/*
 * Lyxal OS — Logic Engine V2 (Enterprise, X2 Adaptive)
 * Package: @lyxal/logic-meta
 * File: metaParser.security.ts (Part 3/3)
 * Rôle: Couche de sécurité pour le MetaParser (policies, allow/deny, runtime).
 */

import { MetaContext } from './types';

export interface SecurityCheckResult {
  allowed: boolean;
  reason?: string;
}

export function checkOperatorSecurity(opName: string, ctx: MetaContext): SecurityCheckResult {
  const policy = ctx.policy;
  if (!policy) return { allowed: true }; // Pas de policy = full access (DEV mode)

  const runtime = ctx.runtime;

  // Vérification runtime autorisé par policy
  if (policy.runtime !== 'both' && policy.runtime !== runtime) {
    return {
      allowed: false,
      reason: `Operator "${opName}" not allowed in runtime "${runtime}".`,
    };
  }

  // Vérifie deny_ops (exclusion prioritaire)
  if (policy.deny_ops && matchPattern(opName, policy.deny_ops)) {
    return {
      allowed: false,
      reason: `Operator "${opName}" denied by policy.`,
    };
  }

  // Vérifie allow_ops (si défini, whitelisting strict)
  if (policy.allow_ops && !matchPattern(opName, policy.allow_ops)) {
    return {
      allowed: false,
      reason: `Operator "${opName}" not in allow list.`,
    };
  }

  return { allowed: true };
}

/** Check plugin allowed/denied (future: attach op → plugin metadata) */
export function checkPluginSecurity(pluginName: string, ctx: MetaContext): SecurityCheckResult {
  const policy = ctx.policy;
  if (!policy) return { allowed: true };

  if (policy.deny_plugins && policy.deny_plugins.includes(pluginName)) {
    return {
      allowed: false,
      reason: `Plugin "${pluginName}" denied by policy.`,
    };
  }

  if (policy.allow_plugins && !policy.allow_plugins.includes(pluginName)) {
    return {
      allowed: false,
      reason: `Plugin "${pluginName}" not in allow list.`,
    };
  }

  return { allowed: true };
}

/** Support des patterns glob comme "http.*" */
function matchPattern(op: string, patterns: string[]): boolean {
  return patterns.some((p) => {
    if (p === op) return true;
    if (p.endsWith('*')) {
      const prefix = p.slice(0, -1);
      return op.startsWith(prefix);
    }
    return false;
  });
}
