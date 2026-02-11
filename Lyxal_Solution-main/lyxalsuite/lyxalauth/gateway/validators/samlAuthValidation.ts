 /**
 * @file samlAuthValidation.ts
 * @description Fonctions de validation pour les routes liées à l'authentification SAML
 */

import { structuredLogger as logger } from '../core/logger/structuredLogger';
import {
  samlAuthRedirectSchema,
  samlAuthPostSchema,
  SamlAuthRedirectData,
  SamlAuthPostData
} from './schemas/samlAuthSchemas';

/**
 * Valide les données de requête d'authentification SAML via Redirect binding (GET)
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSamlAuthRedirect(data: unknown): SamlAuthRedirectData {
  try {
    logger.debug('Validation des données de requête SAML Redirect', 'samlAuthValidation');
    return samlAuthRedirectSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de requête SAML Redirect: ${error.message}`, 'samlAuthValidation', { issues: error.errors });
    throw error;
  }
}

/**
 * Valide les données de requête d'authentification SAML via POST binding (POST)
 * @param data Les données à valider
 * @returns Les données validées ou lance une erreur
 * @throws {import('zod').ZodError} Si les données ne sont pas valides
 */
export function validateSamlAuthPost(data: unknown): SamlAuthPostData {
  try {
    logger.debug('Validation des données de requête SAML POST', 'samlAuthValidation');
    return samlAuthPostSchema.parse(data);
  } catch (error: any) {
    logger.error(`Erreur de validation de requête SAML POST: ${error.message}`, 'samlAuthValidation', { issues: error.errors });
    throw error;
  }
}