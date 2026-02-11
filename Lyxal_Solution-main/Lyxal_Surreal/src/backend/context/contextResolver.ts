// =========================================================
// Moteur de résolution de contexte Surreal:
// - depuis un domaine (marque blanche)
// - depuis un workspace/account
// - avec modules SaaS activés
// - avec cache TTL + LRU pour les contextes résolus
// =========================================================

import { createContext } from "../client/surrealContext";
import type {
  ResolvedSurrealContext,
  TenantContextConfig,
} from "./contextTypes";
import { getDomainRoute } from "./domainMapping";
import { getWorkspaceRoute } from "./workspaceMapping";
import { getSaaSModules } from "./saasMapping";
import { getFromContextCache } from "./contextCache";

/**
 * Input générique pour résoudre un contexte depuis une requête,
 * un environnement ou un SDK.
 */
export interface GenericContextInput {
  domain?: string;
  workspaceId?: string;
  explicitContext?: TenantContextConfig; // fallback manuel
}

/**
 * Construit un ResolvedSurrealContext à partir d'une TenantContextConfig,
 * d'une source et éventuellement de modules activés.
 */
function buildResolvedContext(
  config: TenantContextConfig,
  source: ResolvedSurrealContext["source"],
): ResolvedSurrealContext {
  const base = createContext(config.namespace, config.database, {
    label: config.label,
    tenantId: config.tenantId,
  });

  const modulesConfig = getSaaSModules(config.tenantId, config.workspaceId);

  return {
    ...base,
    source,
    tenantId: config.tenantId,
    workspaceId: config.workspaceId,
    enabledModules: modulesConfig?.modules,
  };
}

/**
 * Résout un contexte à partir d'un domaine.
 */
export function resolveContextFromDomain(
  domain: string,
): ResolvedSurrealContext | null {
  const route = getDomainRoute(domain);
  if (!route) return null;

  return buildResolvedContext(route.context, "domain");
}

/**
 * Résout un contexte à partir d'un workspaceId.
 */
export function resolveContextFromWorkspace(
  workspaceId: string,
): ResolvedSurrealContext | null {
  const route = getWorkspaceRoute(workspaceId);
  if (!route) return null;

  return buildResolvedContext(route.context, "workspace");
}

/**
 * Implémentation interne de la résolution de contexte
 * sans cache (logique brute).
 */
function resolveContextInternal(
  input: GenericContextInput,
): ResolvedSurrealContext | null {
  if (input.domain) {
    const ctx = resolveContextFromDomain(input.domain);
    if (ctx) return ctx;
  }

  if (input.workspaceId) {
    const ctx = resolveContextFromWorkspace(input.workspaceId);
    if (ctx) return ctx;
  }

  if (input.explicitContext) {
    return buildResolvedContext(input.explicitContext, "manual");
  }

  return null;
}

/**
 * Construit une clé de cache stable pour un GenericContextInput.
 * L'idée est que deux requêtes identiques (même domaine/workspace/ns/db)
 * partagent la même entrée dans le cache.
 */
function makeContextCacheKey(input: GenericContextInput): string {
  const domainPart = input.domain ? `d:${input.domain.toLowerCase()}` : "";
  const wsPart = input.workspaceId ? `w:${input.workspaceId}` : "";
  const explicit = input.explicitContext
    ? `e:${input.explicitContext.namespace}:${input.explicitContext.database}:${input.explicitContext.tenantId || ""}:${input.explicitContext.workspaceId || ""}`
    : "";

  const parts = [domainPart, wsPart, explicit].filter(Boolean);
  return parts.join("|");
}

/**
 * Résout un contexte de la manière la plus intelligente possible :
 * 1) domaine
 * 2) workspace
 * 3) contexte explicite
 *
 * et met en cache le résultat avec TTL + LRU.
 */
export function resolveContext(
  input: GenericContextInput,
): ResolvedSurrealContext | null {
  const key = makeContextCacheKey(input);

  return getFromContextCache(key, () => resolveContextInternal(input));
}
