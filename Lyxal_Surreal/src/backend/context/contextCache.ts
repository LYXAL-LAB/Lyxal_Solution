// =========================================================
// Cache pour les ResolvedSurrealContext avec TTL + LRU.
// Permet d'éviter de recalculer le contexte pour chaque requête
// (par exemple quand le mapping est stocké dans Surreal).
// =========================================================

import type { ResolvedSurrealContext } from "./contextTypes";

interface ContextCacheEntry {
  value: ResolvedSurrealContext;
  expiresAt: number;
  lastHit: number;
}

const cache = new Map<string, ContextCacheEntry>();

// TTL d'un contexte résolu : 5 minutes
const CONTEXT_TTL_MS = 5 * 60 * 1000;

// Taille max du cache (nombre de clés)
const MAX_CACHE_SIZE = 1000;

/**
 * Génère une entrée cache à partir d'un contexte.
 */
function createEntry(ctx: ResolvedSurrealContext): ContextCacheEntry {
  const now = Date.now();
  return {
    value: ctx,
    expiresAt: now + CONTEXT_TTL_MS,
    lastHit: now,
  };
}

/**
 * Nettoie une entrée si elle est expirée.
 * Retourne true si l'entrée a été supprimée.
 */
function evictIfExpired(key: string, entry: ContextCacheEntry): boolean {
  if (Date.now() > entry.expiresAt) {
    cache.delete(key);
    return true;
  }
  return false;
}

/**
 * Applique une politique LRU simple quand la taille max est dépassée :
 * - on trouve l'entrée avec lastHit le plus ancien
 * - on la supprime
 */
function evictLRUIfNeeded() {
  if (cache.size <= MAX_CACHE_SIZE) return;

  let oldestKey: string | null = null;
  let oldestHit = Infinity;

  for (const [key, entry] of cache.entries()) {
    if (entry.lastHit < oldestHit) {
      oldestHit = entry.lastHit;
      oldestKey = key;
    }
  }

  if (oldestKey !== null) {
    cache.delete(oldestKey);
  }
}

/**
 * Récupère une valeur du cache ou la calcule via "compute" si manquante/expirée.
 *
 * @param key Clé de cache (ex: "domain:acme.com|ws:ws_123")
 * @param compute Fonction de fallback qui calcule le contexte si non trouvé
 */
export function getFromContextCache(
  key: string,
  compute: () => ResolvedSurrealContext | null,
): ResolvedSurrealContext | null {
  if (!key) {
    // Pas de clé -> pas de cache
    return compute();
  }

  const existing = cache.get(key);

  if (existing) {
    // Si expiré, on supprime et on recalculera
    if (evictIfExpired(key, existing)) {
      // continue → compute en dessous
    } else {
      // Cache valide : on met à jour lastHit et on renvoie
      existing.lastHit = Date.now();
      return existing.value;
    }
  }

  // Pas de cache ou expiré → on calcule
  const computed = compute();
  if (!computed) {
    // Rien à stocker
    return null;
  }

  // On stocke et on applique la politique LRU
  const entry = createEntry(computed);
  cache.set(key, entry);
  evictLRUIfNeeded();

  return computed;
}

/**
 * Vide complètement le cache de contextes.
 */
export function clearContextCache() {
  cache.clear();
}

/**
 * Retourne quelques stats simples sur le cache.
 */
export function getContextCacheStats() {
  return {
    size: cache.size,
    ttlMs: CONTEXT_TTL_MS,
    maxSize: MAX_CACHE_SIZE,
  };
}
