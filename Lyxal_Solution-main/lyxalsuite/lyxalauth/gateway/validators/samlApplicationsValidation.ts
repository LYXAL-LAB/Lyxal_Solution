/**
 * @file samlApplicationsValidation.ts
 * @description Fonctions de validation pour les routes liées aux applications SAML
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createSamlApplicationSchema,
  updateSamlApplicationSchema,
  createSamlApplicationSecretSchema,
  updateSamlApplicationSecretSchema,
  CreateSamlApplicationData,
  UpdateSamlApplicationData,
  CreateSamlApplicationSecretData,
  UpdateSamlApplicationSecretData
} from './schemas/samlApplicationsSchemas';

/**
 * Valide les données de création d'une application SAML
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateSamlApplication(data: unknown): CreateSamlApplicationData {
  try {
    logger.debug('Validation des données de création d\'application SAML', 'samlApplicationsValidation');
    return createSamlApplicationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création d'application SAML: ${error.message}`, 'samlApplicationsValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'une application SAML
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateSamlApplication(data: unknown): UpdateSamlApplicationData {
  try {
    logger.debug('Validation des données de mise à jour d\'application SAML', 'samlApplicationsValidation');
    return updateSamlApplicationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour d'application SAML: ${error.message}`, 'samlApplicationsValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création d'un secret d'application SAML
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateSamlApplicationSecret(data: unknown): CreateSamlApplicationSecretData {
  try {
    logger.debug('Validation des données de création de secret d\'application SAML', 'samlApplicationsValidation');
    return createSamlApplicationSecretSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de secret d'application SAML: ${error.message}`, 'samlApplicationsValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un secret d'application SAML
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateSamlApplicationSecret(data: unknown): UpdateSamlApplicationSecretData {
  try {
    logger.debug('Validation des données de mise à jour de secret d\'application SAML', 'samlApplicationsValidation');
    return updateSamlApplicationSecretSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de secret d'application SAML: ${error.message}`, 'samlApplicationsValidation', { issues: error.errors });
    throw error;
  }
}
