/**
 * @file rateLimitMiddleware.ts
 * @description Middleware de limitation de débit (rate limiting) simplifié pour l'API
 */

import { Context, Next } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';

// Interface pour les entrées de limite de débit
interface RateLimitEntry {
  count: number;
  resetAt: number;
}

// Interface pour les options du rate limiter
interface RateLimitOptions {
  limit: number;        // Nombre maximal de requêtes par fenêtre
  window: string;       // Fenêtre de temps (format: '15m', '1h', etc.)
  message?: string;     // Message d'erreur personnalisé
}

// Stockage en mémoire pour les limites de débit
const ipLimits = new Map<string, Map<string, RateLimitEntry>>();

/**
 * Convertit une chaîne de temps (ex: '15m', '1h') en millisecondes
 */
function parseTimeWindow(window: string): number {
  const regex = /^(\d+)([smh])$/;
  const match = window.match(regex);
  
  if (!match) {
    throw new Error(`Format de fenêtre invalide: ${window}. Utilisez le format '10s', '5m', '1h', etc.`);
  }
  
  const value = parseInt(match[1], 10);
  const unit = match[2];
  
  switch (unit) {
    case 's': return value * 1000;           // secondes
    case 'm': return value * 1000 * 60;      // minutes
    case 'h': return value * 1000 * 60 * 60; // heures
    default: return 60000; // 1 minute par défaut
  }
}

/**
 * Nettoie périodiquement les entrées expirées du stockage en mémoire
 */
function setupCleanup() {
  setInterval(() => {
    const now = Date.now();
    for (const [path, entries] of ipLimits.entries()) {
      for (const [ip, entry] of entries.entries()) {
        if (now > entry.resetAt) {
          entries.delete(ip);
        }
      }
      
      if (entries.size === 0) {
        ipLimits.delete(path);
      }
    }
  }, 60000); // Nettoyer toutes les minutes
}

// Démarrer le nettoyage périodique
setupCleanup();

/**
 * Extrait l'adresse IP de la requête
 */
function getIpFromRequest(c: Context): string {
  // Récupérer l'IP réelle derrière les proxys si disponible
  const forwardedFor = c.req.header('x-forwarded-for');
  if (forwardedFor) {
    // Prendre la première IP dans la liste
    return forwardedFor.split(',')[0].trim();
  }
  
  // Comme fallback, utiliser l'IP directe
  return c.env?.remoteAddr || 'unknown-ip';
}

/**
 * Middleware standard pour la limitation de débit
 */
export function rateLimit(options: RateLimitOptions) {
  const limit = options.limit || 100;
  const windowMs = parseTimeWindow(options.window || '1m');
  const message = options.message || 'Trop de requêtes, veuillez réessayer plus tard';
  
  return async (c: Context, next: Next) => {
    const path = c.req.path;
    const ip = getIpFromRequest(c);
    const key = `${ip}:${path}`;
    
    // Initialiser le stockage pour ce chemin s'il n'existe pas
    if (!ipLimits.has(path)) {
      ipLimits.set(path, new Map());
    }
    
    const pathLimits = ipLimits.get(path)!;
    const now = Date.now();
    let entry = pathLimits.get(key);
    
    if (!entry || now > entry.resetAt) {
      // Réinitialiser l'entrée si elle est expirée ou n'existe pas
      entry = {
        count: 1,
        resetAt: now + windowMs
      };
    } else {
      // Incrémenter le compteur
      entry.count++;
    }
    
    // Mettre à jour l'entrée
    pathLimits.set(key, entry);
    
    // Ajouter des en-têtes pour informer le client
    c.header('X-RateLimit-Limit', limit.toString());
    c.header('X-RateLimit-Remaining', Math.max(0, limit - entry.count).toString());
    c.header('X-RateLimit-Reset', Math.ceil(entry.resetAt / 1000).toString());
    
    // Vérifier si la limite est dépassée
    if (entry.count > limit) {
      // Ajouter l'en-tête Retry-After
      const retryAfterSeconds = Math.ceil((entry.resetAt - now) / 1000);
      c.header('Retry-After', retryAfterSeconds.toString());
      
      logger.warn(`Limite de débit dépassée pour ${ip} sur ${path}`, 'rateLimitMiddleware', {
        ip,
        path,
        limit,
        window: options.window,
        count: entry.count
      });
      
      return c.json({
        error: 'rate_limit_exceeded',
        error_description: message,
        retry_after: retryAfterSeconds,
        status: 429
      }, 429);
    }
    
    // Continuer si la limite n'est pas dépassée
    await next();
  };
}

/**
 * Middleware de limitation de débit strict (plus restrictif)
 */
export function rateLimitStrict(options: RateLimitOptions) {
  const strictOptions = {
    limit: options.limit || 10,
    window: options.window || '1m',
    message: options.message || 'Trop de requêtes sensibles, veuillez réessayer plus tard'
  };
  
  return rateLimit(strictOptions);
} 