/**
 * @file interactionValidation.ts
 * @description Fonctions de validation pour les routes liées aux interactions
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  updateIdentifiersSchema,
  updateProfileSchema,
  patchProfileSchema,
  consentSchema,
  socialAuthorizationUriSchema,
  updateMfaSchema,
  singleSignOnAuthorizationUrlSchema,
  singleSignOnAuthenticationSchema,
  singleSignOnRegistrationSchema,
  UpdateIdentifiersData,
  UpdateProfileData,
  PatchProfileData,
  ConsentData,
  SocialAuthorizationUriData,
  UpdateMfaData,
  SingleSignOnAuthorizationUrlData,
  SingleSignOnAuthenticationData,
  SingleSignOnRegistrationData
} from './schemas/interactionSchemas';

/**
 * Valide les données de mise à jour des identifiants
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateIdentifiers(data: unknown): UpdateIdentifiersData {
  try {
    logger.debug('Validation des données de mise à jour des identifiants', 'interactionValidation');
    return updateIdentifiersSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour des identifiants: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour du profil
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateProfile(data: unknown): UpdateProfileData {
  try {
    logger.debug('Validation des données de mise à jour du profil', 'interactionValidation');
    return updateProfileSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du profil: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour partielle du profil
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validatePatchProfile(data: unknown): PatchProfileData {
  try {
    logger.debug('Validation des données de mise à jour partielle du profil', 'interactionValidation');
    return patchProfileSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour partielle du profil: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de consentement
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateConsent(data: unknown): ConsentData {
  try {
    logger.debug('Validation des données de consentement', 'interactionValidation');
    return consentSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de consentement: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'autorisation sociale
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSocialAuthorizationUri(data: unknown): SocialAuthorizationUriData {
  try {
    logger.debug('Validation des données d\'autorisation sociale', 'interactionValidation');
    return socialAuthorizationUriSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'autorisation sociale: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour MFA
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateMfa(data: unknown): UpdateMfaData {
  try {
    logger.debug('Validation des données de mise à jour MFA', 'interactionValidation');
    return updateMfaSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour MFA: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'URL d'autorisation SSO
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSingleSignOnAuthorizationUrl(data: unknown): SingleSignOnAuthorizationUrlData {
  try {
    logger.debug('Validation des données d\'URL d\'autorisation SSO', 'interactionValidation');
    return singleSignOnAuthorizationUrlSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'URL d'autorisation SSO: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'authentification SSO
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSingleSignOnAuthentication(data: unknown): SingleSignOnAuthenticationData {
  try {
    logger.debug('Validation des données d\'authentification SSO', 'interactionValidation');
    return singleSignOnAuthenticationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'authentification SSO: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'enregistrement SSO
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSingleSignOnRegistration(data: unknown): SingleSignOnRegistrationData {
  try {
    logger.debug('Validation des données d\'enregistrement SSO', 'interactionValidation');
    return singleSignOnRegistrationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'enregistrement SSO: ${error.message}`, 'interactionValidation', { issues: error.errors });
    throw error;
  }
} 