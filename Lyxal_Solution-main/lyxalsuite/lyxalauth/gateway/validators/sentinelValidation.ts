/**
 * @file sentinelValidation.ts
 * @description Fonctions de validation pour les routes liées à Sentinel
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  bulkDeleteSentinelActivitiesSchema,
  BulkDeleteSentinelActivitiesData
} from './schemas/sentinelSchemas';

/**
 * Valide les données de suppression en masse d'activités Sentinel
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateBulkDeleteSentinelActivities(data: unknown): BulkDeleteSentinelActivitiesData {
  try {
    logger.debug('Validation des données de suppression en masse d\'activités Sentinel', 'sentinelValidation');
    return bulkDeleteSentinelActivitiesSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de suppression en masse: ${error.message}`, 'sentinelValidation', { issues: error.errors });
    throw error;
  }
} 