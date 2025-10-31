/**
 * @file resourceSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux ressources API
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'une ressource API
 * @typedef {Object} CreateResourceData
 */
export const createResourceSchema = z.object({
  name: z.string().min(1, "Le nom de la ressource API est requis"),
  identifier: z.string().min(1, "L'identifiant de la ressource API est requis"),
  description: z.string().optional().transform(val => val || undefined),
  isDefault: z.boolean().optional(),
  accessTokenLifespan: z.number().int().positive("La durée de vie du jeton d'accès doit être un entier positif").optional()
}, {
  required_error: "Les données de la ressource API sont requises",
  invalid_type_error: "Format de données de ressource API invalide"
});

/**
 * Type inféré pour la création d'une ressource API
 */
export type CreateResourceData = z.infer<typeof createResourceSchema>;

/**
 * Schéma de validation pour la mise à jour d'une ressource API
 * @typedef {Object} UpdateResourceData
 */
export const updateResourceSchema = z.object({
  name: z.string().min(1, "Le nom de la ressource API est requis").optional(),
  description: z.string().optional().transform(val => val || undefined),
  accessTokenLifespan: z.number().int().positive("La durée de vie du jeton d'accès doit être un entier positif").optional()
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données de ressource API invalide"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins une propriété à mettre à jour est requise"
  }
);

/**
 * Type inféré pour la mise à jour d'une ressource API
 */
export type UpdateResourceData = z.infer<typeof updateResourceSchema>;

/**
 * Schéma de validation pour définir une ressource API comme défaut
 * @typedef {Object} SetResourceAsDefaultData
 */
export const setResourceAsDefaultSchema = z.object({
  isDefault: z.boolean({
    required_error: "La propriété isDefault est requise",
    invalid_type_error: "La propriété isDefault doit être un booléen"
  })
});

/**
 * Type inféré pour définir une ressource API comme défaut
 */
export type SetResourceAsDefaultData = z.infer<typeof setResourceAsDefaultSchema>;

/**
 * Schéma de validation pour la création d'un scope de ressource API
 * @typedef {Object} CreateResourceScopeData
 */
export const createResourceScopeSchema = z.object({
  name: z.string().min(1, "Le nom du scope est requis"),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données du scope sont requises",
  invalid_type_error: "Format de données de scope invalide"
});

/**
 * Type inféré pour la création d'un scope de ressource API
 */
export type CreateResourceScopeData = z.infer<typeof createResourceScopeSchema>;

/**
 * Schéma de validation pour la mise à jour d'un scope de ressource API
 * @typedef {Object} UpdateResourceScopeData
 */
export const updateResourceScopeSchema = z.object({
  name: z.string().min(1, "Le nom du scope est requis").optional(),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données de scope invalide"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins une propriété à mettre à jour est requise"
  }
);

/**
 * Type inféré pour la mise à jour d'un scope de ressource API
 */
export type UpdateResourceScopeData = z.infer<typeof updateResourceScopeSchema>;

/**
 * Schéma de validation pour la pagination
 * @typedef {Object} PaginationData
 */
export const paginationSchema = z.object({
  page: z.number().int().positive("Le numéro de page doit être un entier positif").optional(),
  pageSize: z.number().int().positive("La taille de la page doit être un entier positif").optional()
}, {
  required_error: "Les données de pagination sont requises",
  invalid_type_error: "Format de données de pagination invalide"
}).transform(data => ({
  page: data.page || 1,
  pageSize: data.pageSize || 20
}));

/**
 * Type inféré pour la pagination
 */
export type PaginationData = z.infer<typeof paginationSchema>;
