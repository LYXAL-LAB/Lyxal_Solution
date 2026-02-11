 /**
 * @file organizationInvitationSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux invitations d'organisation
 */

import { z } from 'zod';

/**
 * Schéma de validation pour la création d'une invitation à une organisation
 * @typedef {Object} CreateOrganizationInvitationData
 */
export const createOrganizationInvitationSchema = z.object({
  organizationId: z.string().min(1, "L'ID de l'organisation est requis"),
  invitee: z.string().email("Format d'email invalide pour l'invité"),
  expiresInSeconds: z.number().positive("La durée de validité doit être un nombre positif").optional(),
  role: z.string().min(1, "L'identifiant du rôle doit contenir au moins un caractère").optional()
}, {
  required_error: "Les données de l'invitation à l'organisation sont requises",
  invalid_type_error: "Format de données d'invitation invalide"
});

/**
 * Type inféré pour la création d'une invitation à une organisation
 */
export type CreateOrganizationInvitationData = z.infer<typeof createOrganizationInvitationSchema>;

/**
 * Schéma de validation pour la mise à jour du statut d'une invitation
 * @typedef {Object} UpdateOrganizationInvitationStatusData
 */
export const updateOrganizationInvitationStatusSchema = z.object({
  status: z.enum(['accepted', 'declined'], {
    errorMap: () => ({ message: "Le statut doit être 'accepted' ou 'declined'" })
  })
}, {
  required_error: "Le statut de l'invitation est requis",
  invalid_type_error: "Format de données de statut d'invitation invalide"
});

/**
 * Type inféré pour la mise à jour du statut d'une invitation
 */
export type UpdateOrganizationInvitationStatusData = z.infer<typeof updateOrganizationInvitationStatusSchema>;

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
