/**
 * @file emailTemplateSchemas.ts
 * @description Schémas de validation Zod pour les routes de modèles d'emails
 */

import { z } from 'zod';

/**
 * Schéma pour la mise à jour d'un modèle d'email
 * @typedef {Object} UpdateEmailTemplateData
 * @property {string} [subject] - Le sujet de l'email
 * @property {string} [htmlContent] - Le contenu HTML de l'email
 * @property {string} [textContent] - Le contenu texte de l'email
 * @property {string} [language] - La langue du modèle d'email
 */
export const updateEmailTemplateSchema = z.object({
  subject: z.string().min(1, "Le sujet est requis").optional(),
  htmlContent: z.string().min(1, "Le contenu HTML est requis").optional(),
  textContent: z.string().min(1, "Le contenu texte est requis").optional(),
  language: z.string().min(1, "La langue est requise").optional()
}, {
  invalid_type_error: "Format de données invalide pour la mise à jour du modèle d'email"
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: "Au moins un champ doit être fourni pour la mise à jour"
  }
);

/**
 * Type inféré pour la mise à jour d'un modèle d'email
 */
export type UpdateEmailTemplateData = z.infer<typeof updateEmailTemplateSchema>;

/**
 * Schéma pour un modèle d'email complet
 * @typedef {Object} EmailTemplateData
 * @property {string} id - L'identifiant unique du modèle
 * @property {string} type - Le type du modèle d'email
 * @property {string} subject - Le sujet de l'email
 * @property {string} htmlContent - Le contenu HTML de l'email
 * @property {string} [textContent] - Le contenu texte de l'email (optionnel)
 * @property {string} language - La langue du modèle d'email
 */
export const emailTemplateSchema = z.object({
  id: z.string().min(1, "L'ID du modèle est requis"),
  type: z.string().min(1, "Le type du modèle est requis"),
  subject: z.string().min(1, "Le sujet est requis"),
  htmlContent: z.string().min(1, "Le contenu HTML est requis"),
  textContent: z.string().min(1, "Le contenu texte est requis").optional(),
  language: z.string().min(1, "La langue est requise")
}, {
  required_error: "Les données du modèle d'email sont requises",
  invalid_type_error: "Format de données invalide pour le modèle d'email"
});

/**
 * Type inféré pour un modèle d'email complet
 */
export type EmailTemplateData = z.infer<typeof emailTemplateSchema>;

/**
 * Schéma pour le remplacement de tous les modèles d'emails
 */
export const replaceEmailTemplatesSchema = z.array(
  emailTemplateSchema,
  {
    required_error: "La liste des modèles d'emails est requise",
    invalid_type_error: "Format de données invalide pour la liste des modèles d'emails"
  }
);

/**
 * Type inféré pour le remplacement de tous les modèles d'emails
 */
export type ReplaceEmailTemplatesData = z.infer<typeof replaceEmailTemplatesSchema>;