import { z } from 'zod';

/**
 * Schéma pour la vérification de l'état de santé
 * @typedef {z.infer<typeof healthCheckSchema>} HealthCheckInput
 */
export const healthCheckSchema = z.object({
  detailed: z.boolean().optional().describe('Indique si des informations détaillées sont demandées'),
  timeout: z.number().int().min(100).optional().describe('Délai d\'attente maximum en millisecondes')
}).optional();

export type HealthCheckInput = z.infer<typeof healthCheckSchema>; 