// src/client/surrealConfig.ts
// =========================================================
// Fusion env + contexte par défaut pour produire la config runtime.
// Point central pour toutes les options de connexion SurrealDB.
// =========================================================

import { loadBaseSurrealEnv } from "./surrealEnvironment";
import {
  createContext,
  setDefaultContext,
  type SurrealContext,
} from "./surrealContext";

export type ConnectionMode = "ws" | "http";

export interface SurrealConfig {
  url: string;
  user: string;
  pass: string;
  defaultContext: SurrealContext;
  /**
   * Liste d'URLs de fallback (autres régions, proxys, etc.)
   */
  fallbackUrls: string[];
  /**
   * Ordre de préférence des modes de connexion.
   * Exemple : ["ws", "http"] (par défaut).
   */
  preferredModes: ConnectionMode[];
}

let cachedConfig: SurrealConfig | null = null;

/**
 * Charge la configuration Surreal (avec cache) et initialise
 * le contexte par défaut utilisé par le client.
 */
export function getSurrealConfig(): SurrealConfig {
  if (cachedConfig) return cachedConfig;

  const env = loadBaseSurrealEnv();

  const defaultCtx = createContext(env.DEFAULT_NAMESPACE, env.DEFAULT_DATABASE, {
    label: "default",
  });

  setDefaultContext(defaultCtx);

  cachedConfig = {
    url: env.URL,
    user: env.USER,
    pass: env.PASS,
    defaultContext: defaultCtx,
    fallbackUrls: env.FALLBACK_URLS,
    preferredModes: ["ws", "http"],
  };

  return cachedConfig;
}
