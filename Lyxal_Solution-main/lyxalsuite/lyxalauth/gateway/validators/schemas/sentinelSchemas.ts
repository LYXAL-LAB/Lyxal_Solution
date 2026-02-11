/**
 * @file sentinelSchemas.ts
 * @description Schémas de validation Zod pour les routes liées à Sentinel
 */

import { z } from 'zod';

/**
 * Schéma pour la suppression en masse d'activités Sentinel
 * @typedef {Object} BulkDeleteSentinelActivitiesData
 */
export const bulkDeleteSentinelActivitiesSchema = z.object({
  ids: z.array(z.string()).min(1, "Au moins un ID d'activité est requis")
}, {
  required_error: "Les données de suppression en masse sont requises",
  invalid_type_error: "Format de données de suppression en masse invalide"
});

/**
 * Type inféré pour la suppression en masse d'activités Sentinel
 */
export type BulkDeleteSentinelActivitiesData = z.infer<typeof bulkDeleteSentinelActivitiesSchema>; 