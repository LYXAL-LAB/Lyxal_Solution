/**
 * @file secureLogger.ts
 * @description Logger sécurisé qui masque les données sensibles dans les logs
 */

import { Context, Next } from 'hono';
import { logger as honoLogger } from 'hono/logger';
import { v4 as uuidv4 } from 'uuid';

// Regex pour détecter les données sensibles
const SENSITIVE_PATTERNS = {
  // Format standard JWT: header.payload.signature
  JWT_TOKEN: /eyJ[a-zA-Z0-9_-]{5,}\.[a-zA-Z0-9_-]{5,}\.[a-zA-Z0-9_-]{5,}/g,
  
  // Email: format simple pour la détection
  EMAIL: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
  
  // Mots de passe hashés (formats courants)
  HASHED_PASSWORD: /\$2[ayb]\$[0-9]{2}\$[A-Za-z0-9./]{53}/g, // bcrypt
  SHA_PASSWORD: /[a-f0-9]{40,128}/g, // SHA-1, SHA-256, SHA-512, etc.
  
  // Clés API (formats génériques)
  API_KEY: /[a-zA-Z0-9_-]{20,}/g,
  
  // Numéros de carte de crédit
  CREDIT_CARD: /\b(?:\d[ -]*?){13,16}\b/g
};

/**
 * Masque les données sensibles dans une chaîne
 */
export function maskSensitiveData(input: string): string {
  if (typeof input !== 'string') return input;
  
  let masked = input;
  
  // Masquer les tokens JWT
  masked = masked.replace(SENSITIVE_PATTERNS.JWT_TOKEN, '[TOKEN_MASQUÉ]');
  
  // Masquer les emails
  masked = masked.replace(SENSITIVE_PATTERNS.EMAIL, (match) => {
    const parts = match.split('@');
    if (parts.length !== 2) return match;
    
    // Garder le premier caractère et le domaine
    return `${parts[0].charAt(0)}***@${parts[1]}`;
  });
  
  // Masquer les mots de passe hashés
  masked = masked.replace(SENSITIVE_PATTERNS.HASHED_PASSWORD, '[HASH_MASQUÉ]');
  masked = masked.replace(SENSITIVE_PATTERNS.SHA_PASSWORD, '[HASH_MASQUÉ]');
  
  // Masquer les clés API
  masked = masked.replace(SENSITIVE_PATTERNS.API_KEY, '[CLÉ_API_MASQUÉE]');
  
  // Masquer les numéros de carte de crédit
  masked = masked.replace(SENSITIVE_PATTERNS.CREDIT_CARD, '[CARTE_MASQUÉE]');
  
  return masked;
}

/**
 * Masque les données sensibles dans un objet
 */
export function maskSensitiveObject(obj: any): any {
  if (!obj || typeof obj !== 'object') {
    return obj;
  }
  
  // Traiter les tableaux
  if (Array.isArray(obj)) {
    return obj.map(item => maskSensitiveObject(item));
  }
  
  // Traiter les objets
  const result: any = {};
  for (const key in obj) {
    // Masquer les valeurs sensibles basées sur le nom de la clé
    if (['password', 'token', 'secret', 'apiKey', 'key', 'authorization', 'auth'].includes(key.toLowerCase())) {
      result[key] = typeof obj[key] === 'string' ? '[VALEUR_SENSIBLE_MASQUÉE]' : obj[key];
    } 
    // Traiter récursivement les objets imbriqués
    else if (typeof obj[key] === 'object' && obj[key] !== null) {
      result[key] = maskSensitiveObject(obj[key]);
    } 
    // Masquer les chaînes potentiellement sensibles
    else if (typeof obj[key] === 'string') {
      result[key] = maskSensitiveData(obj[key]);
    } 
    // Conserver les autres types de données
    else {
      result[key] = obj[key];
    }
  }
  
  return result;
}

/**
 * Middleware de journalisation sécurisé
 * Ajoute un requestId et masque les données sensibles
 */
export function secureLogger() {
  const originalLogger = honoLogger();
  
  return async (c: Context, next: Next) => {
    // Générer un ID unique pour cette requête
    const requestId = uuidv4();
    c.set('requestId', requestId);
    
    // Ajouter l'ID de requête aux en-têtes de réponse
    c.header('X-Request-ID', requestId);
    
    // Intercepter les logs de la requête
    const originalLog = console.log;
    const originalError = console.error;
    const originalWarn = console.warn;
    const originalInfo = console.info;
    
    // Remplacer temporairement les fonctions de log
    console.log = (...args) => {
      const maskedArgs = args.map(arg => 
        typeof arg === 'string' ? maskSensitiveData(arg) : 
        typeof arg === 'object' ? maskSensitiveObject(arg) : arg
      );
      originalLog(`[${requestId}]`, ...maskedArgs);
    };
    
    console.error = (...args) => {
      const maskedArgs = args.map(arg => 
        typeof arg === 'string' ? maskSensitiveData(arg) : 
        typeof arg === 'object' ? maskSensitiveObject(arg) : arg
      );
      originalError(`[${requestId}]`, ...maskedArgs);
    };
    
    console.warn = (...args) => {
      const maskedArgs = args.map(arg => 
        typeof arg === 'string' ? maskSensitiveData(arg) : 
        typeof arg === 'object' ? maskSensitiveObject(arg) : arg
      );
      originalWarn(`[${requestId}]`, ...maskedArgs);
    };
    
    console.info = (...args) => {
      const maskedArgs = args.map(arg => 
        typeof arg === 'string' ? maskSensitiveData(arg) : 
        typeof arg === 'object' ? maskSensitiveObject(arg) : arg
      );
      originalInfo(`[${requestId}]`, ...maskedArgs);
    };
    
    try {
      // Appliquer le logger Hono original
      await originalLogger(c, next);
    } finally {
      // Restaurer les fonctions de log originales
      console.log = originalLog;
      console.error = originalError;
      console.warn = originalWarn;
      console.info = originalInfo;
    }
  };
}

/**
 * Fonctions de journalisation sécurisées
 */
export const secureLog = {
  debug: (message: string, data?: any) => {
    console.log(`[DEBUG] ${message}`, data ? maskSensitiveObject(data) : '');
  },
  
  info: (message: string, data?: any) => {
    console.info(`[INFO] ${message}`, data ? maskSensitiveObject(data) : '');
  },
  
  warn: (message: string, data?: any) => {
    console.warn(`[WARN] ${message}`, data ? maskSensitiveObject(data) : '');
  },
  
  error: (message: string, data?: any) => {
    console.error(`[ERROR] ${message}`, data ? maskSensitiveObject(data) : '');
  },
  
  event: (eventName: string, message: string, data?: any) => {
    console.log(`[EVENT:${eventName}] ${message}`, data ? maskSensitiveObject(data) : '');
  }
}; 