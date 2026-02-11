/**
 * @file applicationValidation.ts
 * @description Fonctions de validation centralisées pour les routes d'applications
 */

import {
  createApplicationSchema,
  updateApplicationSchema,
  updateAppCustomDataSchema,
  assignApiResourceRolesSchema,
  addCustomDomainSchema,
  addApplicationSecretSchema,
  updateApplicationSecretSchema,
  assignUserConsentScopesSchema,
  updateAppSignInExperienceSchema,
  grantOrganizationAccessSchema,
  CreateApplicationData,
  UpdateApplicationData,
  UpdateAppCustomDataData,
  AssignApiResourceRolesData,
  AddCustomDomainData,
  AddApplicationSecretData,
  UpdateApplicationSecretData,
  AssignUserConsentScopesData,
  UpdateAppSignInExperienceData,
  GrantOrganizationAccessData
} from './schemas/applicationSchemas';
import { structuredLogger as logger } from '../core/logger/structuredLogger';

/**
 * Valide les données de création d'une application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateCreateApplication(input: unknown): CreateApplicationData {
  try {
    return createApplicationSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation de création d'application: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'une application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateUpdateApplication(input: unknown): UpdateApplicationData {
  try {
    return updateApplicationSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation de mise à jour d'application: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données personnalisées d'une application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateUpdateAppCustomData(input: unknown): UpdateAppCustomDataData {
  try {
    return updateAppCustomDataSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation des données personnalisées d'application: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données d'attribution de rôles de ressources API
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateAssignApiResourceRoles(input: unknown): AssignApiResourceRolesData {
  try {
    return assignApiResourceRolesSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation d'attribution de rôles: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données d'ajout de domaine personnalisé
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateAddCustomDomain(input: unknown): AddCustomDomainData {
  try {
    return addCustomDomainSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation d'ajout de domaine personnalisé: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données d'ajout de secret d'application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateAddApplicationSecret(input: unknown): AddApplicationSecretData {
  try {
    return addApplicationSecretSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation d'ajout de secret d'application: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données de mise à jour de secret d'application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateUpdateApplicationSecret(input: unknown): UpdateApplicationSecretData {
  try {
    return updateApplicationSecretSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation de mise à jour de secret d'application: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données d'attribution de scopes de consentement utilisateur
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateAssignUserConsentScopes(input: unknown): AssignUserConsentScopesData {
  try {
    return assignUserConsentScopesSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation d'attribution de scopes de consentement: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données de mise à jour de l'expérience de connexion d'une application
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateUpdateAppSignInExperience(input: unknown): UpdateAppSignInExperienceData {
  try {
    return updateAppSignInExperienceSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation de mise à jour d'expérience de connexion: ${error}`, 'application-validation');
    throw error;
  }
}

/**
 * Valide les données d'attribution d'accès à une organisation
 * @param input Données à valider
 * @returns Données validées avec le type approprié
 * @throws {Error} Si les données ne sont pas valides
 */
export function validateGrantOrganizationAccess(input: unknown): GrantOrganizationAccessData {
  try {
    return grantOrganizationAccessSchema.parse(input);
  } catch (error) {
    logger.error(`Erreur de validation d'attribution d'accès organisationnel: ${error}`, 'application-validation');
    throw error;
  }
}
