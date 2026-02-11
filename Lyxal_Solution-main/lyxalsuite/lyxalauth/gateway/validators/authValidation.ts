/**
 * @file authValidation.ts
 * @description Fonctions de validation pour les routes d'authentification
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  loginSchema, Login,
  verifyTokenSchema, VerifyToken,
  refreshTokenSchema, RefreshToken,
  registerSchema, Register,
  resetPasswordRequestSchema, ResetPasswordRequest,
  resetPasswordConfirmSchema, ResetPasswordConfirm
} from './schemas/authSchemas';

/**
 * Valide les données de connexion
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateLogin = (body: any): Login => {
  try {
    logger.debug('Validation des données de connexion', 'authValidation');
    return loginSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de connexion: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données de vérification de token
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateVerifyToken = (body: any): VerifyToken => {
  try {
    logger.debug('Validation des données de vérification de token', 'authValidation');
    return verifyTokenSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de vérification de token: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données de rafraîchissement de token
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateRefreshToken = (body: any): RefreshToken => {
  try {
    logger.debug('Validation des données de rafraîchissement de token', 'authValidation');
    return refreshTokenSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de rafraîchissement de token: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données d'inscription
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateRegister = (body: any): Register => {
  try {
    logger.debug('Validation des données d\'inscription', 'authValidation');
    return registerSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données d'inscription: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données de demande de réinitialisation de mot de passe
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateResetPasswordRequest = (body: any): ResetPasswordRequest => {
  try {
    logger.debug('Validation des données de demande de réinitialisation de mot de passe', 'authValidation');
    return resetPasswordRequestSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de demande de réinitialisation de mot de passe: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données de confirmation de réinitialisation de mot de passe
 * @param body Les données du corps de la requête
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateResetPasswordConfirm = (body: any): ResetPasswordConfirm => {
  try {
    logger.debug('Validation des données de confirmation de réinitialisation de mot de passe', 'authValidation');
    return resetPasswordConfirmSchema.parse(body);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de confirmation de réinitialisation de mot de passe: ${error.message}`, 'authValidation', { issues: error.errors });
    throw error;
  }
}; 