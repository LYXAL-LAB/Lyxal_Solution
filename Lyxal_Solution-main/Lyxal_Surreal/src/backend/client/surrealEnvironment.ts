// =========================================================
// Lecture et validation des variables d'environnement
// Base pour la configuration SurrealDB (multi-SaaS / multi-env).
// =========================================================

export interface BaseSurrealEnv {
    URL: string;
    USER: string;
    PASS: string;
    DEFAULT_NAMESPACE: string;
    DEFAULT_DATABASE: string;
    FALLBACK_URLS: string[];
  }
  
  let cachedEnv: BaseSurrealEnv | null = null;
  
  function required(name: string, value: string | undefined): string {
    if (!value || value.trim() === "") {
      throw new Error(`[Lyxal_Surreal] Missing required env variable: ${name}`);
    }
    return value.trim();
  }
  
  /**
   * Découpe une liste d'URLs fallback à partir d'une env "LYXAL_SURREAL_FALLBACKS"
   * sous forme: "wss://a;wss://b;wss://c"
   */
  function parseFallbackUrls(raw: string | undefined): string[] {
    if (!raw) return [];
    return raw
      .split(";")
      .map((v) => v.trim())
      .filter((v) => v.length > 0);
  }
  
  /**
   * Charge et valide la configuration de base depuis process.env.
   * C’est la seule porte d’entrée vers process.env pour Surreal.
   */
  export function loadBaseSurrealEnv(): BaseSurrealEnv {
    if (cachedEnv) return cachedEnv;
  
    const URL = required("LYXAL_SURREAL_URL", process.env.LYXAL_SURREAL_URL);
    const USER = required("LYXAL_SURREAL_USER", process.env.LYXAL_SURREAL_USER);
    const PASS = required("LYXAL_SURREAL_PASS", process.env.LYXAL_SURREAL_PASS);
    const DEFAULT_NAMESPACE = required(
      "LYXAL_SURREAL_NAMESPACE",
      process.env.LYXAL_SURREAL_NAMESPACE,
    );
    const DEFAULT_DATABASE = required(
      "LYXAL_SURREAL_DATABASE",
      process.env.LYXAL_SURREAL_DATABASE,
    );
  
    const FALLBACK_URLS = parseFallbackUrls(
      process.env.LYXAL_SURREAL_FALLBACKS,
    );
  
    cachedEnv = {
      URL,
      USER,
      PASS,
      DEFAULT_NAMESPACE,
      DEFAULT_DATABASE,
      FALLBACK_URLS,
    };
  
    return cachedEnv;
  }
  