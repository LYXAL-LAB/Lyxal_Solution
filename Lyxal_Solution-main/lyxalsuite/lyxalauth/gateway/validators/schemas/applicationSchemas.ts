/**
 * @file applicationSchemas.ts
 * @description Schémas Zod pour la validation des requêtes liées aux applications
 */

import { z } from 'zod';

/**
 * Schéma pour la création d'une nouvelle application
 */
export const createApplicationSchema = z.object({
  name: z.string().min(1, { message: "Le nom de l'application est requis" }),
  description: z.string().optional(),
  type: z.enum(['native', 'spa', 'traditional', 'machine_to_machine', 'web'], { 
    errorMap: () => ({ message: "Le type d'application doit être 'native', 'spa', 'traditional', 'machine_to_machine' ou 'web'" }) 
  }),
  redirectUris: z.array(z.string().url({ message: "L'URI de redirection doit être une URL valide" }))
    .optional(),
  postLogoutRedirectUris: z.array(z.string().url({ message: "L'URI de redirection après déconnexion doit être une URL valide" }))
    .optional(),
  allowedOrigins: z.array(z.string())
    .optional(),
  logoUri: z.string().url({ message: "L'URI du logo doit être une URL valide" }).optional(),
  customData: z.record(z.any()).optional(),
});

/**
 * Type pour les données de création d'application
 */
export type CreateApplicationData = z.infer<typeof createApplicationSchema>;

/**
 * Schéma pour la mise à jour d'une application existante
 */
export const updateApplicationSchema = z.object({
  name: z.string().min(1, { message: "Le nom de l'application est requis" }).optional(),
  description: z.string().optional(),
  redirectUris: z.array(z.string().url({ message: "L'URI de redirection doit être une URL valide" }))
    .optional(),
  postLogoutRedirectUris: z.array(z.string().url({ message: "L'URI de redirection après déconnexion doit être une URL valide" }))
    .optional(),
  allowedOrigins: z.array(z.string())
    .optional(),
  logoUri: z.string().url({ message: "L'URI du logo doit être une URL valide" }).optional(),
  isActive: z.boolean().optional(),
});

/**
 * Type pour les données de mise à jour d'application
 */
export type UpdateApplicationData = z.infer<typeof updateApplicationSchema>;

/**
 * Schéma pour la mise à jour des données personnalisées d'une application
 */
export const updateAppCustomDataSchema = z.object({
  customData: z.record(z.any()),
});

/**
 * Type pour les données personnalisées d'application
 */
export type UpdateAppCustomDataData = z.infer<typeof updateAppCustomDataSchema>;

/**
 * Schéma pour l'attribution de rôles de ressources API
 */
export const assignApiResourceRolesSchema = z.object({
  resourceIds: z.array(z.string().uuid({ message: "L'identifiant de ressource doit être un UUID valide" })),
  roleIds: z.array(z.string().uuid({ message: "L'identifiant de rôle doit être un UUID valide" })),
});

/**
 * Type pour les données d'attribution de rôles de ressources API
 */
export type AssignApiResourceRolesData = z.infer<typeof assignApiResourceRolesSchema>;

/**
 * Schéma pour l'ajout d'un domaine personnalisé
 */
export const addCustomDomainSchema = z.object({
  domain: z.string().regex(/^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$/, { 
    message: "Le domaine doit être un nom de domaine valide" 
  }),
});

/**
 * Type pour les données d'ajout de domaine personnalisé
 */
export type AddCustomDomainData = z.infer<typeof addCustomDomainSchema>;

/**
 * Schéma pour l'ajout d'un secret d'application
 */
export const addApplicationSecretSchema = z.object({
  name: z.string().min(1, { message: "Le nom du secret est requis" }),
  expiresAt: z.string().datetime({ message: "La date d'expiration doit être au format ISO 8601" }).optional(),
});

/**
 * Type pour les données d'ajout de secret d'application
 */
export type AddApplicationSecretData = z.infer<typeof addApplicationSecretSchema>;

/**
 * Schéma pour la mise à jour d'un secret d'application
 */
export const updateApplicationSecretSchema = z.object({
  name: z.string().min(1, { message: "Le nom du secret est requis" }).optional(),
  isActive: z.boolean().optional(),
  expiresAt: z.string().datetime({ message: "La date d'expiration doit être au format ISO 8601" }).optional(),
});

/**
 * Type pour les données de mise à jour de secret d'application
 */
export type UpdateApplicationSecretData = z.infer<typeof updateApplicationSecretSchema>;

/**
 * Schéma pour l'attribution de scopes de consentement utilisateur
 */
export const assignUserConsentScopesSchema = z.object({
  scopes: z.array(z.string().min(1, { message: "Le scope ne peut pas être vide" })),
});

/**
 * Type pour les données d'attribution de scopes de consentement utilisateur
 */
export type AssignUserConsentScopesData = z.infer<typeof assignUserConsentScopesSchema>;

/**
 * Schéma pour la mise à jour de l'expérience de connexion d'une application
 */
export const updateAppSignInExperienceSchema = z.object({
  termsOfUseUrl: z.string().url({ message: "L'URL des conditions d'utilisation doit être valide" }).optional(),
  privacyPolicyUrl: z.string().url({ message: "L'URL de la politique de confidentialité doit être valide" }).optional(),
  customCss: z.string().optional(),
  branding: z.object({
    logoUrl: z.string().url({ message: "L'URL du logo doit être valide" }).optional(),
    primaryColor: z.string().regex(/^#[0-9A-Fa-f]{6}$/, { message: "La couleur primaire doit être au format hexadécimal (ex: #FF0000)" }).optional(),
    darkMode: z.boolean().optional(),
  }).optional(),
});

/**
 * Type pour les données de mise à jour de l'expérience de connexion
 */
export type UpdateAppSignInExperienceData = z.infer<typeof updateAppSignInExperienceSchema>;

/**
 * Schéma pour l'attribution d'accès à une organisation
 */
export const grantOrganizationAccessSchema = z.object({
  organizationIds: z.array(z.string().uuid({ message: "L'identifiant d'organisation doit être un UUID valide" })),
});

/**
 * Type pour les données d'attribution d'accès à une organisation
 */
export type GrantOrganizationAccessData = z.infer<typeof grantOrganizationAccessSchema>; 