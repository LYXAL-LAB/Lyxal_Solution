/**
 * @file experienceValidation.ts
 * @description Fonctions de validation pour les routes liées à l'expérience utilisateur
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  initInteractionSchema,
  updateInteractionEventSchema,
  identifyUserSchema,
  submitInteractionSchema,
  createPasswordVerificationSchema,
  createVerificationCodeSchema,
  verifyVerificationCodeSchema,
  InitInteractionData,
  UpdateInteractionEventData,
  IdentifyUserData,
  SubmitInteractionData,
  CreatePasswordVerificationData,
  CreateVerificationCodeData,
  VerifyVerificationCodeData
} from './schemas/experienceSchemas';

/**
 * Valide les données d'initialisation d'une interaction
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateInitInteraction(data: unknown): InitInteractionData {
  try {
    logger.debug('Validation des données d\'initialisation d\'interaction', 'experienceValidation');
    return initInteractionSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'initialisation d'interaction: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un événement d'interaction
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateInteractionEvent(data: unknown): UpdateInteractionEventData {
  try {
    logger.debug('Validation des données de mise à jour d\'événement d\'interaction', 'experienceValidation');
    return updateInteractionEventSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour d'événement d'interaction: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'identification d'un utilisateur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateIdentifyUser(data: unknown): IdentifyUserData {
  try {
    logger.debug('Validation des données d\'identification d\'utilisateur', 'experienceValidation');
    return identifyUserSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'identification d'utilisateur: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de soumission d'une interaction
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSubmitInteraction(data: unknown): SubmitInteractionData {
  try {
    logger.debug('Validation des données de soumission d\'interaction', 'experienceValidation');
    return submitInteractionSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de soumission d'interaction: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création d'un enregistrement de vérification par mot de passe
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreatePasswordVerification(data: unknown): CreatePasswordVerificationData {
  try {
    logger.debug('Validation des données de création de vérification par mot de passe', 'experienceValidation');
    return createPasswordVerificationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de vérification par mot de passe: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création et d'envoi d'un code de vérification
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateVerificationCode(data: unknown): CreateVerificationCodeData {
  try {
    logger.debug('Validation des données de création de code de vérification', 'experienceValidation');
    return createVerificationCodeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de code de vérification: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de vérification d'un code
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateVerifyVerificationCode(data: unknown): VerifyVerificationCodeData {
  try {
    logger.debug('Validation des données de vérification de code', 'experienceValidation');
    return verifyVerificationCodeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de vérification de code: ${error.message}`, 'experienceValidation', { issues: error.errors });
    throw error;
  }
} 