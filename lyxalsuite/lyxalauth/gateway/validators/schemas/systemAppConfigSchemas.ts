/**
 * @file systemAppConfigSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux configurations d'application système
 * 
 * Note: Les routes systemAppConfig sont principalement des endpoints GET qui ne nécessitent pas
 * de validation d'entrée utilisateur, donc ce fichier contient peu de schémas.
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la structure de configuration du système
 * Principalement utilisé pour la documentation et le typage.
 * @typedef {Object} SystemAppConfigData
 */
export const systemAppConfigSchema = z.object({
  version: z.string(),
  buildNumber: z.string().optional(),
  environment: z.string(),
  defaultLocale: z.string(),
  supportedLocales: z.array(z.string()),
  features: z.record(z.boolean()).optional(),
  constants: z.record(z.union([z.string(), z.number(), z.boolean(), z.null()])).optional()
}, {
  required_error: "Les données de configuration système sont requises",
  invalid_type_error: "Format de données de configuration système invalide"
});

/**
 * Type inféré pour la configuration système
 */
export type SystemAppConfigData = z.infer<typeof systemAppConfigSchema>; 