/**
 * @file phraseValidation.ts
 * @description Fonctions de validation pour les routes de phrases personnalisées
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  upsertCustomPhraseSchema,
  upsertCustomPhraseWithLanguageSchema
} from './schemas/phraseSchemas';

/**
 * Valide les données de mise à jour des phrases personnalisées (sans languageTag)
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpsertCustomPhrase(data: unknown) {
  try {
    logger.debug('Validation des données de mise à jour des phrases personnalisées', 'phraseValidation');
    return upsertCustomPhraseSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des phrases personnalisées: ${error.message}`, 'phraseValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données complètes de mise à jour des phrases personnalisées (avec languageTag)
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpsertCustomPhraseWithLanguage(data: unknown) {
  try {
    logger.debug('Validation des données complètes de mise à jour des phrases personnalisées', 'phraseValidation');
    return upsertCustomPhraseWithLanguageSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des phrases personnalisées avec langue: ${error.message}`, 'phraseValidation', { issues: error.errors });
    throw error;
  }
} 