/**
 * @file oneTimeTokenValidation.ts
 * @description Fonctions de validation pour les routes liées aux jetons à usage unique
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createOneTimeTokenSchema,
  verifyOneTimeTokenSchema,
  updateOneTimeTokenStatusSchema,
  paginationSchema,
  CreateOneTimeTokenData,
  VerifyOneTimeTokenData,
  UpdateOneTimeTokenStatusData,
  PaginationData
} from './schemas/oneTimeTokenSchemas';

/**
 * Valide les données de création d'un jeton à usage unique
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateOneTimeToken(data: unknown): CreateOneTimeTokenData {
  try {
    logger.debug('Validation des données de création d\'un jeton à usage unique', 'oneTimeTokenValidation');
    return createOneTimeTokenSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création d'un jeton à usage unique: ${error.message}`, 'oneTimeTokenValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de vérification d'un jeton à usage unique
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateVerifyOneTimeToken(data: unknown): VerifyOneTimeTokenData {
  try {
    logger.debug('Validation des données de vérification d\'un jeton à usage unique', 'oneTimeTokenValidation');
    return verifyOneTimeTokenSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de vérification d'un jeton à usage unique: ${error.message}`, 'oneTimeTokenValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour du statut d'un jeton à usage unique
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateOneTimeTokenStatus(data: unknown): UpdateOneTimeTokenStatusData {
  try {
    logger.debug('Validation des données de mise à jour du statut d\'un jeton à usage unique', 'oneTimeTokenValidation');
    return updateOneTimeTokenStatusSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour du statut d'un jeton à usage unique: ${error.message}`, 'oneTimeTokenValidation', { issues: error.errors });
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
    logger.debug('Validation des données de pagination', 'oneTimeTokenValidation');
    return paginationSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de pagination: ${error.message}`, 'oneTimeTokenValidation', { issues: error.errors });
    throw error;
  }
} 