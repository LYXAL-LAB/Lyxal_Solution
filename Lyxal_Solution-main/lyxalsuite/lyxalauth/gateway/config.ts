/**
 * @file config.ts
 * @description Configuration pour la Gateway lyxalauth
 */

/**
 * Configuration pour l'API Logto Cloud
 */
export interface LogtoConfig {
  /** Endpoint de l'API Logto */
  endpoint: string;
  /** Clé API pour l'accès administrateur */
  apiKey: string;
  /** ID de l'application */
  appId: string;
  /** Secret de l'application */
  appSecret: string;
  /** Audience pour les tokens */
  audience: string;
  /** Scopes par défaut */
  defaultScopes: string[];
}

/**
 * Configuration pour la Gateway
 */
export interface GatewayConfig {
  /** Port d'écoute du serveur */
  port: number;
  /** Mode d'environnement (production, development) */
  nodeEnv: 'production' | 'development';
  /** Origine pour CORS */
  corsOrigin: string | string[];
  /** URL de base pour les redirections */
  baseUrl: string;
  /** Durée de vie des cookies de session (en secondes) */
  cookieMaxAge: number;
  /** Secret pour les cookies */
  cookieSecret: string;
  /** Les cookies doivent-ils être sécurisés */
  secureCookies: boolean;
  /** Configuration Logto */
  logto: LogtoConfig;
  /** Configuration de rate limiting */
  rateLimit: {
    /** Fenêtre de temps en secondes */
    windowMs: number;
    /** Nombre maximum de requêtes par fenêtre */
    max: number;
    /** Message d'erreur */
    message: string;
  };
  /** Configuration de logging */
  logging: {
    /** Niveau de log */
    level: 'error' | 'warn' | 'info' | 'debug';
    /** Format de log */
    format: 'json' | 'text';
  };
}

/**
 * Charge la configuration depuis les variables d'environnement
 * @returns Configuration de la Gateway
 */
export function loadConfig(): GatewayConfig {
  return {
    port: parseInt(process.env.PORT || '3000', 10),
    nodeEnv: (process.env.NODE_ENV || 'development') as 'production' | 'development',
    corsOrigin: process.env.CORS_ORIGIN?.split(',') || '*',
    baseUrl: process.env.BASE_URL || 'http://localhost:3000',
    cookieMaxAge: parseInt(process.env.COOKIE_MAX_AGE || '86400', 10), // 24 heures par défaut
    cookieSecret: process.env.COOKIE_SECRET || 'lyxal-gateway-secret',
    secureCookies: process.env.SECURE_COOKIES === 'true',
    logto: {
      endpoint: process.env.LOGTO_ENDPOINT || 'https://api.logto.io',
      apiKey: process.env.LOGTO_API_KEY || '',
      appId: process.env.LOGTO_APP_ID || '',
      appSecret: process.env.LOGTO_APP_SECRET || '',
      audience: process.env.LOGTO_AUDIENCE || 'https://api.logto.io',
      defaultScopes: (process.env.LOGTO_DEFAULT_SCOPES || 'read:profile').split(',')
    },
    rateLimit: {
      windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10), // 1 minute par défaut
      max: parseInt(process.env.RATE_LIMIT_MAX || '100', 10), // 100 requêtes par minute par défaut
      message: 'Trop de requêtes, veuillez réessayer plus tard'
    },
    logging: {
      level: (process.env.LOG_LEVEL || 'info') as 'error' | 'warn' | 'info' | 'debug',
      format: (process.env.LOG_FORMAT || 'json') as 'json' | 'text'
    }
  };
}

/**
 * Configuration par défaut de la Gateway
 */
export const config = loadConfig(); 