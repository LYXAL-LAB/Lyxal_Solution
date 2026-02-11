// =========================================================
// rawQuery PRO — exécution directe de SurrealQL
// avec support retry, logs, multi-contexte.
// =========================================================

import type { SurrealContext } from "../client/surrealContext";
import { withSurrealContext } from "../client/surrealClient";
import { wrapSurrealError, LyxalErrorCode } from "../utils/errors";
import { withRetry } from "../utils/retry";
import { logDebug, logError, logInfo } from "../utils/logger";
import type { JsonValue } from "../utils/types";

export interface RawQueryOptions {
  /**
   * Active le retry automatique sur la requête.
   */
  useRetry?: boolean;
  /**
   * Options de retry. Ignorées si useRetry = false.
   */
  attempts?: number;
  delayMs?: number;
  backoffFactor?: number;
  jitter?: boolean;
  /**
   * Label pour les logs (ex: "crm:list_companies").
   */
  label?: string;
}

/**
 * Exécute une requête SurrealQL brute.
 * Retourne le tableau de résultats tel que renvoyé par le client Surreal.
 */
export async function rawQuery<T = JsonValue[]>(
  surql: string,
  vars: Record<string, unknown> = {},
  ctx: SurrealContext | null = null,
  options: RawQueryOptions = {},
): Promise<T> {
  const {
    useRetry = true,
    attempts = 3,
    delayMs = 200,
    backoffFactor = 1.5,
    jitter = true,
    label,
  } = options;

  const logLabel = label ? ` [${label}]` : "";

  const execOnce = async () => {
    logDebug(
      `[rawQuery] Executing query${logLabel}`,
      { surql, vars, ctx },
    );

    try {
      return await withSurrealContext(ctx, async (db) => {
        const res = await db.query(surql, vars);
        logDebug(
          `[rawQuery] Query success${logLabel}`,
          { surql, resultCount: Array.isArray(res) ? res.length : "unknown" },
        );
        return res as T;
      });
    } catch (err) {
      throw wrapSurrealError(
        `[rawQuery] Query failed${logLabel}: ${surql}`,
        LyxalErrorCode.QUERY_FAILED,
        err,
      );
    }
  };

  if (!useRetry) {
    return execOnce();
  }

  try {
    return await withRetry(execOnce, {
      attempts,
      delayMs,
      backoffFactor,
      jitter,
    });
  } catch (err) {
    logError(
      `[rawQuery] Query failed after retries${logLabel}`,
      { surql, vars, ctx },
    );
    if (err instanceof Error) throw err;
    throw wrapSurrealError(
      `[rawQuery] Unknown error after retries${logLabel}`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}
