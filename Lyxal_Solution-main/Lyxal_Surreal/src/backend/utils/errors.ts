// src/utils/errors.ts
// =========================================================
// Gestion PRO des erreurs Surreal / SDK
// =========================================================

import type { StandardError } from "./types";

/**
 * Codes d’erreurs standardisés pour LYXAL.
 * Tu peux en ajouter à volonté (ex: AUTH_REQUIRED, INVALID_CONTEXT, etc.)
 */
export enum LyxalErrorCode {
  UNKNOWN = "UNKNOWN",
  CONNECTION_FAILED = "CONNECTION_FAILED",
  QUERY_FAILED = "QUERY_FAILED",
  INVALID_CONTEXT = "INVALID_CONTEXT",
  CONFIG_MISSING = "CONFIG_MISSING",
}

/**
 * Erreur normalisée LYXAL Surreal Engine.
 */
// @ts-ignore: noImplicitOverride conflicts with interface implementation
export class SurrealError extends Error {
  public readonly code: LyxalErrorCode;
  public override readonly cause?: unknown;

  constructor(
    message: string,
    code: LyxalErrorCode = LyxalErrorCode.UNKNOWN,
    cause?: unknown,
  ) {
    super(message);
    this.name = "SurrealError";
    this.code = code;
    this.cause = cause;

    if (cause instanceof Error && cause.stack) {
      this.stack = cause.stack;
    }
  }
}

/**
 * Permet de vérifier si une erreur est un SurrealError.
 */
export function isSurrealError(err: unknown): err is SurrealError {
  return err instanceof SurrealError;
}

/**
 * Wrappe une erreur inconnue dans un SurrealError PRO.
 */
export function wrapSurrealError(
  message: string,
  code: LyxalErrorCode = LyxalErrorCode.UNKNOWN,
  cause?: unknown,
): SurrealError {
  if (isSurrealError(cause)) return cause;

  return new SurrealError(message, code, cause);
}
