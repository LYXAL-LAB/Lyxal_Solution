/**
 * @file samlAuthSchemas.ts
 * @description Schémas de validation Zod pour les routes liées à l'authentification SAML
 */

import { z } from 'zod';

/**
 * Schéma de validation pour les requêtes d'authentification SAML via Redirect binding (GET)
 * @typedef {Object} SamlAuthRedirectData
 */
export const samlAuthRedirectSchema = z.object({
  SAMLRequest: z.string().min(1, "La requête SAML est requise"),
  RelayState: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données de la requête SAML Redirect sont requises",
  invalid_type_error: "Format de données de requête SAML Redirect invalide"
});

/**
 * Schéma de validation pour les requêtes d'authentification SAML via POST binding (POST)
 * @typedef {Object} SamlAuthPostData
 */
export const samlAuthPostSchema = z.object({
  SAMLRequest: z.string().min(1, "La requête SAML est requise"),
  RelayState: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données de la requête SAML POST sont requises",
  invalid_type_error: "Format de données de requête SAML POST invalide"
});

/**
 * Type inféré pour les requêtes d'authentification SAML via Redirect binding
 */
export type SamlAuthRedirectData = z.infer<typeof samlAuthRedirectSchema>;

/**
 * Type inféré pour les requêtes d'authentification SAML via POST binding
 */
export type SamlAuthPostData = z.infer<typeof samlAuthPostSchema>;