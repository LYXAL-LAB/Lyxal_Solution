/**
 * @file myAccountValidation.ts
 * @description Fonctions de validation pour les routes liées à la gestion du compte utilisateur
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  updateProfileSchema,
  updateOtherProfileSchema,
  updatePasswordSchema,
  updatePrimaryEmailSchema,
  updatePrimaryPhoneSchema,
  addUserIdentitySchema,
  deleteUserIdentitySchema,
  UpdateProfileData,
  UpdateOtherProfileData,
  UpdatePasswordData,
  UpdatePrimaryEmailData,
  UpdatePrimaryPhoneData,
  AddUserIdentityData,
  DeleteUserIdentityData
} from './schemas/myAccountSchemas';

/**
 * Valide les données de mise à jour du profil
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateProfile(data: unknown): UpdateProfileData {
  try {
    logger.debug('Validation des données de mise à jour du profil', 'myAccountValidation');
    return updateProfileSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du profil: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un autre profil
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOtherProfile(data: unknown): UpdateOtherProfileData {
  try {
    logger.debug('Validation des données de mise à jour d\'un autre profil', 'myAccountValidation');
    return updateOtherProfileSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour d'un autre profil: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour du mot de passe
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdatePassword(data: unknown): UpdatePasswordData {
  try {
    logger.debug('Validation des données de mise à jour du mot de passe', 'myAccountValidation');
    return updatePasswordSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du mot de passe: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour de l'email primaire
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdatePrimaryEmail(data: unknown): UpdatePrimaryEmailData {
  try {
    logger.debug('Validation des données de mise à jour de l\'email primaire', 'myAccountValidation');
    return updatePrimaryEmailSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de l'email primaire: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour du téléphone primaire
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdatePrimaryPhone(data: unknown): UpdatePrimaryPhoneData {
  try {
    logger.debug('Validation des données de mise à jour du téléphone primaire', 'myAccountValidation');
    return updatePrimaryPhoneSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du téléphone primaire: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données d'ajout d'une identité utilisateur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateAddUserIdentity(data: unknown): AddUserIdentityData {
  try {
    logger.debug('Validation des données d\'ajout d\'une identité utilisateur', 'myAccountValidation');
    return addUserIdentitySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'ajout d'une identité utilisateur: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de suppression d'une identité utilisateur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateDeleteUserIdentity(data: unknown): DeleteUserIdentityData {
  try {
    logger.debug('Validation des données de suppression d\'une identité utilisateur', 'myAccountValidation');
    return deleteUserIdentitySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de suppression d'une identité utilisateur: ${error.message}`, 'myAccountValidation', { issues: error.errors });
    throw error;
  }
} 