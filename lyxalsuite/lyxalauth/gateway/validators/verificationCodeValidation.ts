/**
 * @file verificationCodeValidation.ts
 * @description Fonctions de validation pour les routes liées aux codes de vérification
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  requestVerificationCodeSchema,
  verifyVerificationCodeSchema,
  RequestVerificationCodeData,
  VerifyVerificationCodeData
} from './schemas/verificationCodeSchemas';

/**
 * Valide les données de demande d'un code de vérification
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateRequestVerificationCode(data: unknown): RequestVerificationCodeData {
  try {
    logger.debug('Validation des données de demande de code de vérification', 'verificationCodeValidation');
    return requestVerificationCodeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de demande de code de vérification: ${error.message}`, 'verificationCodeValidation', { issues: error.errors });
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
    logger.debug('Validation des données de vérification de code', 'verificationCodeValidation');
    return verifyVerificationCodeSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de vérification de code: ${error.message}`, 'verificationCodeValidation', { issues: error.errors });
    throw error;
  }
} 