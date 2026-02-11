/**
 * @file authnSchemas.ts
 * @description Schémas de validation Zod pour les routes d'authentification externe (Hasura, SAML)
 */

import { z } from 'zod';

/**
 * Schéma pour la validation des paramètres d'authentification Hasura
 * @description Valide les paramètres de requête pour l'endpoint d'authentification Hasura
 * @property {string} [role] - Rôle demandé pour l'authentification (optionnel)
 */
export const hasuraAuthQuerySchema = z.object({
  role: z.string().optional().describe("Rôle demandé")
});

/**
 * Type inféré du schéma d'authentification Hasura
 */
export type HasuraAuthQuery = z.infer<typeof hasuraAuthQuerySchema>;

/**
 * Schéma pour la validation des données SAML ACS
 * @description Valide les données de réponse SAML envoyées par un fournisseur d'identité
 * @property {string} [RelayState] - État de relais SAML (optionnel)
 * @property {string} SAMLResponse - Réponse SAML encodée (requise)
 */
export const samlAcsBodySchema = z.object({
  RelayState: z.string().optional().describe("État de relais SAML"),
  SAMLResponse: z.string().min(1, 'La réponse SAML est requise').describe("Réponse SAML")
});

/**
 * Type inféré du schéma SAML ACS
 */
export type SamlAcsBody = z.infer<typeof samlAcsBodySchema>; 