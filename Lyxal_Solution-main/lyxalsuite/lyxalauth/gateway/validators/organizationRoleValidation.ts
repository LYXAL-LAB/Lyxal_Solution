/**
 * @file organizationRoleValidation.ts
 * @description Fonctions de validation pour les routes liées aux rôles d'organisation
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createOrganizationRoleSchema,
  updateOrganizationRoleSchema,
  assignOrganizationScopesSchema,
  assignResourceScopesSchema,
  paginationSchema,
  CreateOrganizationRoleData,
  UpdateOrganizationRoleData,
  AssignOrganizationScopesData,
  AssignResourceScopesData,
  PaginationData
} from './schemas/organizationRoleSchemas';

/**
 * Valide les données de création d'un rôle d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateOrganizationRole(data: unknown): CreateOrganizationRoleData {
  try {
    logger.debug('Validation des données de création de rôle d\'organisation', 'organizationRoleValidation');
    return createOrganizationRoleSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de rôle d'organisation: ${error.message}`, 'organizationRoleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un rôle d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOrganizationRole(data: unknown): UpdateOrganizationRoleData {
  try {
    logger.debug('Validation des données de mise à jour de rôle d\'organisation', 'organizationRoleValidation');
    return updateOrganizationRoleSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de rôle d'organisation: ${error.message}`, 'organizationRoleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'attribution de scopes à un rôle d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignOrganizationScopes(data: unknown): AssignOrganizationScopesData {
  try {
    logger.debug('Validation des données d\'attribution de scopes', 'organizationRoleValidation');
    return assignOrganizationScopesSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'attribution de scopes: ${error.message}`, 'organizationRoleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'attribution de scopes de ressource à un rôle d'organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignResourceScopes(data: unknown): AssignResourceScopesData {
  try {
    logger.debug('Validation des données d\'attribution de scopes de ressource', 'organizationRoleValidation');
    return assignResourceScopesSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'attribution de scopes de ressource: ${error.message}`, 'organizationRoleValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'organizationRoleValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'organizationRoleValidation', { issues: error.errors });
    throw error;
  }
}