import { Context, MiddlewareHandler, Next } from 'hono';
import { Logger } from './logger';
import { 
  SurrealError, 
  SurrealConnectionError,
  SurrealAuthError,
  SurrealNamespaceError,
  SurrealQueryError,
  SaaSNotFoundError,
  SaaSInactiveError,
  WorkspaceNotFoundError,
  WorkspaceInactiveError,
  WorkspaceModuleNotFoundError,
  ProvisioningError
} from '../types/errors.types';

/**
 * Interface pour les réponses d'erreur standardisées
 */
export interface ErrorResponse {
  error: string;
  code: string;
  message: string;
  details?: Record<string, any>;
  path?: string;
  timestamp: string;
}

/**
 * Middleware pour la gestion centralisée des erreurs
 */
export const errorHandler: MiddlewareHandler = async (c: Context, next: Next) => {
  try {
    await next();
    return;
  } catch (error) {
    const logger = Logger.getInstance();
    
    // Construire une réponse d'erreur standardisée
    const errorResponse: ErrorResponse = {
      error: 'UnknownError',
      code: 'ERR_UNKNOWN',
      message: 'Une erreur inconnue est survenue',
      timestamp: new Date().toISOString()
    };
    
    // Ajouter le chemin de la requête
    errorResponse.path = c.req.path;
    
    // Définir le code HTTP par défaut
    let statusCode = 500;
    
    // Traiter les erreurs spécifiques
    if (error instanceof SurrealError) {
      const surrealError = error as SurrealError;
      errorResponse.error = surrealError.name;
      errorResponse.code = surrealError.code;
      errorResponse.message = surrealError.message;
      if (surrealError.details) {
        errorResponse.details = surrealError.details;
      }
      
      // Mapper les types d'erreurs spécifiques aux codes HTTP appropriés
      if (error instanceof SurrealConnectionError) {
        statusCode = 503; // Service Unavailable
        logger.error(`Erreur de connexion SurrealDB: ${surrealError.message}`, surrealError as Error);
      } 
      else if (error instanceof SurrealAuthError) {
        statusCode = 401; // Unauthorized
        logger.error(`Erreur d'authentification SurrealDB: ${surrealError.message}`, surrealError as Error);
      } 
      else if (error instanceof SurrealNamespaceError) {
        statusCode = 500; // Internal Server Error
        logger.error(`Erreur de namespace SurrealDB: ${surrealError.message}`, surrealError as Error);
      } 
      else if (error instanceof SurrealQueryError) {
        statusCode = 400; // Bad Request
        logger.error(`Erreur de requête SurrealDB: ${surrealError.message}`, surrealError as Error);
      } 
      else if (error instanceof SaaSNotFoundError) {
        statusCode = 404; // Not Found
        logger.warn(`Instance SaaS non trouvée: ${surrealError.message}`);
      } 
      else if (error instanceof SaaSInactiveError) {
        statusCode = 403; // Forbidden
        logger.warn(`Instance SaaS inactive: ${surrealError.message}`);
      } 
      else if (error instanceof WorkspaceNotFoundError) {
        statusCode = 404; // Not Found
        logger.warn(`Workspace non trouvé: ${surrealError.message}`);
      } 
      else if (error instanceof WorkspaceInactiveError) {
        statusCode = 403; // Forbidden
        logger.warn(`Workspace inactif: ${surrealError.message}`);
      }
      else if (error instanceof WorkspaceModuleNotFoundError) {
        statusCode = 404; // Not Found
        logger.warn(`Module de workspace non trouvé: ${surrealError.message}`);
      } 
      else if (error instanceof ProvisioningError) {
        statusCode = 500; // Internal Server Error
        logger.error(`Erreur de provisionnement: ${surrealError.message}`, surrealError as Error);
      } 
      else {
        // Autres erreurs SurrealDB
        logger.error(`Erreur SurrealDB: ${surrealError.message}`, surrealError as Error);
      }
    } 
    else if (error instanceof Error) {
      // Erreurs standards de JavaScript
      errorResponse.error = error.name;
      errorResponse.message = error.message;
      logger.error(`Erreur non gérée: ${error.message}`, error);
    } 
    else {
      // Erreurs inconnues (non-Error)
      errorResponse.message = String(error);
      logger.error(`Erreur inconnue: ${String(error)}`);
    }
    
    // Renvoyer la réponse d'erreur
    return c.json(errorResponse, statusCode as 200 | 400 | 401 | 403 | 404 | 500 | 503);
  }
};

/**
 * Gestionnaire qui transforme les erreurs en objets SurrealError
 */
export function handleSurrealDBError(error: unknown, context?: string): SurrealError {
  if (error instanceof SurrealError) {
    return error;
  }
  
  const errorMessage = (error as Error)?.message || String(error);
  const contextPrefix = context ? `[${context}] ` : '';
  
  // Analyser le message d'erreur pour déterminer le type
  if (errorMessage.includes('connection') || errorMessage.includes('connect')) {
    return new SurrealConnectionError(`${contextPrefix}Erreur de connexion: ${errorMessage}`);
  } 
  else if (errorMessage.includes('auth') || errorMessage.includes('permission') || errorMessage.includes('credentials')) {
    return new SurrealAuthError(`${contextPrefix}Erreur d'authentification: ${errorMessage}`);
  } 
  else if (errorMessage.includes('namespace')) {
    return new SurrealNamespaceError(`${contextPrefix}Erreur de namespace: ${errorMessage}`);
  } 
  else if (errorMessage.includes('query') || errorMessage.includes('syntax')) {
    return new SurrealQueryError(`${contextPrefix}Erreur de requête: ${errorMessage}`);
  } 
  
  // Erreur générique SurrealDB par défaut
  return new SurrealError(`${contextPrefix}${errorMessage}`, 'ERR_SURREAL');
} 