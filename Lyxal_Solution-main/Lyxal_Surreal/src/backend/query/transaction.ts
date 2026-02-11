// =========================================================
// Helper transactionnel PRO (BEGIN / COMMIT / CANCEL).
// =========================================================

import type Surreal from "surrealdb";
import type { SurrealContext } from "../client/surrealContext";
import { withSurrealContext } from "../client/surrealClient";
import { wrapSurrealError, LyxalErrorCode } from "../utils/errors";
import { logDebug, logError } from "../utils/logger";

/**
 * Exécute un bloc de logique dans une transaction SurrealQL.
 * Utilise BEGIN / COMMIT / CANCEL TRANSACTION.
 */
export async function transactional<T>(
  ctx: SurrealContext | null,
  steps: (db: Surreal) => Promise<T>,
): Promise<T> {
  return withSurrealContext(ctx, async (db) => {
    logDebug("[transactional] BEGIN TRANSACTION", { ctx });

    try {
      await db.query("BEGIN TRANSACTION;");
      const result = await steps(db);
      await db.query("COMMIT TRANSACTION;");
      logDebug("[transactional] COMMIT TRANSACTION", { ctx });
      return result;
    } catch (err) {
      logError("[transactional] Error in transaction, rolling back", {
        ctx,
        err,
      });

      try {
        await db.query("CANCEL TRANSACTION;");
        logDebug("[transactional] CANCEL TRANSACTION executed", { ctx });
      } catch (cancelErr) {
        logError(
          "[transactional] Failed to CANCEL TRANSACTION",
          cancelErr,
        );
      }

      throw wrapSurrealError(
        "[transactional] Transaction failed",
        LyxalErrorCode.QUERY_FAILED,
        err,
      );
    }
  });
}
