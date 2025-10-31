/**
 * @file middleware.ts
 * @description Middleware d'authentification pour les frameworks Node.js (Hono)
 */

import { Context, Next } from 'hono';
import { extractTokenFromAuthHeader, mapError } from '../core/utils';
import { isTokenValid, hasScope, hasRole, getUserIdFromToken } from '../core/auth';
import { AuthClient } from './client';

/**
 * Options pour le middleware d'authentification
 */
export interface AuthMiddlewareOptions {
  /** URL de base de la gateway */
  gatewayUrl: string;
  /** Clé API pour l'authentification serveur-à-serveur */
  apiKey?: string;
  /** Vérifier le token sur la gateway (plus sécurisé mais plus lent) */
  remoteVerification?: boolean;
}

// Étendre l'interface Context de Hono pour inclure auth
declare module 'hono' {
  interface ContextVariableMap {
    auth?: {
      userId: string;
      token: string;
      isAuthenticated: boolean;
      hasScope: (scope: string) => boolean;
      hasRole: (role: string) => boolean;
    };
  }
}

/**
 * Crée un middleware d'authentification pour Hono
 * @param options Options du middleware
 * @returns Middleware Hono
 */
export function createAuthMiddleware(options: AuthMiddlewareOptions) {
  const client = options.remoteVerification 
    ? new AuthClient({ 
        gatewayUrl: options.gatewayUrl,
        apiKey: options.apiKey
      })
    : null;

  /**
   * Middleware d'authentification Hono
   */
  return async function authMiddleware(c: Context, next: Next) {
    try {
      // Extraire le token du header Authorization
      const authHeader = c.req.header('authorization');
      const token = extractTokenFromAuthHeader(authHeader);
      
      if (!token) {
        return c.json({
          error: 'unauthorized',
          error_description: 'Token d\'authentification manquant',
          status: 401
        }, 401);
      }
      
      // Vérifier la validité du token
      let isValid: boolean;
      let userId: string | null = null;
      
      if (options.remoteVerification && client) {
        // Vérification à distance via la gateway
        const verification = await client.verifyToken(token);
        isValid = verification.valid;
        userId = verification.userId || null;
      } else {
        // Vérification locale du token
        isValid = isTokenValid(token);
        userId = getUserIdFromToken(token);
      }
      
      if (!isValid || !userId) {
        return c.json({
          error: 'invalid_token',
          error_description: 'Token d\'authentification invalide ou expiré',
          status: 401
        }, 401);
      }
      
      // Ajouter les informations d'authentification au contexte
      c.set('auth', {
        userId,
        token,
        isAuthenticated: true,
        // Fonctions pour vérifier les scopes et rôles
        hasScope: (scope: string) => hasScope(token, scope),
        hasRole: (role: string) => hasRole(token, role)
      });
      
      await next();
    } catch (error) {
      const mappedError = mapError(error);
      
      return c.json(mappedError, mappedError.status || 500);
    }
  };
}

/**
 * Middleware pour vérifier un scope
 * @param requiredScope Scope requis
 * @returns Middleware Hono
 */
export function requireScope(requiredScope: string) {
  return async function scopeMiddleware(c: Context, next: Next) {
    const auth = c.get('auth');
    
    if (!auth || !auth.isAuthenticated) {
      return c.json({
        error: 'unauthorized',
        error_description: 'Authentification requise',
        status: 401
      }, 401);
    }

    if (!auth.hasScope(requiredScope)) {
      return c.json({
        error: 'insufficient_scope',
        error_description: `Le scope "${requiredScope}" est requis`,
        status: 403
      }, 403);
    }

    await next();
  };
}

/**
 * Middleware pour vérifier un rôle
 * @param requiredRole Rôle requis
 * @returns Middleware Hono
 */
export function requireRole(requiredRole: string) {
  return async function roleMiddleware(c: Context, next: Next) {
    const auth = c.get('auth');
    
    if (!auth || !auth.isAuthenticated) {
      return c.json({
        error: 'unauthorized',
        error_description: 'Authentification requise',
        status: 401
      }, 401);
    }

    if (!auth.hasRole(requiredRole)) {
      return c.json({
        error: 'insufficient_role',
        error_description: `Le rôle "${requiredRole}" est requis`,
        status: 403
      }, 403);
    }

    await next();
  };
} 