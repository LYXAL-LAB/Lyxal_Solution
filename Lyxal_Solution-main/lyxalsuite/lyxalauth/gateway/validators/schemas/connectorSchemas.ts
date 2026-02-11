/**
 * @file connectorSchemas.ts
 * @description Schémas de validation Zod pour les routes de connecteurs
 */

import { z } from 'zod';

/**
 * Schéma pour la création d'un connecteur
 */
export const createConnectorSchema = z.object({
  target: z.string().min(1, "Le target est requis"),
  config: z.record(z.unknown()),
  metadata: z.object({
    name: z.string().min(1, "Le nom est requis"),
    description: z.string().optional(),
    logo: z.string().url("Le logo doit être une URL valide").optional(),
    logoDark: z.string().url("Le logo dark doit être une URL valide").optional()
  }).optional()
});

/**
 * Schéma pour la mise à jour d'un connecteur
 */
export const updateConnectorSchema = z.object({
  config: z.record(z.unknown()).optional(),
  metadata: z.object({
    name: z.string().min(1, "Le nom est requis").optional(),
    description: z.string().optional(),
    logo: z.string().url("Le logo doit être une URL valide").optional(),
    logoDark: z.string().url("Le logo dark doit être une URL valide").optional()
  }).optional()
});

/**
 * Schéma pour tester un connecteur sans mot de passe
 */
export const testPasswordlessConnectorSchema = z.object({
  connectorId: z.string().min(1, "L'ID du connecteur est requis"),
  phone: z.string().optional(),
  email: z.string().email("Format d'email invalide").optional()
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);

/**
 * Schéma pour récupérer l'URI d'autorisation d'un connecteur
 */
export const getAuthorizationUriSchema = z.object({
  state: z.string().min(1, "Le state est requis"),
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide"),
  connectorId: z.string().optional()
}); 