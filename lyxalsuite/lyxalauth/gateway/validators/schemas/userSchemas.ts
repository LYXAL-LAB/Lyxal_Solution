/**
 * @file userSchemas.ts
 * @description Schémas de validation Zod pour les routes utilisateurs
 */

import { z } from 'zod';

/**
 * Schéma de base pour les données utilisateur
 */
const userBaseSchema = {
  username: z.string().optional().describe("Nom d'utilisateur"),
  name: z.string().optional().describe("Nom complet de l'utilisateur"),
  primaryEmail: z.string().email({ message: "Format d'email invalide" }).optional().describe("Email principal de l'utilisateur"),
  primaryPhone: z.string().optional().describe("Numéro de téléphone principal de l'utilisateur"),
  customData: z.record(z.unknown()).optional().describe("Données personnalisées de l'utilisateur")
};

/**
 * Schéma pour la création d'un utilisateur
 * @typedef {z.infer<typeof createUserSchema>} CreateUserInput
 */
export const createUserSchema = z.object({
  ...userBaseSchema,
  username: z.string().min(3, { message: "Le nom d'utilisateur doit comporter au moins 3 caractères" }).describe("Nom d'utilisateur (minimum 3 caractères)"),
  password: z.string().min(8, { message: "Le mot de passe doit comporter au moins 8 caractères" }).optional().describe("Mot de passe (minimum 8 caractères)")
});

/**
 * Schéma pour la mise à jour d'un utilisateur
 * @typedef {z.infer<typeof updateUserSchema>} UpdateUserInput
 */
export const updateUserSchema = z.object({
  ...userBaseSchema
});

/**
 * Schéma pour la mise à jour du mot de passe
 * @typedef {z.infer<typeof updatePasswordSchema>} UpdatePasswordInput
 */
export const updatePasswordSchema = z.object({
  currentPassword: z.string().min(1, { message: "Le mot de passe actuel est requis" }).describe("Mot de passe actuel"),
  newPassword: z.string().min(8, { message: "Le mot de passe doit comporter au moins 8 caractères" })
    .regex(/[A-Z]/, { message: "Le mot de passe doit contenir au moins une majuscule" })
    .regex(/[a-z]/, { message: "Le mot de passe doit contenir au moins une minuscule" })
    .regex(/[0-9]/, { message: "Le mot de passe doit contenir au moins un chiffre" })
    .regex(/[^A-Za-z0-9]/, { message: "Le mot de passe doit contenir au moins un caractère spécial" })
    .describe("Nouveau mot de passe (doit respecter les critères de complexité)")
});

/**
 * Schéma pour la vérification de mot de passe
 * @typedef {z.infer<typeof verifyPasswordSchema>} VerifyPasswordInput
 */
export const verifyPasswordSchema = z.object({
  password: z.string().min(1, { message: "Le mot de passe est requis" }).describe("Mot de passe à vérifier")
});

/**
 * Schéma pour la mise à jour du statut de suspension
 * @typedef {z.infer<typeof updateSuspensionSchema>} UpdateSuspensionInput
 */
export const updateSuspensionSchema = z.object({
  isSuspended: z.boolean().describe("Indique si l'utilisateur est suspendu")
});

/**
 * Schéma pour l'attribution de rôles
 * @typedef {z.infer<typeof assignRolesSchema>} AssignRolesInput
 */
export const assignRolesSchema = z.object({
  roleIds: z.array(z.string().describe("ID du rôle")).describe("Liste des IDs des rôles à attribuer")
});

/**
 * Schéma pour la mise à jour des données personnalisées
 * @typedef {z.infer<typeof updateCustomDataSchema>} UpdateCustomDataInput
 */
export const updateCustomDataSchema = z.object({
  customData: z.record(z.unknown()).describe("Données personnalisées à mettre à jour")
});

/**
 * Schéma pour l'ajout d'un token d'accès personnel
 * @typedef {z.infer<typeof addPersonalAccessTokenSchema>} AddPersonalAccessTokenInput
 */
export const addPersonalAccessTokenSchema = z.object({
  name: z.string().min(1, { message: "Le nom du token est requis" }).describe("Nom du token d'accès personnel"),
  expiresInDays: z.number().int().positive().optional().describe("Nombre de jours avant l'expiration du token")
});

/**
 * Schéma pour la mise à jour d'un token d'accès personnel
 * @typedef {z.infer<typeof updatePersonalAccessTokenSchema>} UpdatePersonalAccessTokenInput
 */
export const updatePersonalAccessTokenSchema = z.object({
  name: z.string().min(1, { message: "Le nom du token est requis" }).describe("Nouveau nom du token d'accès personnel")
});

/**
 * Schéma pour la liaison d'une identité sociale
 * @typedef {z.infer<typeof linkSocialIdentitySchema>} LinkSocialIdentityInput
 */
export const linkSocialIdentitySchema = z.object({
  provider: z.string().min(1, { message: "Le fournisseur est requis" }).describe("Fournisseur d'identité sociale"),
  userId: z.string().min(1, { message: "L'ID utilisateur est requis" }).describe("ID utilisateur chez le fournisseur d'identité sociale")
});

/**
 * Schéma pour les paramètres de pagination
 * @typedef {z.infer<typeof paginationSchema>} PaginationInput
 */
export const paginationSchema = z.object({
  page: z.string().optional().transform(val => parseInt(val || '1') || 1).describe("Numéro de page"),
  page_size: z.string().optional().transform(val => parseInt(val || '20') || 20).describe("Nombre d'éléments par page")
});

/**
 * Schéma pour la création de vérification MFA
 * @typedef {z.infer<typeof createMfaVerificationSchema>} CreateMfaVerificationInput
 */
export const createMfaVerificationSchema = z.object({
  type: z.enum(['Totp', 'WebAuthn', 'BackupCode'], { 
    errorMap: () => ({ message: "Le type doit être 'Totp', 'WebAuthn' ou 'BackupCode'" })
  }).describe("Type de vérification MFA"),
  code: z.string().optional().describe("Code de vérification (pour Totp)"),
  credential: z.record(z.unknown()).optional().describe("Informations d'identification (pour WebAuthn)")
});

// Export des types inférés
export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type VerifyPasswordInput = z.infer<typeof verifyPasswordSchema>;
export type UpdateSuspensionInput = z.infer<typeof updateSuspensionSchema>;
export type AssignRolesInput = z.infer<typeof assignRolesSchema>;
export type UpdateCustomDataInput = z.infer<typeof updateCustomDataSchema>;
export type AddPersonalAccessTokenInput = z.infer<typeof addPersonalAccessTokenSchema>;
export type UpdatePersonalAccessTokenInput = z.infer<typeof updatePersonalAccessTokenSchema>;
export type LinkSocialIdentityInput = z.infer<typeof linkSocialIdentitySchema>;
export type CreateMfaVerificationInput = z.infer<typeof createMfaVerificationSchema>; 

