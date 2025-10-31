/**
 * @file logValidation.ts
 * @description Fonctions de validation pour les routes liées aux logs
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  getLogsQuerySchema,
  getApplicationLogsQuerySchema,
  getUserLogsQuerySchema,
  GetLogsQueryData,
  GetApplicationLogsQueryData,
  GetUserLogsQueryData
} from './schemas/logSchemas';

/**
 * Valide les paramètres de requête pour récupérer des logs
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateGetLogsQuery(data: unknown): GetLogsQueryData {
  try {
    logger.debug('Validation des paramètres de requête pour récupérer des logs', 'logValidation');
    return getLogsQuerySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des paramètres de requête pour récupérer des logs: ${error.message}`, 'logValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les paramètres de requête pour récupérer des logs d'application
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateGetApplicationLogsQuery(data: unknown): GetApplicationLogsQueryData {
  try {
    logger.debug('Validation des paramètres de requête pour récupérer des logs d\'application', 'logValidation');
    return getApplicationLogsQuerySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des paramètres de requête pour récupérer des logs d'application: ${error.message}`, 'logValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les paramètres de requête pour récupérer des logs d'utilisateur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateGetUserLogsQuery(data: unknown): GetUserLogsQueryData {
  try {
    logger.debug('Validation des paramètres de requête pour récupérer des logs d\'utilisateur', 'logValidation');
    return getUserLogsQuerySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des paramètres de requête pour récupérer des logs d'utilisateur: ${error.message}`, 'logValidation', { issues: error.errors });
    throw error;
  }
}