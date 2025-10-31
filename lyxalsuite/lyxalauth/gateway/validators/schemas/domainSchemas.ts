/**
 * @file domainSchemas.ts
 * @description Schémas de validation Zod pour les routes de domaines
 */

import { z } from 'zod';

/**
 * Schéma pour la création d'un domaine
 * @typedef {Object} CreateDomainData
 * @property {string} domain - Le nom de domaine (format: example.com)
 * @property {'Primary'|'Secondary'} type - Le type de domaine
 * @property {string} [organizationId] - L'ID de l'organisation associée (optionnel)
 */
export const createDomainSchema = z.object({
  domain: z.string().min(1, "Le nom de domaine est requis").refine(
    (value) => /^([\w-]+\.)+[\w-]+$/.test(value),
    {
      message: "Format de domaine invalide"
    }
  ),
  type: z.enum(['Primary', 'Secondary'], {
    errorMap: () => ({ message: "Le type doit être 'Primary' ou 'Secondary'" })
  }),
  organizationId: z.string().optional().describe("ID de l'organisation associée (optionnel)")
}, {
  required_error: "Les données du domaine sont requises",
  invalid_type_error: "Format de données invalide"
});

/**
 * Type inféré pour la création d'un domaine
 */
export type CreateDomainData = z.infer<typeof createDomainSchema>; 