/**
 * @file samlApplicationsSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux applications SAML
 */

import { z } from 'zod';

/**
 * Schéma de validation pour le certificat d'une application SAML
 * @typedef {Object} SamlCertificateData
 */
export const certificateSchema = z.object({
  publicKey: z.string().optional().transform(val => val || undefined),
  privateKey: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données du certificat sont requises",
  invalid_type_error: "Format de données de certificat invalide"
});

/**
 * Schéma de validation pour la création d'une application SAML
 * @typedef {Object} CreateSamlApplicationData
 */
export const createSamlApplicationSchema = z.object({
  name: z.string().min(1, "Le nom de l'application est requis"),
  description: z.string().optional().transform(val => val || undefined),
  acs: z.string().url("L'URL ACS doit être une URL valide"),
  entityId: z.string().min(1, "L'identifiant d'entité est requis"),
  notBeforeMinutes: z.number().int().nonnegative("La durée de validité avant ne peut pas être négative").optional(),
  expiresMinutes: z.number().int().positive("La durée d'expiration doit être positive").optional(),
  certificate: certificateSchema.optional()
}, {
  required_error: "Les données de l'application SAML sont requises",
  invalid_type_error: "Format de données d'application SAML invalide"
});

/**
 * Schéma de validation pour la mise à jour d'une application SAML
 * @typedef {Object} UpdateSamlApplicationData
 */
export const updateSamlApplicationSchema = z.object({
  name: z.string().min(1, "Le nom de l'application est requis").optional(),
  description: z.string().optional().transform(val => val || undefined),
  acs: z.string().url("L'URL ACS doit être une URL valide").optional(),
  entityId: z.string().min(1, "L'identifiant d'entité est requis").optional(),
  notBeforeMinutes: z.number().int().nonnegative("La durée de validité avant ne peut pas être négative").optional(),
  expiresMinutes: z.number().int().positive("La durée d'expiration doit être positive").optional(),
  certificate: certificateSchema.optional()
}, {
  required_error: "Les données de mise à jour de l'application SAML sont requises",
  invalid_type_error: "Format de données de mise à jour d'application SAML invalide"
});

/**
 * Schéma de validation pour la création d'un secret d'application SAML
 * @typedef {Object} CreateSamlApplicationSecretData
 */
export const createSamlApplicationSecretSchema = z.object({
  name: z.string().min(1, "Le nom du secret est requis"),
  expiresAt: z.string().optional().transform(val => val || undefined) // ISO 8601 date format
}, {
  required_error: "Les données du secret SAML sont requises",
  invalid_type_error: "Format de données de secret SAML invalide"
});

/**
 * Schéma de validation pour la mise à jour d'un secret d'application SAML
 * @typedef {Object} UpdateSamlApplicationSecretData
 */
export const updateSamlApplicationSecretSchema = z.object({
  name: z.string().min(1, "Le nom du secret est requis").optional(),
  expiresAt: z.string().optional().transform(val => val || undefined) // ISO 8601 date format
}, {
  required_error: "Les données de mise à jour du secret SAML sont requises",
  invalid_type_error: "Format de données de mise à jour de secret SAML invalide"
});

/**
 * Type inféré pour le certificat d'une application SAML
 */
export type SamlCertificateData = z.infer<typeof certificateSchema>;

/**
 * Type inféré pour la création d'une application SAML
 */
export type CreateSamlApplicationData = z.infer<typeof createSamlApplicationSchema>;

/**
 * Type inféré pour la mise à jour d'une application SAML
 */
export type UpdateSamlApplicationData = z.infer<typeof updateSamlApplicationSchema>;

/**
 * Type inféré pour la création d'un secret d'application SAML
 */
export type CreateSamlApplicationSecretData = z.infer<typeof createSamlApplicationSecretSchema>;

/**
 * Type inféré pour la mise à jour d'un secret d'application SAML
 */
export type UpdateSamlApplicationSecretData = z.infer<typeof updateSamlApplicationSecretSchema>;