/**
 * @file captchaSchemas.ts
 * @description Schémas de validation Zod pour les routes de CAPTCHA
 */

import { z } from 'zod';

/**
 * Schéma pour la configuration du fournisseur de CAPTCHA
 * @description Configuration spécifique au fournisseur de CAPTCHA
 * @property {string} siteKey - Clé du site fournie par le service CAPTCHA
 * @property {string} secretKey - Clé secrète fournie par le service CAPTCHA
 */
export const captchaConfigSchema = z.object({
  siteKey: z.string().min(1, 'La clé du site est requise').describe("Clé du site"),
  secretKey: z.string().min(1, 'La clé secrète est requise').describe("Clé secrète")
});

/**
 * Type inféré du schéma de configuration CAPTCHA
 */
export type CaptchaConfig = z.infer<typeof captchaConfigSchema>;

/**
 * Schéma pour la mise à jour du fournisseur de CAPTCHA
 * @description Définit les informations nécessaires pour configurer un fournisseur de CAPTCHA
 * @property {string} provider - Nom du fournisseur de CAPTCHA (ex: "recaptcha", "hcaptcha")
 * @property {object} config - Configuration du fournisseur contenant les clés
 */
export const updateCaptchaProviderSchema = z.object({
  provider: z.string().min(1, 'Le fournisseur est requis').describe("Nom du fournisseur"),
  config: captchaConfigSchema.describe("Configuration du fournisseur")
});

/**
 * Type inféré du schéma de mise à jour du fournisseur CAPTCHA
 */
export type UpdateCaptchaProvider = z.infer<typeof updateCaptchaProviderSchema>;

/**
 * Schéma pour la vérification d'un CAPTCHA
 * @description Utilisé pour valider une réponse CAPTCHA côté serveur
 * @property {string} response - Jeton de réponse CAPTCHA obtenu côté client
 * @property {string} [remoteIp] - Adresse IP du client (optionnelle, mais recommandée)
 */
export const verifyCaptchaSchema = z.object({
  response: z.string().min(1, 'La réponse CAPTCHA est requise').describe("Jeton de réponse CAPTCHA"),
  remoteIp: z.string().optional().describe("Adresse IP du client")
});

/**
 * Type inféré du schéma de vérification CAPTCHA
 */
export type VerifyCaptcha = z.infer<typeof verifyCaptchaSchema>; 