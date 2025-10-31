/**
 * @file organizationInvitationValidation.ts
 * @description Fonctions de validation pour les routes liées aux invitations d'organisation
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createOrganizationInvitationSchema,
  updateOrganizationInvitationStatusSchema,
  paginationSchema,
  CreateOrganizationInvitationData,
  UpdateOrganizationInvitationStatusData,
  PaginationData
} from './schemas/organizationInvitationSchemas';

/**
 * Valide les données de création d'une invitation à une organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateOrganizationInvitation(data: unknown): CreateOrganizationInvitationData {
  try {
    logger.debug('Validation des données de création d\'invitation', 'organizationInvitationValidation');
    return createOrganizationInvitationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création d'invitation: ${error.message}`, 'organizationInvitationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour du statut d'une invitation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOrganizationInvitationStatus(data: unknown): UpdateOrganizationInvitationStatusData {
  try {
    logger.debug('Validation des données de mise à jour du statut d\'invitation', 'organizationInvitationValidation');
    return updateOrganizationInvitationStatusSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du statut d'invitation: ${error.message}`, 'organizationInvitationValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'organizationInvitationValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'organizationInvitationValidation', { issues: error.errors });
    throw error;
  }
}
