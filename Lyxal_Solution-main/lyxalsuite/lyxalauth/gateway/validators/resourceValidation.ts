/**
 * @file resourceValidation.ts
 * @description Fonctions de validation pour les routes liées aux ressources API
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createResourceSchema,
  updateResourceSchema,
  setResourceAsDefaultSchema,
  createResourceScopeSchema,
  updateResourceScopeSchema,
  paginationSchema,
  CreateResourceData,
  UpdateResourceData,
  SetResourceAsDefaultData,
  CreateResourceScopeData,
  UpdateResourceScopeData,
  PaginationData
} from './schemas/resourceSchemas';

/**
 * Valide les données de création d'une ressource API
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateResource(data: unknown): CreateResourceData {
  try {
    logger.debug('Validation des données de création de ressource API', 'resourceValidation');
    return createResourceSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de ressource API: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'une ressource API
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateResource(data: unknown): UpdateResourceData {
  try {
    logger.debug('Validation des données de mise à jour de ressource API', 'resourceValidation');
    return updateResourceSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de ressource API: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données pour définir une ressource API comme défaut
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSetResourceAsDefault(data: unknown): SetResourceAsDefaultData {
  try {
    logger.debug('Validation des données pour définir une ressource API comme défaut', 'resourceValidation');
    return setResourceAsDefaultSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation pour définir une ressource API comme défaut: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création d'un scope de ressource API
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateResourceScope(data: unknown): CreateResourceScopeData {
  try {
    logger.debug('Validation des données de création de scope de ressource API', 'resourceValidation');
    return createResourceScopeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de scope de ressource API: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un scope de ressource API
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateResourceScope(data: unknown): UpdateResourceScopeData {
  try {
    logger.debug('Validation des données de mise à jour de scope de ressource API', 'resourceValidation');
    return updateResourceScopeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de scope de ressource API: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de pagination
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validatePagination(data: unknown): PaginationData {
  try {
    logger.debug('Validation des données de pagination', 'resourceValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'resourceValidation', { issues: error.errors });
    throw error;
  }
} 