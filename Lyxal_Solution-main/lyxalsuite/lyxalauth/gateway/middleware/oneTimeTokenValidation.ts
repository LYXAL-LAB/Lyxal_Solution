import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un jeton à usage unique
 */
export const createOneTimeTokenSchema = z.object({
  type: z.string().min(1, "Le type est requis"),
  code: z.string().optional(),
  pattern: z.string().optional(),
  userId: z.string().optional(),
  action: z.string().optional(),
  payload: z.record(z.unknown()).optional(),
  resource: z.string().optional(),
  expiresInSeconds: z.number().positive("La durée de validité doit être un nombre positif").optional()
});

/**
 * Schéma de validation pour la vérification d'un jeton à usage unique
 */
export const verifyOneTimeTokenSchema = z.object({
  token: z.string().min(1, "Le jeton est requis"),
  userId: z.string().optional(),
  interactionId: z.string().optional(),
  action: z.string().optional(),
  resource: z.string().optional()
});

/**
 * Schéma de validation pour la mise à jour du statut d'un jeton à usage unique
 */
export const updateOneTimeTokenStatusSchema = z.object({
  status: z.enum(['consumed', 'expired', 'inactive'], {
    errorMap: () => ({ message: "Le statut doit être 'consumed', 'expired' ou 'inactive'" })
  })
});

/**
 * Schéma de validation pour la pagination
 */
export const paginationSchema = z.object({
  page: z.number().int().positive("Le numéro de page doit être un entier positif").optional(),
  pageSize: z.number().int().positive("La taille de la page doit être un entier positif").optional()
});

/**
 * Fonction de validation pour la création d'un jeton à usage unique
 */
export function validateCreateOneTimeToken(input: unknown) {
  return createOneTimeTokenSchema.parse(input);
}

/**
 * Fonction de validation pour la vérification d'un jeton à usage unique
 */
export function validateVerifyOneTimeToken(input: unknown) {
  return verifyOneTimeTokenSchema.parse(input);
}

/**
 * Fonction de validation pour la mise à jour du statut d'un jeton à usage unique
 */
export function validateUpdateOneTimeTokenStatus(input: unknown) {
  return updateOneTimeTokenStatusSchema.parse(input);
}

/**
 * Fonction de validation pour la pagination
 */
export function validatePagination(input: unknown) {
  return paginationSchema.parse(input);
} 
