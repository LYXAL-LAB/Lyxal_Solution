/**
 * @file interactionSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux interactions
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la mise à jour des identifiants
 * @typedef {Object} UpdateIdentifiersData
 */
export const updateIdentifiersSchema = z.object({
  username: z.string().optional().transform(val => val || undefined),
  email: z.string().email("Le format de l'email est invalide").optional().transform(val => val || undefined),
  phone: z.string().optional().transform(val => val || undefined),
  connectorId: z.string().optional().transform(val => val || undefined),
  code: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données d'identifiants sont requises",
  invalid_type_error: "Format de données d'identifiants invalide"
}).refine(
  data => data.username !== undefined || data.email !== undefined || data.phone !== undefined || (data.connectorId !== undefined && data.code !== undefined),
  {
    message: "Au moins un identifiant (username, email, phone) ou (connectorId et code) est requis"
  }
);

/**
 * Type inféré pour la mise à jour des identifiants
 */
export type UpdateIdentifiersData = z.infer<typeof updateIdentifiersSchema>;

/**
 * Schéma de validation pour la mise à jour du profil
 * @typedef {Object} UpdateProfileData
 */
export const updateProfileSchema = z.object({
  username: z.string().optional().transform(val => val || undefined),
  primaryEmail: z.string().email("Le format de l'email est invalide").optional().transform(val => val || undefined),
  primaryPhone: z.string().optional().transform(val => val || undefined),
  name: z.string().optional().transform(val => val || undefined),
  avatar: z.string().url("L'URL de l'avatar est invalide").optional().transform(val => val || undefined),
  customData: z.record(z.unknown()).optional()
}, {
  required_error: "Les données de profil sont requises",
  invalid_type_error: "Format de données de profil invalide"
});

/**
 * Type inféré pour la mise à jour du profil
 */
export type UpdateProfileData = z.infer<typeof updateProfileSchema>;

/**
 * Schéma de validation pour la mise à jour partielle du profil
 * @typedef {Object} PatchProfileData
 */
export const patchProfileSchema = updateProfileSchema;

/**
 * Type inféré pour la mise à jour partielle du profil
 */
export type PatchProfileData = z.infer<typeof patchProfileSchema>;

/**
 * Schéma de validation pour le consentement
 * @typedef {Object} ConsentData
 */
export const consentSchema = z.object({
  consent: z.boolean({
    required_error: "La décision de consentement est requise",
    invalid_type_error: "La décision de consentement doit être un booléen"
  })
}, {
  required_error: "Les données de consentement sont requises",
  invalid_type_error: "Format de données de consentement invalide"
});

/**
 * Type inféré pour le consentement
 */
export type ConsentData = z.infer<typeof consentSchema>;

/**
 * Schéma de validation pour l'autorisation sociale
 * @typedef {Object} SocialAuthorizationUriData
 */
export const socialAuthorizationUriSchema = z.object({
  connectorId: z.string().min(1, "L'identifiant du connecteur est requis"),
  state: z.string().optional().transform(val => val || undefined),
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide")
}, {
  required_error: "Les données d'autorisation sociale sont requises",
  invalid_type_error: "Format de données d'autorisation sociale invalide"
});

/**
 * Type inféré pour l'autorisation sociale
 */
export type SocialAuthorizationUriData = z.infer<typeof socialAuthorizationUriSchema>;

/**
 * Schéma de validation pour la mise à jour MFA
 * @typedef {Object} UpdateMfaData
 */
export const updateMfaSchema = z.object({
  enabled: z.boolean({
    required_error: "Le statut d'activation MFA est requis",
    invalid_type_error: "Le statut d'activation MFA doit être un booléen"
  })
}, {
  required_error: "Les données de mise à jour MFA sont requises",
  invalid_type_error: "Format de données de mise à jour MFA invalide"
});

/**
 * Type inféré pour la mise à jour MFA
 */
export type UpdateMfaData = z.infer<typeof updateMfaSchema>;

/**
 * Schéma de validation pour l'URL d'autorisation SSO
 * @typedef {Object} SingleSignOnAuthorizationUrlData
 */
export const singleSignOnAuthorizationUrlSchema = z.object({
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide")
}, {
  required_error: "Les données d'URL d'autorisation SSO sont requises",
  invalid_type_error: "Format de données d'URL d'autorisation SSO invalide"
});

/**
 * Type inféré pour l'URL d'autorisation SSO
 */
export type SingleSignOnAuthorizationUrlData = z.infer<typeof singleSignOnAuthorizationUrlSchema>;

/**
 * Schéma de validation pour l'authentification SSO
 * @typedef {Object} SingleSignOnAuthenticationData
 */
export const singleSignOnAuthenticationSchema = z.object({
  data: z.record(z.unknown(), {
    required_error: "Les données d'authentification sont requises",
    invalid_type_error: "Format de données d'authentification invalide"
  })
}, {
  required_error: "Les données d'authentification SSO sont requises",
  invalid_type_error: "Format de données d'authentification SSO invalide"
});

/**
 * Type inféré pour l'authentification SSO
 */
export type SingleSignOnAuthenticationData = z.infer<typeof singleSignOnAuthenticationSchema>;

/**
 * Schéma de validation pour l'enregistrement SSO
 * @typedef {Object} SingleSignOnRegistrationData
 */
export const singleSignOnRegistrationSchema = z.object({
  data: z.record(z.unknown(), {
    required_error: "Les données d'enregistrement sont requises",
    invalid_type_error: "Format de données d'enregistrement invalide"
  })
}, {
  required_error: "Les données d'enregistrement SSO sont requises",
  invalid_type_error: "Format de données d'enregistrement SSO invalide"
});

/**
 * Type inféré pour l'enregistrement SSO
 */
export type SingleSignOnRegistrationData = z.infer<typeof singleSignOnRegistrationSchema>;
