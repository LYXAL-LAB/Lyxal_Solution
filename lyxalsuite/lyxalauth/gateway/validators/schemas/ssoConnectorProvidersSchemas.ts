import { z } from 'zod';

/**
 * Schéma pour la récupération des fournisseurs de connecteurs SSO
 * @typedef {z.infer<typeof getSsoConnectorProvidersSchema>} GetSsoConnectorProvidersInput
 */
export const getSsoConnectorProvidersSchema = z.object({
  filters: z.string().optional().describe('Filtres à appliquer à la liste des fournisseurs'),
  limit: z.number().int().min(1).optional().describe('Nombre maximum de résultats à retourner'),
  offset: z.number().int().min(0).optional().describe('Offset pour la pagination')
}).optional();

export type GetSsoConnectorProvidersInput = z.infer<typeof getSsoConnectorProvidersSchema>; 