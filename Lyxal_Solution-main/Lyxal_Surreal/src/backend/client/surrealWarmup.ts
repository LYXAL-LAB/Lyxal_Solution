// src/client/surrealWarmup.ts
// =========================================================
// Helper de préchauffage des connexions SurrealDB.
// À appeler au démarrage de l'application (main/boot).
// =========================================================

import type { SurrealContext } from "./surrealContext";
import { getSurrealClient } from "./surrealClient";
import { logInfo, logError } from "../utils/logger";

/**
 * Préchauffe (ouvre) les connexions pour une liste de contextes donnés.
 * Utile pour éviter la latence de la première requête sur les services critiques
 * (Auth, Config, CRM...).
 *
 * @param contexts Liste des contextes à initialiser
 * @param parallel Si true, initialise tout en parallèle (défaut: true)
 */
export async function warmupSurrealConnections(
  contexts: SurrealContext[],
  parallel = true,
): Promise<void> {
  logInfo(`[SurrealWarmup] Starting warmup for ${contexts.length} contexts…`);
  const start = Date.now();

  const tasks = contexts.map(async (ctx) => {
    try {
      await getSurrealClient(ctx);
      // logInfo(`[SurrealWarmup] Warmup success for ${ctx.namespace}/${ctx.database}`);
    } catch (err) {
      logError(
        `[SurrealWarmup] Failed to warmup connection for ${ctx.namespace}/${ctx.database}`,
        err,
      );
      // On ne throw pas ici pour ne pas bloquer le boot des autres services,
      // mais c'est logué en erreur.
    }
  });

  if (parallel) {
    await Promise.all(tasks);
  } else {
    for (const task of tasks) {
      await task;
    }
  }

  const duration = Date.now() - start;
  logInfo(`[SurrealWarmup] Warmup completed in ${duration}ms.`);
}

