/**
 * @file dashboardValidation.ts
 * @description Fonctions de validation pour les routes du tableau de bord
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { userStatsQuerySchema, UserStatsQuery } from './schemas/dashboardSchemas';

/**
 * Valide les paramètres de requête pour les statistiques d'utilisateurs
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUserStatsQuery(data: unknown): UserStatsQuery {
  try {
    logger.debug('Validation des paramètres de statistiques d\'utilisateurs', 'dashboardValidation');
    return userStatsQuerySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des paramètres de statistiques: ${error.message}`, 'dashboardValidation', { issues: error.errors });
    throw error;
  }
}