// =========================================================
// Helpers de lecture (SELECT) PRO
// =========================================================

import type { SurrealContext } from "../client/surrealContext";
import { withSurrealContext } from "../client/surrealClient";
import { wrapSurrealError, LyxalErrorCode } from "../utils/errors";
import { logDebug, logError } from "../utils/logger";

/**
 * Sélectionne tous les enregistrements d'une table.
 */
export async function selectAll<T extends Record<string, unknown> = Record<string, unknown>>(
  table: string,
  ctx: SurrealContext | null = null,
): Promise<T[]> {
  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[selectAll] Selecting all", { table, ctx });
      const res = await db.select(table);
      return res as unknown as T[];
    });
  } catch (err) {
    logError("[selectAll] Failed", { table, ctx, err });
    throw wrapSurrealError(
      `[selectAll] Failed on table "${table}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}

/**
 * Sélectionne un enregistrement par ID sous forme:
 * - "table:id"
 * ou
 * - table + id séparés.
 */
export async function selectById<T extends Record<string, unknown> = Record<string, unknown>>(
  tableOrRecordId: string,
  id?: string,
  ctx: SurrealContext | null = null,
): Promise<T | null> {
  const key = id ? `${tableOrRecordId}:${id}` : tableOrRecordId;

  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[selectById] Selecting record", { key, ctx });
      const res = await db.select(key);
      return res as unknown as T | null;
    });
  } catch (err) {
    logError("[selectById] Failed", { key, ctx, err });
    throw wrapSurrealError(
      `[selectById] Failed on "${key}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}
