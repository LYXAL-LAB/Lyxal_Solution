/**
 * @file utils.ts
 * @description Fonctions utilitaires partagées pour tous les modules lyxalauth
 */

import { AuthErrorResponse } from './types';

/**
 * Construit une chaîne de requête à partir d'un objet de paramètres
 * @param params Objet contenant les paramètres à inclure dans la chaîne de requête
 * @returns Chaîne de requête formatée (sans le ? initial)
 */
export function buildQueryParams(params: Record<string, any>): string {
  const queryParams = new URLSearchParams();
  
  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null) {
      if (Array.isArray(value)) {
        // Pour les tableaux, ajouter chaque élément avec le même nom de clé
        value.forEach(item => {
          queryParams.append(key, item.toString());
        });
      } else {
        queryParams.append(key, value.toString());
      }
    }
  }
  
  return queryParams.toString();
}

/**
 * Transforme une erreur en objet AuthErrorResponse standardisé
 * @param error L'erreur à transformer
 * @returns Objet AuthErrorResponse standardisé
 */
export function mapError(error: any): AuthErrorResponse {
  if (error && typeof error === 'object') {
    // Si l'erreur est déjà au format attendu
    if (error.error && typeof error.error === 'string') {
      return {
        error: error.error,
        error_description: error.error_description || error.message || 'Erreur inconnue',
        status: error.status || 500
      };
    }
    
    // Si l'erreur vient d'une réponse fetch
    if (error.status && typeof error.status === 'number') {
      return {
        error: `http_error_${error.status}`,
        error_description: error.statusText || 'Erreur HTTP',
        status: error.status
      };
    }
    
    // Si c'est une erreur JavaScript
    if (error.message) {
      return {
        error: error.name || 'error',
        error_description: error.message,
        status: 500
      };
    }
  }
  
  // Erreur par défaut
  return {
    error: 'unknown_error',
    error_description: error?.toString() || 'Erreur inconnue',
    status: 500
  };
}

/**
 * Détermine si une chaîne est une adresse email valide
 * @param value La chaîne à vérifier
 * @returns true si la chaîne est une adresse email valide, false sinon
 */
export function isValidEmail(value: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(value);
}

/**
 * Détermine si une chaîne est un numéro de téléphone valide
 * @param value La chaîne à vérifier
 * @returns true si la chaîne est un numéro de téléphone valide, false sinon
 */
export function isValidPhone(value: string): boolean {
  // Format international E.164 (simpliste)
  const phoneRegex = /^\+[1-9]\d{1,14}$/;
  return phoneRegex.test(value);
}

/**
 * Génère un ID unique
 * @returns Un ID unique au format UUID v4
 */
export function generateUniqueId(): string {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  
  // Fallback si randomUUID n'est pas disponible
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Formatte une date en ISO string
 * @param date Date à formater
 * @returns Date au format ISO string
 */
export function formatDate(date: Date): string {
  return date.toISOString();
}

/**
 * Récupère le token depuis un header Authorization
 * @param authHeader Header Authorization (Bearer token)
 * @returns Le token ou null si non trouvé
 */
export function extractTokenFromAuthHeader(authHeader?: string): string | null {
  if (!authHeader) return null;
  
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return null;
  
  return parts[1];
}

/**
 * Crée un header Authorization avec un token
 * @param token Token à inclure dans le header
 * @returns Header Authorization au format Bearer
 */
export function createAuthHeader(token: string): string {
  return `Bearer ${token}`;
}

/**
 * Vérifie si une URL est valide
 * @param url URL à vérifier
 * @returns true si l'URL est valide, false sinon
 */
export function isValidUrl(url: string): boolean {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
} 