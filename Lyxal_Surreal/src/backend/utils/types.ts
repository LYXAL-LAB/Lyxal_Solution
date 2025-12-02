// =========================================================
// Types utilitaires PRO pour LYXAL Surreal Engine
// =========================================================

export type JsonPrimitive = string | number | boolean | null;
export type JsonValue = JsonPrimitive | JsonObject | JsonArray;

export interface JsonObject {
  [key: string]: JsonValue;
}

export interface JsonArray extends Array<JsonValue> {}

// Pour les retours Surreal (`id`, etc.)
export interface SurrealRecord<T = any> {
  id: string;
  [key: string]: any;
}

// Partial profond
export type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};

// Fonction qui accepte synchrone ou async
export type MaybePromise<T> = T | Promise<T>;

// Pour les erreurs normalisées
export interface StandardError {
  message: string;
  code?: string;
  cause?: unknown;
}
