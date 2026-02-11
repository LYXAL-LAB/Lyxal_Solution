/**
 * @file hookValidation.ts
 * @description Fonctions de validation pour les routes liées aux webhooks
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  webhookConfigSchema,
  createHookSchema,
  updateHookSchema,
  updateSigningKeySchema,
  WebhookConfigData,
  CreateHookData,
  UpdateHookData,
  UpdateSigningKeyData
} from './schemas/hookSchemas';

/**
 * Valide les données de configuration d'un webhook
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateWebhookConfig(data: unknown): WebhookConfigData {
  try {
    logger.debug('Validation des données de configuration d\'un webhook', 'hookValidation');
    return webhookConfigSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de configuration d'un webhook: ${error.message}`, 'hookValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de création d'un webhook
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateHook(data: unknown): CreateHookData {
  try {
    logger.debug('Validation des données de création d\'un webhook', 'hookValidation');
    return createHookSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création d'un webhook: ${error.message}`, 'hookValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un webhook
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateHook(data: unknown): UpdateHookData {
  try {
    logger.debug('Validation des données de mise à jour d\'un webhook', 'hookValidation');
    return updateHookSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour d'un webhook: ${error.message}`, 'hookValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour de la clé de signature d'un webhook
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateSigningKey(data: unknown): UpdateSigningKeyData {
  try {
    logger.debug('Validation des données de mise à jour de la clé de signature d\'un webhook', 'hookValidation');
    return updateSigningKeySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de la clé de signature d'un webhook: ${error.message}`, 'hookValidation', { issues: error.errors });
    throw error;
  }
}