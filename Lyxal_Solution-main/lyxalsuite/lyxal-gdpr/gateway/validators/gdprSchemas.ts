import { z } from 'zod';

/**
 *  Sélection des types de requêtes RGPD
 * 0 = Access | 1 = Erasure
 */
export const gdprTypeSelectSchema = z.enum(['0', '1']);

/**
 *  Sélection des statuts RGPD
 * 0 = Received | 1 = Confirmed | 2 = Sent | 3 = Canceled
 */
export const gdprStatusSelectSchema = z.enum(['0', '1', '2', '3']);

/**
 *  Création de requête GDPR
 */
export const createGdprRequestSchema = z.object({
  typeSelect: z.union([z.literal(0), z.literal(1)]),
  modelId: z.number().int().positive(),
  modelSelect: z.string().min(1),
  requestComment: z.string().optional(),
  gdprRequestOrigin: z.string().startsWith('gdpr_request_origin:'), // record id
});

/**
 *  Mise à jour partielle d’une requête RGPD
 */
export const updateGdprRequestSchema = z.object({
  statusSelect: gdprStatusSelectSchema.optional(),
  requestComment: z.string().optional(),
});

/**
 *  ID de requête dans l’URL
 */
export const gdprRequestParamsSchema = z.object({
  id: z.string().startsWith('gdpr_request:'),
});

/**
 *  Création d'une réponse RGPD liée à une requête
 */
export const createGdprResponseSchema = z.object({
  responseEmailAddress: z.string().email(),
  anonymizationResult: z.string().optional(),
  messageId: z.string().optional(),
  fileId: z.string().optional(),
});

/**
 *  Params pour lier une réponse à une requête
 */
export const gdprResponseParamsSchema = z.object({
  requestId: z.string().startsWith('gdpr_request:'),
});
