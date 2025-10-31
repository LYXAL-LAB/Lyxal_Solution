/**
 * @file organizationSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux organisations
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'une organisation
 * @typedef {Object} CreateOrganizationData
 */
export const createOrganizationSchema = z.object({
  name: z.string().min(1, "Le nom de l'organisation est requis"),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Les données de l'organisation sont requises",
  invalid_type_error: "Format de données d'organisation invalide"
});

/**
 * Type inféré pour la création d'une organisation
 */
export type CreateOrganizationData = z.infer<typeof createOrganizationSchema>;

/**
 * Schéma de validation pour la mise à jour d'une organisation
 * @typedef {Object} UpdateOrganizationData
 */
export const updateOrganizationSchema = z.object({
  name: z.string().min(1, "Le nom de l'organisation est requis").optional(),
  description: z.string().optional().transform(val => val || undefined)
}, {
  required_error: "Au moins une propriété à mettre à jour est requise",
  invalid_type_error: "Format de données d'organisation invalide"
});

/**
 * Type inféré pour la mise à jour d'une organisation
 */
export type UpdateOrganizationData = z.infer<typeof updateOrganizationSchema>;

/**
 * Schéma de validation pour l'ajout/attribution de membres utilisateurs à une organisation
 * @typedef {Object} OrganizationUserMembersData
 */
export const organizationUserMembersSchema = z.object({
  userIds: z.array(z.string()).min(1, "Au moins un ID utilisateur est requis")
}, {
  required_error: "Les IDs des utilisateurs sont requis",
  invalid_type_error: "Format de données des membres utilisateurs invalide"
});

/**
 * Type inféré pour l'ajout/attribution de membres utilisateurs à une organisation
 */
export type OrganizationUserMembersData = z.infer<typeof organizationUserMembersSchema>;

/**
 * Schéma de validation pour l'attribution de rôles à des utilisateurs dans une organisation
 * @typedef {Object} AssignRolesToUserData
 */
export const assignRolesToUserSchema = z.object({
  roleIds: z.array(z.string()).min(1, "Au moins un ID de rôle est requis")
}, {
  required_error: "Les IDs des rôles sont requis",
  invalid_type_error: "Format de données des rôles invalide"
});

/**
 * Type inféré pour l'attribution de rôles à des utilisateurs dans une organisation
 */
export type AssignRolesToUserData = z.infer<typeof assignRolesToUserSchema>;

/**
 * Schéma de validation pour l'ajout/attribution d'applications à une organisation
 * @typedef {Object} OrganizationApplicationsData
 */
export const organizationApplicationsSchema = z.object({
  applicationIds: z.array(z.string()).min(1, "Au moins un ID d'application est requis")
}, {
  required_error: "Les IDs des applications sont requis",
  invalid_type_error: "Format de données des applications invalide"
});

/**
 * Type inféré pour l'ajout/attribution d'applications à une organisation
 */
export type OrganizationApplicationsData = z.infer<typeof organizationApplicationsSchema>;

/**
 * Schéma de validation pour l'attribution de rôles à des applications dans une organisation
 * @typedef {Object} AssignRolesToApplicationData
 */
export const assignRolesToApplicationSchema = z.object({
  roleIds: z.array(z.string()).min(1, "Au moins un ID de rôle est requis")
}, {
  required_error: "Les IDs des rôles sont requis",
  invalid_type_error: "Format de données des rôles invalide"
});

/**
 * Type inféré pour l'attribution de rôles à des applications dans une organisation
 */
export type AssignRolesToApplicationData = z.infer<typeof assignRolesToApplicationSchema>;

/**
 * Schéma de validation pour la gestion des domaines email JIT
 * @typedef {Object} JitEmailDomainsData
 */
export const jitEmailDomainsSchema = z.object({
  domains: z.array(z.string().regex(/^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]*\.([a-zA-Z]{2,})+$/, "Format de domaine invalide")).min(1, "Au moins un domaine email est requis")
}, {
  required_error: "Les domaines email sont requis",
  invalid_type_error: "Format de données des domaines email invalide"
});

/**
 * Type inféré pour la gestion des domaines email JIT
 */
export type JitEmailDomainsData = z.infer<typeof jitEmailDomainsSchema>;

/**
 * Schéma de validation pour la gestion des rôles par défaut JIT
 * @typedef {Object} JitDefaultRolesData
 */
export const jitDefaultRolesSchema = z.object({
  roleIds: z.array(z.string()).min(1, "Au moins un ID de rôle est requis")
}, {
  required_error: "Les IDs des rôles par défaut sont requis",
  invalid_type_error: "Format de données des rôles par défaut invalide"
});

/**
 * Type inféré pour la gestion des rôles par défaut JIT
 */
export type JitDefaultRolesData = z.infer<typeof jitDefaultRolesSchema>;

/**
 * Schéma de validation pour la gestion des connecteurs SSO JIT
 * @typedef {Object} JitSsoConnectorsData
 */
export const jitSsoConnectorsSchema = z.object({
  connectorIds: z.array(z.string()).min(1, "Au moins un ID de connecteur est requis")
}, {
  required_error: "Les IDs des connecteurs SSO sont requis",
  invalid_type_error: "Format de données des connecteurs SSO invalide"
});

/**
 * Type inféré pour la gestion des connecteurs SSO JIT
 */
export type JitSsoConnectorsData = z.infer<typeof jitSsoConnectorsSchema>;

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
