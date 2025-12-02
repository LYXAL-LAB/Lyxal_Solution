// =========================================================
// API haut niveau pour travailler avec les contextes:
// - obtenir un SurrealContext pour un domaine/workspace
// - lister tous les contextes pour warmup
// - vérifier si un module est activé
// =========================================================

import type { SurrealContext } from "../client/surrealContext";
import type {
  ResolvedSurrealContext,
  TenantContextConfig,
  SaaSModuleId,
} from "./contextTypes";
import { resolveContext, type GenericContextInput } from "./contextResolver";
import { listDomainContexts } from "./domainMapping";
import { listWorkspaceContexts } from "./workspaceMapping";
import { isModuleEnabled } from "./saasMapping";

/**
 * Résout un contexte et retourne seulement le SurrealContext nu.
 */
export function getSurrealContextFor(
  input: GenericContextInput,
): SurrealContext | null {
  const resolved = resolveContext(input);
  if (!resolved) return null;

  // On renvoie uniquement les champs SurrealContext de base
  return {
    namespace: resolved.namespace,
    database: resolved.database,
    label: resolved.label,
    tenantId: resolved.tenantId,
  };
}

/**
 * Résout un contexte complet (enrichi) avec modules activés, source, etc.
 */
export function getResolvedContextFor(
  input: GenericContextInput,
): ResolvedSurrealContext | null {
  return resolveContext(input);
}

/**
 * Retourne tous les contextes connus (via domaines + workspaces),
 * utile pour le warmup ou la supervision.
 */
export function listAllKnownContexts(): TenantContextConfig[] {
  return [...listDomainContexts(), ...listWorkspaceContexts()];
}

/**
 * Vérifie si un module SaaS est activé pour un contexte résolu.
 */
export function isModuleEnabledForContext(
  moduleId: SaaSModuleId,
  resolved: ResolvedSurrealContext,
): boolean {
  return isModuleEnabled(moduleId, resolved.tenantId, resolved.workspaceId);
}
