/**
 * @file verificationSchemas.ts
 * @description Schémas de validation Zod pour les routes de vérification
 */

import { z } from 'zod';

/**
 * Schéma pour la création d'une vérification par mot de passe
 */
export const createVerificationByPasswordSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  password: z.string().min(1, "Le mot de passe est requis")
});

/**
 * Schéma pour la création d'une vérification par code
 */
export const createVerificationByCodeSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  codeType: z.string().min(1, "Le type de code est requis"),
  email: z.string().email("Format d'email invalide").optional(),
  phone: z.string().optional()
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);

/**
 * Schéma pour la vérification d'un code
 */
export const verifyCodeSchema = z.object({
  verificationId: z.string().min(1, "L'ID de vérification est requis"),
  code: z.string().min(1, "Le code est requis")
});

/**
 * Schéma pour la création d'une vérification sociale
 */
export const createSocialVerificationSchema = z.object({
  userId: z.string().min(1, "L'ID utilisateur est requis"),
  provider: z.string().min(1, "Le fournisseur est requis"),
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide")
});

/**
 * Schéma pour la vérification d'une vérification sociale
 */
export const verifySocialVerificationSchema = z.object({
  verificationId: z.string().min(1, "L'ID de vérification est requis"),
  code: z.string().min(1, "Le code est requis"),
  state: z.string().optional()
});

/**
 * Schéma pour la demande d'un code de vérification
 */
export const requestVerificationCodeSchema = z.object({
  phone: z.string().optional(),
  email: z.string().email("Format d'email invalide").optional(),
  purpose: z.string().min(1, "L'objectif est requis"),
  codeType: z.string().optional()
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);

/**
 * Schéma pour la vérification d'un code de vérification
 */
export const verifyVerificationCodeSchema = z.object({
  phone: z.string().optional(),
  email: z.string().email("Format d'email invalide").optional(),
  code: z.string().min(1, "Le code est requis"),
  purpose: z.string().min(1, "L'objectif est requis")
}).refine(
  data => !!(data.email || data.phone),
  {
    message: "Au moins un email ou un téléphone est requis",
    path: ["email"]
  }
);

// Export des types inférés
export type CreateVerificationByPasswordInput = z.infer<typeof createVerificationByPasswordSchema>;
export type CreateVerificationByCodeInput = z.infer<typeof createVerificationByCodeSchema>;
export type VerifyCodeInput = z.infer<typeof verifyCodeSchema>;
export type CreateSocialVerificationInput = z.infer<typeof createSocialVerificationSchema>;
export type VerifySocialVerificationInput = z.infer<typeof verifySocialVerificationSchema>;
export type RequestVerificationCodeInput = z.infer<typeof requestVerificationCodeSchema>;
export type VerifyVerificationCodeData = z.infer<typeof verifyVerificationCodeSchema>;
