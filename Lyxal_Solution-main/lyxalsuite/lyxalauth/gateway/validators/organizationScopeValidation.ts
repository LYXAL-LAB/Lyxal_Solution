/**
 * @file organizationScopeValidation.ts
 * @description Fonctions de validation pour les routes liées aux scopes d'organisation
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createOrganizationScopeSchema,
  updateOrganizationScopeSchema,
  paginationSchema,
  CreateOrganizationScopeData,
  UpdateOrganizationScopeData,
  PaginationData
} from './schemas/organizationScopeSchemas';

/**
 * Valide les données de création d'un scope d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateOrganizationScope(data: unknown): CreateOrganizationScopeData {
  try {
    logger.debug('Validation des données de création de scope d\'organisation', 'organizationScopeValidation');
    return createOrganizationScopeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de scope d'organisation: ${error.message}`, 'organizationScopeValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un scope d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOrganizationScope(data: unknown): UpdateOrganizationScopeData {
  try {
    logger.debug('Validation des données de mise à jour de scope d\'organisation', 'organizationScopeValidation');
    return updateOrganizationScopeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de scope d'organisation: ${error.message}`, 'organizationScopeValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'organizationScopeValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'organizationScopeValidation', { issues: error.errors });
    throw error;
  }
} 