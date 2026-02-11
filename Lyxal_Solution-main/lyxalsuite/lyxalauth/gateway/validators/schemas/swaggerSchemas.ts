/**
 * @file swaggerSchemas.ts
 * @description Schémas de validation Zod pour les routes liées à la documentation Swagger
 * 
 * Note: Les routes Swagger sont principalement des endpoints GET qui ne nécessitent pas
 * de validation d'entrée utilisateur, donc ce fichier contient peu de schémas.
 */

import { z } from 'zod';

/**
 * Schéma de validation pour filtrer les opérations de l'API (utilisé dans des cas spécifiques)
 * @typedef {Object} SwaggerFilterData
 */
export const swaggerFilterSchema = z.object({
  tags: z.array(z.string()).optional(),
  paths: z.array(z.string()).optional(),
  operations: z.array(z.string()).optional()
}, {
  required_error: "Les données de filtrage Swagger sont requises",
  invalid_type_error: "Format de données de filtrage Swagger invalide"
});

/**
 * Type inféré pour le filtrage Swagger
 */
export type SwaggerFilterData = z.infer<typeof swaggerFilterSchema>; 