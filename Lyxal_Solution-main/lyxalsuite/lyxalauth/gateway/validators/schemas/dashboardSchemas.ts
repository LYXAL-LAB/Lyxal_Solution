/**
 * @file dashboardSchemas.ts
 * @description Schémas de validation Zod pour les routes du tableau de bord
 */

import { z } from 'zod';

/**
 * Schéma pour les requêtes de statistiques d'utilisateurs
 * Permet de filtrer les données par période en utilisant des timestamps
 * @typedef {Object} UserStatsQuery
 * @property {number} [startTimeExclusive] - Timestamp de début de période (exclusif)
 * @property {number} [endTimeInclusive] - Timestamp de fin de période (inclusif)
 */
export const userStatsQuerySchema = z.object({
  startTimeExclusive: z.coerce.number().optional().describe('Timestamp de début (exclusif)'),
  endTimeInclusive: z.coerce.number().optional().describe('Timestamp de fin (inclusif)')
}, {
  required_error: "Les paramètres de requête sont requis",
  invalid_type_error: "Format de paramètres invalide"
});

/**
 * Type inféré pour les requêtes de statistiques d'utilisateurs
 */
export type UserStatsQuery = z.infer<typeof userStatsQuerySchema>;