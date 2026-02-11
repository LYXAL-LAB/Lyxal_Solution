/**
 * @file verificationCodeSchemas.ts
 * @description Schémas de validation Zod pour les routes liées aux codes de vérification
 */

import { z } from 'zod';

/**
 * Schéma pour la vérification d'un code
 * @typedef {Object} VerifyVerificationCodeData
 */
export const verifyVerificationCodeSchema = z.object({
  phone: z.string().optional().transform(val => val || undefined),
  email: z.string().email("Format d'email invalide").optional().transform(val => val || undefined),
  code: z.string().min(1, "Le code est requis"),
  purpose: z.string().min(1, "L'objectif est requis")
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);

/**
 * Type inféré pour la vérification d'un code
 */
export type VerifyVerificationCodeData = z.infer<typeof verifyVerificationCodeSchema>;

