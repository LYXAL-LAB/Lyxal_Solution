/**
 * @file roleSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux rôles
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'un rôle
 * @typedef {Object} CreateRoleData
 */
export const createRoleSchema = z.object({
  name: z.string().min(1, "Le nom du rôle est requis"),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données du rôle sont requises",
  invalid_type_error: "Format de données de rôle invalide"
});

/**
 * Type inféré pour la création d'un rôle
 */
export type CreateRoleData = z.infer<typeof createRoleSchema>;

/**
 * Schéma de validation pour la mise à jour d'un rôle
 * @typedef {Object} UpdateRoleData
 */
export const updateRoleSchema = z.object({
  name: z.string().min(1, "Le nom du rôle est requis").optional(),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données de rôle invalide"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins une propriété à mettre à jour est requise"
  }
);

/**
 * Type inféré pour la mise à jour d'un rôle
 */
export type UpdateRoleData = z.infer<typeof updateRoleSchema>;

/**
 * Schéma de validation pour l'assignation de rôles à des utilisateurs
 * @typedef {Object} AssignRoleToUsersData
 */
export const assignRoleToUsersSchema = z.object({
  userIds: z.array(z.string().min(1, "L'ID utilisateur ne peut pas être vide")).min(1, "Au moins un ID utilisateur est requis")
}, {
  required_error: "Les IDs des utilisateurs sont requis",
  invalid_type_error: "Format de données d'utilisateurs invalide"
});

/**
 * Type inféré pour l'assignation de rôles à des utilisateurs
 */
export type AssignRoleToUsersData = z.infer<typeof assignRoleToUsersSchema>;

/**
 * Schéma de validation pour l'assignation de rôles à des applications
 * @typedef {Object} AssignRoleToApplicationsData
 */
export const assignRoleToApplicationsSchema = z.object({
  applicationIds: z.array(z.string().min(1, "L'ID d'application ne peut pas être vide")).min(1, "Au moins un ID d'application est requis")
}, {
  required_error: "Les IDs des applications sont requis",
  invalid_type_error: "Format de données d'applications invalide"
});

/**
 * Type inféré pour l'assignation de rôles à des applications
 */
export type AssignRoleToApplicationsData = z.infer<typeof assignRoleToApplicationsSchema>;

/**
 * Schéma de validation pour lier des scopes à un rôle
 * @typedef {Object} LinkScopesToRoleData
 */
export const linkScopesToRoleSchema = z.object({
  scopeIds: z.array(z.string().min(1, "L'ID de scope ne peut pas être vide")).min(1, "Au moins un ID de scope est requis")
}, {
  required_error: "Les IDs des scopes sont requis",
  invalid_type_error: "Format de données de scopes invalide"
});

/**
 * Type inféré pour lier des scopes à un rôle
 */
export type LinkScopesToRoleData = z.infer<typeof linkScopesToRoleSchema>;

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
