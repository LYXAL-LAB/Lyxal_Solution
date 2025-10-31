/**
 * @file organizationValidation.ts
 * @description Fonctions de validation pour les routes liées aux organisations
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createOrganizationSchema,
  updateOrganizationSchema,
  organizationUserMembersSchema,
  assignRolesToUserSchema,
  organizationApplicationsSchema,
  assignRolesToApplicationSchema,
  jitEmailDomainsSchema,
  jitDefaultRolesSchema,
  jitSsoConnectorsSchema,
  paginationSchema,
  CreateOrganizationData,
  UpdateOrganizationData,
  OrganizationUserMembersData,
  AssignRolesToUserData,
  OrganizationApplicationsData,
  AssignRolesToApplicationData,
  JitEmailDomainsData,
  JitDefaultRolesData,
  JitSsoConnectorsData,
  PaginationData
} from './schemas/organizationSchemas';

/**
 * Valide les données de création d'une organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateOrganization(data: unknown): CreateOrganizationData {
  try {
    logger.debug('Validation des données de création d\'organisation', 'organizationValidation');
    return createOrganizationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création d'organisation: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'une organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOrganization(data: unknown): UpdateOrganizationData {
  try {
    logger.debug('Validation des données de mise à jour d\'organisation', 'organizationValidation');
    return updateOrganizationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour d'organisation: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de membres utilisateurs d'une organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateOrganizationUserMembers(data: unknown): OrganizationUserMembersData {
  try {
    logger.debug('Validation des données de membres utilisateurs', 'organizationValidation');
    return organizationUserMembersSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de membres utilisateurs: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'attribution de rôles à un utilisateur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignRolesToUser(data: unknown): AssignRolesToUserData {
  try {
    logger.debug('Validation des données d\'attribution de rôles à un utilisateur', 'organizationValidation');
    return assignRolesToUserSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'attribution de rôles à un utilisateur: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'applications d'une organisation
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateOrganizationApplications(data: unknown): OrganizationApplicationsData {
  try {
    logger.debug('Validation des données d\'applications', 'organizationValidation');
    return organizationApplicationsSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'applications: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'attribution de rôles à une application
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAssignRolesToApplication(data: unknown): AssignRolesToApplicationData {
  try {
    logger.debug('Validation des données d\'attribution de rôles à une application', 'organizationValidation');
    return assignRolesToApplicationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'attribution de rôles à une application: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de domaines email JIT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateJitEmailDomains(data: unknown): JitEmailDomainsData {
  try {
    logger.debug('Validation des données de domaines email JIT', 'organizationValidation');
    return jitEmailDomainsSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de domaines email JIT: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de rôles par défaut JIT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateJitDefaultRoles(data: unknown): JitDefaultRolesData {
  try {
    logger.debug('Validation des données de rôles par défaut JIT', 'organizationValidation');
    return jitDefaultRolesSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de rôles par défaut JIT: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de connecteurs SSO JIT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateJitSsoConnectors(data: unknown): JitSsoConnectorsData {
  try {
    logger.debug('Validation des données de connecteurs SSO JIT', 'organizationValidation');
    return jitSsoConnectorsSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de connecteurs SSO JIT: ${error.message}`, 'organizationValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'organizationValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'organizationValidation', { issues: error.errors });
    throw error;
  }
} 
