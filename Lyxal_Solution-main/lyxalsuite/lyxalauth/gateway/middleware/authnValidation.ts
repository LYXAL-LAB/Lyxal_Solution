import { z } from 'zod';

/**
 * Schéma pour les paramètres de la requête Hasura auth hook
 */
export const hasuraAuthQuerySchema = z.object({
  role: z.string().optional(),
});

/**
 * Schéma pour les paramètres de la requête SAML ACS (social et SSO)
 */
export const samlAcsSchema = z.object({
  RelayState: z.string().optional(),
  SAMLResponse: z.string(),
});

/**
 * Fonction de validation pour les paramètres de la requête Hasura auth hook
 */
export function validateHasuraAuthQuery(input: unknown) {
  return hasuraAuthQuerySchema.parse(input);
}

/**
 * Fonction de validation pour les paramètres de la requête SAML ACS (social et SSO)
 */
export function validateSamlAcsBody(input: unknown) {
  return samlAcsSchema.parse(input);
} 
