/**
 * @file logSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux logs
 */

import { z } from 'zod';

/**
 * Schéma de validation pour les paramètres de requête de logs
 * @typedef {Object} GetLogsQueryData
 */
export const getLogsQuerySchema = z.object({
  page: z.coerce.number().min(1, "La page doit être un nombre positif").optional().transform(val => val || 1),
  page_size: z.coerce.number().min(1, "La taille de page doit être un nombre positif").max(1000, "La taille de page ne peut pas dépasser 1000").optional().transform(val => val || 100),
  application_id: z.string().optional().transform(val => val || undefined),
  application_name: z.string().optional().transform(val => val || undefined),
  user_id: z.string().optional().transform(val => val || undefined),
  username: z.string().optional().transform(val => val || undefined),
  event: z.string().optional().transform(val => val || undefined),
  type: z.string().optional().transform(val => val || undefined),
  ip_address: z.string().optional().transform(val => val || undefined),
  range: z.string().optional().transform((val) => {
    if (!val) return undefined;
    const [start, end] = val.split(',');
    if (!start || !end) return undefined;
    return [start, end] as [string, string];
  }),
}, {
  required_error: "Les paramètres de requête sont requis",
  invalid_type_error: "Format de paramètres de requête invalide"
});

/**
 * Type inféré pour les paramètres de requête de logs
 */
export type GetLogsQueryData = z.infer<typeof getLogsQuerySchema>;

/**
 * Schéma de validation pour les paramètres de requête de logs d'application
 * @typedef {Object} GetApplicationLogsQueryData
 */
export const getApplicationLogsQuerySchema = getLogsQuerySchema.omit({
  application_id: true,
  application_name: true
}).extend({
  resource_id: z.string().optional().transform(val => val || undefined),
  resource_type: z.string().optional().transform(val => val || undefined)
});

/**
 * Type inféré pour les paramètres de requête de logs d'application
 */
export type GetApplicationLogsQueryData = z.infer<typeof getApplicationLogsQuerySchema>;

/**
 * Schéma de validation pour les paramètres de requête de logs d'utilisateur
 * @typedef {Object} GetUserLogsQueryData
 */
export const getUserLogsQuerySchema = getLogsQuerySchema.omit({
  user_id: true,
  username: true
}).extend({
  detail_level: z.enum(["basic", "detailed", "full"], {
    required_error: "Le niveau de détail est requis",
    invalid_type_error: "Le niveau de détail doit être 'basic', 'detailed' ou 'full'"
  }).optional().transform(val => val || "basic")
});

/**
 * Type inféré pour les paramètres de requête de logs d'utilisateur
 */
export type GetUserLogsQueryData = z.infer<typeof getUserLogsQuerySchema>; 