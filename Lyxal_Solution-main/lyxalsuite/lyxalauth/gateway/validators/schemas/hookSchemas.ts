/**
 * @file hookSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux webhooks
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la configuration d'un webhook
 * @typedef {Object} WebhookConfigData
 */
export const webhookConfigSchema = z.object({
  url: z.string().url("L'URL du webhook doit être une URL valide"),
  headers: z.record(z.string()).optional().transform(val => val || undefined)
}, {
  required_error: "La configuration du webhook est requise",
  invalid_type_error: "Format de configuration du webhook invalide"
});

/**
 * Type inféré pour la configuration d'un webhook
 */
export type WebhookConfigData = z.infer<typeof webhookConfigSchema>;

/**
 * Schéma de validation pour la création d'un webhook
 * @typedef {Object} CreateHookData
 */
export const createHookSchema = z.object({
  name: z.string().min(1, "Le nom du webhook est requis").max(256, "Le nom du webhook ne doit pas dépasser 256 caractères"),
  events: z.array(z.string().min(1, "L'événement est requis")).min(1, "Au moins un événement est requis"),
  config: webhookConfigSchema,
  enabled: z.boolean().optional().default(true)
}, {
  required_error: "Les données de création du webhook sont requises",
  invalid_type_error: "Format de données de création du webhook invalide"
});

/**
 * Type inféré pour la création d'un webhook
 */
export type CreateHookData = z.infer<typeof createHookSchema>;

/**
 * Schéma de validation pour la mise à jour d'un webhook
 * @typedef {Object} UpdateHookData
 */
export const updateHookSchema = z.object({
  name: z.string().min(1, "Le nom du webhook est requis").max(256, "Le nom du webhook ne doit pas dépasser 256 caractères").optional(),
  events: z.array(z.string().min(1, "L'événement est requis")).min(1, "Au moins un événement est requis").optional(),
  config: webhookConfigSchema.optional(),
  enabled: z.boolean().optional()
}, {
  required_error: "Les données de mise à jour du webhook sont requises",
  invalid_type_error: "Format de données de mise à jour du webhook invalide"
});

/**
 * Type inféré pour la mise à jour d'un webhook
 */
export type UpdateHookData = z.infer<typeof updateHookSchema>;

/**
 * Schéma de validation pour la mise à jour de la clé de signature d'un webhook
 * @typedef {Object} UpdateSigningKeyData
 */
export const updateSigningKeySchema = z.object({
  signingKey: z.string().max(64, "La clé de signature ne doit pas dépasser 64 caractères").optional()
}, {
  required_error: "Les données de mise à jour de la clé de signature sont requises",
  invalid_type_error: "Format de données de mise à jour de la clé de signature invalide"
});

/**
 * Type inféré pour la mise à jour de la clé de signature d'un webhook
 */
export type UpdateSigningKeyData = z.infer<typeof updateSigningKeySchema>; 