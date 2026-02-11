/**
 * @file connectorValidation.ts
 * @description Fonctions de validation pour les routes de connecteurs
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  createConnectorSchema,
  updateConnectorSchema,
  testPasswordlessConnectorSchema,
  getAuthorizationUriSchema
} from './schemas/connectorSchemas';

/**
 * Valide les données de création d'un connecteur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateCreateConnector(data: unknown) {
  try {
    logger.debug('Validation des données de création d\'un connecteur', 'connectorValidation');
    return createConnectorSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de création de connecteur: ${error.message}`, 'connectorValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de mise à jour d'un connecteur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateUpdateConnector(data: unknown) {
  try {
    logger.debug('Validation des données de mise à jour d\'un connecteur', 'connectorValidation');
    return updateConnectorSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de mise à jour de connecteur: ${error.message}`, 'connectorValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de test d'un connecteur sans mot de passe
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateTestPasswordlessConnector(data: unknown) {
  try {
    logger.debug('Validation des données de test d\'un connecteur sans mot de passe', 'connectorValidation');
    return testPasswordlessConnectorSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de test de connecteur sans mot de passe: ${error.message}`, 'connectorValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de récupération de l'URI d'autorisation d'un connecteur
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateGetAuthorizationUri(data: unknown) {
  try {
    logger.debug('Validation des données de récupération d\'URI d\'autorisation', 'connectorValidation');
    return getAuthorizationUriSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de récupération d'URI d'autorisation: ${error.message}`, 'connectorValidation', { issues: error.errors });
    throw error;
  }
} 