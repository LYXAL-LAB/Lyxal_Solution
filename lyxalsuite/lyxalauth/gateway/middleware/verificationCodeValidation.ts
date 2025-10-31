import { z } from 'zod';

/**
 * Schéma pour la demande de code de vérification
 */
export const requestVerificationCodeSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().optional(),
  connectorId: z.string().optional(),
  purpose: z.enum(['Register', 'SignIn', 'ForgotPassword', 'Generic'])
}).refine(
  (data) => data.email || data.phone, 
  { message: "Au moins un des champs 'email' ou 'phone' doit être fourni" }
);

/**
 * Schéma pour la vérification de code
 */
export const verifyVerificationCodeSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().optional(),
  code: z.string().min(1, "Le code est requis"),
  purpose: z.enum(['Register', 'SignIn', 'ForgotPassword', 'Generic'])
}).refine(
  (data) => data.email || data.phone, 
  { message: "Au moins un des champs 'email' ou 'phone' doit être fourni" }
);

/**
 * Fonction de validation pour la demande de code de vérification
 */
export function validateRequestVerificationCode(input: unknown) {
  return requestVerificationCodeSchema.parse(input);
}

/**
 * Fonction de validation pour la vérification de code
 */
export function validateVerifyVerificationCode(input: unknown) {
  return verifyVerificationCodeSchema.parse(input);
}
