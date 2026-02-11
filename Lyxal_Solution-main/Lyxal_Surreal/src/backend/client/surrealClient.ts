// src/client/surrealClient.ts
// =========================================================
// Client SurrealDB intelligent (Singleton + Pool Multi-Context)
// S'appuie sur surrealConnection.ts (version PRO).
// =========================================================

import Surreal from "surrealdb";

import {
  getDefaultContext,
  type SurrealContext,
} from "./surrealContext";
import {
  createSurrealConnection,
  testConnection,
  type SurrealConnectionResult,
} from "./surrealConnection";

import { logInfo, logWarn } from "../utils/logger";

/* ---------------------------------------------------------
 * Configuration du Pool (Limites & Timings)
 * --------------------------------------------------------- */

const IDLE_TIMEOUT_MS = 10 * 60 * 1000; // 10 minutes d'inactivité
const HEALTH_CHECK_INTERVAL_MS = 30 * 1000; // Tester la santé max toutes les 30s
const CLEANUP_INTERVAL_MS = 60 * 1000; // Vérifier les connexions mortes chaque minute

interface PoolEntry {
  conn: SurrealConnectionResult;
  lastUsed: number;
  lastHealthCheck: number;
}

/* ---------------------------------------------------------
 * Pool de connexions : Map<"namespace:database", PoolEntry>
 * --------------------------------------------------------- */

// Stocke les connexions actives avec métadonnées
const clientPool = new Map<string, PoolEntry>();

// Stocke les promesses d'initialisation en cours (pour éviter les doublons)
const pendingConnections = new Map<string, Promise<SurrealConnectionResult>>();

// Timer pour le nettoyage automatique
let cleanupTimer: NodeJS.Timeout | null = null;

/**
 * Génère une clé unique pour identifier le contexte dans le pool.
 */
function getContextKey(ctx: SurrealContext): string {
  return `${ctx.namespace}:${ctx.database}`;
}

/* ---------------------------------------------------------
 * Nettoyage automatique (LRU / Idle Timeout)
 * --------------------------------------------------------- */

function startCleanupInterval() {
  if (cleanupTimer) return;

  cleanupTimer = setInterval(() => {
    const now = Date.now();
    let closedCount = 0;

    for (const [key, entry] of clientPool.entries()) {
      if (now - entry.lastUsed > IDLE_TIMEOUT_MS) {
        // Connexion inactive : on ferme
        logInfo(`[SurrealClient] Closing idle connection for ${key} (unused for > 10min).`);
        
        // On tente de fermer proprement
        try {
          entry.conn.db.close();
        } catch (err) {
          // Ignore errors during close
        }
        
        clientPool.delete(key);
        closedCount++;
      }
    }

    if (closedCount > 0) {
      logInfo(`[SurrealClient] Cleanup finished. Closed ${closedCount} idle connections.`);
    }
    
    // Si le pool est vide, on peut arrêter le timer pour économiser les ressources
    if (clientPool.size === 0 && cleanupTimer) {
      clearInterval(cleanupTimer);
      cleanupTimer = null;
    }

  }, CLEANUP_INTERVAL_MS);
}

/* ---------------------------------------------------------
 * Initialisation de la connexion pour un contexte donné.
 * --------------------------------------------------------- */

async function initClientWithContext(
  ctx: SurrealContext,
): Promise<SurrealConnectionResult> {
  const key = getContextKey(ctx);
  
  logInfo(
    `[SurrealClient] Initializing client for NS="${ctx.namespace}" DB="${ctx.database}"`,
  );

  try {
    const result = await createSurrealConnection(ctx, {
      modes: ["ws", "http"],
      beforeConnect: () =>
        logInfo(`[SurrealClient] Preparing connection for ${key}…`),
      afterConnect: () =>
        logInfo(`[SurrealClient] Connection established successfully for ${key}.`),
    });

    // Une fois connecté, on l'ajoute au pool et on nettoie la promesse en cours
    const now = Date.now();
    clientPool.set(key, {
      conn: result,
      lastUsed: now,
      lastHealthCheck: now, // On vient de connecter, c'est healthy
    });

    // S'assurer que le nettoyeur tourne
    startCleanupInterval();

    return result;
  } finally {
    pendingConnections.delete(key);
  }
}

/* ---------------------------------------------------------
 * Reconnexion automatique si la connexion devient invalide.
 * --------------------------------------------------------- */

async function reconnectClient(ctx: SurrealContext): Promise<SurrealConnectionResult> {
  const key = getContextKey(ctx);

  // Si une reconnexion est déjà en cours pour ce contexte, on l'attend
  if (pendingConnections.has(key)) {
    logWarn(`[SurrealClient] Reconnect already in progress for ${key}… waiting.`);
    return pendingConnections.get(key)!;
  }

  logWarn(
    `[SurrealClient] Connection lost or unhealthy. Reconnecting for NS="${ctx.namespace}" DB="${ctx.database}"…`,
  );

  // On démarre la reconnexion
  const promise = initClientWithContext(ctx);
  pendingConnections.set(key, promise);

  const result = await promise;
  logInfo(`[SurrealClient] Reconnected successfully for ${key}.`);
  return result;
}

/* ---------------------------------------------------------
 * API principale : obtenir le client Surreal pour un contexte.
 * --------------------------------------------------------- */

export async function getSurrealClient(
  ctx: SurrealContext | null = null,
): Promise<Surreal> {
  const context = ctx ?? getDefaultContext();
  const key = getContextKey(context);
  const now = Date.now();

  // CAS 1 — un client existe déjà dans le pool
  if (clientPool.has(key)) {
    const entry = clientPool.get(key)!;
    entry.lastUsed = now; // Mise à jour timestamp utilisation
    
    const { db } = entry.conn;

    // Optimisation HealthCheck : seulement si intervalle dépassé
    if (now - entry.lastHealthCheck > HEALTH_CHECK_INTERVAL_MS) {
      const health = await testConnection(db);
      entry.lastHealthCheck = now;

      if (!health.ok) {
        logWarn(
          `[SurrealClient] Existing connection for ${key} is unhealthy. Triggering reconnect…`,
        );
        const result = await reconnectClient(context);
        return result.db;
      }
    }

    return db;
  }

  // CAS 2 — initialisation déjà en cours (promesse partagée)
  if (pendingConnections.has(key)) {
    logInfo(`[SurrealClient] Awaiting ongoing initialization for ${key}…`);
    const result = await pendingConnections.get(key)!;
    return result.db;
  }

  // CAS 3 — première connexion pour ce contexte
  logInfo(`[SurrealClient] Creating first SurrealDB connection for ${key}…`);
  const promise = initClientWithContext(context);
  pendingConnections.set(key, promise);
  
  const result = await promise;
  return result.db;
}

/* ---------------------------------------------------------
 * Helper : exécuter une fonction dans un contexte NS/DB donné.
 * --------------------------------------------------------- */

export async function withSurrealContext<T>(
  ctx: SurrealContext | null,
  fn: (db: Surreal) => Promise<T>,
): Promise<T> {
  const context = ctx ?? getDefaultContext();
  
  // On récupère un client DÉJÀ connecté au bon contexte (namespace/database)
  // Plus besoin de faire db.use() ici, ce qui élimine la Race Condition.
  const db = await getSurrealClient(context);

  try {
    return await fn(db);
  } catch (err) {
    logWarn(
      `[SurrealClient] Error during query on ${context.namespace}/${context.database}. Retrying once with fresh connection…`,
      err,
    );

    // En cas d'erreur, on tente une reconnexion forcée pour ce contexte
    const result = await reconnectClient(context);
    const freshDb = result.db;

    return await fn(freshDb);
  }
}
