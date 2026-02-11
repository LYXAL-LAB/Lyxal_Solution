/**
 * @file swaggerValidation.ts
 * @description Fonctions de validation pour les routes liées à la documentation Swagger
 * 
 * Note: Les routes Swagger actuelles ne nécessitent pas de validation d'entrée utilisateur,
 * mais ce fichier est créé pour maintenir la cohérence avec le reste de l'application
 * et pour préparer d'éventuelles validations futures.
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  swaggerFilterSchema,
  SwaggerFilterData
} from './schemas/swaggerSchemas';

/**
 * Valide les données de filtrage Swagger
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSwaggerFilter(data: unknown): SwaggerFilterData {
  try {
    logger.debug('Validation des données de filtrage Swagger', 'swaggerValidation');
    return swaggerFilterSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de filtrage Swagger: ${error.message}`, 'swaggerValidation', { issues: error.errors });
    throw error;
  }
} 