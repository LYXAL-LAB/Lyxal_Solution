/**
 * @file honoAuthMiddleware.ts
 * @description Middleware d'authentification pour la Gateway avec Hono
 */

import { Context, Next } from 'hono';
import { getCookie, setCookie, deleteCookie } from 'hono/cookie';
import { logtoService } from '../services/logtoService';
import { config } from '../config';
import { 
  extractTokenFromAuthHeader, 
  getUserIdFromToken, 
  parseJwt 
} from '../../sdk/core/auth';
import { structuredLogger as logger } from '../core/logger/structuredLogger';

// Étendre l'interface de la requête Hono pour inclure l'utilisateur
declare module 'hono' {
  interface ContextVariableMap {
    user?: {
      token: string;
      userId: string;
      tokenData: any;
    };
  }
}

/**
 * Middleware pour vérifier la validité d'un token JWT
 * @description Vérifie la présence et la validité d'un token JWT dans les headers ou cookies
 * @param c - Contexte Hono
 * @param next - Fonction next
 * @returns Response en cas d'erreur, sinon continue l'exécution
 */
export async function authMiddleware(c: Context, next: Next) {
  try {
    // Extraire le token du header Authorization ou des cookies
    let token = extractTokenFromAuthHeader(c.req.header('Authorization') || '');
    
    // Si pas de token dans le header, essayer dans les cookies
    if (!token) {
      token = getCookie(c, 'access_token');
    }
    
    // Si toujours pas de token, renvoyer une erreur
    if (!token) {
      logger.warn('Tentative d\'accès sans token d\'authentification', 'authMiddleware', {
        path: c.req.path,
        method: c.req.method
      });
      
      return c.json({
        error: 'unauthorized',
        error_description: 'Token d\'authentification manquant',
        status: 401
      }, 401);
    }
    
    // Vérifier la validité du token
    const isValid = await logtoService.verifyToken(token);
    
    if (!isValid) {
      // Si le token est invalide, essayer de le rafraîchir si un refresh token est disponible
      const refreshToken = getCookie(c, 'refresh_token');
      if (refreshToken) {
        try {
          logger.info('Tentative de rafraîchissement du token expiré', 'authMiddleware');
          
          const response = await logtoService.refreshToken(refreshToken);
          
          // Mettre à jour les cookies avec les nouveaux tokens
          setTokenCookies(c, response.accessToken, response.refreshToken);
          
          // Continuer avec le nouveau token
          const userId = getUserIdFromToken(response.accessToken) || '';
          c.set('user', {
            token: response.accessToken,
            userId,
            tokenData: parseJwt(response.accessToken)
          });
          
          logger.info('Token rafraîchi avec succès', 'authMiddleware', { userId });
          
          await next();
          return;
        } catch (refreshError: any) {
          // Si le rafraîchissement échoue, supprimer les cookies et renvoyer une erreur
          logger.warn('Échec du rafraîchissement du token', 'authMiddleware', { 
            error: refreshError.message 
          });
          
          clearTokenCookies(c);
          
          return c.json({
            error: 'invalid_token',
            error_description: 'Session expirée, veuillez vous reconnecter',
            status: 401
          }, 401);
        }
      }
      
      logger.warn('Token invalide sans refresh token disponible', 'authMiddleware');
      
      // Si pas de refresh token, renvoyer une erreur
      return c.json({
        error: 'invalid_token',
        error_description: 'Token d\'authentification invalide ou expiré',
        status: 401
      }, 401);
    }
    
    // Si le token est valide, extraire l'ID utilisateur
    const userId = getUserIdFromToken(token);
    
    if (!userId) {
      logger.warn('Token valide mais sans ID utilisateur', 'authMiddleware');
      
      return c.json({
        error: 'invalid_token',
        error_description: 'Token d\'authentification invalide (user ID manquant)',
        status: 401
      }, 401);
    }
    
    // Ajouter les informations d'authentification au contexte
    c.set('user', {
      token,
      userId,
      tokenData: parseJwt(token)
    });
    
    logger.debug('Authentification réussie', 'authMiddleware', { userId });
    
    await next();
  } catch (error: any) {
    logger.error(`Erreur dans le middleware d'authentification: ${error.message}`, 'authMiddleware', {
      stack: error.stack,
      path: c.req.path
    });
    
    return c.json({
      error: 'auth_error',
      error_description: 'Erreur lors de la vérification de l\'authentification',
      status: 500
    }, 500);
  }
}

/**
 * Middleware pour vérifier une clé API
 * @description Vérifie la présence et la validité d'une clé API dans les headers
 * @param c - Contexte Hono
 * @param next - Fonction next
 * @returns Response en cas d'erreur, sinon continue l'exécution
 */
export async function apiKeyMiddleware(c: Context, next: Next) {
  try {
    const apiKey = c.req.header('x-api-key');
    
    // Vérifier si la clé API est présente et valide
    if (!apiKey || apiKey !== config.logto.apiKey) {
      logger.warn('Tentative d\'accès avec une clé API invalide ou manquante', 'apiKeyMiddleware', {
        path: c.req.path,
        method: c.req.method
      });
      
      return c.json({
        error: 'invalid_api_key',
        error_description: 'Clé API invalide ou manquante',
        status: 401
      }, 401);
    }
    
    logger.debug('Authentification par clé API réussie', 'apiKeyMiddleware');
    
    await next();
  } catch (error: any) {
    logger.error(`Erreur dans le middleware de clé API: ${error.message}`, 'apiKeyMiddleware', {
      stack: error.stack,
      path: c.req.path
    });
    
    return c.json({
      error: 'api_key_error',
      error_description: 'Erreur lors de la vérification de la clé API',
      status: 500
    }, 500);
  }
}

/**
 * Définit les cookies pour les tokens
 * @description Configure les cookies sécurisés pour stocker les tokens d'authentification
 * @param c - Contexte Hono
 * @param accessToken - Token d'accès à stocker
 * @param refreshToken - Token de rafraîchissement à stocker
 */
export function setTokenCookies(c: Context, accessToken?: string, refreshToken?: string) {
  const cookieOptions = {
    httpOnly: true,
    secure: config.secureCookies,
    sameSite: 'Lax' as const,
    maxAge: config.cookieMaxAge
  };
  
  if (accessToken) {
    setCookie(c, 'access_token', accessToken, cookieOptions);
    logger.debug('Cookie access_token défini', 'setTokenCookies');
  }
  
  if (refreshToken) {
    // Le refresh token a une durée de vie plus longue
    setCookie(c, 'refresh_token', refreshToken, {
      ...cookieOptions,
      maxAge: config.cookieMaxAge * 2
    });
    logger.debug('Cookie refresh_token défini', 'setTokenCookies');
  }
}

/**
 * Supprime les cookies de tokens
 * @description Efface les cookies d'authentification (logout)
 * @param c - Contexte Hono
 */
export function clearTokenCookies(c: Context) {
  deleteCookie(c, 'access_token');
  deleteCookie(c, 'refresh_token');
  logger.debug('Cookies d\'authentification supprimés', 'clearTokenCookies');
} 