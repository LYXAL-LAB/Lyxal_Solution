/**
 * @file csrfProtection.ts
 * @description Middleware de protection contre les attaques CSRF (Cross-Site Request Forgery)
 */

import { Context, Next } from 'hono';
import { getCookie, setCookie } from 'hono/cookie';
import { config } from '../config';
import crypto from 'crypto';

// Nom du cookie qui stockera le token CSRF
const CSRF_COOKIE_NAME = 'csrf_token';
// Nom du header qui doit contenir le token CSRF
const CSRF_HEADER_NAME = 'x-csrf-token';
// Durée de validité du token CSRF en secondes (1 heure par défaut)
const CSRF_TOKEN_TTL = 3600;

/**
 * Génère un token CSRF aléatoire et sécurisé
 */
function generateCsrfToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Vérifie si le token CSRF est valide (comparaison à temps constant)
 */
function validateCsrfToken(token1: string, token2: string): boolean {
  if (!token1 || !token2 || token1.length !== token2.length) {
    return false;
  }
  
  // Utilisation d'une comparaison à temps constant pour éviter les attaques timing
  return crypto.timingSafeEqual(
    Buffer.from(token1, 'hex'),
    Buffer.from(token2, 'hex')
  );
}

/**
 * Middleware qui génère et injecte un token CSRF pour les requêtes GET
 * Ce token sera stocké dans un cookie sécurisé et devra être renvoyé
 * dans un header pour les requêtes mutables (POST, PUT, etc.)
 */
export function csrfTokenInjector() {
  return async (c: Context, next: Next) => {
    // Ne générer un nouveau token que pour les requêtes GET
    if (c.req.method === 'GET') {
      // Générer un nouveau token CSRF
      const csrfToken = generateCsrfToken();
      
      // Définir le cookie avec les options de sécurité modernes
      setCookie(c, CSRF_COOKIE_NAME, csrfToken, {
        httpOnly: true,             // Empêche l'accès via JavaScript
        secure: config.secureCookies, // Uniquement via HTTPS en production
        sameSite: 'Lax',           // Protection contre CSRF tout en permettant la navigation
        maxAge: CSRF_TOKEN_TTL,     // Durée de vie du token
        path: '/',                  // Disponible pour tout le site
      });
      
      // Ajouter le token à l'en-tête de la réponse pour que le frontend puisse le récupérer
      c.header('X-CSRF-Token', csrfToken);
    }
    
    await next();
  };
}

/**
 * Middleware qui vérifie la présence et la validité du token CSRF
 * pour les requêtes mutables (POST, PUT, DELETE, PATCH)
 */
export function csrfProtection() {
  return async (c: Context, next: Next) => {
    const method = c.req.method;
    
    // Ne vérifier que les méthodes mutables
    if (['POST', 'PUT', 'DELETE', 'PATCH'].includes(method)) {
      // Récupérer le token depuis le cookie
      const cookieToken = getCookie(c, CSRF_COOKIE_NAME);
      // Récupérer le token depuis l'en-tête
      const headerToken = c.req.header(CSRF_HEADER_NAME);
      
      // Vérifier que les deux tokens existent et sont identiques
      if (!cookieToken || !headerToken || !validateCsrfToken(cookieToken, headerToken)) {
        return c.json({
          error: 'csrf_validation_failed',
          error_description: 'Protection CSRF: validation du token échouée',
          status: 403
        }, 403);
      }
    }
    
    await next();
  };
}

/**
 * Middleware combiné qui injecte et vérifie les tokens CSRF
 */
export function csrfMiddleware() {
  const injector = csrfTokenInjector();
  const protector = csrfProtection();
  
  return async (c: Context, next: Next) => {
    // D'abord injecter le token si nécessaire
    await injector(c, next.clone());
    // Puis vérifier le token pour les requêtes mutables
    await protector(c, next);
  };
} 