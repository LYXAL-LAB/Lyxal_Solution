/**
 * @file auth.ts
 * @description Fonctions d'authentification partagées pour tous les modules lyxalauth
 */

import { DecodedToken } from './types';

/**
 * Parse un JWT et retourne son contenu décodé
 * @param token JWT token à décoder
 * @returns Le contenu décodé du token ou null si invalide
 */
export function parseJwt(token: string): DecodedToken | null {
  try {
    // Le token JWT est divisé en trois parties: header.payload.signature
    const base64Url = token.split('.')[1];
    if (!base64Url) return null;
    
    // Décoder la partie payload du token
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    );

    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('Erreur lors du décodage du JWT:', error);
    return null;
  }
}

/**
 * Vérifie si un token JWT est expiré
 * @param token Le token JWT à vérifier ou un objet token déjà décodé
 * @returns true si le token est expiré, false sinon
 */
export function isTokenExpired(token: string | DecodedToken): boolean {
  try {
    const decodedToken = typeof token === 'string' ? parseJwt(token) : token;
    if (!decodedToken || !decodedToken.exp) return true;
    
    // exp est en secondes depuis l'epoch, Date.now() est en millisecondes
    const currentTime = Math.floor(Date.now() / 1000);
    return decodedToken.exp < currentTime;
  } catch (error) {
    console.error('Erreur lors de la vérification de l\'expiration du token:', error);
    return true; // Par sécurité, on considère le token comme expiré en cas d'erreur
  }
}

/**
 * Calcule le temps restant avant expiration d'un token en secondes
 * @param token Le token JWT à vérifier ou un objet token déjà décodé
 * @returns Le nombre de secondes avant expiration, ou 0 si expiré/invalide
 */
export function getTokenTimeRemaining(token: string | DecodedToken): number {
  try {
    const decodedToken = typeof token === 'string' ? parseJwt(token) : token;
    if (!decodedToken || !decodedToken.exp) return 0;
    
    const currentTime = Math.floor(Date.now() / 1000);
    const timeRemaining = decodedToken.exp - currentTime;
    
    return timeRemaining > 0 ? timeRemaining : 0;
  } catch (error) {
    console.error('Erreur lors du calcul du temps restant:', error);
    return 0;
  }
}

/**
 * Vérifie si un token possède un scope spécifique
 * @param token Le token JWT à vérifier ou un objet token déjà décodé
 * @param requiredScope Le scope requis
 * @returns true si le token possède le scope requis, false sinon
 */
export function hasScope(token: string | DecodedToken, requiredScope: string): boolean {
  try {
    const decodedToken = typeof token === 'string' ? parseJwt(token) : token;
    if (!decodedToken || !decodedToken.scope) return false;
    
    const scopes = decodedToken.scope.split(' ');
    return scopes.includes(requiredScope);
  } catch (error) {
    console.error('Erreur lors de la vérification des scopes:', error);
    return false;
  }
}

/**
 * Vérifie si un token possède un rôle spécifique
 * @param token Le token JWT à vérifier ou un objet token déjà décodé
 * @param requiredRole Le rôle requis
 * @returns true si le token possède le rôle requis, false sinon
 */
export function hasRole(token: string | DecodedToken, requiredRole: string): boolean {
  try {
    const decodedToken = typeof token === 'string' ? parseJwt(token) : token;
    if (!decodedToken || !decodedToken.roles || !Array.isArray(decodedToken.roles)) return false;
    
    return decodedToken.roles.includes(requiredRole);
  } catch (error) {
    console.error('Erreur lors de la vérification des rôles:', error);
    return false;
  }
}

/**
 * Extrait le userId (subject) d'un token
 * @param token Le token JWT à vérifier ou un objet token déjà décodé
 * @returns Le userId ou null si non trouvé
 */
export function getUserIdFromToken(token: string | DecodedToken): string | null {
  try {
    const decodedToken = typeof token === 'string' ? parseJwt(token) : token;
    if (!decodedToken || !decodedToken.sub) return null;
    
    return decodedToken.sub;
  } catch (error) {
    console.error('Erreur lors de l\'extraction du userId:', error);
    return null;
  }
}

/**
 * Vérifie si un token est valide (bien formé, non expiré)
 * @param token Le token JWT à vérifier
 * @returns true si le token est valide, false sinon
 */
export function isTokenValid(token: string): boolean {
  if (!token) return false;
  
  const decodedToken = parseJwt(token);
  if (!decodedToken) return false;
  
  return !isTokenExpired(decodedToken);
}

/**
 * Extrait le token d'authentification du header Authorization
 * @param authHeader Header Authorization
 * @returns Token extrait ou undefined
 */
export function extractTokenFromAuthHeader(authHeader?: string): string | undefined {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return undefined;
  }
  
  return authHeader.split(' ')[1];
} 