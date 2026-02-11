/**
 * @file structuredLogger.ts
 * @description Logger structuré avec format JSON, requestId et masquage des données sensibles
 */

import { Context, Next } from 'hono';
import { v4 as uuidv4 } from 'uuid';
import { maskSensitiveData, maskSensitiveObject } from '../../utils/secureLogger';

// Types pour le logger structuré
export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  requestId?: string;
  tag?: string;
  data?: any;
}

// Contexte de log global pour stocker le requestId courant
const logContext: { requestId?: string } = {};

/**
 * Crée une entrée de log au format JSON structuré
 */
function createLogEntry(level: LogLevel, message: string, options: { tag?: string, data?: any } = {}): LogEntry {
  const { tag, data } = options;
  
  // Créer l'entrée de log
  const logEntry: LogEntry = {
    timestamp: new Date().toISOString(),
    level,
    message,
    tag,
    // Utiliser le requestId du contexte global s'il existe
    requestId: logContext.requestId
  };
  
  // Ajouter les données supplémentaires si présentes, en masquant les informations sensibles
  if (data) {
    logEntry.data = maskSensitiveObject(data);
  }
  
  return logEntry;
}

/**
 * Écrit une entrée de log au format JSON
 */
function writeLog(entry: LogEntry): void {
  // Convertir l'entrée en JSON
  const jsonLog = JSON.stringify(entry);
  
  // Écrire dans la console appropriée selon le niveau
  switch (entry.level) {
    case 'debug':
      console.debug(jsonLog);
      break;
    case 'info':
      console.info(jsonLog);
      break;
    case 'warn':
      console.warn(jsonLog);
      break;
    case 'error':
      console.error(jsonLog);
      break;
    default:
      console.log(jsonLog);
  }
}

/**
 * API du logger structuré
 */
export const structuredLogger = {
  /**
   * Log de niveau debug
   */
  debug: (message: string, tag?: string, data?: any) => {
    writeLog(createLogEntry('debug', message, { tag, data }));
  },
  
  /**
   * Log de niveau info
   */
  info: (message: string, tag?: string, data?: any) => {
    writeLog(createLogEntry('info', message, { tag, data }));
  },
  
  /**
   * Log de niveau warn
   */
  warn: (message: string, tag?: string, data?: any) => {
    writeLog(createLogEntry('warn', message, { tag, data }));
  },
  
  /**
   * Log de niveau error
   */
  error: (message: string, tag?: string, data?: any) => {
    writeLog(createLogEntry('error', message, { tag, data }));
  },
  
  /**
   * Log d'événement métier
   */
  event: (eventName: string, message: string, tag?: string, data?: any) => {
    const eventData = { ...data, eventName };
    writeLog(createLogEntry('info', message, { tag: tag || 'event', data: eventData }));
  },
  
  /**
   * Log d'audit de sécurité
   */
  audit: (action: string, message: string, tag?: string, data?: any) => {
    const auditData = { ...data, action };
    writeLog(createLogEntry('info', message, { tag: tag || 'audit', data: auditData }));
  },
  
  /**
   * Log de performance
   */
  perf: (operation: string, durationMs: number, tag?: string, data?: any) => {
    const perfData = { ...data, operation, durationMs };
    writeLog(createLogEntry('debug', `Performance: ${operation} took ${durationMs}ms`, { tag: tag || 'perf', data: perfData }));
  },
  
  /**
   * Définit le requestId dans le contexte global
   */
  setRequestId: (requestId: string) => {
    logContext.requestId = requestId;
  },
  
  /**
   * Efface le requestId du contexte global
   */
  clearRequestId: () => {
    delete logContext.requestId;
  }
};

/**
 * Middleware qui ajoute un requestId à chaque requête et l'expose dans les logs
 */
export function requestIdMiddleware() {
  return async (c: Context, next: Next) => {
    // Générer un UUID pour cette requête
    const requestId = uuidv4();
    
    // Stocker dans le contexte de la requête
    c.set('requestId', requestId);
    
    // Ajouter aux en-têtes de réponse
    c.header('X-Request-ID', requestId);
    
    // Définir dans le contexte global de log
    structuredLogger.setRequestId(requestId);
    
    try {
      // Continuer le traitement
      await next();
    } finally {
      // Nettoyer le contexte global après la requête
      structuredLogger.clearRequestId();
    }
  };
}

/**
 * Middleware qui mesure le temps de traitement des requêtes
 */
export function requestLoggerMiddleware() {
  return async (c: Context, next: Next) => {
    const start = Date.now();
    const method = c.req.method;
    const path = c.req.path;
    
    // Log de début de requête
    structuredLogger.info(`${method} ${path} - Début`, 'http', {
      method,
      path,
      query: c.req.query(),
      headers: maskSensitiveObject(Object.fromEntries(Array.from(c.req.raw.headers.entries())))
    });
    
    try {
      // Traiter la requête
      await next();
      
      // Calculer la durée
      const duration = Date.now() - start;
      
      // Log de fin de requête
      structuredLogger.info(`${method} ${path} - Terminé en ${duration}ms`, 'http', {
        method,
        path,
        status: c.res.status,
        duration
      });
      
      // Log de performance
      structuredLogger.perf(`http:${method}:${path}`, duration);
    } catch (error: any) {
      // Calculer la durée même en cas d'erreur
      const duration = Date.now() - start;
      
      // Log d'erreur
      structuredLogger.error(`${method} ${path} - Erreur: ${error.message}`, 'http', {
        method,
        path,
        error: {
          message: error.message,
          name: error.name,
          stack: error.stack
        },
        duration
      });
      
      // Relancer l'erreur pour qu'elle soit traitée par le gestionnaire d'erreurs global
      throw error;
    }
  };
} 