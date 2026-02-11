/**
 * @file subjectTokenValidation.ts
 * @description Fonctions de validation pour les routes liées aux tokens de sujet
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createSubjectTokenSchema,
  CreateSubjectTokenData
} from './schemas/subjectTokenSchemas';

/**
 * Valide les données de création d'un token de sujet
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateSubjectToken(data: unknown): CreateSubjectTokenData {
  try {
    logger.debug('Validation des données de création de token de sujet', 'subjectTokenValidation');
    return createSubjectTokenSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de token de sujet: ${error.message}`, 'subjectTokenValidation', { issues: error.errors });
    throw error;
  }
} 