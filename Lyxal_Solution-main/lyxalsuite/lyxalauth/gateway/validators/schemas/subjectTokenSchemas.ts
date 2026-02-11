/**
 * @file subjectTokenSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux tokens de sujet
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un token de sujet
 * @typedef {Object} CreateSubjectTokenData
 */
export const createSubjectTokenSchema = z.object({
  userId: z.string().min(1, "L'ID de l'utilisateur est requis"),
  expiresIn: z.number().positive("La durée d'expiration doit être un nombre positif").optional(),
  tenantId: z.string().optional().transform(val => val || undefined),
  scope: z.union([
    z.string(),
    z.array(z.string())
  ]).optional()
}, {
  required_error: "Les données du token de sujet sont requises",
  invalid_type_error: "Format de données de token de sujet invalide"
});

/**
 * Type inféré pour la création d'un token de sujet
 */
export type CreateSubjectTokenData = z.infer<typeof createSubjectTokenSchema>; 