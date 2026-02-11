/**
 * @file systemAppConfigValidation.ts
 * @description Fonctions de validation pour les routes liées aux configurations d'application système
 * 
 * Note: Les routes systemAppConfig actuelles ne nécessitent pas de validation d'entrée utilisateur,
 * mais ce fichier est créé pour maintenir la cohérence avec le reste de l'application
 * et pour préparer d'éventuelles validations futures.
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  systemAppConfigSchema,
  SystemAppConfigData
} from './schemas/systemAppConfigSchemas';

/**
 * Valide les données de configuration système
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSystemAppConfig(data: unknown): SystemAppConfigData {
  try {
    logger.debug('Validation des données de configuration système', 'systemAppConfigValidation');
    return systemAppConfigSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de configuration système: ${error.message}`, 'systemAppConfigValidation', { issues: error.errors });
    throw error;
  }
} 