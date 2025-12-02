// =========================================================
// Gestion PRO des connexions SurrealDB (multi-URL, multi-mode).
// Utilisé par surrealClient.ts (qui gère le singleton).
// =========================================================

import Surreal from "surrealdb";
import { getSurrealConfig, type ConnectionMode } from "./surrealConfig";
import type { SurrealContext } from "./surrealContext";
import { logInfo, logError, logWarn, logDebug } from "../utils/logger";
import { withRetry } from "../utils/retry";

export interface ConnectionOptions {
  context?: SurrealContext | null;
  timeoutMs?: number;
  beforeConnect?: () => Promise<void> | void;
  afterConnect?: (db: Surreal) => Promise<void> | void;
  modes?: ConnectionMode[];
}

export interface SurrealConnectionResult {
  db: Surreal;
  mode: ConnectionMode;
  latency: number;
  url: string;
}

/* ---------------------------------------------------------
 * Liste finale des URLs à tenter (principal + fallbacks)
 * --------------------------------------------------------- */

function getAllCandidateUrls(): string[] {
  const cfg = getSurrealConfig();
  const urls = [cfg.url, ...cfg.fallbackUrls];
  // Filtre les doublons par sécurité
  return Array.from(new Set(urls.map((u) => u.trim()).filter(Boolean)));
}

/**
 * Transforme un URL selon le mode:
 * - mode "ws"  : s'assure que l'URL est ws:// ou wss://
 * - mode "http": s'assure que l'URL est http:// ou https://
 */
function normalizeUrlForMode(url: string, mode: ConnectionMode): string {
  const trimmed = url.trim();
  if (!trimmed) {
    throw new Error("[SurrealConnection] normalizeUrlForMode: URL is empty.");
  }

  if (mode === "ws") {
    // Si déjà ws ou wss on garde
    if (trimmed.startsWith("ws://") || trimmed.startsWith("wss://")) {
      return trimmed;
    }
    // Transforme http -> ws, https -> wss
    if (trimmed.startsWith("http://")) {
      return trimmed.replace("http://", "ws://");
    }
    if (trimmed.startsWith("https://")) {
      return trimmed.replace("https://", "wss://");
    }
    // Sinon, on suppose que c'est un endpoint ws déjà correct
    return trimmed;
  }

  // mode === "http"
  if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
    return trimmed;
  }
  if (trimmed.startsWith("ws://")) {
    return trimmed.replace("ws://", "http://");
  }
  if (trimmed.startsWith("wss://")) {
    return trimmed.replace("wss://", "https://");
  }
  return trimmed;
}

/* ---------------------------------------------------------
 * Connexion unique sur un couple (url, mode)
 * --------------------------------------------------------- */

async function tryConnectOnce(
  rawUrl: string,
  mode: ConnectionMode,
  ctx: SurrealContext,
  opts: ConnectionOptions,
): Promise<SurrealConnectionResult> {
  const cfg = getSurrealConfig();
  const url = normalizeUrlForMode(rawUrl, mode);
  const start = Date.now();

  logInfo(`[SurrealConnection] Trying ${mode.toUpperCase()} → ${url}`);

  if (opts.beforeConnect) {
    await opts.beforeConnect();
  }

  const db = new Surreal();

  // NOTE : le client "surrealdb" choisira le transport selon l'URL.
  await db.connect(url);
  await db.signin({
    username: cfg.user,
    password: cfg.pass,
  });

  await db.use({
    namespace: ctx.namespace,
    database: ctx.database,
  });

  if (opts.afterConnect) {
    await opts.afterConnect(db);
  }

  const latency = Date.now() - start;
  logInfo(
    `[SurrealConnection] Connected via ${mode.toUpperCase()} in ${latency}ms (ctx=${ctx.namespace}/${ctx.database})`,
  );

  return { db, mode, latency, url };
}

/* ---------------------------------------------------------
 * Algorithme global de connexion avec retry & fallbacks
 * --------------------------------------------------------- */

export async function createSurrealConnection(
  ctx: SurrealContext,
  options: ConnectionOptions = {},
): Promise<SurrealConnectionResult> {
  const cfg = getSurrealConfig();
  const modes = options.modes || cfg.preferredModes;
  const urls = getAllCandidateUrls();

  let lastError: unknown = null;

  for (const rawUrl of urls) {
    for (const mode of modes) {
      try {
        const result = await withRetry(
          () => tryConnectOnce(rawUrl, mode, ctx, options),
          {
            attempts: 3,
            delayMs: 300,
          },
        );
        return result;
      } catch (err) {
        lastError = err;
        logWarn(
          `[SurrealConnection] Failed for URL="${rawUrl}" MODE="${mode}". Trying next candidate…`,
        );
      }
    }
  }

  logError(
    "[SurrealConnection] All connection attempts failed. Check SurrealDB availability and configuration.",
    lastError,
  );
  throw lastError;
}

/* ---------------------------------------------------------
 * Test rapide de la connexion (health check)
 * --------------------------------------------------------- */

export async function testConnection(
  db: Surreal,
): Promise<{ ok: boolean; latency: number }> {
  const start = Date.now();
  try {
    await db.query("RETURN 1;");
    return { ok: true, latency: Date.now() - start };
  } catch (err) {
    logWarn("[SurrealConnection] Health check failed", err);
    return { ok: false, latency: -1 };
  }
}
