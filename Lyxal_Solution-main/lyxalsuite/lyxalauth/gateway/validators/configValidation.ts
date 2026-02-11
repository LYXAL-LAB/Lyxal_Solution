/**
 * @file configValidation.ts
 * @description Fonctions de validation pour les routes de configuration
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  updateAdminConsoleConfigSchema,
  upsertJwtCustomizerSchema,
  patchJwtCustomizerSchema,
  testJwtCustomizerSchema
} from './schemas/configSchemas';

/**
 * Valide les données de mise à jour de la configuration de la console d'administration
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateAdminConsoleConfig(data: unknown) {
  try {
    logger.debug('Validation des données de mise à jour de la configuration admin', 'configValidation');
    return updateAdminConsoleConfigSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de la configuration admin: ${error.message}`, 'configValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création/mise à jour d'un personnalisateur JWT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpsertJwtCustomizer(data: unknown) {
  try {
    logger.debug('Validation des données de création/mise à jour du personnalisateur JWT', 'configValidation');
    return upsertJwtCustomizerSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation d'upsert JWT customizer: ${error.message}`, 'configValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour partielle d'un personnalisateur JWT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validatePatchJwtCustomizer(data: unknown) {
  try {
    logger.debug('Validation des données de mise à jour partielle du personnalisateur JWT', 'configValidation');
    return patchJwtCustomizerSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de patch JWT customizer: ${error.message}`, 'configValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de test d'un personnalisateur JWT
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateTestJwtCustomizer(data: unknown) {
  try {
    logger.debug('Validation des données de test du personnalisateur JWT', 'configValidation');
    return testJwtCustomizerSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de test JWT customizer: ${error.message}`, 'configValidation', { issues: error.errors });
    throw error;
  }
} 