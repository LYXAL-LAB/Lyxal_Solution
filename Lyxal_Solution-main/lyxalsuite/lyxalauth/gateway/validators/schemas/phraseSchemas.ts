/**
 * @file phraseSchemas.ts
 * @description Schémas de validation Zod pour les routes de phrases personnalisées
 */

import { z } from 'zod';

/**
 * Liste des codes de langue valides selon la documentation de Logto
 */
const validLanguageTags = [
  'af-ZA', 'am-ET', 'ar', 'ar-AR', 'as-IN', 'az-AZ', 'be-BY', 'bg-BG', 'bn-IN',
  'br-FR', 'bs-BA', 'ca-ES', 'cb-IQ', 'co-FR', 'cs-CZ', 'cx-PH', 'cy-GB', 'da-DK',
  'de', 'de-DE', 'el-GR', 'en', 'en-GB', 'en-US', 'eo-EO', 'es', 'es-ES', 'es-419',
  'et-EE', 'eu-ES', 'fa-IR', 'ff-NG', 'fi', 'fi-FI', 'fo-FO', 'fr', 'fr-CA', 'fr-FR',
  'fy-NL', 'ga-IE', 'gl-ES', 'gn-PY', 'gu-IN', 'ha-NG', 'he-IL', 'hi-IN', 'hr-HR',
  'ht-HT', 'hu-HU', 'hy-AM', 'id-ID', 'ik-US', 'is-IS', 'it', 'it-IT', 'iu-CA', 'ja',
  'ja-JP', 'ja-KS', 'jv-ID', 'ka-GE', 'kk-KZ', 'km-KH', 'kn-IN', 'ko', 'ko-KR', 'ku-TR',
  'ky-KG', 'lo-LA', 'lt-LT', 'lv-LV', 'mg-MG', 'mk-MK', 'ml-IN', 'mn-MN', 'mr-IN',
  'ms-MY', 'mt-MT', 'my-MM', 'nb-NO', 'ne-NP', 'nl', 'nl-BE', 'nl-NL', 'nn-NO', 'or-IN',
  'pa-IN', 'pl-PL', 'ps-AF', 'pt', 'pt-BR', 'pt-PT', 'ro-RO', 'ru', 'ru-RU', 'rw-RW',
  'sc-IT', 'si-LK', 'sk-SK', 'sl-SI', 'sn-ZW', 'sq-AL', 'sr-RS', 'sv', 'sv-SE', 'sw-KE',
  'sy-SY', 'sz-PL', 'ta-IN', 'te-IN', 'tg-TJ', 'th', 'th-TH', 'tl-PH', 'tr', 'tr-TR',
  'tt-RU', 'tz-MA', 'uk-UA', 'ur-PK', 'uz-UZ', 'vi-VN', 'zh', 'zh-CN', 'zh-HK', 'zh-MO',
  'zh-TW', 'zz-TR'
] as const;

/**
 * Schéma pour la création ou mise à jour de phrases personnalisées
 */
export const upsertCustomPhraseSchema = z.object({
  translation: z.record(z.string().min(1, 'La traduction ne peut pas être vide'), {
    required_error: "L'objet de traduction est requis",
    invalid_type_error: "L'objet de traduction doit être un objet valide"
  })
});

/**
 * Schéma complet pour la mise à jour des phrases personnalisées
 * y compris le languageTag qui peut être passé dans l'URL ou le corps
 */
export const upsertCustomPhraseWithLanguageSchema = z.object({
  languageTag: z.enum(validLanguageTags, {
    errorMap: () => ({ message: 'Code de langue invalide' })
  }),
  translation: z.record(z.string().min(1, 'La traduction ne peut pas être vide'), {
    required_error: "L'objet de traduction est requis",
    invalid_type_error: "L'objet de traduction doit être un objet valide"
  })
}); 