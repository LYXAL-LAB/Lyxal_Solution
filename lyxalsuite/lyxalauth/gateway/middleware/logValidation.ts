import { z } from 'zod';

/**
 * Schéma pour les paramètres de requête de logs
 */
export const getLogsQuerySchema = z.object({
  page: z.coerce.number().optional(),
  page_size: z.coerce.number().optional(),
  application_id: z.string().optional(),
  application_name: z.string().optional(),
  user_id: z.string().optional(),
  username: z.string().optional(),
  event: z.string().optional(),
  type: z.string().optional(),
  ip_address: z.string().optional(),
  range: z.string().optional().transform((val) => {
    if (!val) return undefined;
    const [start, end] = val.split(',');
    if (!start || !end) return undefined;
    return [start, end] as [string, string];
  }),
});

/**
 * Fonction de validation pour les paramètres de requête de logs
 */
export function validateGetLogsQuery(input: unknown) {
  return getLogsQuerySchema.parse(input);
} 
