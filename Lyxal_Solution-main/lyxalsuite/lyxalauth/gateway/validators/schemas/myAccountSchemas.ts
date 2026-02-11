/**
 * @file myAccountSchemas.ts
 * @description Schémas de validation Zod pour les routes liées à la gestion du compte utilisateur
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la mise à jour du profil
 * @typedef {Object} UpdateProfileData
 */
export const updateProfileSchema = z.object({
  name: z.string().optional().transform(val => val || undefined),
  avatar: z.string().url("L'URL de l'avatar doit être une URL valide").optional().transform(val => val || undefined),
  customData: z.record(z.unknown()).optional()
});

/**
 * Type inféré pour la mise à jour du profil
 */
export type UpdateProfileData = z.infer<typeof updateProfileSchema>;

/**
 * Schéma de validation pour la mise à jour d'un autre profil
 * @typedef {Object} UpdateOtherProfileData
 */
export const updateOtherProfileSchema = updateProfileSchema.extend({
  userId: z.string().min(1, "L'identifiant de l'utilisateur est requis")
});

/**
 * Type inféré pour la mise à jour d'un autre profil
 */
export type UpdateOtherProfileData = z.infer<typeof updateOtherProfileSchema>;

/**
 * Schéma de validation pour la mise à jour du mot de passe
 * @typedef {Object} UpdatePasswordData
 */
export const updatePasswordSchema = z.object({
  oldPassword: z.string().min(1, "L'ancien mot de passe est requis"),
  newPassword: z.string().min(8, "Le nouveau mot de passe doit contenir au moins 8 caractères")
});

/**
 * Type inféré pour la mise à jour du mot de passe
 */
export type UpdatePasswordData = z.infer<typeof updatePasswordSchema>;

/**
 * Schéma de validation pour la mise à jour de l'email primaire
 * @typedef {Object} UpdatePrimaryEmailData
 */
export const updatePrimaryEmailSchema = z.object({
  email: z.string().email("Le format de l'email est invalide"),
  verificationCode: z.string().min(1, "Le code de vérification est requis")
});

/**
 * Type inféré pour la mise à jour de l'email primaire
 */
export type UpdatePrimaryEmailData = z.infer<typeof updatePrimaryEmailSchema>;

/**
 * Schéma de validation pour la mise à jour du téléphone primaire
 * @typedef {Object} UpdatePrimaryPhoneData
 */
export const updatePrimaryPhoneSchema = z.object({
  phone: z.string().min(1, "Le numéro de téléphone est requis"),
  verificationCode: z.string().min(1, "Le code de vérification est requis")
});

/**
 * Type inféré pour la mise à jour du téléphone primaire
 */
export type UpdatePrimaryPhoneData = z.infer<typeof updatePrimaryPhoneSchema>;

/**
 * Schéma de validation pour l'ajout d'une identité utilisateur
 * @typedef {Object} AddUserIdentityData
 */
export const addUserIdentitySchema = z.object({
  target: z.string().min(1, "La cible est requise"),
  connectorId: z.string().min(1, "L'identifiant du connecteur est requis")
});

/**
 * Type inféré pour l'ajout d'une identité utilisateur
 */
export type AddUserIdentityData = z.infer<typeof addUserIdentitySchema>;

/**
 * Schéma de validation pour la suppression d'une identité utilisateur
 * @typedef {Object} DeleteUserIdentityData
 */
export const deleteUserIdentitySchema = z.object({
  target: z.string().min(1, "La cible est requise"),
  connectorId: z.string().min(1, "L'identifiant du connecteur est requis")
});

/**
 * Type inféré pour la suppression d'une identité utilisateur
 */
export type DeleteUserIdentityData = z.infer<typeof deleteUserIdentitySchema>; 
