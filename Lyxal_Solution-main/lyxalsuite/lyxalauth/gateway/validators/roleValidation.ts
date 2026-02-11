/**
 * @file roleValidation.ts
 * @description Fonctions de validation pour les routes liées aux rôles
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createRoleSchema,
  updateRoleSchema,
  assignRoleToUsersSchema,
  assignRoleToApplicationsSchema,
  linkScopesToRoleSchema,
  paginationSchema,
  CreateRoleData,
  UpdateRoleData,
  AssignRoleToUsersData,
  AssignRoleToApplicationsData,
  LinkScopesToRoleData,
  PaginationData
} from './schemas/roleSchemas';

/**
 * Valide les données de création d'un rôle
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateRole(data: unknown): CreateRoleData {
  try {
    logger.debug('Validation des données de création de rôle', 'roleValidation');
    return createRoleSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de rôle: ${error.message}`, 'roleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un rôle
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateRole(data: unknown): UpdateRoleData {
  try {
    logger.debug('Validation des données de mise à jour de rôle', 'roleValidation');
    return updateRoleSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de rôle: ${error.message}`, 'roleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'assignation de rôle à des utilisateurs
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignRoleToUsers(data: unknown): AssignRoleToUsersData {
  try {
    logger.debug('Validation des données d\'assignation de rôle à des utilisateurs', 'roleValidation');
    return assignRoleToUsersSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'assignation de rôle à des utilisateurs: ${error.message}`, 'roleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'assignation de rôle à des applications
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignRoleToApplications(data: unknown): AssignRoleToApplicationsData {
  try {
    logger.debug('Validation des données d\'assignation de rôle à des applications', 'roleValidation');
    return assignRoleToApplicationsSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'assignation de rôle à des applications: ${error.message}`, 'roleValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de liaison de scopes à un rôle
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateLinkScopesToRole(data: unknown): LinkScopesToRoleData {
  try {
    logger.debug('Validation des données de liaison de scopes à un rôle', 'roleValidation');
    return linkScopesToRoleSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de liaison de scopes à un rôle: ${error.message}`, 'roleValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'roleValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'roleValidation', { issues: error.errors });
    throw error;
  }
} 