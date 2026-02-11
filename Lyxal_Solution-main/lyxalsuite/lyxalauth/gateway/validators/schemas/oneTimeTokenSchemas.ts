/**
 * @file oneTimeTokenSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux jetons à usage unique
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un jeton à usage unique
 * @typedef {Object} CreateOneTimeTokenData
 */
export const createOneTimeTokenSchema = z.object({
  type: z.string().min(1, "Le type de jeton est requis"),
  code: z.string().optional().transform(val => val || undefined),
  pattern: z.string().optional().transform(val => val || undefined),
  userId: z.string().optional().transform(val => val || undefined),
  action: z.string().optional().transform(val => val || undefined),
  payload: z.record(z.unknown()).optional(),
  resource: z.string().optional().transform(val => val || undefined),
  expiresInSeconds: z.number().positive("La durée de validité doit être un nombre positif").optional()
}, {
  required_error: "Les données de création du jeton à usage unique sont requises",
  invalid_type_error: "Format de données de création du jeton à usage unique invalide"
});

/**
 * Type inféré pour la création d'un jeton à usage unique
 */
export type CreateOneTimeTokenData = z.infer<typeof createOneTimeTokenSchema>;

/**
 * Schéma de validation pour la vérification d'un jeton à usage unique
 * @typedef {Object} VerifyOneTimeTokenData
 */
export const verifyOneTimeTokenSchema = z.object({
  token: z.string().min(1, "Le jeton est requis"),
  userId: z.string().optional().transform(val => val || undefined),
  interactionId: z.string().optional().transform(val => val || undefined),
  action: z.string().optional().transform(val => val || undefined),
  resource: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données de vérification du jeton à usage unique sont requises",
  invalid_type_error: "Format de données de vérification du jeton à usage unique invalide"
});

/**
 * Type inféré pour la vérification d'un jeton à usage unique
 */
export type VerifyOneTimeTokenData = z.infer<typeof verifyOneTimeTokenSchema>;

/**
 * Schéma de validation pour la mise à jour du statut d'un jeton à usage unique
 * @typedef {Object} UpdateOneTimeTokenStatusData
 */
export const updateOneTimeTokenStatusSchema = z.object({
  status: z.enum(['consumed', 'expired', 'inactive'], {
    errorMap: () => ({ message: "Le statut doit être 'consumed', 'expired' ou 'inactive'" })
  })
}, {
  required_error: "Les données de mise à jour du statut du jeton à usage unique sont requises",
  invalid_type_error: "Format de données de mise à jour du statut du jeton à usage unique invalide"
});

/**
 * Type inféré pour la mise à jour du statut d'un jeton à usage unique
 */
export type UpdateOneTimeTokenStatusData = z.infer<typeof updateOneTimeTokenStatusSchema>;

/**
 * Schéma de validation pour la pagination
 * @typedef {Object} PaginationData
 */
export const paginationSchema = z.object({
  page: z.number().int("Le numéro de page doit être un entier").positive("Le numéro de page doit être positif").default(1),
  pageSize: z.number().int("La taille de page doit être un entier").positive("La taille de page doit être positive").default(20)
}, {
  required_error: "Les données de pagination sont requises",
  invalid_type_error: "Format de données de pagination invalide"
});

/**
 * Type inféré pour la pagination
 */
export type PaginationData = z.infer<typeof paginationSchema>; 
