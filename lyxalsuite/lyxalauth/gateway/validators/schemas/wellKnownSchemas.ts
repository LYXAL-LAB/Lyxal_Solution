import { z } from 'zod';

/**
 * Schéma pour la récupération de l'expérience de connexion complète
 * Définit les paramètres optionnels pour la requête d'expérience de connexion
 */
export const getFullSignInExperienceSchema = z.object({
  organizationId: z.string().optional()
    .describe("Identifiant optionnel de l'organisation pour filtrer l'expérience de connexion"),
  appId: z.string().optional()
    .describe("Identifiant optionnel de l'application pour filtrer l'expérience de connexion")
});

/**
 * Type inféré pour les paramètres de récupération de l'expérience de connexion
 */
export type GetFullSignInExperienceParams = z.infer<typeof getFullSignInExperienceSchema>;

/**
 * Schéma pour la récupération des phrases localisées
 * Définit les paramètres optionnels pour la requête de phrases localisées
 */
export const getWellKnownLocalizedPhrasesSchema = z.object({
  language: z.string().optional()
    .describe("Code de langue optionnel pour filtrer les phrases (par exemple 'fr', 'en')")
});

/**
 * Type inféré pour les paramètres de récupération des phrases localisées
 */
export type GetWellKnownLocalizedPhrasesParams = z.infer<typeof getWellKnownLocalizedPhrasesSchema>; 