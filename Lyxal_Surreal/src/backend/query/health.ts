// =========================================================
// Health-check PRO pour SurrealDB via le client.
// =========================================================

import type { SurrealContext } from "../client/surrealContext";
import { withSurrealContext } from "../client/surrealClient";
import { logDebug, logWarn } from "../utils/logger";

export interface HealthStatus {
  ok: boolean;
  latency: number;
}

/**
 * Vérifie l'état de SurrealDB pour un contexte donné.
 */
export async function checkHealth(
  ctx: SurrealContext | null = null,
): Promise<HealthStatus> {
  const start = Date.now();

  try {
    await withSurrealContext(ctx, async (db) => {
      await db.query("RETURN 1;");
    });

    const latency = Date.now() - start;
    logDebug("[checkHealth] SurrealDB is healthy", { ctx, latency });

    return { ok: true, latency };
  } catch (err) {
    logWarn("[checkHealth] SurrealDB health check failed", { ctx, err });
    return { ok: false, latency: -1 };
  }
}
