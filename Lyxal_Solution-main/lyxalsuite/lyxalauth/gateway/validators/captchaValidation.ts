/**
 * @file captchaValidation.ts
 * @description Fonctions de validation pour les routes de CAPTCHA
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  updateCaptchaProviderSchema, UpdateCaptchaProvider,
  verifyCaptchaSchema, VerifyCaptcha,
  captchaConfigSchema, CaptchaConfig
} from './schemas/captchaSchemas';

/**
 * Valide les données de mise à jour d'un fournisseur de CAPTCHA
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateUpdateCaptchaProvider = (data: any): UpdateCaptchaProvider => {
  try {
    logger.debug('Validation des données de mise à jour du fournisseur de CAPTCHA', 'captchaValidation');
    return updateCaptchaProviderSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de mise à jour du CAPTCHA: ${error.message}`, 'captchaValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide la configuration d'un fournisseur de CAPTCHA
 * @param config La configuration à valider
 * @returns La configuration validée ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateCaptchaConfig = (config: any): CaptchaConfig => {
  try {
    logger.debug('Validation de la configuration du fournisseur de CAPTCHA', 'captchaValidation');
    return captchaConfigSchema.parse(config);
  } catch (error: any) {
    logger.error(`Erreur de validation de la configuration du CAPTCHA: ${error.message}`, 'captchaValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données de vérification d'un CAPTCHA
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateVerifyCaptcha = (data: any): VerifyCaptcha => {
  try {
    logger.debug('Validation des données de vérification du CAPTCHA', 'captchaValidation');
    return verifyCaptchaSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des données de vérification du CAPTCHA: ${error.message}`, 'captchaValidation', { issues: error.errors });
    throw error;
  }
}; 