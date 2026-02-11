/**
 * @file authnValidation.ts
 * @description Fonctions de validation pour les routes d'authentification externe (Hasura, SAML)
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  hasuraAuthQuerySchema, HasuraAuthQuery,
  samlAcsBodySchema, SamlAcsBody
} from './schemas/authnSchemas';

/**
 * Valide les paramètres de requête pour l'authentification Hasura
 * @param params Les paramètres de requête à valider
 * @returns Les paramètres validés ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateHasuraAuthQuery = (params: any): HasuraAuthQuery => {
  try {
    logger.debug('Validation des paramètres de requête Hasura', 'authnValidation');
    return hasuraAuthQuerySchema.parse(params);
  } catch (error: any) {
    logger.error(`Erreur de validation des paramètres Hasura: ${error.message}`, 'authnValidation', { issues: error.errors });
    throw error;
  }
};

/**
 * Valide les données SAML ACS
 * @param data Les données SAML à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export const validateSamlAcsBody = (data: any): SamlAcsBody => {
  try {
    logger.debug('Validation des données SAML ACS', 'authnValidation');
    return samlAcsBodySchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation des données SAML: ${error.message}`, 'authnValidation', { issues: error.errors });
    throw error;
  }
}; 