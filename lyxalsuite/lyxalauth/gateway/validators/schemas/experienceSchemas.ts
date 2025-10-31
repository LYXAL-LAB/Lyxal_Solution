/**
 * @file experienceSchemas.ts
 * @description Schémas de validation Zod pour les routes liées à l'expérience utilisateur
 */

import { z } from 'zod';

/**
 * Schéma de validation pour l'initialisation d'une interaction
 * @typedef {Object} InitInteractionData
 */
export const initInteractionSchema = z.object({
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide"),
  clientId: z.string().optional(),
  state: z.string().optional(),
  scope: z.string().optional(),
  nonce: z.string().optional(),
  responseType: z.string().optional(),
  codeChallenge: z.string().optional(),
  codeChallengeMethod: z.string().optional(),
  maxAge: z.number().optional(),
  responseMode: z.string().optional(),
  idTokenHint: z.string().optional(),
  prompt: z.string().optional(),
  loginHint: z.string().optional(),
  acr: z.string().optional(),
  connector: z.string().optional(),
  authorizationId: z.string().optional()
}, {
  required_error: "Les données d'initialisation d'interaction sont requises",
  invalid_type_error: "Format de données d'initialisation d'interaction invalide"
});

/**
 * Type inféré pour l'initialisation d'une interaction
 */
export type InitInteractionData = z.infer<typeof initInteractionSchema>;

/**
 * Schéma de validation pour la mise à jour d'un événement d'interaction
 * @typedef {Object} UpdateInteractionEventData
 */
export const updateInteractionEventSchema = z.object({
  event: z.string().min(1, "L'événement est requis"),
  params: z.record(z.unknown()).optional()
}, {
  required_error: "Les données d'événement d'interaction sont requises",
  invalid_type_error: "Format de données d'événement d'interaction invalide"
});

/**
 * Type inféré pour la mise à jour d'un événement d'interaction
 */
export type UpdateInteractionEventData = z.infer<typeof updateInteractionEventSchema>;

/**
 * Schéma de validation pour l'identification d'un utilisateur
 * @typedef {Object} IdentifyUserData
 */
export const identifyUserSchema = z.object({
  email: z.string().email("Format d'email invalide").optional(),
  phone: z.string().optional(),
  username: z.string().optional(),
  connectorId: z.string().optional(),
  code: z.string().optional()
}, {
  required_error: "Les données d'identification d'utilisateur sont requises",
  invalid_type_error: "Format de données d'identification d'utilisateur invalide"
}).refine(
  data => data.email !== undefined || data.phone !== undefined || data.username !== undefined || (data.connectorId !== undefined && data.code !== undefined),
  {
    message: "Au moins un des identifiants (email, téléphone, nom d'utilisateur) ou (connectorId et code) est requis"
  }
);

/**
 * Type inféré pour l'identification d'un utilisateur
 */
export type IdentifyUserData = z.infer<typeof identifyUserSchema>;

/**
 * Schéma de validation pour la soumission d'une interaction
 * @typedef {Object} SubmitInteractionData
 */
export const submitInteractionSchema = z.object({
  verifierId: z.string().optional(),
  interactionEvent: z.string().optional()
}, {
  required_error: "Les données de soumission d'interaction sont requises",
  invalid_type_error: "Format de données de soumission d'interaction invalide"
});

/**
 * Type inféré pour la soumission d'une interaction
 */
export type SubmitInteractionData = z.infer<typeof submitInteractionSchema>;

/**
 * Schéma de validation pour la création d'un enregistrement de vérification par mot de passe
 * @typedef {Object} CreatePasswordVerificationData
 */
export const createPasswordVerificationSchema = z.object({
  password: z.string().min(1, "Le mot de passe est requis")
}, {
  required_error: "Les données de vérification par mot de passe sont requises",
  invalid_type_error: "Format de données de vérification par mot de passe invalide"
});

/**
 * Type inféré pour la création d'un enregistrement de vérification par mot de passe
 */
export type CreatePasswordVerificationData = z.infer<typeof createPasswordVerificationSchema>;

/**
 * Schéma de validation pour la création et l'envoi d'un code de vérification
 * @typedef {Object} CreateVerificationCodeData
 */
export const createVerificationCodeSchema = z.object({
  email: z.string().email("Format d'email invalide").optional(),
  phone: z.string().optional(),
  purpose: z.string().min(1, "Le but est requis")
}, {
  required_error: "Les données de création de code de vérification sont requises",
  invalid_type_error: "Format de données de création de code de vérification invalide"
}).refine(
  data => data.email !== undefined || data.phone !== undefined,
  {
    message: "L'email ou le téléphone est requis"
  }
);

/**
 * Type inféré pour la création et l'envoi d'un code de vérification
 */
export type CreateVerificationCodeData = z.infer<typeof createVerificationCodeSchema>;

/**
 * Schéma de validation pour la vérification d'un code
 * @typedef {Object} VerifyVerificationCodeData
 */
export const verifyVerificationCodeSchema = z.object({
  email: z.string().email("Format d'email invalide").optional(),
  phone: z.string().optional(),
  code: z.string().min(1, "Le code est requis"),
  purpose: z.string().min(1, "Le but est requis")
}, {
  required_error: "Les données de vérification de code sont requises",
  invalid_type_error: "Format de données de vérification de code invalide"
}).refine(
  data => data.email !== undefined || data.phone !== undefined,
  {
    message: "L'email ou le téléphone est requis"
  }
);

/**
 * Type inféré pour la vérification d'un code
 */
export type VerifyVerificationCodeData = z.infer<typeof verifyVerificationCodeSchema>;