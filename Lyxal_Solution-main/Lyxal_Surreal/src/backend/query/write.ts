// =========================================================
// Helpers d'écriture (CREATE / UPDATE / MERGE / DELETE) PRO
// =========================================================

import type { SurrealContext } from "../client/surrealContext";
import { withSurrealContext } from "../client/surrealClient";
import { wrapSurrealError, LyxalErrorCode } from "../utils/errors";
import { logDebug, logError } from "../utils/logger";
import type { DeepPartial, SurrealRecord } from "../utils/types";

/**
 * Crée un enregistrement dans une table donnée.
 */
export async function createRecord<T = any>(
  table: string,
  data: DeepPartial<T>,
  ctx: SurrealContext | null = null,
): Promise<SurrealRecord<T>> {
  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[createRecord] Creating record", { table, data, ctx });
      const res = await db.create(table, data as any);
      return res[0] as unknown as SurrealRecord<T>;
    });
  } catch (err) {
    logError("[createRecord] Failed", { table, data, ctx, err });
    throw wrapSurrealError(
      `[createRecord] Failed on table "${table}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}

/**
 * Remplace complètement un enregistrement (UPDATE).
 * tableOrRecordId peut être:
 * - "table"
 * - "table:id"
 * Si id est fourni, la clé devient "table:id".
 */
export async function updateRecord<T = any>(
  tableOrRecordId: string,
  data: DeepPartial<T>,
  ctx: SurrealContext | null = null,
  id?: string,
): Promise<SurrealRecord<T>> {
  const key = id ? `${tableOrRecordId}:${id}` : tableOrRecordId;

  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[updateRecord] Updating record", { key, data, ctx });
      const res = await db.update(key, data as any);
      return res[0] as unknown as SurrealRecord<T>;
    });
  } catch (err) {
    logError("[updateRecord] Failed", { key, data, ctx, err });
    throw wrapSurrealError(
      `[updateRecord] Failed on "${key}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}

/**
 * Fusionne partiellement un enregistrement (MERGE).
 */
export async function mergeRecord<T = any>(
  tableOrRecordId: string,
  data: DeepPartial<T>,
  ctx: SurrealContext | null = null,
  id?: string,
): Promise<SurrealRecord<T>> {
  const key = id ? `${tableOrRecordId}:${id}` : tableOrRecordId;

  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[mergeRecord] Merging record", { key, data, ctx });
      const res = await db.merge(key, data as any);
      return res[0] as unknown as SurrealRecord<T>;
    });
  } catch (err) {
    logError("[mergeRecord] Failed", { key, data, ctx, err });
    throw wrapSurrealError(
      `[mergeRecord] Failed on "${key}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}

/**
 * Supprime un enregistrement ou tous les enregistrements d'une table.
 * - "table" → supprime tous les enregistrements de la table.
 * - "table:id" ou id + table → supprime un record.
 */
export async function deleteRecord<T extends Record<string, unknown> = Record<string, unknown>>(
  tableOrRecordId: string,
  ctx: SurrealContext | null = null,
  id?: string,
): Promise<T | null> {
  const key = id ? `${tableOrRecordId}:${id}` : tableOrRecordId;

  try {
    return await withSurrealContext(ctx, async (db) => {
      logDebug("[deleteRecord] Deleting record", { key, ctx });
      const res = await db.delete(key);
      return res as unknown as T | null;
    });
  } catch (err) {
    logError("[deleteRecord] Failed", { key, ctx, err });
    throw wrapSurrealError(
      `[deleteRecord] Failed on "${key}"`,
      LyxalErrorCode.QUERY_FAILED,
      err,
    );
  }
}
