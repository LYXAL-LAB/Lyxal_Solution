/**
 * @file rateLimiter.ts
 * @description Middleware de limitation de débit (rate limiting) pour prévenir les attaques DoS/DDoS
 */

import { Context, Next } from 'hono';

// Interface pour les entrées de limite de débit
interface RateLimitEntry {
  count: number;
  resetAt: number;
}

// Interface pour les options du rate limiter
interface RateLimiterOptions {
  windowMs: number;        // Fenêtre de temps en millisecondes
  maxRequests: number;     // Nombre maximal de requêtes par fenêtre
  message?: string;        // Message d'erreur personnalisé
  statusCode?: number;     // Code de statut HTTP personnalisé
  keyGenerator?: (c: Context) => string; // Générateur de clé personnalisé
}

// Stockage en mémoire pour les limites de débit
const ipLimits = new Map<string, RateLimitEntry>();

/**
 * Nettoie périodiquement les entrées expirées du stockage en mémoire
 */
function setupCleanup() {
  setInterval(() => {
    const now = Date.now();
    for (const [key, entry] of ipLimits.entries()) {
      if (now > entry.resetAt) {
        ipLimits.delete(key);
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
  // Note: Dans Hono, l'accès à l'IP peut varier selon l'environnement d'exécution
  // Cette méthode est simplifiée, à adapter selon le contexte de déploiement
  return c.env?.remoteAddr || 'unknown-ip';
}

/**
 * Crée et renvoie un middleware de limitation de débit
 */
export function rateLimiter(options: RateLimiterOptions) {
  const windowMs = options.windowMs || 60000; // 1 minute par défaut
  const maxRequests = options.maxRequests || 100; // 100 requêtes par défaut
  const message = options.message || 'Trop de requêtes, veuillez réessayer plus tard';
  const statusCode = options.statusCode || 429; // Too Many Requests
  
  const keyGenerator = options.keyGenerator || getIpFromRequest;
  
  return async (c: Context, next: Next) => {
    // Générer la clé pour cette requête (IP par défaut)
    const key = keyGenerator(c);
    
    // Obtenir l'entrée actuelle ou en créer une nouvelle
    const now = Date.now();
    let entry = ipLimits.get(key);
    
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
    ipLimits.set(key, entry);
    
    // Ajouter des en-têtes pour informer le client
    c.header('X-RateLimit-Limit', maxRequests.toString());
    c.header('X-RateLimit-Remaining', Math.max(0, maxRequests - entry.count).toString());
    c.header('X-RateLimit-Reset', Math.ceil(entry.resetAt / 1000).toString());
    
    // Vérifier si la limite est dépassée
    if (entry.count > maxRequests) {
      // Ajouter l'en-tête Retry-After
      const retryAfterSeconds = Math.ceil((entry.resetAt - now) / 1000);
      c.header('Retry-After', retryAfterSeconds.toString());
      
      return c.json({
        error: 'rate_limit_exceeded',
        error_description: message,
        retry_after: retryAfterSeconds,
        status: statusCode
      }, statusCode);
    }
    
    // Continuer si la limite n'est pas dépassée
    await next();
  };
}

/**
 * Middleware pour les routes de mutation avec des règles strictes
 * (POST, PUT, DELETE, PATCH)
 */
export function mutationRateLimiter() {
  return rateLimiter({
    windowMs: 60000, // 1 minute
    maxRequests: 30, // 30 requêtes par minute
    message: 'Trop de requêtes de mutation, veuillez réessayer plus tard'
  });
}

/**
 * Middleware pour les routes d'API sensibles
 */
export function apiRateLimiter() {
  return rateLimiter({
    windowMs: 60000, // 1 minute
    maxRequests: 120, // 120 requêtes par minute
    message: 'Trop de requêtes d\'API, veuillez réessayer plus tard'
  });
}

/**
 * Middleware pour les routes d'authentification (plus restrictif)
 */
export function authRateLimiter() {
  return rateLimiter({
    windowMs: 300000, // 5 minutes
    maxRequests: 20,  // 20 requêtes par 5 minutes
    message: 'Trop de tentatives d\'authentification, veuillez réessayer plus tard'
  });
} 