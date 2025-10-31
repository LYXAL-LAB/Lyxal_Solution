/**
 * @file accountSchemas.ts
 * @description Schémas de validation Zod pour les routes de gestion du compte
 */

import { z } from 'zod';

/**
 * Schéma pour la mise à jour des paramètres du centre de compte
 * @description Valide les données pour la mise à jour des paramètres du centre de compte utilisateur
 */
export const updateAccountCenterSettingsSchema = z.object({
  uriTemplate: z.string().url("L'URI template doit être une URL valide").optional(),
  privateUriTemplate: z.string().url("L'URI template privé doit être une URL valide").optional(),
  branding: z.object({
    logoUrl: z.string().url("L'URL du logo doit être une URL valide").optional(),
    darkLogoUrl: z.string().url("L'URL du logo en mode sombre doit être une URL valide").optional(),
    favicon: z.string().url("L'URL du favicon doit être une URL valide").optional(),
    darkFavicon: z.string().url("L'URL du favicon en mode sombre doit être une URL valide").optional(),
    appName: z.record(z.string().min(1, "Le nom de l'application ne peut pas être vide")).optional(),
    appNameAlt: z.record(z.string().min(1, "Le nom alternatif de l'application ne peut pas être vide")).optional(),
    themeOverride: z.record(z.unknown()).optional(),
  }).optional(),
  customCss: z.string().optional(),
  customCssEnabled: z.boolean().optional(),
  languageInfo: z.object({
    autoDetect: z.boolean().optional(),
    fallbackLanguage: z.string().min(2, "Le code de langue doit comporter au moins 2 caractères").optional(),
  }).optional(),
  termsEnabled: z.boolean().optional(),
  termsUrl: z.record(z.string().url("L'URL des conditions d'utilisation doit être une URL valide")).optional(),
  privacyEnabled: z.boolean().optional(),
  privacyUrl: z.record(z.string().url("L'URL de la politique de confidentialité doit être une URL valide")).optional(),
});

/**
 * Type pour les données de mise à jour des paramètres du centre de compte
 */
export type UpdateAccountCenterSettings = z.infer<typeof updateAccountCenterSettingsSchema>; 