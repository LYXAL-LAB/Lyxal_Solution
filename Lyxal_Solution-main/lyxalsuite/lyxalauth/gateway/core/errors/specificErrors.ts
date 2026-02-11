/**
 * Erreurs spécifiques pour le module LyxalAuth
 * @module SpecificErrors
 */

import { AppError, ErrorCode } from './AppError';

/**
 * Erreur de validation des données
 */
export class ValidationError extends AppError {
  constructor(message: string = 'Données de validation invalides', details?: any) {
    super(message, ErrorCode.VALIDATION_ERROR, details);
  }
}

/**
 * Erreur d'authentification invalide
 */
export class InvalidAuthenticationError extends AppError {
  constructor(message: string = 'Authentification invalide') {
    super(message, ErrorCode.INVALID_CREDENTIALS);
  }
}

/**
 * Erreur de token expiré
 */
export class TokenExpiredError extends AppError {
  constructor(message: string = 'Token expiré') {
    super(message, ErrorCode.TOKEN_EXPIRED);
  }
}

/**
 * Erreur de permissions insuffisantes
 */
export class InsufficientPermissionsError extends AppError {
  constructor(message: string = 'Permissions insuffisantes') {
    super(message, ErrorCode.INSUFFICIENT_PERMISSIONS);
  }
}

/**
 * Erreur de configuration manquante
 */
export class ConfigurationMissingError extends AppError {
  constructor(message: string = 'Configuration manquante') {
    super(message, ErrorCode.INTERNAL_SERVER_ERROR);
  }
} 