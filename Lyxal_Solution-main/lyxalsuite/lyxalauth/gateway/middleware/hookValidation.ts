import { z } from 'zod';

/**
 * Schéma de validation pour la configuration d'un webhook
 */
export const webhookConfigSchema = z.object({
  url: z.string().url("L'URL du webhook doit être une URL valide"),
  headers: z.record(z.string()).optional()
});

/**
 * Schéma de validation pour la création d'un webhook
 */
export const createHookSchema = z.object({
  name: z.string().min(1, "Le nom du webhook est requis").max(256, "Le nom du webhook ne doit pas dépasser 256 caractères"),
  events: z.array(z.string().min(1, "L'événement est requis")).min(1, "Au moins un événement est requis"),
  config: webhookConfigSchema,
  enabled: z.boolean().optional()
});

/**
 * Schéma de validation pour la mise à jour d'un webhook
 */
export const updateHookSchema = z.object({
  name: z.string().min(1, "Le nom du webhook est requis").max(256, "Le nom du webhook ne doit pas dépasser 256 caractères").optional(),
  events: z.array(z.string().min(1, "L'événement est requis")).min(1, "Au moins un événement est requis").optional(),
  config: webhookConfigSchema.optional(),
  enabled: z.boolean().optional()
});

/**
 * Schéma de validation pour la mise à jour de la clé de signature d'un webhook
 */
export const updateSigningKeySchema = z.object({
  signingKey: z.string().max(64, "La clé de signature ne doit pas dépasser 64 caractères").optional()
});

/**
 * Fonction de validation pour la création d'un webhook
 */
export function validateCreateHook(input: unknown) {
  return createHookSchema.parse(input);
}

/**
 * Fonction de validation pour la mise à jour d'un webhook
 */
export function validateUpdateHook(input: unknown) {
  return updateHookSchema.parse(input);
}

/**
 * Fonction de validation pour la mise à jour de la clé de signature d'un webhook
 */
export function validateUpdateSigningKey(input: unknown) {
  return updateSigningKeySchema.parse(input);
} 
