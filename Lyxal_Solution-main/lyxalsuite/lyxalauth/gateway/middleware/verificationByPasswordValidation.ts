import { z } from 'zod';

/**
 * Schéma pour la création d'un enregistrement par mot de passe
 */
export const createVerificationByPasswordSchema = z.object({
  username: z.string().optional(),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  password: z.string().min(1, "Le mot de passe est requis")
}).refine(
  (data) => data.username || data.email || data.phone, 
  { message: "Au moins un des champs 'username', 'email' ou 'phone' doit être fourni" }
);

/**
 * Schéma pour la création d'un enregistrement par code de vérification
 */
export const createVerificationByCodeSchema = z.object({
  username: z.string().optional(),
  email: z.string().email().optional(),
  phone: z.string().optional(),
  code: z.string().min(1, "Le code est requis"),
  purpose: z.enum(['Register', 'SignIn', 'ForgotPassword', 'Generic'])
}).refine(
  (data) => data.username || data.email || data.phone, 
  { message: "Au moins un des champs 'username', 'email' ou 'phone' doit être fourni" }
);

/**
 * Schéma pour la vérification d'un code de vérification
 */
export const verifyCodeSchema = z.object({
  interactionEvent: z.string().min(1, "L'événement d'interaction est requis"),
  code: z.string().min(1, "Le code est requis")
});

/**
 * Schéma pour la création d'un enregistrement de vérification sociale
 */
export const createSocialVerificationSchema = z.object({
  connectorId: z.string().min(1, "L'ID du connecteur est requis"),
  state: z.string().min(1, "L'état est requis"),
  redirectUri: z.string().url("L'URI de redirection doit être une URL valide"),
  code: z.string().optional(),
  authCode: z.string().optional()
}).refine(
  (data) => data.code || data.authCode, 
  { message: "Au moins un des champs 'code' ou 'authCode' doit être fourni" }
);

/**
 * Schéma pour la vérification d'un enregistrement social
 */
export const verifySocialVerificationSchema = z.object({
  interactionEvent: z.string().min(1, "L'événement d'interaction est requis"),
  data: z.record(z.any())
});

/**
 * Fonction de validation pour la création d'un enregistrement par mot de passe
 */
export function validateCreateVerificationByPassword(input: unknown) {
  return createVerificationByPasswordSchema.parse(input);
}

/**
 * Fonction de validation pour la création d'un enregistrement par code de vérification
 */
export function validateCreateVerificationByCode(input: unknown) {
  return createVerificationByCodeSchema.parse(input);
}

/**
 * Fonction de validation pour la vérification d'un code
 */
export function validateVerifyCode(input: unknown) {
  return verifyCodeSchema.parse(input);
}

/**
 * Fonction de validation pour la création d'un enregistrement de vérification sociale
 */
export function validateCreateSocialVerification(input: unknown) {
  return createSocialVerificationSchema.parse(input);
}

/**
 * Fonction de validation pour la vérification d'un enregistrement social
 */
export function validateVerifySocialVerification(input: unknown) {
  return verifySocialVerificationSchema.parse(input);
}
