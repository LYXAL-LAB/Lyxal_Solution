/**
 * @file organizationRoleSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux rôles d'organisation
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un rôle d'organisation
 * @typedef {Object} CreateOrganizationRoleData
 */
export const createOrganizationRoleSchema = z.object({
  organizationId: z.string().min(1, "L'ID de l'organisation est requis"),
  name: z.string().min(1, "Le nom du rôle est requis"),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données du rôle d'organisation sont requises",
  invalid_type_error: "Format de données de rôle d'organisation invalide"
});

/**
 * Type inféré pour la création d'un rôle d'organisation
 */
export type CreateOrganizationRoleData = z.infer<typeof createOrganizationRoleSchema>;

/**
 * Schéma de validation pour la mise à jour d'un rôle d'organisation
 * @typedef {Object} UpdateOrganizationRoleData
 */
export const updateOrganizationRoleSchema = z.object({
  name: z.string().min(1, "Le nom du rôle est requis").optional(),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données de rôle d'organisation invalide"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins une propriété à mettre à jour est requise"
  }
);

/**
 * Type inféré pour la mise à jour d'un rôle d'organisation
 */
export type UpdateOrganizationRoleData = z.infer<typeof updateOrganizationRoleSchema>;

/**
 * Schéma de validation pour l'attribution de scopes à un rôle d'organisation
 * @typedef {Object} AssignOrganizationScopesData
 */
export const assignOrganizationScopesSchema = z.object({
  scopes: z.array(z.string().min(1, "L'identifiant du scope doit contenir au moins un caractère")).min(1, "Au moins un scope est requis")
}, {
  required_error: "Les scopes sont requis",
  invalid_type_error: "Format de données de scopes invalide"
});

/**
 * Type inféré pour l'attribution de scopes à un rôle d'organisation
 */
export type AssignOrganizationScopesData = z.infer<typeof assignOrganizationScopesSchema>;

/**
 * Schéma de validation pour l'attribution de scopes de ressource à un rôle d'organisation
 * @typedef {Object} AssignResourceScopesData
 */
export const assignResourceScopesSchema = z.object({
  resourceScopes: z.array(
    z.object({
      resourceId: z.string().min(1, "L'ID de la ressource est requis"),
      scopeIds: z.array(z.string().min(1, "L'identifiant du scope doit contenir au moins un caractère")).min(1, "Au moins un scope est requis")
    }, {
      required_error: "Les données de ressource et scopes sont requises",
      invalid_type_error: "Format de données de ressource et scopes invalide"
    })
  ).min(1, "Au moins une ressource avec des scopes est requise")
}, {
  required_error: "Les ressources avec scopes sont requises",
  invalid_type_error: "Format de données de ressources avec scopes invalide"
});

/**
 * Type inféré pour l'attribution de scopes de ressource à un rôle d'organisation
 */
export type AssignResourceScopesData = z.infer<typeof assignResourceScopesSchema>;

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
