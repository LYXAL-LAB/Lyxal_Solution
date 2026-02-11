/**
 * @file organizationScopeSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux scopes d'organisation
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un scope d'organisation
 * @typedef {Object} CreateOrganizationScopeData
 */
export const createOrganizationScopeSchema = z.object({
  organizationId: z.string().min(1, "L'ID de l'organisation est requis"),
  name: z.string().min(1, "Le nom du scope est requis"),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données du scope d'organisation sont requises",
  invalid_type_error: "Format de données de scope d'organisation invalide"
});

/**
 * Type inféré pour la création d'un scope d'organisation
 */
export type CreateOrganizationScopeData = z.infer<typeof createOrganizationScopeSchema>;

/**
 * Schéma de validation pour la mise à jour d'un scope d'organisation
 * @typedef {Object} UpdateOrganizationScopeData
 */
export const updateOrganizationScopeSchema = z.object({
  name: z.string().min(1, "Le nom du scope est requis").optional(),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données de scope d'organisation invalide"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins une propriété à mettre à jour est requise"
  }
);

/**
 * Type inféré pour la mise à jour d'un scope d'organisation
 */
export type UpdateOrganizationScopeData = z.infer<typeof updateOrganizationScopeSchema>;

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
