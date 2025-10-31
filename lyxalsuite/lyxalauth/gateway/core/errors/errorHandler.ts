/**
 * @file errorHandler.ts
 * @description Gestionnaire d'erreurs centralisé pour l'application
 */

import { Context } from 'hono';
import { AppError, ErrorCode } from './AppError';
import { structuredLogger } from '../logger/structuredLogger';
import { ZodError } from 'zod';
import { ValidationError } from './specificErrors';

/**
 * Convertit une erreur Zod en ValidationError
 */
function handleZodError(error: ZodError): ValidationError {
  // Extraire les erreurs de validation
  const issues = error.errors.map(issue => ({
    path: issue.path.join('.'),
    message: issue.message,
    code: issue.code
  }));
  
  return new ValidationError('Validation des données échouée', { issues });
}

/**
 * Convertit une erreur standard en AppError
 */
function normalizeError(error: Error): AppError {
  // Si c'est déjà une AppError, la retourner telle quelle
  if (error instanceof AppError) {
    return error;
  }
  
  // Si c'est une erreur Zod, la convertir en ValidationError
  if (error instanceof ZodError) {
    return handleZodError(error);
  }
  
  // Sinon, créer une erreur interne générique
  return new AppError(
    'Une erreur inattendue est survenue',
    ErrorCode.INTERNAL_SERVER_ERROR,
    { originalError: error.message },
    false // Non opérationnelle car inattendue
  );
}

/**
 * Middleware de gestion globale des erreurs
 */
export function errorMiddleware() {
  return async (err: Error, c: Context) => {
    // Normaliser l'erreur
    const appError = normalizeError(err);
    
    // Journaliser l'erreur avec des détails différents selon qu'elle est opérationnelle ou non
    if (appError.isOperational) {
      // Erreur attendue (ex: validation, authentification)
      structuredLogger.warn(`${appError.name}: ${appError.message}`, 'error', {
        code: appError.code,
        details: appError.details,
        path: c.req.path,
        method: c.req.method
      });
    } else {
      // Erreur inattendue (bug potentiel)
      structuredLogger.error(`${appError.name}: ${appError.message}`, 'error', {
        code: appError.code,
        details: appError.details,
        stack: appError.stack,
        path: c.req.path,
        method: c.req.method
      });
    }
    
    // Renvoyer une réponse JSON standardisée
    return c.json(appError.toJSON(), appError.httpStatus as any);
  };
}

/**
 * Middleware pour gérer les routes non trouvées
 */
export function notFoundHandler() {
  return (c: Context) => {
    const path = c.req.path;
    const method = c.req.method;
    
    // Créer une erreur 404 standardisée
    const error = new AppError(
      `Route non trouvée: ${method} ${path}`,
      ErrorCode.RESOURCE_NOT_FOUND
    );
    
    // Logger l'erreur
    structuredLogger.warn(`Route non trouvée: ${method} ${path}`, 'route', {
      path,
      method
    });
    
    // Renvoyer une réponse JSON standardisée
    return c.json(error.toJSON(), error.httpStatus as any);
  };
} 